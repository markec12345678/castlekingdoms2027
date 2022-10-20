local loveframes = require("libraries.loveframes")
local states = require("states.ui.states")
local ab = require("states.ui.action_bar_frames")
local actionBar = require("states.ui.ActionBar")
local scale = actionBar.element.scalex

local ActionBarButton = require("states.ui.ActionBarButton")
local backButton = ActionBarButton:new(love.graphics.newImage("assets/ui/back_ab.png"), states.STATE_STOCKPILE, 12)
local StockpileGoodsImage = love.graphics.newImage("assets/ui/action_bar_stockpile.png")
backButton:setOnClick(function(self)
    actionBar:switchMode()
end)
actionBar:registerGroup("stockpile", {backButton})

local frWood = {
    x = ab.frFull.x + 365 * scale,
    y = ab.frFull.y + 165 * scale,
    width = StockpileGoodsImage:getWidth() * scale,
    height = StockpileGoodsImage:getWidth() * scale
}
local frStone = {
    x = ab.frFull.x + 435 * scale,
    y = ab.frFull.y + 165 * scale,
    width = StockpileGoodsImage:getWidth() * scale,
    height = StockpileGoodsImage:getWidth() * scale
}
local frWheat = {
    x = ab.frFull.x + 504 * scale,
    y = ab.frFull.y + 165 * scale,
    width = StockpileGoodsImage:getWidth() * scale,
    height = StockpileGoodsImage:getWidth() * scale
}
local frTar = {
    x = ab.frFull.x + 572 * scale,
    y = ab.frFull.y + 165 * scale,
    width = StockpileGoodsImage:getWidth() * scale,
    height = StockpileGoodsImage:getWidth() * scale
}
local frAle = {
    x = ab.frFull.x + 642 * scale,
    y = ab.frFull.y + 165 * scale,
    width = StockpileGoodsImage:getWidth() * scale,
    height = StockpileGoodsImage:getWidth() * scale
}
local frIron = {
    x = ab.frFull.x + 713 * scale,
    y = ab.frFull.y + 165 * scale,
    width = StockpileGoodsImage:getWidth() * scale,
    height = StockpileGoodsImage:getWidth() * scale
}
local frHop = {
    x = ab.frFull.x + 782 * scale,
    y = ab.frFull.y + 165 * scale,
    width = StockpileGoodsImage:getWidth() * scale,
    height = StockpileGoodsImage:getWidth() * scale
}
local frFlour = {
    x = ab.frFull.x + 852 * scale,
    y = ab.frFull.y + 165 * scale,
    width = StockpileGoodsImage:getWidth() * scale,
    height = StockpileGoodsImage:getWidth() * scale
}
local shadowColorR, shadowColorG, shadowColorB = (135 / 255) - 0.2, (112 / 255) - 0.2, (94 / 255) - 0.2

local woodCountText = loveframes.Create("text")
woodCountText:SetPos(frWood.x, frWood.y)
woodCountText:SetState(states.STATE_STOCKPILE)
woodCountText:SetFont(loveframes.font_immortal_large)
woodCountText:SetShadowColor(shadowColorR, shadowColorG, shadowColorB)
woodCountText:SetShadow(true)

local hopCountText = loveframes.Create("text")
hopCountText:SetPos(frHop.x, frHop.y)
hopCountText:SetState(states.STATE_STOCKPILE)
hopCountText:SetFont(loveframes.font_immortal_large)
hopCountText:SetShadowColor(shadowColorR, shadowColorG, shadowColorB)
hopCountText:SetShadow(true)

local stoneCountText = loveframes.Create("text")
stoneCountText:SetPos(frStone.x, frStone.y)
stoneCountText:SetState(states.STATE_STOCKPILE)
stoneCountText:SetFont(loveframes.font_immortal_large)
stoneCountText:SetShadowColor(shadowColorR, shadowColorG, shadowColorB)
stoneCountText:SetShadow(true)

local ironCountText = loveframes.Create("text")
ironCountText:SetPos(frIron.x, frIron.y)
ironCountText:SetState(states.STATE_STOCKPILE)
ironCountText:SetFont(loveframes.font_immortal_large)
ironCountText:SetShadowColor(shadowColorR, shadowColorG, shadowColorB)
ironCountText:SetShadow(true)

local tarCountText = loveframes.Create("text")
tarCountText:SetPos(frTar.x, frTar.y)
tarCountText:SetState(states.STATE_STOCKPILE)
tarCountText:SetFont(loveframes.font_immortal_large)
tarCountText:SetShadowColor(shadowColorR, shadowColorG, shadowColorB)
tarCountText:SetShadow(true)

local wheatCountText = loveframes.Create("text")
wheatCountText:SetPos(frWheat.x, frWheat.y)
wheatCountText:SetState(states.STATE_STOCKPILE)
wheatCountText:SetFont(loveframes.font_immortal_large)
wheatCountText:SetShadowColor(shadowColorR, shadowColorG, shadowColorB)
wheatCountText:SetShadow(true)

local aleCountText = loveframes.Create("text")
aleCountText:SetPos(frAle.x, frAle.y)
aleCountText:SetState(states.STATE_STOCKPILE)
aleCountText:SetFont(loveframes.font_immortal_large)
aleCountText:SetShadowColor(shadowColorR, shadowColorG, shadowColorB)
aleCountText:SetShadow(true)

local flourCountText = loveframes.Create("text")
flourCountText:SetPos(frFlour.x, frFlour.y)
flourCountText:SetState(states.STATE_STOCKPILE)
flourCountText:SetFont(loveframes.font_immortal_large)
flourCountText:SetShadowColor(shadowColorR, shadowColorG, shadowColorB)
flourCountText:SetShadow(true)

function actionBar:updateStockpileResourcesCount()
    local color = {(135 / 255) + 0.2, (112 / 255) + 0.2, (94 / 255) + 0.2, 1}

    woodCountText:SetText({{
        color = color
    }, _G.state.resources["wood"]})
    woodCountText:SetPos(frWood.x - woodCountText.font:getWidth(_G.state.resources["wood"]) / 2, frWood.y)

    hopCountText:SetText({{
        color = color
    }, _G.state.resources["hop"]})
    hopCountText:SetPos(frHop.x - hopCountText.font:getWidth(_G.state.resources["hop"]) / 2, frHop.y)

    stoneCountText:SetText({{
        color = color
    }, _G.state.resources["stone"]})
    stoneCountText:SetPos(frStone.x - stoneCountText.font:getWidth(_G.state.resources["stone"]) / 2, frStone.y)

    ironCountText:SetText({{
        color = color
    }, _G.state.resources["iron"]})
    ironCountText:SetPos(frIron.x - ironCountText.font:getWidth(_G.state.resources["iron"]) / 2, frIron.y)

    tarCountText:SetText({{
        color = color
    }, _G.state.resources["tar"]})
    tarCountText:SetPos(frTar.x - tarCountText.font:getWidth(_G.state.resources["tar"]) / 2, frTar.y)

    wheatCountText:SetText({{
        color = color
    }, _G.state.resources["wheat"]})
    wheatCountText:SetPos(frWheat.x - wheatCountText.font:getWidth(_G.state.resources["wheat"]) / 2, frWheat.y)

    aleCountText:SetText({{
        color = color
    }, _G.state.resources["ale"]})
    aleCountText:SetPos(frAle.x - aleCountText.font:getWidth(_G.state.resources["ale"]) / 2, frAle.y)

    flourCountText:SetText({{
        color = color
    }, _G.state.resources["flour"]})
    flourCountText:SetPos(frFlour.x - flourCountText.font:getWidth(_G.state.resources["flour"]) / 2, frFlour.y)

end
