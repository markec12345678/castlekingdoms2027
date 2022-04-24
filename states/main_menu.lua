local main_menu = {}
local Gamestate = require('libraries.gamestate')
local game = require('states.game')
local counter, stringLoop = 0, 1
local loadingString = {'Loading', 'Loading.', 'Loading..', 'Loading...'}
local renderLoadingScreen = require('states.ui.loading_screen')

function main_menu:update(dt)
    counter = counter + 1
    if counter >= 10 then
        stringLoop = (stringLoop % 4) + 1
        counter = 0
    end
    if love.keyboard.isDown("escape") then
        love.event.quit()
    end
    if object_image then
        Gamestate.switch(game)
    end
end

function main_menu:draw()
    renderLoadingScreen(loadingString[stringLoop])
end

return main_menu
