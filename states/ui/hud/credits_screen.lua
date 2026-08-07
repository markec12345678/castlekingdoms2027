-- states/ui/hud/credits_screen.lua
-- Castle Kingdoms 2027 - Credits Screen
-- End game credits with scrolling text

local CreditsScreen = {}

local credits = {
    { type = "title", text = "STRONGHOLD 2027" },
    { type = "spacer" },
    { type = "section", text = "RAZVOJ" },
    { type = "name", text = "markec12345678" },
    { type = "role", text = "Glavni razvijalec" },
    { type = "spacer" },
    { type = "section", text = "OSNOVA" },
    { type = "name", text = "Stone Kingdoms" },
    { type = "role", text = "Odprtokodni projekt (Apache 2.0)" },
    { type = "spacer" },
    { type = "section", text = "ASSETI" },
    { type = "name", text = "Kenney.nl" },
    { type = "role", text = "CC0 gradivo (grad, enote, teren)" },
    { type = "spacer" },
    { type = "section", text = "GLASBA" },
    { type = "name", text = "Castle Kingdoms OST" },
    { type = "role", text = "Stone Kingdoms community" },
    { type = "name", text = "Alexander Nakarada" },
    { type = "name", text = "Kevin MacLeod" },
    { type = "role", text = "Razširjeni soundtrack" },
    { type = "spacer" },
    { type = "section", text = "LOKALIZACIJA" },
    { type = "name", text = "Slovenščina, Angleščina, Srbščina" },
    { type = "role", text = "32 jezikov" },
    { type = "spacer" },
    { type = "section", text = "TEHNOLOGIJE" },
    { type = "name", text = "LÖVE 11.5" },
    { type = "role", text = "Game engine (Lua/LuaJIT)" },
    { type = "name", text = "LuaSocket" },
    { type = "role", text = "Multiplayer networking" },
    { type = "name", text = "GLSL" },
    { type = "role", text = "HD shaderji" },
    { type = "spacer" },
    { type = "section", text = "ZAHVALE" },
    { type = "name", text = "Stone Kingdoms community" },
    { type = "role", text = "Originalni Castle Kingdoms (2001)" },
    { type = "name", text = "Stone Kingdoms ekipa" },
    { type = "role", text = "Odprtokodna osnova" },
    { type = "name", text = "Kenney.nl" },
    { type = "role", text = "CC0 asseti za indie razvoj" },
    { type = "spacer" },
    { type = "section", text = "POSEBNO HVALA" },
    { type = "name", text = "Vsem testnim igralcem" },
    { type = "role", text = "Za povratne informacije in podporo" },
    { type = "spacer" },
    { type = "spacer" },
    { type = "title", text = "HVALA ZA IGRANJE!" },
    { type = "spacer" },
    { type = "subtitle", text = "Castle Kingdoms 2027 v1.22.0" },
    { type = "subtitle", text = "© 2025-2027 markec12345678" },
}

local scrollY = 0
local scrollSpeed = 50  -- pixels per second
local isActive = false
local initialized = false

function CreditsScreen.init()
    if initialized then return end
    initialized = true
    print("[CreditsScreen] Initialized")
end

function CreditsScreen.show()
    CreditsScreen.init()
    isActive = true
    scrollY = 0
    if _G.GameEventBus then
        _G.GameEventBus.emit("credits_started")
    end
    print("[CreditsScreen] Showing credits")
end

function CreditsScreen.hide()
    isActive = false
    if _G.GameEventBus then
        _G.GameEventBus.emit("credits_ended")
    end
end

function CreditsScreen.isActive()
    return isActive
end

function CreditsScreen.update(dt)
    if not isActive then return end
    scrollY = scrollY + scrollSpeed * dt
end

function CreditsScreen.draw()
    if not isActive then return end

    local w, h = love.graphics.getDimensions()

    -- Black background
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("fill", 0, 0, w, h)

    -- Draw credits
    local y = h - scrollY
    local centerX = w / 2

    for _, entry in ipairs(credits) do
        if y > -50 and y < h + 50 then
            if entry.type == "title" then
                love.graphics.setColor(1, 0.85, 0.3, 1)
                love.graphics.setFont(love.graphics.newFont(32))
                love.graphics.printf(entry.text, 0, y, w, "center")
            elseif entry.type == "section" then
                love.graphics.setColor(0.7, 0.8, 1, 1)
                love.graphics.setFont(love.graphics.newFont(22))
                love.graphics.printf(entry.text, 0, y, w, "center")
            elseif entry.type == "name" then
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.setFont(love.graphics.newFont(18))
                love.graphics.printf(entry.text, 0, y, w, "center")
            elseif entry.type == "role" then
                love.graphics.setColor(0.6, 0.6, 0.6, 1)
                love.graphics.setFont(love.graphics.newFont(14))
                love.graphics.printf(entry.text, 0, y, w, "center")
            elseif entry.type == "subtitle" then
                love.graphics.setColor(0.5, 0.5, 0.5, 1)
                love.graphics.setFont(love.graphics.newFont(14))
                love.graphics.printf(entry.text, 0, y, w, "center")
            end
        end

        -- Increment Y based on entry type
        if entry.type == "spacer" then
            y = y + 30
        elseif entry.type == "title" then
            y = y + 60
        elseif entry.type == "section" then
            y = y + 40
        elseif entry.type == "name" then
            y = y + 25
        elseif entry.type == "role" then
            y = y + 20
        elseif entry.type == "subtitle" then
            y = y + 20
        end
    end

    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)

    -- Check if credits finished scrolling
    if y < 0 then
        CreditsScreen.hide()
    end

    -- Skip hint
    love.graphics.setColor(0.4, 0.4, 0.4, 1)
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.printf("Pritisnite ESC za preskok", 0, h - 30, w, "center")
    love.graphics.setColor(1, 1, 1, 1)
end

function CreditsScreen.keypressed(key)
    if not isActive then return false end
    if key == "escape" then
        CreditsScreen.hide()
        return true
    end
    return false
end

return CreditsScreen
