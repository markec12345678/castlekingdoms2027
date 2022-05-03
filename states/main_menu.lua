local mainMenu = {}
local Gamestate = require('libraries.gamestate')
local game = require('states.game')
local counter, stringLoop = 0, 1
local loadingString = {'Loading', 'Loading.', 'Loading..', 'Loading...'}
local renderLoadingScreen = require('states.ui.loading_screen')

function mainMenu:update(dt)
    counter = counter + 1
    if counter >= 10 then
        stringLoop = (stringLoop % 4) + 1
        counter = 0
    end
    if love.keyboard.isDown("escape") then
        love.event.quit()
    end
    if objectAtlas then
        Gamestate.switch(game)
    end
end

function mainMenu:draw()
    renderLoadingScreen(loadingString[stringLoop])
end

return mainMenu
