-- objects/UI/GamepadSupport.lua
-- Stronghold 2027 - Gamepad Support
-- Controller input for accessibility and console-like experience

local Gamepad = {}

local initialized = false
local isConnected = false
local deadzone = 0.25
local cursorSpeed = 400
local virtualCursor = { x = 0, y = 0 }
local useVirtualCursor = false

-- Button mapping
local BUTTON_MAP = {
    a = "select",         -- A = select/click
    b = "cancel",         -- B = cancel/back
    x = "secondary",      -- X = secondary action
    y = "menu",           -- Y = open menu
    leftshoulder = "tab_left",   -- LB = previous tab
    rightshoulder = "tab_right", -- RB = next tab
    back = "options",     -- Back = options/settings
    start = "pause",      -- Start = pause game
    dpup = "zoom_in",     -- D-pad up = zoom in
    dpdown = "zoom_out",  -- D-pad down = zoom out
    dpleft = "speed_down", -- D-pad left = decrease speed
    dpright = "speed_up",  -- D-pad right = increase speed
}

Gamepad.BUTTON_MAP = BUTTON_MAP

function Gamepad.init()
    if initialized then return end
    initialized = true

    -- Check if any gamepad is connected
    local joysticks = love.joystick.getJoysticks()
    for _, joy in ipairs(joysticks) do
        if joy:isGamepad() then
            isConnected = true
            print("[Gamepad] Connected: " .. joy:getName())
            break
        end
    end

    -- Initialize virtual cursor at screen center
    local w, h = love.graphics.getDimensions()
    virtualCursor.x = w / 2
    virtualCursor.y = h / 2

    print("[Gamepad] Initialized (connected: " .. tostring(isConnected) .. ")")
end

function Gamepad.setConnected(connected)
    isConnected = connected
    if connected then
        useVirtualCursor = true
        print("[Gamepad] Controller connected — virtual cursor enabled")
    else
        useVirtualCursor = false
        print("[Gamepad] Controller disconnected")
    end
end

function Gamepad.isConnected()
    return isConnected
end

-- Update (called every frame — handles continuous gamepad input)
function Gamepad.update(dt)
    if not initialized or not isConnected then return end

    -- Handle continuous left stick camera movement
    local joysticks = love.joystick.getJoysticks()
    for _, joy in ipairs(joysticks) do
        if joy:isGamepad() then
            -- Left stick = camera
            local lx = joy:getGamepadAxis("leftx")
            local ly = joy:getGamepadAxis("lefty")
            if math.abs(lx) > deadzone and _G.state and _G.state.viewXview then
                _G.state.viewXview = _G.state.viewXview - lx * cursorSpeed * dt
            end
            if math.abs(ly) > deadzone and _G.state and _G.state.viewYview then
                _G.state.viewYview = _G.state.viewYview - ly * cursorSpeed * dt
            end

            -- Right stick = virtual cursor
            if useVirtualCursor then
                local rx = joy:getGamepadAxis("rightx")
                local ry = joy:getGamepadAxis("righty")
                if math.abs(rx) > deadzone then
                    virtualCursor.x = virtualCursor.x + rx * cursorSpeed * 2 * dt
                end
                if math.abs(ry) > deadzone then
                    virtualCursor.y = virtualCursor.y + ry * cursorSpeed * 2 * dt
                end
                -- Clamp to screen
                local w, h = love.graphics.getDimensions()
                virtualCursor.x = math.max(0, math.min(w, virtualCursor.x))
                virtualCursor.y = math.max(0, math.min(h, virtualCursor.y))
            end
            break  -- Only use first gamepad
        end
    end
end

function Gamepad.setVirtualCursor(enabled)
    useVirtualCursor = enabled
end

function Gamepad.isVirtualCursorActive()
    return useVirtualCursor
end

function Gamepad.getCursorPosition()
    if useVirtualCursor then
        return virtualCursor.x, virtualCursor.y
    else
        return love.mouse.getPosition()
    end
end

-- Handle gamepad axis movement (for camera/scrolling)
function Gamepad.handleAxis(joystick, axis, value)
    if not initialized or not isConnected then return end

    -- Left stick = camera movement
    if axis == "leftx" then
        if math.abs(value) > deadzone then
            if _G.state and _G.state.viewXview then
                _G.state.viewXview = _G.state.viewXview - value * cursorSpeed * love.timer.getDelta()
            end
        end
    elseif axis == "lefty" then
        if math.abs(value) > deadzone then
            if _G.state and _G.state.viewYview then
                _G.state.viewYview = _G.state.viewYview - value * cursorSpeed * love.timer.getDelta()
            end
        end
    end

    -- Right stick = virtual cursor
    if useVirtualCursor then
        if axis == "rightx" and math.abs(value) > deadzone then
            virtualCursor.x = virtualCursor.x + value * cursorSpeed * 2 * love.timer.getDelta()
        elseif axis == "righty" and math.abs(value) > deadzone then
            virtualCursor.y = virtualCursor.y + value * cursorSpeed * 2 * love.timer.getDelta()
        end

        -- Clamp to screen
        local w, h = love.graphics.getDimensions()
        virtualCursor.x = math.max(0, math.min(w, virtualCursor.x))
        virtualCursor.y = math.max(0, math.min(h, virtualCursor.y))
    end

    -- Triggers = zoom
    if axis == "triggerleft" and value > 0.5 then
        -- Zoom out
    elseif axis == "triggerright" and value > 0.5 then
        -- Zoom in
    end
end

-- Handle gamepad button press
function Gamepad.handleButton(joystick, button)
    if not initialized or not isConnected then return false end

    local action = BUTTON_MAP[button]
    if not action then return false end

    print("[Gamepad] Button: " .. button .. " -> " .. action)

    if action == "select" then
        -- Simulate left click at cursor position
        if useVirtualCursor then
            local x, y = virtualCursor.x, virtualCursor.y
            if _G.GameEventBus then
                _G.GameEventBus.emit("gamepad_click", { x = x, y = y, button = 1 })
            end
            -- Forward to game mousepressed
            if love.mousepressed then
                -- Can't call love.mousepressed directly, use simulation
                local game = require("states.game")
                if game.mousepressed then game:mousepressed(x, y, 1) end
            end
        end
        return true

    elseif action == "cancel" then
        -- Right-click (cancel/dismiss)
        if useVirtualCursor then
            local x, y = virtualCursor.x, virtualCursor.y
            local RightClickDismiss = require("objects.UI.RightClickDismiss")
            if RightClickDismiss.handleRightClick(x, y, 2) then return true end
        end
        return true

    elseif action == "pause" then
        -- Toggle pause
        local GameSpeedControl = require("objects.UI.GameSpeedControl")
        GameSpeedControl.togglePause()
        return true

    elseif action == "menu" then
        -- Open/close settings
        local UnifiedSettings = require("states.ui.settings.unified_settings")
        UnifiedSettings.toggle()
        return true

    elseif action == "speed_up" then
        local GameSpeedControl = require("objects.UI.GameSpeedControl")
        GameSpeedControl.cycleSpeed()
        return true

    elseif action == "speed_down" then
        local GameSpeedControl = require("objects.UI.GameSpeedControl")
        GameSpeedControl.setSpeed(1)  -- 1x
        return true
    end

    return false
end

-- Draw virtual cursor
function Gamepad.draw()
    if not initialized or not useVirtualCursor then return end

    -- Draw virtual cursor
    love.graphics.setColor(0.3, 0.6, 1.0, 0.8)
    love.graphics.circle("fill", virtualCursor.x, virtualCursor.y, 8)
    love.graphics.setColor(1, 1, 1, 0.9)
    love.graphics.setLineWidth(2)
    love.graphics.circle("line", virtualCursor.x, virtualCursor.y, 10)

    -- Crosshair
    love.graphics.line(virtualCursor.x - 14, virtualCursor.y, virtualCursor.x - 8, virtualCursor.y)
    love.graphics.line(virtualCursor.x + 8, virtualCursor.y, virtualCursor.x + 14, virtualCursor.y)
    love.graphics.line(virtualCursor.x, virtualCursor.y - 14, virtualCursor.x, virtualCursor.y - 8)
    love.graphics.line(virtualCursor.x, virtualCursor.y + 8, virtualCursor.x, virtualCursor.y + 14)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setLineWidth(1)
end

function Gamepad.getStats()
    return {
        connected = isConnected,
        virtualCursor = useVirtualCursor,
        cursorPos = { virtualCursor.x, virtualCursor.y },
        deadzone = deadzone,
    }
end

return Gamepad
