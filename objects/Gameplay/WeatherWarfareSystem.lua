-- objects/Gameplay/WeatherWarfareSystem.lua
-- Castle Kingdoms 2027 v2.8.6 - Weather Warfare System
--
-- Allows players to manipulate weather for strategic advantage.
-- Weather changes affect both player and AI — use wisely!
--
-- Features:
-- - Summon weather changes (costs gold + cooldown)
-- - Weather affects combat: archers weaker in rain, siege in storm
-- - Lightning strike ability (storm weather)
-- - Fog concealment (fog weather hides units from enemy)
-- - Drought damage (heatwave damages farms)
-- - Blizzard slow zone (snow slows all units)

local WeatherWarfare = {}

-- Weather abilities
local ABILITIES = {
    summon_rain = {
        name = "Prikliči dež",
        nameEn = "Summon Rain",
        cost = 200,
        cooldown = 120,
        duration = 60,
        weather = "rain",
        description = "Prikliči dež — kmetije +50% produkcije, lokostrelci -20%",
    },
    summon_storm = {
        name = "Prikliči nevihto",
        nameEn = "Summon Storm",
        cost = 500,
        cooldown = 300,
        duration = 90,
        weather = "storm",
        description = "Nevihta — vse enote -50% hitrosti, možnost strele",
    },
    summon_fog = {
        name = "Prikliči meglo",
        nameEn = "Summon Fog",
        cost = 300,
        cooldown = 180,
        duration = 120,
        weather = "fog",
        description = "Megla — vidljivost -50%, enote skrite pred sovražnikom",
    },
    summon_blizzard = {
        name = "Prikliči metež",
        nameEn = "Summon Blizzard",
        cost = 600,
        cooldown = 360,
        duration = 60,
        weather = "blizzard",
        description = "Metež — vse enote -70% hitrosti, kmetije -90%",
    },
    summon_heatwave = {
        name = "Prikliči vročinski val",
        nameEn = "Summon Heatwave",
        cost = 400,
        cooldown = 240,
        duration = 75,
        weather = "heatwave",
        description = "Vročina — kmetije -40%, nevarnost požara +100%",
    },
    lightning_strike = {
        name = "Strela",
        nameEn = "Lightning Strike",
        cost = 250,
        cooldown = 60,
        duration = 0,
        weather = nil,
        description = "Udari sovražnikovo enoto z strelo (50 damage)",
    },
    clear_weather = {
        name = "Počisti vreme",
        nameEn = "Clear Weather",
        cost = 100,
        cooldown = 30,
        duration = 0,
        weather = "clear",
        description = "Počisti vreme — odstrani vse vremenske učinke",
    },
}

WeatherWarfare.ABILITIES = ABILITIES

local initialized = false
local cooldowns = {}  -- [abilityId] = remainingCooldown
local activeWeatherChange = nil  -- { abilityId, timeRemaining }
local totalLightningStrikes = 0

function WeatherWarfare.init()
    if initialized then return end
    initialized = true
    -- Initialize cooldowns
    for abilityId, _ in pairs(ABILITIES) do
        cooldowns[abilityId] = 0
    end
    print("[WeatherWarfare] Initialized with " .. WeatherWarfare._getAbilityCount() .. " abilities")
end

function WeatherWarfare._getAbilityCount()
    local count = 0
    for _ in pairs(ABILITIES) do count = count + 1 end
    return count
end

-- Check if an ability can be used
function WeatherWarfare.canUse(abilityId)
    if not ABILITIES[abilityId] then return false, "Unknown ability" end
    if cooldowns[abilityId] and cooldowns[abilityId] > 0 then
        return false, "Cooldown: " .. math.ceil(cooldowns[abilityId]) .. "s"
    end
    if _G.state and (_G.state.gold or 0) < ABILITIES[abilityId].cost then
        return false, "Not enough gold (" .. ABILITIES[abilityId].cost .. "g)"
    end
    return true
end

-- Use a weather ability
function WeatherWarfare.use(abilityId, targetGx, targetGy)
    local canUse, reason = WeatherWarfare.canUse(abilityId)
    if not canUse then
        if _G.ModernUI then
            _G.ModernUI.notifyError(reason)
        end
        return false
    end

    local ability = ABILITIES[abilityId]
    -- Deduct cost
    if _G.state then
        _G.state.gold = (_G.state.gold or 0) - ability.cost
    end
    -- Set cooldown
    cooldowns[abilityId] = ability.cooldown

    -- Handle instant abilities
    if abilityId == "lightning_strike" then
        WeatherWarfare._lightningStrike(targetGx, targetGy)
        return true
    end

    -- Handle weather change
    if ability.weather then
        -- Set weather via WeatherSystem
        local WeatherSystem = _G.WeatherSystem
        if WeatherSystem and WeatherSystem.setWeather then
            pcall(function() WeatherSystem.setWeather(ability.weather) end)
        end
        -- Also set WeatherGameplay
        local WeatherGameplay = _G.WeatherGameplay
        if WeatherGameplay and WeatherGameplay.setWeather then
            pcall(function() WeatherGameplay.setWeather(ability.weather) end)
        end

        activeWeatherChange = {
            abilityId = abilityId,
            timeRemaining = ability.duration,
            weather = ability.weather,
        }

        if _G.ModernUI then
            _G.ModernUI.notifySuccess(ability.name .. "! (" .. ability.duration .. "s)")
        end
        if _G.VoiceOver then
            pcall(function() _G.VoiceOver.notify("festival_started", ability.name) end)
        end
    end

    -- Fire event
    if _G.GameEventBus then
        pcall(function() _G.GameEventBus.emit("weather_warfare_used", {
            abilityId = abilityId,
            weather = ability.weather,
            targetGx = targetGx,
            targetGy = targetGy,
        }) end)
    end

    print("[WeatherWarfare] Used: " .. ability.name)
    return true
end

-- Lightning strike — damages units at target location
function WeatherWarfare._lightningStrike(gx, gy)
    if not gx or not gy then return end
    totalLightningStrikes = totalLightningStrikes + 1

    local damage = 50
    local radius = 3  -- tiles
    local hitCount = 0

    if _G.state and _G.state.gameObjectList then
        for _, unit in ipairs(_G.state.gameObjectList) do
            if unit.faction and unit.faction ~= 1 and unit.faction ~= 5
                and unit.health and unit.health > 0 and unit.gx and unit.gy then
                local dx = unit.gx - gx
                local dy = unit.gy - gy
                if dx * dx + dy * dy <= radius * radius then
                    unit.health = unit.health - damage
                    hitCount = hitCount + 1
                    if unit.health <= 0 and unit.combatState then
                        unit.combatState = "dead"
                    end
                end
            end
        end
    end

    -- Visual effect
    if _G.VisualPolish and _G.state then
        local sx = _G.IsoToScreenX(gx, gy) - (_G.state.viewXview or 0)
        local sy = _G.IsoToScreenY(gx, gy) - (_G.state.viewYview or 0)
        pcall(function() _G.VisualPolish.spawnEffect(sx, sy, "spark", 20) end)
    end

    -- Screen shake
    if _G.GameFeel then
        pcall(function() _G.GameFeel.shake(8, 0.3) end)
    end

    if _G.ModernUI then
        _G.ModernUI.notifySuccess("Strela! " .. hitCount .. " enot zadetih (-" .. damage .. " HP)")
    end

    print("[WeatherWarfare] Lightning strike at (" .. gx .. "," .. gy .. ") — hit " .. hitCount .. " units")
end

-- Update cooldowns and active weather
function WeatherWarfare.update(dt)
    if not initialized then return end

    -- Update cooldowns
    for abilityId, _ in pairs(ABILITIES) do
        if cooldowns[abilityId] and cooldowns[abilityId] > 0 then
            cooldowns[abilityId] = cooldowns[abilityId] - dt
            if cooldowns[abilityId] <= 0 then
                cooldowns[abilityId] = 0
                if _G.ModernUI then
                    _G.ModernUI.notifyInfo("Weather Warfare: " .. ABILITIES[abilityId].name .. " pripravljeno!")
                end
            end
        end
    end

    -- Update active weather change
    if activeWeatherChange then
        activeWeatherChange.timeRemaining = activeWeatherChange.timeRemaining - dt
        if activeWeatherChange.timeRemaining <= 0 then
            -- Revert to clear weather
            local WeatherSystem = _G.WeatherSystem
            if WeatherSystem and WeatherSystem.setWeather then
                pcall(function() WeatherSystem.setWeather("clear") end)
            end
            if _G.ModernUI then
                _G.ModernUI.notifyInfo("Vremenski učinek je potekel")
            end
            activeWeatherChange = nil
        end
    end
end

-- Get ability info
function WeatherWarfare.getAbilityInfo(abilityId)
    local ability = ABILITIES[abilityId]
    if not ability then return nil end
    return {
        id = abilityId,
        name = ability.name,
        nameEn = ability.nameEn,
        cost = ability.cost,
        cooldown = ability.cooldown,
        duration = ability.duration,
        weather = ability.weather,
        description = ability.description,
        currentCooldown = cooldowns[abilityId] or 0,
        ready = (cooldowns[abilityId] or 0) <= 0,
    }
end

-- Get all abilities with status
function WeatherWarfare.getAllAbilities()
    local result = {}
    for abilityId, _ in pairs(ABILITIES) do
        table.insert(result, WeatherWarfare.getAbilityInfo(abilityId))
    end
    return result
end

-- Get active weather change
function WeatherWarfare.getActiveWeather()
    if not activeWeatherChange then return nil end
    return {
        abilityId = activeWeatherChange.abilityId,
        weather = activeWeatherChange.weather,
        timeRemaining = math.ceil(activeWeatherChange.timeRemaining),
    }
end

-- Get stats
function WeatherWarfare.getStats()
    local readyCount = 0
    for abilityId, _ in pairs(ABILITIES) do
        if (cooldowns[abilityId] or 0) <= 0 then
            readyCount = readyCount + 1
        end
    end
    return {
        totalAbilities = WeatherWarfare._getAbilityCount(),
        readyAbilities = readyCount,
        activeWeatherChange = activeWeatherChange ~= nil,
        totalLightningStrikes = totalLightningStrikes,
    }
end

return WeatherWarfare
