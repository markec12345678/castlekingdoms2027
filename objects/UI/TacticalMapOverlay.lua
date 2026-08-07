-- objects/UI/TacticalMapOverlay.lua
-- Stronghold 2027 v2.7.8 - Tactical Map Overlay
--
-- Strategic overlay system that visualizes tactical information on the map.
-- Can be toggled to show: threat zones, supply coverage, territory control,
-- unit deployment zones, and strategic objectives.
--
-- Overlay modes:
-- - Threat: shows enemy threat zones (red gradient)
-- - Supply: shows supply coverage (green gradient)
-- - Territory: shows faction territory control (colored zones)
-- - Economy: shows resource production hotspots
-- - Military: shows unit deployment and formation positions

local TacticalOverlay = {}

local initialized = false
local isVisible = false
local currentMode = "off"  -- off, threat, supply, territory, economy, military
local overlayData = {}
local updateTimer = 0
local updateInterval = 1.0  -- refresh every 1 second
local opacity = 0.5

-- Overlay modes
local MODES = {
    off = { name = "Izklopljen", key = "F3", color = nil },
    threat = { name = "Grožnje", key = "threat", color = {0.9, 0.2, 0.2} },
    supply = { name = "Oskrba", key = "supply", color = {0.2, 0.8, 0.2} },
    territory = { name = "Ozemlje", key = "territory", color = {0.3, 0.5, 0.9} },
    economy = { name = "Ekonomija", key = "economy", color = {0.9, 0.8, 0.2} },
    military = { name = "Vojska", key = "military", color = {0.8, 0.4, 0.8} },
}

TacticalOverlay.MODES = MODES

local modeOrder = {"off", "threat", "supply", "territory", "economy", "military"}

function TacticalOverlay.init()
    if initialized then return end
    initialized = true
    print("[TacticalOverlay] Initialized with " .. #modeOrder .. " modes")
end

-- Cycle through overlay modes
function TacticalOverlay.cycleMode()
    local idx = 1
    for i, mode in ipairs(modeOrder) do
        if mode == currentMode then idx = i break end
    end
    local nextMode = modeOrder[(idx % #modeOrder) + 1]
    TacticalOverlay.setMode(nextMode)
end

-- Set specific mode
function TacticalOverlay.setMode(mode)
    if not MODES[mode] then return false end
    currentMode = mode
    isVisible = mode ~= "off"
    if _G.ModernUI then
        if mode == "off" then
            _G.ModernUI.notifyInfo("Taktični overlay: izklopljen")
        else
            _G.ModernUI.notifyInfo("Taktični overlay: " .. MODES[mode].name)
        end
    end
    print("[TacticalOverlay] Mode: " .. mode)
    return true
end

-- Get current mode
function TacticalOverlay.getMode()
    return currentMode
end

-- Check if visible
function TacticalOverlay.isVisible()
    return isVisible
end

-- Update overlay data
function TacticalOverlay._refreshData()
    overlayData = {
        threats = {},
        supplies = {},
        territories = {},
        economy = {},
        military = {},
    }

    if not _G.state or not _G.state.gameObjectList then return end

    -- Collect data from game objects
    for _, obj in ipairs(_G.state.gameObjectList) do
        if obj.gx and obj.gy then
            -- Threat data: enemy military units
            if obj._combatAttached and obj.faction and obj.faction ~= 1 and obj.faction ~= 5 then
                table.insert(overlayData.threats, {
                    gx = obj.gx, gy = obj.gy,
                    strength = (obj.health or 50) + (obj.damage or 10),
                    faction = obj.faction,
                })
            end

            -- Supply data: supply buildings
            if (not obj.faction or obj.faction == 1) and obj.class and obj.class.name then
                local name = obj.class.name
                if name == "Stockpile" or name == "Granary" or name == "Armoury" or name == "Market" or name == "Inn" then
                    table.insert(overlayData.supplies, {
                        gx = obj.gx, gy = obj.gy,
                        type = name,
                    })
                end

                -- Economy data: production buildings
                if name == "WheatFarm" or name == "Woodcutter" or name == "Quarry" or name == "IronMine" then
                    table.insert(overlayData.economy, {
                        gx = obj.gx, gy = obj.gy,
                        type = name,
                    })
                end

                -- Military data: military buildings and player units
                if name == "Barracks" or name == "StoneBarracks" or name == "EngineersGuild" then
                    table.insert(overlayData.military, {
                        gx = obj.gx, gy = obj.gy,
                        type = name,
                        isBuilding = true,
                    })
                end
            end

            -- Player military units
            if obj._combatAttached and (not obj.faction or obj.faction == 1) then
                table.insert(overlayData.military, {
                    gx = obj.gx, gy = obj.gy,
                    type = obj.className or "Unit",
                    isBuilding = false,
                    health = obj.health or 100,
                })
            end

            -- Territory: all buildings by faction
            if obj.class and obj.class.name and obj.faction then
                table.insert(overlayData.territories, {
                    gx = obj.gx, gy = obj.gy,
                    faction = obj.faction,
                })
            end
        end
    end
end

-- Update
function TacticalOverlay.update(dt)
    if not initialized then return end
    if not isVisible then return end
    updateTimer = updateTimer + dt
    if updateTimer >= updateInterval then
        updateTimer = 0
        TacticalOverlay._refreshData()
    end
end

-- Draw the overlay
function TacticalOverlay.draw()
    if not initialized or not isVisible then return end
    if not _G.state or not _G.state.viewXview then return end

    if currentMode == "threat" then
        TacticalOverlay._drawThreats()
    elseif currentMode == "supply" then
        TacticalOverlay._drawSupplies()
    elseif currentMode == "territory" then
        TacticalOverlay._drawTerritories()
    elseif currentMode == "economy" then
        TacticalOverlay._drawEconomy()
    elseif currentMode == "military" then
        TacticalOverlay._drawMilitary()
    end

    -- Draw mode label
    local mode = MODES[currentMode]
    if mode and mode.color then
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 10, 10, 200, 25)
        love.graphics.setColor(mode.color[1], mode.color[2], mode.color[3], 1)
        love.graphics.print("Taktični overlay: " .. mode.name, 15, 15)
    end
    love.graphics.setColor(1, 1, 1, 1)
end

-- Draw threat zones
function TacticalOverlay._drawThreats()
    local color = MODES.threat.color
    for _, threat in ipairs(overlayData.threats) do
        local sx = _G.IsoToScreenX(threat.gx, threat.gy) - _G.state.viewXview
        local sy = _G.IsoToScreenY(threat.gx, threat.gy) - _G.state.viewYview
        -- Draw threat circle (size based on strength)
        local radius = math.max(10, math.min(40, threat.strength / 5))
        love.graphics.setColor(color[1], color[2], color[3], opacity * 0.3)
        love.graphics.circle("fill", sx, sy, radius)
        love.graphics.setColor(color[1], color[2], color[3], opacity)
        love.graphics.circle("line", sx, sy, radius)
    end
    love.graphics.setColor(1, 1, 1, 1)
end

-- Draw supply coverage
function TacticalOverlay._drawSupplies()
    local color = MODES.supply.color
    local supplyRange = 30
    for _, supply in ipairs(overlayData.supplies) do
        local sx = _G.IsoToScreenX(supply.gx, supply.gy) - _G.state.viewXview
        local sy = _G.IsoToScreenY(supply.gx, supply.gy) - _G.state.viewYview
        -- Draw supply range circle
        love.graphics.setColor(color[1], color[2], color[3], opacity * 0.15)
        love.graphics.circle("fill", sx, sy, supplyRange * 4)
        love.graphics.setColor(color[1], color[2], color[3], opacity * 0.5)
        love.graphics.circle("line", sx, sy, supplyRange * 4)
        -- Draw icon
        love.graphics.setColor(color[1], color[2], color[3], opacity)
        love.graphics.print(supply.type:sub(1, 3), sx - 8, sy - 5)
    end
    love.graphics.setColor(1, 1, 1, 1)
end

-- Draw territory control
function TacticalOverlay._drawTerritories()
    -- Faction colors
    local factionColors = {
        [1] = {0.3, 0.5, 0.9},  -- Player (blue)
        [2] = {0.9, 0.3, 0.3},  -- Enemy 1 (red)
        [3] = {0.9, 0.7, 0.2},  -- Enemy 2 (yellow)
        [4] = {0.8, 0.3, 0.8},  -- Enemy 3 (purple)
        [5] = {0.5, 0.5, 0.5},  -- Neutral (gray)
    }
    for _, terr in ipairs(overlayData.territories) do
        local sx = _G.IsoToScreenX(terr.gx, terr.gy) - _G.state.viewXview
        local sy = _G.IsoToScreenY(terr.gx, terr.gy) - _G.state.viewYview
        local color = factionColors[terr.faction] or {0.5, 0.5, 0.5}
        love.graphics.setColor(color[1], color[2], color[3], opacity * 0.4)
        love.graphics.circle("fill", sx, sy, 15)
    end
    love.graphics.setColor(1, 1, 1, 1)
end

-- Draw economy hotspots
function TacticalOverlay._drawEconomy()
    local color = MODES.economy.color
    for _, econ in ipairs(overlayData.economy) do
        local sx = _G.IsoToScreenX(econ.gx, econ.gy) - _G.state.viewXview
        local sy = _G.IsoToScreenY(econ.gx, econ.gy) - _G.state.viewYview
        love.graphics.setColor(color[1], color[2], color[3], opacity * 0.4)
        love.graphics.circle("fill", sx, sy, 12)
        love.graphics.setColor(color[1], color[2], color[3], opacity)
        love.graphics.circle("line", sx, sy, 12)
        -- Draw type label
        love.graphics.print(econ.type:sub(1, 4), sx - 10, sy - 20)
    end
    love.graphics.setColor(1, 1, 1, 1)
end

-- Draw military deployment
function TacticalOverlay._drawMilitary()
    local color = MODES.military.color
    for _, unit in ipairs(overlayData.military) do
        local sx = _G.IsoToScreenX(unit.gx, unit.gy) - _G.state.viewXview
        local sy = _G.IsoToScreenY(unit.gx, unit.gy) - _G.state.viewYview
        if unit.isBuilding then
            -- Buildings: square
            love.graphics.setColor(color[1], color[2], color[3], opacity * 0.3)
            love.graphics.rectangle("fill", sx - 12, sy - 12, 24, 24)
            love.graphics.setColor(color[1], color[2], color[3], opacity)
            love.graphics.rectangle("line", sx - 12, sy - 12, 24, 24)
        else
            -- Units: circle with health bar
            love.graphics.setColor(color[1], color[2], color[3], opacity * 0.5)
            love.graphics.circle("fill", sx, sy, 8)
            love.graphics.setColor(color[1], color[2], color[3], opacity)
            love.graphics.circle("line", sx, sy, 8)
            -- Health bar
            if unit.health then
                local hp = math.max(0, math.min(1, unit.health / 100))
                love.graphics.setColor(1, 0, 0, opacity)
                love.graphics.rectangle("fill", sx - 8, sy - 15, 16, 2)
                love.graphics.setColor(0, 1, 0, opacity)
                love.graphics.rectangle("fill", sx - 8, sy - 15, 16 * hp, 2)
            end
        end
    end
    love.graphics.setColor(1, 1, 1, 1)
end

-- Get stats
function TacticalOverlay.getStats()
    return {
        mode = currentMode,
        visible = isVisible,
        threatsTracked = #overlayData.threats,
        suppliesTracked = #overlayData.supplies,
        economyTracked = #overlayData.economy,
        militaryTracked = #overlayData.military,
        territoriesTracked = #overlayData.territories,
    }
end

-- Set opacity
function TacticalOverlay.setOpacity(value)
    opacity = math.max(0.1, math.min(1.0, value))
end

return TacticalOverlay
