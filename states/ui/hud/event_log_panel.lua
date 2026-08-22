-- states/ui/hud/event_log_panel.lua
-- Castle Kingdoms 2027 v3.12.146 - Event Log Panel
--
-- Modern UI panel showing the game event log with filtering:
--   * All events listed with timestamp, category badge, message
--   * Filter by category (All / Build / Military / Economy / Royal / etc.)
--   * Search by message text
--   * Click on event to see full data
--   * Clear log button
--
-- Toggle with Ctrl+Shift+L (L for "Log").

local PanelAnim = require("states.ui.hud.PanelAnimations")
local UISound = require("objects.Audio.UISoundHelper")
local EventLog = require("objects.Feedback.GameEventLog")

local EventLogPanel = {}

local visible = false
local activeFilter = "all"
local scrollOffset = 0
local searchActive = false
local searchQuery = ""
local rowPositions = {}

local animState = PanelAnim.createState({
    duration = 0.22,
    slideDir = "left",
    slideDist = 24,
    easing = "easeOut",
})

local FILTERS = {
    all          = { label = "VSI",        color = {0.7, 0.75, 0.8} },
    build        = { label = "GRADNJA",     color = {0.85, 0.7, 0.3} },
    military     = { label = "VOJSKA",      color = {0.9, 0.4, 0.4} },
    economy      = { label = "EKONOMIJA",   color = {0.4, 0.85, 0.4} },
    royal        = { label = "ROYAL",       color = {0.85, 0.6, 0.95} },
    achievement  = { label = "DOSEŽKI",     color = {0.95, 0.85, 0.3} },
    market       = { label = "TRG",          color = {0.4, 0.7, 0.95} },
    combat       = { label = "BOJ",          color = {0.9, 0.5, 0.3} },
    system       = { label = "SISTEM",       color = {0.5, 0.65, 0.85} },
}
local FILTER_ORDER = {"all", "build", "military", "economy", "royal", "achievement", "market", "combat", "system"}

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
    local allEvents = EventLog.getEvents()
    local filtered = {}
    local query = searchQuery:lower()
    for _, event in ipairs(allEvents) do
        local matchesFilter = (activeFilter == "all") or (event.category == activeFilter)
        if matchesFilter then
            if query == "" or event.message:lower():find(query, 1, true) then
                filtered[#filtered + 1] = event
            end
        end
    end
    return filtered
end

function EventLogPanel.draw()
    if not visible and not PanelAnim.isAnimating(animState) then return end

    local alpha = PanelAnim.getProgress(animState)
    local offsetX, offsetY = PanelAnim.getOffset(animState)

    local screenW, screenH = love.graphics.getDimensions()
    local panelW = math.min(800, screenW - 60)
    local panelH = math.min(640, screenH - 60)
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
    love.graphics.setColor(0.5, 0.6, 0.85, alpha)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", panelX, panelY, panelW, panelH, 8, 8, 8, 8)
    love.graphics.setLineWidth(1)

    -- Title
    love.graphics.setFont(titleFont)
    love.graphics.setColor(0.85, 0.75, 0.5, alpha)
    love.graphics.print("📋 DNEVNIK DOGODKOV — Castle Kingdoms 2027", panelX + 16, panelY + 12)

    -- Hint
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0.55, 0.6, 0.65, alpha)
    local hintText = "Ctrl+Shift+L: zapri  |  /: iskanje  |  Tab: filter  |  C: počisti  |  ↑↓/wheel: scroll"
    if searchActive then hintText = "Iskanje: " .. searchQuery .. "_  |  ENTER: potrdi  |  ESC: prekliči" end
    love.graphics.print(hintText, panelX + 16, panelY + 36)

    -- Stats
    local stats = EventLog.getStats()
    love.graphics.setColor(0.8, 0.85, 0.9, alpha)
    love.graphics.print(string.format("Skupaj: %d dogodkov  |  Max: %d  |  Filter: %s",
        stats.total, stats.maxEvents, FILTERS[activeFilter].label), panelX + 16, panelY + 52)

    -- Filter buttons (2 rows of compact buttons)
    local fbX = panelX + 16
    local fbY = panelY + 74
    local fbW = 80
    local fbH = 20
    local fbGap = 3
    for i, filterKey in ipairs(FILTER_ORDER) do
        local col = (i - 1) % 5
        local row = math.floor((i - 1) / 5)
        local bx = fbX + col * (fbW + fbGap)
        local by = fbY + row * (fbH + fbGap)
        local isActive = activeFilter == filterKey
        local filterInfo = FILTERS[filterKey]
        if isActive then
            love.graphics.setColor(filterInfo.color[1] * 0.3, filterInfo.color[2] * 0.3, filterInfo.color[3] * 0.3, alpha)
        else
            love.graphics.setColor(0.12, 0.13, 0.16, alpha * 0.5)
        end
        love.graphics.rectangle("fill", bx, by, fbW, fbH, 3, 3, 3, 3)
        love.graphics.setColor(filterInfo.color[1], filterInfo.color[2], filterInfo.color[3], alpha * 0.7)
        love.graphics.rectangle("line", bx, by, fbW, fbH, 3, 3, 3, 3)
        love.graphics.setFont(smallFont)
        love.graphics.setColor(isActive and 1 or 0.7, isActive and 1 or 0.7, isActive and 1 or 0.75, alpha)
        -- Show count for this filter
        local count = filterKey == "all" and stats.total or (stats.byCategory[filterKey] or 0)
        love.graphics.print(filterInfo.label .. " (" .. count .. ")", bx + 4, by + 4)
    end

    -- Search box
    local sbX = panelX + panelW - 200
    local sbY = fbY
    love.graphics.setColor(0.1, 0.1, 0.12, alpha)
    love.graphics.rectangle("fill", sbX, sbY, 184, fbH, 3, 3, 3, 3)
    love.graphics.setColor(0.4, 0.5, 0.7, alpha)
    love.graphics.rectangle("line", sbX, sbY, 184, fbH, 3, 3, 3, 3)
    local searchText = searchActive and searchQuery .. "_" or (searchQuery ~= "" and searchQuery or "🔍 Iskanje... (/)")
    if searchText == "🔍 Iskanje... (/)" then
        love.graphics.setColor(0.4, 0.45, 0.5, alpha)
    else
        love.graphics.setColor(0.8, 0.85, 0.9, alpha)
    end
    love.graphics.print(searchText:sub(1, 24), sbX + 6, sbY + 3)

    -- Event list
    local contentTop = panelY + 120
    local contentH = panelH - 140
    local rowH = 28
    local contentLeft = panelX + 16
    local contentW = panelW - 32

    love.graphics.setScissor(panelX + 8, contentTop, panelW - 16, contentH)

    local filtered = getFilteredEvents()
    local listY = contentTop - scrollOffset

    rowPositions = {}

    if #filtered == 0 then
        love.graphics.setFont(font)
        love.graphics.setColor(0.5, 0.55, 0.6, alpha)
        love.graphics.print("(ni dogodkov za prikaz)", contentLeft, contentTop + 20)
    end

    love.graphics.setFont(smallFont)
    for i, event in ipairs(filtered) do
        local ry = listY + (i - 1) * rowH
        if ry + rowH > contentTop and ry < contentTop + contentH then
            local catInfo = FILTERS[event.category] or FILTERS.system

            -- Row bg
            love.graphics.setColor(0.08, 0.08, 0.1, alpha * 0.4)
            love.graphics.rectangle("fill", contentLeft, ry, contentW, rowH - 3, 3, 3, 3, 3)

            -- Category badge (left)
            love.graphics.setColor(catInfo.color[1] * 0.3, catInfo.color[2] * 0.3, catInfo.color[3] * 0.3, alpha * 0.8)
            love.graphics.rectangle("fill", contentLeft, ry, 4, rowH - 3, 3, 0, 0, 3)

            -- Category label
            love.graphics.setColor(catInfo.color[1], catInfo.color[2], catInfo.color[3], alpha)
            love.graphics.print(catInfo.label, contentLeft + 10, ry + 5)

            -- Message
            love.graphics.setColor(0.85, 0.88, 0.92, alpha)
            local msg = event.message
            if #msg > 70 then msg = msg:sub(1, 67) .. "..." end
            love.graphics.print(msg, contentLeft + 90, ry + 5)

            -- Time
            love.graphics.setColor(0.5, 0.55, 0.6, alpha)
            local timeStr = os.date("%H:%M:%S", event.timestamp)
            love.graphics.print(timeStr, contentLeft + contentW - 70, ry + 5)

            rowPositions[#rowPositions + 1] = {
                event = event,
                x = contentLeft, y = ry, w = contentW, h = rowH - 3,
            }
        end
    end

    love.graphics.setScissor()

    -- Scrollbar
    local totalH = #filtered * rowH
    if totalH > contentH then
        local sbX2 = panelX + panelW - 12
        local sbY2 = contentTop
        local sbH2 = contentH
        love.graphics.setColor(0.2, 0.2, 0.25, alpha * 0.5)
        love.graphics.rectangle("fill", sbX2, sbY2, 4, sbH2, 2, 2, 2, 2)
        local thumbH = math.max(20, sbH2 * (contentH / totalH))
        local maxScroll = totalH - contentH
        local thumbY = sbY2 + (sbH2 - thumbH) * (math.min(scrollOffset, maxScroll) / maxScroll)
        love.graphics.setColor(0.4, 0.45, 0.55, alpha)
        love.graphics.rectangle("fill", sbX2 + 1, thumbY, 2, thumbH, 1, 1, 1, 1)
    end

    -- Footer
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0.5, 0.55, 0.6, alpha)
    love.graphics.print(string.format("%d dogodkov  |  8 kategorij  |  Max %d v pomnilniku",
        #filtered, 500), panelX + 16, panelY + panelH - 20)

    love.graphics.setFont(font)
    love.graphics.pop()
    love.graphics.setColor(1, 1, 1, 1)
end

function EventLogPanel.wheelmoved(x, y)
    if not visible and not PanelAnim.isAnimating(animState) then return false end
    if y > 0 then
        scrollOffset = math.max(0, scrollOffset - 36)
        return true
    elseif y < 0 then
        scrollOffset = scrollOffset + 36
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
        EventLog.clear()
        UISound.playToggleOff()
        if _G.NotificationCenter then
            pcall(function()
                _G.NotificationCenter.system("Dnevnik dogodkov: počiščeno",
                    _G.NotificationCenter.PRIORITY.NORMAL, 3)
            end)
        end
        return true
    end
    if key == "up" then
        scrollOffset = math.max(0, scrollOffset - 36)
        return true
    end
    if key == "down" then
        scrollOffset = scrollOffset + 36
        return true
    end
    if key == "pageup" then
        scrollOffset = math.max(0, scrollOffset - 180)
        return true
    end
    if key == "pagedown" then
        scrollOffset = scrollOffset + 180
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
    local panelW = math.min(800, screenW - 60)
    local panelX = (screenW - panelW) / 2
    local screenH = love.graphics.getHeight()
    local panelH = math.min(640, screenH - 60)
    local panelY = (screenH - panelH) / 2

    -- Filter button clicks
    local fbX = panelX + 16
    local fbY = panelY + 74
    local fbW = 80
    local fbH = 20
    local fbGap = 3
    for i, filterKey in ipairs(FILTER_ORDER) do
        local col = (i - 1) % 5
        local row = math.floor((i - 1) / 5)
        local bx = fbX + col * (fbW + fbGap)
        local by = fbY + row * (fbH + fbGap)
        if x >= bx and x <= bx + fbW and y >= by and y <= by + fbH then
            if activeFilter ~= filterKey then
                activeFilter = filterKey
                UISound.playTabSwitch()
            end
            scrollOffset = 0
            return true
        end
    end

    -- Search box click
    local sbX = panelX + panelW - 200
    if x >= sbX and x <= sbX + 184 and y >= fbY and y <= fbY + fbH then
        searchActive = true
        UISound.playSearchFocus()
        return true
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
