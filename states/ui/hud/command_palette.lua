-- states/ui/hud/command_palette.lua
-- Castle Kingdoms 2027 v3.12.149 - Command Palette
--
-- Quick search-based access to ALL game actions:
--   * Open any panel (Tech Tree, Market, Achievements, etc.)
--   * Change difficulty, speed, theme
--   * Toggle settings (UI sounds, minimap, help overlay)
--   * Execute commands (force save, reset hints, screenshot)
--
-- Toggle with Ctrl+Space.
-- Type to filter, ↑↓ to navigate, ENTER to execute, ESC to close.

local PanelAnim = require("states.ui.hud.PanelAnimations")
local UISound = require("objects.Audio.UISoundHelper")

local CommandPalette = {}

local visible = false
local query = ""
local selectedIndex = 1
local scrollOffset = 0
local results = {}

local animState = PanelAnim.createState({
    duration = 0.15,
    slideDir = "down",
    slideDist = 16,
    easing = "easeOut",
})

-- All available commands
local COMMANDS = {
    -- Panels
    { cmd = "tech_tree",         label = "Odpri Tech Tree",         desc = "Graf odvisnosti sistemov",      key = "Ctrl+Shift+G", icon = "🌳" },
    { cmd = "royal_systems",     label = "Odpri Royal Sisteme",     desc = "990 proizvodnih sistemov",     key = "Ctrl+R",       icon = "👑" },
    { cmd = "market_dashboard",  label = "Odpri Market Dashboard", desc = "Cene, prodaja, trendi",        key = "Ctrl+K",       icon = "📊" },
    { cmd = "auto_save_panel",   label = "Odpri Auto-Save Panel",   desc = "Status, interval, force save",key = "Ctrl+U",       icon = "💾" },
    { cmd = "achievements",      label = "Odpri Dosežke",           desc = "37 dosežkov z rarity",        key = "Ctrl+Shift+A", icon = "🏆" },
    { cmd = "statistics",        label = "Odpri Statistiko",        desc = "4 zavihki z grafi",            key = "Ctrl+Shift+I", icon = "📈" },
    { cmd = "tutorial_mgr",     label = "Odpri Tutorial Manager",  desc = "30 hintov z persistenco",      key = "Ctrl+Shift+O", icon = "🎓" },
    { cmd = "difficulty",        label = "Spremeni težavnost",      desc = "5 stopenj z modifierji",       key = "Ctrl+Shift+F", icon = "⚔" },
    { cmd = "keybind_editor",    label = "Urejevalnik tipk",         desc = "Customizacija bližnjic",      key = "Ctrl+Shift+K", icon = "⌨" },
    { cmd = "unified_settings",  label = "Nastavitve",               desc = "Vse na enem mestu",            key = "Ctrl+Shift+E", icon = "⚙" },
    { cmd = "event_log",         label = "Dnevnik dogodkov",         desc = "Centralni log vseh events",   key = "Ctrl+Shift+L", icon = "📋" },
    { cmd = "keybind_help",      label = "Tipkovne bližnjice",       desc = "Vse tipke po kategorijah",    key = "F1",           icon = "❓" },
    { cmd = "toast_history",    label = "Toast zgodovina",          desc = "Zadnjih 100 obvestil",         key = "N",            icon = "🔔" },
    -- Actions
    { cmd = "cycle_theme",       label = "Spremeni barvno temo",    desc = "Ciklaj 6 tem",                key = "Ctrl+Shift+J", icon = "🎨" },
    { cmd = "toggle_ui_sfx",    label = "Toggle UI zvoki",          desc = "Vklop/izklop zvočnih efektov",key = "F2",           icon = "🔊" },
    { cmd = "toggle_help",       label = "Toggle help overlay",      desc = "Tips in context help",        key = "H",            icon = "💡" },
    { cmd = "toggle_pause",      label = "Pavza / nadaljuj",         desc = "Pavziraj igro",                key = "Space",        icon = "⏸" },
    { cmd = "speed_1x",         label = "Hitrost: 1x",              desc = "Normalna hitrost",            key = "1",            icon = "▶" },
    { cmd = "speed_2x",         label = "Hitrost: 2x",              desc = "Dvojna hitrost",              key = "2",            icon = "⏩" },
    { cmd = "speed_3x",         label = "Hitrost: 3x",              desc = "Trojna hitrost",                key = "3",            icon = "⏭" },
    { cmd = "screenshot",        label = "Screenshot",               desc = "Zajemi zaslon",               key = "Ctrl+M",       icon = "📷" },
    { cmd = "force_save",       label = "Force save",              desc = "Takojšnje shranjevanje",      key = "—",            icon = "💾" },
    { cmd = "reset_hints",     label = "Reset tutorial hints",     desc = "Ponastavi vse hinte",         key = "—",            icon = "🔄" },
    { cmd = "toggle_morale",   label = "Toggle morale bars",         desc = "Prikaz morale barov nad enotami", key = "Ctrl+Shift+Z", icon = "⚔" },
    { cmd = "toggle_spacing",  label = "Toggle anti-clustering debug", desc = "Prikaz spacing radiusov v boju (debug)", key = "—",            icon = "🔄" },
    { cmd = "toggle_lod",      label = "Toggle LOD debug",            desc = "Prikaz LOD level-ov enot (debug)",  key = "—",            icon = "📊" },
    { cmd = "toggle_hd_terrain", label = "Toggle HD terrain",         desc = "HD teksture za teren (256x256)",   key = "—",            icon = "🌍" },
    { cmd = "toggle_hd_buildings", label = "Toggle HD buildings",     desc = "HD sprite-i za zgradbe (256x256)", key = "—",            icon = "🏰" },
}

-- Execute a command
local function executeCommand(cmd)
    if cmd == "tech_tree" and _G.TechTreePanel then _G.TechTreePanel.toggle()
    elseif cmd == "royal_systems" and _G.RoyalSystemsPanel then _G.RoyalSystemsPanel.toggle()
    elseif cmd == "market_dashboard" and _G.MarketDashboard then _G.MarketDashboard.toggle()
    elseif cmd == "auto_save_panel" and _G.AutoSavePanel then _G.AutoSavePanel.toggle()
    elseif cmd == "achievements" and _G.AchievementPanel then _G.AchievementPanel.toggle()
    elseif cmd == "statistics" and _G.StatsPanel then _G.StatsPanel.toggle()
    elseif cmd == "tutorial_mgr" and _G.TutorialPanel then _G.TutorialPanel.toggle()
    elseif cmd == "difficulty" and _G.DifficultyPanel then _G.DifficultyPanel.toggle()
    elseif cmd == "keybind_editor" and _G.KeybindEditor then _G.KeybindEditor.toggle()
    elseif cmd == "unified_settings" and _G.UnifiedSettings then _G.UnifiedSettings.toggle()
    elseif cmd == "event_log" and _G.EventLogPanel then _G.EventLogPanel.toggle()
    elseif cmd == "keybind_help" and _G.KeybindHelp then _G.KeybindHelp.toggle()
    elseif cmd == "toast_history" and _G.NotificationCenter then _G.NotificationCenter.toggleHistoryPanel()
    elseif cmd == "cycle_theme" and _G.ColorTheme then _G.ColorTheme.cycle()
    elseif cmd == "toggle_ui_sfx" and _G.UISoundHelper then _G.UISoundHelper.toggle()
    elseif cmd == "toggle_help" and _G.HelpOverlay then _G.HelpOverlay.toggle()
    elseif cmd == "toggle_pause" and _G.GameSpeedControl then _G.GameSpeedControl.togglePause()
    elseif cmd == "speed_1x" and _G.GameSpeedControl then _G.GameSpeedControl.setSpeed(2)
    elseif cmd == "speed_2x" and _G.GameSpeedControl then _G.GameSpeedControl.setSpeed(3)
    elseif cmd == "speed_3x" and _G.GameSpeedControl then _G.GameSpeedControl.setSpeed(4)
    elseif cmd == "screenshot" then
        if _G.ScreenshotManager then pcall(function() _G.ScreenshotManager.capture("palette") end) end
    elseif cmd == "force_save" and _G.AutoSaveSystem then _G.AutoSaveSystem.forceSave()
    elseif cmd == "reset_hints" and _G.TutorialHints then _G.TutorialHints.reset()
    elseif cmd == "toggle_morale" and _G.MoraleSystem then _G.MoraleSystem.toggle()
    elseif cmd == "toggle_spacing" and _G.SpacingSystem then _G.SpacingSystem.toggle()
    elseif cmd == "toggle_lod" and _G.LODSystem then _G.LODSystem.toggle()
    elseif cmd == "toggle_hd_terrain" and _G.TerrainOverride then _G.TerrainOverride.toggle()
    elseif cmd == "toggle_hd_buildings" and _G.BuildingOverride then _G.BuildingOverride.toggle()
    end
    UISound.playSuccess()
    CommandPalette.toggle()
end

-- Filter commands by query
local function updateResults()
    results = {}
    local q = query:lower()
    for _, cmd in ipairs(COMMANDS) do
        if q == "" or
           cmd.label:lower():find(q, 1, true) or
           cmd.desc:lower():find(q, 1, true) or
           cmd.cmd:lower():find(q, 1, true) then
            results[#results + 1] = cmd
        end
    end
    if selectedIndex > #results then selectedIndex = 1 end
    if selectedIndex < 1 then selectedIndex = 1 end
end

function CommandPalette.toggle()
    if not visible then
        visible = true
        PanelAnim.open(animState)
        UISound.playPanelOpen()
        query = ""
        selectedIndex = 1
        scrollOffset = 0
        updateResults()
    else
        PanelAnim.close(animState)
        UISound.playPanelClose()
    end
end

function CommandPalette.isVisible()
    return visible or PanelAnim.isAnimating(animState)
end

function CommandPalette.update(dt)
    if not visible and not PanelAnim.isAnimating(animState) then return end
    PanelAnim.update(animState, dt)
    if animState.phase == "closed" then
        visible = false
    end
end

function CommandPalette.draw()
    if not visible and not PanelAnim.isAnimating(animState) then return end

    local alpha = PanelAnim.getProgress(animState)
    local offsetX, offsetY = PanelAnim.getOffset(animState)

    local screenW, screenH = love.graphics.getDimensions()
    local paletteW = math.min(560, screenW - 80)
    local paletteX = (screenW - paletteW) / 2
    local paletteY = math.min(120, screenH * 0.15)

    local font = love.graphics.getFont()
    local titleFont = love.graphics.newFont(16)
    local smallFont = love.graphics.newFont(11)

    love.graphics.push("all")
    love.graphics.translate(offsetX, offsetY)

    -- Dim background (lighter than panel dim)
    love.graphics.setColor(0, 0, 0, 0.4 * alpha)
    love.graphics.rectangle("fill", 0, 0, screenW, screenH)

    -- Search input box
    local inputH = 44
    love.graphics.setColor(0.1, 0.1, 0.14, 0.98 * alpha)
    love.graphics.rectangle("fill", paletteX, paletteY, paletteW, inputH, 6, 6, 0, 0)
    love.graphics.setColor(0.4, 0.5, 0.7, alpha)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", paletteX, paletteY, paletteW, inputH, 6, 6, 0, 0)
    love.graphics.setLineWidth(1)

    -- Search icon + text
    love.graphics.setFont(titleFont)
    love.graphics.setColor(0.5, 0.6, 0.7, alpha)
    love.graphics.print("🔍", paletteX + 12, paletteY + 10)
    love.graphics.setColor(1, 1, 1, alpha)
    local displayQuery = query
    if #query == 0 then
        love.graphics.setColor(0.4, 0.45, 0.5, alpha)
        displayQuery = "Išči ukaze... (npr. 'tech', 'market', 'theme')"
    end
    love.graphics.print(displayQuery, paletteX + 40, paletteY + 12)

    -- Cursor blink
    if visible and love.timer.getTime() % 1 < 0.5 then
        local cursorX = paletteX + 40 + font:getWidth(query)
        love.graphics.setColor(0.8, 0.85, 0.9, alpha)
        love.graphics.rectangle("fill", cursorX, paletteY + 12, 2, 20)
    end

    -- Results
    local maxResults = 10
    local resultH = 32
    local resultsH = math.min(#results, maxResults) * resultH
    if resultsH > 0 then
        love.graphics.setColor(0.08, 0.08, 0.12, 0.98 * alpha)
        love.graphics.rectangle("fill", paletteX, paletteY + inputH, paletteW, resultsH, 0, 0, 6, 6)
        love.graphics.setColor(0.3, 0.4, 0.5, alpha * 0.5)
        love.graphics.setLineWidth(1)
        love.graphics.rectangle("line", paletteX, paletteY + inputH, paletteW, resultsH, 0, 0, 6, 6)

        love.graphics.setScissor(paletteX, paletteY + inputH, paletteW, resultsH)

        for i = 1, math.min(#results, maxResults) do
            local cmd = results[i]
            local ry = paletteY + inputH + (i - 1) * resultH
            local isSelected = i == selectedIndex

            -- Selected row highlight
            if isSelected then
                love.graphics.setColor(0.2, 0.3, 0.5, alpha * 0.8)
                love.graphics.rectangle("fill", paletteX + 2, ry + 1, paletteW - 4, resultH - 2, 3, 3, 3, 3)
            end

            -- Icon
            love.graphics.setFont(font)
            love.graphics.setColor(isSelected and 1 or 0.7, isSelected and 1 or 0.7, isSelected and 1 or 0.75, alpha)
            love.graphics.print(cmd.icon or "▸", paletteX + 12, ry + 7)

            -- Label
            love.graphics.setColor(isSelected and 1 or 0.85, isSelected and 1 or 0.85, isSelected and 1 or 0.9, alpha)
            love.graphics.print(cmd.label, paletteX + 40, ry + 7)

            -- Description
            love.graphics.setFont(smallFont)
            love.graphics.setColor(0.5, 0.55, 0.6, alpha)
            love.graphics.print(cmd.desc, paletteX + 40, ry + 21)

            -- Keybind hint
            if cmd.key and cmd.key ~= "—" then
                love.graphics.setColor(0.6, 0.65, 0.7, alpha * 0.7)
                local kw = smallFont:getWidth(cmd.key)
                love.graphics.print(cmd.key, paletteX + paletteW - kw - 16, ry + 10)
            end

            love.graphics.setFont(font)
        end

        love.graphics.setScissor()
    end

    -- Footer hint
    if #results == 0 then
        love.graphics.setFont(smallFont)
        love.graphics.setColor(0.5, 0.5, 0.5, alpha)
        love.graphics.print("(ni rezultatov)", paletteX + 12, paletteY + inputH + 8)
    end

    love.graphics.setFont(smallFont)
    love.graphics.setColor(0.4, 0.45, 0.5, alpha)
    love.graphics.print("↑↓: navigiraj  |  ENTER: izvedi  |  ESC: zapri  |  Ctrl+Space: toggle",
        paletteX + 12, paletteY + inputH + resultsH + 6)

    love.graphics.setFont(font)
    love.graphics.pop()
    love.graphics.setColor(1, 1, 1, 1)
end

function CommandPalette.keypressed(key, scancode, isrepeat)
    if not visible and not PanelAnim.isAnimating(animState) then return false end

    if key == "escape" then
        CommandPalette.toggle()
        return true
    end
    if key == "return" then
        if results[selectedIndex] then
            executeCommand(results[selectedIndex].cmd)
        end
        return true
    end
    if key == "up" then
        selectedIndex = math.max(1, selectedIndex - 1)
        UISound.playClick()
        return true
    end
    if key == "down" then
        selectedIndex = math.min(#results, selectedIndex + 1)
        UISound.playClick()
        return true
    end
    if key == "backspace" then
        query = query:sub(1, -2)
        selectedIndex = 1
        updateResults()
        return true
    end
    return false
end

function CommandPalette.textinput(text)
    if not visible then return false end
    if #query < 40 and text:match("^[%w%s%-_]+$") then
        query = query .. text
        selectedIndex = 1
        updateResults()
    end
    return true
end

function CommandPalette.mousepressed(x, y, button)
    if not visible and not PanelAnim.isAnimating(animState) then return false end
    if button ~= 1 then return false end

    local screenW = love.graphics.getDimensions()
    local paletteW = math.min(560, screenW - 80)
    local paletteX = (screenW - paletteW) / 2
    local paletteY = math.min(120, love.graphics.getHeight() * 0.15)
    local inputH = 44
    local resultH = 32

    -- Click on a result
    for i = 1, math.min(#results, 10) do
        local ry = paletteY + inputH + (i - 1) * resultH
        if x >= paletteX and x <= paletteX + paletteW and
           y >= ry and y <= ry + resultH then
            selectedIndex = i
            executeCommand(results[i].cmd)
            return true
        end
    end

    -- Click outside closes
    if y < paletteY or y > paletteY + inputH + math.min(#results, 10) * resultH + 30 then
        CommandPalette.toggle()
        return true
    end
    return false
end

function CommandPalette.wheelmoved(x, y)
    if not visible then return false end
    if y > 0 then
        selectedIndex = math.max(1, selectedIndex - 1)
        return true
    elseif y < 0 then
        selectedIndex = math.min(#results, selectedIndex + 1)
        return true
    end
    return false
end

return CommandPalette
