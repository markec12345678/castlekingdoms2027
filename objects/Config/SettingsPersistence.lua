-- objects/Config/SettingsPersistence.lua
-- Stronghold 2027 - Settings Persistence
--
-- Saves and loads game settings to/from settings.json
-- Settings persist between game sessions.

local SettingsPersistence = {}

local SETTINGS_FILE = "settings.json"
local initialized = false

-- Default settings (used on first launch or reset)
local DEFAULT_SETTINGS = {
    -- Game feel
    screenShake = true,
    hitFlash = true,
    punchZoom = true,
    buildPreview = true,
    selectionGlow = true,
    combatOrderLines = true,
    weatherEffects = true,
    dynamicLighting = true,

    -- Camera
    cameraSmoothing = 5.0,

    -- Audio
    masterVolume = 1.0,
    musicVolume = 0.7,
    sfxVolume = 0.8,
    ambientVolume = 0.5,
    speechVolume = 0.9,

    -- Graphics
    fpsLimit = 60,        -- 0 = unlimited, 30/60/120/144
    vsync = true,
    fullscreen = false,
    borderless = false,
    resolutionW = 1920,
    resolutionH = 1080,

    -- Gameplay
    gameSpeed = 1.0,
    autoSave = true,
    showFps = false,
    useKenneyAssets = false,  -- CC0 asset toggle (Kenney vs original)
}

-- Current settings (loaded from file or defaults)
local currentSettings = {}

-- Initialize
function SettingsPersistence.init()
    if initialized then return end
    initialized = true
    SettingsPersistence.load()
    print("[SettingsPersistence] Initialized")
end

-- Load settings from file
function SettingsPersistence.load()
    -- Start with defaults
    currentSettings = {}
    for k, v in pairs(DEFAULT_SETTINGS) do
        currentSettings[k] = v
    end

    -- Try to load from file
    if love.filesystem then
        local content = love.filesystem.read("string", SETTINGS_FILE)
        if content then
            -- Parse JSON (using our json library)
            local json = require("libraries.json")
            local ok, loaded = pcall(json.decode, content)
            if ok and type(loaded) == "table" then
                -- Merge loaded settings over defaults (nil-safe)
                for k, v in pairs(loaded) do
                    currentSettings[k] = v
                end
                print("[SettingsPersistence] Settings loaded from " .. SETTINGS_FILE)
            else
                print("[SettingsPersistence] Could not parse settings file, using defaults")
            end
        else
            print("[SettingsPersistence] No settings file found, using defaults")
        end
    end

    return currentSettings
end

-- Save settings to file
function SettingsPersistence.save()
    if not love.filesystem then return false end

    local json = require("libraries.json")
    local content = json.encode(currentSettings)

    local ok, err = love.filesystem.write(SETTINGS_FILE, content)
    if ok then
        print("[SettingsPersistence] Settings saved to " .. SETTINGS_FILE)
        return true
    else
        print("[SettingsPersistence] Error saving settings: " .. tostring(err))
        return false
    end
end

-- Get a setting value
function SettingsPersistence.get(key)
    return currentSettings[key]
end

-- Set a setting value (and optionally save)
function SettingsPersistence.set(key, value, autoSave)
    currentSettings[key] = value
    if autoSave then
        SettingsPersistence.save()
    end
end

-- Get all settings
function SettingsPersistence.getAll()
    return currentSettings
end

-- Reset to defaults
function SettingsPersistence.reset()
    currentSettings = {}
    for k, v in pairs(DEFAULT_SETTINGS) do
        currentSettings[k] = v
    end
    SettingsPersistence.save()
    print("[SettingsPersistence] Settings reset to defaults")
    return currentSettings
end

-- Get defaults (for reference)
function SettingsPersistence.getDefaults()
    return DEFAULT_SETTINGS
end

-- Apply audio settings to SoundSystem
function SettingsPersistence.applyAudio()
    local SoundSystem = _G.SoundSystem
    if SoundSystem then
        SoundSystem.setVolume("master", currentSettings.masterVolume or 1.0)
        SoundSystem.setVolume("music", currentSettings.musicVolume or 0.7)
        SoundSystem.setVolume("sfx", currentSettings.sfxVolume or 0.8)
        SoundSystem.setVolume("ambient", currentSettings.ambientVolume or 0.5)
        SoundSystem.setVolume("speech", currentSettings.speechVolume or 0.9)
    end
end

-- Apply graphics settings
function SettingsPersistence.applyGraphics()
    if currentSettings.fpsLimit and currentSettings.fpsLimit > 0 then
        -- Set FPS limit via love.timer (if supported)
        if love.timer.setFPSLimit then
            love.timer.setFPSLimit(currentSettings.fpsLimit)
        end
    else
        if love.timer.setFPSLimit then
            love.timer.setFPSLimit(0)  -- unlimited
        end
    end

    -- VSync and fullscreen would require window mode change
    -- This is more complex and handled in conf.lua / window setup
end

-- Apply all settings to game systems
function SettingsPersistence.applyAll()
    -- Game feel
    if _G.GameFeel then
        _G.GameFeel.setShakeEnabled(currentSettings.screenShake)
        _G.GameFeel.setCameraSmoothing(currentSettings.cameraSmoothing or 5.0)
    end
    if _G.BuildPreview then
        _G.BuildPreview.setEnabled(currentSettings.buildPreview)
    end
    if _G.SelectionFeedback then
        _G.SelectionFeedback.setEnabled(currentSettings.selectionGlow)
    end
    if _G.CombatOrderViz then
        _G.CombatOrderViz.setEnabled(currentSettings.combatOrderLines)
    end

    -- Audio
    SettingsPersistence.applyAudio()

    -- Graphics
    SettingsPersistence.applyGraphics()

    -- CC0 Assets (Kenney)
    local KenneyAssetLoader = _G.KenneyAssetLoader
    if KenneyAssetLoader then
        KenneyAssetLoader.setEnabled(currentSettings.useKenneyAssets == true)
    end

    print("[SettingsPersistence] All settings applied")
end

return SettingsPersistence
