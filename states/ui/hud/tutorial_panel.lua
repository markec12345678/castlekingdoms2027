-- states/ui/hud/tutorial_panel.lua
-- Castle Kingdoms 2027 v3.12.132 - Tutorial Manager Panel
--
-- Modern UI panel for managing tutorial hints:
--   * List all 28 hints organized by priority
--   * Show/hide status (✓ shown, ✗ not yet)
--   * Toggle individual hint shown/hidden
--   * Toggle all hints enabled/disabled
--   * Reset all hints (clear persisted state)
--   * Search by hint key or text
--   * Show hint text preview
--
-- Toggle with Ctrl+Shift+O (O for "Onboarding").
-- Tab to cycle between All / Shown / Hidden tabs.
-- Press / to search.

local PanelAnim = require("states.ui.hud.PanelAnimations")
local TutorialHints = require("objects.Feedback.TutorialHints")
local UISound = require("objects.Audio.UISoundHelper")

local TutorialPanel = {}

local visible = false
local activeFilter = "all"  -- "all" | "shown" | "hidden"
local scrollOffset = 0
local searchActive = false
local searchQuery = ""
local rowPositions = {}
local hoveredRow = nil

local animState = PanelAnim.createState({
    duration = 0.22,
    slideDir = "right",
    slideDist = 24,
    easing = "easeOut",
})

local FILTERS = {
    all    = { label = "VSI",      color = {0.6, 0.75, 0.8} },
    shown  = { label = "PRIKAZANI", color = {0.3, 0.85, 0.4} },
    hidden = { label = "SKRITI",   color = {0.85, 0.6, 0.3} },
}
local FILTER_ORDER = {"all", "shown", "hidden"}

function TutorialPanel.toggle()
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

function TutorialPanel.setVisible(state)
    if state and not visible then
        visible = true
        PanelAnim.open(animState)
        scrollOffset = 0
    elseif not state and visible then
        PanelAnim.close(animState)
    end
end

function TutorialPanel.isVisible()
    return visible or PanelAnim.isAnimating(animState)
end

function TutorialPanel.update(dt)
    if not visible and not PanelAnim.isAnimating(animState) then return end
    PanelAnim.update(animState, dt)
    if animState.phase == "closed" then
        visible = false
    end
end

-- Get filtered hints
local function getFilteredHints()
    local all = TutorialHints.getAll()
    local filtered = {}
    local query = searchQuery:lower()
    for _, hint in ipairs(all) do
        local matchesFilter = (activeFilter == "all") or
                              (activeFilter == "shown" and hint.shown) or
                              (activeFilter == "hidden" and not hint.shown)
        if matchesFilter then
            if query == "" or
               hint.key:lower():find(query, 1, true) or
               hint.text:lower():find(query, 1, true) then
                filtered[#filtered + 1] = hint
            end
        end
    end
    return filtered
end

function TutorialPanel.draw()
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

    -- Panel background
    love.graphics.setColor(0.08, 0.07, 0.1, 0.98 * alpha)
    love.graphics.rectangle("fill", panelX, panelY, panelW, panelH, 8, 8, 8, 8)
    love.graphics.setColor(0.6, 0.7, 0.85, alpha)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", panelX, panelY, panelW, panelH, 8, 8, 8, 8)
    love.graphics.setLineWidth(1)

    -- Title
    love.graphics.setFont(titleFont)
    love.graphics.setColor(0.85, 0.75, 0.5, alpha)
    love.graphics.print("🎓 TUTORIAL MANAGER — Castle Kingdoms 2027", panelX + 16, panelY + 12)

    -- Hint line
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0.55, 0.6, 0.65, alpha)
    local hintText = "Ctrl+Shift+O: zapri  |  /: iskanje  |  Tab: filter  |  ↑↓/wheel: scroll  |  C: počisti vse  |  E: omogoči/onemogoči"
    if searchActive then hintText = "Iskanje: " .. searchQuery .. "_  |  ENTER: potrdi  |  ESC: prekliči" end
    love.graphics.print(hintText, panelX + 16, panelY + 36)

    -- Stats
    local stats = TutorialHints.getStats()
    love.graphics.setColor(0.8, 0.85, 0.9, alpha)
    love.graphics.print(string.format("Skupaj: %d  |  Prikazani: %d  |  Skriti: %d  |  Status: %s",
        stats.totalHints, stats.shownHints, stats.remainingHints,
        stats.enabled and "VKLOPLJENO" or "IZKLOPLJENO"), panelX + 16, panelY + 52)

    -- Filter buttons
    local fbX = panelX + 16
    local fbY = panelY + 74
    local fbW = 130
    local fbH = 22
    local fbGap = 4
    for i, filterKey in ipairs(FILTER_ORDER) do
        local filterInfo = FILTERS[filterKey]
        local bx = fbX + (i - 1) * (fbW + fbGap)
        local isActive = activeFilter == filterKey
        if isActive then
            love.graphics.setColor(filterInfo.color[1], filterInfo.color[2], filterInfo.color[3], alpha * 0.7)
        else
            love.graphics.setColor(0.12, 0.14, 0.18, alpha * 0.6)
        end
        love.graphics.rectangle("fill", bx, fbY, fbW, fbH, 3, 3, 3, 3)
        love.graphics.setColor(filterInfo.color[1], filterInfo.color[2], filterInfo.color[3], alpha)
        love.graphics.rectangle("line", bx, fbY, fbW, fbH, 3, 3, 3, 3)
        love.graphics.setColor(isActive and 1 or 0.8, isActive and 1 or 0.8, isActive and 1 or 0.85, alpha)
        love.graphics.print(filterInfo.label, bx + 8, fbY + 6)
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
    love.graphics.print(searchText:sub(1, 26), sbX + 6, sbY + 5)

    -- Hint list
    local contentTop = panelY + 110
    local contentH = panelH - 130
    local rowH = 36
    local contentLeft = panelX + 16
    local contentW = panelW - 32

    love.graphics.setScissor(panelX + 8, contentTop, panelW - 16, contentH)

    local hints = getFilteredHints()
    local listY = contentTop - scrollOffset

    rowPositions = {}
    hoveredRow = nil

    -- Detect hover
    local mx, my = love.mouse.getPosition()
    -- Adjust mouse for slide offset
    local adjMx = mx - offsetX
    local adjMy = my - offsetY

    for i, hint in ipairs(hints) do
        local ry = listY + (i - 1) * rowH
        if ry + rowH > contentTop and ry < contentTop + contentH then
            local isHovered = adjMx >= contentLeft and adjMx <= contentLeft + contentW and
                              adjMy >= ry and adjMy <= ry + rowH - 4

            -- Row background
            if isHovered then
                love.graphics.setColor(0.15, 0.18, 0.22, alpha * 0.8)
                hoveredRow = {hint = hint, y = ry}
            elseif hint.shown then
                love.graphics.setColor(0.1, 0.12, 0.08, alpha * 0.5)
            else
                love.graphics.setColor(0.08, 0.08, 0.1, alpha * 0.4)
            end
            love.graphics.rectangle("fill", contentLeft, ry, contentW, rowH - 4, 4, 4, 4, 4)

            -- Left border (status color)
            local borderColor
            if hint.shown then
                borderColor = {0.3, 0.85, 0.4, alpha}
            else
                borderColor = {0.85, 0.6, 0.3, alpha}
            end
            love.graphics.setColor(unpack(borderColor))
            love.graphics.rectangle("fill", contentLeft, ry, 4, rowH - 4, 4, 0, 0, 4)

            -- Status icon
            love.graphics.setFont(font)
            love.graphics.setColor(borderColor[1], borderColor[2], borderColor[3], alpha)
            love.graphics.print(hint.shown and "✓" or "○", contentLeft + 12, ry + 4)

            -- Hint key
            love.graphics.setColor(0.7, 0.78, 0.85, alpha)
            love.graphics.print(hint.key, contentLeft + 36, ry + 4)

            -- Priority badge
            love.graphics.setFont(smallFont)
            love.graphics.setColor(0.5, 0.55, 0.6, alpha)
            love.graphics.print("P" .. tostring(hint.priority), contentLeft + 280, ry + 4)

            -- Hint text (truncated)
            love.graphics.setColor(0.85, 0.88, 0.92, alpha)
            local text = hint.text
            if #text > 70 then text = text:sub(1, 67) .. "..." end
            love.graphics.print(text, contentLeft + 36, ry + 18)

            -- Action hint on hover
            if isHovered then
                love.graphics.setColor(0.7, 0.75, 0.8, alpha * 0.9)
                local actionText = hint.shown and "klik: skrij znova" or "klik: označi kot prikazan"
                love.graphics.print(actionText, contentLeft + contentW - 200, ry + 18)
            end

            -- Record row position for click handling
            rowPositions[#rowPositions + 1] = {
                hint = hint,
                x = contentLeft, y = ry, w = contentW, h = rowH - 4,
            }
        end
    end

    if #hints == 0 then
        love.graphics.setFont(font)
        love.graphics.setColor(0.6, 0.6, 0.6, alpha)
        love.graphics.print("(ni hintov za prikaz)", contentLeft, contentTop + 20)
    end

    love.graphics.setScissor()

    -- Scrollbar
    local totalH = #hints * rowH
    if totalH > contentH then
        local sbX2 = panelX + panelW - 12
        local sbY2 = contentTop
        local sbH2 = contentH
        love.graphics.setColor(0.2, 0.2, 0.25, alpha * 0.6)
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
    love.graphics.print("28 hintov · P1-P32 prioritete · Persistenca v tutorial_hints_shown.txt",
        panelX + 16, panelY + panelH - 20)

    love.graphics.setFont(font)
    love.graphics.pop()
    love.graphics.setColor(1, 1, 1, 1)
end

function TutorialPanel.wheelmoved(x, y)
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

function TutorialPanel.keypressed(key, scancode, isrepeat)
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
            scrollOffset = 0
            return true
        end
        return false
    end

    if key == "escape" then
        TutorialPanel.toggle()
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
        TutorialHints.reset()
        UISound.playToggleOff()
        if _G.NotificationCenter then
            pcall(function()
                _G.NotificationCenter.system("Tutorial resetiran — vsi hinti bodo spet prikazani",
                    _G.NotificationCenter.PRIORITY.NORMAL, 4)
            end)
        end
        return true
    end
    if key == "e" then
        local stats = TutorialHints.getStats()
        TutorialHints.setEnabled(not stats.enabled)
        UISound.playToggleOn()
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

function TutorialPanel.textinput(text)
    if not visible or not searchActive then return false end
    if #searchQuery < 30 and text:match("^[%w%s%-_]+$") then
        searchQuery = searchQuery .. text
        scrollOffset = 0
    end
    return true
end

function TutorialPanel.mousepressed(x, y, button)
    if not visible and not PanelAnim.isAnimating(animState) then return false end
    if button ~= 1 then return false end

    local screenW = love.graphics.getWidth()
    local panelW = math.min(800, screenW - 60)
    local panelX = (screenW - panelW) / 2
    local screenH = love.graphics.getHeight()
    local panelH = math.min(640, screenH - 60)
    local panelY = (screenH - panelH) / 2

    -- Click on filter buttons
    local fbX = panelX + 16
    local fbY = panelY + 74
    local fbW = 130
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

    -- Click on search box
    local sbX = panelX + panelW - 200
    if x >= sbX and x <= sbX + 184 and y >= fbY and y <= fbY + fbH then
        searchActive = true
        UISound.playSearchFocus()
        return true
    end

    -- Click on row (toggle shown/hidden)
    for _, pos in ipairs(rowPositions) do
        if x >= pos.x and x <= pos.x + pos.w and y >= pos.y and y <= pos.y + pos.h then
            local hint = pos.hint
            if hint.shown then
                TutorialHints.unmarkShown(hint.key)
                UISound.playToggleOff()
            else
                TutorialHints.markShown(hint.key)
                UISound.playToggleOn()
            end
            return true
        end
    end

    -- Click outside panel closes
    if x < panelX or x > panelX + panelW or y < panelY or y > panelY + panelH then
        TutorialPanel.toggle()
        return true
    end
    return false
end

function TutorialPanel.mousemoved(x, y, dx, dy)
    return false
end

function TutorialPanel.mousereleased(x, y, button)
    return false
end

return TutorialPanel
