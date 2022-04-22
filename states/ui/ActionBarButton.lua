local loveframes = require('libraries.loveframes')
local ab = require('states.ui.action_bar_frames')

local img_ab_background = love.graphics.newImage('assets/ui/action_bar_background_clear.png')
local img_ab_background_hover = love.graphics.newImage('assets/ui/action_bar_background_hover.png')
local img_ab_background_selected = love.graphics.newImage('assets/ui/action_bar_background_selected.png')
local img_ab_background_clear = love.graphics.newImage('assets/ui/action_bar_background_clear.png')

local ActionBarButton = _G.class("ActionBarButton")
ActionBarButton.static.background_image = img_ab_background
ActionBarButton.static.background_hover_image = img_ab_background_hover
ActionBarButton.static.background_selected_image = img_ab_background_selected
ActionBarButton.static.background_clear = img_ab_background_clear
function ActionBarButton:initialize(image, state, position, big_frame_foreground, onclick, disabled)
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
    self.big_frame_foreground = big_frame_foreground or false
    self.on_click = onclick
    self.image = image
    self.disabled = disabled or false
    self.state = state
    self.background = loveframes.Create("image"):SetState(self.state):SetImage(ActionBarButton.background_image)
        :SetOffsetX(ActionBarButton.background_image:getWidth() / 2):SetOffsetY(
            ActionBarButton.background_image:getHeight() / 2)
    if self.disabled then
        self.background:SetImage(ActionBarButton.background_clear):SetOffsetX(
            ActionBarButton.background_clear:getWidth() / 2)
            :SetOffsetY(ActionBarButton.background_clear:getHeight() / 2)
        self.background:SetColor(0.8, 0.8, 0.8, 1)

    end
    local frame = ab["fr_action_" .. tostring(position)]
    self.frame = frame
    local small_frame = ab["fr_action_" .. tostring(position) .. "_img"]
    self.foreground_frame = small_frame
    if self.big_frame_foreground then
        self.foreground_frame = self.frame
    end
    self.background:SetPos(frame.x + frame.width / 2, frame.y + frame.height / 2)
    self.background.stop_propagation = true
    self.background:SetClickBounds(frame.x, frame.y, frame.width, frame.height)
    if (frame.width) / self.background:GetImageWidth() < (frame.height) / self.background:GetImageHeight() then
        self.background:SetScale((frame.width) / self.background:GetImageWidth())
    else
        self.background:SetScale((frame.height) / self.background:GetImageHeight())
    end
    self.background.OnMouseEnter = function(element)
        self:on_mouse_enter(element)
    end
    self.background.OnMouseExit = function(element)
        self:on_mouse_exit(element)
    end
    if self.on_click then
        self.background.OnClick = self.on_click
    end
    self.foreground = loveframes.Create("image"):SetState(self.state):SetImage(self.image):SetOffsetX(
        self.image:getWidth() / 2):SetOffsetY(self.image:getHeight() / 2)
    self.foreground.disablehover = true
    self.foreground:SetPos(self.foreground_frame.x + self.foreground_frame.width / 2,
        self.foreground_frame.y + self.foreground_frame.height / 2)
    if (self.foreground_frame.width) / self.foreground:GetImageWidth() < (self.foreground_frame.height) /
        self.foreground:GetImageHeight() then
        self.foreground:SetScale((self.foreground_frame.width) / self.foreground:GetImageWidth())
    else
        self.foreground:SetScale((self.foreground_frame.height) / self.foreground:GetImageHeight())
    end
    if self.disabled then
        self.foreground:SetColor(0.6, 0.6, 0.6, 0.6)
    end
    -- hidden by default
    self.background.visible = false
    self.foreground.visible = false
end
function ActionBarButton:set_tooltip(title, tooltip_text)
    if not self.tooltip then
        local tooltip = loveframes.Create("tooltip")
        tooltip:SetObject(self.background)
        tooltip:SetState(self.state)
        tooltip:SetPadding(10)
        tooltip:SetText(tooltip_text, title)
        self.tooltip = tooltip
    else
        self.tooltip:SetText(tooltip_text, title)
    end
end
function ActionBarButton:hide()
    self.background.visible = false
    self.foreground.visible = false
end
function ActionBarButton:show()
    self.background.visible = true
    self.foreground.visible = true
end
function ActionBarButton:set_on_click(callback)
    if not callback then
        error("OnClick callback is nil")
    end
    self.background.OnClick = callback
end
function ActionBarButton:on_mouse_enter(element)
    if not self.selected and not self.disabled then
        element:SetImage(ActionBarButton.background_hover_image)
        element:SetScale((self.frame.width) / element:GetImageWidth())
    end
end
function ActionBarButton:on_mouse_exit(element)
    if not self.selected and not self.disabled then
        element:SetImage(ActionBarButton.background_image)
        element:SetScale((self.frame.width) / element:GetImageWidth())
    end
end
function ActionBarButton:unselect()
    self.selected = false
    self.background:SetImage(ActionBarButton.background_image)
end
function ActionBarButton:select()
    self.selected = true
    self.background:SetImage(ActionBarButton.background_selected_image)
end

return ActionBarButton
