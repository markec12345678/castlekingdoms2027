local loveframes = require("libraries.loveframes")
local states = require("states.ui.states")
local framesActionBar = require("states.ui.action_bar_frames")
local actionBar = require("states.ui.ActionBar")
local scale = actionBar.element.scalex

local group = {}

local ActionBarButton = require("states.ui.ActionBarButton")
local backButton = ActionBarButton:new(love.graphics.newImage("assets/ui/back_ab.png"), states.STATE_KEEP_TAX, 12)
backButton:setOnClick(function(self)
    actionBar:switchMode()
end)
actionBar:registerGroup("keep_tax", {backButton})

local emptyImage = love.graphics.newImage("assets/ui/keep/empty_tax_button.png")
local pointerImage = love.graphics.newImage("assets/ui/keep/pointer_keep.png")
local leftButtonImage = love.graphics.newImage("assets/ui/keep/left_keep_button.png")
local leftButtonImageHover = love.graphics.newImage("assets/ui/keep/left_keep_button_hover.png")
local rightButtonImage = love.graphics.newImage("assets/ui/keep/right_keep_button.png")
local rightButtonImageHover = love.graphics.newImage("assets/ui/keep/right_keep_button_hover.png")

local moodNeutralImage = love.graphics.newImage("assets/ui/keep/mood_neutral.png")
local moodNegativeImage = love.graphics.newImage("assets/ui/keep/mood_negative.png")
local moodPositiveImage = love.graphics.newImage("assets/ui/keep/mood_positive.png")
local TaxController = require("objects.Controllers.TaxController")
TaxController.taxText = "No Tax";
local currentOption = 4;

local PointerPositions = {}
-- TEXT                    MOOD   GOLD
-- "Generous Bribe"        +7     -1.0
-- "Large Bribe"           +5     -0.8
-- "Small Bribe"           +3     -0.6
-- "No Taxes"               0      0
-- "Low Taxes"             -2      0.6
-- "Average Taxes"         -4      0.8
-- "High Taxes"            -6      1.0
-- "Mean Taxes"            -8      1.2
-- "Extortionate Taxes"    -12     1.4
-- "Downright Cruel Taxes" -16     1.6

local frLeftButton = {
    x = framesActionBar.frFull.x + 410 * scale,
    y = framesActionBar.frFull.y + 115 * scale,
    width = leftButtonImage:getWidth() * scale,
    height = leftButtonImage:getHeight() * scale
}
local frDynamicPosition = {
    {
        x = framesActionBar.frFull.x + 436 * scale,
        y = framesActionBar.frFull.y + 115 * scale,
        width = emptyImage:getWidth() * scale,
        height = emptyImage:getHeight() * scale
    },
    {
        x = framesActionBar.frFull.x + 463 * scale,
        y = framesActionBar.frFull.y + 115 * scale,
        width = emptyImage:getWidth() * scale,
        height = emptyImage:getHeight() * scale
    },
    {
        x = framesActionBar.frFull.x + 491 * scale,
        y = framesActionBar.frFull.y + 115 * scale,
        width = emptyImage:getWidth() * scale,
        height = emptyImage:getHeight() * scale
    },
    {
        x = framesActionBar.frFull.x + 517 * scale,
        y = framesActionBar.frFull.y + 115 * scale,
        width = emptyImage:getWidth() * scale,
        height = emptyImage:getHeight() * scale
    },
    {
        x = framesActionBar.frFull.x + 545 * scale,
        y = framesActionBar.frFull.y + 115 * scale,
        width = emptyImage:getWidth() * scale,
        height = emptyImage:getHeight() * scale
    },
    {
        x = framesActionBar.frFull.x + 572 * scale,
        y = framesActionBar.frFull.y + 115 * scale,
        width = emptyImage:getWidth() * scale,
        height = emptyImage:getHeight() * scale
    },
    {
        x = framesActionBar.frFull.x + 599 * scale,
        y = framesActionBar.frFull.y + 115 * scale,
        width = emptyImage:getWidth() * scale,
        height = emptyImage:getHeight() * scale
    },
    {
        x = framesActionBar.frFull.x + 626 * scale,
        y = framesActionBar.frFull.y + 115 * scale,
        width = emptyImage:getWidth() * scale,
        height = emptyImage:getHeight() * scale
    },
    {
        x = framesActionBar.frFull.x + 653 * scale,
        y = framesActionBar.frFull.y + 115 * scale,
        width = emptyImage:getWidth() * scale,
        height = emptyImage:getHeight() * scale
    },
    {
        x = framesActionBar.frFull.x + 679 * scale,
        y = framesActionBar.frFull.y + 115 * scale,
        width = emptyImage:getWidth() * scale,
        height = emptyImage:getHeight() * scale
    }
}
local frPointer = {
    x = framesActionBar.frFull.x + 517 * scale,
    y = framesActionBar.frFull.y + 109 * scale,
    width = pointerImage:getWidth() * scale,
    height = pointerImage:getHeight() * scale
}
local frRightButton = {
    x = framesActionBar.frFull.x + 705 * scale,
    y = framesActionBar.frFull.y + 115 * scale,
    width = rightButtonImage:getWidth() * scale,
    height = rightButtonImage:getHeight() * scale
}
local frText = {
    x = framesActionBar.frFull.x + 360 * scale,
    y = framesActionBar.frFull.y + 118 * scale,
    width = 50 * scale,
    height = 20 * scale
}
local frTextRight = {
    x = framesActionBar.frFull.x + 740 * scale,
    y = frText.y,
    width = 160 * scale,
    height = 20 * scale
}
local frMood = {
    x = frText.x - moodNeutralImage:getWidth() * 1.1 * scale,
    y = frText.y,
    width = moodNeutralImage:getWidth() * scale,
    height = moodNeutralImage:getHeight() * scale
}
local frPopulation = {
    x = framesActionBar.frFull.x + 495 * scale,
    y = framesActionBar.frFull.y + 155 * scale,
    width = 50 * scale,
    height = 20 * scale
}
local frGold = {
    x = framesActionBar.frFull.x + 625 * scale,
    y = framesActionBar.frFull.y + 155 * scale,
    width = 50 * scale,
    height = 20 * scale
}
local taxTextGui = loveframes.Create("text")
taxTextGui:SetState(states.STATE_KEEP_TAX)
taxTextGui:SetFont(loveframes.font_immortal_large)
taxTextGui:SetPos(frText.x, frText.y)
taxTextGui:SetText({{
    color = {0, 0, 0, 1}
}, "0"})
taxTextGui:SetShadowColor(0, 0, 0, 1)
taxTextGui:SetShadow(true)

local taxTextGuiRight = loveframes.Create("text")
taxTextGuiRight:SetState(states.STATE_KEEP_TAX)
taxTextGuiRight:SetFont(loveframes.font_immortal_large)
taxTextGuiRight:SetPos(frTextRight.x, frTextRight.y)
taxTextGuiRight:SetText({{
    color = {0, 0, 0, 1}
}, TaxController.taxText})
taxTextGuiRight:SetMaxWidth(frTextRight.width)
taxTextGuiRight:SetShadowColor(0.8, 0.8, 0.8, 1)
taxTextGuiRight:SetShadow(true)
group["tax"] = taxTextGuiRight

local populationText = loveframes.Create("text")
populationText:SetState(states.STATE_KEEP_TAX)
populationText:SetFont(loveframes.font_immortal_large)
populationText:SetPos(frPopulation.x, frPopulation.y)
populationText:SetText("")
populationText:SetShadowColor(0.8, 0.8, 0.8, 1)
populationText:SetShadow(true)
group["population"] = populationText

local goldText = loveframes.Create("text")
goldText:SetState(states.STATE_KEEP_TAX)
goldText:SetFont(loveframes.font_immortal_large)
goldText:SetPos(frGold.x, frGold.y)
goldText:SetText({{
    color = {0, 0, 0, 1}
}, "0"})
goldText:SetShadowColor(0.8, 0.8, 0.8, 1)
goldText:SetShadow(true)
group["gold"] = goldText

local MoodImage = loveframes.Create("image")
MoodImage:SetState(states.STATE_KEEP_TAX)
MoodImage:SetImage(moodNeutralImage)
MoodImage:SetScaleX(frMood.width / MoodImage:GetImageWidth())
MoodImage:SetScaleY(MoodImage:GetScaleX())
MoodImage:SetPos(frMood.x, frMood.y)

local Pointer = loveframes.Create("image")
Pointer:SetState(states.STATE_KEEP_TAX)
Pointer:SetImage(pointerImage)
Pointer:SetScaleX(frPointer.width / Pointer:GetImageWidth())
Pointer:SetScaleY(Pointer:GetScaleX())
Pointer:SetPos(frDynamicPosition[4].x + 8 * scale, frPointer.y)

local taxMapping = {
    "Generous Bribe",
    "Large Bribe",
    "Small Bribe",
    "No Taxes",
    "Low Taxes",
    "Average Taxes",
    "High Taxes",
    "Mean Taxes",
    "Extortionate Taxes",
    "Downright Cruel Taxes",
}
local moodMapping = {
    7,
    5,
    3,
    0,
    -2,
    -4,
    -6,
    -8,
    -12,
    -16,
}
local goldFactorMapping = {
    -1.0,
    -0.8,
    -0.6,
    0,
    0.6,
    0.8,
    1.0,
    1.2,
    1.4,
    1.6,
}
local moodImageMapping = {
    moodPositiveImage,
    moodPositiveImage,
    moodPositiveImage,
    moodNeutralImage,
    moodNegativeImage,
    moodNegativeImage,
    moodNegativeImage,
    moodNegativeImage,
    moodNegativeImage,
    moodNegativeImage,
}
local function SetTax(option)
    local color = {0, 0, 0, 1}

    TaxController.taxText = taxMapping[option]
    local moodText = moodMapping[option]
    if moodText < 0 then
        color = {200 / 255, 90 / 255, 90 / 255, 1}
    elseif moodText > 0 then
        color = {130 / 255, 220 / 255, 123 / 255, 1}
    end
    local moodImage = moodImageMapping[option]
    _G.TaxController:setTaxLevel(TaxController.taxText)
    _G.TaxController.goldFactor = goldFactorMapping[option]
    _G.TaxController.taxOption = option
    Pointer:SetPos(frDynamicPosition[option].x + 8 * scale, frPointer.y)
    MoodImage:SetImage(moodImage)
    taxTextGui:SetText({{
        color = color
    }, moodText})
    taxTextGuiRight:SetText({{
        color = {0, 0, 0, 1}
    }, TaxController.taxText})
    populationText:SetText({{
        color = {0, 0, 0, 1}
    }, _G.state.population})
    goldText:SetText({{
        color = {0, 0, 0, 1}
    }, math.round(_G.state.population * TaxController.goldFactor, 0)})
    currentOption = option
    if option < 4 and _G.state.gold < (math.round(_G.state.population * TaxController.goldFactor, 0) * -1) then
        SetTax(4)
        currentOption = 4
    end
end

group["SetTax"] = SetTax

local LeftButton = loveframes.Create("image")
LeftButton:SetState(states.STATE_KEEP_TAX)
LeftButton:SetImage(leftButtonImage)
LeftButton:SetScaleX(frLeftButton.width / LeftButton:GetImageWidth())
LeftButton:SetScaleY(LeftButton:GetScaleX())
LeftButton:SetPos(frLeftButton.x, frLeftButton.y)

LeftButton.OnClick = function(self)
    if (currentOption ~= 1) then
        PointerPositions[currentOption - 1]:OnClick()
    end
end
LeftButton.OnMouseEnter = function(self)
    self:SetImage(leftButtonImageHover)
end
LeftButton.OnMouseExit = function(self)
    self:SetImage(leftButtonImage)
end

local RightButton = loveframes.Create("image")
RightButton:SetState(states.STATE_KEEP_TAX)
RightButton:SetImage(rightButtonImage)
RightButton:SetScaleX(frRightButton.width / RightButton:GetImageWidth())
RightButton:SetScaleY(RightButton:GetScaleX())
RightButton:SetPos(frRightButton.x, frRightButton.y)

RightButton.OnClick = function(self)
    if (currentOption ~= 10) then
        PointerPositions[currentOption + 1]:OnClick()
    end
end
RightButton.OnMouseEnter = function(self)
    self:SetImage(rightButtonImageHover)
end
RightButton.OnMouseExit = function(self)
    self:SetImage(rightButtonImage)
    -- Pointer:SetPos(frPositive3.x-15, frPointer.y)
end

for i, v in ipairs(frDynamicPosition) do
    local PointerInstance = loveframes.Create("image")
    PointerInstance:SetState(states.STATE_KEEP_TAX)
    PointerInstance:SetImage(emptyImage)
    PointerInstance:SetScaleX(v.width / PointerInstance:GetImageWidth())
    PointerInstance:SetScaleY(PointerInstance:GetScaleX())
    PointerInstance:SetPos(v.x, v.y)
    PointerInstance.OnClick = function(self)
        Pointer:SetPos(v.x + 8 * scale, frPointer.y)
        SetTax(i)
    end
    PointerPositions[i] = PointerInstance
end



return group
