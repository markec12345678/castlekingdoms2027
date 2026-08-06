local loveframes = require("libraries.loveframes")
local states = require("states.ui.states")
local framesActionBar = require("states.ui.action_bar_frames")
local actionBar = require("states.ui.ActionBar")
local scale = actionBar.element.scalex
local Events = require("objects.Enums.Events")
local group = {}
local colorBlack = { 0, 0, 0, 1 }

local ActionBarButton = require("states.ui.ActionBarButton")
local backButton = ActionBarButton:new(love.graphics.newImage("assets/ui/back_ab.png"), states.STATE_UNIT_DETAILS, 12)
backButton:setOnClick(function(self)
    actionBar:switchMode()
end)
actionBar:registerGroup("unit_details", { backButton })

local bowIconNormal = love.graphics.newImage("assets/ui/armoury/bowIconNormal.png")

local referenceButton = {
    x = framesActionBar.frFull.x + 335 * scale,
    y = framesActionBar.frFull.y + 118 * scale,
    width = bowIconNormal:getWidth() * 1.5 * scale,
    height = bowIconNormal:getHeight() * 1.25 * scale
}

local function getImageFromQuad(quad, atlas)
    local _, _, w, h = quad:getViewport()
    local canvas = love.graphics.newCanvas(w, h)
    love.graphics.setCanvas(canvas)
    love.graphics.clear()
    love.graphics.draw(atlas, quad, 0, 0)
    love.graphics.setCanvas()
    return love.graphics.newImage(canvas:newImageData())
end

local currentUnitNameText = loveframes.Create("text")
currentUnitNameText:SetState(states.STATE_UNIT_DETAILS)
currentUnitNameText:SetFont(loveframes.font_times_new_normal_large)
currentUnitNameText:SetPos(framesActionBar.frFull.x + 405 * scale, referenceButton.y)
currentUnitNameText:SetShadow(false)

local currentUnitIconButton = loveframes.Create("image")
currentUnitIconButton:SetState(states.STATE_UNIT_DETAILS)
currentUnitIconButton:SetImage(bowIconNormal)
currentUnitIconButton:SetScaleY(referenceButton.height / currentUnitIconButton:GetHeight())
currentUnitIconButton:SetScaleX(currentUnitIconButton:GetScaleY())
currentUnitIconButton:SetPos(referenceButton.x, referenceButton.y)

_G.bus.on(Events.OnUnitDetailsSelected, function(unit)
    currentUnitNameText:SetText({ {
        color = colorBlack
    }, unit.class.name .. ", " .. unit.state })
    local newUnitImage = getImageFromQuad(unit.animation.frames[unit.animation.position], _G.objectAtlas)
    currentUnitIconButton:SetImage(newUnitImage)
end)

return group
