-- objects/UI/ResourceFlowVisualizer.lua
-- Stronghold 2027 - Resource Flow Visualizer
-- Shows production/consumption rates for all resources

local ResourceFlow = {}

local initialized = false
local isVisible = false
local flowData = {}
local updateTimer = 0
local updateInterval = 1.0  -- Update every second

local RESOURCE_LIST = {
    { key = "wood",    name = "Les",       color = {0.6, 0.4, 0.2} },
    { key = "stone",   name = "Kamen",     color = {0.5, 0.5, 0.5} },
    { key = "iron",    name = "Železo",    color = {0.4, 0.4, 0.5} },
    { key = "gold",    name = "Zlato",     color = {1.0, 0.85, 0.2} },
    { key = "food",    name = "Hrana",     color = {0.3, 0.8, 0.3} },
    { key = "pitch",   name = "Smola",     color = {0.3, 0.3, 0.2} },
    { key = "ale",     name = "Ale",       color = {0.8, 0.6, 0.2} },
    { key = "bows",    name = "Loki",      color = {0.5, 0.3, 0.2} },
    { key = "swords",  name = "Meči",      color = {0.7, 0.7, 0.8} },
    { key = "spears",  name = "Kopja",     color = {0.6, 0.5, 0.3} },
}

function ResourceFlow.init()
    if initialized then return end
    initialized = true
    print("[ResourceFlow] Initialized")
end

function ResourceFlow.toggle()
    isVisible = not isVisible
end

function ResourceFlow.setVisible(visible)
    isVisible = visible
end

function ResourceFlow.isVisible()
    return isVisible
end

function ResourceFlow.update(dt)
    if not initialized or not isVisible then return end

    updateTimer = updateTimer + dt
    if updateTimer < updateInterval then return end
    updateTimer = 0

    -- Calculate production/consumption for each resource
    for _, res in ipairs(RESOURCE_LIST) do
        if not flowData[res.key] then
            flowData[res.key] = { production = 0, consumption = 0, net = 0, lastAmount = 0 }
        end

        local currentAmount = 0
        if _G.state and _G.state.resources then
            currentAmount = _G.state.resources[res.key] or 0
        end
        if res.key == "gold" and _G.state then
            currentAmount = _G.state.gold or 0
        end

        local data = flowData[res.key]
        local delta = currentAmount - (data.lastAmount or 0)
        data.net = delta
        data.lastAmount = currentAmount
        data.current = currentAmount

        -- Estimate production and consumption from buildings
        data.production = ResourceFlow._estimateProduction(res.key)
        data.consumption = ResourceFlow._estimateConsumption(res.key)
    end
end

function ResourceFlow._estimateProduction(resourceKey)
    local total = 0
    if not _G.state or not _G.state.gameObjectList then return 0 end

    local producers = {
        wood = {"Woodcutter"},
        stone = {"Quarry"},
        iron = {"IronMine"},
        pitch = {"PitchRig"},
        food = {"Bakery", "HunterHut", "Orchard", "DairyFarm"},
        ale = {"Brewery"},
        bows = {"Fletcher"},
        swords = {"Blacksmith"},
        spears = {"Poleturner"},
    }

    local buildingList = producers[resourceKey]
    if not buildingList then return 0 end

    for _, obj in ipairs(_G.state.gameObjectList) do
        if obj.class and obj.class.name then
            for _, bName in ipairs(buildingList) do
                if obj.class.name == bName then
                    total = total + 1
                end
            end
        end
    end

    return total
end

function ResourceFlow._estimateConsumption(resourceKey)
    local total = 0
    if not _G.state or not _G.state.gameObjectList then return 0 end

    local consumers = {
        wood = {"Stockpile", "Barracks", "Woodcutter", "Quarry", "WheatFarm"},
        stone = {"StoneBarracks", "Armoury"},
        iron = {"Blacksmith", "Armorer"},
        food = {"Inn"},  -- Population eats food
        ale = {"Inn"},
    }

    local buildingList = consumers[resourceKey]
    if not buildingList then return 0 end

    for _, obj in ipairs(_G.state.gameObjectList) do
        if obj.class and obj.class.name then
            for _, bName in ipairs(buildingList) do
                if obj.class.name == bName then
                    total = total + 1
                end
            end
        end
    end

    -- Population consumes food
    if resourceKey == "food" and _G.state and _G.state.population then
        total = total + math.ceil(_G.state.population / 4)
    end

    return total
end

function ResourceFlow.draw()
    if not initialized or not isVisible then return end

    local w, h = love.graphics.getDimensions()
    local panelW = 280
    local panelH = #RESOURCE_LIST * 22 + 40
    local panelX = 10
    local panelY = 50

    -- Background
    love.graphics.setColor(0, 0, 0, 0.85)
    love.graphics.rectangle("fill", panelX, panelY, panelW, panelH)

    -- Border
    love.graphics.setColor(0.4, 0.5, 0.3, 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", panelX, panelY, panelW, panelH)

    -- Title
    love.graphics.setColor(1, 0.9, 0.5, 1)
    love.graphics.print("=== Tok surovin ===", panelX + 10, panelY + 8)

    -- Resources
    for i, res in ipairs(RESOURCE_LIST) do
        local y = panelY + 30 + (i - 1) * 22
        local data = flowData[res.key] or { production = 0, consumption = 0, net = 0, current = 0 }

        -- Resource name + amount
        love.graphics.setColor(res.color[1], res.color[2], res.color[3], 1)
        love.graphics.print(res.name .. ":", panelX + 10, y)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(tostring(data.current or 0), panelX + 70, y)

        -- Production (+green)
        love.graphics.setColor(0.3, 0.9, 0.3, 1)
        love.graphics.print("+" .. tostring(data.production), panelX + 120, y)

        -- Consumption (-red)
        love.graphics.setColor(0.9, 0.3, 0.3, 1)
        love.graphics.print("-" .. tostring(data.consumption), panelX + 160, y)

        -- Net rate
        local net = (data.production or 0) - (data.consumption or 0)
        if net > 0 then
            love.graphics.setColor(0.3, 0.9, 0.3, 1)
            love.graphics.print("(+" .. net .. ")", panelX + 210, y)
        elseif net < 0 then
            love.graphics.setColor(0.9, 0.3, 0.3, 1)
            love.graphics.print("(" .. net .. ")", panelX + 210, y)
        else
            love.graphics.setColor(0.6, 0.6, 0.6, 1)
            love.graphics.print("(0)", panelX + 210, y)
        end
    end

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setLineWidth(1)
end

function ResourceFlow.getStats()
    return {
        visible = isVisible,
        resources = #RESOURCE_LIST,
        data = flowData,
    }
end

return ResourceFlow
