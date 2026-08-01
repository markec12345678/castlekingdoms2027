-- objects/Audio/SoundSystem.lua
-- Stronghold 2027 - Advanced Sound System
--
-- Manages all game audio:
-- - Ambient sounds (wind, birds, fire, rain) with crossfading
-- - SFX with distance attenuation
-- - Combat sounds (arrows, swords, death cries)
-- - UI sounds (clicks, hovers)
-- - Music transitions (explore -> combat -> victory)
--
-- Usage:
--   local SoundSystem = require("objects.Audio.SoundSystem")
--   SoundSystem.init()
--   SoundSystem.update(dt)
--   SoundSystem.playAmbient("wind")
--   SoundSystem.playSfx("arrow_shoot", gx, gy)

local SoundSystem = {}

-- Master volumes (configurable via settings)
local volumes = {
    master = 1.0,
    music = 0.7,
    sfx = 0.8,
    ambient = 0.5,
    speech = 0.9,
}

-- Ambient sound definitions (looped, crossfaded)
local AMBIENTS = {
    wind = { file = "sounds/fx/wind_loop.ogg", volume = 0.4, crossfadeTime = 2.0 },
    birds = { file = "sounds/fx/birds_loop.ogg", volume = 0.3, crossfadeTime = 3.0 },
    fire = { file = "sounds/fx/fire_loop.ogg", volume = 0.5, crossfadeTime = 1.0 },
    rain = { file = "sounds/fx/rain_loop.ogg", volume = 0.6, crossfadeTime = 2.0 },
    crowd = { file = "sounds/fx/crowd_loop.ogg", volume = 0.3, crossfadeTime = 2.0 },
}

-- SFX mappings (with variations)
local SFX_MAP = {
    -- Combat sounds
    arrow_shoot = { files = {"arrowswish1 22k", "arrowswish2 22k", "arrowshoot1 22k"}, category = "sfx" },
    arrow_hit = { files = {"arrowhit4 22k", "arrowstab_01", "arrbounce1", "arrbounce4"}, category = "sfx" },
    sword_hit = { files = {"armourhit_01", "armourhit_02", "armourhit_03", "armourhit_04", "armourhit_05"}, category = "sfx" },
    sword_swing = { files = {"swordswing_01", "swordswing_02", "swordswing_03"}, category = "sfx" },
    death_male = { files = {"arrwdth_01", "arrwdth_02", "arrwdth_03", "arrwdth_04"}, category = "sfx" },
    death_female = { files = {"arrwdth_05", "arrwdth_06", "arrwdth_07", "arrwdth_08"}, category = "sfx" },
    army_charge = { files = {"armycharge1", "armycharge2"}, category = "sfx" },
    shield_hit = { files = {"Shieldclick"}, category = "sfx" },

    -- UI sounds
    ui_click = { files = {"action_bar_rotate"}, category = "sfx" },
    ui_hover = { files = {"action_bar_rotate"}, category = "sfx", volume = 0.3 },

    -- Building sounds
    build_place = { files = {"action_bar_rotate"}, category = "sfx" },
    build_destroy = { files = {"armourhit_01"}, category = "sfx" },

    -- Environment
    footstep_grass = { files = {"footstep_grass_1", "footstep_grass_2", "footstep_grass_3", "footstep_grass_4", "footstep_grass_5"}, category = "sfx", volume = 0.4 },
    footstep_stone = { files = {"footstep_stone_1", "footstep_stone_2"}, category = "sfx", volume = 0.4 },
}

-- Music state
local MUSIC_STATES = {
    menu = { playlist = "menu", volume = 0.6 },
    explore = { playlist = "explore", volume = 0.5 },
    combat = { playlist = "combat", volume = 0.7, crossfadeTime = 1.0 },
    victory = { playlist = "victory", volume = 0.8, crossfadeTime = 2.0 },
    defeat = { playlist = "defeat", volume = 0.8, crossfadeTime = 2.0 },
}

-- State
local initialized = false
local activeAmbients = {}  -- Currently playing ambient sources
local ambientTargets = {}  -- Target volumes for crossfading
local currentMusicState = "explore"
local soundCache = {}      -- Cached Sound sources
local lastCombatSound = 0
local combatMusicCooldown = 5.0  -- seconds before returning to explore music

-- Initialize the sound system
function SoundSystem.init()
    if initialized then return end
    initialized = true

    print("[SoundSystem] Initialized")
    print(string.format("[SoundSystem] Volumes: master=%.1f, music=%.1f, sfx=%.1f, ambient=%.1f",
        volumes.master, volumes.music, volumes.sfx, volumes.ambient))
end

-- Set master volume for a category
function SoundSystem.setVolume(category, volume)
    if not volumes[category] then
        print("[SoundSystem] Unknown category: " .. tostring(category))
        return false
    end
    volumes[category] = math.max(0, math.min(1, volume))
    return true
end

-- Get volume for a category
function SoundSystem.getVolume(category)
    return volumes[category] or 1.0
end

-- Play an ambient sound (looped, crossfaded)
function SoundSystem.playAmbient(name, targetVolume)
    if not AMBIENTS[name] then
        print("[SoundSystem] Unknown ambient: " .. tostring(name))
        return false
    end

    local ambient = AMBIENTS[name]

    -- Already playing?
    if activeAmbients[name] then
        -- Update target volume
        ambientTargets[name] = targetVolume or ambient.volume
        return true
    end

    -- Try to load the sound file
    local ok, source = pcall(love.audio.newSource, ambient.file, "stream")
    if not ok or not source then
        print("[SoundSystem] Could not load ambient: " .. ambient.file)
        return false
    end

    source:setLooping(true)
    source:setVolume(0)  -- Start silent, fade in
    source:play()

    activeAmbients[name] = source
    ambientTargets[name] = targetVolume or ambient.volume

    return true
end

-- Stop an ambient sound (with crossfade)
function SoundSystem.stopAmbient(name, fadeTime)
    if not activeAmbients[name] then return false end
    ambientTargets[name] = 0  -- Will fade out and be removed
    return true
end

-- Stop all ambients
function SoundSystem.stopAllAmbients()
    for name, _ in pairs(activeAmbients) do
        ambientTargets[name] = 0
    end
end

-- Play a SFX with optional position (for distance attenuation)
-- @param sfxName string Key from SFX_MAP
-- @param gx number Optional world X position (for 3D audio)
-- @param gy number Optional world Y position
function SoundSystem.playSfx(sfxName, gx, gy)
    if not SFX_MAP[sfxName] then
        print("[SoundSystem] Unknown SFX: " .. tostring(sfxName))
        return false
    end

    local sfx = SFX_MAP[sfxName]
    local variation = sfx.files[math.random(#sfx.files)]
    local filename = "sounds/fx/" .. variation .. ".ogg"

    -- Try to get from cache or load
    local source = soundCache[filename]
    if not source then
        local ok, src = pcall(love.audio.newSource, filename, "static")
        if not ok or not src then
            print("[SoundSystem] Could not load SFX: " .. filename)
            return false
        end
        soundCache[filename] = src
        source = src
    end

    -- Calculate volume based on distance (if position provided)
    local finalVolume = sfx.volume or 1.0
    if gx and gy and _G.state and _G.state.viewXview then
        -- Get camera position (simplified)
        local camX = love.graphics.getWidth() / 2
        local camY = love.graphics.getHeight() / 2

        -- Convert world to screen coords (simplified isometric)
        local screenX = gx * 32 - gy * 32
        local screenY = gx * 16 + gy * 16

        local dx = screenX - camX
        local dy = screenY - camY
        local distance = math.sqrt(dx * dx + dy * dy)

        -- Attenuation: full volume within 200px, fade to 0 at 1000px
        local maxDistance = 1000
        local fullVolumeRadius = 200
        if distance > maxDistance then
            finalVolume = 0
        else
            finalVolume = finalVolume * (1 - math.max(0, (distance - fullVolumeRadius) / (maxDistance - fullVolumeRadius)))
        end

        -- Stereo panning
        if distance < maxDistance then
            local pan = math.max(-1, math.min(1, dx / 500))
            source:setPosition(pan, 0, 0)
        end
    end

    -- Apply volume settings
    finalVolume = finalVolume * volumes.sfx * volumes.master
    source:setVolume(finalVolume)

    -- Play (clone if already playing to allow overlapping)
    source:stop()
    source:play()

    return true
end

-- Play UI sound (no position, full volume)
function SoundSystem.playUi(sfxName)
    return SoundSystem.playSfx(sfxName)
end

-- Set music state (with crossfade)
function SoundSystem.setMusicState(state)
    if not MUSIC_STATES[state] then
        print("[SoundSystem] Unknown music state: " .. tostring(state))
        return false
    end

    if currentMusicState == state then return true end

    local prevState = currentMusicState
    currentMusicState = state

    print(string.format("[SoundSystem] Music transition: %s -> %s", prevState, state))

    -- TODO: Actual music crossfade when we have music files for each state
    -- For now, just log the transition

    return true
end

-- Trigger combat music (called when combat starts)
function SoundSystem.onCombatStart()
    SoundSystem.setMusicState("combat")
    lastCombatSound = love.timer.getTime()
end

-- Called when combat ends (check if should return to explore music)
function SoundSystem.onCombatEnd()
    -- Don't immediately switch - wait for cooldown
    -- (in case another combat starts soon)
end

-- Update sound system (called every frame)
function SoundSystem.update(dt)
    if not initialized then return end

    -- Crossfade ambients
    for name, source in pairs(activeAmbients) do
        local target = (ambientTargets[name] or 0) * volumes.ambient * volumes.master
        local current = source:getVolume()
        local diff = target - current
        local fadeSpeed = (AMBIENTS[name] and AMBIENTS[name].crossfadeTime or 2.0)

        if math.abs(diff) < 0.01 then
            -- Reached target
            source:setVolume(target)
            if target == 0 then
                -- Stop and remove
                source:stop()
                activeAmbients[name] = nil
                ambientTargets[name] = nil
            end
        else
            -- Fade toward target
            local step = (diff / fadeSpeed) * dt
            source:setVolume(current + step)
        end
    end

    -- Check if combat music should end
    if currentMusicState == "combat" then
        if love.timer.getTime() - lastCombatSound > combatMusicCooldown then
            SoundSystem.setMusicState("explore")
        end
    end

    -- Auto-adjust ambients based on game state
    SoundSystem.updateAmbientContext()
end

-- Auto-adjust ambient sounds based on what's happening
function SoundSystem.updateAmbientContext()
    if not _G.state or not _G.state.gameObjectList then return end

    local hasFire = false
    local hasCrowd = false
    local combatActive = false

    for _, obj in ipairs(_G.state.gameObjectList) do
        if obj.class and obj.class.name then
            local name = obj.class.name
            if name == "Campfire" or name == "Bakery" or name == "Brewery" then
                hasFire = true
            end
            if name == "Inn" or name == "Market" then
                hasCrowd = true
            end
        end
        if obj.combatState and obj.combatState ~= "idle" and obj.combatState ~= "dead" then
            combatActive = true
        end
    end

    -- Manage ambients
    if hasFire then
        SoundSystem.playAmbient("fire", 0.3)
    else
        SoundSystem.stopAmbient("fire")
    end

    if hasCrowd then
        SoundSystem.playAmbient("crowd", 0.3)
    else
        SoundSystem.stopAmbient("crowd")
    end

    -- Wind always on (unless indoors)
    if not activeAmbients.wind then
        SoundSystem.playAmbient("wind", 0.3)
    end

    -- Birds when not in combat
    if not combatActive then
        if not activeAmbients.birds then
            SoundSystem.playAmbient("birds", 0.25)
        end
    else
        SoundSystem.stopAmbient("birds")
    end

    -- Music state
    if combatActive and currentMusicState ~= "combat" then
        SoundSystem.onCombatStart()
    elseif not combatActive and currentMusicState == "combat" then
        SoundSystem.onCombatEnd()
    end
end

-- Get active ambients (for debug)
function SoundSystem.getActiveAmbients()
    local list = {}
    for name, source in pairs(activeAmbients) do
        table.insert(list, {
            name = name,
            volume = source:getVolume(),
            target = ambientTargets[name] or 0,
        })
    end
    return list
end

-- Get current music state
function SoundSystem.getCurrentMusicState()
    return currentMusicState
end

-- Get stats
function SoundSystem.getStats()
    return {
        activeAmbients = #SoundSystem.getActiveAmbients(),
        cachedSounds = #soundCache,
        musicState = currentMusicState,
        volumes = volumes,
    }
end

-- Clear cache (for memory management)
function SoundSystem.clearCache()
    soundCache = {}
    collectgarbage("collect")
    print("[SoundSystem] Cache cleared")
end

-- Reset (for new game/load)
function SoundSystem.reset()
    SoundSystem.stopAllAmbients()
    currentMusicState = "explore"
    print("[SoundSystem] Reset")
end

return SoundSystem
