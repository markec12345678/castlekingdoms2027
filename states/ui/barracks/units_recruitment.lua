--                    BARRACKS UI

-- Knights are unfinished, waiting for stables and horses

local loveframes = require("libraries.loveframes")
local states = require("states.ui.states")
local framesActionBar = require("states.ui.action_bar_frames")
local actionBar = require("states.ui.ActionBar")
local scale = actionBar.element.scalex
local WEAPON = require("objects.Enums.Weapon")
local SID = require("objects.Controllers.LanguageController").lines

local group = {}

local ActionBarButton = require("states.ui.ActionBarButton")
local backButton = ActionBarButton:new(love.graphics.newImage("assets/ui/back_ab.png"), states.STATE_BARRACKS, 12)
backButton:setOnClick(function(self)
    actionBar:switchMode()
end)
actionBar:registerGroup("barracks", { backButton })

local archerIconAvailable = love.graphics.newImage("assets/ui/barracks/archerIconAvailable.png")
local archerIconNotAvailable = love.graphics.newImage("assets/ui/barracks/archerIconNotAvailable.png")
local spearmanIconAvailable = love.graphics.newImage("assets/ui/barracks/spearmanIconAvailable.png")
local spearmanIconNotAvailable = love.graphics.newImage("assets/ui/barracks/spearmanIconNotAvailable.png")
local macemanIconAvailable = love.graphics.newImage("assets/ui/barracks/macemanIconAvailable.png")
local macemanIconNotAvailable = love.graphics.newImage("assets/ui/barracks/macemanIconNotAvailable.png")
local crossbowmanIconAvailable = love.graphics.newImage("assets/ui/barracks/crossbowmanIconAvailable.png")
local crossbowmanIconNotAvailable = love.graphics.newImage("assets/ui/barracks/crossbowmanIconNotAvailable.png")
local pikemanIconAvailable = love.graphics.newImage("assets/ui/barracks/pikemanIconAvailable.png")
local pikemanIconNotAvailable = love.graphics.newImage("assets/ui/barracks/pikemanIconNotAvailable.png")
local swordsmanIconAvailable = love.graphics.newImage("assets/ui/barracks/swordsmanIconAvailable.png")
local swordsmanIconNotAvailable = love.graphics.newImage("assets/ui/barracks/swordsmanIconNotAvailable.png")
local knightIconAvailable = love.graphics.newImage("assets/ui/barracks/knightIconAvailable.png")
local knightIconNotAvailable = love.graphics.newImage("assets/ui/barracks/knightIconNotAvailable.png")
local bowIconNormal = love.graphics.newImage("assets/ui/barracks/bowIconNormal.png")
local bowIconAvailable = love.graphics.newImage("assets/ui/barracks/bowIconAvailable.png")
local spearIconNormal = love.graphics.newImage("assets/ui/barracks/spearIconNormal.png")
local spearIconAvailable = love.graphics.newImage("assets/ui/barracks/spearIconAvailable.png")
local maceIconNormal = love.graphics.newImage("assets/ui/barracks/maceIconNormal.png")
local maceIconAvailable = love.graphics.newImage("assets/ui/barracks/maceIconAvailable.png")
local crossbowIconNormal = love.graphics.newImage("assets/ui/barracks/crossbowIconNormal.png")
local crossbowIconAvailable = love.graphics.newImage("assets/ui/barracks/crossbowIconAvailable.png")
local pikeIconNormal = love.graphics.newImage("assets/ui/barracks/pikeIconNormal.png")
local pikeIconAvailable = love.graphics.newImage("assets/ui/barracks/pikeIconAvailable.png")
local leatherIconNormal = love.graphics.newImage("assets/ui/barracks/leatherIconNormal.png")
local leatherIconAvailable = love.graphics.newImage("assets/ui/barracks/leatherIconAvailable.png")
local swordIconNormal = love.graphics.newImage("assets/ui/barracks/swordIconNormal.png")
local swordIconAvailable = love.graphics.newImage("assets/ui/barracks/swordIconAvailable.png")
local armorIconNormal = love.graphics.newImage("assets/ui/barracks/armorIconNormal.png")
local armorIconAvailable = love.graphics.newImage("assets/ui/barracks/armorIconAvailable.png")
local horseIconNormal = love.graphics.newImage("assets/ui/barracks/horseIconNormal.png")
local horseIconAvailable = love.graphics.newImage("assets/ui/barracks/horseIconAvailable.png")
local goldIconNormal = love.graphics.newImage("assets/ui/barracks/goldIcon.png")
local hoverIconNormal = love.graphics.newImage("assets/ui/barracks/hoverIcon.png")

local frArcherButton = {
    x = framesActionBar.frFull.x + 349 * scale,
    y = framesActionBar.frFull.y + 31 * scale,
    width = archerIconNotAvailable:getWidth() * scale,
    height = archerIconNotAvailable:getHeight() * scale
}
local frSpearmanButton = {
    x = framesActionBar.frFull.x + 416 * scale,
    y = framesActionBar.frFull.y + 31 * scale,
    width = spearmanIconNotAvailable:getWidth() * scale,
    height = spearmanIconNotAvailable:getHeight() * scale
}
local frMacemanButton = {
    x = framesActionBar.frFull.x + 504 * scale,
    y = framesActionBar.frFull.y + 31 * scale,
    width = macemanIconNotAvailable:getWidth() * scale,
    height = macemanIconNotAvailable:getHeight() * scale
}
local frCrossbowmanButton = {
    x = framesActionBar.frFull.x + 588 * scale,
    y = framesActionBar.frFull.y + 31 * scale,
    width = crossbowmanIconNotAvailable:getWidth() * scale,
    height = crossbowmanIconNotAvailable:getHeight() * scale
}
local frPikemanButton = {
    x = framesActionBar.frFull.x + 660 * scale,
    y = framesActionBar.frFull.y + 31 * scale,
    width = pikemanIconNotAvailable:getWidth() * scale,
    height = pikemanIconNotAvailable:getHeight() * scale
}
local frSwordsmanButton = {
    x = framesActionBar.frFull.x + 732 * scale,
    y = framesActionBar.frFull.y + 31 * scale,
    width = swordsmanIconNotAvailable:getWidth() * scale,
    height = swordsmanIconNotAvailable:getHeight() * scale
}
local frKnightButton = {
    x = framesActionBar.frFull.x + 806 * scale,
    y = framesActionBar.frFull.y + 31 * scale,
    width = knightIconNotAvailable:getWidth() * scale,
    height = knightIconNotAvailable:getHeight() * scale
}

local frBowButton = {
    x = framesActionBar.frFull.x + 344 * scale,
    y = framesActionBar.frFull.y + 144 * scale,
    width = bowIconNormal:getWidth() * scale,
    height = bowIconNormal:getHeight() * scale
}
local frSpearButton = {
    x = framesActionBar.frFull.x + 404 * scale,
    y = framesActionBar.frFull.y + 144 * scale,
    width = spearIconNormal:getWidth() * scale,
    height = spearIconNormal:getHeight() * scale
}
local frSwordButton = {
    x = framesActionBar.frFull.x + 463 * scale,
    y = framesActionBar.frFull.y + 144 * scale,
    width = swordIconNormal:getWidth() * scale,
    height = swordIconNormal:getHeight() * scale
}
local frCrossbowButton = {
    x = framesActionBar.frFull.x + 525 * scale,
    y = framesActionBar.frFull.y + 144 * scale,
    width = crossbowIconNormal:getWidth() * scale,
    height = crossbowIconNormal:getHeight() * scale
}
local frPikeButton = {
    x = framesActionBar.frFull.x + 582 * scale,
    y = framesActionBar.frFull.y + 144 * scale,
    width = pikeIconNormal:getWidth() * scale,
    height = pikeIconNormal:getHeight() * scale
}
local frMaceButton = {
    x = framesActionBar.frFull.x + 642 * scale,
    y = framesActionBar.frFull.y + 144 * scale,
    width = maceIconNormal:getWidth() * scale,
    height = maceIconNormal:getHeight() * scale
}
local frLeatherButton = {
    x = framesActionBar.frFull.x + 704 * scale,
    y = framesActionBar.frFull.y + 144 * scale,
    width = leatherIconNormal:getWidth() * scale,
    height = leatherIconNormal:getHeight() * scale
}
local frArmorButton = {
    x = framesActionBar.frFull.x + 762 * scale,
    y = framesActionBar.frFull.y + 144 * scale,
    width = armorIconNormal:getWidth() * scale,
    height = armorIconNormal:getHeight() * scale
}
local frHorseButton = {
    x = framesActionBar.frFull.x + 821 * scale,
    y = framesActionBar.frFull.y + 144 * scale,
    width = horseIconNormal:getWidth() * scale,
    height = horseIconNormal:getHeight() * scale
}

local frGoldIcon = {
    x = framesActionBar.frFull.x + 358 * scale,
    y = framesActionBar.frFull.y + 16 * scale,
    width = goldIconNormal:getWidth() * scale,
    height = goldIconNormal:getHeight() * scale
}

local bowIconButton = loveframes.Create("image")
bowIconButton:SetState(states.STATE_BARRACKS)
bowIconButton:SetImage(bowIconNormal)
bowIconButton:SetScaleX(frBowButton.width / bowIconButton:GetImageWidth())
bowIconButton:SetScaleY(bowIconButton:GetScaleX())
bowIconButton:SetPos(frBowButton.x, frBowButton.y)

local spearIconButton = loveframes.Create("image")
spearIconButton:SetState(states.STATE_BARRACKS)
spearIconButton:SetImage(spearIconNormal)
spearIconButton:SetScaleX(frSpearButton.width / spearIconButton:GetImageWidth())
spearIconButton:SetScaleY(spearIconButton:GetScaleX())
spearIconButton:SetPos(frSpearButton.x, frSpearButton.y)

local maceIconButton = loveframes.Create("image")
maceIconButton:SetState(states.STATE_BARRACKS)
maceIconButton:SetImage(maceIconNormal)
maceIconButton:SetScaleX(frMaceButton.width / maceIconButton:GetImageWidth())
maceIconButton:SetScaleY(maceIconButton:GetScaleX())
maceIconButton:SetPos(frMaceButton.x, frMaceButton.y)

local leatherIconButton = loveframes.Create("image")
leatherIconButton:SetState(states.STATE_BARRACKS)
leatherIconButton:SetImage(leatherIconNormal)
leatherIconButton:SetScaleX(frLeatherButton.width / leatherIconButton:GetImageWidth())
leatherIconButton:SetScaleY(leatherIconButton:GetScaleX())
leatherIconButton:SetPos(frLeatherButton.x, frLeatherButton.y)

local crossbowIconButton = loveframes.Create("image")
crossbowIconButton:SetState(states.STATE_BARRACKS)
crossbowIconButton:SetImage(crossbowIconNormal)
crossbowIconButton:SetScaleX(frCrossbowButton.width / crossbowIconButton:GetImageWidth())
crossbowIconButton:SetScaleY(crossbowIconButton:GetScaleX())
crossbowIconButton:SetPos(frCrossbowButton.x, frCrossbowButton.y)

local pikeIconButton = loveframes.Create("image")
pikeIconButton:SetState(states.STATE_BARRACKS)
pikeIconButton:SetImage(pikeIconNormal)
pikeIconButton:SetScaleX(frPikeButton.width / pikeIconButton:GetImageWidth())
pikeIconButton:SetScaleY(pikeIconButton:GetScaleX())
pikeIconButton:SetPos(frPikeButton.x, frPikeButton.y)

local armorIconButton = loveframes.Create("image")
armorIconButton:SetState(states.STATE_BARRACKS)
armorIconButton:SetImage(armorIconNormal)
armorIconButton:SetScaleX(frArmorButton.width / armorIconButton:GetImageWidth())
armorIconButton:SetScaleY(armorIconButton:GetScaleX())
armorIconButton:SetPos(frArmorButton.x, frArmorButton.y)

local swordIconButton = loveframes.Create("image")
swordIconButton:SetState(states.STATE_BARRACKS)
swordIconButton:SetImage(swordIconNormal)
swordIconButton:SetScaleX(frSwordButton.width / swordIconButton:GetImageWidth())
swordIconButton:SetScaleY(swordIconButton:GetScaleX())
swordIconButton:SetPos(frSwordButton.x, frSwordButton.y)

local horseIconButton = loveframes.Create("image")
horseIconButton:SetState(states.STATE_BARRACKS)
horseIconButton:SetImage(horseIconNormal)
horseIconButton:SetScaleX(frHorseButton.width / horseIconButton:GetImageWidth())
horseIconButton:SetScaleY(horseIconButton:GetScaleX())
horseIconButton:SetPos(frHorseButton.x, frHorseButton.y)

local hoverIcon = loveframes.Create("image")
hoverIcon:SetState(states.STATE_BARRACKS)
hoverIcon:SetImage(hoverIconNormal)
hoverIcon:SetScaleX(frBowButton.width / bowIconButton:GetImageWidth())
hoverIcon:SetScaleY(bowIconButton:GetScaleX())
hoverIcon:SetPos(frBowButton.x + 5, frBowButton.y + 5)
hoverIcon:SetVisible(false)

local hoverIcon_2 = loveframes.Create("image")
hoverIcon_2:SetState(states.STATE_BARRACKS)
hoverIcon_2:SetImage(hoverIconNormal)
hoverIcon_2:SetScaleX(frBowButton.width / bowIconButton:GetImageWidth())
hoverIcon_2:SetScaleY(bowIconButton:GetScaleX())
hoverIcon_2:SetPos(frBowButton.x + 5, frBowButton.y + 5)
hoverIcon_2:SetVisible(false)

local hoverIcon_3 = loveframes.Create("image")
hoverIcon_3:SetState(states.STATE_BARRACKS)
hoverIcon_3:SetImage(hoverIconNormal)
hoverIcon_3:SetScaleX(frBowButton.width / bowIconButton:GetImageWidth())
hoverIcon_3:SetScaleY(bowIconButton:GetScaleX())
hoverIcon_3:SetPos(frBowButton.x + 5, frBowButton.y + 5)
hoverIcon_3:SetVisible(false)

local currentStockBow = loveframes.Create("text")
currentStockBow:SetState(states.STATE_BARRACKS)
currentStockBow:SetFont(loveframes.font_times_new_medium)
currentStockBow:SetPos(frBowButton.x + 7, frBowButton.y + 38)
currentStockBow:SetShadow(false)

local currentStockSpear = loveframes.Create("text")
currentStockSpear:SetState(states.STATE_BARRACKS)
currentStockSpear:SetFont(loveframes.font_times_new_medium)
currentStockSpear:SetPos(frSpearButton.x + 7, frSpearButton.y + 38)
currentStockSpear:SetShadow(false)

local currentStockSword = loveframes.Create("text")
currentStockSword:SetState(states.STATE_BARRACKS)
currentStockSword:SetFont(loveframes.font_times_new_medium)
currentStockSword:SetPos(frSwordButton.x + 7, frSwordButton.y + 38)
currentStockSword:SetShadow(false)

local currentStockCrossbow = loveframes.Create("text")
currentStockCrossbow:SetState(states.STATE_BARRACKS)
currentStockCrossbow:SetFont(loveframes.font_times_new_medium)
currentStockCrossbow:SetPos(frCrossbowButton.x + 7, frCrossbowButton.y + 38)
currentStockCrossbow:SetShadow(false)

local currentStockPike = loveframes.Create("text")
currentStockPike:SetState(states.STATE_BARRACKS)
currentStockPike:SetFont(loveframes.font_times_new_medium)
currentStockPike:SetPos(frPikeButton.x + 7, frPikeButton.y + 38)
currentStockPike:SetShadow(false)

local currentStockMace = loveframes.Create("text")
currentStockMace:SetState(states.STATE_BARRACKS)
currentStockMace:SetFont(loveframes.font_times_new_medium)
currentStockMace:SetPos(frMaceButton.x + 7, frMaceButton.y + 38)
currentStockMace:SetShadow(false)

local currentStockLeather = loveframes.Create("text")
currentStockLeather:SetState(states.STATE_BARRACKS)
currentStockLeather:SetFont(loveframes.font_times_new_medium)
currentStockLeather:SetPos(frLeatherButton.x + 7, frLeatherButton.y + 38)
currentStockLeather:SetShadow(false)

local currentStockArmor = loveframes.Create("text")
currentStockArmor:SetState(states.STATE_BARRACKS)
currentStockArmor:SetFont(loveframes.font_times_new_medium)
currentStockArmor:SetPos(frArmorButton.x + 7, frArmorButton.y + 38)
currentStockArmor:SetShadow(false)

local currentStockHorse = loveframes.Create("text")
currentStockHorse:SetState(states.STATE_BARRACKS)
currentStockHorse:SetFont(loveframes.font_times_new_medium)
currentStockHorse:SetPos(frHorseButton.x + 7, frHorseButton.y + 38)
currentStockHorse:SetShadow(false)

local archerIconButton = loveframes.Create("image")
local spearmanIconButton = loveframes.Create("image")
local macemanIconButton = loveframes.Create("image")
local crossbowmanIconButton = loveframes.Create("image")
local pikemanIconButton = loveframes.Create("image")
local swordsmanIconButton = loveframes.Create("image")
local knightIconButton = loveframes.Create("image")
local goldIcon = loveframes.Create("image")
local currentCost = loveframes.Create("text")
local currentStockPeasants = loveframes.Create("text")
local currentName = loveframes.Create("text")

archerIconButton:SetState(states.STATE_BARRACKS)
archerIconButton:SetImage(archerIconNotAvailable)
archerIconButton:SetScaleX(frArcherButton.width / archerIconButton:GetImageWidth())
archerIconButton:SetScaleY(archerIconButton:GetScaleX())
archerIconButton:SetPos(frArcherButton.x, frArcherButton.y)
archerIconButton.OnMouseEnter = function(self)
    hoverIcon:SetPos(frBowButton.x + 5, frBowButton.y + 6)
    hoverIcon:SetVisible(true)
    goldIcon:SetVisible(true)
    currentCost:SetText({ {
        color = { 0.99, 0.96, 0.78, 1 }
    }, "12 " .. SID.gold })
    currentName:SetText({ {
        color = { 0.99, 0.96, 0.78, 1 }
    }, SID.recruitment.archer })
end
archerIconButton.OnMouseDown = function(self)
    hoverIcon:SetPos(frBowButton.x + 5, frBowButton.y + 6)
    hoverIcon:SetVisible(true)
    goldIcon:SetVisible(true)
    currentCost:SetText({ {
        color = { 0.99, 0.96, 0.78, 1 }
    }, "12 " .. SID.gold })
    currentName:SetText({ {
        color = { 0.99, 0.96, 0.78, 1 }
    }, SID.recruitment.archer })
end
archerIconButton.OnClick = function(self)
    -- create archer unit
end
archerIconButton.OnMouseExit = function(self)
    hoverIcon:SetVisible(false)
    goldIcon:SetVisible(false)
    currentCost:SetText({ {
        color = { 0.99, 0.96, 0.78, 1 }
    }, "" })
    currentName:SetText({ {
        color = { 0.99, 0.96, 0.78, 1 }
    }, "" })
end

spearmanIconButton:SetState(states.STATE_BARRACKS)
spearmanIconButton:SetImage(spearmanIconNotAvailable)
spearmanIconButton:SetScaleX(frSpearmanButton.width / spearmanIconButton:GetImageWidth())
spearmanIconButton:SetScaleY(spearmanIconButton:GetScaleX())
spearmanIconButton:SetPos(frSpearmanButton.x, frSpearmanButton.y)
spearmanIconButton.OnMouseEnter = function(self)
    hoverIcon:SetPos(frSpearButton.x + 5, frSpearButton.y + 6)
    hoverIcon:SetVisible(true)
    goldIcon:SetVisible(true)
    currentCost:SetText({ {
        color = { 0.99, 0.96, 0.78, 1 }
    }, "8 " .. SID.gold })
    currentName:SetText({ {
        color = { 0.99, 0.96, 0.78, 1 }
    }, SID.recruitment.spearman })
end
spearmanIconButton.OnMouseDown = function(self)
    hoverIcon:SetPos(frSpearButton.x + 5, frSpearButton.y + 6)
    hoverIcon:SetVisible(true)
    goldIcon:SetVisible(true)
    currentCost:SetText({ {
        color = { 0.99, 0.96, 0.78, 1 }
    }, "8 " .. SID.gold })
    currentName:SetText({ {
        color = { 0.99, 0.96, 0.78, 1 }
    }, SID.recruitment.spearman })
end
spearmanIconButton.OnClick = function(self)
    -- create spearman unit
end
spearmanIconButton.OnMouseExit = function(self)
    hoverIcon:SetVisible(false)
    goldIcon:SetVisible(false)
    currentCost:SetText({ {
        color = { 0.99, 0.96, 0.78, 1 }
    }, "" })
    currentName:SetText({ {
        color = { 0.99, 0.96, 0.78, 1 }
    }, "" })
end

macemanIconButton:SetState(states.STATE_BARRACKS)
macemanIconButton:SetImage(macemanIconNotAvailable)
macemanIconButton:SetScaleX(frMacemanButton.width / macemanIconButton:GetImageWidth())
macemanIconButton:SetScaleY(macemanIconButton:GetScaleX())
macemanIconButton:SetPos(frMacemanButton.x, frMacemanButton.y)
macemanIconButton.OnMouseEnter = function(self)
    hoverIcon:SetPos(frMaceButton.x + 5, frMaceButton.y + 6)
    hoverIcon:SetVisible(true)
    hoverIcon_2:SetPos(frLeatherButton.x, frLeatherButton.y + 6)
    hoverIcon_2:SetVisible(true)
    goldIcon:SetVisible(true)
    currentCost:SetText({ {
        color = { 0.99, 0.96, 0.78, 1 }
    }, "20 " .. SID.gold })
    currentName:SetText({ {
        color = { 0.99, 0.96, 0.78, 1 }
    }, SID.recruitment.maceman })
end
macemanIconButton.OnMouseDown = function(self)
    hoverIcon:SetPos(frMaceButton.x + 5, frMaceButton.y + 6)
    hoverIcon:SetVisible(true)
    hoverIcon_2:SetPos(frLeatherButton.x, frLeatherButton.y + 6)
    hoverIcon_2:SetVisible(true)
    goldIcon:SetVisible(true)
    currentCost:SetText({ {
        color = { 0.99, 0.96, 0.78, 1 }
    }, "20 " .. SID.gold })
    currentName:SetText({ {
        color = { 0.99, 0.96, 0.78, 1 }
    }, SID.recruitment.maceman })
end
macemanIconButton.OnClick = function(self)
    -- create maceman unit
end
macemanIconButton.OnMouseExit = function(self)
    hoverIcon:SetVisible(false)
    hoverIcon_2:SetVisible(false)
    goldIcon:SetVisible(false)
    currentCost:SetText({ {
        color = { 0.99, 0.96, 0.78, 1 }
    }, "" })
    currentName:SetText({ {
        color = { 0.99, 0.96, 0.78, 1 }
    }, "" })
end

crossbowmanIconButton:SetState(states.STATE_BARRACKS)
crossbowmanIconButton:SetImage(crossbowmanIconNotAvailable)
crossbowmanIconButton:SetScaleX(frCrossbowmanButton.width / crossbowmanIconButton:GetImageWidth())
crossbowmanIconButton:SetScaleY(crossbowmanIconButton:GetScaleX())
crossbowmanIconButton:SetPos(frCrossbowmanButton.x, frCrossbowmanButton.y)
crossbowmanIconButton.OnMouseEnter = function(self)
    hoverIcon:SetPos(frCrossbowButton.x, frCrossbowButton.y + 6)
    hoverIcon:SetVisible(true)
    hoverIcon_2:SetPos(frLeatherButton.x, frLeatherButton.y + 6)
    hoverIcon_2:SetVisible(true)
    goldIcon:SetVisible(true)
    currentCost:SetText({ {
        color = { 0.99, 0.96, 0.78, 1 }
    }, "20 " .. SID.gold })
    currentName:SetText({ {
        color = { 0.99, 0.96, 0.78, 1 }
    }, SID.recruitment.crossbowman })
end
crossbowmanIconButton.OnMouseDown = function(self)
    hoverIcon:SetPos(frCrossbowButton.x, frCrossbowButton.y + 6)
    hoverIcon:SetVisible(true)
    hoverIcon_2:SetPos(frLeatherButton.x, frLeatherButton.y + 6)
    hoverIcon_2:SetVisible(true)
    goldIcon:SetVisible(true)
    currentCost:SetText({ {
        color = { 0.99, 0.96, 0.78, 1 }
    }, "20 " .. SID.gold })
    currentName:SetText({ {
        color = { 0.99, 0.96, 0.78, 1 }
    }, SID.recruitment.crossbowman })
end
crossbowmanIconButton.OnClick = function(self)
    -- create crossbowman unit
end
crossbowmanIconButton.OnMouseExit = function(self)
    hoverIcon:SetVisible(false)
    hoverIcon_2:SetVisible(false)
    goldIcon:SetVisible(false)
    currentCost:SetText({ {
        color = { 0.99, 0.96, 0.78, 1 }
    }, "" })
    currentName:SetText({ {
        color = { 0.99, 0.96, 0.78, 1 }
    }, "" })
end

pikemanIconButton:SetState(states.STATE_BARRACKS)
pikemanIconButton:SetImage(pikemanIconNotAvailable)
pikemanIconButton:SetScaleX(frPikemanButton.width / pikemanIconButton:GetImageWidth())
pikemanIconButton:SetScaleY(pikemanIconButton:GetScaleX())
pikemanIconButton:SetPos(frPikemanButton.x, frPikemanButton.y)
pikemanIconButton.OnMouseEnter = function(self)
    hoverIcon:SetPos(frPikeButton.x + 5, frPikeButton.y + 6)
    hoverIcon:SetVisible(true)
    hoverIcon_2:SetPos(frArmorButton.x + 1, frLeatherButton.y + 6)
    hoverIcon_2:SetVisible(true)
    goldIcon:SetVisible(true)
    currentCost:SetText({ {
        color = { 0.99, 0.96, 0.78, 1 }
    }, "20 " .. SID.gold })
    currentName:SetText({ {
        color = { 0.99, 0.96, 0.78, 1 }
    }, SID.recruitment.pikeman })
end
pikemanIconButton.OnMouseDown = function(self)
    hoverIcon:SetPos(frPikeButton.x + 5, frPikeButton.y + 6)
    hoverIcon:SetVisible(true)
    hoverIcon_2:SetPos(frArmorButton.x + 1, frLeatherButton.y + 6)
    hoverIcon_2:SetVisible(true)
    goldIcon:SetVisible(true)
    currentCost:SetText({ {
        color = { 0.99, 0.96, 0.78, 1 }
    }, "20 " .. SID.gold })
    currentName:SetText({ {
        color = { 0.99, 0.96, 0.78, 1 }
    }, SID.recruitment.pikeman })
end
pikemanIconButton.OnClick = function(self)
    -- create pikeman unit
end
pikemanIconButton.OnMouseExit = function(self)
    hoverIcon:SetVisible(false)
    hoverIcon_2:SetVisible(false)
    goldIcon:SetVisible(false)
    currentCost:SetText({ {
        color = { 0.99, 0.96, 0.78, 1 }
    }, "" })
    currentName:SetText({ {
        color = { 0.99, 0.96, 0.78, 1 }
    }, "" })
end

swordsmanIconButton:SetState(states.STATE_BARRACKS)
swordsmanIconButton:SetImage(swordsmanIconNotAvailable)
swordsmanIconButton:SetScaleX(frSwordsmanButton.width / swordsmanIconButton:GetImageWidth())
swordsmanIconButton:SetScaleY(swordsmanIconButton:GetScaleX())
swordsmanIconButton:SetPos(frSwordsmanButton.x, frSwordsmanButton.y)
swordsmanIconButton.OnMouseEnter = function(self)
    hoverIcon:SetPos(frSwordButton.x + 1, frSwordButton.y + 6)
    hoverIcon:SetVisible(true)
    hoverIcon_2:SetPos(frArmorButton.x + 1, frLeatherButton.y + 6)
    hoverIcon_2:SetVisible(true)
    goldIcon:SetVisible(true)
    currentCost:SetText({ {
        color = { 0.99, 0.96, 0.78, 1 }
    }, "40 " .. SID.gold })
    currentName:SetText({ {
        color = { 0.99, 0.96, 0.78, 1 }
    }, SID.recruitment.swordsman })
end
swordsmanIconButton.OnMouseDown = function(self)
    hoverIcon:SetPos(frSwordButton.x + 1, frSwordButton.y + 6)
    hoverIcon:SetVisible(true)
    hoverIcon_2:SetPos(frArmorButton.x + 1, frLeatherButton.y + 6)
    hoverIcon_2:SetVisible(true)
    goldIcon:SetVisible(true)
    currentCost:SetText({ {
        color = { 0.99, 0.96, 0.78, 1 }
    }, "40 " .. SID.gold })
    currentName:SetText({ {
        color = { 0.99, 0.96, 0.78, 1 }
    }, SID.recruitment.swordsman })
end
swordsmanIconButton.OnClick = function(self)
    -- create swordsman unit
end
swordsmanIconButton.OnMouseExit = function(self)
    hoverIcon:SetVisible(false)
    hoverIcon_2:SetVisible(false)
    goldIcon:SetVisible(false)
    currentCost:SetText({ {
        color = { 0.99, 0.96, 0.78, 1 }
    }, "" })
    currentName:SetText({ {
        color = { 0.99, 0.96, 0.78, 1 }
    }, "" })
end

knightIconButton:SetState(states.STATE_BARRACKS)
knightIconButton:SetImage(knightIconNotAvailable)
knightIconButton:SetScaleX(frKnightButton.width / knightIconButton:GetImageWidth())
knightIconButton:SetScaleY(knightIconButton:GetScaleX())
knightIconButton:SetPos(frKnightButton.x, frKnightButton.y)
knightIconButton.OnMouseEnter = function(self)
    hoverIcon:SetPos(frSwordButton.x + 1, frSwordButton.y + 6)
    hoverIcon:SetVisible(true)
    hoverIcon_2:SetPos(frArmorButton.x + 1, frLeatherButton.y + 6)
    hoverIcon_2:SetVisible(true)
    hoverIcon_3:SetPos(frHorseButton.x + 1, frHorseButton.y + 6)
    hoverIcon_3:SetVisible(true)
    goldIcon:SetVisible(true)
    currentCost:SetText({ {
        color = { 0.99, 0.96, 0.78, 1 }
    }, "40 " .. SID.gold })
    currentName:SetText({ {
        color = { 0.99, 0.96, 0.78, 1 }
    }, SID.recruitment.knight })
end
knightIconButton.OnMouseDown = function(self)
    hoverIcon:SetPos(frSwordButton.x + 1, frPikeButton.y + 6)
    hoverIcon:SetVisible(true)
    hoverIcon_2:SetPos(frArmorButton.x + 1, frLeatherButton.y + 6)
    hoverIcon_2:SetVisible(true)
    hoverIcon_3:SetPos(frHorseButton.x + 1, frHorseButton.y + 6)
    hoverIcon_3:SetVisible(true)
    goldIcon:SetVisible(true)
    currentCost:SetText({ {
        color = { 0.99, 0.96, 0.78, 1 }
    }, "40 " .. SID.gold })
    currentName:SetText({ {
        color = { 0.99, 0.96, 0.78, 1 }
    }, SID.recruitment.knight })
end
knightIconButton.OnClick = function(self)
    -- create knight unit
end
knightIconButton.OnMouseExit = function(self)
    hoverIcon:SetVisible(false)
    hoverIcon_2:SetVisible(false)
    hoverIcon_3:SetVisible(false)
    goldIcon:SetVisible(false)
    currentCost:SetText({ {
        color = { 0.99, 0.96, 0.78, 1 }
    }, "" })
    currentName:SetText({ {
        color = { 0.99, 0.96, 0.78, 1 }
    }, "" })
end


function group.DisplayCurrentStock()
    if _G.state.weapons[WEAPON.leatherArmor] > 0 then
        leatherIconButton:SetImage(leatherIconAvailable)
    else
        leatherIconButton:SetImage(leatherIconNormal)
    end
    if _G.state.weapons[WEAPON.shield] > 0 then
        armorIconButton:SetImage(armorIconAvailable)
    else
        armorIconButton:SetImage(armorIconNormal)
    end
    if _G.state.weapons[WEAPON.sword] > 0 then
        swordIconButton:SetImage(swordIconAvailable)
    else
        swordIconButton:SetImage(swordIconNormal)
    end
    if _G.state.weapons[WEAPON.mace] > 0 then
        maceIconButton:SetImage(maceIconAvailable)
    else
        maceIconButton:SetImage(maceIconNormal)
    end
    if _G.state.weapons[WEAPON.crossbow] > 0 then
        crossbowIconButton:SetImage(crossbowIconAvailable)
    else
        crossbowIconButton:SetImage(crossbowIconNormal)
    end
    if _G.state.weapons[WEAPON.pike] > 0 then
        pikeIconButton:SetImage(pikeIconAvailable)
    else
        pikeIconButton:SetImage(pikeIconNormal)
    end

    if _G.state.weapons[WEAPON.bow] > 0 then
        archerIconButton:SetImage(archerIconAvailable)
        bowIconButton:SetImage(bowIconAvailable)
    else
        archerIconButton:SetImage(archerIconNotAvailable)
        bowIconButton:SetImage(bowIconNormal)
    end
    if _G.state.weapons[WEAPON.spear] > 0 then
        spearmanIconButton:SetImage(spearmanIconAvailable)
        spearIconButton:SetImage(spearIconAvailable)
    else
        spearmanIconButton:SetImage(spearmanIconNotAvailable)
        spearIconButton:SetImage(spearIconNormal)
    end
    if _G.state.weapons[WEAPON.mace] > 0 and _G.state.weapons[WEAPON.leatherArmor] > 0 then
        macemanIconButton:SetImage(macemanIconAvailable)
    else
        macemanIconButton:SetImage(macemanIconNotAvailable)
    end
    if _G.state.weapons[WEAPON.crossbow] > 0 and _G.state.weapons[WEAPON.leatherArmor] > 0 then
        crossbowmanIconButton:SetImage(crossbowmanIconAvailable)
    else
        crossbowmanIconButton:SetImage(crossbowmanIconNotAvailable)
    end
    if _G.state.weapons[WEAPON.pike] > 0 and _G.state.weapons[WEAPON.shield] > 0 then
        pikemanIconButton:SetImage(pikemanIconAvailable)
    else
        pikemanIconButton:SetImage(pikemanIconNotAvailable)
    end
    if _G.state.weapons[WEAPON.sword] > 0 and _G.state.weapons[WEAPON.shield] > 0 then
        swordsmanIconButton:SetImage(swordsmanIconAvailable)
    else
        swordsmanIconButton:SetImage(swordsmanIconNotAvailable)
    end

    -- HORSE YET TO BE IMPLEMENTED

    currentStockPeasants:SetText({ {
        color = { 0.99, 0.96, 0.78, 1 }
    }, SID.recruitment.availablePeasants .. ": " .. _G.campfire.peasants })
    currentStockBow:SetText({ {
        color = { 0, 0, 0, 1 }
    }, _G.state.weapons[WEAPON.bow] })
    currentStockSpear:SetText({ {
        color = { 0, 0, 0, 1 }
    }, _G.state.weapons[WEAPON.spear] })
    currentStockSword:SetText({ {
        color = { 0, 0, 0, 1 }
    }, _G.state.weapons[WEAPON.sword] })
    currentStockCrossbow:SetText({ {
        color = { 0, 0, 0, 1 }
    }, _G.state.weapons[WEAPON.crossbow] })
    currentStockPike:SetText({ {
        color = { 0, 0, 0, 1 }
    }, _G.state.weapons[WEAPON.pike] })
    currentStockMace:SetText({ {
        color = { 0, 0, 0, 1 }
    }, _G.state.weapons[WEAPON.mace] })
    currentStockLeather:SetText({ {
        color = { 0, 0, 0, 1 }
    }, _G.state.weapons[WEAPON.leatherArmor] })
    currentStockArmor:SetText({ {
        color = { 0, 0, 0, 1 }
    }, _G.state.weapons[WEAPON.shield] })
    currentStockHorse:SetText({ {
        color = { 0, 0, 0, 1 }
    }, "0" }) -- HORSE YET TO BE IMPLEMENTED
end

currentStockPeasants:SetState(states.STATE_BARRACKS)
currentStockPeasants:SetFont(loveframes.font_times_new_medium)
currentStockPeasants:SetPos(frSwordsmanButton.x, frSwordsmanButton.y - 13)
currentStockPeasants:SetShadow(true)

currentName:SetState(states.STATE_BARRACKS)
currentName:SetFont(loveframes.font_times_new_medium)
currentName:SetPos(frCrossbowmanButton.x, frCrossbowmanButton.y - 13)
currentName:SetShadow(true)

goldIcon:SetState(states.STATE_BARRACKS)
goldIcon:SetPos(frGoldIcon.x, frGoldIcon.y)
goldIcon:SetVisible(false)
goldIcon:SetImage(goldIconNormal)

currentCost:SetState(states.STATE_BARRACKS)
currentCost:SetFont(loveframes.font_times_new_medium)
currentCost:SetPos(frArcherButton.x + 45, frArcherButton.y - 13)
currentCost:SetShadow(true)

return group
