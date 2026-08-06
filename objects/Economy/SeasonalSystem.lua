-- objects/Economy/SeasonalSystem.lua
-- Stronghold 2027 - Seasonal System
--
-- Manages 4 seasons (Spring, Summer, Autumn, Winter) that affect:
-- - Food production (winter = -50%)
-- - Resource prices (winter = food more expensive)
-- - Unit movement (winter = slower)
-- - Visual atmosphere (via WeatherSystem integration)
--
-- Each season lasts 90 seconds (configurable), full year = 6 minutes

local SeasonalSystem = {}

-- Season definitions
local SEASONS = {
    spring = {
        name = "Spring",
        nameSlv = "Pomlad",
        duration = 90,  -- seconds
        foodModifier = 1.2,        -- +20% food production
        woodModifier = 1.1,        -- +10% wood
        stoneModifier = 1.0,
        ironModifier = 1.0,
        priceModifiers = {
            wheat = 0.9,    -- cheaper (good harvest coming)
            flour = 0.95,
            bread = 1.0,
            apples = 1.1,
            meat = 1.0,
        },
        movementModifier = 1.0,
        weatherPreference = "clear",
    },
    summer = {
        name = "Summer",
        nameSlv = "Poletje",
        duration = 90,
        foodModifier = 1.3,        -- best food production
        woodModifier = 1.0,
        stoneModifier = 1.1,       -- good building conditions
        ironModifier = 1.0,
        priceModifiers = {
            wheat = 0.8,    -- abundant
            flour = 0.85,
            bread = 0.9,
            apples = 0.8,   -- abundant
            meat = 0.95,
            ale = 1.0,
        },
        movementModifier = 1.0,
        weatherPreference = "clear",
    },
    autumn = {
        name = "Autumn",
        nameSlv = "Jesen",
        duration = 90,
        foodModifier = 1.0,        -- normal
        woodModifier = 1.2,        -- +20% (preparation for winter)
        stoneModifier = 1.0,
        ironModifier = 1.0,
        priceModifiers = {
            wheat = 1.0,
            flour = 1.0,
            bread = 1.05,
            apples = 0.9,   -- harvest season
            meat = 1.0,
            wood = 1.1,     -- demand for winter prep
            ale = 1.1,
        },
        movementModifier = 1.0,
        weatherPreference = "rain",
    },
    winter = {
        name = "Winter",
        nameSlv = "Zima",
        duration = 90,
        foodModifier = 0.5,        -- -50% food production
        woodModifier = 0.7,        -- harder to log
        stoneModifier = 0.6,       -- harder to quarry
        ironModifier = 0.8,
        priceModifiers = {
            wheat = 1.5,    -- expensive
            flour = 1.4,
            bread = 1.4,
            apples = 1.6,
            meat = 1.3,
            cheese = 1.3,
            ale = 1.2,
            wood = 1.3,     -- high demand for heating
            stone = 1.1,
        },
        movementModifier = 0.8,    -- 20% slower
        weatherPreference = "snow",
    },
}

local SEASON_ORDER = {"spring", "summer", "autumn", "winter"}

-- State
local initialized = false
local currentSeason = "spring"
local seasonTime = 0  -- time elapsed in current season
local yearCount = 1   -- how many years have passed

-- Initialize
function SeasonalSystem.init()
    if initialized then return end
    initialized = true
    currentSeason = "spring"
    seasonTime = 0
    yearCount = 1
    SeasonalSystem.applySeasonModifiers()
    print("[SeasonalSystem] Initialized (Season: " .. SEASONS[currentSeason].name .. ", Year: " .. yearCount .. ")")
end

-- Update seasonal system
function SeasonalSystem.update(dt)
    if not initialized then return end

    seasonTime = seasonTime + dt
    local seasonData = SEASONS[currentSeason]

    if seasonTime >= seasonData.duration then
        -- Advance to next season
        SeasonalSystem.advanceSeason()
    end
end

-- Advance to next season
function SeasonalSystem.advanceSeason()
    local currentIndex = 1
    for i, season in ipairs(SEASON_ORDER) do
        if season == currentSeason then
            currentIndex = i
            break
        end
    end

    local nextIndex = (currentIndex % #SEASON_ORDER) + 1
    local oldSeason = currentSeason
    currentSeason = SEASON_ORDER[nextIndex]
    seasonTime = 0

    -- If we wrapped around to spring, increment year
    if currentSeason == "spring" then
        yearCount = yearCount + 1
    end

    SeasonalSystem.applySeasonModifiers()
    SeasonalSystem.notifySeasonChange(oldSeason, currentSeason)
end

-- Apply season modifiers to market and other systems
function SeasonalSystem.applySeasonModifiers()
    local seasonData = SEASONS[currentSeason]
    local DynamicMarket = require("objects.Economy.DynamicMarketSystem")

    for resource, multiplier in pairs(seasonData.priceModifiers) do
        DynamicMarket.setSeasonalModifier(resource, multiplier)
    end

    -- Optionally trigger weather change
    if seasonData.weatherPreference then
        local WeatherSystem = require("objects.Weather.WeatherSystem")
        local currentWeather = WeatherSystem.getCurrentWeather()
        -- Only change if weather is clear (don't override player's choice)
        if currentWeather == "clear" and math.random() < 0.5 then
            WeatherSystem.setWeather(seasonData.weatherPreference)
        end
    end
end

-- Notify about season change (UI + sound)
function SeasonalSystem.notifySeasonChange(oldSeason, newSeason)
    local ModernUI = require("objects.UI.ModernUISystem")
    local newSeasonData = SEASONS[newSeason]
    local message = string.format("Season: %s (Year %d)", newSeasonData.nameSlv, yearCount)
    ModernUI.notifyInfo(message)
    print("[SeasonalSystem] Season change: " .. oldSeason .. " -> " .. newSeason .. " (Year " .. yearCount .. ")")
end

-- Get current season
function SeasonalSystem.getCurrentSeason()
    return currentSeason
end

-- Get current season data
function SeasonalSystem.getCurrentSeasonData()
    return SEASONS[currentSeason]
end

-- Get year count
function SeasonalSystem.getYear()
    return yearCount
end

-- Get time remaining in current season
function SeasonalSystem.getTimeRemaining()
    local seasonData = SEASONS[currentSeason]
    return math.max(0, seasonData.duration - seasonTime)
end

-- Get production modifier for resource type
function SeasonalSystem.getProductionModifier(resourceType)
    local seasonData = SEASONS[currentSeason]
    if resourceType == "food" then return seasonData.foodModifier end
    if resourceType == "wood" then return seasonData.woodModifier end
    if resourceType == "stone" then return seasonData.stoneModifier end
    if resourceType == "iron" then return seasonData.ironModifier end
    return 1.0
end

-- Get movement modifier (for units)
function SeasonalSystem.getMovementModifier()
    return SEASONS[currentSeason].movementModifier
end

-- Force season change (for testing or scenarios)
function SeasonalSystem.setSeason(seasonName)
    if not SEASONS[seasonName] then
        print("[SeasonalSystem] Unknown season: " .. tostring(seasonName))
        return false
    end
    currentSeason = seasonName
    seasonTime = 0
    SeasonalSystem.applySeasonModifiers()
    return true
end

-- Set season duration (affects all seasons)
function SeasonalSystem.setSeasonDuration(seconds)
    for _, season in pairs(SEASONS) do
        season.duration = seconds
    end
    print("[SeasonalSystem] Season duration set to " .. seconds .. "s")
end

-- Get all season info (for UI)
function SeasonalSystem.getSeasonInfo()
    local seasonData = SEASONS[currentSeason]
    return {
        current = currentSeason,
        name = seasonData.name,
        nameSlv = seasonData.nameSlv,
        year = yearCount,
        timeElapsed = seasonTime,
        timeRemaining = seasonData.duration - seasonTime,
        duration = seasonData.duration,
        foodModifier = seasonData.foodModifier,
        woodModifier = seasonData.woodModifier,
        movementModifier = seasonData.movementModifier,
        nextSeason = SeasonalSystem.getNextSeason(),
    }
end

-- Get next season
function SeasonalSystem.getNextSeason()
    local currentIndex = 1
    for i, season in ipairs(SEASON_ORDER) do
        if season == currentSeason then
            currentIndex = i
            break
        end
    end
    local nextIndex = (currentIndex % #SEASON_ORDER) + 1
    return SEASON_ORDER[nextIndex]
end

-- Reset (for new game)
function SeasonalSystem.reset()
    currentSeason = "spring"
    seasonTime = 0
    yearCount = 1
    SeasonalSystem.applySeasonModifiers()
    print("[SeasonalSystem] Reset")
end

return SeasonalSystem
