-- objects/Weather/WeatherSystem.lua
-- Castle Kingdoms 2027 - Weather System
--
-- Manages weather effects: rain, snow, fog, clear
-- Each weather has:
-- - Particle effects (visual)
-- - Sound effects (via SoundSystem)
-- - Lighting adjustments (via shaders)
-- - Gameplay effects (e.g., rain slows units)
--
-- Usage:
--   local WeatherSystem = require("objects.Weather.WeatherSystem")
--   WeatherSystem.init()
--   WeatherSystem.update(dt)
--   WeatherSystem.setWeather("rain")

local WeatherSystem = {}

-- Weather definitions
local WEATHER_TYPES = {
    clear = {
        particleCount = 0,
        ambientSound = nil,
        lightAdjust = { r = 1.0, g = 1.0, b = 1.0 },
        speedMultiplier = 1.0,
        transitionTime = 3.0,
    },
    rain = {
        particleCount = 300,
        ambientSound = "rain",
        lightAdjust = { r = 0.7, g = 0.75, b = 0.8 },
        speedMultiplier = 0.85,  -- 15% slower
        transitionTime = 2.0,
        particleType = "rain",
    },
    heavy_rain = {
        particleCount = 600,
        ambientSound = "rain",
        lightAdjust = { r = 0.6, g = 0.65, b = 0.7 },
        speedMultiplier = 0.7,
        transitionTime = 2.0,
        particleType = "rain",
    },
    snow = {
        particleCount = 200,
        ambientSound = "wind",
        lightAdjust = { r = 0.9, g = 0.9, b = 1.0 },
        speedMultiplier = 0.8,
        transitionTime = 4.0,
        particleType = "snow",
    },
    fog = {
        particleCount = 0,
        ambientSound = "wind",
        lightAdjust = { r = 0.85, g = 0.85, b = 0.85 },
        speedMultiplier = 0.95,
        transitionTime = 5.0,
        fogDensity = 0.5,
    },
    storm = {
        particleCount = 800,
        ambientSound = "rain",
        lightAdjust = { r = 0.5, g = 0.55, b = 0.6 },
        speedMultiplier = 0.6,
        transitionTime = 1.5,
        particleType = "rain",
        hasLightning = true,
    },
}

-- State
local initialized = false
local currentWeather = "clear"
local targetWeather = "clear"
local transitionProgress = 1.0  -- 0 = transition start, 1 = complete
local currentLight = { r = 1.0, g = 1.0, b = 1.0 }
local targetLight = { r = 1.0, g = 1.0, b = 1.0 }
local particles = {}
local lightningTimer = 0
local lightningFlash = 0
local lastWeatherChange = 0

-- Initialize
function WeatherSystem.init()
    if initialized then return end
    initialized = true
    currentWeather = "clear"
    targetWeather = "clear"
    transitionProgress = 1.0
    currentLight = { r = 1.0, g = 1.0, b = 1.0 }
    targetLight = { r = 1.0, g = 1.0, b = 1.0 }
    print("[WeatherSystem] Initialized (weather: " .. currentWeather .. ")")
end

-- Set weather (with smooth transition)
function WeatherSystem.setWeather(weatherType)
    if not WEATHER_TYPES[weatherType] then
        print("[WeatherSystem] Unknown weather: " .. tostring(weatherType))
        return false
    end

    if currentWeather == weatherType and transitionProgress >= 1.0 then
        return true
    end

    targetWeather = weatherType
    transitionProgress = 0
    lastWeatherChange = love.timer.getTime()

    local weather = WEATHER_TYPES[weatherType]
    targetLight = {
        r = weather.lightAdjust.r,
        g = weather.lightAdjust.g,
        b = weather.lightAdjust.b,
    }

    -- Update ambient sounds via SoundSystem
    local SoundSystem = require("objects.Audio.SoundSystem")
    if weather.ambientSound then
        SoundSystem.playAmbient(weather.ambientSound, 0.4)
    end

    -- Stop previous ambient if different
    local prevWeather = WEATHER_TYPES[currentWeather]
    if prevWeather and prevWeather.ambientSound and prevWeather.ambientSound ~= weather.ambientSound then
        SoundSystem.stopAmbient(prevWeather.ambientSound)
    end

    print("[WeatherSystem] Weather transition: " .. currentWeather .. " -> " .. weatherType)
    return true
end

-- Get current weather type
function WeatherSystem.getCurrentWeather()
    return currentWeather
end

-- Get current light adjustment
function WeatherSystem.getLightAdjust()
    return currentLight
end

-- Get current speed multiplier
function WeatherSystem.getSpeedMultiplier()
    local weather = WEATHER_TYPES[currentWeather]
    local targetWeather = WEATHER_TYPES[targetWeather]

    -- Smooth interpolation during transition
    if transitionProgress < 1.0 then
        local t = transitionProgress
        return weather.speedMultiplier * (1 - t) + targetWeather.speedMultiplier * t
    end

    return weather.speedMultiplier
end

-- Spawn a particle
local function spawnParticle(particleType)
    local w, h = love.graphics.getDimensions()
    local particle = {
        type = particleType,
        x = math.random(-100, w + 100),
        y = math.random(-200, -50),
        vx = 0,
        vy = 0,
        life = 1.0,
        size = 1,
    }

    if particleType == "rain" then
        particle.vx = -50  -- Wind effect
        particle.vy = 600 + math.random(200)
        particle.size = 1 + math.random() * 1
        particle.length = 8 + math.random(4)
    elseif particleType == "snow" then
        particle.vx = (math.random() - 0.5) * 50
        particle.vy = 50 + math.random(50)
        particle.size = 2 + math.random(2)
        particle.length = particle.size
    end

    return particle
end

-- Update weather system
function WeatherSystem.update(dt)
    if not initialized then return end

    -- Update transition
    if transitionProgress < 1.0 then
        local weather = WEATHER_TYPES[currentWeather] or WEATHER_TYPES.clear
        local targetW = WEATHER_TYPES[targetWeather] or WEATHER_TYPES.clear
        local transitionTime = targetW.transitionTime or 2.0
        transitionProgress = transitionProgress + (dt / transitionTime)

        if transitionProgress >= 1.0 then
            transitionProgress = 1.0
            currentWeather = targetWeather
        end

        -- Interpolate light
        local t = transitionProgress
        currentLight.r = weather.lightAdjust.r * (1 - t) + targetW.lightAdjust.r * t
        currentLight.g = weather.lightAdjust.g * (1 - t) + targetW.lightAdjust.g * t
        currentLight.b = weather.lightAdjust.b * (1 - t) + targetW.lightAdjust.b * t
    end

    -- Update particles
    local weather = WEATHER_TYPES[currentWeather]
    local targetW = WEATHER_TYPES[targetWeather]

    -- Target particle count (interpolate during transition)
    local targetCount = targetW.particleCount or 0
    local currentCount = #particles

    -- Add particles if needed
    while #particles < targetCount do
        table.insert(particles, spawnParticle(weather.particleType or targetW.particleType))
    end

    -- Remove particles if too many
    while #particles > targetCount + 50 do  -- allow some overflow during transition
        table.remove(particles, 1)
    end

    -- Update existing particles
    local w, h = love.graphics.getDimensions()
    for i = #particles, 1, -1 do
        local p = particles[i]
        p.x = p.x + p.vx * dt
        p.y = p.y + p.vy * dt

        -- Remove if off-screen
        if p.y > h + 50 or p.x < -150 or p.x > w + 150 then
            table.remove(particles, i)
        end
    end

    -- Lightning effect for storms
    if weather.hasLightning or targetW.hasLightning then
        lightningTimer = lightningTimer - dt
        if lightningTimer <= 0 then
            lightningTimer = math.random(5, 15)  -- random interval
            lightningFlash = 1.0
            -- Play thunder sound
            local SoundSystem = require("objects.Audio.SoundSystem")
            SoundSystem.playSfx("army_charge")
        end

        if lightningFlash > 0 then
            lightningFlash = lightningFlash - dt * 3  -- fade out over ~0.3s
            if lightningFlash < 0 then lightningFlash = 0 end
        end
    end
end

-- Draw weather effects (called from game:draw, after world but before UI)
function WeatherSystem.draw()
    if not initialized then return end

    local w, h = love.graphics.getDimensions()

    -- Apply weather light tint
    local light = currentLight
    love.graphics.setColor(light.r, light.g, light.b, 1)

    -- Draw fog overlay if active
    local weather = WEATHER_TYPES[currentWeather]
    if weather.fogDensity and weather.fogDensity > 0 then
        love.graphics.setColor(0.8, 0.8, 0.85, weather.fogDensity * 0.3)
        love.graphics.rectangle("fill", 0, 0, w, h)
    end

    -- Draw lightning flash
    if lightningFlash > 0 then
        love.graphics.setColor(1, 1, 1, lightningFlash * 0.5)
        love.graphics.rectangle("fill", 0, 0, w, h)
    end

    -- Draw particles
    love.graphics.setColor(0.7, 0.75, 0.85, 0.6)
    for _, p in ipairs(particles) do
        if p.type == "rain" then
            -- Draw as line
            love.graphics.setLineWidth(p.size)
            love.graphics.line(p.x, p.y, p.x - p.vx * 0.02, p.y - p.length)
        elseif p.type == "snow" then
            -- Draw as circle
            love.graphics.circle("fill", p.x, p.y, p.size)
        end
    end

    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
end

-- Auto-cycle weather (for ambient variation)
-- Call this every few minutes for dynamic weather changes
function WeatherSystem.autoCycle()
    -- 30% chance of weather change every 5 minutes
    if love.timer.getTime() - lastWeatherChange < 300 then return end

    local weathers = {"clear", "clear", "clear", "rain", "fog", "clear", "snow"}
    local newWeather = weathers[math.random(#weathers)]

    if newWeather ~= currentWeather then
        WeatherSystem.setWeather(newWeather)
    end
end

-- Get weather info
function WeatherSystem.getWeatherInfo()
    return {
        current = currentWeather,
        target = targetWeather,
        transition = transitionProgress,
        particleCount = #particles,
        lightningActive = lightningFlash > 0,
        lightAdjust = currentLight,
    }
end

-- Force weather change via console
function WeatherSystem.setWeatherImmediate(weatherType)
    currentWeather = weatherType
    targetWeather = weatherType
    transitionProgress = 1.0
    local weather = WEATHER_TYPES[weatherType]
    if weather then
        currentLight = {
            r = weather.lightAdjust.r,
            g = weather.lightAdjust.g,
            b = weather.lightAdjust.b,
        }
    end
    particles = {}  -- clear particles, will respawn on next update
    print("[WeatherSystem] Weather set immediately: " .. weatherType)
end

return WeatherSystem
