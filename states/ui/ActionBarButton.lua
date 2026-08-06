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

_G.fx = require("sounds.fx")
local ButtonFx = {
    ["BuildHover"] = {
        _G.fx["woodrollover2"],
        _G.fx["woodrollover3"],
        _G.fx["woodrollover7"],
        _G.fx["woodrollover8"],
    },
    -- TODO: add special hover sounds for submenus
    ["CastleHover"] = { _G.fx["metrollover3a"], },
    ["ResourcesHover"] = { _G.fx["metrollover13"], },
    ["FarmsHover"] = { _G.fx["metrollover2"], },
    ["HouseHover"] = { _G.fx["metrollover15"], },
    ["ShieldHover"] = { _G.fx["metrollover12"], },
    ["SickleHover"] = { _G.fx["metrollover4"], },
}

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
    self.onUnselect = function()
    end
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
        self.targetBackgroundScale = (frame.width) / self.background:GetImageWidth()
    else
        self.targetBackgroundScale = (frame.height) / self.background:GetImageHeight()
    end
    self.background:SetScale(self.targetBackgroundScale, self.targetBackgroundScale)
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
        self.targetForegroundScale = (self.foregroundFrame.width) / self.foreground:GetImageWidth()
    else
        self.targetForegroundScale = (self.foregroundFrame.height) / self.foreground:GetImageHeight()
    end
    self.foreground:SetScale(self.targetForegroundScale, self.targetForegroundScale)
    self.foreground.enabled = not self.disabled
    if self.disabled then
        self.foreground:SetColor(0.6, 0.6, 0.6, 0.6)
    end
    -- hidden by default
    self.background.visible = false
    self.foreground.visible = false
    self.bgx, self.bgy = self.background:GetPos()
    self.fgx, self.fgy = self.foreground:GetPos()
end

function ActionBarButton:update()
    if self.actionBarAnim then
        local ActionBar = require("states.ui.ActionBar")
        local bgx, bgy = self.bgx, self.bgy
        local fgx, fgy = self.fgx, self.fgy
        local hideBackground = false
        local scaleFactor = 1
        if self.actionBarAnim == ActionBar.animation and ActionBar.animation.position == 2 then
            self.background:SetPos(bgx, bgy - 3 * ActionBar.element.scalex)
            self.foreground:SetPos(fgx, fgy - 3 * ActionBar.element.scalex)
            scaleFactor = 0.95
            self.foreground:SetScaleY(self.foreground.scalex * 0.95)
        elseif self.actionBarAnim == ActionBar.animation and ActionBar.animation.position == 3 then
            self.background:SetPos(bgx, bgy - 8 * ActionBar.element.scalex)
            self.foreground:SetPos(fgx, fgy - 8 * ActionBar.element.scalex)
            scaleFactor = 0.92
            self.foreground:SetScaleY(self.foreground.scalex * 0.92)
        elseif self.actionBarAnim ~= ActionBar.animation and ActionBar.animation.position == 1 then
            self.background:SetPos(bgx, bgy - 13 * ActionBar.element.scalex)
            self.foreground:SetPos(fgx, fgy - 13 * ActionBar.element.scalex)
            scaleFactor = 0.80
            self.foreground:SetScaleY(self.foreground.scalex * 0.80)
        elseif self.actionBarAnim ~= ActionBar.animation and ActionBar.animation.position == 2 then
            self.background:SetPos(bgx, bgy - 20 * ActionBar.element.scalex)
            self.foreground:SetPos(fgx, fgy - 20 * ActionBar.element.scalex)
            scaleFactor = 0.63
            self.foreground:SetScaleY(self.foreground.scalex * 0.63)
        elseif self.actionBarAnim ~= ActionBar.animation and ActionBar.animation.position == 3 then
            self.background:SetPos(bgx, bgy - 21 * ActionBar.element.scalex)
            self.foreground:SetPos(fgx, fgy - 24 * ActionBar.element.scalex)
            scaleFactor = 0.53
            self.foreground:SetScaleY(self.foreground.scalex * 0.53)
        elseif self.actionBarAnim ~= ActionBar.animation and ActionBar.animation.position == 4 then
            self.background:SetPos(bgx, bgy - 17 * ActionBar.element.scalex)
            self.foreground:SetPos(fgx, fgy - 25 * ActionBar.element.scalex)
            scaleFactor = 0.24
            self.foreground:SetScaleY(self.foreground.scalex * 0.24)
        elseif self.actionBarAnim ~= ActionBar.animation and ActionBar.animation.position == 5 then
            self.background:SetPos(bgx, bgy)
            self.foreground:SetPos(fgx, fgy)
            self.foreground:SetScaleY(self.foreground.scalex)
            self.actionBarAnim = nil
            self:hide()
            ActionBar.rowBackground.visible = false
            hideBackground = true
        end
        if self.position == 1 and not hideBackground then
            ActionBar.rowBackground.visible = true
            ActionBar.rowBackground:SetPos(self.background.x - 31 * ActionBar.element.scalex, self.background.y - 27 * ActionBar.element.scalex)
            ActionBar.rowBackground:SetScale(ActionBar.rowBackground.scalex, scaleFactor)
        end
    else
        if self.actionBarAnimDown then
            local ActionBar = require("states.ui.ActionBar")
            local bgx, bgy = self.bgx, self.bgy
            local fgx, fgy = self.fgx, self.fgy
            if self.actionBarAnimDown.position == 1 then
                if self.resetOnNextFrame then
                    self.background:SetPos(bgx, bgy)
                    self.foreground:SetPos(fgx, fgy)
                    self.actionBarAnimDown = nil
                    self.resetOnNextFrame = nil
                else
                    self.background:SetPos(bgx, bgy + (49 + 10) * ActionBar.element.scalex)
                    self.foreground:SetPos(fgx, fgy + (49 + 10) * ActionBar.element.scalex)
                    self.foreground:SetScaleY(self.foreground.scalex * 0.22)
                end
            elseif self.actionBarAnimDown.position == 2 then
                self.background:SetPos(bgx, bgy + (41 + 10) * ActionBar.element.scalex)
                self.foreground:SetPos(fgx, fgy + (41 + 10) * ActionBar.element.scalex)
                self.foreground:SetScaleY(self.foreground.scalex * 0.43)
            elseif self.actionBarAnimDown.position == 3 then
                self.background:SetPos(bgx, bgy + (29 + 11) * ActionBar.element.scalex)
                self.foreground:SetPos(fgx, fgy + (29 + 11) * ActionBar.element.scalex)
                self.foreground:SetScaleY(self.foreground.scalex * 0.62)
            elseif self.actionBarAnimDown.position == 4 then
                self.background:SetPos(bgx, bgy + (17 + 8) * ActionBar.element.scalex)
                self.foreground:SetPos(fgx, fgy + (17 + 8) * ActionBar.element.scalex)
                self.foreground:SetScaleY(self.foreground.scalex * 0.79)
            elseif self.actionBarAnimDown.position == 5 then
                self.background:SetPos(bgx, bgy + 10 * ActionBar.element.scalex)
                self.foreground:SetPos(fgx, fgy + 10 * ActionBar.element.scalex)
                self.foreground:SetScaleY(self.foreground.scalex)
            elseif self.actionBarAnimDown.position == 6 then
                self.background:SetPos(bgx, bgy + (9 + 10) * ActionBar.element.scalex)
                self.foreground:SetPos(fgx, fgy + (9 + 10) * ActionBar.element.scalex)
                self.foreground:SetScaleY(self.foreground.scalex * 0.91)
            elseif self.actionBarAnimDown.position == 7 then
                self.background:SetPos(bgx, bgy + (11 + 10) * ActionBar.element.scalex)
                self.foreground:SetPos(fgx, fgy + (11 + 10) * ActionBar.element.scalex)
                self.foreground:SetScaleY(self.foreground.scalex * 0.88)
            elseif self.actionBarAnimDown.position == 8 then
                self.background:SetPos(bgx, bgy + 24 * ActionBar.element.scalex)
                self.foreground:SetPos(fgx, fgy + 24 * ActionBar.element.scalex)
            elseif self.actionBarAnimDown.position == 9 then
                self.background:SetPos(bgx, bgy + 25 * ActionBar.element.scalex)
                self.foreground:SetPos(fgx, fgy + 25 * ActionBar.element.scalex)
            elseif self.actionBarAnimDown.position == 10 then
                self.background:SetPos(bgx, bgy + 23 * ActionBar.element.scalex)
                self.foreground:SetPos(fgx, fgy + 23 * ActionBar.element.scalex)
                self.foreground:SetScaleY(self.foreground.scalex * 0.93)
            elseif self.actionBarAnimDown.position == 11 then
                self.background:SetPos(bgx, bgy + 18 * ActionBar.element.scalex)
                self.foreground:SetPos(fgx, fgy + 18 * ActionBar.element.scalex)
            elseif self.actionBarAnimDown.position == 12 then
                self.background:SetPos(bgx, bgy + 12 * ActionBar.element.scalex)
                self.foreground:SetPos(fgx, fgy + 12 * ActionBar.element.scalex)
                self.resetOnNextFrame = true
            end
        end
    end
end

function ActionBarButton:disable(tooltipText)
    self.disabled = true
    self.background.enabled = false
    self.foreground:SetColor(0.6, 0.6, 0.6, 0.6)
    if tooltipText then
        self:setTooltip(tooltipText)
    end
end

function ActionBarButton:enable()
    self.disabled = false
    self.background.enabled = true
    self.foreground:SetColor(1, 1, 1, 1)
end

function ActionBarButton:setImage(image)
    self.foreground:SetImage(image):SetOffsetX(
        image:getWidth() / 2):SetOffsetY(image:getHeight() / 2)
    if (self.foregroundFrame.width) / self.foreground:GetImageWidth() < (self.foregroundFrame.height) /
        self.foreground:GetImageHeight() then
        local s = (self.foregroundFrame.width) / self.foreground:GetImageWidth()
        self.foreground:SetScale(s, s)
    else
        local s = (self.foregroundFrame.height) / self.foreground:GetImageHeight()
        self.foreground:SetScale(s, s)
    end
    self.image = image
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
    self.background:SetPos(self.bgx, self.bgy)
    self.foreground:SetPos(self.fgx, self.fgy)
    self.foreground:SetScale(self.targetForegroundScale, self.targetForegroundScale)
    self.background:SetScale(self.targetBackgroundScale, self.targetBackgroundScale)
end

function ActionBarButton:scrollUp(actionBarAnim)
    self.actionBarAnim = actionBarAnim
    self.background.visible = true
    self.foreground.visible = true
end

function ActionBarButton:scrollDown(actionBarAnim)
    self.actionBarAnimDown = actionBarAnim
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
    -- TODO: add special hover sounds for submenus
    _G.playInterfaceSfx(ButtonFx["BuildHover"], 1)
    if not self.selected and not self.disabled then
        element:SetImage(ActionBarButton.backgroundHoverImage)
        local s = (self.frame.width) / element:GetImageWidth()
        element:SetScale(s, s)
    end
end

function ActionBarButton:onMouseExit(element)
    if not self.selected and not self.disabled then
        element:SetImage(ActionBarButton.backgroundImage)
        local s = (self.frame.width) / element:GetImageWidth()
        element:SetScale(s, s)
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
