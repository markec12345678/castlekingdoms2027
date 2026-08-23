-- states/ui/hud/event_log_panel.lua
-- Castle Kingdoms 2027 v3.12.147 - Event Log Panel
--
-- Central event log showing ALL game events in chronological order:
--   * Market events (price crash, surge, seasonal)
--   * Combat events (battles, kills, deaths)
--   * Achievement unlocks
--   * Resource milestones (low food, low gold, milestones)
--   * System events (auto-save, difficulty change, speed change)
--
-- Features: filtering by category, search, scrollable, timestamps.
-- Toggle with Ctrl+Shift+L (L for "Log").

local PanelAnim = require("states.ui.hud.PanelAnimations")
local UISound = require("objects.Audio.UISoundHelper")

local EventLogPanel = {}

local visible = false
local scrollOffset = 0
local searchActive = false
local searchQuery = ""
local activeFilter = "all"

-- Event log storage (max 200 events, oldest removed)
local MAX_EVENTS = 200
local eventLog = {}

-- Filter definitions
local FILTERS = {
    all       = { label = "VSI",        color = {0.6, 0.75, 0.8} },
    market    = { label = "TRG",         color = {0.4, 0.65, 0.95} },
    combat    = { label = "BOJ",         color = {0.9, 0.4, 0.4} },
    achievement = { label = "DOSEŽKI",  color = {0.85, 0.6, 0.95} },
    system    = { label = "SISTEM",      color = {0.6, 0.6, 0.6} },
    resource  = { label = "VIRI",        color = {0.4, 0.8, 0.5} },
}
local FILTER_ORDER = {"all", "market", "combat", "achievement", "system", "resource"}

local animState = PanelAnim.createState({
    duration = 0.22,
    slideDir = "left",
    slideDist = 24,
    easing = "easeOut",
})

-- Add an event to the log
-- @param category string: "market", "combat", "achievement", "system", "resource"
-- @param text string: event description
-- @param icon string: emoji/icon prefix (optional)
function EventLogPanel.addEvent(category, text, icon)
    local event = {
        category = category or "system",
        text = text or "",
        icon = icon or "",
        timestamp = os.time(),
        timeStr = os.date("%H:%M:%S"),
    }
    eventLog[#eventLog + 1] = event
    -- Trim if too many
    if #eventLog > MAX_EVENTS then
        table.remove(eventLog, 1)
    end
end

function EventLogPanel.toggle()
    if not visible then
        visible = true
        PanelAnim.open(animState)
        UISound.playPanelOpen()
        scrollOffset = 0
    else
        PanelAnim.close(animState)
        UISound.playPanelClose()
    end
end

function EventLogPanel.isVisible()
    return visible or PanelAnim.isAnimating(animState)
end

function EventLogPanel.update(dt)
    if not visible and not PanelAnim.isAnimating(animState) then return end
    PanelAnim.update(animState, dt)
    if animState.phase == "closed" then
        visible = false
    end
end

-- Get filtered events
local function getFilteredEvents()
    local result = {}
    local query = searchQuery:lower()
    for i = #eventLog, 1, -1 do  -- newest first
        local e = eventLog[i]
        if (activeFilter == "all" or e.category == activeFilter) then
            if query == "" or
               e.text:lower():find(query, 1, true) or
               e.category:lower():find(query, 1, true) then
                result[#result + 1] = e
            end
        end
    end
    return result
end

function EventLogPanel.draw()
    if not visible and not PanelAnim.isAnimating(animState) then return end

    local alpha = PanelAnim.getProgress(animState)
    local offsetX, offsetY = PanelAnim.getOffset(animState)

    local screenW, screenH = love.graphics.getDimensions()
    local panelW = math.min(720, screenW - 60)
    local panelH = math.min(620, screenH - 60)
    local panelX = (screenW - panelW) / 2
    local panelY = (screenH - panelH) / 2

    local font = love.graphics.getFont()
    local titleFont = love.graphics.newFont(16)
    local smallFont = love.graphics.newFont(11)

    -- Dim background
    love.graphics.setColor(0, 0, 0, 0.65 * alpha)
    love.graphics.rectangle("fill", 0, 0, screenW, screenH)

    love.graphics.push("all")
    love.graphics.translate(offsetX, offsetY)

    -- Panel
    love.graphics.setColor(0.08, 0.07, 0.1, 0.98 * alpha)
    love.graphics.rectangle("fill", panelX, panelY, panelW, panelH, 8, 8, 8, 8)
    love.graphics.setColor(0.4, 0.5, 0.6, alpha)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", panelX, panelY, panelW, panelH, 8, 8, 8, 8)
    love.graphics.setLineWidth(1)

    -- Title
    love.graphics.setFont(titleFont)
    love.graphics.setColor(0.7, 0.78, 0.85, alpha)
    love.graphics.print("📋 DNEVNIK DOGODKOV — Castle Kingdoms 2027", panelX + 16, panelY + 12)

    -- Hint
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0.55, 0.6, 0.65, alpha)
    local hintText = "Ctrl+Shift+L: zapri  |  /: iskanje  |  Tab: filter  |  C: počisti  |  ↑↓/wheel: scroll"
    if searchActive then hintText = "Iskanje: " .. searchQuery .. "_  |  ENTER: potrdi  |  ESC: prekliči" end
    love.graphics.print(hintText, panelX + 16, panelY + 36)

    -- Stats
    love.graphics.setColor(0.8, 0.85, 0.9, alpha)
    love.graphics.print(string.format("Skupaj: %d dogodkov  |  Prikazano: %d  |  Filter: %s",
        #eventLog, #getFilteredEvents(), FILTERS[activeFilter].label), panelX + 16, panelY + 52)

    -- Filter tabs
    local fbX = panelX + 16
    local fbY = panelY + 72
    local fbW = 100
    local fbH = 22
    local fbGap = 4
    for i, filterKey in ipairs(FILTER_ORDER) do
        local filterInfo = FILTERS[filterKey]
        local bx = fbX + (i - 1) * (fbW + fbGap)
        local isActive = activeFilter == filterKey
        if isActive then
            love.graphics.setColor(filterInfo.color[1] * 0.3, filterInfo.color[2] * 0.3, filterInfo.color[3] * 0.3, alpha)
        else
            love.graphics.setColor(0.12, 0.13, 0.16, alpha * 0.6)
        end
        love.graphics.rectangle("fill", bx, fbY, fbW, fbH, 3, 3, 3, 3)
        love.graphics.setColor(filterInfo.color[1], filterInfo.color[2], filterInfo.color[3], alpha)
        love.graphics.rectangle("line", bx, fbY, fbW, fbH, 3, 3, 3, 3)
        love.graphics.setColor(isActive and 1 or 0.8, isActive and 1 or 0.8, isActive and 1 or 0.85, alpha)
        love.graphics.print(filterInfo.label, bx + 8, fbY + 5)
    end

    -- Event list
    local contentTop = panelY + 106
    local contentH = panelH - 130
    local rowH = 24
    local contentLeft = panelX + 16
    local contentW = panelW - 32

    love.graphics.setScissor(panelX + 8, contentTop, panelW - 16, contentH)

    local events = getFilteredEvents()
    local listY = contentTop - scrollOffset

    for i, e in ipairs(events) do
        local ry = listY + (i - 1) * rowH
        if ry + rowH > contentTop and ry < contentTop + contentH then
            local filterInfo = FILTERS[e.category] or FILTERS.system

            -- Row bg (alternating)
            if i % 2 == 0 then
                love.graphics.setColor(0.1, 0.1, 0.12, alpha * 0.4)
            else
                love.graphics.setColor(0.06, 0.06, 0.08, alpha * 0.3)
            end
            love.graphics.rectangle("fill", contentLeft, ry, contentW, rowH - 2, 2, 2, 2, 2)

            -- Category color bar (left)
            love.graphics.setColor(filterInfo.color[1], filterInfo.color[2], filterInfo.color[3], alpha)
            love.graphics.rectangle("fill", contentLeft, ry, 3, rowH - 2, 2, 0, 0, 2)

            -- Timestamp
            love.graphics.setFont(smallFont)
            love.graphics.setColor(0.5, 0.55, 0.6, alpha)
            love.graphics.print(e.timeStr, contentLeft + 10, ry + 4)

            -- Category badge
            love.graphics.setColor(filterInfo.color[1], filterInfo.color[2], filterInfo.color[3], alpha)
            love.graphics.print("[" .. string.upper(e.category:sub(1, 4)) .. "]", contentLeft + 80, ry + 4)

            -- Event text
            love.graphics.setColor(0.85, 0.88, 0.92, alpha)
            local text = e.icon .. " " .. e.text
            if #text > 70 then text = text:sub(1, 67) .. "..." end
            love.graphics.print(text, contentLeft + 140, ry + 4)
        end
    end

    if #events == 0 then
        love.graphics.setFont(font)
        love.graphics.setColor(0.6, 0.6, 0.6, alpha)
        love.graphics.print("(ni dogodkov za prikaz)", contentLeft, contentTop + 20)
    end

    love.graphics.setScissor()

    -- Scrollbar
    local totalH = #events * rowH
    if totalH > contentH then
        local sbX = panelX + panelW - 12
        local sbY = contentTop
        local sbH = contentH
        love.graphics.setColor(0.2, 0.2, 0.25, alpha * 0.5)
        love.graphics.rectangle("fill", sbX, sbY, 4, sbH, 2, 2, 2, 2)
        local thumbH = math.max(20, sbH * (contentH / totalH))
        local maxScroll = totalH - contentH
        local thumbY = sbY + (sbH - thumbH) * (math.min(scrollOffset, maxScroll) / maxScroll)
        love.graphics.setColor(0.4, 0.45, 0.55, alpha)
        love.graphics.rectangle("fill", sbX + 1, thumbY, 2, thumbH, 1, 1, 1, 1)
    end

    -- Footer
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0.5, 0.55, 0.6, alpha)
    love.graphics.print(string.format("Zadnjih %d dogodkov  |  C: počisti  |  Tab: filter", MAX_EVENTS),
        panelX + 16, panelY + panelH - 20)

    love.graphics.setFont(font)
    love.graphics.pop()
    love.graphics.setColor(1, 1, 1, 1)
end

function EventLogPanel.wheelmoved(x, y)
    if not visible and not PanelAnim.isAnimating(animState) then return false end
    if y > 0 then
        scrollOffset = math.max(0, scrollOffset - 24)
        return true
    elseif y < 0 then
        scrollOffset = scrollOffset + 24
        return true
    end
    return false
end

function EventLogPanel.keypressed(key, scancode, isrepeat)
    if not visible and not PanelAnim.isAnimating(animState) then return false end

    if searchActive then
        if key == "escape" then
            searchActive = false
            searchQuery = ""
            return true
        end
        if key == "return" then
            searchActive = false
            return true
        end
        if key == "backspace" then
            searchQuery = searchQuery:sub(1, -2)
            return true
        end
        return false
    end

    if key == "escape" then
        EventLogPanel.toggle()
        return true
    end
    if key == "/" then
        searchActive = true
        UISound.playSearchFocus()
        return true
    end
    if key == "tab" then
        for i, f in ipairs(FILTER_ORDER) do
            if f == activeFilter then
                activeFilter = FILTER_ORDER[(i % #FILTER_ORDER) + 1]
                UISound.playTabSwitch()
                break
            end
        end
        scrollOffset = 0
        return true
    end
    if key == "c" then
        eventLog = {}
        UISound.playToggleOff()
        scrollOffset = 0
        return true
    end
    if key == "up" then
        scrollOffset = math.max(0, scrollOffset - 24)
        return true
    end
    if key == "down" then
        scrollOffset = scrollOffset + 24
        return true
    end
    if key == "pageup" then
        scrollOffset = math.max(0, scrollOffset - 120)
        return true
    end
    if key == "pagedown" then
        scrollOffset = scrollOffset + 120
        return true
    end
    if key == "home" then
        scrollOffset = 0
        return true
    end
    return false
end

function EventLogPanel.textinput(text)
    if not visible or not searchActive then return false end
    if #searchQuery < 30 and text:match("^[%w%s%-_]+$") then
        searchQuery = searchQuery .. text
    end
    return true
end

function EventLogPanel.mousepressed(x, y, button)
    if not visible and not PanelAnim.isAnimating(animState) then return false end
    if button ~= 1 then return false end

    local screenW = love.graphics.getWidth()
    local panelW = math.min(720, screenW - 60)
    local panelX = (screenW - panelW) / 2
    local screenH = love.graphics.getHeight()
    local panelH = math.min(620, screenH - 60)
    local panelY = (screenH - panelH) / 2

    -- Filter tab click
    local fbX = panelX + 16
    local fbY = panelY + 72
    local fbW = 100
    local fbH = 22
    local fbGap = 4
    for i, filterKey in ipairs(FILTER_ORDER) do
        local bx = fbX + (i - 1) * (fbW + fbGap)
        if x >= bx and x <= bx + fbW and y >= fbY and y <= fbY + fbH then
            if activeFilter ~= filterKey then
                activeFilter = filterKey
                UISound.playTabSwitch()
            end
            scrollOffset = 0
            return true
        end
    end

    -- Click outside panel closes
    if x < panelX or x > panelX + panelW or y < panelY or y > panelY + panelH then
        EventLogPanel.toggle()
        return true
    end
    return false
end

function EventLogPanel.mousemoved(x, y, dx, dy)
    return false
end

return EventLogPanel
