local main_menu = {}
local Gamestate = require('libraries.gamestate')
local game = require('states.game')
local terrain = require('terrain.terrain')
local counter, stringLoop = 0, 1
local loadingString = {
    'Loading',
    'Loading.',
    'Loading..',
    'Loading...',   
}

function main_menu:init()
    main_menu.logo = love.graphics.newImage('assets/other/sk_logo_medium.png')
    terrain.allocateSpriteBatches()
end

function main_menu:update(dt)
    counter = (counter + 1) % 21
    print(counter)
    if counter == 20 then 
        stringLoop = (stringLoop % 4) + 1
    end
    if love.keyboard.isDown("escape")  then
        love.event.quit();
    end
    if object_image then
        Gamestate.switch(game)
    end
end

function main_menu:draw()
    love.graphics.draw(main_menu.logo, 100, 100)
    love.graphics.print(loadingString[stringLoop], 105, 225)
    limitfps()
end

return main_menu