local loveframes = require("libraries.loveframes")
local states = require("states.ui.states")
local framesActionBar = require("states.ui.action_bar_frames")
local actionBar = require("states.ui.ActionBar")
local scale = actionBar.element.scalex

local scribeMoods = {
    love.graphics.newImage("assets/ui/scribe/scribe_0.png"),
    love.graphics.newImage("assets/ui/scribe/scribe_10.png"),
    love.graphics.newImage("assets/ui/scribe/scribe_20.png"),
    love.graphics.newImage("assets/ui/scribe/scribe_30.png"),
    love.graphics.newImage("assets/ui/scribe/scribe_40.png"),
    love.graphics.newImage("assets/ui/scribe/scribe_50.png"),
    love.graphics.newImage("assets/ui/scribe/scribe_60.png"),
    love.graphics.newImage("assets/ui/scribe/scribe_70.png"),
    love.graphics.newImage("assets/ui/scribe/scribe_80.png"),
    love.graphics.newImage("assets/ui/scribe/scribe_90.png"),
    love.graphics.newImage("assets/ui/scribe/scribe_100.png")
}

local frScribeFace = {
    x = framesActionBar.frFull.x + 1011 * scale,
    y = framesActionBar.frFull.y + -3 * scale,
    width = scribeMoods[1]:getWidth() * scale,
    height = scribeMoods[1]:getHeight() * scale
}

local scribeImage = loveframes.Create("image")
scribeImage:SetState(states.STATE_KEEP_TAX)
scribeImage:SetImage(scribeMoods[1])
scribeImage:SetScaleX(frScribeFace.width / scribeImage:GetImageWidth())
scribeImage:SetScaleY(scribeImage:GetScaleX())
scribeImage:SetPos(frScribeFace.x, frScribeFace.y)

function scribeImage:SetImageBasedOnHappiness(happiness)
    scribeImage:SetImage(scribeMoods[math.floor(happiness / 10) + 1])
end

return scribeImage
