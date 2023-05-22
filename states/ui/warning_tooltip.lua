local loveframes = require("libraries.loveframes")
local states = require("states.ui.states")
local w, h = love.graphics.getDimensions()
local colorRed = { 200 / 255, 90 / 255, 90 / 255, 1 }

local warningTooltip = loveframes.Create("image")
warningTooltip:SetState(states.STATE_INGAME_CONSTRUCTION)
warningTooltip:SetPos(0, 0)
warningTooltip:SetSize(w, h * 0.9)
warningTooltip:setTooltip("")
warningTooltip.tooltip.visible = false

function warningTooltip.ShowTooltip(self, text)
    if self.tooltip.visible and text == self.rawtext then return end
    self:setTooltip({ {
        color = colorRed
    }, text })
    self.disablehover = false
    self.rawtext = text
    self.visible = true
    self.tooltip.visible = true
    self.tooltip:update()
end

function warningTooltip.HideTooltip(self)
    self.disablehover = true
    self.visible = false
    self.tooltip.visible = false
end

warningTooltip:HideTooltip()

return warningTooltip
