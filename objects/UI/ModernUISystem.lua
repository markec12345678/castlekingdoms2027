-- objects/UI/ModernUISystem.lua
-- Castle Kingdoms 2027 - Modern UI System
--
-- Enhances the existing loveframes UI with:
-- - Animated tooltips (smooth fade-in)
-- - Hover effects (scale, color shift)
-- - Click feedback (press animation)
-- - Modern cursor system
-- - Notification system (toast messages)
-- - Improved health bars with gradients
--
-- Usage:
--   local ModernUI = require("objects.UI.ModernUISystem")
--   ModernUI.init()
--   ModernUI.update(dt)
--   ModernUI.draw()
--   ModernUI.showTooltip("Build a barracks", x, y)
--   ModernUI.notify("Building placed!", "success")

local ModernUI = {}

-- State
local initialized = false
local tooltips = {}
local notifications = {}
local hoverElements = {}
local cursorScale = 1.0
local cursorTargetScale = 1.0
local cursorX, cursorY = 0, 0
local cursorAlpha = 1.0

-- Configuration
local config = {
    tooltipFadeSpeed = 8.0,        -- seconds to full opacity
    tooltipBgColor = {0.1, 0.1, 0.15, 0.95},
    tooltipTextColor = {1, 1, 1, 1},
    tooltipBorderColor = {0.6, 0.5, 0.3, 1},
    tooltipPadding = 8,
    tooltipMaxWidth = 300,
    tooltipFont = nil,  -- will use default if nil

    notifyDuration = 3.0,
    notifyFadeSpeed = 4.0,
    notifyY = 50,
    notifySpacing = 5,
    notifyBgColor = {0.1, 0.2, 0.1, 0.9},
    notifyErrorColor = {0.3, 0.1, 0.1, 0.9},
    notifyWarningColor = {0.3, 0.25, 0.1, 0.9},
    notifySuccessColor = {0.1, 0.2, 0.1, 0.9},

    hoverScaleAmount = 1.05,
    hoverScaleSpeed = 10.0,
    pressScaleAmount = 0.95,
}

-- Initialize
function ModernUI.init()
    if initialized then return end
    initialized = true
    print("[ModernUI] Initialized")
end

-- Show a tooltip at position
-- @param text string Tooltip text (supports multi-line with \n)
-- @param x number Screen X position
-- @param y number Screen Y position
-- @param duration number Optional: auto-hide after N seconds (0 = persistent)
function ModernUI.showTooltip(text, x, y, duration)
    if not text or text == "" then return end

    local tooltip = {
        text = text,
        x = x,
        y = y,
        alpha = 0,
        targetAlpha = 1,
        duration = duration or 0,
        age = 0,
    }

    -- Try to wrap text if too long
    if #text > 80 then
        -- Simple word wrap
        local lines = {}
        local currentLine = ""
        for word in text:gmatch("%S+") do
            if #currentLine + #word + 1 > 60 then
                table.insert(lines, currentLine)
                currentLine = word
            else
                if currentLine == "" then
                    currentLine = word
                else
                    currentLine = currentLine .. " " .. word
                end
            end
        end
        if currentLine ~= "" then
            table.insert(lines, currentLine)
        end
        tooltip.text = table.concat(lines, "\n")
    end

    table.insert(tooltips, tooltip)
end

-- Hide all tooltips
function ModernUI.clearTooltips()
    for _, t in ipairs(tooltips) do
        t.targetAlpha = 0
    end
end

-- Show a notification (toast message)
-- @param text string Message text
-- @param type string "info", "success", "warning", "error"
-- @param duration number Seconds to show (default 3.0)
function ModernUI.notify(text, notifType, duration)
    if not text or text == "" then return end

    notifType = notifType or "info"
    duration = duration or config.notifyDuration

    local notif = {
        text = text,
        type = notifType,
        alpha = 0,
        targetAlpha = 1,
        age = 0,
        duration = duration,
        yOffset = -20,  -- start above target position
        targetYOffset = 0,
    }

    table.insert(notifications, notif)

    -- Limit max notifications
    while #notifications > 5 do
        table.remove(notifications, 1)
    end
end

-- Register a hover element
-- @param id string Unique identifier
-- @param x, y, w, number Bounding box
-- @param onEnter function Called when mouse enters
-- @param onLeave function Called when mouse leaves
function ModernUI.registerHover(id, x, y, w, h, onEnter, onLeave)
    hoverElements[id] = {
        x = x, y = y, w = w, h = h,
        onEnter = onEnter,
        onLeave = onLeave,
        isHovered = false,
        scale = 1.0,
        targetScale = 1.0,
    }
end

-- Unregister a hover element
function ModernUI.unregisterHover(id)
    hoverElements[id] = nil
end

-- Update hover element bounds
function ModernUI.updateHoverBounds(id, x, y, w, h)
    if hoverElements[id] then
        hoverElements[id].x = x
        hoverElements[id].y = y
        hoverElements[id].w = w
        hoverElements[id].h = h
    end
end

-- Update UI system
function ModernUI.update(dt)
    if not initialized then return end

    -- Update cursor position
    cursorX, cursorY = love.mouse.getPosition()

    -- Smooth cursor scale
    cursorScale = cursorScale + (cursorTargetScale - cursorScale) * dt * config.hoverScaleSpeed
    cursorTargetScale = 1.0  -- reset to default each frame

    -- Update tooltips
    for i = #tooltips, 1, -1 do
        local t = tooltips[i]
        t.alpha = t.alpha + (t.targetAlpha - t.alpha) * dt * config.tooltipFadeSpeed
        t.age = t.age + dt

        -- Auto-hide if duration set
        if t.duration > 0 and t.age > t.duration then
            t.targetAlpha = 0
        end

        -- Remove if fully faded out
        if t.targetAlpha == 0 and t.alpha < 0.01 then
            table.remove(tooltips, i)
        end
    end

    -- Update notifications
    for i = #notifications, 1, -1 do
        local n = notifications[i]
        n.alpha = n.alpha + (n.targetAlpha - n.alpha) * dt * config.notifyFadeSpeed
        n.yOffset = n.yOffset + (n.targetYOffset - n.yOffset) * dt * config.notifyFadeSpeed
        n.age = n.age + dt

        if n.age > n.duration then
            n.targetAlpha = 0
            n.targetYOffset = -20
        end

        -- Remove if faded out
        if n.targetAlpha == 0 and n.alpha < 0.01 then
            table.remove(notifications, i)
        end
    end

    -- Update hover elements
    for id, el in pairs(hoverElements) do
        local isHovered = cursorX >= el.x and cursorX <= el.x + el.w
                       and cursorY >= el.y and cursorY <= el.y + el.h

        if isHovered and not el.isHovered then
            el.isHovered = true
            el.targetScale = config.hoverScaleAmount
            if el.onEnter then el.onEnter() end
        elseif not isHovered and el.isHovered then
            el.isHovered = false
            el.targetScale = 1.0
            if el.onLeave then el.onLeave() end
        end

        el.scale = el.scale + (el.targetScale - el.scale) * dt * config.hoverScaleSpeed
    end
end

-- Draw UI overlays (called after main game draw)
function ModernUI.draw()
    if not initialized then return end

    -- Draw notifications (top-center)
    local notifY = config.notifyY
    for _, n in ipairs(notifications) do
        local font = love.graphics.getFont()
        local textW = font:getWidth(n.text)
        local textH = font:getHeight()
        local padding = 12
        local boxW = textW + padding * 2
        local boxH = textH + padding
        local screenW = love.graphics.getWidth()
        local boxX = (screenW - boxW) / 2
        local boxY = notifY + n.yOffset

        -- Background
        local bgColor
        if n.type == "error" then bgColor = config.notifyErrorColor
        elseif n.type == "warning" then bgColor = config.notifyWarningColor
        elseif n.type == "success" then bgColor = config.notifySuccessColor
        else bgColor = config.notifyBgColor end

        love.graphics.setColor(bgColor[1], bgColor[2], bgColor[3], bgColor[4] * n.alpha)
        love.graphics.rectangle("fill", boxX, boxY, boxW, boxH, 4, 4, 4, 4)

        -- Border
        love.graphics.setColor(0.6, 0.5, 0.3, n.alpha)
        love.graphics.setLineWidth(1)
        love.graphics.rectangle("line", boxX, boxY, boxW, boxH, 4, 4, 4, 4)

        -- Text
        love.graphics.setColor(1, 1, 1, n.alpha)
        love.graphics.print(n.text, boxX + padding, boxY + padding / 2)

        notifY = notifY + boxH + config.notifySpacing
    end

    -- Draw tooltips (near cursor)
    for _, t in ipairs(tooltips) do
        if t.alpha > 0.01 then
            local font = config.tooltipFont or love.graphics.getFont()
            love.graphics.setFont(font)

            -- Calculate tooltip size
            local lines = {}
            for line in t.text:gmatch("[^\n]+") do
                table.insert(lines, line)
            end

            local maxLineWidth = 0
            for _, line in ipairs(lines) do
                local w = font:getWidth(line)
                if w > maxLineWidth then maxLineWidth = w end
            end

            local lineHeight = font:getHeight()
            local boxW = math.min(maxLineWidth + config.tooltipPadding * 2, config.tooltipMaxWidth)
            local boxH = #lines * lineHeight + config.tooltipPadding * 2

            -- Position tooltip (avoid going off-screen)
            local tx = t.x + 15
            local ty = t.y + 15
            local screenW, screenH = love.graphics.getDimensions()
            if tx + boxW > screenW then tx = t.x - boxW - 15 end
            if ty + boxH > screenH then ty = t.y - boxH - 15 end

            -- Background
            love.graphics.setColor(
                config.tooltipBgColor[1],
                config.tooltipBgColor[2],
                config.tooltipBgColor[3],
                config.tooltipBgColor[4] * t.alpha
            )
            love.graphics.rectangle("fill", tx, ty, boxW, boxH, 3, 3, 3, 3)

            -- Border
            love.graphics.setColor(
                config.tooltipBorderColor[1],
                config.tooltipBorderColor[2],
                config.tooltipBorderColor[3],
                config.tooltipBorderColor[4] * t.alpha
            )
            love.graphics.setLineWidth(1)
            love.graphics.rectangle("line", tx, ty, boxW, boxH, 3, 3, 3, 3)

            -- Text
            love.graphics.setColor(
                config.tooltipTextColor[1],
                config.tooltipTextColor[2],
                config.tooltipTextColor[3],
                config.tooltipTextColor[4] * t.alpha
            )
            for i, line in ipairs(lines) do
                love.graphics.print(line, tx + config.tooltipPadding, ty + config.tooltipPadding + (i - 1) * lineHeight)
            end
        end
    end

    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
end

-- Convenience notification methods
function ModernUI.notifyInfo(text, duration)
    ModernUI.notify(text, "info", duration)
end

function ModernUI.notifySuccess(text, duration)
    ModernUI.notify(text, "success", duration)
end

function ModernUI.notifyWarning(text, duration)
    ModernUI.notify(text, "warning", duration)
end

function ModernUI.notifyError(text, duration)
    ModernUI.notify(text, "error", duration)
end

-- Set cursor hover state (call from UI elements on hover)
function ModernUI.setCursorHover()
    cursorTargetScale = 1.2
end

-- Set cursor pressed state
function ModernUI.setCursorPressed()
    cursorTargetScale = 0.8
end

-- Get stats
function ModernUI.getStats()
    return {
        activeTooltips = #tooltips,
        activeNotifications = #notifications,
        registeredHovers = #hoverElements,
        cursorScale = cursorScale,
    }
end

-- Reset (for new game)
function ModernUI.reset()
    tooltips = {}
    notifications = {}
    -- Keep hoverElements as they may be re-registered
end

return ModernUI
