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
    nk.frameBegin()
    if nk.windowBegin('Stone Kingdoms', window_width/2 - 100, 120, 200, 160, 'border') then
        nk.layoutRow('dynamic', 30, 1)
        nk.label('Stone Kingdoms','centered')
        nk.layoutRow('dynamic', 10, 1)
        nk.layoutRow('dynamic', 30, 1)

        if nk.button('Play') then
            Gamestate.switch(game)
        end

        nk.layoutRow('dynamic', 10, 1)
        nk.layoutRow('dynamic', 30, 1)

        if nk.button('Exit') then
            love.event.quit()
        end
    end
    nk.windowEnd()
    nk.frameEnd()
    
    counter = (counter + 1) % 601
    if counter == 600 then 
        stringLoop = (stringLoop % 4) + 1
    end
end

function main_menu:draw()
    if not object_image then
	    love.graphics.draw(main_menu.logo, 100, 100)
	    love.graphics.print(loadingString[stringLoop], 105, 225)
    else
	    nk.draw()
    end
    limitfps()
end

function main_menu:keypressed(key, scancode, isrepeat)
	nk.keypressed(key, scancode, isrepeat)
end

function main_menu:keyreleased(key, scancode)
	nk.keyreleased(key, scancode)
end

function main_menu:mousepressed(x, y, button, istouch)
	nk.mousepressed(x, y, button, istouch)
end

function main_menu:mousereleased(x, y, button, istouch)
	nk.mousereleased(x, y, button, istouch)
end

function main_menu:mousemoved(x, y, dx, dy, istouch)
	nk.mousemoved(x, y, dx, dy, istouch)
end

function main_menu:textinput(text)
	nk.textinput(text)
end

function main_menu:wheelmoved(x, y)
	nk.wheelmoved(x, y)
end

return main_menu