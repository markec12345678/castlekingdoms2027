local loadingScreen = {}
local Gamestate = require("libraries.gamestate")
local game = require("states.game")
local renderLoadingScreen = require("states.ui.loading_screen")
local renderLoadingBar = require("states.ui.loading_bar")

function loadingScreen:update(dt)
    if _G.objectAtlas then
        Gamestate.switch(game)
    end
end

function loadingScreen:draw()
    renderLoadingScreen("")
    renderLoadingBar(1, 10)
end

return loadingScreen
