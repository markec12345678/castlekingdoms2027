-- objects/Economy/ResourceForecastSystem.lua
-- Castle Kingdoms 2027 v3.0.0 - Resource Forecast System
--
-- Predicts future resource production and consumption to help players
-- plan their economy. Shows projected resource levels over time.
--
-- Features:
-- - Real-time production rate tracking (per resource, per second)
-- - Consumption rate tracking (upkeep, military, construction)
-- - 5-minute projection (where will resources be in 5 min?)
-- - Shortage warnings (predicts when a resource will run out)
-- - Surplus indicators (when a resource is accumulating fast)
-- - Net flow visualization (production - consumption)
-- - Historical trend (last 60 seconds of resource changes)
-- - Efficiency calculation (production vs potential)

local Forecast = {}

local initialized = false
local resourceRates = {}  -- [resource] = { production, consumption, net }
local resourceHistory = {} -- [resource] = { {time, amount}, ... }
local maxHistorySeconds = 60
local updateTimer = 0
local updateInterval = 1.0  -- update every second
local projectionMinutes = 5
local lastResourceSnapshot = {}
local warnings = {}
local lastWarningCheck = 0

function Forecast.init()
    if initialized then return end
    initialized = true
    -- Initialize rates for all known resources
    local resources = {"gold", "wood", "stone", "food", "iron", "pitch", "ale", "wheat", "flour", "hop", "tar"}
    for _, res in ipairs(resources) do
        resourceRates[res] = { production = 0, consumption = 0, net = 0 }
        resourceHistory[res] = {}
        lastResourceSnapshot[res] = 0
    end
    print("[Forecast] Initialized — tracking " .. #resources .. " resources")
end

-- Take a snapshot of current resources
function Forecast._takeSnapshot()
    if not _G.state then return end
    local snapshot = {}
    -- Gold
    snapshot.gold = _G.state.gold or 0
    -- Other resources
    if _G.state.resources then
        for res, amount in pairs(_G.state.resources) do
            snapshot[res] = amount or 0
        end
    end
    return snapshot
end

-- Calculate production and consumption rates
function Forecast._calculateRates()
    local current = Forecast._takeSnapshot()
    if not current then return end

    for res, currentAmount in pairs(current) do
        local lastAmount = lastResourceSnapshot[res] or currentAmount
        local delta = currentAmount - lastAmount

        -- Record in history
        if not resourceHistory[res] then resourceHistory[res] = {} end
        table.insert(resourceHistory[res], {
            time = os.time(),
            amount = currentAmount,
            delta = delta,
        })
        -- Trim history
        while #resourceHistory[res] > maxHistorySeconds do
            table.remove(resourceHistory[res], 1)
        end

        -- Calculate average rate from history
        local totalDelta = 0
        local sampleCount = #resourceHistory[res]
        if sampleCount > 1 then
            for i = 2, sampleCount do
                totalDelta = totalDelta + resourceHistory[res][i].delta
            end
            local avgRate = totalDelta / (sampleCount - 1)  -- per second

            if avgRate >= 0 then
                resourceRates[res] = {
                    production = avgRate,
                    consumption = 0,
                    net = avgRate,
                }
            else
                resourceRates[res] = {
                    production = 0,
                    consumption = -avgRate,
                    net = avgRate,  -- negative
                }
            end
        end

        lastResourceSnapshot[res] = currentAmount
    end
end

-- Check for shortage/surplus warnings
function Forecast._checkWarnings()
    warnings = {}
    local current = Forecast._takeSnapshot()
    if not current then return end

    for res, amount in pairs(current) do
        local rate = resourceRates[res]
        if rate and rate.net < 0 and amount > 0 then
            -- Consuming more than producing — will run out
            local secondsToEmpty = amount / (-rate.net)
            if secondsToEmpty < 60 then
                table.insert(warnings, {
                    resource = res,
                    type = "critical_shortage",
                    message = res .. " bo konec čez " .. math.floor(secondsToEmpty) .. "s!",
                    secondsToEmpty = secondsToEmpty,
                    severity = "critical",
                })
            elseif secondsToEmpty < 180 then
                table.insert(warnings, {
                    resource = res,
                    type = "shortage",
                    message = res .. " se zmanjšuje (konec čez " .. math.floor(secondsToEmpty / 60) .. " min)",
                    secondsToEmpty = secondsToEmpty,
                    severity = "warning",
                })
            end
        elseif rate and rate.net > 5 then
            -- Accumulating fast
            table.insert(warnings, {
                resource = res,
                type = "surplus",
                message = res .. " se kopiči (+" .. math.floor(rate.net) .. "/s)",
                severity = "info",
            })
        end

        -- Low resource warning (static, not rate-based)
        if amount < 20 and res ~= "gold" then
            table.insert(warnings, {
                resource = res,
                type = "low",
                message = "Nizke zaloge: " .. res .. " (" .. math.floor(amount) .. ")",
                severity = "warning",
            })
        elseif res == "gold" and amount < 100 then
            table.insert(warnings, {
                resource = res,
                type = "low",
                message = "Nizko zlato (" .. math.floor(amount) .. "g)",
                severity = "warning",
            })
        end
    end
end

-- Get projection for a resource (where will it be in X seconds?)
function Forecast.getProjected(resource, seconds)
    seconds = seconds or projectionMinutes * 60
    if not resourceRates[resource] then return 0 end
    local current = lastResourceSnapshot[resource] or 0
    local projected = current + resourceRates[resource].net * seconds
    return math.max(0, math.floor(projected))
end

-- Get 5-minute projection for all resources
function Forecast.getProjection(minutes)
    minutes = minutes or projectionMinutes
    local result = {}
    for res, rate in pairs(resourceRates) do
        local current = lastResourceSnapshot[res] or 0
        local projected = current + rate.net * minutes * 60
        local willRunOut = rate.net < 0 and current > 0
        local timeToEmpty = willRunOut and (current / (-rate.net)) or nil
        result[res] = {
            current = math.floor(current),
            projected = math.max(0, math.floor(projected)),
            netRate = rate.net,
            productionRate = rate.production,
            consumptionRate = rate.consumption,
            willRunOut = willRunOut,
            timeToEmpty = timeToEmpty and math.floor(timeToEmpty) or nil,
            timeToEmptyFormatted = timeToEmpty and Forecast._formatTime(timeToEmpty) or nil,
            trend = rate.net > 0.5 and "rising" or rate.net < -0.5 and "falling" or "stable",
        }
    end
    return result
end

-- Format time as Xm Ys
function Forecast._formatTime(seconds)
    local m = math.floor(seconds / 60)
    local s = math.floor(seconds % 60)
    if m > 0 then return m .. "m " .. s .. "s"
    else return s .. "s" end
end

-- Get all warnings
function Forecast.getWarnings()
    return warnings
end

-- Get critical warnings only
function Forecast.getCriticalWarnings()
    local result = {}
    for _, w in ipairs(warnings) do
        if w.severity == "critical" then
            table.insert(result, w)
        end
    end
    return result
end

-- Get rate for a specific resource
function Forecast.getRate(resource)
    return resourceRates[resource] or { production = 0, consumption = 0, net = 0 }
end

-- Get all rates
function Forecast.getAllRates()
    return resourceRates
end

-- Get efficiency (actual production vs potential)
function Forecast.getEfficiency()
    local totalProduction = 0
    local totalConsumption = 0
    for _, rate in pairs(resourceRates) do
        totalProduction = totalProduction + rate.production
        totalConsumption = totalConsumption + rate.consumption
    end
    local efficiency = totalProduction > 0 and (totalProduction / (totalProduction + totalConsumption) * 100) or 100
    return {
        production = totalProduction,
        consumption = totalConsumption,
        net = totalProduction - totalConsumption,
        efficiency = math.floor(efficiency),
    }
end

-- Get history for a resource
function Forecast.getHistory(resource, limit)
    if not resourceHistory[resource] then return {} end
    local result = {}
    limit = limit or 30
    local start = math.max(1, #resourceHistory[resource] - limit + 1)
    for i = start, #resourceHistory[resource] do
        table.insert(result, resourceHistory[resource][i])
    end
    return result
end

-- Get formatted summary
function Forecast.getSummary()
    local projection = Forecast.getProjection()
    local lines = {"=== EKONOMSKA PROGNOZA (5 min) ==="}
    for res, data in pairs(projection) do
        local arrow = data.trend == "rising" and "↑" or data.trend == "falling" and "↓" or "→"
        local line = string.format("%s: %d → %d %s (%.1f/s)",
            res, data.current, data.projected, arrow, data.netRate)
        if data.willRunOut then
            line = line .. " ⚠ KONEC: " .. data.timeToEmptyFormatted
        end
        table.insert(lines, line)
    end
    local eff = Forecast.getEfficiency()
    table.insert(lines, string.format("\nUčinkovitost: %d%% (prod: %.1f/s, cons: %.1f/s)",
        eff.efficiency, eff.production, eff.consumption))
    return table.concat(lines, "\n")
end

-- Update
function Forecast.update(dt)
    if not initialized then return end
    updateTimer = updateTimer + dt
    if updateTimer >= updateInterval then
        updateTimer = 0
        Forecast._calculateRates()
        -- Check warnings less frequently
        lastWarningCheck = lastWarningCheck + 1
        if lastWarningCheck >= 5 then  -- every 5 seconds
            lastWarningCheck = 0
            Forecast._checkWarnings()
            -- Notify critical warnings
            local critical = Forecast.getCriticalWarnings()
            for _, w in ipairs(critical) do
                if _G.NotificationCenter then
                    pcall(function() _G.NotificationCenter.economy(w.message, 1) end)  -- HIGH priority
                end
            end
        end
    end
end

-- Get stats
function Forecast.getStats()
    local eff = Forecast.getEfficiency()
    return {
        trackedResources = 0,
        warnings = #warnings,
        criticalWarnings = #Forecast.getCriticalWarnings(),
        efficiency = eff.efficiency,
        netFlow = eff.net,
        projectionMinutes = projectionMinutes,
    }
end

return Forecast
