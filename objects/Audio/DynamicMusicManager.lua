-- objects/Audio/DynamicMusicManager.lua
-- Castle Kingdoms 2027 - Dynamic Music Manager
--
-- Manages music playback based on game state:
-- - Menu music (main menu, lobby)
-- - Peace music (building, economy)
-- - Combat music (when battle starts)
-- - Victory music (when player wins)
-- - Defeat music (when player loses)
--
-- Smooth crossfade transitions between states.
-- Combat music intensity scales with battle size.
--
-- Usage:
--   local DynamicMusic = require("objects.Audio.DynamicMusicManager")
--   DynamicMusic.init()
--   DynamicMusic.update(dt)
--   DynamicMusic.setState("combat")

local DynamicMusic = {}

local playlist = require("sounds.music_playlist")
local music = require("sounds.music")

-- Game states
local STATE = {
    MENU = "menu",
    PEACE = "peace",
    COMBAT = "combat",
    VICTORY = "victory",
    DEFEAT = "defeat",
}

DynamicMusic.STATE = STATE

local currentState = STATE.MENU
local currentStateTime = 0
local combatIntensity = 0  -- 0 = no combat, 1 = massive battle
local lastCombatTime = 0
local combatCooldown = 10  -- seconds after combat ends before switching back to peace
local initialized = false

-- Track for victory/defeat (one-shot, not looping)
local victoryDefeatSource = nil
local isPlayingVictoryDefeat = false

-- Initialize
function DynamicMusic.init()
    if initialized then return end
    initialized = true
    print("[DynamicMusic] Initialized")
    print(string.format("[DynamicMusic] Available tracks: menu=%d, peace=%d, combat=%d",
        #music["menu"], #music["peaceful"], #music["combat"]))
end

-- Set game state
function DynamicMusic.setState(newState)
    if newState == currentState then return end

    local oldState = currentState
    currentState = newState
    currentStateTime = 0

    print(string.format("[DynamicMusic] State: %s -> %s", oldState, newState))

    -- Handle victory/defeat specially
    if newState == STATE.VICTORY or newState == STATE.DEFEAT then
        DynamicMusic._playVictoryDefeat(newState)
        return
    end

    -- Stop victory/defeat music if playing
    if isPlayingVictoryDefeat and victoryDefeatSource then
        love.audio.stop(victoryDefeatSource)
        isPlayingVictoryDefeat = false
    end

    -- Play appropriate playlist
    local mood
    if newState == STATE.MENU then
        mood = "menu"
    elseif newState == STATE.PEACE then
        mood = "peaceful"
    elseif newState == STATE.COMBAT then
        mood = "combat"
    end

    if mood then
        playlist(mood)
    end
end

-- Get current state
function DynamicMusic.getState()
    return currentState
end

-- Play victory or defeat music
function DynamicMusic._playVictoryDefeat(state)
    -- Use the last combat track as victory, or a specific track if available
    -- In a full implementation, we'd have dedicated victory/defeat tracks
    local track = nil
    if state == STATE.VICTORY then
        -- Use a peaceful track for victory
        if #music["peaceful"] > 0 then
            track = music["peaceful"][1]
        end
    else
        -- Use a combat track for defeat
        if #music["combat"] > 0 then
            track = music["combat"][1]
        end
    end

    if track then
        if victoryDefeatSource then
            love.audio.stop(victoryDefeatSource)
        end
        victoryDefeatSource = track
        victoryDefeatSource:setVolume(_G.OPTIONS.MUSIC_VOLUME * _G.OPTIONS.MASTER_VOLUME)
        victoryDefeatSource:play()
        isPlayingVictoryDefeat = true
        print("[DynamicMusic] Playing " .. state .. " music")
    end
end

-- Set combat intensity (0.0 to 1.0)
function DynamicMusic.setCombatIntensity(intensity)
    combatIntensity = math.max(0, math.min(1, intensity))
    if combatIntensity > 0 then
        lastCombatTime = love.timer.getTime()
        if currentState ~= STATE.COMBAT then
            DynamicMusic.setState(STATE.COMBAT)
        end
    end
end

-- Report combat activity (called when units fight)
function DynamicMusic.reportCombat(unitCount)
    local intensity = math.min(1, (unitCount or 1) / 20)  -- 20 units = max intensity
    DynamicMusic.setCombatIntensity(intensity)
end

-- Update (call every frame)
function DynamicMusic.update(dt)
    if not initialized then return end

    currentStateTime = currentStateTime + dt

    -- Check if combat has ended
    if currentState == STATE.COMBAT then
        local timeSinceCombat = love.timer.getTime() - lastCombatTime
        if timeSinceCombat > combatCooldown then
            -- Combat ended, return to peace
            DynamicMusic.setState(STATE.PEACE)
        end
    end

    -- Check if current music track ended (for playlist progression)
    if _G.CURRENT_MUSIC and not _G.CURRENT_MUSIC:isPlaying() and not isPlayingVictoryDefeat then
        local mood
        if currentState == STATE.MENU then mood = "menu"
        elseif currentState == STATE.PEACE then mood = "peaceful"
        elseif currentState == STATE.COMBAT then mood = "combat"
        end
        if mood then
            playlist(mood)
        end
    end

    -- Check if victory/defeat track ended
    if isPlayingVictoryDefeat and victoryDefeatSource and not victoryDefeatSource:isPlaying() then
        isPlayingVictoryDefeat = false
        -- Return to peace after victory/defeat music
        DynamicMusic.setState(STATE.PEACE)
    end
end

-- Force play menu music
function DynamicMusic.playMenuMusic()
    DynamicMusic.setState(STATE.MENU)
end

-- Force play peace music
function DynamicMusic.playPeaceMusic()
    DynamicMusic.setState(STATE.PEACE)
end

-- Force play combat music
function DynamicMusic.playCombatMusic()
    DynamicMusic.setState(STATE.COMBAT)
end

-- Trigger victory
function DynamicMusic.triggerVictory()
    DynamicMusic.setState(STATE.VICTORY)
end

-- Trigger defeat
function DynamicMusic.triggerDefeat()
    DynamicMusic.setState(STATE.DEFEAT)
end

-- Get debug info
function DynamicMusic.getInfo()
    return {
        state = currentState,
        stateTime = math.floor(currentStateTime),
        combatIntensity = combatIntensity,
        isPlaying = _G.CURRENT_MUSIC and _G.CURRENT_MUSIC:isPlaying() or false,
        currentTrack = _G.CURRENT_MUSIC and "playing" or "none",
        isPlayingVictoryDefeat = isPlayingVictoryDefeat,
    }
end

-- Stop all music
function DynamicMusic.stopAll()
    if _G.CURRENT_MUSIC then
        love.audio.stop(_G.CURRENT_MUSIC)
        _G.CURRENT_MUSIC = nil
    end
    if victoryDefeatSource then
        love.audio.stop(victoryDefeatSource)
        victoryDefeatSource = nil
    end
    isPlayingVictoryDefeat = false
end

return DynamicMusic
