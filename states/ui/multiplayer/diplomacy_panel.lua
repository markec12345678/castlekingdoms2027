-- states/ui/multiplayer/diplomacy_panel.lua
-- Stronghold 2027 - Diplomacy & Trade Panel
--
-- Shows diplomatic relationships and trade interface.
-- Press F9 to open/close.
--
-- Features:
-- - List of players and their relation to you
-- - Declare war / propose alliance / propose peace buttons
-- - Trade proposal form (offer/request resources)
-- - Pending trade proposals list
-- - Trade route management

local loveframes = require("libraries.loveframes")
local states = require("states.ui.states")
local DiplomacyController = require("objects.Network.DiplomacyController")
local TradeController = require("objects.Network.TradeController")
local GameClient = require("objects.Network.GameClient")
local NetworkProtocol = require("objects.Network.NetworkProtocol")

local DiplomacyPanel = {}

local panel = nil
local relationList = nil
local tradeList = nil
local isVisible = false
local selectedPlayerId = nil

-- Resource types for trade
local RESOURCE_TYPES = {"wood", "stone", "iron", "gold", "food", "pitch", "ale", "bows", "swords", "spears"}

-- Initialize panel
function DiplomacyPanel.init()
    if panel then return end

    local w, h = love.graphics.getDimensions()
    local panelW = 700
    local panelH = 550
    local panelX = (w - panelW) / 2
    local panelY = (h - panelH) / 2

    panel = loveframes.Create("frame")
    panel:SetName("Diplomacy & Trade - Stronghold 2027")
    panel:SetSize(panelW, panelH)
    panel:SetPos(panelX, panelY)
    panel:SetState(states.STATE_INGAME_CONSTRUCTION)
    panel:ShowCloseButton(false)
    panel:SetVisible(false)

    -- === LEFT SIDE: Diplomacy ===

    local dipTitle = loveframes.Create("text", panel)
    dipTitle:SetPos(15, 30)
    dipTitle:SetText("=== Diplomacy ===")
    dipTitle:SetFont(loveframes.font_vera_bold_medium)

    relationList = loveframes.Create("text", panel)
    relationList:SetPos(15, 55)
    relationList:SetSize(320, 200)

    -- Player selector
    local playerLabel = loveframes.Create("text", panel)
    playerLabel:SetPos(15, 260)
    playerLabel:SetText("Select Player:")

    local playerDropdown = loveframes.Create("multichoice", panel)
    playerDropdown:SetPos(15, 285)
    playerDropdown:SetSize(320, 30)
    playerDropdown.OnChoiceSelected = function(_, choice)
        selectedPlayerId = choice.id
    end

    -- Action buttons
    local btnY = 325
    local declareWarBtn = loveframes.Create("button", panel)
    declareWarBtn:SetPos(15, btnY)
    declareWarBtn:SetSize(100, 30)
    declareWarBtn:SetText("Declare War")
    declareWarBtn.OnClick = function()
        if selectedPlayerId then
            DiplomacyController.declareWar(selectedPlayerId)
            GameClient.send(NetworkProtocol.MSG.DECLARE_WAR, {targetId = selectedPlayerId})
            DiplomacyPanel.refresh()
        end
    end

    local allianceBtn = loveframes.Create("button", panel)
    allianceBtn:SetPos(125, btnY)
    allianceBtn:SetSize(100, 30)
    allianceBtn:SetText("Alliance")
    allianceBtn.OnClick = function()
        if selectedPlayerId then
            DiplomacyController.proposeAlliance(selectedPlayerId)
            GameClient.send(NetworkProtocol.MSG.PROPOSE_ALLIANCE, {targetId = selectedPlayerId})
            DiplomacyPanel.refresh()
        end
    end

    local peaceBtn = loveframes.Create("button", panel)
    peaceBtn:SetPos(235, btnY)
    peaceBtn:SetSize(100, 30)
    peaceBtn:SetText("Propose Peace")
    peaceBtn.OnClick = function()
        if selectedPlayerId then
            DiplomacyController.proposePeace(selectedPlayerId)
            GameClient.send(NetworkProtocol.MSG.PROPOSE_PEACE, {targetId = selectedPlayerId})
            DiplomacyPanel.refresh()
        end
    end

    local btnY2 = 365
    local breakBtn = loveframes.Create("button", panel)
    breakBtn:SetPos(15, btnY2)
    breakBtn:SetSize(100, 30)
    breakBtn:SetText("Break Alliance")
    breakBtn.OnClick = function()
        if selectedPlayerId then
            DiplomacyController.breakAlliance(selectedPlayerId)
            GameClient.send(NetworkProtocol.MSG.BREAK_ALLIANCE, {targetId = selectedPlayerId})
            DiplomacyPanel.refresh()
        end
    end

    -- === RIGHT SIDE: Trade ===

    local tradeTitle = loveframes.Create("text", panel)
    tradeTitle:SetPos(360, 30)
    tradeTitle:SetText("=== Trade ===")
    tradeTitle:SetFont(loveframes.font_vera_bold_medium)

    -- Offer section
    local offerLabel = loveframes.Create("text", panel)
    offerLabel:SetPos(360, 55)
    offerLabel:SetText("You Offer:")

    local offerTypeDropdown = loveframes.Create("multichoice", panel)
    offerTypeDropdown:SetPos(360, 80)
    offerTypeDropdown:SetSize(140, 25)
    for _, res in ipairs(RESOURCE_TYPES) do
        offerTypeDropdown:AddChoice(res)
    end

    local offerAmountInput = loveframes.Create("textinput", panel)
    offerAmountInput:SetPos(510, 80)
    offerAmountInput:SetSize(70, 25)
    offerAmountInput:SetText("100")
    offerAmountInput:SetNumeric(true)

    local offerAddBtn = loveframes.Create("button", panel)
    offerAddBtn:SetPos(590, 80)
    offerAddBtn:SetSize(90, 25)
    offerAddBtn:SetText("Add")

    -- Request section
    local reqLabel = loveframes.Create("text", panel)
    reqLabel:SetPos(360, 115)
    reqLabel:SetText("You Want:")

    local reqTypeDropdown = loveframes.Create("multichoice", panel)
    reqTypeDropdown:SetPos(360, 140)
    reqTypeDropdown:SetSize(140, 25)
    for _, res in ipairs(RESOURCE_TYPES) do
        reqTypeDropdown:AddChoice(res)
    end

    local reqAmountInput = loveframes.Create("textinput", panel)
    reqAmountInput:SetPos(510, 140)
    reqAmountInput:SetSize(70, 25)
    reqAmountInput:SetText("100")
    reqAmountInput:SetNumeric(true)

    local reqAddBtn = loveframes.Create("button", panel)
    reqAddBtn:SetPos(590, 140)
    reqAddBtn:SetSize(90, 25)
    reqAddBtn:SetText("Add")

    -- Current offer/request display
    local currentOffer = {}
    local currentRequest = {}

    local offerDisplay = loveframes.Create("text", panel)
    offerDisplay:SetPos(360, 175)
    offerDisplay:SetSize(320, 40)
    offerDisplay:SetText("Offer: (none)")

    local reqDisplay = loveframes.Create("text", panel)
    reqDisplay:SetPos(360, 220)
    reqDisplay:SetSize(320, 40)
    reqDisplay:SetText("Request: (none)")

    -- Helper to format resources
    local function formatResources(res)
        local parts = {}
        for k, v in pairs(res) do
            table.insert(parts, tostring(v) .. " " .. k)
        end
        if #parts == 0 then return "(none)" end
        return table.concat(parts, ", ")
    end

    offerAddBtn.OnClick = function()
        local resType = offerTypeDropdown:GetText()
        local amount = tonumber(offerAmountInput:GetText()) or 0
        if resType and amount > 0 then
            currentOffer[resType] = (currentOffer[resType] or 0) + amount
            offerDisplay:SetText("Offer: " .. formatResources(currentOffer))
        end
    end

    reqAddBtn.OnClick = function()
        local resType = reqTypeDropdown:GetText()
        local amount = tonumber(reqAmountInput:GetText()) or 0
        if resType and amount > 0 then
            currentRequest[resType] = (currentRequest[resType] or 0) + amount
            reqDisplay:SetText("Request: " .. formatResources(currentRequest))
        end
    end

    -- Propose trade button
    local proposeBtn = loveframes.Create("button", panel)
    proposeBtn:SetPos(360, 270)
    proposeBtn:SetSize(150, 30)
    proposeBtn:SetText("Propose Trade")
    proposeBtn.OnClick = function()
        if selectedPlayerId and (next(currentOffer) or next(currentRequest)) then
            local tradeId = TradeController.proposeTrade(selectedPlayerId, currentOffer, currentRequest)
            if tradeId then
                GameClient.send(NetworkProtocol.MSG.PROPOSE_TRADE, {
                    tradeId = tradeId,
                    targetId = selectedPlayerId,
                    offer = currentOffer,
                    request = currentRequest,
                })
                currentOffer = {}
                currentRequest = {}
                offerDisplay:SetText("Offer: (none)")
                reqDisplay:SetText("Request: (none)")
                DiplomacyPanel.refresh()
            end
        end
    end

    -- Gift button
    local giftBtn = loveframes.Create("button", panel)
    giftBtn:SetPos(520, 270)
    giftBtn:SetSize(150, 30)
    giftBtn:SetText("Gift Resources")
    giftBtn.OnClick = function()
        if selectedPlayerId and next(currentOffer) then
            TradeController.giftResources(selectedPlayerId, currentOffer)
            GameClient.send(NetworkProtocol.MSG.GIFT_RESOURCES, {
                targetId = selectedPlayerId,
                resources = currentOffer,
            })
            currentOffer = {}
            offerDisplay:SetText("Offer: (none)")
            DiplomacyPanel.refresh()
        end
    end

    -- Pending trades list
    local pendingLabel = loveframes.Create("text", panel)
    pendingLabel:SetPos(360, 310)
    pendingLabel:SetText("Pending Trades:")

    tradeList = loveframes.Create("text", panel)
    tradeList:SetPos(360, 335)
    tradeList:SetSize(320, 120)

    -- Close button
    local closeBtn = loveframes.Create("button", panel)
    closeBtn:SetPos(280, 490)
    closeBtn:SetSize(140, 35)
    closeBtn:SetText("Close (F9)")
    closeBtn.OnClick = function()
        DiplomacyPanel.hide()
    end

    -- Store reference for updating
    DiplomacyPanel._playerDropdown = playerDropdown
end

-- Show panel
function DiplomacyPanel.show()
    DiplomacyPanel.init()
    isVisible = true
    panel:SetVisible(true)
    DiplomacyPanel.refresh()
end

-- Hide panel
function DiplomacyPanel.hide()
    isVisible = false
    if panel then panel:SetVisible(false) end
end

function DiplomacyPanel.toggle()
    if isVisible then
        DiplomacyPanel.hide()
    else
        DiplomacyPanel.show()
    end
end

function DiplomacyPanel.isVisible()
    return isVisible
end

-- Refresh display
function DiplomacyPanel.refresh()
    if not isVisible then return end

    -- Update relations
    local status = DiplomacyController.getStatus()
    local lines = {}
    for playerId, info in pairs(status) do
        local relStr = info.relation
        if info.relation == "truce" and info.timeRemaining then
            relStr = string.format("truce (%ds)", info.timeRemaining)
        end
        table.insert(lines, string.format("Player %d: %s", playerId, relStr))
    end

    if #lines == 0 then
        relationList:SetText("No diplomatic relationships\n(All players neutral)")
    else
        relationList:SetText(table.concat(lines, "\n"))
    end

    -- Update player dropdown
    if DiplomacyPanel._playerDropdown then
        -- Get player list from server
        local GameServer = require("objects.Network.GameServer")
        local clients = GameServer.getClients()
        DiplomacyPanel._playerDropdown:Clear()
        for _, client in pairs(clients) do
            if client.id ~= DiplomacyController.getMyPlayerId() then
                DiplomacyPanel._playerDropdown:AddChoice(
                    string.format("Player %d: %s", client.id, client.name),
                    {id = client.id}
                )
            end
        end
    end

    -- Update pending trades
    local pending = TradeController.getPendingTrades()
    local tradeLines = {}
    for _, trade in ipairs(pending) do
        local offerStr = ""
        for k, v in pairs(trade.offer) do offerStr = offerStr .. v .. " " .. k .. " " end
        local reqStr = ""
        for k, v in pairs(trade.request) do reqStr = reqStr .. v .. " " .. k .. " " end
        table.insert(tradeLines, string.format("#%d from P%d: [%s] for [%s]",
            trade.id, trade.fromPlayer, offerStr, reqStr))
    end

    if #tradeLines == 0 then
        tradeList:SetText("No pending trades")
    else
        tradeList:SetText(table.concat(tradeLines, "\n"))
    end
end

return DiplomacyPanel
