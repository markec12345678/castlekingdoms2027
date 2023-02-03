local loveframes = require("libraries.loveframes")
local states = require("states.ui.states")
local framesActionBar = require("states.ui.action_bar_frames")
local actionBar = require("states.ui.ActionBar")
local scale = actionBar.element.scalex

local group = {}
local ladButtonEnable = false
local engButtonEnable = false
local tunButtonEnable = false

local ActionBarButton = require("states.ui.ActionBarButton")
local backButton = ActionBarButton:new(love.graphics.newImage("assets/ui/back_ab.png"), states.STATE_GUILDS, 12)
backButton:setOnClick(function(self)
    actionBar:switchMode()
end)
actionBar:registerGroup("guilds", { backButton })

local ladIcon = love.graphics.newImage("assets/ui/guilds/lad_icon.png")
local engIcon = love.graphics.newImage("assets/ui/guilds/eng_icon.png")
local tunIcon = love.graphics.newImage("assets/ui/guilds/tun_icon.png")
local ladIconHover = love.graphics.newImage("assets/ui/guilds/lad_icon_hover.png")
local engIconHover = love.graphics.newImage("assets/ui/guilds/eng_icon_hover.png")
local tunIconHover = love.graphics.newImage("assets/ui/guilds/tun_icon_hover.png")
local ladIconDisable = love.graphics.newImage("assets/ui/guilds/lad_icon_disable.png")
local engIconDisable = love.graphics.newImage("assets/ui/guilds/eng_icon_disable.png")
local tunIconDisable = love.graphics.newImage("assets/ui/guilds/tun_icon_disable.png")

local frLadButton = {
    x = framesActionBar.frFull.x + 350 * scale,
    y = framesActionBar.frFull.y + 85 * scale,
    width = ladIcon:getWidth() * scale,
    height = ladIcon:getHeight() * scale
}
local frEngButton = {
    x = framesActionBar.frFull.x + 550 * scale,
    y = framesActionBar.frFull.y + 95 * scale,
    width = engIcon:getWidth() * scale,
    height = engIcon:getHeight() * scale
}
local frTunButton = {
    x = framesActionBar.frFull.x + 750 * scale,
    y = framesActionBar.frFull.y + 80 * scale,
    width = tunIcon:getWidth() * scale,
    height = tunIcon:getHeight() * scale
}

local ladIconButton = loveframes.Create("image")
ladIconButton:SetState(states.STATE_GUILDS)
ladIconButton:SetImage(ladIcon)
ladIconButton:SetScaleX(frLadButton.width / ladIconButton:GetImageWidth())
ladIconButton:SetScaleY(ladIconButton:GetScaleX())
ladIconButton:SetPos(frLadButton.x, frLadButton.y)

ladIconButton.OnMouseEnter = function(self)
    if ladButtonEnable then
        ladIconButton:SetImage(ladIconHover)
    end
end

ladIconButton.OnMouseExit = function(self)
    if ladButtonEnable then
        ladIconButton:SetImage(ladIcon)
    end
end

local engIconButton = loveframes.Create("image")
engIconButton:SetState(states.STATE_GUILDS)
engIconButton:SetImage(engIcon)
engIconButton:SetScaleX(frEngButton.width / engIconButton:GetImageWidth())
engIconButton:SetScaleY(engIconButton:GetScaleX())
engIconButton:SetPos(frEngButton.x, frEngButton.y)

engIconButton.OnMouseEnter = function(self)
    if engButtonEnable then
        engIconButton:SetImage(engIconHover)
    end
end

engIconButton.OnMouseExit = function(self)
    if engButtonEnable then
        engIconButton:SetImage(engIcon)
    end
end

local tunIconButton = loveframes.Create("image")
tunIconButton:SetState(states.STATE_GUILDS)
tunIconButton:SetImage(tunIcon)
tunIconButton:SetScaleX(frTunButton.width / tunIconButton:GetImageWidth())
tunIconButton:SetScaleY(tunIconButton:GetScaleX())
tunIconButton:SetPos(frTunButton.x, frTunButton.y)

tunIconButton.OnMouseEnter = function(self)
    if tunButtonEnable then
        tunIconButton:SetImage(tunIconHover)
    end
end

tunIconButton.OnMouseExit = function(self)
    if tunButtonEnable then
        tunIconButton:SetImage(tunIcon)
    end
end

function group.DisplayButtons()
    if _G.BuildingManager:count("TunnelersGuild") == 0 then
        tunIconButton:SetImage(tunIconDisable)
        tunButtonEnable = false
    elseif tunButtonEnable == false and _G.BuildingManager:count("TunnelersGuild") ~= 0 then
        tunIconButton:SetImage(tunIcon)
        tunButtonEnable = true
    end
    if _G.BuildingManager:count("EngineersGuild") == 0 then
        engIconButton:SetImage(engIconDisable)
        ladIconButton:SetImage(ladIconDisable)
        ladButtonEnable = false
        engButtonEnable = false
    elseif ladButtonEnable == false and _G.BuildingManager:count("EngineersGuild") ~= 0 then
        engIconButton:SetImage(engIcon)
        ladIconButton:SetImage(ladIcon)
        ladButtonEnable = true
        engButtonEnable = true
    end
end

return group
