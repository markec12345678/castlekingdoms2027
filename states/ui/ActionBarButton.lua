local loveframes = require('libraries.loveframes')
local ab = require('states.ui.action_bar_frames')

local imgAbBackground = love.graphics.newImage('assets/ui/action_bar_background_clear.png')
local imgAbBackgroundHover = love.graphics.newImage('assets/ui/action_bar_background_hover.png')
local imgAbBackgroundSelected = love.graphics.newImage('assets/ui/action_bar_background_selected.png')
local imgAbBackgroundClear = love.graphics.newImage('assets/ui/action_bar_background_clear.png')

local ActionBarButton = _G.class("ActionBarButton")
ActionBarButton.static.backgroundImage = imgAbBackground
ActionBarButton.static.backgroundHoverImage = imgAbBackgroundHover
ActionBarButton.static.backgroundSelectedImage = imgAbBackgroundSelected
ActionBarButton.static.backgroundClear = imgAbBackgroundClear
function ActionBarButton:initialize(image, state, position, bigFrameForeground, onclick, disabled)
    if onclick then
        assert(type(onclick) == "function")
    end
    if position < 1 or position > 12 then
        error("received invalid position argument for action bar: " .. tostring(position))
    end
    if not image then
        error("image cannot be nil")
    end
    if not state then
        error("state cannot be nil")
    end
    self.onUnselect = function() end
    self.bigFrameForeground = bigFrameForeground or false
    self.onClick = onclick
    self.image = image
    self.position = position
    self.disabled = disabled or false
    self.state = state
    self.background = loveframes.Create("image"):SetState(self.state):SetImage(ActionBarButton.backgroundImage)
        :SetOffsetX(ActionBarButton.backgroundImage:getWidth() / 2):SetOffsetY(
            ActionBarButton.backgroundImage:getHeight() / 2)
    local frame = ab["frAction_" .. tostring(position)]
    self.frame = frame
    local smallFrame = ab["frAction_" .. tostring(position) .. "Img"]
    self.foregroundFrame = smallFrame
    if self.bigFrameForeground then
        self.foregroundFrame = self.frame
    end
    self.background:SetPos(frame.x + frame.width / 2, frame.y + frame.height / 2)
    self.background.stopPropagation = true
    self.background:SetClickBounds(frame.x, frame.y, frame.width, frame.height)
    if (frame.width) / self.background:GetImageWidth() < (frame.height) / self.background:GetImageHeight() then
        self.background:SetScale((frame.width) / self.background:GetImageWidth())
    else
        self.background:SetScale((frame.height) / self.background:GetImageHeight())
    end
    self.background.OnMouseEnter = function(element)
        self:onMouseEnter(element)
    end
    self.background.OnMouseExit = function(element)
        self:onMouseExit(element)
    end
    if self.onClick then
        self.background.OnClick = self.onClick
    end
    self.foreground = loveframes.Create("image"):SetState(self.state):SetImage(self.image):SetOffsetX(
        self.image:getWidth() / 2):SetOffsetY(self.image:getHeight() / 2)
    self.foreground.disablehover = true
    self.foreground:SetPos(self.foregroundFrame.x + self.foregroundFrame.width / 2,
        self.foregroundFrame.y + self.foregroundFrame.height / 2)
    if (self.foregroundFrame.width) / self.foreground:GetImageWidth() < (self.foregroundFrame.height) /
        self.foreground:GetImageHeight() then
        self.foreground:SetScale((self.foregroundFrame.width) / self.foreground:GetImageWidth())
    else
        self.foreground:SetScale((self.foregroundFrame.height) / self.foreground:GetImageHeight())
    end
    if self.disabled then
        self.foreground:SetColor(0.6, 0.6, 0.6, 0.6)
    end
    -- hidden by default
    self.background.visible = false
    self.foreground.visible = false
end

function ActionBarButton:setTooltip(title, tooltipText)
    if not self.tooltip then
        local tooltip = loveframes.Create("tooltip")
        tooltip:SetObject(self.background)
        tooltip:SetState(self.state)
        tooltip:SetPadding(10)
        tooltip.visible = false
        tooltip:SetText(tooltipText, title)
        self.tooltip = tooltip
    else
        self.tooltip:SetText(tooltipText, title)
    end
end

function ActionBarButton:hide()
    self:unselect()
    self.background.visible = false
    self.foreground.visible = false
    self.background.hover = false
    self.foreground.hover = false
end

function ActionBarButton:show()
    self.background.visible = true
    self.foreground.visible = true
end

function ActionBarButton:setOnClick(callback)
    if not callback then
        error("OnClick callback is nil")
    end
    self.background.OnClick = callback
end

function ActionBarButton:press()
    if self.background.OnClick then
        self.background.OnClick()
    end
end

function ActionBarButton:onMouseEnter(element)
    if not self.selected and not self.disabled then
        element:SetImage(ActionBarButton.backgroundHoverImage)
        element:SetScale((self.frame.width) / element:GetImageWidth())
    end
end

function ActionBarButton:onMouseExit(element)
    if not self.selected and not self.disabled then
        element:SetImage(ActionBarButton.backgroundImage)
        element:SetScale((self.frame.width) / element:GetImageWidth())
    end
end

function ActionBarButton:setOnUnselect(callback)
    if type(callback) ~= "function" then
        error("onUnselect should be a function")
    end
    self.onUnselect = callback
end

function ActionBarButton:unselect()
    self.selected = false
    self.onUnselect()
    self.background:SetImage(ActionBarButton.backgroundImage)
end

function ActionBarButton:select()
    self.selected = true
    self.background:SetImage(ActionBarButton.backgroundSelectedImage)
end

return ActionBarButton
