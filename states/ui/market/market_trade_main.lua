local loveframes = require("libraries.loveframes")
local states = require("states.ui.states")
local framesActionBar = require("states.ui.action_bar_frames")
local actionBar = require("states.ui.ActionBar")
local scale = actionBar.element.scalex

local group = {}

local ActionBarButton = require("states.ui.ActionBarButton")
local backButton = ActionBarButton:new(love.graphics.newImage("assets/ui/back_ab.png"), states.STATE_MARKET_MAIN, 12)
backButton:setOnClick(function(self)
    actionBar:switchMode()
end)
actionBar:registerGroup("market", { backButton })

local foodIconImage = love.graphics.newImage("assets/ui/goods/FoodIcon.png")
local foodIconHoverImage = love.graphics.newImage("assets/ui/goods/FoodIconHover.png")

local materialIconImage = love.graphics.newImage("assets/ui/goods/MaterialIcon.png")
local materialIconHoverImage = love.graphics.newImage("assets/ui/goods/MaterialIconHover.png")

local weaponsIconImage = love.graphics.newImage("assets/ui/goods/WeaponsIcon.png")
local weaponsIconHoverImage = love.graphics.newImage("assets/ui/goods/WeaponsIconHover.png")

local frFoodIcon = {
    x = framesActionBar["frFull"].x + 330 * scale,
    y = framesActionBar["frFull"].y + 130 * scale,
    width = foodIconImage:getWidth() * scale,
    height = foodIconImage:getHeight() * scale
}
local frMaterialIcon = {
    x = framesActionBar["frFull"].x + 530 * scale,
    y = framesActionBar["frFull"].y + 130 * scale,
    width = materialIconImage:getWidth() * scale,
    height = materialIconImage:getHeight() * scale
}
local frWeaponsIcon = {
    x = framesActionBar["frFull"].x + 730 * scale,
    y = framesActionBar["frFull"].y + 130 * scale,
    width = weaponsIconImage:getWidth() * scale,
    height = weaponsIconImage:getHeight() * scale
}

local foodIconButton = loveframes.Create("image")
foodIconButton:SetState(states.STATE_MARKET_MAIN)
foodIconButton:SetImage(foodIconImage)
foodIconButton:SetScaleX(frFoodIcon.width / foodIconButton:GetImageWidth())
foodIconButton:SetScaleY(foodIconButton:GetScaleX())
foodIconButton:SetPos(frFoodIcon.x, frFoodIcon.y)
foodIconButton.OnMouseEnter = function(self)
    self:SetImage(foodIconHoverImage)
end
foodIconButton.OnMouseDown = function(self)
    self:SetImage(foodIconHoverImage)
end
foodIconButton.OnClick = function(self)
    actionBar:switchMode("market_trade")
    local switchTradeGroup = unpack(require("states.ui.market.market_trade"))
    switchTradeGroup(1)
    group.name = 1
end
foodIconButton.OnMouseExit = function(self)
    self:SetImage(foodIconImage)
end

local materialIconButton = loveframes.Create("image")
materialIconButton:SetState(states.STATE_MARKET_MAIN)
materialIconButton:SetImage(materialIconImage)
materialIconButton:SetScaleX(frMaterialIcon.width / materialIconButton:GetImageWidth())
materialIconButton:SetScaleY(materialIconButton:GetScaleX())
materialIconButton:SetPos(frMaterialIcon.x, frMaterialIcon.y)
materialIconButton.OnMouseEnter = function(self)
    self:SetImage(materialIconHoverImage)
end
materialIconButton.OnMouseDown = function(self)
    self:SetImage(materialIconHoverImage)
end
materialIconButton.OnClick = function(self)
    actionBar:switchMode("market_trade")
    local switchTradeGroup = unpack(require("states.ui.market.market_trade"))
    switchTradeGroup(2)
    group.name = 2
end
materialIconButton.OnMouseExit = function(self)
    self:SetImage(materialIconImage)
end

local weaponsIconButton = loveframes.Create("image")
weaponsIconButton:SetState(states.STATE_MARKET_MAIN)
weaponsIconButton:SetImage(weaponsIconImage)
weaponsIconButton:SetScaleX(frWeaponsIcon.width / weaponsIconButton:GetImageWidth())
weaponsIconButton:SetScaleY(weaponsIconButton:GetScaleX())
weaponsIconButton:SetPos(frWeaponsIcon.x, frWeaponsIcon.y)
weaponsIconButton.OnMouseEnter = function(self)
    self:SetImage(weaponsIconHoverImage)
end
weaponsIconButton.OnMouseDown = function(self)
    self:SetImage(weaponsIconHoverImage)
end
weaponsIconButton.OnClick = function(self)
    actionBar:switchMode("market_trade")
    local switchTradeGroup = unpack(require("states.ui.market.market_trade"))
    switchTradeGroup(3)
    group.name = 3
end
weaponsIconButton.OnMouseExit = function(self)
    self:SetImage(weaponsIconImage)
end

return group
