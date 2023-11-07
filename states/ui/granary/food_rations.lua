local loveframes = require("libraries.loveframes")
local states = require("states.ui.states")
local framesActionBar = require("states.ui.action_bar_frames")
local actionBar = require("states.ui.ActionBar")
local scale = actionBar.element.scalex
local SID = require("objects.Controllers.LanguageController").lines

local ActionBarButton = require("states.ui.ActionBarButton")
local backButton = ActionBarButton:new(love.graphics.newImage("assets/ui/back_ab.png"), states.STATE_GRANARY, 12)
backButton:setOnClick(function(self)
    actionBar:switchMode()
end)
actionBar:registerGroup("granary", { backButton })

local colorRed = { 200 / 255, 90 / 255, 90 / 255, 1 }
local colorWhite = { 1, 1, 1, 1 }
local colorGreen = { 130 / 255, 220 / 255, 123 / 255, 1 }

local pointerHandButtonImage1 = love.graphics.newImage("assets/ui/hand_1.png")
local pointerHandButtonImage2 = love.graphics.newImage("assets/ui/hand_2.png")
local pointerHandButtonImage3 = love.graphics.newImage("assets/ui/hand_3.png")
local pointerHandButtonImage4 = love.graphics.newImage("assets/ui/hand_4.png")
local pointerHandButtonImage5 = love.graphics.newImage("assets/ui/hand_5.png")
local frPointerHand = {
    x = framesActionBar["frFull"].x + 593 * scale,
    y = framesActionBar["frFull"].y + 148 * scale,
    width = pointerHandButtonImage1:getWidth() * scale,
    height = pointerHandButtonImage1:getHeight() * scale
}
local pointerHand = loveframes.Create("image")
pointerHand:SetState(states.STATE_GRANARY)
pointerHand:SetImage(pointerHandButtonImage3)
pointerHand:SetScaleX(frPointerHand.width / pointerHand:GetImageWidth())
pointerHand:SetScaleY(pointerHand:GetScaleX())
pointerHand:SetPos(frPointerHand.x, frPointerHand.y)
pointerHand.disablehover = true

local frText = {
    x = framesActionBar.frFull.x + 280 * scale,
    y = framesActionBar.frFull.y + 145 * scale,
    width = 50 * scale,
    height = 20 * scale
}
local moodFoodGui = loveframes.Create("text")
moodFoodGui:SetState(states.STATE_GRANARY)
moodFoodGui:SetFont(loveframes.font_immortal_large)
moodFoodGui:SetPos(frText.x, frText.y)
moodFoodGui:SetText({ {
    color = { 1, 1, 1, 1 }
}, "0" })
moodFoodGui:SetShadowColor(0, 0, 0, 1)
moodFoodGui:SetShadow(true)

local moodNeutralImage = love.graphics.newImage("assets/ui/keep/mood_neutral.png")
local moodNegativeImage = love.graphics.newImage("assets/ui/keep/mood_negative.png")
local moodPositiveImage = love.graphics.newImage("assets/ui/keep/mood_positive.png")
local frMood = {
    x = frText.x - moodNeutralImage:getWidth() * 1.1 * scale,
    y = frText.y,
    width = moodNeutralImage:getWidth() * scale,
    height = moodNeutralImage:getHeight() * scale
}
local MoodImage = loveframes.Create("image")
MoodImage:SetState(states.STATE_GRANARY)
MoodImage:SetImage(moodNeutralImage)
MoodImage:SetScaleX(frMood.width / MoodImage:GetImageWidth())
MoodImage:SetScaleY(MoodImage:GetScaleX())
MoodImage:SetPos(frMood.x, frMood.y)
function MoodImage:SetPositiveMood()
    self:SetImage(moodPositiveImage)
end

function MoodImage:SetNegativeMood()
    self:SetImage(moodNegativeImage)
end

function MoodImage:SetNeutralMood()
    self:SetImage(moodNeutralImage)
end

local noRationButtonImage = love.graphics.newImage("assets/ui/no_ration.png")
local noRationButtonImageHover = love.graphics.newImage("assets/ui/no_ration_hover.png")
local noRationButtonImageDown = love.graphics.newImage("assets/ui/no_ration_down.png")
local frNoRation = {
    x = framesActionBar["frFull"].x + 481 * scale,
    y = framesActionBar["frFull"].y + 139 * scale,
    width = noRationButtonImage:getWidth() * scale,
    height = noRationButtonImage:getHeight() * scale
}
local noRationButton = loveframes.Create("image")
noRationButton:SetState(states.STATE_GRANARY)
noRationButton:setTooltip(SID.rations.no.name, SID.rations.no.description)
noRationButton:SetImage(noRationButtonImage)
noRationButton:SetScaleX(frNoRation.width / noRationButton:GetImageWidth())
noRationButton:SetScaleY(noRationButton:GetScaleX())
noRationButton:SetPos(frNoRation.x, frNoRation.y)
noRationButton.OnMouseEnter = function(self)
    self:SetImage(noRationButtonImageHover)
end
noRationButton.OnMouseDown = function(self)
    self:SetImage(noRationButtonImageDown)
end
noRationButton.OnClick = function(self)
    -- TODO add sound
    pointerHand:SetImage(pointerHandButtonImage1)
    local RationController = require("objects.Controllers.RationController")
    RationController:setRationLevel("NoRations")
end
noRationButton.OnMouseExit = function(self)
    self:SetImage(noRationButtonImage)
end

local halfRationButtonImage = love.graphics.newImage("assets/ui/half_ration.png")
local halfRationButtonImageHover = love.graphics.newImage("assets/ui/half_ration_hover.png")
local halfRationButtonImageDown = love.graphics.newImage("assets/ui/half_ration_down.png")
local frHalfRation = {
    x = framesActionBar["frFull"].x + 536 * scale,
    y = framesActionBar["frFull"].y + 123 * scale,
    width = halfRationButtonImage:getWidth() * scale,
    height = halfRationButtonImage:getHeight() * scale
}
local halfRationButton = loveframes.Create("image")
halfRationButton:SetState(states.STATE_GRANARY)
halfRationButton:setTooltip(SID.rations.half.name, SID.rations.half.description)
halfRationButton:SetImage(halfRationButtonImage)
halfRationButton:SetScaleX(frHalfRation.width / halfRationButton:GetImageWidth())
halfRationButton:SetScaleY(halfRationButton:GetScaleX())
halfRationButton:SetPos(frHalfRation.x, frHalfRation.y)
halfRationButton.OnMouseEnter = function(self)
    self:SetImage(halfRationButtonImageHover)
end
halfRationButton.OnMouseDown = function(self)
    self:SetImage(halfRationButtonImageDown)
end
halfRationButton.OnClick = function(self)
    -- TODO add sound
    pointerHand:SetImage(pointerHandButtonImage2)
    local RationController = require("objects.Controllers.RationController")
    RationController:setRationLevel("SmallRations")
end
halfRationButton.OnMouseExit = function(self)
    self:SetImage(halfRationButtonImage)
end

local fullRationButtonImage = love.graphics.newImage("assets/ui/full_ration.png")
local fullRationButtonImageHover = love.graphics.newImage("assets/ui/full_ration_hover.png")
local fullRationButtonImageDown = love.graphics.newImage("assets/ui/full_ration_down.png")
local frFullRation = {
    x = framesActionBar["frFull"].x + 590 * scale,
    y = framesActionBar["frFull"].y + 116 * scale,
    width = fullRationButtonImage:getWidth() * scale,
    height = fullRationButtonImage:getHeight() * scale
}
local fullRationButton = loveframes.Create("image")
fullRationButton:SetState(states.STATE_GRANARY)
fullRationButton:setTooltip(SID.rations.full.name, SID.rations.full.description)
fullRationButton:SetImage(fullRationButtonImage)
fullRationButton:SetScaleX(frFullRation.width / fullRationButton:GetImageWidth())
fullRationButton:SetScaleY(fullRationButton:GetScaleX())
fullRationButton:SetPos(frFullRation.x, frFullRation.y)
fullRationButton.OnMouseEnter = function(self)
    self:SetImage(fullRationButtonImageHover)
end
fullRationButton.OnMouseDown = function(self)
    self:SetImage(fullRationButtonImageDown)
end
fullRationButton.OnClick = function(self)
    -- TODO add sound
    pointerHand:SetImage(pointerHandButtonImage3)
    local RationController = require("objects.Controllers.RationController")
    RationController:setRationLevel("NormalRations")
end
fullRationButton.OnMouseExit = function(self)
    self:SetImage(fullRationButtonImage)
end

local extraRationButtonImage = love.graphics.newImage("assets/ui/extra_ration.png")
local extraRationButtonImageHover = love.graphics.newImage("assets/ui/extra_ration_hover.png")
local extraRationButtonImageDown = love.graphics.newImage("assets/ui/extra_ration_down.png")
local frExtraRation = {
    x = framesActionBar["frFull"].x + 650 * scale,
    y = framesActionBar["frFull"].y + 122 * scale,
    width = extraRationButtonImage:getWidth() * scale,
    height = extraRationButtonImage:getHeight() * scale
}
local extraRationButton = loveframes.Create("image")
extraRationButton:SetState(states.STATE_GRANARY)
extraRationButton:setTooltip(SID.rations.extra.name, SID.rations.extra.description)
extraRationButton:SetImage(extraRationButtonImage)
extraRationButton:SetScaleX(frExtraRation.width / extraRationButton:GetImageWidth())
extraRationButton:SetScaleY(extraRationButton:GetScaleX())
extraRationButton:SetPos(frExtraRation.x, frExtraRation.y)
extraRationButton.OnMouseEnter = function(self)
    self:SetImage(extraRationButtonImageHover)
end
extraRationButton.OnMouseDown = function(self)
    self:SetImage(extraRationButtonImageDown)
end
extraRationButton.OnClick = function(self)
    -- TODO add sound
    pointerHand:SetImage(pointerHandButtonImage4)
    local RationController = require("objects.Controllers.RationController")
    RationController:setRationLevel("ExtraRations")
end
extraRationButton.OnMouseExit = function(self)
    self:SetImage(extraRationButtonImage)
end

local doubleRationButtonImage = love.graphics.newImage("assets/ui/double_ration.png")
local doubleRationButtonImageHover = love.graphics.newImage("assets/ui/double_ration_hover.png")
local doubleRationButtonImageDown = love.graphics.newImage("assets/ui/double_ration_down.png")
local frDoubleRation = {
    x = framesActionBar["frFull"].x + 698 * scale,
    y = framesActionBar["frFull"].y + 139 * scale,
    width = doubleRationButtonImage:getWidth() * scale,
    height = doubleRationButtonImage:getHeight() * scale
}
local doubleRationButton = loveframes.Create("image")
doubleRationButton:SetState(states.STATE_GRANARY)
doubleRationButton:setTooltip(SID.rations.double.name, SID.rations.double.description)
doubleRationButton:SetImage(doubleRationButtonImage)
doubleRationButton:SetScaleX(frDoubleRation.width / doubleRationButton:GetImageWidth())
doubleRationButton:SetScaleY(doubleRationButton:GetScaleX())
doubleRationButton:SetPos(frDoubleRation.x, frDoubleRation.y)
doubleRationButton.OnMouseEnter = function(self)
    self:SetImage(doubleRationButtonImageHover)
end
doubleRationButton.OnMouseDown = function(self)
    self:SetImage(doubleRationButtonImageDown)
end
doubleRationButton.OnClick = function(self)
    -- TODO add sound
    pointerHand:SetImage(pointerHandButtonImage5)
    local RationController = require("objects.Controllers.RationController")
    RationController:setRationLevel("LargeRations")
end
doubleRationButton.OnMouseExit = function(self)
    self:SetImage(doubleRationButtonImage)
end

return { MoodImage, moodFoodGui }
