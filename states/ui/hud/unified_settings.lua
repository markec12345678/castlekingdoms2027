-- states/ui/hud/unified_settings.lua
-- Castle Kingdoms 2027 v3.12.145 - Unified Settings Panel
--
-- Central hub combining ALL game settings into one panel:
--   * Game: difficulty, speed, auto-save
--   * UI: sound effects, help overlay, minimap, keybind editor
--   * Display: HD mode, postshader, debug overlay
--   * Gameplay: tutorial hints, game speed, pause on focus loss
--
-- Toggle with Ctrl+Shift+E (E for "Everything settings").

local PanelAnim = require("states.ui.hud.PanelAnimations")
local UISound = require("objects.Audio.UISoundHelper")

local UnifiedSettings = {}

local visible = false
local activeCategory = "game"
local scrollOffset = 0
local rowPositions = {}

local animState = PanelAnim.createState({
    duration = 0.22,
    slideDir = "up",
    slideDist = 24,
    easing = "easeOut",
})

local CATEGORIES = {
    game     = { label = "IGRA",         color = {0.4, 0.8, 0.5} },
    ui       = { label = "VMESNIK",      color = {0.4, 0.65, 0.95} },
    display  = { label = "PRIKAZ",       color = {0.85, 0.65, 0.3} },
    gameplay = { label = "IGRALEC",      color = {0.85, 0.45, 0.85} },
}
local CAT_ORDER = {"game", "ui", "display", "gameplay"}

function UnifiedSettings.toggle()
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

function UnifiedSettings.isVisible()
    return visible or PanelAnim.isAnimating(animState)
end

function UnifiedSettings.update(dt)
    if not visible and not PanelAnim.isAnimating(animState) then return end
    PanelAnim.update(animState, dt)
    if animState.phase == "closed" then
        visible = false
    end
end

-- Helper: draw a toggle row
local function drawToggleRow(x, y, w, label, isEnabled, alpha, hoverState)
    local isHovered = hoverState
    -- Row bg
    if isHovered then
        love.graphics.setColor(0.15, 0.18, 0.22, alpha * 0.8)
    else
        love.graphics.setColor(0.08, 0.08, 0.1, alpha * 0.4)
    end
    love.graphics.rectangle("fill", x, y, w, 32, 3, 3, 3, 3)

    -- Label
    love.graphics.setColor(0.85, 0.88, 0.92, alpha)
    local font = love.graphics.getFont()
    love.graphics.print(label, x + 12, y + 8)

    -- Toggle switch
    local tw = 44
    local th = 20
    local tx = x + w - tw - 12
    local ty = y + 6
    -- Track
    if isEnabled then
        love.graphics.setColor(0.2, 0.6, 0.3, alpha * 0.8)
    else
        love.graphics.setColor(0.3, 0.15, 0.15, alpha * 0.6)
    end
    love.graphics.rectangle("fill", tx, ty, tw, th, 10, 10, 10, 10)
    -- Knob
    local knobX = isEnabled and (tx + tw - th + 2) or (tx + 2)
    love.graphics.setColor(1, 1, 1, alpha * 0.9)
    love.graphics.circle("fill", knobX + (th - 4) / 2, ty + th / 2, (th - 4) / 2)

    -- Border
    love.graphics.setColor(0.4, 0.45, 0.55, alpha * 0.5)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", tx, ty, tw, th, 10, 10, 10, 10)

    return { x = tx, y = ty, w = tw, h = th, rowY = y, rowH = 32 }
end

-- Helper: draw a value row (non-toggle, shows a value)
local function drawValueRow(x, y, w, label, value, valueColor, alpha, hoverState)
    local isHovered = hoverState
    if isHovered then
        love.graphics.setColor(0.15, 0.18, 0.22, alpha * 0.8)
    else
        love.graphics.setColor(0.08, 0.08, 0.1, alpha * 0.4)
    end
    love.graphics.rectangle("fill", x, y, w, 32, 3, 3, 3, 3)

    love.graphics.setColor(0.85, 0.88, 0.92, alpha)
    local font = love.graphics.getFont()
    love.graphics.print(label, x + 12, y + 8)

    love.graphics.setColor(valueColor[1], valueColor[2], valueColor[3], alpha)
    local vw = font:getWidth(tostring(value))
    love.graphics.print(tostring(value), x + w - vw - 12, y + 8)

    return { x = x, y = y, w = w, h = 32 }
end

function UnifiedSettings.draw()
    if not visible and not PanelAnim.isAnimating(animState) then return end

    local alpha = PanelAnim.getProgress(animState)
    local offsetX, offsetY = PanelAnim.getOffset(animState)

    local screenW, screenH = love.graphics.getDimensions()
    local panelW = math.min(680, screenW - 60)
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
    love.graphics.setColor(0.5, 0.6, 0.85, alpha)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", panelX, panelY, panelW, panelH, 8, 8, 8, 8)
    love.graphics.setLineWidth(1)

    -- Title
    love.graphics.setFont(titleFont)
    love.graphics.setColor(0.85, 0.75, 0.5, alpha)
    love.graphics.print("⚙ NASTAVITVE — Castle Kingdoms 2027", panelX + 16, panelY + 12)

    -- Hint
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0.55, 0.6, 0.65, alpha)
    love.graphics.print("Ctrl+Shift+E: zapri  |  Tab: kategorija  |  Klik: toggle  |  ↑↓/wheel: scroll",
        panelX + 16, panelY + 36)

    -- Category tabs
    local tabX = panelX + 16
    local tabY = panelY + 56
    local tabW = 130
    local tabH = 24
    local tabGap = 4
    for i, catKey in ipairs(CAT_ORDER) do
        local catInfo = CATEGORIES[catKey]
        local bx = tabX + (i - 1) * (tabW + tabGap)
        local isActive = activeCategory == catKey
        if isActive then
            love.graphics.setColor(catInfo.color[1] * 0.3, catInfo.color[2] * 0.3, catInfo.color[3] * 0.3, alpha)
        else
            love.graphics.setColor(0.12, 0.13, 0.16, alpha * 0.6)
        end
        love.graphics.rectangle("fill", bx, tabY, tabW, tabH, 3, 3, 3, 3)
        love.graphics.setColor(catInfo.color[1], catInfo.color[2], catInfo.color[3], alpha)
        love.graphics.rectangle("line", bx, tabY, tabW, tabH, 3, 3, 3, 3)
        love.graphics.setColor(isActive and 1 or 0.8, isActive and 1 or 0.8, isActive and 1 or 0.85, alpha)
        love.graphics.setFont(smallFont)
        love.graphics.print(catInfo.label, bx + 8, tabY + 6)
    end

    -- Content
    local contentTop = panelY + 92
    local contentH = panelH - 112
    local contentLeft = panelX + 16
    local contentW = panelW - 32

    love.graphics.setScissor(panelX + 8, contentTop, panelW - 16, contentH)

    local mx, my = love.mouse.getPosition()
    local adjMx = mx - offsetX
    local adjMy = my - offsetY

    local y = contentTop - scrollOffset
    rowPositions = {}

    love.graphics.setFont(font)

    if activeCategory == "game" then
        -- Difficulty
        if _G.DifficultySettings then
            local info = _G.DifficultySettings.getCurrentInfo()
            local r = drawValueRow(contentLeft, y, contentW, "Težavnost",
                info.icon .. " " .. info.label, info.color, alpha,
                adjMx >= contentLeft and adjMx <= contentLeft + contentW and adjMy >= y and adjMy <= y + 32)
            rowPositions[#rowPositions + 1] = { type = "link", target = "difficulty", unpackSafe = r }
            y = y + 36
        end

        -- Game speed
        if _G.GameSpeedControl then
            local stats = _G.GameSpeedControl.getStats()
            local r = drawValueRow(contentLeft, y, contentW, "Hitrost igre",
                stats.currentName .. " " .. stats.currentLabel, {0.4, 0.7, 0.95}, alpha,
                adjMx >= contentLeft and adjMx <= contentLeft + contentW and adjMy >= y and adjMy <= y + 32)
            rowPositions[#rowPositions + 1] = { type = "link", target = "speed", unpackSafe = r }
            y = y + 36
        end

        -- Auto-save
        if _G.AutoSaveSystem then
            local stats = _G.AutoSaveSystem.getStats()
            local r = drawValueRow(contentLeft, y, contentW, "Auto-save",
                stats.enabled and "VKLOPLJEN" or "IZKLOPLJEN",
                stats.enabled and {0.3, 0.85, 0.4} or {0.85, 0.4, 0.3}, alpha,
                adjMx >= contentLeft and adjMx <= contentLeft + contentW and adjMy >= y and adjMy <= y + 32)
            rowPositions[#rowPositions + 1] = { type = "link", target = "autosave", unpackSafe = r }
            y = y + 36
        end

    elseif activeCategory == "ui" then
        -- UI Sounds
        local sfxEnabled = _G.UISoundHelper and _G.UISoundHelper.isEnabled() or false
        local r1 = drawToggleRow(contentLeft, y, contentW, "UI zvočni efekti", sfxEnabled, alpha,
            adjMx >= contentLeft and adjMx <= contentLeft + contentW and adjMy >= y and adjMy <= y + 32)
        rowPositions[#rowPositions + 1] = { type = "toggle", target = "ui_sfx", x = r1.x, y = r1.y, w = r1.w, h = r1.h, rowY = r1.rowY, rowH = r1.rowH }
        y = y + 36

        -- Help overlay
        local helpEnabled = _G.HelpOverlay and _G.HelpOverlay.isEnabled() or false
        local r2 = drawToggleRow(contentLeft, y, contentW, "Pomoč overlay (tips)", helpEnabled, alpha,
            adjMx >= contentLeft and adjMx <= contentLeft + contentW and adjMy >= y and adjMy <= y + 32)
        rowPositions[#rowPositions + 1] = { type = "toggle", target = "help_overlay", x = r2.x, y = r2.y, w = r2.w, h = r2.h, rowY = r2.rowY, rowH = r2.rowH }
        y = y + 36

        -- Minimap
        local mmEnabled = _G.MinimapWidget and _G.MinimapWidget.isVisible() or false
        local r3 = drawToggleRow(contentLeft, y, contentW, "Minimap HUD", mmEnabled, alpha,
            adjMx >= contentLeft and adjMx <= contentLeft + contentW and adjMy >= y and adjMy <= y + 32)
        rowPositions[#rowPositions + 1] = { type = "toggle", target = "minimap", x = r3.x, y = r3.y, w = r3.w, h = r3.h, rowY = r3.rowY, rowH = r3.rowH }
        y = y + 36

        -- Tutorial hints
        local tutEnabled = _G.TutorialHints and _G.TutorialHints.getStats and _G.TutorialHints.getStats().enabled or true
        local r4 = drawToggleRow(contentLeft, y, contentW, "Tutorial hinti", tutEnabled, alpha,
            adjMx >= contentLeft and adjMx <= contentLeft + contentW and adjMy >= y and adjMy <= y + 32)
        rowPositions[#rowPositions + 1] = { type = "toggle", target = "tutorial", x = r4.x, y = r4.y, w = r4.w, h = r4.h, rowY = r4.rowY, rowH = r4.rowH }
        y = y + 36

        -- Keybind editor link
        local r5 = drawValueRow(contentLeft, y, contentW, "Urejevalnik tipk", "Ctrl+Shift+K", {0.85, 0.7, 0.3}, alpha,
            adjMx >= contentLeft and adjMx <= contentLeft + contentW and adjMy >= y and adjMy <= y + 32)
        rowPositions[#rowPositions + 1] = { type = "link", target = "keybind_editor", unpackSafe = r5 }
        y = y + 36

    elseif activeCategory == "display" then
        -- HD mode
        local hdOn = _G.PROF_CAPTURE or false
        local r1 = drawToggleRow(contentLeft, y, contentW, "HD profiliranje", hdOn, alpha,
            adjMx >= contentLeft and adjMx <= contentLeft + contentW and adjMy >= y and adjMy <= y + 32)
        rowPositions[#rowPositions + 1] = { type = "info", target = "hd", x = r1.x, y = r1.y, w = r1.w, h = r1.h, rowY = r1.rowY, rowH = r1.rowH }
        y = y + 36

        -- Postshader
        local psOn = _G.postshader and true or false
        local r2 = drawValueRow(contentLeft, y, contentW, "Postshader", psOn and "VKLOPLJEN" or "IZKLOPLJEN",
            psOn and {0.3, 0.85, 0.4} or {0.85, 0.4, 0.3}, alpha,
            adjMx >= contentLeft and adjMx <= contentLeft + contentW and adjMy >= y and adjMy <= y + 32)
        rowPositions[#rowPositions + 1] = { type = "info", target = "postshader", unpackSafe = r2 }
        y = y + 36

        -- Performance overlay
        local perfOn = false
        if _G.PerformanceOverlay and _G.PerformanceOverlay.isVisible then
            perfOn = _G.PerformanceOverlay.isVisible()
        end
        local r3 = drawToggleRow(contentLeft, y, contentW, "Performance overlay (F3)", perfOn, alpha,
            adjMx >= contentLeft and adjMx <= contentLeft + contentW and adjMy >= y and adjMy <= y + 32)
        rowPositions[#rowPositions + 1] = { type = "link", target = "perf", x = r3.x, y = r3.y, w = r3.w, h = r3.h, rowY = r3.rowY, rowH = r3.rowH }
        y = y + 36

        -- Screen resolution
        local sw, sh = love.graphics.getDimensions()
        local r4 = drawValueRow(contentLeft, y, contentW, "Ločljivost", sw .. "×" .. sh, {0.6, 0.7, 0.85}, alpha,
            adjMx >= contentLeft and adjMx <= contentLeft + contentW and adjMy >= y and adjMy <= y + 32)
        rowPositions[#rowPositions + 1] = { type = "info", target = "resolution", unpackSafe = r4 }
        y = y + 36

    elseif activeCategory == "gameplay" then
        -- Game speed info
        if _G.GameSpeedControl then
            local stats = _G.GameSpeedControl.getStats()
            love.graphics.setColor(0.6, 0.65, 0.7, alpha)
            love.graphics.setFont(smallFont)
            love.graphics.print("Hitrost igre: " .. stats.currentName .. " " .. stats.currentLabel, contentLeft + 12, y + 8)
            love.graphics.setFont(font)
            y = y + 36
        end

        -- Pause state
        local paused = _G.paused or false
        local r2 = drawValueRow(contentLeft, y, contentW, "Stanje igre", paused and "⏸ PAVZIRANA" or "▶ V TEKU",
            paused and {0.85, 0.5, 0.3} or {0.3, 0.85, 0.4}, alpha,
            adjMx >= contentLeft and adjMx <= contentLeft + contentW and adjMy >= y and adjMy <= y + 32)
        rowPositions[#rowPositions + 1] = { type = "info", target = "pause", unpackSafe = r2 }
        y = y + 36

        -- Combat stats
        if _G.CombatIntegration and _G.CombatIntegration.getStats then
            local cs = _G.CombatIntegration.getStats()
            local r3 = drawValueRow(contentLeft, y, contentW, "K/D razmerje",
                string.format("%.2f (%d/%d)", cs.kdr, cs.playerKills, cs.playerDeaths),
                {0.85, 0.65, 0.3}, alpha,
                adjMx >= contentLeft and adjMx <= contentLeft + contentW and adjMy >= y and adjMy <= y + 32)
            rowPositions[#rowPositions + 1] = { type = "info", target = "combat", unpackSafe = r3 }
            y = y + 36
        end

        -- Achievements
        if _G.AchievementTracker and _G.AchievementTracker.getStats then
            local as = _G.AchievementTracker.getStats()
            local r4 = drawValueRow(contentLeft, y, contentW, "Dosežki",
                as.unlocked .. "/" .. as.total .. " (" .. string.format("%.0f%%", as.percent) .. ")",
                {0.85, 0.6, 0.95}, alpha,
                adjMx >= contentLeft and adjMx <= contentLeft + contentW and adjMy >= y and adjMy <= y + 32)
            rowPositions[#rowPositions + 1] = { type = "link", target = "achievements", unpackSafe = r4 }
            y = y + 36
        end

        -- Reset all settings
        local r5 = drawValueRow(contentLeft, y, contentW, "⚠ Ponastavi vse nastavitve", "Shift+R",
            {0.9, 0.4, 0.3}, alpha,
            adjMx >= contentLeft and adjMx <= contentLeft + contentW and adjMy >= y and adjMy <= y + 32)
        rowPositions[#rowPositions + 1] = { type = "info", target = "reset", unpackSafe = r5 }
        y = y + 36
    end

    love.graphics.setScissor()

    -- Scrollbar
    local totalH = y - (contentTop - scrollOffset)
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
    love.graphics.print("Vse nastavitve na enem mestu  |  Tab: kategorija  |  Klik: toggle/odpri",
        panelX + 16, panelY + panelH - 20)

    love.graphics.setFont(font)
    love.graphics.pop()
    love.graphics.setColor(1, 1, 1, 1)
end

function UnifiedSettings.wheelmoved(x, y)
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

function UnifiedSettings.keypressed(key, scancode, isrepeat)
    if not visible and not PanelAnim.isAnimating(animState) then return false end
    if key == "escape" then
        UnifiedSettings.toggle()
        return true
    end
    if key == "tab" then
        for i, c in ipairs(CAT_ORDER) do
            if c == activeCategory then
                activeCategory = CAT_ORDER[(i % #CAT_ORDER) + 1]
                UISound.playTabSwitch()
                break
            end
        end
        scrollOffset = 0
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

function UnifiedSettings.mousepressed(x, y, button)
    if not visible and not PanelAnim.isAnimating(animState) then return false end
    if button ~= 1 then return false end

    local screenW = love.graphics.getWidth()
    local panelW = math.min(680, screenW - 60)
    local panelX = (screenW - panelW) / 2
    local screenH = love.graphics.getHeight()
    local panelH = math.min(620, screenH - 60)
    local panelY = (screenH - panelH) / 2

    -- Category tab click
    local tabX = panelX + 16
    local tabY = panelY + 56
    local tabW = 130
    local tabH = 24
    local tabGap = 4
    for i, catKey in ipairs(CAT_ORDER) do
        local bx = tabX + (i - 1) * (tabW + tabGap)
        if x >= bx and x <= bx + tabW and y >= tabY and y <= tabY + tabH then
            if activeCategory ~= catKey then
                activeCategory = catKey
                UISound.playTabSwitch()
            end
            scrollOffset = 0
            return true
        end
    end

    -- Row clicks (toggles and links)
    for _, pos in ipairs(rowPositions) do
        if pos.type == "toggle" then
            -- Check if click is on the toggle switch
            if x >= pos.x and x <= pos.x + pos.w and
               y >= pos.y and y <= pos.y + pos.h then
                -- Toggle the setting
                if pos.target == "ui_sfx" and _G.UISoundHelper then
                    _G.UISoundHelper.toggle()
                elseif pos.target == "help_overlay" and _G.HelpOverlay then
                    _G.HelpOverlay.toggle()
                elseif pos.target == "minimap" and _G.MinimapWidget then
                    _G.MinimapWidget.toggle()
                elseif pos.target == "tutorial" and _G.TutorialHints then
                    local stats = _G.TutorialHints.getStats()
                    _G.TutorialHints.setEnabled(not stats.enabled)
                end
                UISound.playClick()
                return true
            end
        elseif pos.type == "link" then
            -- Check if click is on the row
            if x >= pos.unpackSafe and x <= pos.unpackSafe + contentW and
               y >= pos.unpackSafe and y <= pos.unpackSafe + 32 then
                -- Open the relevant panel
                if pos.target == "difficulty" and _G.DifficultyPanel then
                    _G.DifficultyPanel.toggle()
                elseif pos.target == "speed" and _G.GameSpeedControl then
                    _G.GameSpeedControl.cycleSpeed()
                elseif pos.target == "autosave" and _G.AutoSavePanel then
                    _G.AutoSavePanel.toggle()
                elseif pos.target == "keybind_editor" and _G.KeybindEditor then
                    _G.KeybindEditor.toggle()
                elseif pos.target == "achievements" and _G.AchievementPanel then
                    _G.AchievementPanel.toggle()
                elseif pos.target == "perf" and _G.PerformanceOverlay then
                    _G.PerformanceOverlay.toggle()
                end
                UISound.playClick()
                return true
            end
        end
    end

    -- Click outside panel closes
    if x < panelX or x > panelX + panelW or y < panelY or y > panelY + panelH then
        UnifiedSettings.toggle()
        return true
    end
    return false
end

function UnifiedSettings.mousemoved(x, y, dx, dy)
    return false
end

return UnifiedSettings
