local actionBar = require("states.ui.ActionBar")
local scribeImage = require("states.ui.scribe.scribe_face")

local ScribeController = _G.class("StockpileController")
local actionBarFrames = require("states.ui.action_bar_frames")

local anim8 = require 'libraries/anim8'

local scribeSheet = love.graphics.newImage('assets/ui/scribe/scribe_sheet.png')
local g = anim8.newGrid(83, 99, scribeSheet:getWidth(), scribeSheet:getHeight())
-- local animation = anim8.newAnimation(g('1-11', 1, '11-1', 1), 0.12, "pauseAtEnd")
-- local animation2 = anim8.newAnimation(g('1-11', 2, '11-1', 2), 0.12)
local animationHappy = anim8.newAnimation(g('1-11', 3, '11-1', 3), 0.12, function(an)
    an:pause()
    local Scribe = require("objects.Controllers.ScribeController")
    Scribe:onAnimationEnd()
end)
local animationDisgusted = anim8.newAnimation(g('1-11', 4, '11-1', 4), 0.12, function(an)
    an:pause()
    local Scribe = require("objects.Controllers.ScribeController")
    Scribe:onAnimationEnd()
end)


function ScribeController:onAnimationEnd()
    self.animation = nil
end

function ScribeController:update()
    if _G.state.popularity == nil or scribeImage == nil then
        return
    end
    scribeImage:SetState(actionBar.popularityText:GetState())
    scribeImage:SetImageBasedOnHappiness(_G.state.popularity)
    if self.animation then
        self.animation:update(_G.dt)
    end
end

function ScribeController:triggerHappyEvent()
    self.animation = animationHappy
    self.animation:gotoFrame(1)
    self.animation:resume()
end

function ScribeController:triggerUnhappyEvent()
    self.animation = animationDisgusted
    self.animation:gotoFrame(1)
    self.animation:resume()
end

function ScribeController:draw()
    local scale = actionBar.element.scalex
    if self.animation then
        self.animation:draw(scribeSheet, actionBarFrames.frFull.x + 1024 * scale, actionBarFrames.frFull.y + 5 * scale, 0,
            scale,
            scale)
    end
end

return ScribeController:new()
