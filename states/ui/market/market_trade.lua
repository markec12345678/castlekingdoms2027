local loveframes = require("libraries.loveframes")
local states = require("states.ui.states")
local framesActionBar = require("states.ui.action_bar_frames")
local actionBar = require("states.ui.ActionBar")
local scale = actionBar.element.scalex
local groupTypeMarket = require("states.ui.market.market_trade_main")
local ActionBarButton = require("states.ui.ActionBarButton")
local backButtonImage = love.graphics.newImage("assets/ui/goods/back_ab_market.png")
local backButtonHover = love.graphics.newImage("assets/ui/goods/back_ab_market_hover.png")
local backButtonA = ActionBarButton:new(love.graphics.newImage("assets/ui/goods/emptyIcon.png"), states.STATE_MARKET, 12)
local backButton = loveframes.Create("image")
local FOOD = require("objects.Enums.Food")
local WEAPON = require("objects.Enums.Weapon")

local good
local quantity = 5
local price = 5
local dynamicBuyTooltip = ""
local dynamicSellTooltip = ""

backButton.OnClick = function(self)
    actionBar:switchMode("market")
    good = nil
end

--QUICK TAB ICONS
local materialButtonImage = love.graphics.newImage("assets/ui/goods/hammer_button_normal.png")
local materialButtonHoverImage = love.graphics.newImage("assets/ui/goods/hammer_button_hover.png")
local materialButtonClickedImage = love.graphics.newImage("assets/ui/goods/hammer_button_clicked.png")
local foodButtonImage = love.graphics.newImage("assets/ui/goods/apple_button_normal.png")
local foodButtonHoverImage = love.graphics.newImage("assets/ui/goods/apple_button_hover.png")
local foodButtonClickedImage = love.graphics.newImage("assets/ui/goods/apple_button_clicked.png")
local weaponButtonImage = love.graphics.newImage("assets/ui/goods/shield_button_normal.png")
local weaponButtonHoverImage = love.graphics.newImage("assets/ui/goods/shield_button_hover.png")
local weaponButtonClickedImage = love.graphics.newImage("assets/ui/goods/shield_button_clicked.png")
--AUTO TRADE ICONS
local autoTradeOnImage = love.graphics.newImage("assets/ui/goods/auto_button_clicked.png")
local autoTradeOffImage = love.graphics.newImage("assets/ui/goods/auto_button_normal.png")
local autoTradeDeleteOnImage = love.graphics.newImage("assets/ui/goods/delete_button_clicked.png")
local autoTradeDeleteOffImage = love.graphics.newImage("assets/ui/goods/delete_button_normal.png")

local marketBuyButtonImage = love.graphics.newImage("assets/ui/market_Buy_Button.png")
local marketBuyButtonHoverImage = love.graphics.newImage("assets/ui/market_Buy_Button_Hover.png")
local marketSellButtonImage = love.graphics.newImage("assets/ui/market_Sell_Button.png")
local marketSellButtonHoverImage = love.graphics.newImage("assets/ui/market_Sell_Button_Hover.png")

local IncButtonImage = love.graphics.newImage("assets/ui/goods/tradeIncButton.png")
local DecButtonImage = love.graphics.newImage("assets/ui/goods/tradeDecButton.png")
local IncButtonImageHover = love.graphics.newImage("assets/ui/goods/tradeIncButtonHover.png")
local DecButtonImageHover = love.graphics.newImage("assets/ui/goods/tradeDecButtonHover.png")

-- GOODS ICONS
local woodIcon = love.graphics.newImage("assets/ui/goods/woodIcon.png")
local hopIcon = love.graphics.newImage("assets/ui/goods/hopIcon.png")
local stoneIcon = love.graphics.newImage("assets/ui/goods/stoneIcon.png")
local ironIcon = love.graphics.newImage("assets/ui/goods/ironIcon.png")
local tarIcon = love.graphics.newImage("assets/ui/goods/tarIcon.png")
local aleIcon = love.graphics.newImage("assets/ui/goods/aleIcon.png")
local wheatIcon = love.graphics.newImage("assets/ui/goods/wheatIcon.png")
local flourIcon = love.graphics.newImage("assets/ui/goods/flourIcon.png")
-- FOOD ICONS
local meatIcon = love.graphics.newImage("assets/ui/goods/meatIcon.png")
local cheeseIcon = love.graphics.newImage("assets/ui/goods/cheeseIcon.png")
local appleIcon = love.graphics.newImage("assets/ui/goods/appleIcon.png")
local breadIcon = love.graphics.newImage("assets/ui/goods/breadIcon.png")
-- BIG ICONS
local woodIconBig = love.graphics.newImage("assets/ui/goods/woodIconBig.png")
local stoneIconBig = love.graphics.newImage("assets/ui/goods/stoneIconBig.png")
local wheatIconBig = love.graphics.newImage("assets/ui/goods/wheatIconBig.png")
local tarIconBig = love.graphics.newImage("assets/ui/goods/tarIconBig.png")
local aleIconBig = love.graphics.newImage("assets/ui/goods/aleIconBig.png")
local ironIconBig = love.graphics.newImage("assets/ui/goods/ironIconBig.png")
local hopIconBig = love.graphics.newImage("assets/ui/goods/hopIconBig.png")
local flourIconBig = love.graphics.newImage("assets/ui/goods/flourIconBig.png")
-- FOOD ICONS
local meatIconBig = love.graphics.newImage("assets/ui/goods/meatIconBig.png")
local cheeseIconBig = love.graphics.newImage("assets/ui/goods/cheeseIconBig.png")
local appleIconBig = love.graphics.newImage("assets/ui/goods/appleIconBig.png")
local breadIconBig = love.graphics.newImage("assets/ui/goods/breadIconBig.png")
-- WEAPON ICONS
local bowIcon = love.graphics.newImage("assets/ui/goods/bowIcon.png")
local bowIconBig = love.graphics.newImage("assets/ui/goods/bowIconBig.png")
local spearIcon = love.graphics.newImage("assets/ui/goods/spearIcon.png")
local spearIconBig = love.graphics.newImage("assets/ui/goods/spearIconBig.png")
local crossbowIcon = love.graphics.newImage("assets/ui/goods/crossbowIcon.png")
local crossbowIconBig = love.graphics.newImage("assets/ui/goods/crossbowIconBig.png")
local pikeIcon = love.graphics.newImage("assets/ui/goods/pikeIcon.png")
local pikeIconBig = love.graphics.newImage("assets/ui/goods/pikeIconBig.png")
local swordIcon = love.graphics.newImage("assets/ui/goods/swordIcon.png")
local swordIconBig = love.graphics.newImage("assets/ui/goods/swordIconBig.png")
local maceIcon = love.graphics.newImage("assets/ui/goods/maceIcon.png")
local maceIconBig = love.graphics.newImage("assets/ui/goods/maceIconBig.png")
local leatherIcon = love.graphics.newImage("assets/ui/goods/leatherIcon.png")
local leatherIconBig = love.graphics.newImage("assets/ui/goods/leatherIconBig.png")
local armorIcon = love.graphics.newImage("assets/ui/goods/armorIcon.png")
local armorIconBig = love.graphics.newImage("assets/ui/goods/armorIconBig.png")

local emptyIconBig = love.graphics.newImage("assets/ui/goods/emptyIconBig.png")

local frBigButton = {
    x = framesActionBar.frFull.x + 568 * scale,
    y = framesActionBar.frFull.y + 110 * scale,
    width = woodIconBig:getWidth() * scale,
    height = woodIconBig:getHeight() * scale
}
-- FR RESOURCE BUTTONS
local frWoodButton = {
    x = framesActionBar.frFull.x + 140 * scale,
    y = framesActionBar.frFull.y + 120 * scale,
    width = woodIcon:getWidth() * scale,
    height = woodIcon:getHeight() * scale
}
local frStoneButton = {
    x = framesActionBar.frFull.x + 190 * scale,
    y = framesActionBar.frFull.y + 120 * scale,
    width = stoneIcon:getWidth() * scale,
    height = stoneIcon:getHeight() * scale
}
local frWheatButton = {
    x = framesActionBar.frFull.x + 250 * scale,
    y = framesActionBar.frFull.y + 115 * scale,
    width = wheatIcon:getWidth() * scale,
    height = wheatIcon:getHeight() * scale
}
local frTarButton = {
    x = framesActionBar.frFull.x + 290 * scale,
    y = framesActionBar.frFull.y + 115 * scale,
    width = tarIcon:getWidth() * scale,
    height = tarIcon:getHeight() * scale
}
local frAleButton = {
    x = framesActionBar.frFull.x + 340 * scale,
    y = framesActionBar.frFull.y + 120 * scale,
    width = aleIcon:getWidth() * scale,
    height = aleIcon:getHeight() * scale
}
local frIronButton = {
    x = framesActionBar.frFull.x + 390 * scale,
    y = framesActionBar.frFull.y + 120 * scale,
    width = ironIcon:getWidth() * scale,
    height = ironIcon:getHeight() * scale
}
local frHopButton = {
    x = framesActionBar.frFull.x + 450 * scale,
    y = framesActionBar.frFull.y + 115 * scale,
    width = hopIcon:getWidth() * scale,
    height = hopIcon:getHeight() * scale
}
local frFlourButton = {
    x = framesActionBar.frFull.x + 510 * scale,
    y = framesActionBar.frFull.y + 115 * scale,
    width = flourIcon:getWidth() * scale,
    height = flourIcon:getHeight() * scale
}
-- FOOD ICONS
local frMeatButton = {
    x = framesActionBar.frFull.x + 140 * scale,
    y = framesActionBar.frFull.y + 120 * scale,
    width = meatIcon:getWidth() * scale,
    height = meatIcon:getHeight() * scale
}
local frCheeseButton = {
    x = framesActionBar.frFull.x + 190 * scale,
    y = framesActionBar.frFull.y + 120 * scale,
    width = cheeseIcon:getWidth() * scale,
    height = cheeseIcon:getHeight() * scale
}
local frAppleButton = {
    x = framesActionBar.frFull.x + 250 * scale,
    y = framesActionBar.frFull.y + 115 * scale,
    width = appleIcon:getWidth() * scale,
    height = appleIcon:getHeight() * scale
}
local frBreadButton = {
    x = framesActionBar.frFull.x + 290 * scale,
    y = framesActionBar.frFull.y + 115 * scale,
    width = breadIcon:getWidth() * scale,
    height = breadIcon:getHeight() * scale
}
-- WEAPON ICONS
local frBowButton = {
    x = framesActionBar.frFull.x + 140 * scale,
    y = framesActionBar.frFull.y + 120 * scale,
    width = bowIcon:getWidth() * scale,
    height = bowIcon:getHeight() * scale
}
local frSpearButton = {
    x = framesActionBar.frFull.x + 190 * scale,
    y = framesActionBar.frFull.y + 120 * scale,
    width = spearIcon:getWidth() * scale,
    height = spearIcon:getHeight() * scale
}
local frMaceButton = {
    x = framesActionBar.frFull.x + 250 * scale,
    y = framesActionBar.frFull.y + 115 * scale,
    width = maceIcon:getWidth() * scale,
    height = maceIcon:getHeight() * scale
}
local frCrossbowButton = {
    x = framesActionBar.frFull.x + 290 * scale,
    y = framesActionBar.frFull.y + 115 * scale,
    width = crossbowIcon:getWidth() * scale,
    height = crossbowIcon:getHeight() * scale
}
local frPikeButton = {
    x = framesActionBar.frFull.x + 340 * scale,
    y = framesActionBar.frFull.y + 120 * scale,
    width = pikeIcon:getWidth() * scale,
    height = pikeIcon:getHeight() * scale
}
local frSwordButton = {
    x = framesActionBar.frFull.x + 390 * scale,
    y = framesActionBar.frFull.y + 120 * scale,
    width = swordIcon:getWidth() * scale,
    height = swordIcon:getHeight() * scale
}
local frLetherButton = {
    x = framesActionBar.frFull.x + 450 * scale,
    y = framesActionBar.frFull.y + 115 * scale,
    width = leatherIcon:getWidth() * scale,
    height = leatherIcon:getHeight() * scale
}
local frArmourButton = {
    x = framesActionBar.frFull.x + 510 * scale,
    y = framesActionBar.frFull.y + 115 * scale,
    width = armorIcon:getWidth() * scale,
    height = armorIcon:getHeight() * scale
}

local frBuyButton = {
    x = framesActionBar.frFull.x + 683 * scale,
    y = framesActionBar.frFull.y + 115 * scale,
    width = marketBuyButtonImage:getWidth() * scale,
    height = marketBuyButtonImage:getHeight() * scale
}
local frSellButton = {
    x = framesActionBar.frFull.x + 683 * scale,
    y = framesActionBar.frFull.y + 152 * scale,
    width = marketSellButtonImage:getWidth() * scale,
    height = marketSellButtonImage:getHeight() * scale
}
local frIncButton = {
    x = framesActionBar.frFull.x + 890 * scale,
    y = framesActionBar.frFull.y + 112 * scale,
    width = IncButtonImage:getWidth() * scale,
    height = IncButtonImage:getHeight() * scale
}
local frDecButton = {
    x = framesActionBar.frFull.x + 890 * scale,
    y = framesActionBar.frFull.y + 152 * scale,
    width = DecButtonImage:getWidth() * scale,
    height = DecButtonImage:getHeight() * scale
}
local frGold = {
    x = framesActionBar.frFull.x + 930 * scale,
    y = framesActionBar.frFull.y + 120 * scale,
    width = 50 * scale,
    height = 20 * scale
}
local frQuantity = {
    x = framesActionBar.frFull.x + 930 * scale,
    y = framesActionBar.frFull.y + 160 * scale,
    width = 50 * scale,
    height = 20 * scale
}
local frStock = {
    x = framesActionBar.frFull.x + 650 * scale,
    y = framesActionBar.frFull.y + 120 * scale,
    width = 50 * scale,
    height = 20 * scale
}
local frBackButton = {
    x = framesActionBar.frFull.x + 140 * scale,
    y = framesActionBar.frFull.y + 155 * scale,
    width = IncButtonImage:getWidth() * scale,
    height = IncButtonImage:getHeight() * scale
}
local frBackButtonA = { --HACK
    x = framesActionBar.frFull.x + 1920 * scale,
    y = framesActionBar.frFull.y + 1080 * scale,
    width = 0,
    height = 0
}
local frAutoTrade = {
    x = framesActionBar.frFull.x + 962 * scale,
    y = framesActionBar.frFull.y + 60 * scale,
    width = autoTradeOnImage:getWidth() * scale,
    height = autoTradeOnImage:getWidth() * scale
}
local frAutoTradeDelete = {
    x = framesActionBar.frFull.x + 928 * scale,
    y = framesActionBar.frFull.y + 60 * scale,
    width = autoTradeDeleteOnImage:getWidth() * scale,
    height = autoTradeDeleteOnImage:getWidth() * scale
}
local frFood = {
    x = framesActionBar.frFull.x + 124 * scale,
    y = framesActionBar.frFull.y + 60 * scale,
    width = materialButtonImage:getWidth() * scale,
    height = materialButtonImage:getWidth() * scale
}
local frMaterial = {
    x = framesActionBar.frFull.x + 160 * scale,
    y = framesActionBar.frFull.y + 60 * scale,
    width = materialButtonImage:getWidth() * scale,
    height = materialButtonImage:getWidth() * scale
}
local frWeapon = {
    x = framesActionBar.frFull.x + 198 * scale,
    y = framesActionBar.frFull.y + 60 * scale,
    width = foodButtonImage:getWidth() * scale,
    height = foodButtonImage:getWidth() * scale
}

backButtonA.background:SetPos(frBackButtonA.x, frBackButtonA.y)
backButtonA.foreground:SetPos(frBackButtonA.x, frBackButtonA.y)

backButton:SetState(states.STATE_MARKET)
backButton:SetImage(backButtonImage)
backButton:SetScaleX(frBackButton.width / backButton:GetImageWidth())
backButton:SetScaleY(backButton:GetScaleX())
backButton:SetPos(frBackButton.x, frBackButton.y)

backButton.OnMouseEnter = function(self)
    self:SetImage(backButtonHover) -- TODO HOVER BUTTON
end
backButton.OnMouseDown = function(self)
    self:SetImage(backButtonHover) -- TODO DOWN BUTTON
end
backButton.OnMouseExit = function(self)
    self:SetImage(backButtonImage)
end

local priceText = loveframes.Create("text")
priceText:SetState(states.STATE_MARKET)
priceText:SetFont(loveframes.font_times_new_normal_large)
priceText:SetPos(frGold.x, frGold.y)
priceText:SetText({ {
    color = { 0, 0, 0, 1 }
}, "5" })
priceText:SetShadow(false)

local quantityText = loveframes.Create("text")
quantityText:SetState(states.STATE_MARKET)
quantityText:SetFont(loveframes.font_times_new_normal_large)
quantityText:SetPos(frQuantity.x, frQuantity.y)
quantityText:SetText({ {
    color = { 0, 0, 0, 1 }
}, "5" })
quantityText:SetShadow(false)

local currentStock = loveframes.Create("text")
currentStock:SetState(states.STATE_MARKET)
currentStock:SetFont(loveframes.font_times_new_normal_large)
currentStock:SetPos(frStock.x, frStock.y)
currentStock:SetText({ {
    color = { 0, 0, 0, 1 }
}, "" })
currentStock:SetShadow(false)
function DisplayCurrentStock(itemGroup)
    if itemGroup == 1 then
        currentStock:SetText({ {
            color = { 0, 0, 0, 1 }
        }, _G.state.food[good] })
    end
    if itemGroup == 2 then
        currentStock:SetText({ {
            color = { 0, 0, 0, 1 }
        }, _G.state.resources[good] })
    end
    if itemGroup == 3 then
        currentStock:SetText({ {
            color = { 0, 0, 0, 1 }
        }, _G.state.weapons[good] })
    end
end

local bigIconTemplate = loveframes.Create("image")
bigIconTemplate:SetState(states.STATE_MARKET)
bigIconTemplate:SetImage(emptyIconBig)
bigIconTemplate:SetScaleX(frBigButton.width / bigIconTemplate:GetImageWidth())
bigIconTemplate:SetScaleY(bigIconTemplate:GetScaleX())
bigIconTemplate:SetPos(frBigButton.x, frBigButton.y)

-- WOOD ICON BUTTON
local woodIconButton = loveframes.Create("image")
woodIconButton:SetState(states.STATE_MARKET)
woodIconButton:SetImage(woodIcon)
woodIconButton:SetScaleX(frWoodButton.width / woodIconButton:GetImageWidth())
woodIconButton:SetScaleY(woodIconButton:GetScaleX())
woodIconButton:SetPos(frWoodButton.x, frWoodButton.y)
woodIconButton.OnMouseEnter = function(self)
    self:SetImage(woodIcon) -- TODO HOVER BUTTON
end
woodIconButton.OnMouseDown = function(self)
    self:SetImage(woodIcon) -- TODO DOWN BUTTON
end
woodIconButton.OnClick = function(self)
    -- TODO add sound
    bigIconTemplate:SetImage(woodIconBig)
    bigIconTemplate:SetPos(frBigButton.x, frBigButton.y)
    good = "wood"
    DisplayCurrentStock(2)
end

-- STONE ICON BUTTON
local stoneIconButton = loveframes.Create("image")
stoneIconButton:SetState(states.STATE_MARKET)
stoneIconButton:SetImage(stoneIcon)
stoneIconButton:SetScaleX(frStoneButton.width / stoneIconButton:GetImageWidth())
stoneIconButton:SetScaleY(stoneIconButton:GetScaleX())
stoneIconButton:SetPos(frStoneButton.x, frStoneButton.y)
stoneIconButton.OnMouseEnter = function(self)
    self:SetImage(stoneIcon) -- TODO HOVER BUTTON
end
stoneIconButton.OnMouseDown = function(self)
    self:SetImage(stoneIcon) -- TODO DOWN BUTTON
end
stoneIconButton.OnClick = function(self)
    -- TODO add sound

    bigIconTemplate:SetImage(stoneIconBig)
    bigIconTemplate:SetPos(frBigButton.x, frBigButton.y)
    good = "stone"
    DisplayCurrentStock(2)
end
woodIconButton.OnMouseExit = function(self)
    self:SetImage(woodIcon)
end

-- WHEAT ICON BUTTON
local wheatIconButton = loveframes.Create("image")
wheatIconButton:SetState(states.STATE_MARKET)
wheatIconButton:SetImage(wheatIcon)
wheatIconButton:SetScaleX(frWheatButton.width / wheatIconButton:GetImageWidth())
wheatIconButton:SetScaleY(wheatIconButton:GetScaleX())
wheatIconButton:SetPos(frWheatButton.x, frWheatButton.y)
wheatIconButton.OnMouseEnter = function(self)
    self:SetImage(wheatIcon) -- TODO HOVER BUTTON
end
wheatIconButton.OnMouseDown = function(self)
    self:SetImage(wheatIcon) -- TODO DOWN BUTTON
end
wheatIconButton.OnClick = function(self)
    -- TODO add sound

    bigIconTemplate:SetImage(wheatIconBig)
    bigIconTemplate:SetPos(frBigButton.x, frBigButton.y)
    good = "wheat"
    DisplayCurrentStock(2)
end
wheatIconButton.OnMouseExit = function(self)
    self:SetImage(wheatIcon)
end

-- TAR ICON BUTTON
local tarIconButton = loveframes.Create("image")
tarIconButton:SetState(states.STATE_MARKET)
tarIconButton:SetImage(tarIcon)
tarIconButton:SetScaleX(frTarButton.width / tarIconButton:GetImageWidth())
tarIconButton:SetScaleY(tarIconButton:GetScaleX())
tarIconButton:SetPos(frTarButton.x, frTarButton.y)
tarIconButton.OnMouseEnter = function(self)
    self:SetImage(tarIcon) -- TODO HOVER BUTTON
end
tarIconButton.OnMouseDown = function(self)
    self:SetImage(tarIcon) -- TODO DOWN BUTTON
end
tarIconButton.OnClick = function(self)
    -- TODO add sound

    bigIconTemplate:SetImage(tarIconBig)
    bigIconTemplate:SetPos(frBigButton.x, frBigButton.y)
    good = "tar"
    DisplayCurrentStock(2)
end
tarIconButton.OnMouseExit = function(self)
    self:SetImage(tarIcon)
end

-- ALE ICON BUTTON
local aleIconButton = loveframes.Create("image")
aleIconButton:SetState(states.STATE_MARKET)
aleIconButton:SetImage(aleIcon)
aleIconButton:SetScaleX(frAleButton.width / aleIconButton:GetImageWidth())
aleIconButton:SetScaleY(aleIconButton:GetScaleX())
aleIconButton:SetPos(frAleButton.x, frAleButton.y)
aleIconButton.OnMouseEnter = function(self)
    self:SetImage(aleIcon) -- TODO HOVER BUTTON
end
aleIconButton.OnMouseDown = function(self)
    self:SetImage(aleIcon) -- TODO DOWN BUTTON
end
aleIconButton.OnClick = function(self)
    -- TODO add sound

    bigIconTemplate:SetImage(aleIconBig)
    bigIconTemplate:SetPos(frBigButton.x, frBigButton.y)
    good = "ale"
    DisplayCurrentStock(2)
end
aleIconButton.OnMouseExit = function(self)
    self:SetImage(aleIcon)
end

-- IRON ICON BUTTON
local ironIconButton = loveframes.Create("image")
ironIconButton:SetState(states.STATE_MARKET)
ironIconButton:SetImage(ironIcon)
ironIconButton:SetScaleX(frIronButton.width / ironIconButton:GetImageWidth())
ironIconButton:SetScaleY(ironIconButton:GetScaleX())
ironIconButton:SetPos(frIronButton.x, frIronButton.y)
ironIconButton.OnMouseEnter = function(self)
    self:SetImage(ironIcon) -- TODO HOVER BUTTON
end
ironIconButton.OnMouseDown = function(self)
    self:SetImage(ironIcon) -- TODO DOWN BUTTON
end
ironIconButton.OnClick = function(self)
    -- TODO add sound

    bigIconTemplate:SetImage(ironIconBig)
    bigIconTemplate:SetPos(frBigButton.x, frBigButton.y)
    good = "iron"
    DisplayCurrentStock(2)
end
ironIconButton.OnMouseExit = function(self)
    self:SetImage(ironIcon)
end

-- HOP ICON BUTTON
local hopIconButton = loveframes.Create("image")
hopIconButton:SetState(states.STATE_MARKET)
hopIconButton:SetImage(hopIcon)
hopIconButton:SetScaleX(frIronButton.width / hopIconButton:GetImageWidth())
hopIconButton:SetScaleY(hopIconButton:GetScaleX())
hopIconButton:SetPos(frHopButton.x, frHopButton.y)
hopIconButton.OnMouseEnter = function(self)
    self:SetImage(hopIcon) -- TODO HOVER BUTTON
end
hopIconButton.OnMouseDown = function(self)
    self:SetImage(hopIcon) -- TODO DOWN BUTTON
end
hopIconButton.OnClick = function(self)
    -- TODO add sound

    bigIconTemplate:SetImage(hopIconBig)
    bigIconTemplate:SetPos(frBigButton.x, frBigButton.y)
    good = "hop"
    DisplayCurrentStock(2)
end
hopIconButton.OnMouseExit = function(self)
    self:SetImage(hopIcon)
end

-- FLOUR ICON BUTTON
local flourIconButton = loveframes.Create("image")
flourIconButton:SetState(states.STATE_MARKET)
flourIconButton:SetImage(flourIcon)
flourIconButton:SetScaleX(frFlourButton.width / flourIconButton:GetImageWidth())
flourIconButton:SetScaleY(flourIconButton:GetScaleX())
flourIconButton:SetPos(frFlourButton.x, frFlourButton.y)
flourIconButton.OnMouseEnter = function(self)
    self:SetImage(flourIcon) -- TODO HOVER BUTTON
end
flourIconButton.OnMouseDown = function(self)
    self:SetImage(flourIcon) -- TODO DOWN BUTTON
end
flourIconButton.OnClick = function(self)
    -- TODO add sound

    bigIconTemplate:SetImage(flourIconBig)
    bigIconTemplate:SetPos(frBigButton.x, frBigButton.y)
    good = "flour"
    DisplayCurrentStock(2)
end
flourIconButton.OnMouseExit = function(self)
    self:SetImage(flourIcon)
end

-- MEAT ICON BUTTON
local meatIconButton = loveframes.Create("image")
meatIconButton:SetState(states.STATE_MARKET)
meatIconButton:SetImage(meatIcon)
meatIconButton:SetScaleX(frMeatButton.width / meatIconButton:GetImageWidth())
meatIconButton:SetScaleY(meatIconButton:GetScaleX())
meatIconButton:SetPos(frMeatButton.x, frMeatButton.y)
meatIconButton.OnMouseEnter = function(self)
    self:SetImage(meatIcon) -- TODO HOVER BUTTON
end
meatIconButton.OnMouseDown = function(self)
    self:SetImage(meatIcon) -- TODO DOWN BUTTON
end
meatIconButton.OnClick = function(self)
    -- TODO add sound

    bigIconTemplate:SetImage(meatIconBig)
    bigIconTemplate:SetPos(frBigButton.x, frBigButton.y)

    good = FOOD.meat
    DisplayCurrentStock(1)
end
meatIconButton.OnMouseExit = function(self)
    self:SetImage(meatIcon)
end

-- CHEESE ICON BUTTON
local cheeseIconButton = loveframes.Create("image")
cheeseIconButton:SetState(states.STATE_MARKET)
cheeseIconButton:SetImage(cheeseIcon)
cheeseIconButton:SetScaleX(frCheeseButton.width / cheeseIconButton:GetImageWidth())
cheeseIconButton:SetScaleY(cheeseIconButton:GetScaleX())
cheeseIconButton:SetPos(frCheeseButton.x, frCheeseButton.y)
cheeseIconButton.OnMouseEnter = function(self)
    self:SetImage(cheeseIcon) -- TODO HOVER BUTTON
end
cheeseIconButton.OnMouseDown = function(self)
    self:SetImage(cheeseIcon) -- TODO DOWN BUTTON
end
cheeseIconButton.OnClick = function(self)
    -- TODO add sound

    bigIconTemplate:SetImage(cheeseIconBig)
    bigIconTemplate:SetPos(frBigButton.x, frBigButton.y)

    good = FOOD.cheese
    DisplayCurrentStock(1)
end
cheeseIconButton.OnMouseExit = function(self)
    self:SetImage(cheeseIcon)
end

-- APPLE ICON BUTTON
local appleIconButton = loveframes.Create("image")
appleIconButton:SetState(states.STATE_MARKET)
appleIconButton:SetImage(appleIcon)
appleIconButton:SetScaleX(frAppleButton.width / appleIconButton:GetImageWidth())
appleIconButton:SetScaleY(appleIconButton:GetScaleX())
appleIconButton:SetPos(frAppleButton.x, frAppleButton.y)
appleIconButton.OnMouseEnter = function(self)
    self:SetImage(appleIcon) -- TODO HOVER BUTTON
end
appleIconButton.OnMouseDown = function(self)
    self:SetImage(appleIcon) -- TODO DOWN BUTTON
end
appleIconButton.OnClick = function(self)
    -- TODO add sound

    bigIconTemplate:SetImage(appleIconBig)
    bigIconTemplate:SetPos(frBigButton.x, frBigButton.y)

    good = FOOD.apples
    DisplayCurrentStock(1)
end
appleIconButton.OnMouseExit = function(self)
    self:SetImage(appleIcon)
end

-- BREAD ICON BUTTON
local breadIconButton = loveframes.Create("image")
breadIconButton:SetState(states.STATE_MARKET)
breadIconButton:SetImage(breadIcon)
breadIconButton:SetScaleX(frBreadButton.width / breadIconButton:GetImageWidth())
breadIconButton:SetScaleY(breadIconButton:GetScaleX())
breadIconButton:SetPos(frBreadButton.x, frBreadButton.y)
breadIconButton.OnMouseEnter = function(self)
    self:SetImage(breadIcon) -- TODO HOVER BUTTON
end
breadIconButton.OnMouseDown = function(self)
    self:SetImage(breadIcon) -- TODO DOWN BUTTON
end
breadIconButton.OnClick = function(self)
    -- TODO add sound
    bigIconTemplate:SetImage(breadIconBig)
    bigIconTemplate:SetPos(frBigButton.x, frBigButton.y)
    good = FOOD.bread
    DisplayCurrentStock(1)
end
breadIconButton.OnMouseExit = function(self)
    self:SetImage(breadIcon)
end
-- WEAPON BUTTONS
-- BOW ICON BUTTON
local bowIconButton = loveframes.Create("image")
bowIconButton:SetState(states.STATE_MARKET)
bowIconButton:SetImage(bowIcon)
bowIconButton:SetScaleX(frBowButton.width / bowIconButton:GetImageWidth())
bowIconButton:SetScaleY(bowIconButton:GetScaleX())
bowIconButton:SetPos(frBowButton.x, frBowButton.y)
bowIconButton.OnMouseEnter = function(self)
    self:SetImage(bowIcon) -- TODO HOVER BUTTON
end
bowIconButton.OnMouseDown = function(self)
    self:SetImage(bowIcon) -- TODO DOWN BUTTON
end
bowIconButton.OnClick = function(self)
    -- TODO add sound

    bigIconTemplate:SetImage(bowIconBig)
    bigIconTemplate:SetPos(frBigButton.x, frBigButton.y)

    good = WEAPON.bow
    DisplayCurrentStock(3)
end
bowIconButton.OnMouseExit = function(self)
    self:SetImage(bowIcon)
end
-- CROSSBOW ICON BUTTON
local crossbowIconButton = loveframes.Create("image")
crossbowIconButton:SetState(states.STATE_MARKET)
crossbowIconButton:SetImage(crossbowIcon)
crossbowIconButton:SetScaleX(frCrossbowButton.width / crossbowIconButton:GetImageWidth())
crossbowIconButton:SetScaleY(crossbowIconButton:GetScaleX())
crossbowIconButton:SetPos(frCrossbowButton.x, frCrossbowButton.y)
crossbowIconButton.OnMouseEnter = function(self)
    self:SetImage(crossbowIcon) -- TODO HOVER BUTTON
end
crossbowIconButton.OnMouseDown = function(self)
    self:SetImage(crossbowIcon) -- TODO DOWN BUTTON
end
crossbowIconButton.OnClick = function(self)
    -- TODO add sound

    bigIconTemplate:SetImage(crossbowIconBig)
    bigIconTemplate:SetPos(frBigButton.x, frBigButton.y)

    good = WEAPON.crossbow
    DisplayCurrentStock(3)
end
crossbowIconButton.OnMouseExit = function(self)
    self:SetImage(crossbowIcon)
end
-- SPEAR ICON BUTTON
local spearIconButton = loveframes.Create("image")
spearIconButton:SetState(states.STATE_MARKET)
spearIconButton:SetImage(spearIcon)
spearIconButton:SetScaleX(frSpearButton.width / spearIconButton:GetImageWidth())
spearIconButton:SetScaleY(spearIconButton:GetScaleX())
spearIconButton:SetPos(frSpearButton.x, frSpearButton.y)
spearIconButton.OnMouseEnter = function(self)
    self:SetImage(spearIcon) -- TODO HOVER BUTTON
end
spearIconButton.OnMouseDown = function(self)
    self:SetImage(spearIcon) -- TODO DOWN BUTTON
end
spearIconButton.OnClick = function(self)
    -- TODO add sound

    bigIconTemplate:SetImage(spearIconBig)
    bigIconTemplate:SetPos(frBigButton.x, frBigButton.y)

    good = WEAPON.spear
    DisplayCurrentStock(3)
end
spearIconButton.OnMouseExit = function(self)
    self:SetImage(spearIcon)
end
-- MACE ICON BUTTON
local maceIconButton = loveframes.Create("image")
maceIconButton:SetState(states.STATE_MARKET)
maceIconButton:SetImage(maceIcon)
maceIconButton:SetScaleX(frMaceButton.width / maceIconButton:GetImageWidth())
maceIconButton:SetScaleY(maceIconButton:GetScaleX())
maceIconButton:SetPos(frMaceButton.x, frMaceButton.y)
maceIconButton.OnMouseEnter = function(self)
    self:SetImage(maceIcon) -- TODO HOVER BUTTON
end
maceIconButton.OnMouseDown = function(self)
    self:SetImage(maceIcon) -- TODO DOWN BUTTON
end
maceIconButton.OnClick = function(self)
    -- TODO add sound

    bigIconTemplate:SetImage(maceIconBig)
    bigIconTemplate:SetPos(frBigButton.x, frBigButton.y)

    good = WEAPON.mace
    DisplayCurrentStock(3)
end
maceIconButton.OnMouseExit = function(self)
    self:SetImage(maceIcon)
end
-- SWORD ICON BUTTON
local swordIconButton = loveframes.Create("image")
swordIconButton:SetState(states.STATE_MARKET)
swordIconButton:SetImage(swordIcon)
swordIconButton:SetScaleX(frSwordButton.width / swordIconButton:GetImageWidth())
swordIconButton:SetScaleY(swordIconButton:GetScaleX())
swordIconButton:SetPos(frSwordButton.x, frSwordButton.y)
swordIconButton.OnMouseEnter = function(self)
    self:SetImage(swordIcon) -- TODO HOVER BUTTON
end
swordIconButton.OnMouseDown = function(self)
    self:SetImage(swordIcon) -- TODO DOWN BUTTON
end
swordIconButton.OnClick = function(self)
    -- TODO add sound

    bigIconTemplate:SetImage(swordIconBig)
    bigIconTemplate:SetPos(frBigButton.x, frBigButton.y)

    good = WEAPON.sword
    DisplayCurrentStock(3)
end
swordIconButton.OnMouseExit = function(self)
    self:SetImage(swordIcon)
end
-- PIKE ICON BUTTON
local pikeIconButton = loveframes.Create("image")
pikeIconButton:SetState(states.STATE_MARKET)
pikeIconButton:SetImage(pikeIcon)
pikeIconButton:SetScaleX(frPikeButton.width / pikeIconButton:GetImageWidth())
pikeIconButton:SetScaleY(pikeIconButton:GetScaleX())
pikeIconButton:SetPos(frPikeButton.x, frPikeButton.y)
pikeIconButton.OnMouseEnter = function(self)
    self:SetImage(pikeIcon) -- TODO HOVER BUTTON
end
pikeIconButton.OnMouseDown = function(self)
    self:SetImage(pikeIcon) -- TODO DOWN BUTTON
end
pikeIconButton.OnClick = function(self)
    -- TODO add sound

    bigIconTemplate:SetImage(pikeIconBig)
    bigIconTemplate:SetPos(frBigButton.x, frBigButton.y)

    good = WEAPON.pike
    DisplayCurrentStock(3)
end
pikeIconButton.OnMouseExit = function(self)
    self:SetImage(pikeIcon)
end
-- LETHER ICON BUTTON
local leatherIconButton = loveframes.Create("image")
leatherIconButton:SetState(states.STATE_MARKET)
leatherIconButton:SetImage(leatherIcon)
leatherIconButton:SetScaleX(frLetherButton.width / leatherIconButton:GetImageWidth())
leatherIconButton:SetScaleY(leatherIconButton:GetScaleX())
leatherIconButton:SetPos(frLetherButton.x, frLetherButton.y)
leatherIconButton.OnMouseEnter = function(self)
    self:SetImage(leatherIcon) -- TODO HOVER BUTTON
end
leatherIconButton.OnMouseDown = function(self)
    self:SetImage(leatherIcon) -- TODO DOWN BUTTON
end
leatherIconButton.OnClick = function(self)
    -- TODO add sound

    bigIconTemplate:SetImage(leatherIconBig)
    bigIconTemplate:SetPos(frBigButton.x, frBigButton.y)

    good = WEAPON.leatherArmor
    DisplayCurrentStock(3)
end
leatherIconButton.OnMouseExit = function(self)
    self:SetImage(leatherIcon)
end
-- ARMOUR ICON BUTTON
local armourIconButton = loveframes.Create("image")
armourIconButton:SetState(states.STATE_MARKET)
armourIconButton:SetImage(armorIcon)
armourIconButton:SetScaleX(frArmourButton.width / armourIconButton:GetImageWidth())
armourIconButton:SetScaleY(armourIconButton:GetScaleX())
armourIconButton:SetPos(frArmourButton.x, frArmourButton.y)
armourIconButton.OnMouseEnter = function(self)
    self:SetImage(armorIcon) -- TODO HOVER BUTTON
end
armourIconButton.OnMouseDown = function(self)
    self:SetImage(armorIcon) -- TODO DOWN BUTTON
end
armourIconButton.OnClick = function(self)
    -- TODO add sound

    bigIconTemplate:SetImage(armorIconBig)
    bigIconTemplate:SetPos(frBigButton.x, frBigButton.y)

    good = WEAPON.shield
    DisplayCurrentStock(3)
end
armourIconButton.OnMouseExit = function(self)
    self:SetImage(armorIcon)
end

-- QUICK TAB ICONS
local foodButton = loveframes.Create("image")
local materialButton = loveframes.Create("image")
local weaponButton = loveframes.Create("image")

local function DisplayFoodIcons(option)
    option = (option ~= false)
    meatIconButton:SetVisible(option)
    cheeseIconButton:SetVisible(option)
    appleIconButton:SetVisible(option)
    breadIconButton:SetVisible(option)
end

local function DisplayMaterialIcons(option)
    option = (option ~= false)
    woodIconButton:SetVisible(option)
    stoneIconButton:SetVisible(option)
    wheatIconButton:SetVisible(option)
    tarIconButton:SetVisible(option)
    aleIconButton:SetVisible(option)
    ironIconButton:SetVisible(option)
    hopIconButton:SetVisible(option)
    flourIconButton:SetVisible(option)
end

local function DisplayWeaponIcons(option)
    option = (option ~= false)
    bowIconButton:SetVisible(option)
    crossbowIconButton:SetVisible(option)
    maceIconButton:SetVisible(option)
    pikeIconButton:SetVisible(option)
    spearIconButton:SetVisible(option)
    leatherIconButton:SetVisible(option)
    swordIconButton:SetVisible(option)
    armourIconButton:SetVisible(option)
end

local function switchTradeGroup(groupType)
    if groupType == 1 then
        currentStock:SetText("")
        DisplayFoodIcons(true)
        DisplayMaterialIcons(false)
        DisplayWeaponIcons(false)
        foodButton:SetImage(foodButtonClickedImage)
        materialButton:SetImage(materialButtonImage)
        weaponButton:SetImage(weaponButtonImage)
        bigIconTemplate:SetImage(emptyIconBig)
    elseif groupType == 2 then
        currentStock:SetText("")
        DisplayFoodIcons(false)
        DisplayMaterialIcons(true)
        DisplayWeaponIcons(false)
        foodButton:SetImage(foodButtonImage)
        materialButton:SetImage(materialButtonClickedImage)
        weaponButton:SetImage(weaponButtonImage)
        bigIconTemplate:SetImage(emptyIconBig)
    elseif groupType == 3 then
        currentStock:SetText("")
        DisplayFoodIcons(false)
        DisplayMaterialIcons(false)
        DisplayWeaponIcons(true)
        foodButton:SetImage(foodButtonImage)
        materialButton:SetImage(materialButtonImage)
        weaponButton:SetImage(weaponButtonClickedImage)
        bigIconTemplate:SetImage(emptyIconBig)
    end
end

materialButton:SetState(states.STATE_MARKET)
materialButton:SetImage(materialButtonImage)
materialButton:SetScaleX(frMaterial.width / materialButton:GetImageWidth())
materialButton:SetScaleY(materialButton:GetScaleX())
materialButton:SetPos(frMaterial.x, frMaterial.y)
materialButton.OnMouseEnter = function(self)
    self:SetImage(materialButtonHoverImage)
end
materialButton.OnClick = function(self)
    self:SetImage(materialButtonClickedImage)
    foodButton:SetImage(foodButtonImage)
    weaponButton:SetImage(weaponButtonImage)
    switchTradeGroup(2)
    groupTypeMarket.name = 2
end
materialButton.OnMouseExit = function(self)
    if groupTypeMarket.name == 2 then
        self:SetImage(materialButtonClickedImage)
        foodButton:SetImage(foodButtonImage)
        weaponButton:SetImage(weaponButtonImage)
    else
        self:SetImage(materialButtonImage)
    end
end
foodButton:SetState(states.STATE_MARKET)
foodButton:SetImage(foodButtonImage)
foodButton:SetScaleX(frFood.width / foodButton:GetImageWidth())
foodButton:SetScaleY(foodButton:GetScaleX())
foodButton:SetPos(frFood.x, frFood.y)
foodButton.OnMouseEnter = function(self)
    self:SetImage(foodButtonHoverImage)
end
foodButton.OnClick = function(self)
    self:SetImage(foodButtonClickedImage)
    materialButton:SetImage(materialButtonImage)
    weaponButton:SetImage(weaponButtonImage)
    switchTradeGroup(1)
    groupTypeMarket.name = 1
end
foodButton.OnMouseExit = function(self)
    if groupTypeMarket.name == 1 then
        self:SetImage(foodButtonClickedImage)
        materialButton:SetImage(materialButtonImage)
        weaponButton:SetImage(weaponButtonImage)
    else
        self:SetImage(foodButtonImage)
    end
end
weaponButton:SetState(states.STATE_MARKET)
weaponButton:SetImage(weaponButtonImage)
weaponButton:SetScaleX(frWeapon.width / weaponButton:GetImageWidth())
weaponButton:SetScaleY(foodButton:GetScaleX())
weaponButton:SetPos(frWeapon.x, frWeapon.y)
weaponButton.OnMouseEnter = function(self)
    self:SetImage(weaponButtonHoverImage)
end
weaponButton.OnClick = function(self)
    self:SetImage(weaponButtonClickedImage)
    foodButton:SetImage(foodButtonImage)
    materialButton:SetImage(materialButtonImage)
    switchTradeGroup(3)
    groupTypeMarket.name = 3
end
weaponButton.OnMouseExit = function(self)
    if groupTypeMarket.name == 3 then
        self:SetImage(weaponButtonClickedImage)
        foodButton:SetImage(foodButtonImage)
        materialButton:SetImage(materialButtonImage)
    else
        self:SetImage(weaponButtonImage)
    end
end

actionBar:registerGroup("market_trade", { backButtonA })

local IncButton = loveframes.Create("image")
IncButton:SetState(states.STATE_MARKET)
IncButton:setTooltip("Increase quantity of items you want to trade by 5")
IncButton:SetImage(IncButtonImage)
IncButton:SetScaleX(frIncButton.width / IncButton:GetImageWidth())
IncButton:SetScaleY(IncButton:GetScaleX())
IncButton:SetPos(frIncButton.x, frIncButton.y)
IncButton.OnMouseEnter = function(self)
    self:SetImage(IncButtonImageHover)
end
IncButton.OnMouseDown = function(self)
    self:SetImage(IncButtonImageHover) -- TODO DOWN BUTTON
end
IncButton.OnClick = function(self)
    -- TODO add sound

    quantity = quantity + 5
    price = ((5 * quantity) / 5)

    priceText:SetText({ {
        color = { 0, 0, 0, 1 }
    }, price })

    quantityText:SetText({ {
        color = { 0, 0, 0, 1 }
    }, quantity })

end

IncButton.OnMouseExit = function(self)
    self:SetImage(IncButtonImage)
end

local DecButton = loveframes.Create("image")
DecButton:SetState(states.STATE_MARKET)
DecButton:setTooltip("Decrease quantity of items you want to trade by 5")
DecButton:SetImage(DecButtonImage)
DecButton:SetScaleX(frDecButton.width / DecButton:GetImageWidth())
DecButton:SetScaleY(DecButton:GetScaleX())
DecButton:SetPos(frDecButton.x, frDecButton.y)
DecButton.OnMouseEnter = function(self)
    self:SetImage(DecButtonImageHover)
end
DecButton.OnMouseDown = function(self)
    self:SetImage(DecButtonImageHover) -- TODO DOWN BUTTON
end
DecButton.OnClick = function(self)
    -- TODO add sound

    if quantity > 5 then
        quantity = quantity - 5
        price = ((5 * quantity) / 5)

        priceText:SetText({ {
            color = { 0, 0, 0, 1 }
        }, price })

        quantityText:SetText({ {
            color = { 0, 0, 0, 1 }
        }, quantity })

    end
end

DecButton.OnMouseExit = function(self)
    self:SetImage(DecButtonImage)
end

local marketBuyButton = loveframes.Create("image")
local marketSellButton = loveframes.Create("image")

local function UpdateTooltip()
    dynamicBuyTooltip = ("Buy '%d' pieces of %s for '%d' gold"):format(quantity, good, price)
    dynamicSellTooltip = ("Sell '%d' pieces of %s for '%d' gold"):format(quantity, good, price)

    marketBuyButton:setTooltip(dynamicBuyTooltip)
    marketSellButton:setTooltip(dynamicSellTooltip)
end

marketBuyButton:SetState(states.STATE_MARKET)
marketBuyButton:setTooltip(dynamicBuyTooltip)
marketBuyButton:SetImage(marketBuyButtonImage)
marketBuyButton:SetScaleX(frBuyButton.width / marketBuyButton:GetImageWidth())
marketBuyButton:SetScaleY(marketBuyButton:GetScaleX())
marketBuyButton:SetPos(frBuyButton.x, frBuyButton.y)
marketBuyButton.OnMouseEnter = function(self)
    self:SetImage(marketBuyButtonHoverImage)
    UpdateTooltip()
end
marketBuyButton.OnMouseDown = function(self)
    self:SetImage(marketBuyButtonHoverImage) -- TODO DOWN BUTTON
end
marketBuyButton.OnClick = function(self)
    -- TODO add sound
    if good and good ~= "" and _G.state.gold >= price then

        if groupTypeMarket.name == 1 then
            if _G.foodpile:store(good) then
                for _ = 1, quantity - 1 do
                    if _G.foodpile:store(good) then
                        _G.state.gold = _G.state.gold - 1
                    end
                end
                _G.state.gold = _G.state.gold - 1
                _G.playInterfaceSfx(_G.fx["drawbridge_control"])
            else
                _G.playSpeech("granary_full")
            end
        end

        if groupTypeMarket.name == 2 then
            if _G.stockpile:store(good) then
                for _ = 1, quantity - 1 do
                    if _G.stockpile:store(good) then
                        _G.state.gold = _G.state.gold - 1
                    end
                end
                _G.state.gold = _G.state.gold - 1
                _G.playInterfaceSfx(_G.fx["drawbridge_control"])
            else
                _G.playSpeech("stockpile_full")
            end
        end

        if groupTypeMarket.name == 3 then
            if _G.weaponpile:store(good) then
                for _ = 1, quantity - 1 do
                    if _G.weaponpile:store(good) then
                        _G.state.gold = _G.state.gold - 1
                    end
                end
                _G.state.gold = _G.state.gold - 1
                _G.playInterfaceSfx(_G.fx["drawbridge_control"])
            else
                _G.playSpeech("stockpile_full") -- TODO ARMOUR SOUND
            end
        end
        DisplayCurrentStock(groupTypeMarket.name)
        actionBar:updateStockpileResourcesCount()
        actionBar:updateGoldCount()
    end
end
marketBuyButton.OnMouseExit = function(self)
    self:SetImage(marketBuyButtonImage)
end

marketSellButton:SetState(states.STATE_MARKET)
marketSellButton:setTooltip(dynamicSellTooltip)
marketSellButton:SetImage(marketSellButtonImage)
marketSellButton:SetScaleX(frSellButton.width / marketSellButton:GetImageWidth())
marketSellButton:SetScaleY(marketSellButton:GetScaleX())
marketSellButton:SetPos(frSellButton.x, frSellButton.y)
marketSellButton.OnMouseEnter = function(self)
    self:SetImage(marketSellButtonHoverImage)
    UpdateTooltip()
end
marketSellButton.OnMouseDown = function(self)
    self:SetImage(marketSellButtonHoverImage) -- TODO DOWN BUTTON
end
marketSellButton.OnClick = function(self)
    -- TODO add sound
    local quantity_temp;
    if good then
        if _G.state.resources[good] == 0 or _G.state.food[good] == 0 then
            _G.playSpeech("not_enough_goods")
            return
        end

        if groupTypeMarket.name == 1 then
            if _G.state.food[good] < 5 then
                quantity_temp = _G.state.food[good]
                for _ = 1, quantity_temp do
                    _G.foodpile:take(good)
                    _G.state.gold = _G.state.gold + 1
                end
                _G.playInterfaceSfx(_G.fx["drawbridge_control"])
            elseif _G.state.food[good] >= quantity then
                for _ = 1, quantity do
                    _G.foodpile:take(good)
                    _G.state.gold = _G.state.gold + 1
                end
                _G.playInterfaceSfx(_G.fx["drawbridge_control"])
            end
        end

        if groupTypeMarket.name == 2 then
            if _G.state.resources[good] >= quantity then
                for _ = 1, quantity do
                    if _G.stockpile:take(good) then
                        _G.state.gold = _G.state.gold + 1
                    end
                end
                _G.playInterfaceSfx(_G.fx["drawbridge_control"])
            elseif _G.state.resources[good] < 5 then
                quantity_temp = _G.state.resources[good]
                for _ = 1, quantity_temp do
                    if _G.stockpile:take(good) then
                        _G.state.gold = _G.state.gold + 1
                    end
                end
                _G.playInterfaceSfx(_G.fx["drawbridge_control"])
            end
        end

        if groupTypeMarket.name == 3 then
            if _G.state.weapons[good] >= quantity then
                for _ = 1, quantity do
                    if _G.weaponpile:take(good) then
                        _G.state.gold = _G.state.gold + 1
                    end
                end
                _G.playInterfaceSfx(_G.fx["drawbridge_control"])
            elseif _G.state.weapons[good] < 5 then
                quantity_temp = _G.state.weapons[good]
                for _ = 1, quantity_temp do
                    if _G.weaponpile:take(good) then
                        _G.state.gold = _G.state.gold + 1
                    end
                end
                _G.playInterfaceSfx(_G.fx["drawbridge_control"])
            end
        end
        DisplayCurrentStock(groupTypeMarket.name)
        actionBar:updateStockpileResourcesCount()
        actionBar:updateGoldCount()
    end
end
marketSellButton.OnMouseExit = function(self)
    self:SetImage(marketSellButtonImage)
end

return { switchTradeGroup, DisplayCurrentStock }
