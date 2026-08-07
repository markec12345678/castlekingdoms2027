-- objects/Audio/SFXLibrary.lua
-- Castle Kingdoms 2027 - SFX Library
--
-- Organized sound effects library with categories:
-- - Combat (sword hits, arrow shots, death sounds)
-- - Building (construction, destruction, placement)
-- - UI (button clicks, menu sounds, notifications)
-- - Environment (water, fire, wind, birds)
-- - Speech (Slovenian voice over notifications)
--
-- All SFX support 3D positional audio (distance-based volume).
--
-- Usage:
--   local SFX = require("objects.Audio.SFXLibrary")
--   SFX.init()
--   SFX.play("combat", "sword_hit", gx, gy)
--   SFX.play("ui", "button_click")

local SFXLibrary = {}

local initialized = false
local sfxCategories = {}

-- SFX category definitions
-- Each category maps logical names to actual sound source names from _G.fx
local CATEGORY_MAP = {
    combat = {
        sword_hit    = { "armourhit_01", "armourhit_02", "armourhit_03", "armourhit_04", "armourhit_05" },
        arrow_shoot  = { "arrowshoot1 22k", "arrowbasic_01", "arrowbasic_02" },
        arrow_hit    = { "arrowhit4 22k", "arrowstab_01", "arrbounce1", "arrbounce4" },
        army_charge  = { "armycharge1", "armycharge2" },
        shield_block = { "shieldclick" },
        death        = { "deathmale1", "deathmale2", "deathmale3", "deathfemale1" },
    },
    building = {
        place        = { "woodpush2", "woodpush3" },
        construct    = { "woodrollover2", "woodrollover3" },
        destroy      = { "building_collapse1", "building_collapse2" },
    },
    ui = {
        button_click = { "woodpush2" },
        button_hover = { "woodrollover2", "woodrollover3", "woodrollover7", "woodrollover8" },
        menu_open    = { "action_bar_rotate" },
        menu_close   = { "woodpush3" },
        error        = { "error_beep" },
        success      = { "success_chime" },
        notification = { "notification" },
    },
    environment = {
        water        = { "streamlp_02" },
        fire         = { "fire_loop" },
    },
    -- Castle Kingdoms 2027 v2.5.8: New SFX categories
    siege = {
        catapult_fire    = { "catapult_fire_01", "catapult_fire_02" },
        trebuchet_fire   = { "trebuchet_fire_01" },
        ram_hit          = { "ram_hit_01", "ram_hit_02", "ram_hit_03" },
        tower_deploy     = { "tower_deploy_01" },
        wall_collapse    = { "wall_collapse_01", "wall_collapse_02" },
    },
    festival = {
        cheer        = { "crowd_cheer_01", "crowd_cheer_02" },
        fanfare      = { "fanfare_01" },
        bell         = { "bell_ring_01", "bell_ring_02" },
    },
    weather = {
        rain         = { "rain_loop" },
        thunder      = { "thunder_01", "thunder_02", "thunder_03" },
        wind         = { "wind_loop" },
    },
    veterancy = {
        level_up     = { "level_up_01", "level_up_02" },
        legendary    = { "legendary_fanfare" },
    },
}

-- Initialize
function SFXLibrary.init()
    if initialized then return end
    initialized = true

    -- Build category lookup
    for category, sounds in pairs(CATEGORY_MAP) do
        sfxCategories[category] = sounds
    end

    local totalSounds = 0
    for _, sounds in pairs(sfxCategories) do
        for _, aliases in pairs(sounds) do
            totalSounds = totalSounds + #aliases
        end
    end

    print(string.format("[SFXLibrary] Initialized (%d sound aliases across %d categories)",
        totalSounds, #sfxCategories))
end

-- Play a sound effect
-- @param category string Category name (combat, building, ui, environment)
-- @param name string Logical sound name
-- @param gx number World X position (optional, for 3D audio)
-- @param gy number World Y position (optional)
-- @param volume number Volume override (0-1, optional)
function SFXLibrary.play(category, name, gx, gy, volume)
    if not initialized then return end
    if not _G.fx then return end

    local cat = sfxCategories[category]
    if not cat then
        print("[SFXLibrary] Unknown category: " .. tostring(category))
        return
    end

    local aliases = cat[name]
    if not aliases then
        print("[SFXLibrary] Unknown sound: " .. category .. "." .. name)
        return
    end

    -- Pick random alias
    local alias = aliases[math.random(#aliases)]
    local source = _G.fx[alias]

    if not source then
        -- Try the alias directly as a fx name
        source = _G.fx[name]
    end

    if not source then return end

    -- Handle table of sources (random variant)
    if type(source) == "table" then
        source = source[math.random(#source)]
    end

    if not source then return end

    -- Calculate volume
    local finalVolume = volume or 1.0

    -- 3D positional audio (distance-based)
    if gx and gy and _G.state and _G.state.viewXview then
        local screenX = _G.IsoToScreenX(gx, gy) - _G.state.viewXview
        local screenY = _G.IsoToScreenY(gx, gy) - _G.state.viewYview
        local centerX = love.graphics.getWidth() / 2
        local centerY = love.graphics.getHeight() / 2
        local dist = math.sqrt((screenX - centerX)^2 + (screenY - centerY)^2)
        local maxDist = 2000
        if dist > maxDist then return end  -- Too far
        finalVolume = finalVolume * (1 - (dist / maxDist) * 0.7)
    end

    -- Apply volume settings
    if _G.OPTIONS then
        finalVolume = finalVolume * (_G.OPTIONS.EFFECTS_VOLUME or 1) * (_G.OPTIONS.MASTER_VOLUME or 1)
    end

    source:setVolume(math.max(0, math.min(1, finalVolume)))
    source:stop()
    source:play()
end

-- Play combat sound
function SFXLibrary.playCombat(name, gx, gy)
    SFXLibrary.play("combat", name, gx, gy)
end

-- Play building sound
function SFXLibrary.playBuilding(name, gx, gy)
    SFXLibrary.play("building", name, gx, gy)
end

-- Play UI sound (no position, always full volume)
function SFXLibrary.playUI(name)
    SFXLibrary.play("ui", name)
end

-- Play environment sound
function SFXLibrary.playEnvironment(name, gx, gy)
    SFXLibrary.play("environment", name, gx, gy)
end

-- Get available sounds in a category
function SFXLibrary.getCategorySounds(category)
    return sfxCategories[category] or {}
end

-- Get all categories
function SFXLibrary.getCategories()
    local cats = {}
    for cat, _ in pairs(sfxCategories) do
        table.insert(cats, cat)
    end
    return cats
end

-- Get stats
function SFXLibrary.getStats()
    local stats = {
        categories = #sfxCategories,
        totalSounds = 0,
    }
    for _, sounds in pairs(sfxCategories) do
        for _, aliases in pairs(sounds) do
            stats.totalSounds = stats.totalSounds + #aliases
        end
    end
    return stats
end

return SFXLibrary
