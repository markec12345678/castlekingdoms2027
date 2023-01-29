local loveframes = require("libraries.loveframes")
local states = require("states.ui.states")
local framesActionBar = require("states.ui.action_bar_frames")
local actionBar = require("states.ui.ActionBar")
local scale = actionBar.element.scalex
local WEAPON = require("objects.Enums.Weapon")

local group = {}

local switchTradeGroup = unpack(require("states.ui.market.market_trade"))
local ActionBarButton = require("states.ui.ActionBarButton")
local backButton = ActionBarButton:new(love.graphics.newImage("assets/ui/back_ab.png"), states.STATE_ARMOURY, 12)
backButton:setOnClick(function(self)
    actionBar:switchMode()
end)
actionBar:registerGroup("armoury", { backButton })

local bowIconNormal = love.graphics.newImage("assets/ui/armoury/bowIconNormal.png")
local bowIconHover = love.graphics.newImage("assets/ui/armoury/bowIconHover.png")
local spearIconNormal = love.graphics.newImage("assets/ui/armoury/spearIconNormal.png")
local spearIconHover = love.graphics.newImage("assets/ui/armoury/spearIconHover.png")
local crossbowIconNormal = love.graphics.newImage("assets/ui/armoury/crossbowIconNormal.png")
local crossbowIconHover = love.graphics.newImage("assets/ui/armoury/crossbowIconHover.png")
local pikeIconNormal = love.graphics.newImage("assets/ui/armoury/pikeIconNormal.png")
local pikeIconHover = love.graphics.newImage("assets/ui/armoury/pikeIconHover.png")
local swordIconNormal = love.graphics.newImage("assets/ui/armoury/swordIconNormal.png")
local swordIconHover = love.graphics.newImage("assets/ui/armoury/swordIconHover.png")
local maceIconNormal = love.graphics.newImage("assets/ui/armoury/maceIconNormal.png")
local maceIconHover = love.graphics.newImage("assets/ui/armoury/maceIconHover.png")
local leatherIconNormal = love.graphics.newImage("assets/ui/armoury/leatherIconNormal.png")
local leatherIconHover = love.graphics.newImage("assets/ui/armoury/leatherIconHover.png")
local armorIconNormal = love.graphics.newImage("assets/ui/armoury/armorIconNormal.png")
local armorIconHover = love.graphics.newImage("assets/ui/armoury/armorIconHover.png")

local frBowButton = {
    x = framesActionBar.frFull.x + 335 * scale,
    y = framesActionBar.frFull.y + 118 * scale,
    width = bowIconNormal:getWidth() * scale,
    height = bowIconNormal:getHeight() * scale
}
local frSpearButton = {
    x = framesActionBar.frFull.x + 405 * scale,
    y = framesActionBar.frFull.y + 118 * scale,
    width = spearIconNormal:getWidth() * scale,
    height = spearIconNormal:getHeight() * scale
}
local frMaceButton = {
    x = framesActionBar.frFull.x + 475 * scale,
    y = framesActionBar.frFull.y + 118 * scale,
    width = maceIconNormal:getWidth() * scale,
    height = maceIconNormal:getHeight() * scale
}
local frCrossbowButton = {
    x = framesActionBar.frFull.x + 545 * scale,
    y = framesActionBar.frFull.y + 118 * scale,
    width = crossbowIconNormal:getWidth() * scale,
    height = crossbowIconNormal:getHeight() * scale
}
local frPikeButton = {
    x = framesActionBar.frFull.x + 615 * scale,
    y = framesActionBar.frFull.y + 118 * scale,
    width = pikeIconNormal:getWidth() * scale,
    height = pikeIconNormal:getHeight() * scale
}
local frSwordButton = {
    x = framesActionBar.frFull.x + 685 * scale,
    y = framesActionBar.frFull.y + 118 * scale,
    width = swordIconNormal:getWidth() * scale,
    height = swordIconNormal:getHeight() * scale
}
local frLetherButton = {
    x = framesActionBar.frFull.x + 755 * scale,
    y = framesActionBar.frFull.y + 118 * scale,
    width = leatherIconNormal:getWidth() * scale,
    height = leatherIconNormal:getHeight() * scale
}
local frArmourButton = {
    x = framesActionBar.frFull.x + 825 * scale,
    y = framesActionBar.frFull.y + 118 * scale,
    width = armorIconNormal:getWidth() * scale,
    height = armorIconNormal:getHeight() * scale
}


local currentStockBow = loveframes.Create("text")
currentStockBow:SetState(states.STATE_ARMOURY)
currentStockBow:SetFont(loveframes.font_times_new_normal_large)
currentStockBow:SetPos(frBowButton.x + (frBowButton.width / 2), frBowButton.y + 48)
currentStockBow:SetShadow(false)

local currentStockSpear = loveframes.Create("text")
currentStockSpear:SetState(states.STATE_ARMOURY)
currentStockSpear:SetFont(loveframes.font_times_new_normal_large)
currentStockSpear:SetPos(frSpearButton.x + (frSpearButton.width / 2), frSpearButton.y + 48)
currentStockSpear:SetShadow(false)

local currentStockMace = loveframes.Create("text")
currentStockMace:SetState(states.STATE_ARMOURY)
currentStockMace:SetFont(loveframes.font_times_new_normal_large)
currentStockMace:SetPos(frMaceButton.x + (frMaceButton.width / 2), frMaceButton.y + 48)
currentStockMace:SetShadow(false)

local currentStockCrossbow = loveframes.Create("text")
currentStockCrossbow:SetState(states.STATE_ARMOURY)
currentStockCrossbow:SetFont(loveframes.font_times_new_normal_large)
currentStockCrossbow:SetPos(frCrossbowButton.x + (frCrossbowButton.width / 2), frCrossbowButton.y + 48)
currentStockCrossbow:SetShadow(false)

local currentStockPike = loveframes.Create("text")
currentStockPike:SetState(states.STATE_ARMOURY)
currentStockPike:SetFont(loveframes.font_times_new_normal_large)
currentStockPike:SetPos(frPikeButton.x + (frPikeButton.width / 2), frPikeButton.y + 48)
currentStockPike:SetShadow(false)

local currentStockSword = loveframes.Create("text")
currentStockSword:SetState(states.STATE_ARMOURY)
currentStockSword:SetFont(loveframes.font_times_new_normal_large)
currentStockSword:SetPos(frSwordButton.x + (frSwordButton.width / 2), frSwordButton.y + 48)
currentStockSword:SetShadow(false)

local currentStockLeather = loveframes.Create("text")
currentStockLeather:SetState(states.STATE_ARMOURY)
currentStockLeather:SetFont(loveframes.font_times_new_normal_large)
currentStockLeather:SetPos(frLetherButton.x + (frLetherButton.width / 2), frLetherButton.y + 48)
currentStockLeather:SetShadow(false)

local currentStockArmor = loveframes.Create("text")
currentStockArmor:SetState(states.STATE_ARMOURY)
currentStockArmor:SetFont(loveframes.font_times_new_normal_large)
currentStockArmor:SetPos(frArmourButton.x + (frArmourButton.width / 2), frArmourButton.y + 48)
currentStockArmor:SetText({ {
    color = { 0, 0, 0, 1 }
}, "0" }) -- TODO ARMOUR DOESNT EXIST
currentStockArmor:SetShadow(false)
local noMarketInfo = loveframes.Create("text")
noMarketInfo:SetState(states.STATE_ARMOURY)
noMarketInfo:SetFont(loveframes.font_times_new_normal_large)
noMarketInfo:SetSize(50, 20)
noMarketInfo:SetVisible(false)
noMarketInfo:SetPos(frBowButton.x - 100 + (frBowButton.width / 2), frBowButton.y)
noMarketInfo:SetText({ {
    color = { 0, 0, 0, 1 }
}, "Build a market to trade!" })
noMarketInfo:SetShadow(false)
function SwitchToTheMarket()
    if _G.BuildingManager:count("Market") >= 1 then
        actionBar:switchMode("market_trade")
        switchTradeGroup(3)
        group.name = 3
        noMarketInfo:SetVisible(false)
    else
        noMarketInfo:SetVisible(true)
    end
end

function group.DisplayCurrentStock()

    currentStockLeather:SetText({ {
        color = { 0, 0, 0, 1 }
    }, _G.state.weapons[WEAPON.leatherArmor] })
    currentStockSword:SetText({ {
        color = { 0, 0, 0, 1 }
    }, _G.state.weapons[WEAPON.sword] })
    currentStockPike:SetText({ {
        color = { 0, 0, 0, 1 }
    }, _G.state.weapons[WEAPON.pike] })
    currentStockCrossbow:SetText({ {
        color = { 0, 0, 0, 1 }
    }, _G.state.weapons[WEAPON.crossbow] })
    currentStockMace:SetText({ {
        color = { 0, 0, 0, 1 }
    }, _G.state.weapons[WEAPON.mace] })
    currentStockSpear:SetText({ {
        color = { 0, 0, 0, 1 }
    }, _G.state.weapons[WEAPON.spear] })
    currentStockBow:SetText({ {
        color = { 0, 0, 0, 1 }
    }, _G.state.weapons[WEAPON.bow] })

end

local bowIconButton = loveframes.Create("image")
bowIconButton:SetState(states.STATE_ARMOURY)
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
bowIconButton.OnClick = function(self)
    group.good = WEAPON.bow
    SwitchToTheMarket()
end
bowIconButton.OnMouseExit = function(self)
    self:SetImage(bowIconNormal)
end

local crossbowIconButton = loveframes.Create("image")
crossbowIconButton:SetState(states.STATE_ARMOURY)
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
crossbowIconButton.OnClick = function(self)
    group.good = WEAPON.crossbow
    SwitchToTheMarket()
end
crossbowIconButton.OnMouseExit = function(self)
    self:SetImage(crossbowIconNormal)
end
-- SPEAR ICON BUTTON
local spearIconButton = loveframes.Create("image")
spearIconButton:SetState(states.STATE_ARMOURY)
spearIconButton:SetImage(spearIconNormal)
spearIconButton:SetScaleX(frSpearButton.width / spearIconButton:GetImageWidth())
spearIconButton:SetScaleY(spearIconButton:GetScaleX())
spearIconButton:SetPos(frSpearButton.x, frSpearButton.y)
spearIconButton.OnMouseEnter = function(self)
    self:SetImage(spearIconHover)
end
spearIconButton.OnMouseDown = function(self)
    self:SetImage(spearIconHover)
end
spearIconButton.OnClick = function(self)
    group.good = WEAPON.spear
    SwitchToTheMarket()
end
spearIconButton.OnMouseExit = function(self)
    self:SetImage(spearIconNormal)
end
-- MACE ICON BUTTON
local maceIconButton = loveframes.Create("image")
maceIconButton:SetState(states.STATE_ARMOURY)
maceIconButton:SetImage(maceIconNormal)
maceIconButton:SetScaleX(frMaceButton.width / maceIconButton:GetImageWidth())
maceIconButton:SetScaleY(maceIconButton:GetScaleX())
maceIconButton:SetPos(frMaceButton.x, frMaceButton.y)
maceIconButton.OnMouseEnter = function(self)
    self:SetImage(maceIconHover)
end
maceIconButton.OnMouseDown = function(self)
    self:SetImage(maceIconHover)
end
maceIconButton.OnClick = function(self)
    group.good = WEAPON.mace
    SwitchToTheMarket()
end
maceIconButton.OnMouseExit = function(self)
    self:SetImage(maceIconNormal)
end
-- SWORD ICON BUTTON
local swordIconButton = loveframes.Create("image")
swordIconButton:SetState(states.STATE_ARMOURY)
swordIconButton:SetImage(swordIconNormal)
swordIconButton:SetScaleX(frSwordButton.width / swordIconButton:GetImageWidth())
swordIconButton:SetScaleY(swordIconButton:GetScaleX())
swordIconButton:SetPos(frSwordButton.x, frSwordButton.y)
swordIconButton.OnMouseEnter = function(self)
    self:SetImage(swordIconHover)
end
swordIconButton.OnMouseDown = function(self)
    self:SetImage(swordIconHover)
end
swordIconButton.OnClick = function(self)
    group.good = WEAPON.sword
    SwitchToTheMarket()
end
swordIconButton.OnMouseExit = function(self)
    self:SetImage(swordIconNormal)
end
-- PIKE ICON BUTTON
local pikeIconButton = loveframes.Create("image")
pikeIconButton:SetState(states.STATE_ARMOURY)
pikeIconButton:SetImage(pikeIconNormal)
pikeIconButton:SetScaleX(frPikeButton.width / pikeIconButton:GetImageWidth())
pikeIconButton:SetScaleY(pikeIconButton:GetScaleX())
pikeIconButton:SetPos(frPikeButton.x, frPikeButton.y)
pikeIconButton.OnMouseEnter = function(self)
    self:SetImage(pikeIconHover)
end
pikeIconButton.OnMouseDown = function(self)
    self:SetImage(pikeIconHover)
end
pikeIconButton.OnClick = function(self)
    group.good = WEAPON.pike
    SwitchToTheMarket()
end
pikeIconButton.OnMouseExit = function(self)
    self:SetImage(pikeIconNormal)
end
-- LETHER ICON BUTTON
local leatherIconButton = loveframes.Create("image")
leatherIconButton:SetState(states.STATE_ARMOURY)
leatherIconButton:SetImage(leatherIconNormal)
leatherIconButton:SetScaleX(frLetherButton.width / leatherIconButton:GetImageWidth())
leatherIconButton:SetScaleY(leatherIconButton:GetScaleX())
leatherIconButton:SetPos(frLetherButton.x, frLetherButton.y)
leatherIconButton.OnMouseEnter = function(self)
    self:SetImage(leatherIconHover)
end
leatherIconButton.OnMouseDown = function(self)
    self:SetImage(leatherIconHover)
end
leatherIconButton.OnClick = function(self)
    group.good = WEAPON.leatherArmor
    SwitchToTheMarket()
end
leatherIconButton.OnMouseExit = function(self)
    self:SetImage(leatherIconNormal)
end
-- ARMOUR ICON BUTTON
local armourIconButton = loveframes.Create("image")
armourIconButton:SetState(states.STATE_ARMOURY)
armourIconButton:SetImage(armorIconNormal)
armourIconButton:SetScaleX(frArmourButton.width / armourIconButton:GetImageWidth())
armourIconButton:SetScaleY(armourIconButton:GetScaleX())
armourIconButton:SetPos(frArmourButton.x, frArmourButton.y)
armourIconButton.OnMouseEnter = function(self)
    self:SetImage(armorIconHover)
end
armourIconButton.OnMouseDown = function(self)
    self:SetImage(armorIconHover)
end
armourIconButton.OnClick = function(self)
    group.good = WEAPON.shield
    SwitchToTheMarket()
end
armourIconButton.OnMouseExit = function(self)
    self:SetImage(armorIconNormal)
end

return group
