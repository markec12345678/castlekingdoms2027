local startMenu = {}
require("states.ui.init")
local loveframes = require("libraries.loveframes")
local states = require("states.ui.states")
local renderLoadingScreen = require("states.ui.loading_screen")
local playlist = require("sounds.music_playlist")
local console = require "libraries.console"
console.addCommand("debug", function()
    local haslldebugger, lldebugger = pcall(require, "lldebugger")
    if haslldebugger then
        lldebugger.start()
        print("Debugger attached!")
    else
        print("Couldn't enable debug.")
        print("You need to start the game using VSCode Run and Debug in order to use the debugger!")
    end
end, "Attach VSCode debugger")

local startMenuFadeIn = 1.5
local startMenuDisplay = 4

local startMenuTimer = 0
local startMenuAplha = 0


function startMenu:enter()
    loveframes.SetState(states.STATE_MAIN_MENU)
    playlist("menu")
end

function startMenu:textinput(text)
    console.textinput(text)
end

local framesFromStart = 0
function startMenu:update(dt)
    if _G.objectAtlas then
        startMenuTimer = startMenuTimer + dt
    end
    if 0 < startMenuTimer and startMenuTimer < startMenuFadeIn then
        startMenuAplha = startMenuTimer / startMenuFadeIn
    end
    if startMenuFadeIn < startMenuTimer and startMenuTimer < startMenuDisplay then
        startMenuAplha = 1
    end

    if framesFromStart < 30 then
        framesFromStart = framesFromStart + 1
        if framesFromStart == 30 then
            _G.playSpeech("General_Startgame")
        end
    end
    loveframes.update()
end

function startMenu:draw()
    renderLoadingScreen("", startMenuAplha)
    love.graphics.setColor(1, 1, 1, 1)
    if _G.objectAtlas then
        loveframes.draw()
    else
        local screenWidth = love.graphics.getWidth()
        local screenHeight = love.graphics.getHeight()

        local textWidth = love.graphics.getFont():getWidth("Loading textures...")
        local textHeight = love.graphics.getFont():getHeight()

        local x = (screenWidth - textWidth) / 2
        local y = (screenHeight - textHeight) / 2

        love.graphics.print("Loading textures...", x, y)
    end
    love.graphics.print(_G.version, _G.ScreenWidth - love.graphics.getFont():getWidth(_G.version .. "----"),
        _G.ScreenHeight - love.graphics.getFont():getHeight() * 2)
    console.draw()
end

function startMenu:keypressed(key, scancode, isRepeat)
    if love.keyboard.isScancodeDown("`") and love.keyboard.isScancodeDown("lshift") then
        console:toggleEnable()
        return
    end
    if console.isEnabled() then
        console.keypressed(key, scancode, isRepeat)
        return
    end
end

function startMenu:mousepressed(x, y, button)
    loveframes.mousepressed(x, y, button)
end

function startMenu:mousereleased(x, y, button)
    loveframes.mousereleased(x, y, button)
end

return startMenu
