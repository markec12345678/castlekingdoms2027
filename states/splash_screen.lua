local splashScreen = {}
local one_ten_one = require("libraries.o-ten-one")
local Gamestate = require("libraries.gamestate")
local startMenu = require("states.start_menu")
local config = require("config_file")

local isOTenOne = false

local skLogo = love.graphics.newImage("assets/other/sk_logo_large.png")
local skLogoScaleFactor

local skFadeIn = 1.5
local skDisplay = 4
local skFadeOut = 5.5

local skTimer = 0
local skAlpha = 0

local splashScreenFont = love.graphics.newFont("assets/fonts/IMMORTAL.ttf", 24)
local fireflyNotice =
"Assets, Music & Sound effects provided at the courtesy of Firefly Studios Limited.\n Features additional art by Lord Steinhauer, Monsterfish and Zarentreuer Lenin\n    Thanks to UCP team and Project Reconquista for technical support."
local repoLink = "https://gitlab.com/stone-kingdoms/stone-kingdoms"

function splashScreen:enter()
    local logoWidth, logoHeight = skLogo:getDimensions()
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local logoScaleX, logoScaleY
    -- The logo shouldn't take more than 70% of the horizontal space
    logoScaleX = screenWidth / (logoWidth * 1.3)
    -- The logo shouldn't take more than 2.5x of it's height in the vertical space
    logoScaleY = screenHeight / (logoHeight * 2.5)
    -- Choose whichever is smaller and the logo will never go outside the screen
    -- on both dimensions
    skLogoScaleFactor = math.min(logoScaleX, logoScaleY)

    if config.general.skipSplashScreen then
        splashScreen:finish()
    else
        -- Stronghold 2027: pcall to catch LFS pointer crashes in splash library
        local splashOk, splashErr = pcall(function()
            isOTenOne = true
            splashScreen.splash = one_ten_one({
                background = { 0, 0, 0 },
                delay_after = 0.5
            })
            splashScreen.splash.onDone = function()
                isOTenOne = false
            end
        end)
        if not splashOk then
            print("Splash screen skipped due to error: " .. tostring(splashErr))
            isOTenOne = false
            skTimer = skFadeOut + 1
        end
    end
end

function splashScreen:update(dt)
    if isOTenOne then
        splashScreen.splash:update(dt)
    else
        skTimer = skTimer + dt
        if 0 < skTimer and skTimer < skFadeIn then
            skAlpha = skTimer / skFadeIn
        end
        if skFadeIn < skTimer and skTimer < skDisplay then
            skAlpha = 1
        end
        if skDisplay < skTimer and skTimer < skFadeOut then
            skAlpha = 1 - ((skTimer - skDisplay) / (skFadeOut - skDisplay))
        end
        if skTimer > skFadeOut then
            splashScreen:finish()
        end
    end
end

function splashScreen:draw()
    if isOTenOne then
        splashScreen.splash:draw()
    else
        love.graphics.setColor(255, 255, 255, skAlpha)

        local skLogoX = (love.graphics.getWidth() / 2) - (skLogo:getWidth() / 2 * skLogoScaleFactor)
        local skLogoY = (love.graphics.getHeight() / 2) - skLogo:getHeight() * skLogoScaleFactor
        love.graphics.draw(skLogo, skLogoX, skLogoY, 0, skLogoScaleFactor, skLogoScaleFactor)

        local fireflyNoticeX = (love.graphics.getWidth() / 2) - (splashScreenFont:getWidth(fireflyNotice) / 2)
        local fireflyNoticeY = love.graphics.getHeight() - (love.graphics.getHeight() / 5)
        love.graphics.print(fireflyNotice, splashScreenFont, fireflyNoticeX, fireflyNoticeY, 0)
        local repoLinkX = (love.graphics.getWidth() / 2) - (splashScreenFont:getWidth(repoLink) / 2)
        local repoLinkY = fireflyNoticeY + splashScreenFont:getHeight() * 3
        love.graphics.print(repoLink, splashScreenFont, repoLinkX, repoLinkY, 0)
    end
end

function splashScreen:keyreleased(key)
    if key == "escape" then
        if isOTenOne then
            splashScreen.splash:skip()
        end
        splashScreen:finish()
    end
end

function splashScreen:mousereleased()
    if isOTenOne then
        splashScreen.splash:skip()
    end
    splashScreen:finish()
end

function splashScreen:finish()
    Gamestate.switch(startMenu)
end

return splashScreen
