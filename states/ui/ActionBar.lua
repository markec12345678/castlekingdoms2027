local loveframes = require('libraries.loveframes')
local states = require('states.ui.states')
local base = require('states.ui.base')
local w, h = base.w, base.h

local ACTION_BAR_USER_SCALE_W = 60
local ACTION_BAR_USER_SCALE_H = 20

if ACTION_BAR_USER_SCALE_W > 100 or ACTION_BAR_USER_SCALE_W < 5 then
    error("Action bar scale must be between 5 and 100")
end

local ActionBar = _G.class("ActionBar")
ActionBar.static.action_bar_image = love.graphics.newImage('assets/ui/action_bar.png')
function ActionBar:initialize()
    local element = loveframes.Create("image")
    element:SetState(states.STATE_INGAME_CONSTRUCTION)
    element:SetImage(ActionBar.action_bar_image)
    element:SetOffsetX(element:GetImageWidth() / 2)
    local scale_1 = (w.percent[ACTION_BAR_USER_SCALE_W]) / ActionBar.action_bar_image:getWidth()
    local scale_2 = (h.percent[ACTION_BAR_USER_SCALE_H]) / ActionBar.action_bar_image:getHeight()
    local scale = math.min(scale_1, scale_2)
    element:SetScale(scale, scale)
    element:SetPos(w.percent[50], h.percent[100] - element:GetImageHeight() * element:GetScaleY())
    self.element = element
    self.groups = {}
    self.current_group = "main"
end
function ActionBar:select_button(element)
    if not element.background.visible then
        error("trying to select an invisible button")
    end
    for _, el in ipairs(self.groups[element.group]) do
        el:unselect()
    end
    element:select()
end
function ActionBar:register_group(name, list_of_elements)
    self.groups[name] = list_of_elements
    for _, v in ipairs(list_of_elements) do
        v.group = name
    end
end
function ActionBar:hide_group(name)
    for _, el in ipairs(self.groups[name]) do
        el:hide()
    end
end
function ActionBar:show_group(name)
    self.current_group = name
    for k, elements in pairs(self.groups) do
        if k == name then
            for _, el in ipairs(elements) do
                el:show()
            end
        else
            self:hide_group(k)
        end
    end
end
function ActionBar:hide()
    self.element.visible = false
end
function ActionBar:show()
    self.element.visible = true
end
return ActionBar:new()
