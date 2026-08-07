-- objects/Audio/AudioMixSystem.lua
-- Castle Kingdoms 2027 - Audio Mix System
--
-- Centralized audio management:
-- - Master/SFX/Music/Speech volume control
-- - Audio categories with independent volume
-- - Fade in/out for music tracks
-- - Dynamic music based on game state (menu, peace, combat, victory)
-- - 3D positional audio for combat
--
-- Usage:
--   local AudioMix = require("objects.Audio.AudioMixSystem")
--   AudioMix.init()
--   AudioMix.setVolume("master", 0.8)
--   AudioMix.playSfx("sword_hit", x, y)
--   AudioMix.playMusic("combat")

local AudioMix = {}

-- Volume levels (0.0 - 1.0)
local volumes = {
    master = 1.0,
    sfx = 1.0,
    music = 0.7,
    speech = 1.0,
    ambient = 0.5,
}

-- Audio categories
local CATEGORY = {
    SFX = "sfx",
    MUSIC = "music",
    SPEECH = "speech",
    AMBIENT = "ambient",
}

AudioMix.CATEGORY = CATEGORY

-- Currently playing music
local currentMusic = nil
local currentMusicSource = nil
local nextMusicSource = nil
local musicFadeTimer = 0
local musicFadeDuration = 2.0
local isFading = false

-- SFX cache
local sfxCache = {}

-- Music tracks (path -> source)
local musicTracks = {}

-- Initialize
function AudioMix.init()
    print("[AudioMix] Initialized")
    print(string.format("[AudioMix] Volumes: master=%.1f sfx=%.1f music=%.1f speech=%.1f",
        volumes.master, volumes.sfx, volumes.music, volumes.speech))
end

-- Set volume for a category
function AudioMix.setVolume(category, volume)
    if not volumes[category] then return false end
    volume = math.max(0, math.min(1, volume))
    volumes[category] = volume
    AudioMix._applyVolumes()
    return true
end

-- Get volume for a category
function AudioMix.getVolume(category)
    return volumes[category] or 0
end

-- Get all volumes
function AudioMix.getAllVolumes()
    return {
        master = volumes.master,
        sfx = volumes.sfx,
        music = volumes.music,
        speech = volumes.speech,
        ambient = volumes.ambient,
    }
end

-- Apply volumes to all playing audio
function AudioMix._applyVolumes()
    if currentMusicSource then
        currentMusicSource:setVolume(volumes.master * volumes.music)
    end
    -- SFX sources apply volume on play
end

-- Play a sound effect
-- @param name string SFX name (from sounds.fx)
-- @param x number World X position (for 3D audio, optional)
-- @param y number World Y position (optional)
function AudioMix.playSfx(name, x, y)
    if not _G.fx or not _G.fx[name] then return end

    local source = _G.fx[name]
    if type(source) == "table" then
        -- Random variant
        source = source[math.random(#source)]
    end

    if not source then return end

    -- Calculate volume based on distance (3D positional)
    local volume = volumes.master * volumes.sfx
    if x and y and _G.state and _G.state.viewXview then
        local screenX = _G.IsoToScreenX(x, y) - _G.state.viewXview
        local screenY = _G.IsoToScreenY(x, y) - _G.state.viewYview
        local centerX = love.graphics.getWidth() / 2
        local centerY = love.graphics.getHeight() / 2
        local dist = math.sqrt((screenX - centerX)^2 + (screenY - centerY)^2)
        local maxDist = 1500
        if dist > maxDist then return end  -- Too far to hear
        volume = volume * (1 - dist / maxDist)
    end

    source:setVolume(volume)
    source:stop()
    source:play()
end

-- Play speech (voice over)
function AudioMix.playSpeech(name)
    if not _G.speechFx or not _G.speechFx[name] then return end

    local source = _G.speechFx[name]
    if not source then return end

    source:setVolume(volumes.master * volumes.speech)
    source:stop()
    source:play()
end

-- Play music track
-- @param trackName string Track name: "menu", "peace", "combat", "victory", "defeat"
function AudioMix.playMusic(trackName)
    if currentMusic == trackName then return end

    -- Try to load track
    local trackPath = AudioMix._getMusicPath(trackName)
    if not trackPath then
        print("[AudioMix] No music track for: " .. trackName)
        return
    end

    -- Start fade transition
    nextMusicSource = love.audio.newSource(trackPath, "stream")
    if nextMusicSource then
        nextMusicSource:setLooping(true)
        nextMusicSource:setVolume(0)
        nextMusicSource:play()
        musicFadeTimer = 0
        isFading = true
        currentMusic = trackName
        print("[AudioMix] Playing music: " .. trackName)
    end
end

-- Get music file path for track name
function AudioMix._getMusicPath(trackName)
    local paths = {
        menu = "sounds/music/menu.ogg",
        peace = "sounds/music/peace.ogg",
        combat = "sounds/music/combat.ogg",
        victory = "sounds/music/victory.ogg",
        defeat = "sounds/music/defeat.ogg",
    }
    return paths[trackName]
end

-- Stop music
function AudioMix.stopMusic()
    if currentMusicSource then
        currentMusicSource:stop()
        currentMusicSource = nil
    end
    if nextMusicSource then
        nextMusicSource:stop()
        nextMusicSource = nil
    end
    currentMusic = nil
    isFading = false
end

-- Update audio system (call every frame)
function AudioMix.update(dt)
    -- Handle music fade transition
    if isFading then
        musicFadeTimer = musicFadeTimer + dt
        local progress = musicFadeTimer / musicFadeDuration

        if progress >= 1.0 then
            -- Fade complete
            if currentMusicSource then
                currentMusicSource:stop()
            end
            currentMusicSource = nextMusicSource
            nextMusicSource = nil
            if currentMusicSource then
                currentMusicSource:setVolume(volumes.master * volumes.music)
            end
            isFading = false
        else
            -- Crossfade
            if currentMusicSource then
                currentMusicSource:setVolume(volumes.master * volumes.music * (1 - progress))
            end
            if nextMusicSource then
                nextMusicSource:setVolume(volumes.master * volumes.music * progress)
            end
        end
    end
end

-- Mute/unmute all audio
function AudioMix.setMuted(muted)
    if muted then
        love.audio.setVolume(0)
    else
        love.audio.setVolume(1)
    end
end

-- Save volumes to settings
function AudioMix.save()
    return AudioMix.getAllVolumes()
end

-- Load volumes from settings
function AudioMix.load(data)
    if not data then return end
    for category, vol in pairs(data) do
        if volumes[category] then
            volumes[category] = vol
        end
    end
    AudioMix._applyVolumes()
    print("[AudioMix] Loaded volumes from settings")
end

return AudioMix
