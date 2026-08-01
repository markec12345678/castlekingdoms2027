-- states/ui/hud/credits_screen.lua
-- Stronghold 2027 - Credits Screen
--
-- Shows scrolling credits when campaign is completed.
-- Press ESC or click to skip.

local CreditsScreen = {}

local visible = false
local scrollY = 0
local scrollSpeed = 50  -- pixels per second
local alpha = 0

-- Credits content
local CREDITS = {
    { type = "title", text = "STRONGHOLD 2027" },
    { type = "subtitle", text = "The Lord of Fernhaven" },
    { type = "spacer" },
    { type = "header", text = "RAZVOJ" },
    { type = "name", text = "markec12345678" },
    { type = "role", text = "Glavni razvijalec" },
    { type = "spacer" },
    { type = "header", text = "ZGODBA" },
    { type = "name", text = "Sir Markus" },
    { type = "role", text = "Lord of Fernhaven" },
    { type = "name", text = "Lady Elara" },
    { type = "role", text = "Zaveznica Westmarsha" },
    { type = "name", text = "Lord Draven" },
    { type = "role", text = "Antagonist" },
    { type = "name", text = "Brother Cedric" },
    { type = "role", text = "Mentor in svetovalec" },
    { type = "name", text = "Captain Roric" },
    { type = "role", text = "Vojaški poveljnik" },
    { type = "spacer" },
    { type = "header", text = "POVZETEK KAMPANJE" },
    { type = "text", text = "1. Vrnitev v Fernhaven" },
    { type = "text", text = "2. Prvi branilci" },
    { type = "text", text = "3. Zavezništvo z Westmarshem" },
    { type = "text", text = "4. Železni griči" },
    { type = "text", text = "5. Banditski kralj" },
    { type = "text", text = "6. Izdaja pri Eastvalu" },
    { type = "text", text = "7. Severni prelaz" },
    { type = "text", text = "8. Katedrala" },
    { type = "text", text = "9. Žrtev Lady Elare" },
    { type = "text", text = "10. Prestol Valdemarja" },
    { type = "spacer" },
    { type = "header", text = "ZAHVALE" },
    { type = "text", text = "Firefly Studios" },
    { type = "role", text = "Za originalno igro Stronghold in dovoljenje za asset-e" },
    { type = "text", text = "Stone Kingdoms ekipa" },
    { type = "role", text = "Za odprtokodno bazo in vzdrževanje projekta" },
    { type = "text", text = "LÖVE community" },
    { type = "role", text = "Za odličen game engine" },
    { type = "text", text = "Crowdin prevajalci" },
    { type = "role", text = "Za prevode v 16 jezikov" },
    { type = "spacer" },
    { type = "header", text = "TEHNOLOGIJE" },
    { type = "text", text = "LÖVE 11.5 (Lua)" },
    { type = "text", text = "Git LFS za binarne datoteke" },
    { type = "text", text = "GitHub Actions za CI/CD" },
    { type = "text", text = "GLSL shaderji za vizualne efekti" },
    { type = "spacer" },
    { type = "header", text = "POVZETEK PROJEKTA" },
    { type = "text", text = "280+ Lua datotek" },
    { type = "text", text = "213,000+ vrstic kode" },
    { type = "text", text = "71 zgradb, 42 enot" },
    { type = "text", text = "16 podprtih jezikov" },
    { type = "text", text = "10 misij kampanje" },
    { type = "text", text = "4 AI osebnosti, 4 težavnosti" },
    { type = "spacer" },
    { type = "spacer" },
    { type = "title", text = "HVALA ZA IGRANJE!" },
    { type = "subtitle", text = "Sir Markus je postal Kralj Valdemarja" },
    { type = "spacer" },
    { type = "spacer" },
    { type = "text", text = "Stronghold 2027" },
    { type = "text", text = "Apache 2.0 License" },
    { type = "text", text = "github.com/markec12345678/stronghold2027" },
}

function CreditsScreen.show()
    visible = true
    scrollY = 0
    alpha = 0
end

function CreditsScreen.hide()
    visible = false
end

function CreditsScreen.isVisible()
    return visible
end

function CreditsScreen.update(dt)
    if not visible then return end
    scrollY = scrollY + scrollSpeed * dt
    alpha = math.min(1, alpha + dt * 1.5)

    -- Auto-hide when credits finish
    local totalHeight = #CREDITS * 30 + 200
    if scrollY > totalHeight + love.graphics.getHeight() then
        CreditsScreen.hide()
    end
end

function CreditsScreen.draw()
    if not visible then return end

    local screenW, screenH = love.graphics.getDimensions()

    -- Dark background
    love.graphics.setColor(0, 0, 0, alpha * 0.9)
    love.graphics.rectangle("fill", 0, 0, screenW, screenH)

    -- Scroll credits
    local startY = screenH - scrollY
    local y = startY
    local centerX = screenW / 2

    for _, entry in ipairs(CREDITS) do
        if entry.type == "title" then
            love.graphics.setColor(1, 0.85, 0.3, alpha)
            local font = love.graphics.getFont()
            local w = font:getWidth(entry.text)
            love.graphics.print(entry.text, centerX - w / 2, y)
            y = y + 50
        elseif entry.type == "subtitle" then
            love.graphics.setColor(0.8, 0.8, 0.8, alpha)
            local font = love.graphics.getFont()
            local w = font:getWidth(entry.text)
            love.graphics.print(entry.text, centerX - w / 2, y)
            y = y + 35
        elseif entry.type == "header" then
            love.graphics.setColor(0.6, 0.5, 0.3, alpha)
            local font = love.graphics.getFont()
            local w = font:getWidth(entry.text)
            love.graphics.print(entry.text, centerX - w / 2, y)
            y = y + 30
        elseif entry.type == "name" then
            love.graphics.setColor(1, 1, 1, alpha)
            local font = love.graphics.getFont()
            local w = font:getWidth(entry.text)
            love.graphics.print(entry.text, centerX - w / 2, y)
            y = y + 20
        elseif entry.type == "role" then
            love.graphics.setColor(0.6, 0.6, 0.6, alpha)
            local font = love.graphics.getFont()
            local w = font:getWidth(entry.text)
            love.graphics.print(entry.text, centerX - w / 2, y)
            y = y + 20
        elseif entry.type == "text" then
            love.graphics.setColor(0.8, 0.8, 0.8, alpha)
            local font = love.graphics.getFont()
            local w = font:getWidth(entry.text)
            love.graphics.print(entry.text, centerX - w / 2, y)
            y = y + 22
        elseif entry.type == "spacer" then
            y = y + 25
        end
    end

    -- Skip hint
    love.graphics.setColor(0.4, 0.4, 0.4, alpha)
    love.graphics.print("[ESC] Preskoči", 20, screenH - 30)

    love.graphics.setColor(1, 1, 1, 1)
end

function CreditsScreen.keypressed(key)
    if key == "escape" and visible then
        CreditsScreen.hide()
        -- Return to main menu
        local Gamestate = require("libraries.gamestate")
        local startMenu = require("states.start_menu")
        Gamestate.switch(startMenu)
        return true
    end
    return false
end

return CreditsScreen
