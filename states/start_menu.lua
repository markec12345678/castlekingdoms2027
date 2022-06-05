local startMenu = {}
require("states.ui.init")
local loveframes = require("libraries.loveframes")
local states = require("states.ui.states")
local renderLoadingScreen = require("states.ui.loading_screen")

function startMenu:enter()
    loveframes.SetState(states.STATE_MAIN_MENU)
end

local framesFromStart = 0
function startMenu:update(dt)
    if framesFromStart < 30 then
        framesFromStart = framesFromStart + 1
        if framesFromStart == 30 then
            _G.playSpeech("General_Startgame")
        end
    end
    loveframes.update()
end

function startMenu:draw()
    renderLoadingScreen("")
    loveframes.draw()
    love.graphics.print(_G.version, _G.ScreenWidth - love.graphics.getFont():getWidth(_G.version .. "----"),
        _G.ScreenHeight - love.graphics.getFont():getHeight() * 2)
end

function startMenu:mousepressed(x, y, button)
    loveframes.mousepressed(x, y, button)
end

function startMenu:mousereleased(x, y, button)
    loveframes.mousereleased(x, y, button)
end

return startMenu
