local SID = require("objects.Controllers.LanguageController").lines

local _, ScreenHeight, _ = love.window.getMode()
local bg = love.graphics.newImage('assets/ui/loading_bar_background.png')
local fg = love.graphics.newImage('assets/ui/loading_bar_foreground.png')
local scale = (ScreenHeight * (3.5 / 100)) / bg:getHeight()
local font = love.graphics.newFont("assets/fonts/KellySlab-Regular.ttf", math.floor(18 * scale))

local textStates = {
    [1] = SID.ui.load.states.loadingTextures,
    [2] = SID.ui.load.states.initializingTerrain,
    [3] = SID.ui.load.states.updatingTerrain,
    [4] = SID.ui.load.states.updatingObjects,
    [5] = SID.ui.load.states.renderingTerrain
}

local fgPercent = {}

for i = 1, 100 do
    fgPercent[#fgPercent + 1] = love.graphics.newQuad(0, 0, fg:getWidth() * (i / 100), fg:getHeight(), fg)
end

local function renderLoadingBar(textState, percentage)
    local text = textStates[textState]
    love.graphics.push()
    love.graphics.translate((love.graphics.getWidth() / 2), (love.graphics.getHeight() / 2))
    love.graphics.draw(bg, -(bg:getWidth() / 2) * scale, ScreenHeight / 2 - (bg:getHeight() * 2) * scale, nil, scale)
    if percentage >= 1 then
        love.graphics.draw(fg, fgPercent[math.floor(percentage)], -(fg:getWidth() / 2) * scale,
            ScreenHeight / 2 - (fg:getHeight() * 2) * scale, nil, scale, scale)
    end
    local prvFont = love.graphics.getFont()
    love.graphics.setFont(font)
    love.graphics.setColor(0.916, 0.823529412, 0.631372549)
    love.graphics.print(text, -(font:getWidth(text) / 2), ScreenHeight / 2 - (bg:getHeight() * 2) * scale + ((bg:getHeight() * scale) / 2) - (font:getHeight(text) / 2))
    love.graphics.setFont(prvFont)
    love.graphics.pop()
end

return renderLoadingBar
