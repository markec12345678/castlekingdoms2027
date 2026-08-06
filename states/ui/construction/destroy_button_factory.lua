local states = require("states.ui.states")
local ActionBarButton = require("states.ui.ActionBarButton")
local ActionBar = require("states.ui.ActionBar")
local SID = require("objects.Controllers.LanguageController").lines

return function()
    local destroyButton = ActionBarButton:new(love.graphics.newImage("assets/ui/cursor_destroy.png"),
        states.STATE_INGAME_CONSTRUCTION, 11)
    destroyButton:setTooltip(SID.groups.destroy.name, SID.groups.destroy.description)
    destroyButton:setOnClick(function(self)
        ActionBar:unselectAll()
        local enabled = _G.DestructionController:toggle()
        if enabled then
            destroyButton:setTooltip(SID.groups.destroy.exitTooltip, SID.groups.destroy.exitTooltip)
            ActionBar:selectButton(destroyButton)
        end
    end)

    destroyButton:setOnUnselect(function(self)
        destroyButton:setTooltip(SID.groups.destroy.name, SID.groups.destroy.description)
        _G.DestructionController:disable()
    end)
    return destroyButton
end
