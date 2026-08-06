-- states/ui/economy/caravan_ui.lua
-- Stronghold 2027 - Trade Caravan UI
--
-- Allows player to:
-- - Select target AI faction
-- - Choose goods to send
-- - Set escort units
-- - See estimated payment and risk
-- - Track active caravans
--
-- Toggle with 'C' key or via Market building
--
-- Usage:
--   local CaravanUI = require("states.ui.economy.caravan_ui")
--   CaravanUI.toggle()
--   CaravanUI.update(dt)
--   CaravanUI.draw()

local loveframes = require("libraries.loveframes")
local TradeCaravans = require("objects.Economy.TradeCaravanSystem")
local DynamicMarket = require("objects.Economy.DynamicMarketSystem")
local AIIntegration = require("objects.AI.AIIntegration")

local CaravanUI = {}

-- State
local visible = false
local selectedFaction = nil
local selectedGoods = {}  -- map of resource -> quantity
local selectedEscort = {}  -- list of unit class names
local currentTab = "send"  -- send, active, history

-- Available goods for trade
local TRADE_GOODS = {
    {resource = "wood", name = "Les", nameSlv = "Les"},
    {resource = "stone", name = "Kamen", nameSlv = "Kamen"},
    {resource = "iron", name = "Železo", nameSlv = "Železo"},
    {resource = "wheat", name = "Pšenica", nameSlv = "Pšenica"},
    {resource = "ale", name = "Ale", nameSlv = "Ale"},
    {resource = "bread", name = "Kruh", nameSlv = "Kruh"},
}

-- Available escort units
local ESCORT_UNITS = {
    {unit = "Knight", name = "Vitez", cost = 50},
    {unit = "Archer", name = "Lokostrelec", cost = 30},
    {unit = "Swordsman", name = "Mečevalec", cost = 40},
    {unit = "Maceman", name = "Buzdovanaš", cost = 35},
}

-- Toggle visibility
function CaravanUI.toggle()
    visible = not visible
    if visible then
        CaravanUI.refreshFactions()
    end
end

function CaravanUI.setVisible(state)
    visible = state
end

function CaravanUI.isVisible()
    return visible
end

-- Refresh available AI factions
function CaravanUI.refreshFactions()
    -- Will be populated when drawing
end

-- Get available AI factions
function CaravanUI.getAvailableFactions()
    local factions = {}
    if AIIntegration and AIIntegration.getAllFactionsInfo then
        local allInfo = AIIntegration.getAllFactionsInfo()
        for _, info in ipairs(allInfo) do
            table.insert(factions, {
                id = info.faction,
                name = string.format("Faction %d (%s/%s)", info.faction, info.personality, info.difficulty),
                personality = info.personality,
                difficulty = info.difficulty,
            })
        end
    end
    return factions
end

-- Update UI
function CaravanUI.update(dt)
    if not visible then return end
end

-- Calculate estimated values
function CaravanUI.getEstimates()
    local totalGoods = 0
    for _, qty in pairs(selectedGoods) do
        totalGoods = totalGoods + qty
    end

    local estimatedPayment = TradeCaravans.estimatePayment(selectedGoods)
    local risk = TradeCaravans.calculateRisk(selectedEscort)
    local escortCount = #selectedEscort

    return {
        totalGoods = totalGoods,
        payment = estimatedPayment,
        risk = risk,
        escortCount = escortCount,
        canSend = totalGoods > 0 and selectedFaction ~= nil,
    }
end

-- Send caravan
function CaravanUI.sendCaravan()
    local estimates = CaravanUI.getEstimates()
    if not estimates.canSend then return false end

    local caravanId = TradeCaravans.send(
        selectedFaction,
        selectedGoods,
        estimates.payment,
        selectedEscort
    )

    if caravanId then
        -- Reset selection
        selectedGoods = {}
        selectedEscort = {}
        return true
    end
    return false
end

-- Add goods
function CaravanUI.addGood(resource, amount)
    selectedGoods[resource] = (selectedGoods[resource] or 0) + amount
end

-- Remove goods
function CaravanUI.removeGood(resource, amount)
    selectedGoods[resource] = (selectedGoods[resource] or 0) - amount
    if selectedGoods[resource] <= 0 then
        selectedGoods[resource] = nil
    end
end

-- Toggle escort unit
function CaravanUI.toggleEscort(unitName)
    for i, u in ipairs(selectedEscort) do
        if u == unitName then
            table.remove(selectedEscort, i)
            return
        end
    end
    table.insert(selectedEscort, unitName)
end

-- Draw the caravan UI
function CaravanUI.draw()
    if not visible then return end

    local screenW, screenH = love.graphics.getDimensions()
    local panelW = 700
    local panelH = 550
    local panelX = (screenW - panelW) / 2
    local panelY = (screenH - panelH) / 2

    -- Background overlay
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 0, 0, screenW, screenH)

    -- Main panel
    love.graphics.setColor(0.15, 0.12, 0.1, 0.95)
    love.graphics.rectangle("fill", panelX, panelY, panelW, panelH, 8, 8, 8, 8)

    -- Border
    love.graphics.setColor(0.6, 0.5, 0.3, 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", panelX, panelY, panelW, panelH, 8, 8, 8, 8)

    -- Title
    love.graphics.setColor(1, 0.9, 0.7, 1)
    love.graphics.print("Trgovske Karavane", panelX + 20, panelY + 15)

    -- Tabs
    local tabY = panelY + 50
    local tabX = panelX + 20
    local tabs = {"send", "active", "history"}
    local tabLabels = {send = "Pošlji", active = "Aktivne", history = "Zgodovina"}

    for _, tab in ipairs(tabs) do
        local label = tabLabels[tab]
        local tabW = 120
        local isActive = currentTab == tab

        if isActive then
            love.graphics.setColor(0.4, 0.35, 0.25, 1)
        else
            love.graphics.setColor(0.2, 0.18, 0.15, 1)
        end
        love.graphics.rectangle("fill", tabX, tabY, tabW, 25, 4, 4, 4, 4)

        love.graphics.setColor(0.6, 0.5, 0.3, 1)
        love.graphics.rectangle("line", tabX, tabY, tabW, 25, 4, 4, 4, 4)

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(label, tabX + 20, tabY + 5)

        tabX = tabX + tabW + 5
    end

    -- Draw current tab content
    if currentTab == "send" then
        CaravanUI.drawSendTab(panelX, panelY + 90, panelW, panelH - 90)
    elseif currentTab == "active" then
        CaravanUI.drawActiveTab(panelX, panelY + 90, panelW, panelH - 90)
    elseif currentTab == "history" then
        CaravanUI.drawHistoryTab(panelX, panelY + 90, panelW, panelH - 90)
    end

    -- Close hint
    love.graphics.setColor(0.6, 0.6, 0.6, 1)
    love.graphics.print("[C] Zapri", panelX + panelW - 80, panelY + panelH - 25)

    love.graphics.setColor(1, 1, 1, 1)
end

-- Draw send tab
function CaravanUI.drawSendTab(panelX, startY, panelW, panelH)
    local y = startY

    -- Section 1: Target faction
    love.graphics.setColor(1, 0.9, 0.7, 1)
    love.graphics.print("1. Izberi ciljno frakcijo:", panelX + 20, y)
    y = y + 25

    local factions = CaravanUI.getAvailableFactions()
    if #factions == 0 then
        love.graphics.setColor(0.8, 0.5, 0.5, 1)
        love.graphics.print("Ni AI nasprotnikov. Pritisni F7 za spawn AI.", panelX + 30, y)
        y = y + 60
    else
        local fxX = panelX + 30
        for i, faction in ipairs(factions) do
            local isSelected = selectedFaction == faction.id
            if isSelected then
                love.graphics.setColor(0.3, 0.4, 0.3, 1)
            else
                love.graphics.setColor(0.2, 0.2, 0.2, 1)
            end
            love.graphics.rectangle("fill", fxX, y, 200, 30, 4, 4, 4, 4)
            love.graphics.setColor(0.6, 0.5, 0.3, 1)
            love.graphics.rectangle("line", fxX, y, 200, 30, 4, 4, 4, 4)
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.print(faction.name, fxX + 10, y + 7)
            fxX = fxX + 210
            if fxX > panelX + panelW - 200 then
                fxX = panelX + 30
                y = y + 35
            end
        end
        y = y + 50
    end

    -- Section 2: Goods selection
    love.graphics.setColor(1, 0.9, 0.7, 1)
    love.graphics.print("2. Izberi blago za trgovino:", panelX + 20, y)
    y = y + 25

    for _, good in ipairs(TRADE_GOODS) do
        local qty = selectedGoods[good.resource] or 0
        local price = DynamicMarket.getPrice(good.resource, "sell")

        -- Background
        love.graphics.setColor(0.2, 0.18, 0.15, 1)
        love.graphics.rectangle("fill", panelX + 30, y, panelW - 60, 30, 4, 4, 4, 4)

        -- Resource name
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(good.nameSlv, panelX + 40, y + 7)

        -- Current price
        love.graphics.setColor(0.5, 1, 0.5, 1)
        love.graphics.print(string.format("Cena: %d g", price), panelX + 180, y + 7)

        -- Quantity
        love.graphics.setColor(1, 0.9, 0.5, 1)
        love.graphics.print(string.format("Količina: %d", qty), panelX + 320, y + 7)

        -- Buttons (- and +)
        love.graphics.setColor(0.5, 0.3, 0.3, 1)
        love.graphics.rectangle("fill", panelX + 450, y + 3, 25, 24)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print("-10", panelX + 455, y + 10)

        love.graphics.setColor(0.3, 0.5, 0.3, 1)
        love.graphics.rectangle("fill", panelX + 485, y + 3, 25, 24)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print("+10", panelX + 488, y + 10)

        y = y + 35
    end

    y = y + 10

    -- Section 3: Escort
    love.graphics.setColor(1, 0.9, 0.7, 1)
    love.graphics.print("3. Spremstvo (zmanjša tveganje):", panelX + 20, y)
    y = y + 25

    local escX = panelX + 30
    for _, unit in ipairs(ESCORT_UNITS) do
        local isSelected = false
        for _, s in ipairs(selectedEscort) do
            if s == unit.unit then isSelected = true; break end
        end

        if isSelected then
            love.graphics.setColor(0.3, 0.4, 0.3, 1)
        else
            love.graphics.setColor(0.2, 0.2, 0.2, 1)
        end
        love.graphics.rectangle("fill", escX, y, 150, 30, 4, 4, 4, 4)
        love.graphics.setColor(0.6, 0.5, 0.3, 1)
        love.graphics.rectangle("line", escX, y, 150, 30, 4, 4, 4, 4)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(string.format("%s (%d g)", unit.name, unit.cost), escX + 10, y + 7)
        escX = escX + 160
    end
    y = y + 50

    -- Section 4: Summary and send button
    local estimates = CaravanUI.getEstimates()

    love.graphics.setColor(0.2, 0.18, 0.15, 0.95)
    love.graphics.rectangle("fill", panelX + 20, y, panelW - 40, 80, 6, 6, 6, 6)
    love.graphics.setColor(0.6, 0.5, 0.3, 1)
    love.graphics.rectangle("line", panelX + 20, y, panelW - 40, 80, 6, 6, 6, 6)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(string.format("Skupno blago: %d", estimates.totalGoods), panelX + 35, y + 10)
    love.graphics.setColor(0.5, 1, 0.5, 1)
    love.graphics.print(string.format("Pričakovan dobiček: %d g (+30%%)", estimates.payment), panelX + 35, y + 30)
    love.graphics.setColor(1, 0.7, 0.3, 1)
    love.graphics.print(string.format("Tveganje napada: %.0f%%", estimates.risk * 100), panelX + 35, y + 50)
    love.graphics.setColor(0.7, 0.7, 1, 1)
    love.graphics.print(string.format("Spremstvo: %d enot", estimates.escortCount), panelX + 300, y + 10)

    -- Send button
    if estimates.canSend then
        love.graphics.setColor(0.3, 0.6, 0.3, 1)
    else
        love.graphics.setColor(0.3, 0.3, 0.3, 1)
    end
    love.graphics.rectangle("fill", panelX + panelW - 180, y + 20, 140, 40, 6, 6, 6, 6)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("POŠLJI KARAVANO", panelX + panelW - 165, y + 32)
end

-- Draw active caravans tab
function CaravanUI.drawActiveTab(panelX, startY, panelW, panelH)
    local y = startY

    love.graphics.setColor(1, 0.9, 0.7, 1)
    love.graphics.print("Aktivne karavane:", panelX + 20, y)
    y = y + 30

    local activeCaravans = TradeCaravans.getActiveCaravans()

    if #activeCaravans == 0 then
        love.graphics.setColor(0.7, 0.7, 0.7, 1)
        love.graphics.print("Ni aktivnih karavan.", panelX + 30, y)
        return
    end

    for _, caravan in ipairs(activeCaravans) do
        love.graphics.setColor(0.2, 0.18, 0.15, 1)
        love.graphics.rectangle("fill", panelX + 20, y, panelW - 40, 60, 6, 6, 6, 6)
        love.graphics.setColor(0.6, 0.5, 0.3, 1)
        love.graphics.rectangle("line", panelX + 20, y, panelW - 40, 60, 6, 6, 6, 6)

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(string.format("Karavana #%d → Frakcija %d", caravan.id, caravan.targetFaction),
            panelX + 30, y + 8)

        love.graphics.setColor(0.7, 0.7, 0.7, 1)
        love.graphics.print(string.format("Stanje: %s", caravan.state), panelX + 30, y + 25)
        love.graphics.print(string.format("Dobiček: %d g", caravan.payment), panelX + 200, y + 25)
        love.graphics.print(string.format("Preostali čas: %.0fs", caravan.remaining), panelX + 350, y + 25)

        -- Progress bar
        local barX = panelX + 30
        local barY = y + 45
        local barW = panelW - 60
        local barH = 8

        love.graphics.setColor(0.2, 0.2, 0.2, 1)
        love.graphics.rectangle("fill", barX, barY, barW, barH)

        love.graphics.setColor(0.3, 0.7, 0.3, 1)
        love.graphics.rectangle("fill", barX, barY, barW * caravan.progress, barH)

        y = y + 70
    end
end

-- Draw history tab
function CaravanUI.drawHistoryTab(panelX, startY, panelW, panelH)
    local y = startY

    love.graphics.setColor(1, 0.9, 0.7, 1)
    love.graphics.print("Zgodovina karavan:", panelX + 20, y)
    y = y + 30

    local stats = TradeCaravans.getStats()
    love.graphics.setColor(0.8, 0.8, 0.8, 1)
    love.graphics.print(string.format("Skupaj: %d | Uspešne: %d | Neuspešne: %d | Dobiček: %d g | Stopnja uspeha: %.0f%%",
        stats.completedCount, stats.successCount, stats.failCount, stats.totalProfit, stats.successRate * 100),
        panelX + 20, y)
    y = y + 30

    local history = TradeCaravans.getCompletedCaravans()

    if #history == 0 then
        love.graphics.setColor(0.7, 0.7, 0.7, 1)
        love.graphics.print("Ni zgodovine karavan.", panelX + 30, y)
        return
    end

    -- Header
    love.graphics.setColor(0.7, 0.7, 0.7, 1)
    love.graphics.print("ID", panelX + 30, y)
    love.graphics.print("Frakcija", panelX + 90, y)
    love.graphics.print("Rezultat", panelX + 200, y)
    love.graphics.print("Dobiček", panelX + 320, y)
    y = y + 25

    -- Show last 10
    local startIdx = math.max(1, #history - 9)
    for i = #history, startIdx, -1 do
        local caravan = history[i]

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print("#" .. caravan.id, panelX + 30, y)
        love.graphics.print("Frakcija " .. caravan.targetFaction, panelX + 90, y)

        if caravan.success then
            love.graphics.setColor(0.3, 1, 0.3, 1)
            love.graphics.print("Uspešno", panelX + 200, y)
        else
            love.graphics.setColor(1, 0.3, 0.3, 1)
            love.graphics.print("Napadeno", panelX + 200, y)
        end

        love.graphics.setColor(0.5, 1, 0.5, 1)
        love.graphics.print(caravan.payment .. " g", panelX + 320, y)

        y = y + 25
    end
end

-- Handle mouse click
function CaravanUI.mousepressed(x, y, button)
    if not visible or button ~= 1 then return false end

    local screenW, screenH = love.graphics.getDimensions()
    local panelW = 700
    local panelH = 550
    local panelX = (screenW - panelW) / 2
    local panelY = (screenH - panelH) / 2

    -- Tab clicks
    local tabY = panelY + 50
    local tabX = panelX + 20
    local tabs = {"send", "active", "history"}
    local tabW = 120

    for _, tab in ipairs(tabs) do
        if x >= tabX and x <= tabX + tabW and y >= tabY and y <= tabY + 25 then
            currentTab = tab
            return true
        end
        tabX = tabX + tabW + 5
    end

    -- Handle tab-specific clicks
    if currentTab == "send" then
        return CaravanUI.handleSendTabClick(x, y, panelX, panelY + 90)
    end

    return false
end

-- Handle clicks on send tab
function CaravanUI.handleSendTabClick(x, y, panelX, startY)
    local cy = startY + 25  -- skip section title

    -- Faction selection
    local factions = CaravanUI.getAvailableFactions()
    if #factions > 0 then
        local fxX = panelX + 30
        for _, faction in ipairs(factions) do
            if x >= fxX and x <= fxX + 200 and y >= cy and y <= cy + 30 then
                selectedFaction = faction.id
                return true
            end
            fxX = fxX + 210
            if fxX > panelX + 600 then
                fxX = panelX + 30
                cy = cy + 35
            end
        end
        cy = cy + 50
    end

    -- Goods section (skip title)
    cy = cy + 25
    for _, good in ipairs(TRADE_GOODS) do
        -- -10 button
        if x >= panelX + 450 and x <= panelX + 475 and y >= cy + 3 and y <= cy + 27 then
            CaravanUI.removeGood(good.resource, 10)
            return true
        end
        -- +10 button
        if x >= panelX + 485 and x <= panelX + 510 and y >= cy + 3 and y <= cy + 27 then
            CaravanUI.addGood(good.resource, 10)
            return true
        end
        cy = cy + 35
    end

    -- Escort section (skip title)
    cy = cy + 20  -- section title
    local escX = panelX + 30
    for _, unit in ipairs(ESCORT_UNITS) do
        if x >= escX and x <= escX + 150 and y >= cy and y <= cy + 30 then
            CaravanUI.toggleEscort(unit.unit)
            return true
        end
        escX = escX + 160
    end

    cy = cy + 50

    -- Send button
    local estimates = CaravanUI.getEstimates()
    if estimates.canSend then
        if x >= panelX + panelW - 180 and x <= panelX + panelW - 40
           and y >= cy + 20 and y <= cy + 60 then
            CaravanUI.sendCaravan()
            return true
        end
    end

    return false
end

-- Handle keypress
function CaravanUI.keypressed(key)
    if key == "c" or key == "escape" then
        CaravanUI.toggle()
        return true
    end
    return false
end

-- Get info
function CaravanUI.getInfo()
    return {
        visible = visible,
        tab = currentTab,
        selectedFaction = selectedFaction,
        goodsCount = #selectedGoods,
        escortCount = #selectedEscort,
    }
end

return CaravanUI
