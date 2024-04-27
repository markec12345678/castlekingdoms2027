local loveframes = require("libraries.loveframes")
local states = require("states.ui.states")
local framesActionBar = require("states.ui.action_bar_frames")
local actionBar = require("states.ui.ActionBar")
local scale = actionBar.element.scalex
local SID = require("objects.Controllers.LanguageController").lines

local group = {}

local ActionBarButton = require("states.ui.ActionBarButton")
local backButton = ActionBarButton:new(love.graphics.newImage("assets/ui/back_ab.png"), states.STATE_RELIGION, 12)
backButton:setOnClick(function(self)
    actionBar:switchMode()
end)
actionBar:registerGroup("religion", { backButton })

local blessingCoverageText = loveframes.Create("text")
blessingCoverageText:SetState(states.STATE_RELIGION)
blessingCoverageText:SetFont(loveframes.font_times_new_normal_large)
blessingCoverageText:SetPos(framesActionBar.frFull.x + 316 * scale, framesActionBar.frFull.y + 114 * scale)
blessingCoverageText:SetShadow(false)

local moodNeutralImage = love.graphics.newImage("assets/ui/keep/mood_neutral.png")
local moodPositiveImage = love.graphics.newImage("assets/ui/keep/mood_positive.png")

local moodImage = loveframes.Create("image")
moodImage:SetState(states.STATE_RELIGION)
moodImage:SetImage(moodNeutralImage)
moodImage:SetScaleX(scale)
moodImage:SetScaleY(moodImage:GetScaleX())
moodImage:SetPos(blessingCoverageText.x + blessingCoverageText:GetWidth() + (20 * scale), framesActionBar.frFull.y + 114 * scale)

local moodBonusText = loveframes.Create("text")
moodBonusText:SetState(states.STATE_RELIGION)
moodBonusText:SetFont(loveframes.font_immortal_large)
moodBonusText:SetPos(moodImage.x + (moodImage:GetWidth() * scale), framesActionBar.frFull.y + 114 * scale)
moodBonusText:SetShadowColor(0, 0, 0, 1)
moodBonusText:SetShadow(true)

local nextBonusText = loveframes.Create("text")
nextBonusText:SetState(states.STATE_RELIGION)
nextBonusText:SetFont(loveframes.font_times_new_normal_large)
nextBonusText:SetPos(framesActionBar.frFull.x + 316 * scale, framesActionBar.frFull.y + 154 * scale)
nextBonusText:SetShadow(false)

local monkIcon = love.graphics.newImage("assets/ui/guilds/monk_icon.png")
local monkIconHover = love.graphics.newImage("assets/ui/guilds/monk_icon_hover.png")

local goldIcon = loveframes.Create("image")
local currentCost = loveframes.Create("text")
local currentStockPeasants = loveframes.Create("text")
local currentName = loveframes.Create("text")

local frMonkButton = {
    x = moodImage.x + moodImage:GetWidth() + (20 * scale),
    y = framesActionBar.frFull.y + 95 * scale,
    width = monkIcon:getWidth() * scale,
    height = monkIcon:getHeight() * scale
}

local monkIconButton = loveframes.Create("image")
monkIconButton:SetState(states.STATE_RELIGION)
monkIconButton:SetImage(monkIcon)
monkIconButton:SetScaleX(frMonkButton.width / monkIconButton:GetImageWidth())
monkIconButton:SetScaleY(monkIconButton:GetScaleX())
monkIconButton:SetPos(frMonkButton.x, frMonkButton.y)

monkIconButton.OnMouseEnter = function(self)
        monkIconButton:SetImage(monkIconHover)
        currentCost:SetText({ {
            color = { 0.99, 0.96, 0.78, 1 }
        }, "12 gold" })
        currentName:SetText({ {
            color = { 0.99, 0.96, 0.78, 1 }
        }, "Monk" })
end

monkIconButton.OnClick = function(self)
    _G.JobController:makeSoldier("Monk")
end

monkIconButton.OnMouseExit = function(self)
        monkIconButton:SetImage(monkIcon)
        currentCost:SetText({ {
            color = { 0.99, 0.96, 0.78, 1 }
        }, "" })
        currentName:SetText({ {
            color = { 0.99, 0.96, 0.78, 1 }
        }, "" })
end

function actionBar:showCathedralOptions(show)
    monkIconButton:SetVisible(show)
end

function actionBar:updateBlessingCoverage(coverage, bonus)
    blessingCoverageText:SetText({ {
        color = { 0, 0, 0, 1 }
    }, string.format(SID.popularityText.blessingCoverage .. ": %d%%", math.floor(coverage)) })

    if bonus > 0 then
        moodImage:SetImage(moodPositiveImage)
        moodBonusText:SetText({ {
            color = { 130 / 255, 220 / 255, 123 / 255, 1 }
        },  bonus })
    else
        moodImage:SetImage(moodNeutralImage)
        moodBonusText:SetText({ {
            color = { 0, 0, 0, 1 }
        },  bonus })
    end
    moodImage:SetPos(blessingCoverageText.x + blessingCoverageText:GetWidth() + (20 * scale), framesActionBar.frFull.y + 114 * scale)
    moodBonusText:SetPos(moodImage.x + (moodImage:GetWidth() * scale), framesActionBar.frFull.y + 114 * scale)
    monkIconButton:SetPos(moodBonusText.x + moodBonusText:GetWidth() + (20 * scale), framesActionBar.frFull.y + 95 * scale)

    local nextBonusLevel = (bonus + 1) * 25
    if nextBonusLevel <= 100 then
        nextBonusText:SetText({ {
            color = { 0, 0, 0, 1 }
        }, string.format(SID.popularityText.nextBlessingBonus, nextBonusLevel) })
    else
        nextBonusText:SetText({ {
            color = { 0, 0, 0, 1 }
        }, SID.popularityText.maximumBlessingBonus })
    end
end

return group
