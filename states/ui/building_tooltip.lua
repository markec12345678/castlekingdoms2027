local loveframes = require("libraries.loveframes")
local states = require("states.ui.states")
local w, h = love.graphics.getDimensions()
local buildingHover = loveframes.Create("image")
buildingHover:SetState(states.STATE_INGAME_CONSTRUCTION)
buildingHover:SetPos(0, 0)
buildingHover:SetSize(w, h * 0.9)
buildingHover:setTooltip("")
buildingHover.tooltip.visible = false
function buildingHover.ShowTooltip(self, text, paragraph)
    if self.tooltip.visible then return end
    self.disablehover = false
    self.visible = true
    self.tooltip.visible = true
    if paragraph then
        self:setTooltip(text, paragraph)
    else
        self:setTooltip(text)
    end
end

function buildingHover.HideTooltip(self)
    self.disablehover = true
    self.visible = false
    self.tooltip.visible = false
end

return buildingHover
