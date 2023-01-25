local loveframes = require("libraries.loveframes")
local actionBar = require("states.ui.ActionBar")
local states = require("states.ui.states")
local scale = actionBar.element.scalex
local bowIconNormal = love.graphics.newImage("assets/ui/workshops/bowIconNormal.png")
local bowIconHover = love.graphics.newImage("assets/ui/workshops/bowIconHover.png")
local crossbowIconNormal = love.graphics.newImage("assets/ui/workshops/crossbowIconNormal.png")
local crossbowIconHover = love.graphics.newImage("assets/ui/workshops/crossbowIconHover.png")

local spearIconNormal = love.graphics.newImage("assets/ui/workshops/spearIconNormal.png")
local spearIconHover = love.graphics.newImage("assets/ui/workshops/spearIconHover.png")
local pikeIconNormal = love.graphics.newImage("assets/ui/workshops/pikeIconNormal.png")
local pikeIconHover = love.graphics.newImage("assets/ui/workshops/pikeIconHover.png")

local swordIconNormal = love.graphics.newImage("assets/ui/workshops/swordIconNormal.png")
local swordIconHover = love.graphics.newImage("assets/ui/workshops/swordIconHover.png")
local maceIconNormal = love.graphics.newImage("assets/ui/workshops/maceIconNormal.png")
local maceIconHover = love.graphics.newImage("assets/ui/workshops/maceIconHover.png")

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
local swordIconButton = loveframes.Create("image")
local maceIconButton = loveframes.Create("image")
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

local pikeIconButton = loveframes.Create("image")
local spearIconButton = loveframes.Create("image")
spearIconButton.visible = false
spearIconButton:SetState(states.STATE_INGAME_CONSTRUCTION)
spearIconButton:SetImage(spearIconNormal)
spearIconButton:SetScaleX(frBowButton.width / bowIconButton:GetImageWidth())
spearIconButton:SetScaleY(spearIconButton:GetScaleX())
spearIconButton:SetPos(frBowButton.x, frBowButton.y)
spearIconButton.OnMouseEnter = function(self)
    self:SetImage(spearIconHover)
end

spearIconButton.OnMouseDown = function(self)
    self:SetImage(spearIconHover)
end

spearIconButton.OnMouseExit = function(self)
    self:SetImage(spearIconNormal)
end

pikeIconButton.visible = false
pikeIconButton:SetState(states.STATE_INGAME_CONSTRUCTION)
pikeIconButton:SetImage(pikeIconNormal)
pikeIconButton:SetScaleX(frCrossbowButton.width / crossbowIconButton:GetImageWidth())
pikeIconButton:SetScaleY(pikeIconButton:GetScaleX())
pikeIconButton:SetPos(frCrossbowButton.x, frCrossbowButton.y)
pikeIconButton.OnMouseEnter = function(self)
    self:SetImage(pikeIconHover)
end

pikeIconButton.OnMouseDown = function(self)
    self:SetImage(pikeIconHover)
end

pikeIconButton.OnMouseExit = function(self)
    self:SetImage(pikeIconNormal)
end
swordIconButton.visible = false
swordIconButton:SetState(states.STATE_INGAME_CONSTRUCTION)
swordIconButton:SetImage(swordIconNormal)
swordIconButton:SetScaleX(frBowButton.width / swordIconButton:GetImageWidth())
swordIconButton:SetScaleY(swordIconButton:GetScaleX())
swordIconButton:SetPos(frBowButton.x, frBowButton.y)
swordIconButton.OnMouseEnter = function(self)
    self:SetImage(swordIconHover)
end

swordIconButton.OnMouseDown = function(self)
    self:SetImage(swordIconHover)
end

swordIconButton.OnMouseExit = function(self)
    self:SetImage(swordIconNormal)
end
maceIconButton.visible = false
maceIconButton:SetState(states.STATE_INGAME_CONSTRUCTION)
maceIconButton:SetImage(maceIconNormal)
maceIconButton:SetScaleX(frCrossbowButton.width / maceIconButton:GetImageWidth())
maceIconButton:SetScaleY(maceIconButton:GetScaleX())
maceIconButton:SetPos(frCrossbowButton.x, frCrossbowButton.y)
maceIconButton.OnMouseEnter = function(self)
    self:SetImage(maceIconHover)
end
maceIconButton.OnMouseDown = function(self)
    self:SetImage(maceIconHover)
end
maceIconButton.OnMouseExit = function(self)
    self:SetImage(maceIconNormal)
end

return { crossbowIconButton, bowIconButton, pikeIconButton, spearIconButton, swordIconButton, maceIconButton }
