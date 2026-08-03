-- objects/Config/ConfigProfileSystem.lua
-- Stronghold 2027 - Config Profile System
-- Preset graphics profiles for different hardware

local ConfigProfiles = {}

local PROFILES = {
    ultra = {
        name = "Ultra (4K, RTX)",
        description = "Maximum quality for high-end hardware",
        settings = {
            quality = 4,  -- PerfWatchdog.QUALITY.ULTRA
            bloom = true,
            ssao = true,
            colorGrading = true,
            vignette = true,
            dynamicLighting = true,
            normalMapping = true,
            toneMapping = true,
            hdPipeline = true,
            maxFPS = 144,
            shadowQuality = "high",
            textureFilter = "anisotropic",
        },
    },
    high = {
        name = "High (1080p, GTX)",
        description = "High quality for modern hardware",
        settings = {
            quality = 3,
            bloom = true,
            ssao = false,
            colorGrading = true,
            vignette = true,
            dynamicLighting = true,
            normalMapping = true,
            toneMapping = true,
            hdPipeline = true,
            maxFPS = 60,
            shadowQuality = "medium",
            textureFilter = "linear",
        },
    },
    medium = {
        name = "Medium (720p, Integrated)",
        description = "Balanced quality for mid-range hardware",
        settings = {
            quality = 2,
            bloom = false,
            ssao = false,
            colorGrading = true,
            vignette = false,
            dynamicLighting = true,
            normalMapping = false,
            toneMapping = true,
            hdPipeline = true,
            maxFPS = 60,
            shadowQuality = "low",
            textureFilter = "linear",
        },
    },
    low = {
        name = "Low (Potato, Laptop)",
        description = "Minimum quality for older hardware",
        settings = {
            quality = 1,
            bloom = false,
            ssao = false,
            colorGrading = false,
            vignette = false,
            dynamicLighting = false,
            normalMapping = false,
            toneMapping = false,
            hdPipeline = false,
            maxFPS = 30,
            shadowQuality = "off",
            textureFilter = "nearest",
        },
    },
    custom = {
        name = "Custom",
        description = "User-defined settings",
        settings = {},
    },
}

ConfigProfiles.PROFILES = PROFILES

local currentProfile = "high"
local initialized = false

function ConfigProfiles.init()
    if initialized then return end
    initialized = true
    ConfigProfiles._loadSavedProfile()
    print("[ConfigProfiles] Initialized (profile: " .. currentProfile .. ")")
end

-- Apply a profile
function ConfigProfiles.apply(profileName)
    local profile = PROFILES[profileName]
    if not profile then
        print("[ConfigProfiles] Unknown profile: " .. tostring(profileName))
        return false
    end

    currentProfile = profileName
    local settings = profile.settings

    -- Apply to PerfWatchdog
    local PerfWatchdog = require("objects.QA.PerformanceWatchdog")
    if PerfWatchdog and settings.quality then
        PerfWatchdog.setQuality(settings.quality)
    end

    -- Apply to HD Shaders
    local HDShaders = require("shaders.HD_SHADERS")
    if HDShaders then
        HDShaders.enable("bloom", settings.bloom ~= false)
        HDShaders.enable("color_grading", settings.colorGrading ~= false)
        HDShaders.enable("vignette", settings.vignette ~= false)
        HDShaders.enable("dynamic_lighting", settings.dynamicLighting ~= false)
    end

    -- Apply to HD Render Pipeline
    local HDRenderPipeline = require("objects.Environment.HDRenderPipeline")
    if HDRenderPipeline then
        HDRenderPipeline.setEnabled(settings.hdPipeline ~= false)
    end

    -- Save preference
    ConfigProfiles._saveProfile(profileName)

    print("[ConfigProfiles] Applied profile: " .. profileName .. " (" .. profile.name .. ")")
    return true
end

-- Get current profile
function ConfigProfiles.getCurrentProfile()
    return currentProfile
end

-- Get profile info
function ConfigProfiles.getProfileInfo(name)
    return PROFILES[name]
end

-- Get all profiles
function ConfigProfiles.getAllProfiles()
    local list = {}
    for name, profile in pairs(PROFILES) do
        table.insert(list, {
            name = name,
            displayName = profile.name,
            description = profile.description,
        })
    end
    return list
end

-- Auto-detect best profile based on system
function ConfigProfiles.autoDetect()
    local w, h = love.graphics.getDimensions()
    local totalPixels = w * h

    -- Estimate GPU capability based on screen resolution
    if totalPixels >= 3840 * 2160 then
        -- 4K
        ConfigProfiles.apply("ultra")
    elseif totalPixels >= 1920 * 1080 then
        -- 1080p
        ConfigProfiles.apply("high")
    elseif totalPixels >= 1280 * 720 then
        -- 720p
        ConfigProfiles.apply("medium")
    else
        -- Low res
        ConfigProfiles.apply("low")
    end

    print("[ConfigProfiles] Auto-detected profile: " .. currentProfile)
    return currentProfile
end

-- Save profile preference
function ConfigProfiles._saveProfile(name)
    local file = love.filesystem.newFile("config_profile.txt")
    if file:open("w") then
        file:write(name)
        file:close()
    end
end

-- Load saved profile
function ConfigProfiles._loadSavedProfile()
    local file = love.filesystem.newFile("config_profile.txt")
    if file:open("r") then
        local name = file:read()
        file:close()
        if name and PROFILES[name] then
            currentProfile = name
        end
    end
end

-- Get settings for current profile
function ConfigProfiles.getSettings()
    local profile = PROFILES[currentProfile]
    return profile and profile.settings or {}
end

return ConfigProfiles
