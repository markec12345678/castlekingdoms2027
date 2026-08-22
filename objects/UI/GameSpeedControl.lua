-- objects/UI/GameSpeedControl.lua
-- Castle Kingdoms 2027 - Game Speed Control
-- Pause, 1x, 2x, 3x, 5x speed with visual UI
--
-- v3.12.139: Upgraded with persistence, UISoundHelper, NotificationCenter, modern styling

local GameSpeedControl = {}

local SPEEDS = {
    { name = "⏸",    label = "Pavza", value = 0,   key = "space", color = {0.9, 0.5, 0.3} },
    { name = "1×",   label = "Normalno", value = 1,   key = "1",    color = {0.4, 0.8, 0.5} },
    { name = "2×",   label = "Hitro",    value = 2,   key = "2",    color = {0.4, 0.7, 0.95} },
    { name = "3×",   label = "Zelo hitro", value = 3, key = "3",    color = {0.85, 0.65, 0.3} },
    { name = "5×",   label = "Ekstremno", value = 5, key = "4",    color = {0.9, 0.3, 0.3} },
}

GameSpeedControl.SPEEDS = SPEEDS

local currentSpeedIndex = 2  -- Default 1x
local initialized = false
local buttonPositions = {}
local hoveredButton = nil

-- v3.12.139: Persistence
local SPEED_FILE = "game_speed.txt"
local lastChangeTime = 0

function GameSpeedControl.init()
    if initialized then return end
    initialized = true
    -- v3.12.139: Load persisted speed
    local ok, content = pcall(love.filesystem.read, SPEED_FILE)
    if ok and content then
        content = content:gsub("%s+$", "")
        local savedIndex = tonumber(content)
        if savedIndex and savedIndex >= 1 and savedIndex <= #SPEEDS then
            currentSpeedIndex = savedIndex
        end
    end
    -- Apply loaded speed
    if _G.state then
        _G.speedModifier = SPEEDS[currentSpeedIndex].value
    end
    if SPEEDS[currentSpeedIndex].value == 0 then
        _G.paused = true
    end
    print("[GameSpeedControl] Initialized — speed: " .. SPEEDS[currentSpeedIndex].name .. " (Space=pause, 1-4=speed)")
end

-- v3.12.139: Save speed to file
local function saveSpeed()
    pcall(love.filesystem.write, SPEED_FILE, tostring(currentSpeedIndex) .. "\n")
end

function GameSpeedControl.getCurrentSpeed()
    return SPEEDS[currentSpeedIndex].value
end

function GameSpeedControl.getCurrentName()
    return SPEEDS[currentSpeedIndex].name
end

function GameSpeedControl.getCurrentLabel()
    return SPEEDS[currentSpeedIndex].label
end

function GameSpeedControl.getCurrentIndex()
    return currentSpeedIndex
end

function GameSpeedControl.setSpeed(index)
    if index < 1 or index > #SPEEDS then return false end
    local wasPaused = SPEEDS[currentSpeedIndex].value == 0
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

    -- v3.12.139: Persist
    saveSpeed()

    -- v3.12.139: Play sound
    if _G.UISoundHelper then
        if SPEEDS[currentSpeedIndex].value == 0 then
            pcall(function() _G.UISoundHelper.playToggleOff() end)
        elseif wasPaused then
            pcall(function() _G.UISoundHelper.playToggleOn() end)
        else
            pcall(function() _G.UISoundHelper.playClick() end)
        end
    end

    -- v3.12.139: Send toast notification
    if _G.NotificationCenter then
        local speed = SPEEDS[currentSpeedIndex]
        local priority = speed.value == 0 and _G.NotificationCenter.PRIORITY.NORMAL or _G.NotificationCenter.PRIORITY.LOW
        pcall(function()
            _G.NotificationCenter.show(
                speed.name .. " " .. speed.label,
                "system", priority, 2
            )
        end)
    end

    -- Emit event
    if _G.GameEventBus then
        _G.GameEventBus.emit("speed_changed", { speed = SPEEDS[currentSpeedIndex].value })
    end

    lastChangeTime = love.timer and love.timer.getTime() or 0
    return true
end

function GameSpeedControl.togglePause()
    if SPEEDS[currentSpeedIndex].value == 0 then
        GameSpeedControl.setSpeed(2)  -- Unpause -> 1x
    else
        GameSpeedControl.setSpeed(1)  -- Pause
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
    local btnSize = 38
    local btnGap = 4
    local totalWidth = #SPEEDS * (btnSize + btnGap) - btnGap
    local startX = w - totalWidth - 10
    local y = h - 150 - btnSize - 10  -- Above action bar

    -- Track mouse for hover
    local mx, my = love.mouse.getPosition()
    hoveredButton = nil

    -- v3.12.139: Background panel with rounded corners
    local panelPad = 6
    love.graphics.setColor(0.06, 0.07, 0.09, 0.85)
    love.graphics.rectangle("fill", startX - panelPad, y - panelPad, totalWidth + panelPad * 2, btnSize + panelPad * 2, 6, 6, 6, 6)
    love.graphics.setColor(0.3, 0.4, 0.5, 0.5)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", startX - panelPad, y - panelPad, totalWidth + panelPad * 2, btnSize + panelPad * 2, 6, 6, 6, 6)

    local font = love.graphics.getFont()
    local smallFont = love.graphics.newFont(10)

    for i, speed in ipairs(SPEEDS) do
        local x = startX + (i - 1) * (btnSize + btnGap)
        local isCurrent = i == currentSpeedIndex
        local isHovered = mx >= x and mx <= x + btnSize and my >= y and my <= y + btnSize

        if isHovered then
            hoveredButton = i
        end

        -- Button background with color coding
        local bgAlpha = 0.85
        if isCurrent then
            love.graphics.setColor(speed.color[1] * 0.4, speed.color[2] * 0.4, speed.color[3] * 0.4, bgAlpha)
        elseif isHovered then
            love.graphics.setColor(0.2, 0.22, 0.28, bgAlpha)
        else
            love.graphics.setColor(0.12, 0.13, 0.16, bgAlpha * 0.9)
        end
        love.graphics.rectangle("fill", x, y, btnSize, btnSize, 4, 4, 4, 4)

        -- Border
        if isCurrent then
            love.graphics.setColor(speed.color[1], speed.color[2], speed.color[3], 1)
            love.graphics.setLineWidth(2)
        else
            love.graphics.setColor(0.4, 0.45, 0.55, 0.6)
            love.graphics.setLineWidth(1)
        end
        love.graphics.rectangle("line", x, y, btnSize, btnSize, 4, 4, 4, 4)
        love.graphics.setLineWidth(1)

        -- Speed name (icon)
        love.graphics.setFont(font)
        love.graphics.setColor(isCurrent and 1 or 0.85, isCurrent and 1 or 0.85, isCurrent and 1 or 0.9, 1)
        local tw = font:getWidth(speed.name)
        local th = font:getHeight()
        love.graphics.print(speed.name, x + (btnSize - tw) / 2, y + (btnSize - th) / 2 - 3)

        -- Key hint (small, below)
        love.graphics.setFont(smallFont)
        love.graphics.setColor(0.5, 0.55, 0.6, 0.7)
        local keyDisplay = speed.key == "space" and "SPC" or speed.key
        local kw = smallFont:getWidth(keyDisplay)
        love.graphics.print(keyDisplay, x + (btnSize - kw) / 2, y + btnSize - 12)

        -- Store position for click detection
        buttonPositions[i] = { x = x, y = y, w = btnSize, h = btnSize }
    end

    love.graphics.setFont(font)
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

-- v3.12.139: Mousemoved for hover detection
function GameSpeedControl.mousemoved(x, y, dx, dy)
    if not initialized then return false end
    -- Hover is detected in draw()
    return false
end

function GameSpeedControl.getStats()
    return {
        currentSpeed = SPEEDS[currentSpeedIndex].value,
        currentName = SPEEDS[currentSpeedIndex].name,
        currentLabel = SPEEDS[currentSpeedIndex].label,
        isPaused = SPEEDS[currentSpeedIndex].value == 0,
        currentIndex = currentSpeedIndex,
    }
end

return GameSpeedControl
