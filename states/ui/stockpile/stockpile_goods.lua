local loveframes = require("libraries.loveframes")
local states = require("states.ui.states")
local framesActionBar = require("states.ui.action_bar_frames")
local actionBar = require("states.ui.ActionBar")
local scale = actionBar.element.scalex
local Events = require "objects.Enums.Events"

local group = {}

local ActionBarButton = require("states.ui.ActionBarButton")
local backButton = ActionBarButton:new(love.graphics.newImage("assets/ui/back_ab.png"), states.STATE_STOCKPILE, 12)
backButton:setOnClick(function(self)
    actionBar:switchMode()
end)
actionBar:registerGroup("stockpile", { backButton })

local woodIconNormal = love.graphics.newImage("assets/ui/goods/woodIcon.png")
local woodIconHover = love.graphics.newImage("assets/ui/goods/woodIconHover.png")
local stoneIconNormal = love.graphics.newImage("assets/ui/goods/stoneIcon.png")
local stoneIconHover = love.graphics.newImage("assets/ui/goods/stoneIconHover.png")
local wheatIconNormal = love.graphics.newImage("assets/ui/goods/wheatIcon.png")
local wheatIconHover = love.graphics.newImage("assets/ui/goods/wheatIconHover.png")
local tarIconNormal = love.graphics.newImage("assets/ui/goods/tarIcon.png")
local tarIconHover = love.graphics.newImage("assets/ui/goods/tarIconHover.png")
local aleIconNormal = love.graphics.newImage("assets/ui/goods/aleIcon.png")
local aleIconHover = love.graphics.newImage("assets/ui/goods/aleIconHover.png")
local ironIconNormal = love.graphics.newImage("assets/ui/goods/ironIcon.png")
local ironIconHover = love.graphics.newImage("assets/ui/goods/ironIconHover.png")
local hopIconNormal = love.graphics.newImage("assets/ui/goods/hopIcon.png")
local hopIconHover = love.graphics.newImage("assets/ui/goods/hopIconHover.png")
local flourIconNormal = love.graphics.newImage("assets/ui/goods/flourIcon.png")
local flourIconHover = love.graphics.newImage("assets/ui/goods/flourIconHover.png")

local frWoodButton = {
    x = framesActionBar.frFull.x + 366 * scale,
    y = framesActionBar.frFull.y + 114 * scale,
    width = woodIconNormal:getWidth() * scale,
    height = woodIconNormal:getHeight() * scale
}

local frStoneButton = {
    x = framesActionBar.frFull.x + 426 * scale,
    y = framesActionBar.frFull.y + 116 * scale,
    width = stoneIconNormal:getWidth() * scale,
    height = stoneIconNormal:getHeight() * scale
}

local frWheatButton = {
    x = framesActionBar.frFull.x + 481 * scale,
    y = framesActionBar.frFull.y + 109 * scale,
    width = wheatIconNormal:getWidth() * scale,
    height = wheatIconNormal:getHeight() * scale
}

local frTarButton = {
    x = framesActionBar.frFull.x + 514 * scale,
    y = framesActionBar.frFull.y + 112 * scale,
    width = tarIconNormal:getWidth() * scale,
    height = tarIconNormal:getHeight() * scale
}

local frAleButton = {
    x = framesActionBar.frFull.x + 564 * scale,
    y = framesActionBar.frFull.y + 117 * scale,
    width = aleIconNormal:getWidth() * scale,
    height = aleIconNormal:getHeight() * scale
}

local frIronButton = {
    x = framesActionBar.frFull.x + 609 * scale,
    y = framesActionBar.frFull.y + 116 * scale,
    width = ironIconNormal:getWidth() * scale,
    height = ironIconNormal:getHeight() * scale
}

local frHopButton = {
    x = framesActionBar.frFull.x + 669 * scale,
    y = framesActionBar.frFull.y + 119 * scale,
    width = hopIconNormal:getWidth() * scale,
    height = hopIconNormal:getHeight() * scale
}

local frFlourButton = {
    x = framesActionBar.frFull.x + 722 * scale,
    y = framesActionBar.frFull.y + 112 * scale,
    width = flourIconNormal:getWidth() * scale,
    height = flourIconNormal:getHeight() * scale
}

local currentStockWood = loveframes.Create("text")
currentStockWood:SetState(states.STATE_STOCKPILE)
currentStockWood:SetFont(loveframes.font_times_new_normal_large)
currentStockWood:SetPos(frWoodButton.x - 10 + (frWoodButton.width / 2), frWoodButton.y + 51 * scale)
currentStockWood:SetShadow(false)

local currentStockStone = loveframes.Create("text")
currentStockStone:SetState(states.STATE_STOCKPILE)
currentStockStone:SetFont(loveframes.font_times_new_normal_large)
currentStockStone:SetPos(frStoneButton.x - 9 + (frStoneButton.width / 2), frStoneButton.y + 49 * scale)
currentStockStone:SetShadow(false)

local currentStockWheat = loveframes.Create("text")
currentStockWheat:SetState(states.STATE_STOCKPILE)
currentStockWheat:SetFont(loveframes.font_times_new_normal_large)
currentStockWheat:SetPos(frWheatButton.x - 10 + (frWheatButton.width / 2), frWheatButton.y + 55 * scale)
currentStockWheat:SetShadow(false)

local currentStockTar = loveframes.Create("text")
currentStockTar:SetState(states.STATE_STOCKPILE)
currentStockTar:SetFont(loveframes.font_times_new_normal_large)
currentStockTar:SetPos(frTarButton.x - 7 + (frTarButton.width / 2), frTarButton.y + 53 * scale)
currentStockTar:SetShadow(false)

local currentStockAle = loveframes.Create("text")
currentStockAle:SetState(states.STATE_STOCKPILE)
currentStockAle:SetFont(loveframes.font_times_new_normal_large)
currentStockAle:SetPos(frAleButton.x - 7 + (frAleButton.width / 2), frAleButton.y + 47 * scale)
currentStockAle:SetShadow(false)

local currentStockIron = loveframes.Create("text")
currentStockIron:SetState(states.STATE_STOCKPILE)
currentStockIron:SetFont(loveframes.font_times_new_normal_large)
currentStockIron:SetPos(frIronButton.x - 7 + (frIronButton.width / 2), frIronButton.y + 48 * scale)
currentStockIron:SetShadow(false)

local currentStockHop = loveframes.Create("text")
currentStockHop:SetState(states.STATE_STOCKPILE)
currentStockHop:SetFont(loveframes.font_times_new_normal_large)
currentStockHop:SetPos(frHopButton.x - 6 + (frHopButton.width / 2), frHopButton.y + 45 * scale)
currentStockHop:SetShadow(false)

local currentStockFlour = loveframes.Create("text")
currentStockFlour:SetState(states.STATE_STOCKPILE)
currentStockFlour:SetFont(loveframes.font_times_new_normal_large)
currentStockFlour:SetPos(frFlourButton.x - 8 + (frFlourButton.width / 2), frFlourButton.y + 52 * scale)
currentStockFlour:SetShadow(false)

local noMarketInfo = loveframes.Create("text")
noMarketInfo:SetState(states.STATE_STOCKPILE)
noMarketInfo:SetFont(loveframes.font_vera_italic)
noMarketInfo:SetSize(50, 20)
noMarketInfo:SetVisible(false)
noMarketInfo:SetPos(frWoodButton.x - 100 + (frWoodButton.width / 2), frWoodButton.y)
noMarketInfo:SetText({ {
    color = { 0, 0, 0, 1 }
}, "Build a market to trade!" })
noMarketInfo:SetShadow(false)
local function SwitchToTheMarket()
    noMarketInfo:SetVisible(false)
    if _G.BuildingManager:count("Market") >= 1 then
        local switchTradeGroup = unpack(require("states.ui.market.market_trade"))
        local resourceList = _G.MissionController:getLockedTradeResources()
        if resourceList ~= nil then
            for _, value in pairs(resourceList) do
                if value == group.good then
                    noMarketInfo:SetText({ {
                        color = { 0, 0, 0, 1 }
                    }, "You can't trade that!" })
                    noMarketInfo:SetVisible(true)
                    group.good = nil
                    return;
                end
            end
        end
        _G.bus.emit(Events.OnItemClicked, group.good)
        actionBar:switchMode("market_trade")
        switchTradeGroup(2)
        group.name = 2
        noMarketInfo:SetVisible(false)
    else
        noMarketInfo:SetText({ {
            color = { 0, 0, 0, 1 }
        }, "Build a market to trade!" })
        noMarketInfo:SetVisible(true)
    end
end

function actionBar:updateStockpileResourcesCount()
    currentStockWood:SetText({ {
        color = { 0, 0, 0, 1 }
    }, _G.state.resources["wood"] })
    currentStockStone:SetText({ {
        color = { 0, 0, 0, 1 }
    }, _G.state.resources["stone"] })
    currentStockWheat:SetText({ {
        color = { 0, 0, 0, 1 }
    }, _G.state.resources["wheat"] })
    currentStockTar:SetText({ {
        color = { 0, 0, 0, 1 }
    }, _G.state.resources["tar"] })
    currentStockAle:SetText({ {
        color = { 0, 0, 0, 1 }
    }, _G.state.resources["ale"] })
    currentStockIron:SetText({ {
        color = { 0, 0, 0, 1 }
    }, _G.state.resources["iron"] })
    currentStockHop:SetText({ {
        color = { 0, 0, 0, 1 }
    }, _G.state.resources["hop"] })
    currentStockFlour:SetText({ {
        color = { 0, 0, 0, 1 }
    }, _G.state.resources["flour"] })
end

-- wood button
local woodIconButton = loveframes.Create("image")
woodIconButton:SetState(states.STATE_STOCKPILE)
woodIconButton:SetImage(woodIconNormal)
woodIconButton:SetScaleX(frWoodButton.width / woodIconButton:GetImageWidth())
woodIconButton:SetScaleY(woodIconButton:GetScaleX())
woodIconButton:SetPos(frWoodButton.x, frWoodButton.y)
woodIconButton.OnMouseEnter = function(self)
    self:SetImage(woodIconHover)
end
woodIconButton.OnMouseDown = function(self)
    self:SetImage(woodIconNormal)
end
woodIconButton.OnClick = function(self)
    group.good = "wood"
    SwitchToTheMarket()
end
woodIconButton.OnMouseExit = function(self)
    self:SetImage(woodIconNormal)
end
-- stone button
local stoneIconButton = loveframes.Create("image")
stoneIconButton:SetState(states.STATE_STOCKPILE)
stoneIconButton:SetImage(stoneIconNormal)
stoneIconButton:SetScaleX(frStoneButton.width / stoneIconButton:GetImageWidth())
stoneIconButton:SetScaleY(stoneIconButton:GetScaleX())
stoneIconButton:SetPos(frStoneButton.x, frStoneButton.y)
stoneIconButton.OnMouseEnter = function(self)
    self:SetImage(stoneIconHover)
end
stoneIconButton.OnMouseDown = function(self)
    self:SetImage(stoneIconNormal)
end
stoneIconButton.OnClick = function(self)
    group.good = "stone"
    SwitchToTheMarket()
end
stoneIconButton.OnMouseExit = function(self)
    self:SetImage(stoneIconNormal)
end
-- wheat button
local wheatIconButton = loveframes.Create("image")
wheatIconButton:SetState(states.STATE_STOCKPILE)
wheatIconButton:SetImage(wheatIconNormal)
wheatIconButton:SetScaleX(frWheatButton.width / wheatIconButton:GetImageWidth())
wheatIconButton:SetScaleY(wheatIconButton:GetScaleX())
wheatIconButton:SetPos(frWheatButton.x, frWheatButton.y)
wheatIconButton.OnMouseEnter = function(self)
    self:SetImage(wheatIconHover)
end
wheatIconButton.OnMouseDown = function(self)
    self:SetImage(wheatIconNormal)
end
wheatIconButton.OnClick = function(self)
    group.good = "wheat"
    SwitchToTheMarket()
end
wheatIconButton.OnMouseExit = function(self)
    self:SetImage(wheatIconNormal)
end
-- tar button
local tarIconButton = loveframes.Create("image")
tarIconButton:SetState(states.STATE_STOCKPILE)
tarIconButton:SetImage(tarIconNormal)
tarIconButton:SetScaleX(frTarButton.width / tarIconButton:GetImageWidth())
tarIconButton:SetScaleY(tarIconButton:GetScaleX())
tarIconButton:SetPos(frTarButton.x, frTarButton.y)
tarIconButton.OnMouseEnter = function(self)
    self:SetImage(tarIconHover)
end
tarIconButton.OnMouseDown = function(self)
    self:SetImage(tarIconNormal)
end
tarIconButton.OnClick = function(self)
    group.good = "tar"
    SwitchToTheMarket()
end
tarIconButton.OnMouseExit = function(self)
    self:SetImage(tarIconNormal)
end
-- ale button
local aleIconButton = loveframes.Create("image")
aleIconButton:SetState(states.STATE_STOCKPILE)
aleIconButton:SetImage(aleIconNormal)
aleIconButton:SetScaleX(frAleButton.width / aleIconButton:GetImageWidth())
aleIconButton:SetScaleY(aleIconButton:GetScaleX())
aleIconButton:SetPos(frAleButton.x, frAleButton.y)
aleIconButton.OnMouseEnter = function(self)
    self:SetImage(aleIconHover)
end
aleIconButton.OnMouseDown = function(self)
    self:SetImage(aleIconNormal)
end
aleIconButton.OnClick = function(self)
    group.good = "ale"
    SwitchToTheMarket()
end
aleIconButton.OnMouseExit = function(self)
    self:SetImage(aleIconNormal)
end
-- iron button
local ironIconButton = loveframes.Create("image")
ironIconButton:SetState(states.STATE_STOCKPILE)
ironIconButton:SetImage(ironIconNormal)
ironIconButton:SetScaleX(frIronButton.width / ironIconButton:GetImageWidth())
ironIconButton:SetScaleY(ironIconButton:GetScaleX())
ironIconButton:SetPos(frIronButton.x, frIronButton.y)
ironIconButton.OnMouseEnter = function(self)
    self:SetImage(ironIconHover)
end
ironIconButton.OnMouseDown = function(self)
    self:SetImage(ironIconNormal)
end
ironIconButton.OnClick = function(self)
    group.good = "iron"
    SwitchToTheMarket()
end
ironIconButton.OnMouseExit = function(self)
    self:SetImage(ironIconNormal)
end
-- hop button
local hopIconButton = loveframes.Create("image")
hopIconButton:SetState(states.STATE_STOCKPILE)
hopIconButton:SetImage(hopIconNormal)
hopIconButton:SetScaleX(frHopButton.width / hopIconButton:GetImageWidth())
hopIconButton:SetScaleY(hopIconButton:GetScaleX())
hopIconButton:SetPos(frHopButton.x, frHopButton.y)
hopIconButton.OnMouseEnter = function(self)
    self:SetImage(hopIconHover)
end
hopIconButton.OnMouseDown = function(self)
    self:SetImage(hopIconNormal)
end
hopIconButton.OnClick = function(self)
    group.good = "hop"
    SwitchToTheMarket()
end
hopIconButton.OnMouseExit = function(self)
    self:SetImage(hopIconNormal)
end
-- flour button
local flourIconButton = loveframes.Create("image")
flourIconButton:SetState(states.STATE_STOCKPILE)
flourIconButton:SetImage(flourIconNormal)
flourIconButton:SetScaleX(frFlourButton.width / flourIconButton:GetImageWidth())
flourIconButton:SetScaleY(flourIconButton:GetScaleX())
flourIconButton:SetPos(frFlourButton.x, frFlourButton.y)
flourIconButton.OnMouseEnter = function(self)
    self:SetImage(flourIconHover)
end
flourIconButton.OnMouseDown = function(self)
    self:SetImage(flourIconNormal)
end
flourIconButton.OnClick = function(self)
    group.good = "flour"
    SwitchToTheMarket()
end
flourIconButton.OnMouseExit = function(self)
    self:SetImage(flourIconNormal)
end

return group
