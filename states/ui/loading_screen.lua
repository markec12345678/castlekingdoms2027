local background
local ScreenWidth, ScreenHeight, _ = love.window.getMode()
if ScreenHeight > 2000 then
    background = love.graphics.newImage('assets/other/stronghold_4k_background.png')
else
    background = love.graphics.newImage('assets/other/stronghold_2k_background.png')
end
local bgScaleX = ScreenWidth / background:getWidth()
local bgScaleY = ScreenHeight / background:getHeight()
local bgScale = math.min(bgScaleX, bgScaleY)
local logo = love.graphics.newImage('assets/other/sk_logo_medium.png')

local function renderLoadingScreen(loadingString)
    love.graphics.push()
    love.graphics.translate((love.graphics.getWidth() / 2), (love.graphics.getHeight() / 2))
    love.graphics.draw(background, -(background:getWidth() / 2) * bgScale, -(background:getHeight() / 2) * bgScale, nil,
        bgScale)
    love.graphics.draw(logo, -(logo:getWidth() / 2), -(logo:getHeight() / 4) - (love.graphics.getHeight() / 2) + 50)
    love.graphics.print(loadingString, -15, (love.graphics.getHeight() / 2) - 90)
    love.graphics.pop()
end

return renderLoadingScreen
