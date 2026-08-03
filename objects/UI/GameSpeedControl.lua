-- objects/UI/GameSpeedControl.lua
-- Stronghold 2027 - Game Speed Control
-- Pause, 1x, 2x, 3x speed with visual UI

local GameSpeedControl = {}

local SPEEDS = {
    { name = "Pavza",  value = 0,   key = "space" },
    { name = "1x",     value = 1,   key = "1" },
    { name = "2x",     value = 2,   key = "2" },
    { name = "3x",     value = 3,   key = "3" },
    { name = "5x",     value = 5,   key = "4" },
}

GameSpeedControl.SPEEDS = SPEEDS

local currentSpeedIndex = 2  -- Default 1x
local initialized = false
local buttonPositions = {}

function GameSpeedControl.init()
    if initialized then return end
    initialized = true
    print("[GameSpeedControl] Initialized (Space=pause, 1-4=speed)")
end

function GameSpeedControl.getCurrentSpeed()
    return SPEEDS[currentSpeedIndex].value
end

function GameSpeedControl.getCurrentName()
    return SPEEDS[currentSpeedIndex].name
end

function GameSpeedControl.setSpeed(index)
    if index < 1 or index > #SPEEDS then return false end
    currentSpeedIndex = index

    -- Apply to game
    if _G.state then
        _G.speedModifier = SPEEDS[currentSpeedIndex].value
    end

    -- Handle pause
    if SPEEDS[currentSpeedIndex].value == 0 then
        _G.paused = true
    else
        _G.paused = false
    end

    -- Notification
    if _G.ModernUI then
        _G.ModernUI.notifyInfo("Hitrost: " .. SPEEDS[currentSpeedIndex].name)
    end

    -- Emit event
    if _G.GameEventBus then
        _G.GameEventBus.emit("speed_changed", { speed = SPEEDS[currentSpeedIndex].value })
    end

    print("[GameSpeedControl] Speed: " .. SPEEDS[currentSpeedIndex].name)
    return true
end

function GameSpeedControl.togglePause()
    if SPEEDS[currentSpeedIndex].value == 0 then
        -- Unpause -> 1x
        GameSpeedControl.setSpeed(2)
    else
        -- Pause
        GameSpeedControl.setSpeed(1)
    end
end

function GameSpeedControl.cycleSpeed()
    currentSpeedIndex = currentSpeedIndex + 1
    if currentSpeedIndex > #SPEEDS then
        currentSpeedIndex = 1  -- Back to pause
    end
    GameSpeedControl.setSpeed(currentSpeedIndex)
end

function GameSpeedControl.keypressed(key)
    if not initialized then return false end

    if key == "space" then
        GameSpeedControl.togglePause()
        return true
    elseif key == "1" then
        GameSpeedControl.setSpeed(2)  -- 1x
        return true
    elseif key == "2" then
        GameSpeedControl.setSpeed(3)  -- 2x
        return true
    elseif key == "3" then
        GameSpeedControl.setSpeed(4)  -- 3x
        return true
    elseif key == "4" then
        GameSpeedControl.setSpeed(5)  -- 5x
        return true
    end

    return false
end

function GameSpeedControl.draw()
    if not initialized then return end

    local w, h = love.graphics.getDimensions()
    local btnSize = 35
    local totalWidth = #SPEEDS * (btnSize + 5) - 5
    local startX = w - totalWidth - 10
    local y = h - 150 - btnSize - 10  -- Above action bar

    for i, speed in ipairs(SPEEDS) do
        local x = startX + (i - 1) * (btnSize + 5)

        -- Button background
        if i == currentSpeedIndex then
            love.graphics.setColor(0.3, 0.5, 0.8, 0.9)
        else
            love.graphics.setColor(0.15, 0.15, 0.2, 0.8)
        end
        love.graphics.rectangle("fill", x, y, btnSize, btnSize)

        -- Border
        love.graphics.setColor(0.5, 0.5, 0.5, 1)
        love.graphics.setLineWidth(1)
        love.graphics.rectangle("line", x, y, btnSize, btnSize)

        -- Text
        love.graphics.setColor(1, 1, 1, 1)
        local font = love.graphics.getFont()
        local text = speed.name
        local tw = font:getWidth(text)
        local th = font:getHeight()
        love.graphics.print(text, x + (btnSize - tw) / 2, y + (btnSize - th) / 2)

        -- Store position for click detection
        buttonPositions[i] = { x = x, y = y, w = btnSize, h = btnSize }
    end

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setLineWidth(1)
end

function GameSpeedControl.mousepressed(x, y, button)
    if not initialized or button ~= 1 then return false end

    for i, pos in ipairs(buttonPositions) do
        if x >= pos.x and x <= pos.x + pos.w and
           y >= pos.y and y <= pos.y + pos.h then
            GameSpeedControl.setSpeed(i)
            return true
        end
    end

    return false
end

function GameSpeedControl.getStats()
    return {
        currentSpeed = SPEEDS[currentSpeedIndex].value,
        currentName = SPEEDS[currentSpeedIndex].name,
        isPaused = SPEEDS[currentSpeedIndex].value == 0,
    }
end

return GameSpeedControl
