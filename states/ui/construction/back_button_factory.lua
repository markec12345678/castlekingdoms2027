local states = require("states.ui.states")
local ActionBarButton = require("states.ui.ActionBarButton")
local ActionBar = require("states.ui.ActionBar")

return function()
    local backButton = ActionBarButton:new(love.graphics.newImage("assets/ui/back_ab.png"), states.STATE_INGAME_CONSTRUCTION,
        12)
    backButton:setTooltip("Back", "Return to main construction menu")
    backButton:setOnClick(function(self)
        -- Stronghold 2027: Use skipAnimation=true to force immediate switch
        -- This bypasses the animation queue which can get stuck
        pcall(function()
            ActionBar:showGroup("main", nil, true)
        end)
        -- Force-hide all other groups immediately
        pcall(function()
            for k, _ in pairs(ActionBar.groups) do
                if k ~= "main" then
                    ActionBar:hideGroup(k)
                end
            end
            -- Show main group buttons
            if ActionBar.groups["main"] then
                for _, el in pairs(ActionBar.groups["main"]) do
                    pcall(function() el:show(true) end)
                end
            end
        end)
        -- Reset action bar image
        pcall(function()
            if ActionBar.element then
                ActionBar.element:SetImage(ActionBar.actionBarImage)
            end
        end)
        -- Disable build controller if active
        if not _G.BuildController.start then
            pcall(function() _G.BuildController:disable() end)
            if _G.BuildController.onBuildCallback then
                pcall(function() _G.BuildController.onBuildCallback() end)
                _G.BuildController.onBuildCallback = nil
                pcall(function() ActionBar:unselectAll() end)
            end
        end
        -- Force animation to paused state
        pcall(function()
            if ActionBar.firstAnimation then ActionBar.firstAnimation:pause() end
            if ActionBar.secondAnimation then ActionBar.secondAnimation:pause() end
        end)
    end)
    return backButton
end
