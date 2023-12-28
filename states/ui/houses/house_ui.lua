local loveframes = require("libraries.loveframes")
local states = require("states.ui.states")
local framesActionBar = require("states.ui.action_bar_frames")
local ActionBar = require("states.ui.ActionBar")
local scale = ActionBar.element.scalex
local Events = require("objects.Enums.Events")
local SID = require("objects.Controllers.LanguageController").lines

local ActionBarButton = require("states.ui.ActionBarButton")
local backButton = ActionBarButton:new(love.graphics.newImage("assets/ui/back_ab.png"), states.STATE_HOUSE, 12)
backButton:setOnClick(function(self)
    ActionBar:switchMode()
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

local targetHouse, house, X, Y
local acomodationNumber = 4
local lockButton
local textUpgradeCost = loveframes.Create("text")
local textUpgradePop = loveframes.Create("text")
local textAcomodation = loveframes.Create("text")
local upgradeButton = loveframes.Create("image")
local textUpgrade = loveframes.Create("text")

_G.bus.on(Events.UpgradeHouse, function(tier, obj)
    targetHouse = tier
    house = obj
    acomodationNumber = 4 * tier
    if tier == 1 then
        sketchIcon:SetImage(hovelSketchImage)
        sketchIcon:SetScale(frSketch.width / sketchIcon:GetImageHeight())
    end
    if tier == 2 then
        sketchIcon:SetImage(flatSketchImage)
        sketchIcon:SetScale(frSketch.width / sketchIcon:GetImageHeight())
    end
    if tier == 3 then
        sketchIcon:SetImage(residenceSketchImage)
        sketchIcon:SetScale(frSketch.width / sketchIcon:GetImageHeight())
    end
    if tier == 4 then
        sketchIcon:SetImage(bigresidenceSketchImage)
        sketchIcon:SetScale(frSketch.width / sketchIcon:GetImageHeight())
    end
    textUpgrade:SetText({ {
        color = { 0, 0, 0, 1 }
    }, SID.houses.upgradeButton })
    textAcomodation:SetText({ {
        color = { 0, 0, 0, 1 }
    }, string.format(SID.houses.description, acomodationNumber) })
    textUpgradePop:SetText({ {
        color = { 0, 0, 0, 1 }
    }, acomodationNumber + 4 })
    textUpgradeCost:SetText({ {
        color = { 0, 0, 0, 1 }
    }, 5 })
    if tier + 1 > _G.state.tier then
        lockButton = true
        upgradeButton:SetImage(upgradeIconLocked)
    else
        lockButton = false
        upgradeButton:SetImage(upgradeIconNormal)
    end
    if tier == 4 then
        upgradeButton.visible = false
        textUpgradeCost.visible = false
        textUpgradePop.visible = false
        textUpgrade.visible = false
    else
        upgradeButton.visible = true
        textUpgradeCost.visible = true
        textUpgradePop.visible = true
        textUpgrade.visible = true
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
    if lockButton then return end
    local Flat = require("objects.Structures.Flat")
    local Residence = require("objects.Structures.Residence")
    local BigResidence = require("objects.Structures.BigResidence")
    if targetHouse == 3 then
        -- RESIDENCE
        if _G.state.tier >= 4 and _G.BuildController:isHouseUpgradeAffordable() then
            _G.BuildController:purchaseHouseUpgrade()
            _G.DestructionController:destroyAtLocation(house.gx, house.gy, nil, nil, true)
            local newHouse = BigResidence:new(house.gx, house.gy)
            _G.bus.emit(Events.UpgradeHouse, 4, newHouse)
            ActionBar:switchMode("max_house")
        end
    elseif targetHouse == 2 then
        -- FLAT
        if _G.state.tier >= 3 and _G.BuildController:isHouseUpgradeAffordable() then
            _G.BuildController:purchaseHouseUpgrade()
            _G.DestructionController:destroyAtLocation(house.gx, house.gy, nil, nil, true)
            local newHouse = Residence:new(house.gx, house.gy)
            _G.bus.emit(Events.UpgradeHouse, 3, newHouse)
        end
    elseif targetHouse == 1 then
        -- HOVEL
        if _G.state.tier >= 2 and _G.BuildController:isHouseUpgradeAffordable() then
            _G.BuildController:purchaseHouseUpgrade()
            _G.DestructionController:destroyAtLocation(house.gx, house.gy, nil, nil, true)
            local newHouse = Flat:new(house.gx, house.gy)
            _G.bus.emit(Events.UpgradeHouse, 2, newHouse)
        end
    else
        return
    end
    ActionBar:updatePopulationCount()
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
}, SID.houses.upgradeButton })
textUpgrade:SetShadowColor(0, 0, 0, 1)
textUpgrade:SetShadow(true)
textUpgrade:SetClickBounds(0, 0, 0, 0) -- the text is not clickable; the button bellow is.

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
}, string.format(SID.houses.description, acomodationNumber) })
textAcomodation:SetShadowColor(0, 0, 0, 1)
textAcomodation:SetShadow(true)

sketchIcon:SetState(states.STATE_HOUSE)
sketchIcon:SetPos(frSketch.x, frSketch.y)
sketchIcon:SetScaleX(frSketch.width / sketchIcon:GetImageWidth())
sketchIcon:SetScaleY(sketchIcon:GetScaleX())
