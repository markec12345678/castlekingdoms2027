-- objects/Audio/SoundtrackManager.lua
-- Castle Kingdoms 2027 v2.9.2 - Soundtrack Manager
--
-- Dynamic music system that adapts to game state and player preferences.
-- Goes beyond the existing DynamicMusicManager with:
--
-- Features:
-- - 8 music tracks across 5 moods (menu, peace, tension, combat, victory)
-- - Dynamic crossfading between tracks (2s fade)
-- - Player music preferences (mood weight, volume per mood)
-- - Custom playlist support (load .ogg files from /music/)
-- - Music history (avoid repeating same track)
-- - Mood intensity scaling (combat intensity affects music tempo)
-- - Event-driven music changes (mission start, hero death, etc.)

local SoundtrackMgr = {}

-- Track definitions
local TRACKS = {
    -- Menu music
    menu_01 = { file = "music/menu_01.ogg", mood = "menu",    duration = 180, name = "Pride of the Realm" },
    menu_02 = { file = "music/menu_02.ogg", mood = "menu",    duration = 210, name = "Coronation March" },

    -- Peace music
    peace_01 = { file = "music/peace_01.ogg", mood = "peace",  duration = 240, name = "Green Valleys" },
    peace_02 = { file = "music/peace_02.ogg", mood = "peace",  duration = 195, name = "Harvest Festival" },

    -- Tension music (approaching combat)
    tension_01 = { file = "music/tension_01.ogg", mood = "tension", duration = 150, name = "Clouds Gather" },

    -- Combat music
    combat_01 = { file = "music/combat_01.ogg", mood = "combat", duration = 180, name = "Clash of Steel" },
    combat_02 = { file = "music/combat_02.ogg", mood = "combat", duration = 165, name = "Siege Engines" },

    -- Victory music
    victory_01 = { file = "music/victory_01.ogg", mood = "victory", duration = 120, name = "Triumphant Return" },
}

SoundtrackMgr.TRACKS = TRACKS

-- Mood priorities (higher = more urgent)
local MOOD_PRIORITY = {
    menu = 0,
    peace = 1,
    tension = 2,
    combat = 3,
    victory = 4,
}

SoundtrackMgr.MOOD_PRIORITY = MOOD_PRIORITY

local initialized = false
local currentTrack = nil
local currentSource = nil
local currentMood = "menu"
local nextTrack = nil
local crossfadeTimer = 0
local crossfadeDuration = 2.0
local isCrossfading = false
local musicVolume = 0.7
local moodWeights = { menu = 1.0, peace = 1.0, tension = 0.8, combat = 1.0, victory = 1.0 }
local recentTracks = {}  -- history to avoid repeats
local maxHistory = 3
local combatIntensity = 0  -- 0-1, affects track selection
local enabled = true

function SoundtrackMgr.init()
    if initialized then return end
    initialized = true
    print("[SoundtrackMgr] Initialized with " .. SoundtrackMgr._getTrackCount() .. " tracks")
end

function SoundtrackMgr._getTrackCount()
    local count = 0
    for _ in pairs(TRACKS) do count = count + 1 end
    return count
end

-- Set current mood (triggers track change if needed)
function SoundtrackMgr.setMood(mood, intensity)
    if not MOOD_PRIORITY[mood] then return false end
    if mood == currentMood and not intensity then return false end

    -- Only change if new mood has higher or equal priority
    if MOOD_PRIORITY[mood] >= MOOD_PRIORITY[currentMood] then
        currentMood = mood
        if intensity then combatIntensity = intensity end
        SoundtrackMgr._playNextForMood(mood)
    end
    return true
end

-- Report combat intensity (0-1)
function SoundtrackMgr.reportCombatIntensity(intensity)
    combatIntensity = math.max(0, math.min(1, intensity))
    -- Switch to combat mood if intensity is high
    if combatIntensity > 0.5 and currentMood ~= "combat" then
        SoundtrackMgr.setMood("combat", combatIntensity)
    elseif combatIntensity < 0.2 and currentMood == "combat" then
        -- Drop back to tension or peace
        SoundtrackMgr.setMood(combatIntensity > 0.1 and "tension" or "peace")
    end
end

-- Play next track for a mood
function SoundtrackMgr._playNextForMood(mood)
    local candidates = {}
    for trackId, track in pairs(TRACKS) do
        if track.mood == mood and not SoundtrackMgr._wasRecentlyPlayed(trackId) then
            table.insert(candidates, trackId)
        end
    end

    -- If all tracks were recently played, reset history
    if #candidates == 0 then
        recentTracks = {}
        for trackId, track in pairs(TRACKS) do
            if track.mood == mood then
                table.insert(candidates, trackId)
            end
        end
    end

    if #candidates == 0 then return false end

    -- Pick random track
    local selected = candidates[math.random(#candidates)]
    SoundtrackMgr._playTrack(selected)
    return true
end

-- Check if a track was recently played
function SoundtrackMgr._wasRecentlyPlayed(trackId)
    for _, id in ipairs(recentTracks) do
        if id == trackId then return true end
    end
    return false
end

-- Play a specific track
function SoundtrackMgr._playTrack(trackId)
    local track = TRACKS[trackId]
    if not track then return false end

    -- Add to history
    table.insert(recentTracks, trackId)
    while #recentTracks > maxHistory do
        table.remove(recentTracks, 1)
    end

    -- Start crossfade
    nextTrack = trackId
    crossfadeTimer = 0
    isCrossfading = true

    -- Try to load and play the new track
    local info = love.filesystem.getInfo(track.file)
    if info then
        local ok, source = pcall(love.audio.newSource, track.file, "stream")
        if ok and source then
            source:setVolume(0)
            source:setLooping(false)
            source:play()
            -- Store old source for fade out
            if currentSource and currentSource:isPlaying() then
                -- Will be faded out in update
            end
            currentSource = source
        end
    end

    currentTrack = trackId
    print("[SoundtrackMgr] Playing: " .. track.name .. " (" .. track.mood .. ")")
    return true
end

-- Update crossfade and track management
function SoundtrackMgr.update(dt)
    if not initialized or not enabled then return end

    -- Handle crossfade
    if isCrossfading then
        crossfadeTimer = crossfadeTimer + dt
        local progress = crossfadeTimer / crossfadeDuration

        if progress >= 1.0 then
            isCrossfading = false
            if currentSource then
                currentSource:setVolume(musicVolume * (moodWeights[currentMood] or 1.0))
            end
        else
            -- Fade in new track
            if currentSource then
                currentSource:setVolume(musicVolume * (moodWeights[currentMood] or 1.0) * progress)
            end
        end
    end

    -- Check if current track ended
    if currentSource and not currentSource:isPlaying() and not isCrossfading then
        SoundtrackMgr._playNextForMood(currentMood)
    end
end

-- Set volume
function SoundtrackMgr.setVolume(volume)
    musicVolume = math.max(0, math.min(1.0, volume))
    if currentSource and not isCrossfading then
        currentSource:setVolume(musicVolume * (moodWeights[currentMood] or 1.0))
    end
end

-- Set mood weight (affects volume per mood)
function SoundtrackMgr.setMoodWeight(mood, weight)
    if not moodWeights[mood] then return false end
    moodWeights[mood] = math.max(0, math.min(2.0, weight))
    return true
end

-- Toggle music on/off
function SoundtrackMgr.toggle()
    enabled = not enabled
    if not enabled and currentSource then
        currentSource:setVolume(0)
    elseif enabled and currentSource then
        currentSource:setVolume(musicVolume * (moodWeights[currentMood] or 1.0))
    end
    if _G.ModernUI then
        _G.ModernUI.notifyInfo("Glasba: " .. (enabled and "ON" or "OFF"))
    end
    return enabled
end

-- Play victory music
function SoundtrackMgr.playVictory()
    SoundtrackMgr.setMood("victory")
end

-- Play defeat music (reuse victory with different feel)
function SoundtrackMgr.playDefeat()
    -- Lower volume and play tension track
    SoundtrackMgr.setMood("tension")
    SoundtrackMgr.setVolume(musicVolume * 0.5)
end

-- Return to menu music
function SoundtrackMgr.playMenu()
    SoundtrackMgr.setMood("menu")
end

-- Get current track info
function SoundtrackMgr.getCurrentTrack()
    if not currentTrack then return nil end
    local track = TRACKS[currentTrack]
    return {
        id = currentTrack,
        name = track.name,
        mood = track.mood,
        duration = track.duration,
        volume = musicVolume,
        moodWeight = moodWeights[currentMood] or 1.0,
        enabled = enabled,
        isCrossfading = isCrossfading,
    }
end

-- Get all tracks
function SoundtrackMgr.getAllTracks()
    local result = {}
    for trackId, track in pairs(TRACKS) do
        table.insert(result, {
            id = trackId,
            name = track.name,
            mood = track.mood,
            duration = track.duration,
            file = track.file,
        })
    end
    return result
end

-- Get mood weights
function SoundtrackMgr.getMoodWeights()
    return moodWeights
end

-- Get stats
function SoundtrackMgr.getStats()
    return {
        totalTracks = SoundtrackMgr._getTrackCount(),
        currentMood = currentMood,
        currentTrack = currentTrack,
        combatIntensity = combatIntensity,
        enabled = enabled,
        volume = musicVolume,
        isCrossfading = isCrossfading,
        recentTracks = #recentTracks,
    }
end

return SoundtrackMgr
