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

local good = "good"
local quantity = 5
local price = 5
local dynamicBuyTooltip = ""
local dynamicSellTooltip = ""

backButton.OnClick = function(self)
    actionBar:switchMode("market")
    good = ""
end

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
priceText:SetFont(loveframes.font_vera_italic)
priceText:SetPos(frGold.x, frGold.y)
priceText:SetText({{
    color = {0, 0, 0, 1}
}, "5"})
priceText:SetShadow(false)

local quantityText = loveframes.Create("text")
quantityText:SetState(states.STATE_MARKET)
quantityText:SetFont(loveframes.font_vera_italic)
quantityText:SetPos(frQuantity.x, frQuantity.y)
quantityText:SetText({{
    color = {0, 0, 0, 1}
}, "5"})
quantityText:SetShadow(false)

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
    print("iron")
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

    print("flour has been chosen")
    good = "flour"
    print(good)
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

    print("meat has been chosen")
    good = "meat"
    print(good)
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

    print("cheese has been chosen")
    good = "cheese"
    print(good)
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

    print("apple has been chosen")
    good = "apples"
    print(good)
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
    good = "bread"
end
breadIconButton.OnMouseExit = function(self)
    self:SetImage(breadIcon)
end

local function switchTradeGroup(groupType)
    if groupType == 1 then
        woodIconButton:SetVisible(false)
        stoneIconButton:SetVisible(false)
        wheatIconButton:SetVisible(false)
        tarIconButton:SetVisible(false)
        aleIconButton:SetVisible(false)
        ironIconButton:SetVisible(false)
        hopIconButton:SetVisible(false)
        flourIconButton:SetVisible(false)

        meatIconButton:SetVisible(true)
        cheeseIconButton:SetVisible(true)
        appleIconButton:SetVisible(true)
        breadIconButton:SetVisible(true)
        bigIconTemplate:SetImage(emptyIconBig)
    elseif groupType == 2 then
        woodIconButton:SetVisible(true)
        stoneIconButton:SetVisible(true)
        wheatIconButton:SetVisible(true)
        tarIconButton:SetVisible(true)
        aleIconButton:SetVisible(true)
        ironIconButton:SetVisible(true)
        hopIconButton:SetVisible(true)
        flourIconButton:SetVisible(true)

        meatIconButton:SetVisible(false)
        cheeseIconButton:SetVisible(false)
        appleIconButton:SetVisible(false)
        breadIconButton:SetVisible(false)
        bigIconTemplate:SetImage(emptyIconBig)
    elseif groupType == 3 then
        woodIconButton:SetVisible(false)
        stoneIconButton:SetVisible(false)
        wheatIconButton:SetVisible(false)
        tarIconButton:SetVisible(false)
        aleIconButton:SetVisible(false)
        ironIconButton:SetVisible(false)
        hopIconButton:SetVisible(false)
        flourIconButton:SetVisible(false)

        meatIconButton:SetVisible(false)
        cheeseIconButton:SetVisible(false)
        appleIconButton:SetVisible(false)
        breadIconButton:SetVisible(false)
        bigIconTemplate:SetImage(emptyIconBig)
    end
end

actionBar:registerGroup("market_trade", {backButtonA})

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

    priceText:SetText({{
        color = {0, 0, 0, 1}
    }, price})

    quantityText:SetText({{
        color = {0, 0, 0, 1}
    }, quantity})

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

    priceText:SetText({{
        color = {0, 0, 0, 1}
    }, price})

    quantityText:SetText({{
        color = {0, 0, 0, 1}
    }, quantity})

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
    local stockpileController = require("objects.Controllers.StockpileController")

    if good ~= "" and _G.state.gold >= price then

        if groupTypeMarket.name == 1 then
            _G.state.gold = _G.state.gold - ((5 * quantity) / 5)
            for _ = 1, quantity do
                _G.foodpile:store(good)
            end
        end

        if groupTypeMarket.name == 2 then
            _G.state.gold = _G.state.gold - ((5 * quantity) / 5)
            for _ = 1, quantity do
                _G.stockpile:store(good)
            end
        end

        stockpileController:updateResourceCount()
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
    local stockpileController = require("objects.Controllers.StockpileController")
    local quantity_temp;

    if good ~= ""  then


        if groupTypeMarket.name == 1 and  _G.state.food[good] >= quantity then
            _G.state.gold = _G.state.gold + ((5 * quantity) / 5)
            for _ = 1, quantity do
                _G.foodpile:take(good)
            end
        end

        if groupTypeMarket.name == 1 and _G.state.food[good] < 5  then
            quantity_temp = _G.state.food[good]
            _G.state.gold = _G.state.gold + ((5 * quantity_temp) / 5)
            for _ = 1, quantity_temp do
                _G.foodpile:take(good)
            end
        end

        if groupTypeMarket.name == 2 and _G.state.resources[good] >= quantity  then
            _G.state.gold = _G.state.gold + ((5 * quantity) / 5)
            for _ = 1, quantity do
                _G.stockpile:take(good)
            end
        end

        if groupTypeMarket.name == 2 and _G.state.resources[good] < 5  then
            quantity_temp = _G.state.resources[good]
            _G.state.gold = _G.state.gold + ((5 * quantity_temp) / 5)
            for _ = 1, quantity_temp do
                _G.stockpile:take(good)
            end
        end

        stockpileController:updateResourceCount()
        actionBar:updateStockpileResourcesCount()
        actionBar:updateGoldCount()
    end
end
marketSellButton.OnMouseExit = function(self)
    self:SetImage(marketSellButtonImage)
end

return switchTradeGroup
