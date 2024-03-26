local loveframes = require("libraries.loveframes")
local states = require("states.ui.states")
local framesActionBar = require("states.ui.action_bar_frames")
local actionBar = require("states.ui.ActionBar")
local scale = actionBar.element.scalex
local SID = require("objects.Controllers.LanguageController").lines

local group = {}

local ActionBarButton = require("states.ui.ActionBarButton")
local backButton = ActionBarButton:new(love.graphics.newImage("assets/ui/back_ab.png"), states.STATE_INN, 12)
backButton:setOnClick(function(self)
    actionBar:switchMode()
    actionBar.chosenInn = nil
end)
actionBar:registerGroup("inn", { backButton })

local numberOfJugsText = loveframes.Create("text")
numberOfJugsText:SetState(states.STATE_INN)
numberOfJugsText:SetFont(loveframes.font_times_new_normal_large)
numberOfJugsText:SetPos(framesActionBar.frFull.x + 316 * scale, framesActionBar.frFull.y + 114 * scale)
numberOfJugsText:SetShadow(false)

local aleCoverageText = loveframes.Create("text")
aleCoverageText:SetState(states.STATE_INN)
aleCoverageText:SetFont(loveframes.font_times_new_normal_large)
aleCoverageText:SetPos(numberOfJugsText.x + numberOfJugsText:GetWidth() + (50 * scale), framesActionBar.frFull.y + 114 * scale)
aleCoverageText:SetShadow(false)

local moodNeutralImage = love.graphics.newImage("assets/ui/keep/mood_neutral.png")
local moodPositiveImage = love.graphics.newImage("assets/ui/keep/mood_positive.png")

local moodImage = loveframes.Create("image")
moodImage:SetState(states.STATE_INN)
moodImage:SetImage(moodNeutralImage)
moodImage:SetScaleX(scale)
moodImage:SetScaleY(moodImage:GetScaleX())
moodImage:SetPos(aleCoverageText.x + aleCoverageText:GetWidth() + (20 * scale), framesActionBar.frFull.y + 114 * scale)

local moodBonusText = loveframes.Create("text")
moodBonusText:SetState(states.STATE_INN)
moodBonusText:SetFont(loveframes.font_immortal_large)
moodBonusText:SetPos(moodImage.x + (moodImage:GetWidth() * scale), framesActionBar.frFull.y + 114 * scale)
moodBonusText:SetShadowColor(0, 0, 0, 1)
moodBonusText:SetShadow(true)

local nextBonusText = loveframes.Create("text")
nextBonusText:SetState(states.STATE_INN)
nextBonusText:SetFont(loveframes.font_times_new_normal_large)
nextBonusText:SetPos(framesActionBar.frFull.x + 316 * scale, framesActionBar.frFull.y + 154 * scale)
nextBonusText:SetShadow(false)

function actionBar:setChosenInn(inn)
    actionBar.chosenInn = inn

    numberOfJugsText:SetText({ {
        color = { 0, 0, 0, 1 }
    },  string.format(SID.popularityText.aleInInn, actionBar.chosenInn.jugsOfAle) })
    aleCoverageText:SetPos(numberOfJugsText.x + numberOfJugsText:GetWidth() + (50 * scale), framesActionBar.frFull.y + 114 * scale)
    moodImage:SetPos(aleCoverageText.x + aleCoverageText:GetWidth() + (20 * scale), framesActionBar.frFull.y + 114 * scale)
    moodBonusText:SetPos(moodImage.x + (moodImage:GetWidth() * scale), framesActionBar.frFull.y + 114 * scale)
end

function actionBar:updateAleCoverage(coverage, bonus)
    if actionBar.chosenInn then
        numberOfJugsText:SetText({ {
            color = { 0, 0, 0, 1 }
        }, string.format(SID.popularityText.aleInInn, actionBar.chosenInn.jugsOfAle) })
    end
    
    aleCoverageText:SetText({ {
        color = { 0, 0, 0, 1 }
    }, string.format(SID.popularityText.aleCoverage .. ": %d%%", math.floor(coverage)) })

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
    aleCoverageText:SetPos(numberOfJugsText.x + numberOfJugsText:GetWidth() + (50 * scale), framesActionBar.frFull.y + 114 * scale)
    moodImage:SetPos(aleCoverageText.x + aleCoverageText:GetWidth() + (20 * scale), framesActionBar.frFull.y + 114 * scale)
    moodBonusText:SetPos(moodImage.x + (moodImage:GetWidth() * scale), framesActionBar.frFull.y + 114 * scale)

    local nextBonusLevel = (bonus + 1) * 25
    if nextBonusLevel <= 100 then
        nextBonusText:SetText({ {
            color = { 0, 0, 0, 1 }
        }, string.format(SID.popularityText.nextAleBonus, nextBonusLevel) })
    else
        nextBonusText:SetText({ {
            color = { 0, 0, 0, 1 }
        }, SID.popularityText.maximumAleBonus })
    end
end

return group
