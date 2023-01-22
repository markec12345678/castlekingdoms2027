local loveframes = require("libraries.loveframes")
local actionBar = require("states.ui.ActionBar")
local states = require("states.ui.states")
local scale = actionBar.element.scalex
local bowIconNormal = love.graphics.newImage("assets/ui/fletcher/bowIconNormal.png")
local bowIconHover = love.graphics.newImage("assets/ui/fletcher/bowIconHover.png")
local crossbowIconNormal = love.graphics.newImage("assets/ui/fletcher/crossbowIconNormal.png")
local crossbowIconHover = love.graphics.newImage("assets/ui/fletcher/crossbowIconHover.png")

local frBowButton = {
    x = 500 * scale,
    y = 500 * scale,
    width = bowIconNormal:getWidth() * scale,
    height = bowIconNormal:getHeight() * scale
}
local frCrossbowButton = {
    x = 500 + 30 * scale,
    y = 500 * scale,
    width = crossbowIconNormal:getWidth() * scale,
    height = crossbowIconNormal:getHeight() * scale
}

local crossbowIconButton = loveframes.Create("image")
local bowIconButton = loveframes.Create("image")
bowIconButton.visible = false
bowIconButton:SetState(states.STATE_INGAME_CONSTRUCTION)
bowIconButton:SetImage(bowIconNormal)
bowIconButton:SetScaleX(frBowButton.width / bowIconButton:GetImageWidth())
bowIconButton:SetScaleY(bowIconButton:GetScaleX())
bowIconButton:SetPos(frBowButton.x, frBowButton.y)
bowIconButton.OnMouseEnter = function(self)
    self:SetImage(bowIconHover)
end

bowIconButton.OnMouseDown = function(self)
    self:SetImage(bowIconHover)
end

bowIconButton.OnMouseExit = function(self)
    self:SetImage(bowIconNormal)
end

crossbowIconButton.visible = false
crossbowIconButton:SetState(states.STATE_INGAME_CONSTRUCTION)
crossbowIconButton:SetImage(crossbowIconNormal)
crossbowIconButton:SetScaleX(frCrossbowButton.width / crossbowIconButton:GetImageWidth())
crossbowIconButton:SetScaleY(crossbowIconButton:GetScaleX())
crossbowIconButton:SetPos(frCrossbowButton.x, frCrossbowButton.y)
crossbowIconButton.OnMouseEnter = function(self)
    self:SetImage(crossbowIconHover)
end

crossbowIconButton.OnMouseDown = function(self)
    self:SetImage(crossbowIconHover)
end

crossbowIconButton.OnMouseExit = function(self)
    self:SetImage(crossbowIconNormal)
end

return { crossbowIconButton, bowIconButton }
