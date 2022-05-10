local mainMenu = {}
require('states.ui.init')
local loveframes = require('libraries.loveframes')
local states = require('states.ui.states')
local renderLoadingScreen = require('states.ui.loading_screen')

function mainMenu:enter()
    loveframes.SetState(states.STATE_MAIN_MENU)
end

function mainMenu:update(dt)
    loveframes.update()
end

function mainMenu:draw()
    renderLoadingScreen("")
    loveframes.draw()
end

function mainMenu:mousepressed(x, y, button)
    loveframes.mousepressed(x, y, button)
end

function mainMenu:mousereleased(x, y, button)
    loveframes.mousereleased(x, y, button)
end

return mainMenu
