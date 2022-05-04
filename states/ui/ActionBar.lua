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
ActionBar.static.actionBarImage = love.graphics.newImage('assets/ui/action_bar.png')
function ActionBar:initialize()
    local element = loveframes.Create("image")
    element:SetState(states.STATE_INGAME_CONSTRUCTION)
    element:SetImage(ActionBar.actionBarImage)
    element:SetOffsetX(element:GetImageWidth() / 2)
    local scale_1 = (w.percent[ACTION_BAR_USER_SCALE_W]) / ActionBar.actionBarImage:getWidth()
    local scale_2 = (h.percent[ACTION_BAR_USER_SCALE_H]) / ActionBar.actionBarImage:getHeight()
    local scale = math.min(scale_1, scale_2)
    element:SetScale(scale, scale)
    element:SetPos(w.percent[50], h.percent[100] - element:GetImageHeight() * element:GetScaleY())
    self.element = element
    self.groups = {}
    self.currentGroup = "main"
end
function ActionBar:activateButton(position)
    if self.groups[self.currentGroup] then
        local button = self.groups[self.currentGroup][position]
        if button then
            button:press()
        end
    end
end
function ActionBar:keypressed(key, scancode)
    if key == "1" then
        self:activateButton(1)
    elseif key == "2" then
        self:activateButton(2)
    elseif key == "3" then
        self:activateButton(3)
    elseif key == "4" then
        self:activateButton(4)
    elseif key == "5" then
        self:activateButton(5)
    elseif key == "6" then
        self:activateButton(6)
    elseif key == "7" then
        self:activateButton(7)
    elseif key == "8" then
        self:activateButton(8)
    elseif key == "9" then
        self:activateButton(9)
    elseif key == "0" then
        self:activateButton(10)
    elseif key == "-" then
        self:activateButton(11)
    elseif key == "=" or key == "`" then
        self:activateButton(12)
    end
end
function ActionBar:selectButton(element)
    if not element.background.visible then
        error("trying to select an invisible button")
    end
    for _, el in ipairs(self.groups[element.group]) do
        el:unselect()
    end
    element:select()
end
function ActionBar:registerGroup(name, listOfElements)
    self.groups[name] = {}
    for _, v in ipairs(listOfElements) do
        v.group = name
        self.groups[name][v.position] = v
    end
end
function ActionBar:hideGroup(name)
    for _, el in pairs(self.groups[name]) do
        el:hide()
    end
end
function ActionBar:showGroup(name)
    self.currentGroup = name
    for k, _ in pairs(self.groups) do
        if k ~= name then
            self:hideGroup(k)
        end
    end
    if name then
        for _, el in pairs(self.groups[name]) do
            el:show()
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
