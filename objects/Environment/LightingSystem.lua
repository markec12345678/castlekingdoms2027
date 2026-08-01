-- objects/Environment/LightingSystem.lua
-- Stronghold 2027 - Dynamic Lighting System
--
-- Integrates HD shaders (bloom, color_grading, vignette, dynamic_lighting)
-- with the game loop. Provides:
-- - Day/night cycle (configurable speed)
-- - Torch lights at night
-- - Building lights (windows glow at night)
-- - Fire light flicker
-- - Smooth transitions between times of day
--
-- Usage:
--   local LightingSystem = require("objects.Environment.LightingSystem")
--   LightingSystem.init()
--   LightingSystem.update(dt)
--   LightingSystem.apply(canvas)  -- in draw

local LightingSystem = {}

local HDShaders = require("shaders.HD_SHADERS")

-- Day/night cycle configuration
local DAY_LENGTH = 600  -- 10 minutes = full day cycle (in seconds)
local START_TIME = 0.3  -- Start at morning (0=midnight, 0.5=noon)

-- State
local initialized = false
local timeOfDay = START_TIME  -- 0=midnight, 0.25=sunrise, 0.5=noon, 0.75=sunset
local dayLength = DAY_LENGTH
local paused = false

-- Torch light sources (dynamic lights)
local lightSources = {}

-- Initialize
function LightingSystem.init()
    if initialized then return end
    initialized = true

    -- Initialize HD shaders
    HDShaders.init()

    -- Enable relevant shaders
    HDShaders.enable("bloom", true)
    HDShaders.enable("color_grading", true)
    HDShaders.enable("vignette", true)
    HDShaders.enable("dynamic_lighting", true)

    -- Set initial time
    LightingSystem.updateSunPosition()

    print(string.format("[LightingSystem] Initialized (day length: %ds, time: %.2f)", dayLength, timeOfDay))
end

-- Set time of day (0-1)
-- 0.0 = midnight, 0.25 = sunrise, 0.5 = noon, 0.75 = sunset, 1.0 = midnight
function LightingSystem.setTimeOfDay(time)
    timeOfDay = time % 1.0
    LightingSystem.updateSunPosition()
    LightingSystem.updateShaderParams()
end

-- Get current time of day
function LightingSystem.getTimeOfDay()
    return timeOfDay
end

-- Get formatted time string (HH:MM)
function LightingSystem.getTimeString()
    -- Convert 0-1 to 24-hour format
    local hours24 = (timeOfDay * 24) % 24
    local h = math.floor(hours24)
    local m = math.floor((hours24 - h) * 60)
    return string.format("%02d:%02d", h, m)
end

-- Get time period name
function LightingSystem.getTimePeriod()
    if timeOfDay < 0.2 or timeOfDay > 0.8 then return "Night"
    elseif timeOfDay < 0.3 then return "Dawn"
    elseif timeOfDay < 0.45 then return "Morning"
    elseif timeOfDay < 0.55 then return "Noon"
    elseif timeOfDay < 0.7 then return "Afternoon"
    else return "Dusk" end
end

-- Set day length (in seconds)
function LightingSystem.setDayLength(seconds)
    dayLength = seconds
end

-- Pause/unpause day/night cycle
function LightingSystem.setPaused(state)
    paused = state
end

-- Update sun position based on time of day
function LightingSystem.updateSunPosition()
    -- Sun rises in east (right), sets in west (left)
    -- At noon, sun is at top
    local angle = (timeOfDay - 0.25) * math.pi * 2  -- 0 at sunrise, pi at sunset

    -- Sun position (normalized 0-1)
    local sunX = 0.5 + math.cos(angle) * 0.4
    local sunY = 0.5 - math.sin(angle) * 0.5  -- negative because Y is inverted in screen coords

    HDShaders.setParam("dynamic_lighting", "sunPosition", { sunX, sunY })

    -- Sun color shifts throughout the day
    local sunColor
    if timeOfDay < 0.2 or timeOfDay > 0.8 then
        -- Night: moonlight (cool blue)
        sunColor = { 0.3, 0.4, 0.7 }
    elseif timeOfDay < 0.3 then
        -- Dawn: warm orange
        local t = (timeOfDay - 0.2) / 0.1
        sunColor = {
            0.3 + t * 0.7,
            0.4 + t * 0.5,
            0.7 - t * 0.0,
        }
    elseif timeOfDay < 0.7 then
        -- Day: warm yellow-white
        sunColor = { 1.0, 0.95, 0.85 }
    else
        -- Dusk: deep orange
        local t = (timeOfDay - 0.7) / 0.1
        sunColor = {
            1.0 - t * 0.0,
            0.95 - t * 0.5,
            0.85 - t * 0.65,
        }
    end

    HDShaders.setParam("dynamic_lighting", "sunColor", sunColor)

    -- Ambient intensity (brighter during day)
    local ambientIntensity
    if timeOfDay < 0.2 or timeOfDay > 0.8 then
        -- Night
        ambientIntensity = 0.4
    elseif timeOfDay < 0.3 then
        -- Dawn transition
        local t = (timeOfDay - 0.2) / 0.1
        ambientIntensity = 0.4 + t * 0.6
    elseif timeOfDay < 0.7 then
        -- Day
        ambientIntensity = 1.0
    else
        -- Dusk transition
        local t = (timeOfDay - 0.7) / 0.1
        ambientIntensity = 1.0 - t * 0.6
    end

    HDShaders.setParam("dynamic_lighting", "ambientIntensity", ambientIntensity)
    HDShaders.setParam("dynamic_lighting", "timeOfDay", timeOfDay)
end

-- Update shader parameters for current time
function LightingSystem.updateShaderParams()
    -- Adjust color grading based on time of day
    if timeOfDay < 0.2 or timeOfDay > 0.8 then
        -- Night: cool blue tint, lower saturation
        HDShaders.setParam("color_grading", "shadows", { 0.7, 0.75, 0.9 })
        HDShaders.setParam("color_grading", "saturation", 0.85)
        HDShaders.setParam("color_grading", "brightness", -0.05)
    elseif timeOfDay < 0.3 or timeOfDay > 0.7 then
        -- Dawn/Dusk: warm orange tint
        HDShaders.setParam("color_grading", "shadows", { 0.9, 0.7, 0.5 })
        HDShaders.setParam("color_grading", "saturation", 1.1)
        HDShaders.setParam("color_grading", "brightness", 0.0)
    else
        -- Day: neutral
        HDShaders.setParam("color_grading", "shadows", { 0.9, 0.85, 0.8 })
        HDShaders.setParam("color_grading", "saturation", 1.15)
        HDShaders.setParam("color_grading", "brightness", 0.0)
    end

    -- Adjust vignette (more pronounced at night)
    if timeOfDay < 0.2 or timeOfDay > 0.8 then
        HDShaders.setParam("vignette", "intensity", 0.5)
        HDShaders.setParam("vignette", "radius", 0.7)
    else
        HDShaders.setParam("vignette", "intensity", 0.3)
        HDShaders.setParam("vignette", "radius", 0.85)
    end
end

-- Register a dynamic light source
-- @param id string Unique identifier
-- @param gx number World X position
-- @param gy number World Y position
-- @param radius number Light radius (in tiles)
-- @param color table {r, g, b} (0-1)
-- @param flicker boolean Whether light should flicker (for fire)
function LightingSystem.addLightSource(id, gx, gy, radius, color, flicker)
    lightSources[id] = {
        gx = gx,
        gy = gy,
        radius = radius or 5,
        color = color or { 1.0, 0.8, 0.5 },  -- warm orange by default
        flicker = flicker or false,
        flickerPhase = math.random() * math.pi * 2,
        intensity = 1.0,
    }
end

-- Remove a light source
function LightingSystem.removeLightSource(id)
    lightSources[id] = nil
end

-- Update light source position
function LightingSystem.updateLightSource(id, gx, gy)
    if lightSources[id] then
        lightSources[id].gx = gx
        lightSources[id].gy = gy
    end
end

-- Auto-detect light sources from game objects (torches, fires, etc.)
function LightingSystem.autoDetectLights()
    if not _G.state or not _G.state.gameObjectList then return end

    for _, obj in ipairs(_G.state.gameObjectList) do
        if obj.class and obj.class.name and obj.gx and obj.gy then
            local name = obj.class.name
            local lightId = "obj_" .. tostring(obj):match("0x(%x+)") or name

            -- Buildings with fire/light
            if name == "Campfire" then
                LightingSystem.addLightSource(lightId, obj.gx, obj.gy, 4, { 1.0, 0.6, 0.2 }, true)
            elseif name == "Bakery" or name == "Brewery" then
                LightingSystem.addLightSource(lightId, obj.gx, obj.gy, 3, { 1.0, 0.7, 0.3 }, true)
            elseif name == "Chapel" or name == "Church" or name == "Cathedral" then
                -- Only lit at night
                if timeOfDay < 0.2 or timeOfDay > 0.8 then
                    LightingSystem.addLightSource(lightId, obj.gx, obj.gy, 5, { 0.9, 0.85, 0.6 }, false)
                else
                    LightingSystem.removeLightSource(lightId)
                end
            end
        end
    end
end

-- Update lighting system (called every frame)
function LightingSystem.update(dt)
    if not initialized then return end

    -- Advance time of day
    if not paused then
        timeOfDay = (timeOfDay + dt / dayLength) % 1.0
    end

    -- Update sun position and shader params
    LightingSystem.updateSunPosition()
    LightingSystem.updateShaderParams()

    -- Update flicker on light sources
    for id, light in pairs(lightSources) do
        if light.flicker then
            light.flickerPhase = light.flickerPhase + dt * 8  -- 8 Hz flicker
            light.intensity = 0.85 + math.sin(light.flickerPhase) * 0.1 + math.random() * 0.05
        end
    end

    -- Auto-detect lights every 2 seconds (don't do every frame for performance)
    if not LightingSystem._lastLightDetect or love.timer.getTime() - LightingSystem._lastLightDetect > 2.0 then
        LightingSystem.autoDetectLights()
        LightingSystem._lastLightDetect = love.timer.getTime()
    end
end

-- Apply lighting shaders to a canvas
-- @param canvas Canvas to apply shaders to
-- @return Canvas New canvas with shaders applied
function LightingSystem.apply(canvas)
    if not initialized then return canvas end
    return HDShaders.apply(canvas)
end

-- Draw light source overlays (for visual debugging)
function LightingSystem.drawLights()
    if not initialized then return end

    for _, light in pairs(lightSources) do
        if light.gx and light.gy then
            -- Convert world to screen (simplified isometric)
            local screenX = light.gx * 32 - light.gy * 32
            local screenY = light.gx * 16 + light.gy * 16

            if _G.state and _G.state.viewXview then
                screenX = screenX - _G.state.viewXview
                screenY = screenY - _G.state.viewYview
            end

            local radius = light.radius * 32 * light.intensity

            -- Draw radial gradient light
            love.graphics.setColor(light.color[1], light.color[2], light.color[3], 0.3 * light.intensity)
            love.graphics.circle("fill", screenX, screenY, radius)
        end
    end

    love.graphics.setColor(1, 1, 1, 1)
end

-- Get lighting info (for debug overlay)
function LightingSystem.getInfo()
    return {
        timeOfDay = timeOfDay,
        timeString = LightingSystem.getTimeString(),
        timePeriod = LightingSystem.getTimePeriod(),
        paused = paused,
        dayLength = dayLength,
        lightCount = #lightSources,
        shadersEnabled = {
            bloom = HDShaders.isEnabled("bloom"),
            color_grading = HDShaders.isEnabled("color_grading"),
            vignette = HDShaders.isEnabled("vignette"),
            dynamic_lighting = HDShaders.isEnabled("dynamic_lighting"),
        },
    }
end

-- Force a specific time period (for testing or scenarios)
function LightingSystem.setTimePeriod(period)
    if period == "dawn" then LightingSystem.setTimeOfDay(0.25)
    elseif period == "day" then LightingSystem.setTimeOfDay(0.5)
    elseif period == "dusk" then LightingSystem.setTimeOfDay(0.75)
    elseif period == "night" then LightingSystem.setTimeOfDay(0.0)
    end
end

-- Reset (for new game)
function LightingSystem.reset()
    timeOfDay = START_TIME
    lightSources = {}
    LightingSystem.updateSunPosition()
    LightingSystem.updateShaderParams()
end

return LightingSystem
