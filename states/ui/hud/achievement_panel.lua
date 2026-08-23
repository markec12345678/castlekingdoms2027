-- states/ui/hud/achievement_panel.lua
-- Castle Kingdoms 2027 v3.12.128 - Modern Achievement Panel
--
-- Animated UI panel showing all achievements (existing + new Royal Systems achievements).
-- Toggle with Ctrl+Shift+A.
--
-- Features:
--   * Animated fade-in/out + slide effect (uses PanelAnimations)
--   * Category filter (All / Combat / Economy / Campaign / Social / Special)
--   * Search by name
--   * Progress bars for partial achievements
--   * Rarity color coding (common=gray, rare=blue, epic=purple, legendary=gold)
--   * Unlock dates
--   * Stats summary (X/Y unlocked, %, by category)
--   * Hover tooltip with full description
--   * Click-to-show-details (in future)

local PanelAnim = require("states.ui.hud.PanelAnimations")
local Tracker = require("objects.Steam.AchievementTracker")
local UISound = require("objects.Audio.UISoundHelper")

local AchievementPanel = {}

local visible = false
local scrollOffset = 0
local searchActive = false
local searchQuery = ""
local activeCategory = "all"  -- "all" | "combat" | "economy" | "campaign" | "social" | "special"
local hoveredAch = nil  -- {id, x, y, w, h} set during mousemoved
local rowPositions = {}  -- populated during draw for hit-testing

-- Anim state (slide-down + fade)
local animState = PanelAnim.createState({
    duration = 0.22,
    slideDir = "down",
    slideDist = 26,
    easing = "easeOut",
})

-- Category metadata
local CATEGORIES = {
    all       = { label = "VSI",          color = {0.7, 0.75, 0.8} },
    combat    = { label = "BOJEVANJE",    color = {0.9, 0.3, 0.3} },
    economy   = { label = "EKONOMIJA",    color = {0.3, 0.8, 0.3} },
    campaign  = { label = "KAMPAJA",      color = {0.9, 0.8, 0.2} },
    social    = { label = "DRUŽBENO",     color = {0.8, 0.4, 0.8} },
    special   = { label = "POSEBNO",      color = {0.6, 0.6, 0.6} },
}

-- Rarity color coding
local RARITY_COLORS = {
    common    = {0.6, 0.6, 0.6, 1},
    rare      = {0.3, 0.5, 0.95, 1},
    epic      = {0.75, 0.3, 0.85, 1},
    legendary = {0.95, 0.75, 0.2, 1},
}

local RARITY_ICONS = {
    common = "●",
    rare = "▲",
    epic = "◆",
    legendary = "★",
}

function AchievementPanel.toggle()
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

function AchievementPanel.setVisible(state)
    if state and not visible then
        visible = true
        PanelAnim.open(animState)
        scrollOffset = 0
    elseif not state and visible then
        PanelAnim.close(animState)
    end
end

function AchievementPanel.isVisible()
    return visible or PanelAnim.isAnimating(animState)
end

function AchievementPanel.update(dt)
    if not visible and not PanelAnim.isAnimating(animState) then return end
    PanelAnim.update(animState, dt)
    if animState.phase == "closed" then
        visible = false
    end
end

-- Get filtered achievements (by category + search)
local function getFilteredAchievements()
    local all = Tracker.getAll()
    local filtered = {}
    local query = searchQuery:lower()
    for _, ach in ipairs(all) do
        -- Category filter
        if activeCategory ~= "all" and ach.category ~= activeCategory then
            -- skip
        else
            -- Search filter
            if query == "" or
               ach.nameSlv:lower():find(query, 1, true) or
               ach.name:lower():find(query, 1, true) or
               ach.descSlv:lower():find(query, 1, true) then
                filtered[#filtered + 1] = ach
            end
        end
    end
    -- Sort: unlocked first, then by category, then by name
    table.sort(filtered, function(a, b)
        if a.unlocked ~= b.unlocked then return a.unlocked end
        if a.category ~= b.category then return a.category < b.category end
        return a.nameSlv < b.nameSlv
    end)
    return filtered
end

function AchievementPanel.draw()
    if not visible and not PanelAnim.isAnimating(animState) then return end

    local alpha = PanelAnim.getProgress(animState)
    local offsetX, offsetY = PanelAnim.getOffset(animState)

    local screenW, screenH = love.graphics.getDimensions()
    local panelW = math.min(900, screenW - 60)
    local panelH = math.min(680, screenH - 60)
    local panelX = (screenW - panelW) / 2
    local panelY = (screenH - panelH) / 2

    local font = love.graphics.getFont()
    local titleFont = love.graphics.newFont(16)
    local smallFont = love.graphics.newFont(11)

    -- Dim background
    love.graphics.setColor(0, 0, 0, 0.65 * alpha)
    love.graphics.rectangle("fill", 0, 0, screenW, screenH)

    -- Apply slide offset
    love.graphics.push("all")
    love.graphics.translate(offsetX, offsetY)

    -- Panel background
    love.graphics.setColor(0.08, 0.07, 0.1, 0.98 * alpha)
    love.graphics.rectangle("fill", panelX, panelY, panelW, panelH, 8, 8, 8, 8)
    love.graphics.setColor(0.6, 0.5, 0.85, alpha)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", panelX, panelY, panelW, panelH, 8, 8, 8, 8)
    love.graphics.setLineWidth(1)

    -- Title
    love.graphics.setFont(titleFont)
    love.graphics.setColor(0.95, 0.85, 0.5, alpha)
    love.graphics.print("🏆 DOSEŽKI — Castle Kingdoms 2027", panelX + 16, panelY + 12)

    -- Hint line
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0.6, 0.6, 0.65, alpha)
    local hintText = "Ctrl+Shift+A: zapri  |  /: iskanje  |  Tab: kategorija  |  ↑↓/wheel: scroll"
    if searchActive then hintText = "Iskanje: " .. searchQuery .. "_  |  ENTER: potrdi  |  ESC: prekliči" end
    love.graphics.print(hintText, panelX + 16, panelY + 36)

    -- Stats summary
    local allAch = Tracker.getAll()
    local unlockedCount = 0
    local byCategory = {}
    for _, ach in ipairs(allAch) do
        if ach.unlocked then unlockedCount = unlockedCount + 1 end
        byCategory[ach.category] = (byCategory[ach.category] or 0) + 1
    end
    local totalCount = #allAch
    local percent = totalCount > 0 and math.floor(unlockedCount / totalCount * 100) or 0

    love.graphics.setColor(0.8, 0.85, 0.9, alpha)
    love.graphics.print(string.format("Odklenjenih: %d / %d (%d%%)", unlockedCount, totalCount, percent),
        panelX + 16, panelY + 52)

    -- Progress bar
    local barX = panelX + 280
    local barY = panelY + 56
    local barW = 220
    local barH = 10
    love.graphics.setColor(0.15, 0.15, 0.18, alpha)
    love.graphics.rectangle("fill", barX, barY, barW, barH, 3, 3, 3, 3)
    -- Color gradient: red → yellow → green based on percent
    local r, g
    if percent < 50 then
        r = 0.85; g = (percent / 50) * 0.7
    else
        r = 0.85 - ((percent - 50) / 50) * 0.6; g = 0.7
    end
    love.graphics.setColor(r, g, 0.2, alpha)
    love.graphics.rectangle("fill", barX + 1, barY + 1, (barW - 2) * percent / 100, barH - 2, 2, 2, 2, 2)
    love.graphics.setColor(0.6, 0.65, 0.7, alpha)
    love.graphics.print(percent .. "%", barX + barW + 8, barY - 2)

    -- Category filter buttons
    love.graphics.setFont(smallFont)
    local catButtonX = panelX + 16
    local catButtonY = panelY + 74
    local catButtonW = 80
    local catButtonH = 22
    local catButtonGap = 4
    local catIndex = 0
    for catKey, catInfo in pairs(CATEGORIES) do
        -- order: all, combat, economy, campaign, social, special
        -- using a fixed order table
    end
    -- Use a fixed order
    local catOrder = {"all", "combat", "economy", "campaign", "social", "special"}
    for i, catKey in ipairs(catOrder) do
        local catInfo = CATEGORIES[catKey]
        local bx = catButtonX + (i - 1) * (catButtonW + catButtonGap)
        local by = catButtonY
        local isActive = activeCategory == catKey
        local count = catKey == "all" and totalCount or (byCategory[catKey] or 0)
        -- Background
        if isActive then
            love.graphics.setColor(catInfo.color[1], catInfo.color[2], catInfo.color[3], alpha * 0.7)
            love.graphics.rectangle("fill", bx, by, catButtonW, catButtonH, 3, 3, 3, 3)
        else
            love.graphics.setColor(0.15, 0.15, 0.2, alpha * 0.6)
            love.graphics.rectangle("fill", bx, by, catButtonW, catButtonH, 3, 3, 3, 3)
        end
        -- Border
        love.graphics.setColor(catInfo.color[1], catInfo.color[2], catInfo.color[3], alpha)
        love.graphics.setLineWidth(1)
        love.graphics.rectangle("line", bx, by, catButtonW, catButtonH, 3, 3, 3, 3)
        -- Label
        love.graphics.setColor(isActive and 1 or 0.8, isActive and 1 or 0.8, isActive and 1 or 0.85, alpha)
        love.graphics.print(catInfo.label .. " (" .. count .. ")", bx + 6, by + 5)
    end

    -- Search box
    local searchX = panelX + panelW - 200
    local searchY = catButtonY
    local searchW = 184
    love.graphics.setColor(0.1, 0.1, 0.12, alpha)
    love.graphics.rectangle("fill", searchX, searchY, searchW, catButtonH, 3, 3, 3, 3)
    love.graphics.setColor(0.4, 0.5, 0.7, alpha)
    love.graphics.rectangle("line", searchX, searchY, searchW, catButtonH, 3, 3, 3, 3)
    love.graphics.setColor(0.7, 0.75, 0.8, alpha)
    local searchText = searchActive and searchQuery .. "_" or (searchQuery ~= "" and searchQuery or "🔍 Iskanje... (/)")
    if searchText == "🔍 Iskanje... (/)" then
        love.graphics.setColor(0.4, 0.45, 0.5, alpha)
    end
    love.graphics.print(searchText:sub(1, 28), searchX + 6, searchY + 5)

    -- Achievement list (scrollable)
    local contentTop = panelY + 110
    local contentH = panelH - 130
    local rowH = 50
    local contentLeft = panelX + 16
    local contentW = panelW - 32

    love.graphics.setScissor(panelX + 8, contentTop, panelW - 16, contentH)

    local filtered = getFilteredAchievements()
    local listY = contentTop - scrollOffset

    -- Reset row positions
    rowPositions = {}

    for i, ach in ipairs(filtered) do
        local rowY = listY + (i - 1) * rowH
        if rowY + rowH > contentTop and rowY < contentTop + contentH then
            local catInfo = CATEGORIES[ach.category] or CATEGORIES.special
            local rarityColor = RARITY_COLORS[ach.rarity] or RARITY_COLORS.common
            local rarityIcon = RARITY_ICONS[ach.rarity] or "●"

            -- Row background
            if ach.unlocked then
                love.graphics.setColor(0.12, 0.15, 0.1, alpha * 0.6)
            else
                love.graphics.setColor(0.08, 0.08, 0.1, alpha * 0.4)
            end
            love.graphics.rectangle("fill", contentLeft, rowY, contentW, rowH - 4, 4, 4, 4, 4)

            -- Left rarity border
            love.graphics.setColor(rarityColor[1], rarityColor[2], rarityColor[3], alpha)
            love.graphics.rectangle("fill", contentLeft, rowY, 4, rowH - 4, 4, 0, 0, 4)

            -- Rarity icon (large)
            love.graphics.setFont(titleFont)
            love.graphics.setColor(rarityColor[1], rarityColor[2], rarityColor[3], alpha)
            love.graphics.print(rarityIcon, contentLeft + 12, rowY + 4)

            -- Name ( Slovenian primary )
            love.graphics.setFont(font)
            if ach.unlocked then
                love.graphics.setColor(0.95, 0.92, 0.85, alpha)
            else
                love.graphics.setColor(0.6, 0.6, 0.65, alpha)
            end
            love.graphics.print(ach.nameSlv, contentLeft + 36, rowY + 4)

            -- English name (smaller)
            love.graphics.setFont(smallFont)
            love.graphics.setColor(0.55, 0.6, 0.65, alpha)
            love.graphics.print(ach.name, contentLeft + 36, rowY + 22)

            -- Description (smaller)
            love.graphics.setColor(0.65, 0.7, 0.75, alpha)
            love.graphics.print(ach.descSlv, contentLeft + 200, rowY + 4)
            love.graphics.print(ach.desc, contentLeft + 200, rowY + 22)

            -- Progress bar
            local pbX = contentLeft + contentW - 220
            local pbY = rowY + 8
            local pbW = 140
            local pbH = 12
            love.graphics.setColor(0.1, 0.1, 0.12, alpha)
            love.graphics.rectangle("fill", pbX, pbY, pbW, pbH, 2, 2, 2, 2)
            -- Fill
            love.graphics.setColor(rarityColor[1], rarityColor[2], rarityColor[3], alpha * 0.85)
            local fillW = pbW * (ach.progressPercent / 100)
            love.graphics.rectangle("fill", pbX + 1, pbY + 1, math.max(0, fillW - 2), pbH - 2, 2, 2, 2, 2)
            -- Border
            love.graphics.setColor(0.4, 0.45, 0.5, alpha)
            love.graphics.rectangle("line", pbX, pbY, pbW, pbH, 2, 2, 2, 2)

            -- Progress text
            love.graphics.setFont(smallFont)
            love.graphics.setColor(0.85, 0.88, 0.92, alpha)
            love.graphics.print(string.format("%d/%d (%d%%)", ach.progressCurrent, ach.progressMax, ach.progressPercent),
                pbX + pbW + 6, pbY - 1)

            -- Status indicator (right side)
            if ach.unlocked then
                love.graphics.setColor(0.3, 0.85, 0.4, alpha)
                love.graphics.print("✓ ODKLENJENO", contentLeft + contentW - 110, rowY + 28)
                -- Unlock date
                if ach.unlockDate then
                    love.graphics.setColor(0.55, 0.6, 0.65, alpha)
                    love.graphics.print(os.date("%d.%m.%Y %H:%M", ach.unlockDate), pbX, rowY + 28)
                end
            else
                love.graphics.setColor(0.5, 0.5, 0.55, alpha)
                love.graphics.print("zaklenjeno", contentLeft + contentW - 100, rowY + 28)
            end

            -- Record row position for hover
            rowPositions[#rowPositions + 1] = {
                id = ach.id,
                x = contentLeft, y = rowY, w = contentW, h = rowH - 4,
                ach = ach,
            }
        end
    end

    if #filtered == 0 then
        love.graphics.setFont(font)
        love.graphics.setColor(0.6, 0.6, 0.6, alpha)
        love.graphics.print("(ni dosežkov za prikaz)", contentLeft, contentTop + 20)
    end

    love.graphics.setScissor()

    -- Scrollbar
    local totalH = #filtered * rowH
    if totalH > contentH then
        local sbX = panelX + panelW - 12
        local sbY = contentTop
        local sbH = contentH
        love.graphics.setColor(0.2, 0.2, 0.25, alpha * 0.6)
        love.graphics.rectangle("fill", sbX, sbY, 4, sbH, 2, 2, 2, 2)
        local thumbH = math.max(20, sbH * (contentH / totalH))
        local maxScroll = totalH - contentH
        local thumbY = sbY + (sbH - thumbH) * (math.min(scrollOffset, maxScroll) / maxScroll)
        love.graphics.setColor(0.4, 0.45, 0.55, alpha)
        love.graphics.rectangle("fill", sbX + 1, thumbY, 2, thumbH, 1, 1, 1, 1)
    end

    -- Hover tooltip
    if hoveredAch then
        local ach = hoveredAch.ach
        if ach then
            local mx, my = love.mouse.getPosition()
            local ttW = 360
            local ttLines = {
                RARITY_ICONS[ach.rarity] .. " " .. ach.nameSlv .. " (" .. ach.rarity .. ")",
                "EN: " .. ach.name,
                "Kategorija: " .. (CATEGORIES[ach.category] and CATEGORIES[ach.category].label or ach.category),
                "Opis: " .. ach.descSlv,
                "EN: " .. ach.desc,
                string.format("Napredek: %d / %d (%d%%)", ach.progressCurrent, ach.progressMax, ach.progressPercent),
            }
            if ach.unlocked then
                table.insert(ttLines, "✓ ODKLENJENO")
                if ach.unlockDate then
                    table.insert(ttLines, "Datum: " .. os.date("%d.%m.%Y %H:%M:%S", ach.unlockDate))
                end
            else
                table.insert(ttLines, "✗ Zaklenjeno")
            end

            love.graphics.setFont(smallFont)
            local maxLineW = 0
            for _, l in ipairs(ttLines) do
                local lw = smallFont:getWidth(l)
                if lw > maxLineW then maxLineW = lw end
            end
            local ttH = #ttLines * 14 + 12
            local ttX = mx + 16
            local ttY = my + 16
            if ttX + maxLineW + 16 > screenW then ttX = mx - maxLineW - 32 end
            if ttY + ttH > screenH then ttY = my - ttH - 16 end

            love.graphics.setColor(0.05, 0.05, 0.08, 0.97 * alpha)
            love.graphics.rectangle("fill", ttX, ttY, maxLineW + 16, ttH, 4, 4, 4, 4)
            love.graphics.setColor(0.6, 0.5, 0.85, alpha)
            love.graphics.setLineWidth(1)
            love.graphics.rectangle("line", ttX, ttY, maxLineW + 16, ttH, 4, 4, 4, 4)

            for i, l in ipairs(ttLines) do
                if i == 1 then
                    local rc = RARITY_COLORS[ach.rarity] or RARITY_COLORS.common
                    love.graphics.setColor(rc[1], rc[2], rc[3], alpha)
                elseif l:find("✓") then
                    love.graphics.setColor(0.3, 0.85, 0.4, alpha)
                elseif l:find("✗") then
                    love.graphics.setColor(0.85, 0.4, 0.3, alpha)
                else
                    love.graphics.setColor(0.85, 0.85, 0.85, alpha)
                end
                love.graphics.print(l, ttX + 8, ttY + 6 + (i - 1) * 14)
            end
        end
    end

    -- Footer
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0.5, 0.55, 0.6, alpha)
    love.graphics.print("Skupaj " .. #filtered .. " dosežkov  |  " .. unlockedCount .. "/" .. totalCount .. " odklenjenih",
        panelX + 16, panelY + panelH - 20)

    love.graphics.setFont(font)
    love.graphics.pop()
    love.graphics.setColor(1, 1, 1, 1)
end

function AchievementPanel.wheelmoved(x, y)
    if not visible and not PanelAnim.isAnimating(animState) then return false end
    if y > 0 then
        scrollOffset = math.max(0, scrollOffset - 40)
        return true
    elseif y < 0 then
        scrollOffset = scrollOffset + 40
        return true
    end
    return false
end

function AchievementPanel.keypressed(key, scancode, isrepeat)
    if not visible and not PanelAnim.isAnimating(animState) then return false end

    -- Search mode
    if searchActive then
        if key == "escape" then
            searchActive = false
            searchQuery = ""
            scrollOffset = 0
            return true
        end
        if key == "return" then
            searchActive = false
            scrollOffset = 0
            return true
        end
        if key == "backspace" then
            searchQuery = searchQuery:sub(1, -2)
            scrollOffset = 0
            return true
        end
        return false  -- let textinput handle character keys
    end

    if key == "escape" then
        AchievementPanel.toggle()
        return true
    end
    if key == "/" then
        searchActive = true
        scrollOffset = 0
        return true
    end
    if key == "tab" then
        -- Cycle category
        local catOrder = {"all", "combat", "economy", "campaign", "social", "special"}
        for i, c in ipairs(catOrder) do
            if c == activeCategory then
                activeCategory = catOrder[(i % #catOrder) + 1]
                UISound.playTabSwitch()
                break
            end
        end
        scrollOffset = 0
        return true
    end
    if key == "up" then
        scrollOffset = math.max(0, scrollOffset - 40)
        return true
    end
    if key == "down" then
        scrollOffset = scrollOffset + 40
        return true
    end
    if key == "pageup" then
        scrollOffset = math.max(0, scrollOffset - 200)
        return true
    end
    if key == "pagedown" then
        scrollOffset = scrollOffset + 200
        return true
    end
    if key == "home" then
        scrollOffset = 0
        return true
    end
    if key == "end" then
        scrollOffset = 999999  -- clamped by scrollbar
        return true
    end
    return false
end

function AchievementPanel.textinput(text)
    if not visible or not searchActive then return false end
    if #searchQuery < 30 and text:match("^[%w%s%-_]+$") then
        searchQuery = searchQuery .. text
        scrollOffset = 0
    end
    return true
end

function AchievementPanel.mousemoved(x, y, dx, dy)
    if not visible and not PanelAnim.isAnimating(animState) then return false end
    -- Check hover on rows
    hoveredAch = nil
    for _, pos in ipairs(rowPositions) do
        if x >= pos.x and x <= pos.x + pos.w and
           y >= pos.y and y <= pos.y + pos.h then
            hoveredAch = pos
            return true
        end
    end
    return false
end

function AchievementPanel.mousepressed(x, y, button)
    if not visible and not PanelAnim.isAnimating(animState) then return false end
    if button ~= 1 then return false end
    -- Click on category buttons
    local screenW = love.graphics.getWidth()
    local panelW = math.min(900, screenW - 60)
    local panelX = (screenW - panelW) / 2
    local catButtonX = panelX + 16
    local catButtonY = (love.graphics.getHeight() - math.min(680, love.graphics.getHeight() - 60)) / 2 + 74
    local catButtonW = 80
    local catButtonH = 22
    local catButtonGap = 4
    local catOrder = {"all", "combat", "economy", "campaign", "social", "special"}
    for i, catKey in ipairs(catOrder) do
        local bx = catButtonX + (i - 1) * (catButtonW + catButtonGap)
        if x >= bx and x <= bx + catButtonW and y >= catButtonY and y <= catButtonY + catButtonH then
            activeCategory = catKey
            UISound.playClick()
            scrollOffset = 0
            return true
        end
    end
    -- Click on search box
    local searchX = panelX + panelW - 200
    if x >= searchX and x <= searchX + 184 and y >= catButtonY and y <= catButtonY + catButtonH then
        searchActive = true
        UISound.playSearchFocus()
        return true
    end
    -- Click outside panel closes
    if x < panelX or x > panelX + panelW then
        AchievementPanel.toggle()
        return true
    end
    return false
end

function AchievementPanel.mousereleased(x, y, button)
    return false
end

return AchievementPanel
