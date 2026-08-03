-- objects/Weather/WeatherGameplayIntegration.lua
-- Stronghold 2027 - Weather affects gameplay

local WeatherGameplay = {}

local WEATHER_EFFECTS = {
    clear = { name = "Jasno", farmMult = 1.0, speedMult = 1.0, visionMult = 1.0, fireRisk = 0.0, archerMult = 1.0, desc = "Idealno vreme." },
    rain = { name = "Dezh", farmMult = 1.5, speedMult = 0.85, visionMult = 0.85, fireRisk = -0.5, archerMult = 0.80, desc = "Dezh povechuje pridelek, a upocasnuje enote." },
    heavy_rain = { name = "Mocan dezh", farmMult = 1.8, speedMult = 0.70, visionMult = 0.70, fireRisk = -1.0, archerMult = 0.65, desc = "Mocan dezh resno upocasnuja gibanje." },
    fog = { name = "Megla", farmMult = 0.90, speedMult = 0.95, visionMult = 0.50, fireRisk = 0.0, archerMult = 0.70, desc = "Megla mochno zmanjhuje vidljivost." },
    snow = { name = "Sneg", farmMult = 0.40, speedMult = 0.60, visionMult = 0.80, fireRisk = -0.3, archerMult = 0.85, desc = "Sneg unichuje pridelek." },
    storm = { name = "Nevihta", farmMult = 1.2, speedMult = 0.50, visionMult = 0.60, fireRisk = 0.3, archerMult = 0.50, desc = "Nevihta je nevarna." },
}

WeatherGameplay.WEATHER_EFFECTS = WEATHER_EFFECTS
local currentWeather = "clear"
local modifiers = {}
local initialized = false

function WeatherGameplay.init()
    if initialized then return end
    initialized = true
    currentWeather = "clear"
    WeatherGameplay._updateModifiers()
    print("[WeatherGameplay] Initialized")
end

function WeatherGameplay._updateModifiers()
    local e = WEATHER_EFFECTS[currentWeather]
    if e then modifiers = e end
end

function WeatherGameplay.setWeather(w)
    if not WEATHER_EFFECTS[w] then return false end
    local old = currentWeather
    currentWeather = w
    WeatherGameplay._updateModifiers()
    if _G.GameEventBus then _G.GameEventBus.emit("weather_changed", {old=old, new=w}) end
    if _G.VoiceOver then _G.VoiceOver.notify("weather_" .. w, modifiers.name) end
    print("[WeatherGameplay] " .. old .. " -> " .. w)
    return true
end

function WeatherGameplay.getWeather() return currentWeather end
function WeatherGameplay.getModifiers() return modifiers end
function WeatherGameplay.getFarmMultiplier() return modifiers.farmMult or 1.0 end
function WeatherGameplay.getUnitSpeedMultiplier() return modifiers.speedMult or 1.0 end
function WeatherGameplay.getVisionRangeMultiplier() return modifiers.visionMult or 1.0 end
function WeatherGameplay.getArcherAccuracyMultiplier() return modifiers.archerMult or 1.0 end
function WeatherGameplay.getFireRisk() return modifiers.fireRisk or 0.0 end

function WeatherGameplay.cycleWeather()
    local order = {"clear", "rain", "heavy_rain", "fog", "snow", "storm"}
    local idx = 1
    for i, w in ipairs(order) do if w == currentWeather then idx = i break end end
    local next = order[(idx % #order) + 1]
    WeatherGameplay.setWeather(next)
    return next
end

return WeatherGameplay
