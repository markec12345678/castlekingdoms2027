local _, ScreenHeight, _ = love.window.getMode()
local bg = love.graphics.newImage('assets/ui/loading_bar_background.png')
local fg = love.graphics.newImage('assets/ui/loading_bar_foreground.png')
local scale = (ScreenHeight * (3.5 / 100)) / bg:getHeight()

local textStates = {
    [1] = love.graphics.newImage("assets/ui/loading_text_1.png"),
    [2] = love.graphics.newImage("assets/ui/loading_text_2.png"),
    [3] = love.graphics.newImage("assets/ui/loading_text_3.png"),
    [4] = love.graphics.newImage("assets/ui/loading_text_4.png"),
    [5] = love.graphics.newImage("assets/ui/loading_text_5.png")
}

local fgPercent = {}

for i = 1, 100 do
    fgPercent[#fgPercent + 1] = love.graphics.newQuad(0, 0, fg:getWidth() * (i / 100), fg:getHeight(), fg)
end

local function renderLoadingBar(textState, percentage)
    local textImage = textStates[textState]
    love.graphics.push()
    love.graphics.translate((love.graphics.getWidth() / 2), (love.graphics.getHeight() / 2))
    love.graphics.draw(bg, -(bg:getWidth() / 2) * scale, ScreenHeight / 2 - (bg:getHeight() * 2) * scale, nil, scale)
    if percentage >= 1 then
        love.graphics.draw(fg, fgPercent[math.floor(percentage)], -(fg:getWidth() / 2) * scale,
            ScreenHeight / 2 - (fg:getHeight() * 2) * scale, nil, scale, scale)
    end
    love.graphics.draw(textImage, -(textImage:getWidth() / 2) * scale,
        ScreenHeight / 2 - (fg:getHeight() * 2) * scale + 10 * scale, nil, scale)
    love.graphics.pop()
end

return renderLoadingBar
