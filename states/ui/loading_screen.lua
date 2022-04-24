local background
local ScreenWidth, ScreenHeight, _ = love.window.getMode()
local textOffsetX, textOffsetY
if ScreenHeight > 2000 then
    love.graphics.setFont(love.graphics.newFont(32))
    textOffsetX, textOffsetY = -30, -180
    background = love.graphics.newImage('assets/other/stronghold_4k_background.png')
else
    textOffsetX, textOffsetY = -15, -90
    background = love.graphics.newImage('assets/other/stronghold_2k_background.png')
end
local bgScaleX = ScreenWidth / background:getWidth()
local bgScaleY = ScreenHeight / background:getHeight()
local bgScale = math.min(bgScaleX, bgScaleY)
local logo = love.graphics.newImage('assets/other/sk_logo_medium.png')
local logoScale = (ScreenHeight * (10 / 100)) / logo:getHeight()

local function renderLoadingScreen(loadingString)
    love.graphics.push()
    love.graphics.translate((love.graphics.getWidth() / 2), (love.graphics.getHeight() / 2))
    love.graphics.draw(background, -(background:getWidth() / 2) * bgScale, -(background:getHeight() / 2) * bgScale, nil,
        bgScale)
    love.graphics.draw(logo, -(logo:getWidth() / 2) * logoScale, -(love.graphics.getHeight() / 2) + 50, nil, logoScale)
    love.graphics.print(loadingString, textOffsetX, (love.graphics.getHeight() / 2) + textOffsetY)
    love.graphics.pop()
end

return renderLoadingScreen
