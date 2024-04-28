local states = require("states.ui.states")
local ActionBarButton = require("states.ui.ActionBarButton")
local ActionBar = require("states.ui.ActionBar")

return function()
    local backButton = ActionBarButton:new(love.graphics.newImage("assets/ui/back_ab.png"), states.STATE_INGAME_CONSTRUCTION,
        12)
    backButton:setOnClick(function(self)
        ActionBar:showGroup("main")
        if not _G.BuildController.start then
            _G.BuildController:disable()
            if _G.BuildController.onBuildCallback then
                _G.BuildController.onBuildCallback()
                _G.BuildController.onBuildCallback = nil
                ActionBar:unselectAll()
            end
        end
    end)
    return backButton
end
