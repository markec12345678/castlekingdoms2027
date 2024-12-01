--[[
The MIT License (MIT)

Copyright (c) 2014 Marcus Ihde

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]
-- Edited to only include tiltshift
if _G.testMode then return end
LOVE_POSTSHADER_BUFFER_RENDER = love.graphics.newCanvas()
LOVE_POSTSHADER_BUFFER_BACK_SWITCH = love.graphics.newCanvas()
LOVE_POSTSHADER_BUFFER_BACK = love.graphics.newCanvas()
LOVE_POSTSHADER_LAST_BUFFER = nil

LOVE_POSTSHADER_BLURV = love.graphics.newShader("shaders/blurv.glsl")
LOVE_POSTSHADER_BLURH = love.graphics.newShader("shaders/blurh.glsl")
LOVE_POSTSHADER_TILT_SHIFT = love.graphics.newShader("shaders/tiltshift.glsl")

love.postshader = {}

love.postshader.setBuffer = function(path)
    if path == "back" then
        love.graphics.setCanvas(LOVE_POSTSHADER_BUFFER_BACK)
    else
        love.graphics.setCanvas({ LOVE_POSTSHADER_BUFFER_RENDER, depth = true })
    end
    local r, g, b, a = love.graphics.getBackgroundColor()
    love.graphics.clear(r, g, b, a, false, 0)
    LOVE_POSTSHADER_LAST_BUFFER = love.graphics.getCanvas()
end

love.postshader.addTiltshift = function(steps)
    LOVE_POSTSHADER_LAST_BUFFER = love.graphics.getCanvas()

    love.graphics.setCanvas(LOVE_POSTSHADER_BUFFER_BACK)
    love.graphics.setBlendMode("alpha")

    -- Blur Shader
    LOVE_POSTSHADER_BLURV:send("screen", { love.graphics.getWidth(), love.graphics.getHeight() })
    LOVE_POSTSHADER_BLURH:send("screen", { love.graphics.getWidth(), love.graphics.getHeight() })
    LOVE_POSTSHADER_BLURV:send("steps", steps)
    LOVE_POSTSHADER_BLURH:send("steps", steps)

    love.graphics.setShader(LOVE_POSTSHADER_BLURV)
    love.graphics.draw(LOVE_POSTSHADER_BUFFER_RENDER)

    love.graphics.setCanvas(LOVE_POSTSHADER_BUFFER_BACK_SWITCH)
    love.graphics.setShader(LOVE_POSTSHADER_BLURH)
    love.graphics.draw(LOVE_POSTSHADER_BUFFER_BACK)

    love.graphics.setCanvas(LOVE_POSTSHADER_BUFFER_BACK)
    LOVE_POSTSHADER_TILT_SHIFT:send("imgBuffer", LOVE_POSTSHADER_BUFFER_RENDER)
    love.graphics.setShader(LOVE_POSTSHADER_TILT_SHIFT)
    love.graphics.draw(LOVE_POSTSHADER_BUFFER_BACK_SWITCH)

    love.graphics.setBlendMode("alpha")
    love.graphics.setCanvas(LOVE_POSTSHADER_LAST_BUFFER)
    love.graphics.setShader()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(LOVE_POSTSHADER_BUFFER_BACK)
end

love.postshader.draw = function()
    if LOVE_POSTSHADER_LAST_BUFFER then
        love.graphics.setBackgroundColor(26 / 255, 26 / 255, 26 / 255, 1)
        love.graphics.setBlendMode("alpha")
        love.graphics.setCanvas()
        love.graphics.setShader()
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(LOVE_POSTSHADER_LAST_BUFFER)
    end
end

love.postshader.refreshScreenSize = function()
    LOVE_POSTSHADER_BUFFER_RENDER = love.graphics.newCanvas()
    LOVE_POSTSHADER_BUFFER_BACK = love.graphics.newCanvas()
end
