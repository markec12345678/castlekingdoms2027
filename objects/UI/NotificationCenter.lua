-- objects/UI/NotificationCenter.lua
-- Castle Kingdoms 2027 v2.7.2 - Notification Center
--
-- Centralized notification management with priority, filtering, and history.
-- Replaces ad-hoc ModernUI.notify calls with a structured system.
--
-- Notification features:
-- - 4 priority levels (critical, high, normal, low)
-- - 6 categories (combat, economy, diplomacy, mission, system, social)
-- - History tracking with search/filter
-- - Auto-expire non-critical notifications
-- - Sound + visual feedback per category

local NotificationCenter = {}

local initialized = false
local activeNotifications = {}  -- currently displayed
local history = {}  -- all past notifications
local maxHistory = 100
local maxActive = 5  -- max concurrent notifications
local nextId = 1

-- Priority levels
local PRIORITY = {
    CRITICAL = 1,  -- red, top of screen, persistent
    HIGH = 2,      -- orange, 8 seconds
    NORMAL = 3,    -- white, 5 seconds
    LOW = 4,       -- gray, 3 seconds
}

NotificationCenter.PRIORITY = PRIORITY

-- Categories with colors and sounds
local CATEGORIES = {
    combat = { color = {0.9, 0.3, 0.3}, sound = "notification", icon = "!" },
    economy = { color = {0.3, 0.8, 0.3}, sound = "success_chime", icon = "$" },
    diplomacy = { color = {0.3, 0.6, 0.9}, sound = "notification", icon = "D" },
    mission = { color = {0.9, 0.8, 0.2}, sound = "success_chime", icon = "M" },
    system = { color = {0.6, 0.6, 0.6}, sound = "notification", icon = "S" },
    social = { color = {0.8, 0.4, 0.8}, sound = "notification", icon = "T" },
}

NotificationCenter.CATEGORIES = CATEGORIES

function NotificationCenter.init()
    if initialized then return end
    initialized = true
    print("[NotificationCenter] Initialized")
end

-- Show a notification
function NotificationCenter.show(text, category, priority, duration)
    if not initialized then NotificationCenter.init() end
    category = category or "system"
    priority = priority or PRIORITY.NORMAL

    local cat = CATEGORIES[category] or CATEGORIES.system
    duration = duration or (priority == PRIORITY.CRITICAL and 0 or
                            priority == PRIORITY.HIGH and 8 or
                            priority == PRIORITY.NORMAL and 5 or 3)

    local notification = {
        id = nextId,
        text = text,
        category = category,
        priority = priority,
        duration = duration,
        elapsed = 0,
        timestamp = os.time(),
        color = cat.color,
        icon = cat.icon,
        expired = false,
    }
    nextId = nextId + 1

    -- Add to active list
    table.insert(activeNotifications, notification)

    -- Remove oldest if exceeding maxActive (keep critical ones)
    while #activeNotifications > maxActive do
        local removed = false
        for i = 1, #activeNotifications do
            if activeNotifications[i].priority ~= PRIORITY.CRITICAL then
                table.remove(activeNotifications, i)
                removed = true
                break
            end
        end
        if not removed then
            table.remove(activeNotifications, 1)  -- force remove oldest
        end
    end

    -- Also show via ModernUI for visual feedback
    if _G.ModernUI then
        local notifType = "info"
        if category == "combat" or priority == PRIORITY.CRITICAL then notifType = "error"
        elseif category == "economy" or priority == PRIORITY.HIGH then notifType = "success"
        elseif priority == PRIORITY.LOW then notifType = "info" end
        pcall(function() _G.ModernUI.notify(text, notifType, duration > 0 and duration / 1000 or 5) end)
    end

    -- Play sound
    if _G.SFXLibrary then
        pcall(function() _G.SFXLibrary.play("ui", cat.sound) end)
    end

    -- Add to history
    table.insert(history, {
        id = notification.id,
        text = text,
        category = category,
        priority = priority,
        timestamp = notification.timestamp,
    })
    while #history > maxHistory do
        table.remove(history, 1)
    end

    -- Fire event
    if _G.GameEventBus then
        pcall(function() _G.GameEventBus.emit("notification_shown", notification) end)
    end

    return notification.id
end

-- Convenience methods per category
function NotificationCenter.combat(text, priority)
    return NotificationCenter.show(text, "combat", priority or PRIORITY.HIGH)
end

function NotificationCenter.economy(text, priority)
    return NotificationCenter.show(text, "economy", priority or PRIORITY.NORMAL)
end

function NotificationCenter.diplomacy(text, priority)
    return NotificationCenter.show(text, "diplomacy", priority or PRIORITY.NORMAL)
end

function NotificationCenter.mission(text, priority)
    return NotificationCenter.show(text, "mission", priority or PRIORITY.HIGH)
end

function NotificationCenter.system(text, priority)
    return NotificationCenter.show(text, "system", priority or PRIORITY.LOW)
end

function NotificationCenter.social(text, priority)
    return NotificationCenter.show(text, "social", priority or PRIORITY.NORMAL)
end

-- Dismiss a notification manually
function NotificationCenter.dismiss(notificationId)
    for i, notif in ipairs(activeNotifications) do
        if notif.id == notificationId then
            notif.expired = true
            return true
        end
    end
    return false
end

-- Update (expire old notifications)
function NotificationCenter.update(dt)
    if not initialized then return end
    for i = #activeNotifications, 1, -1 do
        local notif = activeNotifications[i]
        if notif.priority ~= PRIORITY.CRITICAL and notif.duration > 0 then
            notif.elapsed = notif.elapsed + dt
            if notif.elapsed >= notif.duration then
                notif.expired = true
            end
        end
        if notif.expired then
            table.remove(activeNotifications, i)
        end
    end
end

-- Draw active notifications (bottom-right corner)
function NotificationCenter.draw()
    if not initialized then return end
    if #activeNotifications == 0 then return end

    local screenWidth, screenHeight = love.graphics.getDimensions()
    local x = screenWidth - 320
    local y = screenHeight - 180  -- above action bar

    for i, notif in ipairs(activeNotifications) do
        local alpha = 1.0
        -- Fade out in last second
        if notif.duration > 0 and notif.elapsed > notif.duration - 1 then
            alpha = math.max(0, notif.duration - notif.elapsed)
        end

        -- Background
        love.graphics.setColor(0, 0, 0, 0.7 * alpha)
        love.graphics.rectangle("fill", x, y - (i-1) * 35, 310, 30)

        -- Colored border (left)
        love.graphics.setColor(notif.color[1], notif.color[2], notif.color[3], alpha)
        love.graphics.rectangle("fill", x, y - (i-1) * 35, 4, 30)

        -- Icon
        love.graphics.setColor(notif.color[1], notif.color[2], notif.color[3], alpha)
        love.graphics.print(notif.icon, x + 10, y - (i-1) * 35 + 8)

        -- Text (truncate if too long)
        local displayText = notif.text
        if #displayText > 45 then
            displayText = displayText:sub(1, 42) .. "..."
        end
        love.graphics.setColor(1, 1, 1, alpha)
        love.graphics.print(displayText, x + 25, y - (i-1) * 35 + 8)
    end
    love.graphics.setColor(1, 1, 1, 1)
end

-- Get active notifications
function NotificationCenter.getActive()
    return activeNotifications
end

-- Get history with optional filter
function NotificationCenter.getHistory(category, limit)
    local result = {}
    limit = limit or 20
    -- Iterate history in reverse (most recent first)
    for i = #history, 1, -1 do
        local entry = history[i]
        if not category or entry.category == category then
            table.insert(result, entry)
            if #result >= limit then break end
        end
    end
    return result
end

-- Clear history
function NotificationCenter.clearHistory()
    history = {}
end

-- Get stats
function NotificationCenter.getStats()
    local byCategory = {}
    for _, entry in ipairs(history) do
        byCategory[entry.category] = (byCategory[entry.category] or 0) + 1
    end
    return {
        activeCount = #activeNotifications,
        historyCount = #history,
        byCategory = byCategory,
    }
end

return NotificationCenter
