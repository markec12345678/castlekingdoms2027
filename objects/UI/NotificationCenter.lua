-- objects/UI/NotificationCenter.lua
-- Castle Kingdoms 2027 v2.7.2 - Notification Center
--
-- Centralized notification management with priority, filtering, and history.
-- Replaces ad-hoc ModernUI.notify calls with a structured system.
--
-- v3.12.127: Toast Animation Upgrade
--   * Slide-in animation when notification appears (uses PanelAnimations)
--   * Slide-out animation when notification expires
--   * Click-to-dismiss functionality (mouse click on notification)
--   * Hover effect (highlight on mouseover)
--   * Toast History Panel (press N to view all past notifications)
--   * Stacked layout with smooth animations
--
-- Notification features:
-- - 4 priority levels (critical, high, normal, low)
-- - 6 categories (combat, economy, diplomacy, mission, system, social)
-- - History tracking with search/filter
-- - Auto-expire non-critical notifications
-- - Sound + visual feedback per category

local PanelAnim = require("states.ui.hud.PanelAnimations")

local NotificationCenter = {}

local initialized = false
local activeNotifications = {}  -- currently displayed
local history = {}  -- all past notifications
local maxHistory = 100
local maxActive = 5  -- max concurrent notifications
local nextId = 1

-- v3.12.127: Hover and click state
local mouseX, mouseY = 0, 0
local hoveredNotif = nil  -- { id, x, y, w, h }
local notifClickAreas = {}  -- rebuilt each draw: { {id, x, y, w, h}, ... }

-- v3.12.127: History panel state
local historyPanelVisible = false
local historyScrollOffset = 0
local historyAnimState = PanelAnim.createState({
    duration = 0.20,
    slideDir = "up",
    slideDist = 24,
    easing = "easeOut",
})

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
        -- v3.12.127: Animation state per notification (slide-in)
        animState = PanelAnim.createState({
            duration = 0.25,
            slideDir = "right",
            slideDist = 60,
            easing = "easeOut",
        }),
        -- v3.12.127: Closing animation state (slide-out)
        closing = false,
        closeAnimState = PanelAnim.createState({
            duration = 0.20,
            slideDir = "right",
            slideDist = 60,
            easing = "easeIn",
        }),
    }
    -- Start opening animation
    PanelAnim.open(notification.animState)
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
            -- v3.12.127: Start closing animation instead of instant removal
            if not notif.closing then
                notif.closing = true
                PanelAnim.snapOpen(notif.closeAnimState)
                PanelAnim.close(notif.closeAnimState)
            end
            return true
        end
    end
    return false
end

-- v3.12.127: Toggle history panel visibility
function NotificationCenter.toggleHistoryPanel()
    if not historyPanelVisible then
        historyPanelVisible = true
        PanelAnim.open(historyAnimState)
        historyScrollOffset = 0
    else
        PanelAnim.close(historyAnimState)
        -- historyPanelVisible stays true until close animation completes
    end
end

function NotificationCenter.isHistoryPanelVisible()
    return historyPanelVisible or PanelAnim.isAnimating(historyAnimState)
end

function NotificationCenter.setHistoryPanelVisible(state)
    if state and not historyPanelVisible then
        historyPanelVisible = true
        PanelAnim.open(historyAnimState)
        historyScrollOffset = 0
    elseif not state and historyPanelVisible then
        PanelAnim.close(historyAnimState)
    end
end

-- Update (expire old notifications)
function NotificationCenter.update(dt)
    if not initialized then return end
    -- v3.12.127: Track mouse for hover detection
    mouseX, mouseY = love.mouse.getPosition()
    -- Update each notification's animations
    for _, notif in ipairs(activeNotifications) do
        PanelAnim.update(notif.animState, dt)
        if notif.closing then
            PanelAnim.update(notif.closeAnimState, dt)
        end
    end
    -- Update history panel animation
    if historyPanelVisible or PanelAnim.isAnimating(historyAnimState) then
        PanelAnim.update(historyAnimState, dt)
        if historyAnimState.phase == "closed" then
            historyPanelVisible = false
        end
    end
    -- Expire old notifications
    for i = #activeNotifications, 1, -1 do
        local notif = activeNotifications[i]
        if notif.priority ~= PRIORITY.CRITICAL and notif.duration > 0 and not notif.closing then
            notif.elapsed = notif.elapsed + dt
            if notif.elapsed >= notif.duration then
                notif.closing = true
                PanelAnim.snapOpen(notif.closeAnimState)
                PanelAnim.close(notif.closeAnimState)
            end
        end
        -- Remove notifications whose close animation has finished
        if notif.closing and notif.closeAnimState.phase == "closed" then
            notif.expired = true
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

    -- v3.12.127: Clear and rebuild click areas each frame
    notifClickAreas = {}
    hoveredNotif = nil

    -- Draw from oldest to newest (so newest is on top visually)
    for i, notif in ipairs(activeNotifications) do
        local notifX = x
        local notifY = y - (i-1) * 38  -- v3.12.127: slightly taller for better visibility
        local notifW = 310
        local notifH = 34

        -- v3.12.127: Slide-in/slide-out animation offset
        local slideX, slideY = 0, 0
        local animAlpha = 1.0
        if notif.closing then
            -- Use closing animation
            slideX, slideY = PanelAnim.getOffset(notif.closeAnimState)
            animAlpha = PanelAnim.getProgress(notif.closeAnimState)
        else
            -- Use opening animation
            slideX, slideY = PanelAnim.getOffset(notif.animState)
            animAlpha = PanelAnim.getProgress(notif.animState)
        end
        -- For slideDir=right, slideX is positive (off-screen to the right)
        -- We want notifications to start offscreen right and slide in, so use slideX

        -- Hover detection (only if not closing)
        local isHovered = false
        if not notif.closing then
            if mouseX >= notifX + slideX and mouseX <= notifX + slideX + notifW and
               mouseY >= notifY + slideY and mouseY <= notifY + slideY + notifH then
                isHovered = true
                hoveredNotif = { id = notif.id, x = notifX, y = notifY, w = notifW, h = notifH }
                -- Register click area
                notifClickAreas[#notifClickAreas + 1] = {
                    id = notif.id,
                    x = notifX, y = notifY, w = notifW, h = notifH
                }
            end
        end

        -- Apply the slide offset to actual draw position
        local drawX = notifX + slideX
        local drawY = notifY + slideY

        -- Background (darker on hover)
        local bgAlpha = 0.7 * animAlpha
        if isHovered then bgAlpha = 0.85 * animAlpha end
        love.graphics.setColor(0, 0, 0, bgAlpha)
        love.graphics.rectangle("fill", drawX, drawY, notifW, notifH, 4, 4, 4, 4)

        -- v3.12.127: Hover highlight border
        if isHovered then
            love.graphics.setColor(1, 1, 1, 0.6 * animAlpha)
            love.graphics.setLineWidth(1)
            love.graphics.rectangle("line", drawX, drawY, notifW, notifH, 4, 4, 4, 4)
        end

        -- Colored border (left)
        love.graphics.setColor(notif.color[1], notif.color[2], notif.color[3], animAlpha)
        love.graphics.rectangle("fill", drawX, drawY, 4, notifH, 4, 4, 0, 0)

        -- Icon
        love.graphics.setColor(notif.color[1], notif.color[2], notif.color[3], animAlpha)
        love.graphics.print(notif.icon, drawX + 10, drawY + 10)

        -- Text (truncate if too long)
        local displayText = notif.text
        if #displayText > 45 then
            displayText = displayText:sub(1, 42) .. "..."
        end
        love.graphics.setColor(1, 1, 1, animAlpha)
        love.graphics.print(displayText, drawX + 25, drawY + 10)

        -- v3.12.127: Click-to-dismiss hint on hover
        if isHovered then
            love.graphics.setColor(0.7, 0.7, 0.7, 0.9 * animAlpha)
            local font = love.graphics.getFont()
            local smallFont = love.graphics.newFont(10)
            love.graphics.setFont(smallFont)
            love.graphics.print("× klik", drawX + notifW - 36, drawY + notifH - 14)
            love.graphics.setFont(font)
        end
    end
    love.graphics.setColor(1, 1, 1, 1)
end

-- v3.12.127: Draw the toast history panel (toggle with N)
function NotificationCenter.drawHistoryPanel()
    if not historyPanelVisible and not PanelAnim.isAnimating(historyAnimState) then return end

    local alpha = PanelAnim.getProgress(historyAnimState)
    local offsetX, offsetY = PanelAnim.getOffset(historyAnimState)

    local screenWidth, screenHeight = love.graphics.getDimensions()
    local panelW = 460
    local panelH = math.min(560, screenHeight - 80)
    local panelX = (screenWidth - panelW) / 2
    local panelY = (screenHeight - panelH) / 2

    -- Dim background
    love.graphics.setColor(0, 0, 0, 0.55 * alpha)
    love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)

    -- Panel
    love.graphics.push("all")
    love.graphics.translate(offsetX, offsetY)

    love.graphics.setColor(0.06, 0.07, 0.09, 0.97 * alpha)
    love.graphics.rectangle("fill", panelX, panelY, panelW, panelH, 8, 8, 8, 8)
    love.graphics.setColor(0.55, 0.7, 0.9, alpha)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", panelX, panelY, panelW, panelH, 8, 8, 8, 8)
    love.graphics.setLineWidth(1)

    -- Title
    local titleFont = love.graphics.newFont(16)
    love.graphics.setFont(titleFont)
    love.graphics.setColor(0.9, 0.85, 0.5, alpha)
    love.graphics.print("🔔 ZGODOVINA OBVEŠČANJ", panelX + 16, panelY + 12)

    local font = love.graphics.getFont()
    local smallFont = love.graphics.newFont(11)
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0.6, 0.65, 0.7, alpha)
    love.graphics.print("N: zapri  |  ↑↓/wheel: scroll  |  C: počisti zgodovino", panelX + 16, panelY + 36)

    -- Stats line
    local stats = NotificationCenter.getStats()
    love.graphics.setColor(0.7, 0.75, 0.8, alpha)
    love.graphics.print(string.format("Skupaj: %d obvestil  |  Aktivnih: %d  |  Zgodovina: %d",
        stats.historyCount + stats.activeCount, stats.activeCount, stats.historyCount),
        panelX + 16, panelY + 54)

    -- History list (scrollable)
    local contentTop = panelY + 80
    local contentH = panelH - 100
    local rowH = 36

    love.graphics.setScissor(panelX + 8, contentTop, panelW - 16, contentH)

    local historyList = NotificationCenter.getHistory(nil, 100)  -- get all history
    local startY = contentTop - historyScrollOffset

    for i, entry in ipairs(historyList) do
        local rowY = startY + (i - 1) * rowH
        if rowY + rowH > contentTop and rowY < contentTop + contentH then
            local cat = CATEGORIES[entry.category] or CATEGORIES.system

            -- Row background
            love.graphics.setColor(0.1, 0.1, 0.12, alpha * 0.6)
            love.graphics.rectangle("fill", panelX + 12, rowY, panelW - 24, rowH - 4, 3, 3, 3, 3)

            -- Left color border
            love.graphics.setColor(cat.color[1], cat.color[2], cat.color[3], alpha)
            love.graphics.rectangle("fill", panelX + 12, rowY, 3, rowH - 4, 3, 0, 0, 3)

            -- Icon
            love.graphics.setColor(cat.color[1], cat.color[2], cat.color[3], alpha)
            love.graphics.print(cat.icon, panelX + 22, rowY + 4)

            -- Text
            love.graphics.setColor(0.85, 0.88, 0.92, alpha)
            local text = entry.text
            if #text > 60 then text = text:sub(1, 57) .. "..." end
            love.graphics.print(text, panelX + 36, rowY + 4)

            -- Timestamp
            love.graphics.setColor(0.5, 0.55, 0.6, alpha)
            local timeStr = os.date("%H:%M:%S", entry.timestamp)
            love.graphics.print(timeStr, panelX + 36, rowY + 18)

            -- Priority label
            local priorityLabel
            if entry.priority == PRIORITY.CRITICAL then priorityLabel = "KRITIČNO"
            elseif entry.priority == PRIORITY.HIGH then priorityLabel = "VISOKO"
            elseif entry.priority == PRIORITY.NORMAL then priorityLabel = "NORMALNO"
            else priorityLabel = "NIZKO" end
            love.graphics.setColor(cat.color[1], cat.color[2], cat.color[3], alpha * 0.8)
            love.graphics.print(priorityLabel, panelX + panelW - 80, rowY + 4)
        end
    end

    if #historyList == 0 then
        love.graphics.setColor(0.6, 0.6, 0.6, alpha)
        love.graphics.print("(zgodovina je prazna)", panelX + 16, contentTop + 8)
    end

    love.graphics.setScissor()

    -- Scrollbar
    local totalH = #historyList * rowH
    if totalH > contentH then
        local maxScroll = totalH - contentH
        local sbX = panelX + panelW - 8
        local sbY = contentTop
        local sbH = contentH
        love.graphics.setColor(0.3, 0.35, 0.4, alpha * 0.5)
        love.graphics.rectangle("fill", sbX, sbY, 4, sbH, 2, 2, 2, 2)
        local thumbH = math.max(20, sbH * (contentH / totalH))
        local thumbY = sbY + (sbH - thumbH) * (historyScrollOffset / maxScroll)
        love.graphics.setColor(0.5, 0.6, 0.7, alpha)
        love.graphics.rectangle("fill", sbX + 1, thumbY, 2, thumbH, 1, 1, 1, 1)
    end

    -- Footer hint
    love.graphics.setColor(0.5, 0.55, 0.6, alpha)
    love.graphics.print("Zadnjih 100 obvestil · N: zapri", panelX + 16, panelY + panelH - 20)

    love.graphics.pop()
    love.graphics.setFont(font)
    love.graphics.setColor(1, 1, 1, 1)
end

-- v3.12.127: Mouse click handler (dismiss on click)
function NotificationCenter.mousepressed(x, y, button)
    if not initialized then return false end
    if button ~= 1 then return false end
    -- Check if click is on any notification
    for _, area in ipairs(notifClickAreas) do
        if x >= area.x and x <= area.x + area.w and
           y >= area.y and y <= area.y + area.h then
            NotificationCenter.dismiss(area.id)
            return true
        end
    end
    return false
end

-- v3.12.127: Mouse wheel handler for history panel scroll
function NotificationCenter.wheelmoved(x, y)
    if not historyPanelVisible and not PanelAnim.isAnimating(historyAnimState) then return false end
    if y > 0 then
        historyScrollOffset = math.max(0, historyScrollOffset - 36)
        return true
    elseif y < 0 then
        historyScrollOffset = historyScrollOffset + 36
        return true
    end
    return false
end

-- v3.12.127: Keyboard handler for history panel
function NotificationCenter.keypressed(key)
    if not historyPanelVisible and not PanelAnim.isAnimating(historyAnimState) then return false end
    if key == "n" or key == "escape" then
        NotificationCenter.toggleHistoryPanel()
        return true
    end
    if key == "c" then
        NotificationCenter.clearHistory()
        return true
    end
    if key == "up" then
        historyScrollOffset = math.max(0, historyScrollOffset - 36)
        return true
    end
    if key == "down" then
        historyScrollOffset = historyScrollOffset + 36
        return true
    end
    if key == "pageup" then
        historyScrollOffset = math.max(0, historyScrollOffset - 180)
        return true
    end
    if key == "pagedown" then
        historyScrollOffset = historyScrollOffset + 180
        return true
    end
    if key == "home" then
        historyScrollOffset = 0
        return true
    end
    if key == "end" then
        historyScrollOffset = 999999  -- will be clamped by scrollbar logic
        return true
    end
    return false
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
