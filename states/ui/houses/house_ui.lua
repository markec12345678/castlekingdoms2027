local loveframes = require("libraries.loveframes")
local states = require("states.ui.states")
local framesActionBar = require("states.ui.action_bar_frames")
local actionBar = require("states.ui.ActionBar")
local scale = actionBar.element.scalex
local Events = require("objects.Enums.Events")


local ActionBarButton = require("states.ui.ActionBarButton")
local backButton = ActionBarButton:new(love.graphics.newImage("assets/ui/back_ab.png"), states.STATE_HOUSE, 12)
backButton:setOnClick(function(self)
    actionBar:switchMode()
end)

local upgradeIconNormal = love.graphics.newImage("assets/ui/house/upgradeIconNormal.png")
local upgradeIconHover = love.graphics.newImage("assets/ui/house/upgradeIconHover.png")
local upgradeIconLocked = love.graphics.newImage("assets/ui/house/upgradeIconLocked.png")

local sketchIcon = loveframes.Create("image")
local hovelSketchImage = love.graphics.newImage("assets/ui/house/hovelSketch.png")
local flatSketchImage = love.graphics.newImage("assets/ui/house/flatSketch.png")
local residenceSketchImage = love.graphics.newImage("assets/ui/house/residenceSketch.png")
local bigresidenceSketchImage = love.graphics.newImage("assets/ui/house/bigresidenceSketch.png")

local frSketch = {
    x = framesActionBar["frFull"].x + 150 * scale,
    y = framesActionBar["frFull"].y + 112 * scale,
    width = hovelSketchImage:getWidth() * scale,
    height = hovelSketchImage:getHeight() * scale
}
sketchIcon:SetImage(hovelSketchImage)

local frUpgradeButton = {
    x = framesActionBar["frFull"].x + 704 * scale,
    y = framesActionBar["frFull"].y + 106 * scale,
    width = upgradeIconNormal:getWidth() * scale,
    height = upgradeIconNormal:getHeight() * scale
}

local X
local targetHouse
local Y
local acomodationNumber = 4
local lockButton
local textUpgradeCost = loveframes.Create("text")
local textUpgradePop = loveframes.Create("text")
local textAcomodation = loveframes.Create("text")
local upgradeButton = loveframes.Create("image")
local textUpgrade = loveframes.Create("text")

_G.bus.on(Events.OnHouseUpgraded, function(tier, x, y)
    targetHouse = tier
    X = x
    Y = y
    acomodationNumber = 4 * tier
    if tier == 1 then
        sketchIcon:SetImage(hovelSketchImage)
    end
    if tier == 2 then
        sketchIcon:SetImage(flatSketchImage)
    end
    if tier == 3 then
        sketchIcon:SetImage(residenceSketchImage)
    end
    if tier == 4 then
        sketchIcon:SetImage(bigresidenceSketchImage)
    end
    textUpgrade:SetText({ {
        color = { 0, 0, 0, 1 }
    }, "UPGRADE" })
    textAcomodation:SetText({ {
        color = { 0, 0, 0, 1 }
    }, "Offers shelter to " .. acomodationNumber .. " people" })
    textUpgradePop:SetText({ {
        color = { 0, 0, 0, 1 }
    }, acomodationNumber + 4 })
    textUpgradeCost:SetText({ {
        color = { 0, 0, 0, 1 }
    }, (acomodationNumber + 1) * 2 })
    if tier >= _G.state.tier then
        lockButton = true
        upgradeButton:SetImage(upgradeIconLocked)
    else
        lockButton = false
        upgradeButton:SetImage(upgradeIconNormal)
    end
end)

upgradeButton:SetState(states.STATE_HOUSE)
upgradeButton:SetImage(upgradeIconNormal)
upgradeButton:SetScaleX(frUpgradeButton.width / upgradeButton:GetImageWidth())
upgradeButton:SetScaleY(upgradeButton:GetScaleX())
upgradeButton:SetPos(frUpgradeButton.x, frUpgradeButton.y)
upgradeButton.OnMouseEnter = function(self)
    if lockButton == false then
        self:SetImage(upgradeIconHover)
    end
end

upgradeButton.OnClick = function(self)
    local House = require("objects.Structures.House")
    local Flat = require("objects.Structures.Flat")
    local Residence = require("objects.Structures.Residence")
    local BigResidence = require("objects.Structures.BigResidence")
    -- BIG RESIDENCE
    -- RESIDENCE
    if targetHouse == 3 and lockButton == false then
        if _G.state.tier >= 4 and _G.BuildController:isBuildingAffordable("BigResidence") then
            _G.BuildController:purchaseBuilding("BigResidence")
            Residence:upgradeHouse(X, Y)
            actionBar:switchMode()
        end
        --PLAY SOUND "NOT ENOUGH WOOD"
    end
    -- FLAT
    if targetHouse == 2 and lockButton == false then
        if _G.state.tier >= 3 and _G.BuildController:isBuildingAffordable("Residence") then
            _G.BuildController:purchaseBuilding("Residence")
            Flat:upgradeHouse(X, Y)
            actionBar:switchMode()
        end
        --PLAY SOUND "NOT ENOUGH WOOD"
    end
    -- HOVEL
    if targetHouse == 1 and lockButton == false then
        if _G.state.tier >= 2 and _G.BuildController:isBuildingAffordable("Flat") then
            _G.BuildController:purchaseBuilding("Flat")
            actionBar:switchMode()
            House:upgradeHouseOne(X, Y)
        end
        --PLAY SOUND "NOT ENOUGH WOOD"
    end
end

upgradeButton.OnMouseExit = function(self)
    if lockButton == false then
        self:SetImage(upgradeIconNormal)
    end
end

local frTextUpgrade = {
    x = framesActionBar.frFull.x + 750 * scale,
    y = framesActionBar.frFull.y + 115 * scale,
    width = 10 * scale,
    height = 5 * scale
}

textUpgrade:SetState(states.STATE_HOUSE)
textUpgrade:SetFont(loveframes.font_immortal_large)
textUpgrade:SetPos(frTextUpgrade.x, frTextUpgrade.y)
textUpgrade:SetText({ {
    color = { 0, 0, 0, 1 }
}, "UPGRADE" })
textUpgrade:SetShadowColor(0, 0, 0, 1)
textUpgrade:SetShadow(true)
textUpgrade:SetClickBounds(0,0,0,0) -- the text is not clickable; the button bellow is.

local frTextCost = {
    x = framesActionBar.frFull.x + 705 * scale,
    y = framesActionBar.frFull.y + 155 * scale,
    width = 50 * scale,
    height = 20 * scale
}

textUpgradeCost:SetState(states.STATE_HOUSE)
textUpgradeCost:SetFont(loveframes.font_immortal_large)
textUpgradeCost:SetPos(frTextCost.x, frTextCost.y)
textUpgradeCost:SetText({ {
    color = { 0, 0, 0, 1 }
}, (acomodationNumber + 1) * 2 })
textUpgradeCost:SetShadowColor(0, 0, 0, 1)
textUpgradeCost:SetShadow(true)

local frTextPop = {
    x = framesActionBar.frFull.x + 850 * scale,
    y = framesActionBar.frFull.y + 155 * scale,
    width = 50 * scale,
    height = 20 * scale
}

textUpgradePop:SetState(states.STATE_HOUSE)
textUpgradePop:SetFont(loveframes.font_immortal_large)
textUpgradePop:SetPos(frTextPop.x, frTextPop.y)
textUpgradePop:SetText({ {
    color = { 0, 0, 0, 1 }
}, acomodationNumber + 4 })
textUpgradePop:SetShadowColor(0, 0, 0, 1)
textUpgradePop:SetShadow(true)

local frAcomodationText = {
    x = framesActionBar.frFull.x + 420 * scale,
    y = framesActionBar.frFull.y + 115 * scale,
    width = 50 * scale,
    height = 20 * scale
}

textAcomodation:SetState(states.STATE_HOUSE)
textAcomodation:SetFont(loveframes.font_immortal_large)
textAcomodation:SetPos(frAcomodationText.x, frAcomodationText.y)
textAcomodation:SetText({ {
    color = { 0, 0, 0, 1 }
}, "Offers shelter to " .. acomodationNumber .. " people" })
textAcomodation:SetShadowColor(0, 0, 0, 1)
textAcomodation:SetShadow(true)

sketchIcon:SetState(states.STATE_HOUSE)
sketchIcon:SetPos(frSketch.x, frSketch.y)
sketchIcon:SetScaleX(frSketch.width / sketchIcon:GetImageWidth())
sketchIcon:SetScaleY(sketchIcon:GetScaleX())
