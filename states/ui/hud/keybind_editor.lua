-- states/ui/hud/keybind_editor.lua
-- Castle Kingdoms 2027 v3.12.144 - Keyboard Shortcut Editor
--
-- Allows players to view and customize keybinds:
--   * List all keybinds organized by category
--   * Click on a keybind to rebind it (press new key)
--   * Reset to defaults button
--   * Persistence (custom_keybinds.txt)
--   * Search/filter
--
-- Toggle with Ctrl+Shift+K.

local PanelAnim = require("states.ui.hud.PanelAnimations")
local UISound = require("objects.Audio.UISoundHelper")

local KeybindEditor = {}

local visible = false
local scrollOffset = 0
local searchQuery = ""
local searchActive = false
local rebindingKey = nil  -- which keybind is being rebound (key string)
local rowPositions = {}

local CUSTOM_FILE = "custom_keybinds.txt"
local customBindings = {}

-- Load custom bindings
local function loadCustomBindings()
    local ok, content = pcall(love.filesystem.read, CUSTOM_FILE)
    if ok and content then
        for line in content:gmatch("[^\n]+") do
            local action, key = line:match("^([^=]+)=(.+)$")
            if action and key then
                customBindings[action:match("^%s*(.-)%s*$")] = key:match("^%s*(.-)%s*$")
            end
        end
    end
end
loadCustomBindings()

local function saveCustomBindings()
    local lines = {}
    for action, key in pairs(customBindings) do
        lines[#lines + 1] = action .. "=" .. key
    end
    pcall(love.filesystem.write, CUSTOM_FILE, table.concat(lines, "\n") .. "\n")
end

-- Keybind definitions (action -> {defaultKey, description, category})
local KEYBINDS = {
    -- OSNOVNO
    { action = "pause_menu",       defaultKey = "escape", desc = "Pavza / meni", category = "OSNOVNO" },
    { action = "keybind_help",     defaultKey = "f1",     desc = "Pomoč (to okno)", category = "OSNOVNO" },
    { action = "ui_sfx_toggle",    defaultKey = "f2",     desc = "Toggle UI zvoki", category = "OSNOVNO" },
    { action = "help_overlay",     defaultKey = "h",      desc = "Help overlay toggle", category = "OSNOVNO" },
    { action = "toast_history",    defaultKey = "n",      desc = "Toast zgodovina", category = "OSNOVNO" },
    { action = "game_speed_pause", defaultKey = "space",  desc = "Pavza igre", category = "OSNOVNO" },
    { action = "game_speed_1",     defaultKey = "1",      desc = "1x hitrost", category = "OSNOVNO" },
    { action = "game_speed_2",     defaultKey = "2",      desc = "2x hitrost", category = "OSNOVNO" },
    { action = "game_speed_3",     defaultKey = "3",      desc = "3x hitrost", category = "OSNOVNO" },
    { action = "game_speed_5",     defaultKey = "4",      desc = "5x hitrost", category = "OSNOVNO" },
    { action = "reset_settings",   defaultKey = "shift+r", desc = "Ponastavi vse", category = "OSNOVNO" },
    -- EKONOMIJA
    { action = "market",          defaultKey = "m",       desc = "Tržnica", category = "EKONOMIJA" },
    { action = "caravans",        defaultKey = "c",       desc = "Karavane", category = "EKONOMIJA" },
    { action = "royal_systems",   defaultKey = "ctrl+r",  desc = "Royal sistemi", category = "EKONOMIJA" },
    { action = "market_dash",     defaultKey = "ctrl+k",  desc = "Market dashboard", category = "EKONOMIJA" },
    { action = "tech_tree",       defaultKey = "ctrl+shift+g", desc = "Tech tree", category = "EKONOMIJA" },
    { action = "auto_save_panel", defaultKey = "ctrl+u",  desc = "Auto-save panel", category = "EKONOMIJA" },
    { action = "auto_save_toggle",defaultKey = "shift+u", desc = "Auto-save toggle", category = "EKONOMIJA" },
    { action = "auto_save_hide",  defaultKey = "ctrl+shift+u", desc = "Auto-save overlay hide", category = "EKONOMIJA" },
    -- DOSEŽKI / STATS
    { action = "achievements",    defaultKey = "ctrl+shift+a", desc = "Dosežki", category = "PANELI" },
    { action = "statistics",      defaultKey = "ctrl+shift+i", desc = "Statistika", category = "PANELI" },
    { action = "tutorial_mgr",    defaultKey = "ctrl+shift+o", desc = "Tutorial manager", category = "PANELI" },
    { action = "difficulty",      defaultKey = "ctrl+shift+f", desc = "Težavnost", category = "PANELI" },
    -- WEATHER / TIME
    { action = "weather_cycle",   defaultKey = "ctrl+w",  desc = "Ciklus vremena", category = "OKOLJE" },
    { action = "screenshot",      defaultKey = "ctrl+m",  desc = "Screenshot", category = "OSTALO" },
}

-- Get effective key (custom or default)
local function getEffectiveKey(action)
    return customBindings[action] or action.defaultKey
end

-- Find keybind by action
local function findKeybind(actionName)
    for _, kb in ipairs(KEYBINDS) do
        if kb.action == actionName then return kb end
    end
    return nil
end

local animState = PanelAnim.createState({
    duration = 0.22,
    slideDir = "down",
    slideDist = 24,
    easing = "easeOut",
})

function KeybindEditor.toggle()
    if not visible then
        visible = true
        PanelAnim.open(animState)
        UISound.playPanelOpen()
        scrollOffset = 0
    else
        PanelAnim.close(animState)
        UISound.playPanelClose()
        rebindingKey = nil
    end
end

function KeybindEditor.setVisible(state)
    if state and not visible then
        visible = true
        PanelAnim.open(animState)
        scrollOffset = 0
    elseif not state and visible then
        PanelAnim.close(animState)
        rebindingKey = nil
    end
end

function KeybindEditor.isVisible()
    return visible or PanelAnim.isAnimating(animState)
end

function KeybindEditor.update(dt)
    if not visible and not PanelAnim.isAnimating(animState) then return end
    PanelAnim.update(animState, dt)
    if animState.phase == "closed" then
        visible = false
    end
end

-- Get filtered keybinds
local function getFilteredKeybinds()
    local result = {}
    local query = searchQuery:lower()
    for _, kb in ipairs(KEYBINDS) do
        if query == "" or
           kb.action:lower():find(query, 1, true) or
           kb.desc:lower():find(query, 1, true) or
           kb.category:lower():find(query, 1, true) then
            result[#result + 1] = kb
        end
    end
    return result
end

function KeybindEditor.draw()
    if not visible and not PanelAnim.isAnimating(animState) then return end

    local alpha = PanelAnim.getProgress(animState)
    local offsetX, offsetY = PanelAnim.getOffset(animState)

    local screenW, screenH = love.graphics.getDimensions()
    local panelW = math.min(700, screenW - 60)
    local panelH = math.min(600, screenH - 60)
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
    love.graphics.print("⌨ UREJEVALNIK TIPK — Castle Kingdoms 2027", panelX + 16, panelY + 12)

    -- Hint
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0.55, 0.6, 0.65, alpha)
    local hintText = "Ctrl+Shift+K: zapri  |  /: iskanje  |  klik: preveži  |  R: reset  |  ↑↓/wheel: scroll"
    if searchActive then hintText = "Iskanje: " .. searchQuery .. "_  |  ENTER: potrdi  |  ESC: prekliči" end
    if rebindingKey then hintText = "Pritisni novo tipko za: " .. rebindingKey .. "  |  ESC: prekliči" end
    love.graphics.print(hintText, panelX + 16, panelY + 36)

    -- Stats
    local customCount = 0
    for _ in pairs(customBindings) do customCount = customCount + 1 end
    love.graphics.setColor(0.8, 0.85, 0.9, alpha)
    love.graphics.print(string.format("Skupaj: %d bližnjic  |  Custom: %d  |  Default: %d",
        #KEYBINDS, customCount, #KEYBINDS - customCount), panelX + 16, panelY + 52)

    -- Search box
    local sbX = panelX + panelW - 200
    local sbY = panelY + 50
    love.graphics.setColor(0.1, 0.1, 0.12, alpha)
    love.graphics.rectangle("fill", sbX, sbY, 184, 22, 3, 3, 3, 3)
    love.graphics.setColor(0.4, 0.5, 0.7, alpha)
    love.graphics.rectangle("line", sbX, sbY, 184, 22, 3, 3, 3, 3)
    local searchText = searchActive and searchQuery .. "_" or (searchQuery ~= "" and searchQuery or "🔍 Iskanje... (/)")
    if searchText == "🔍 Iskanje... (/)" then
        love.graphics.setColor(0.4, 0.45, 0.5, alpha)
    else
        love.graphics.setColor(0.8, 0.85, 0.9, alpha)
    end
    love.graphics.print(searchText:sub(1, 26), sbX + 6, sbY + 5)

    -- Keybind list
    local contentTop = panelY + 86
    local contentH = panelH - 110
    local rowH = 30
    local contentLeft = panelX + 16
    local contentW = panelW - 32

    love.graphics.setScissor(panelX + 8, contentTop, panelW - 16, contentH)

    local filtered = getFilteredKeybinds()
    local listY = contentTop - scrollOffset
    rowPositions = {}

    -- Group by category
    local currentCategory = nil
    local y = listY
    for _, kb in ipairs(filtered) do
        if kb.category ~= currentCategory then
            currentCategory = kb.category
            love.graphics.setFont(smallFont)
            love.graphics.setColor(0.5, 0.6, 0.75, alpha)
            love.graphics.print("[" .. kb.category .. "]", contentLeft, y)
            y = y + 20
        end

        local rowY = y
        local isHovered = false
        local mx, my = love.mouse.getPosition()
        -- Adjust mouse for slide offset
        local adjMx = mx - offsetX
        local adjMy = my - offsetY
        if adjMx >= contentLeft and adjMx <= contentLeft + contentW and
           adjMy >= rowY and adjMy <= rowY + rowH - 4 then
            isHovered = true
        end
        local isRebinding = rebindingKey == kb.action

        -- Row bg
        if isRebinding then
            love.graphics.setColor(0.2, 0.3, 0.5, alpha * 0.9)
        elseif isHovered then
            love.graphics.setColor(0.15, 0.18, 0.22, alpha * 0.8)
        else
            love.graphics.setColor(0.08, 0.08, 0.1, alpha * 0.4)
        end
        love.graphics.rectangle("fill", contentLeft, rowY, contentW, rowH - 4, 3, 3, 3, 3)

        -- Key box
        local keyBoxW = 120
        local keyBoxH = 22
        local keyBoxX = contentLeft + 8
        local keyBoxY = rowY + 2
        local effKey = customBindings[kb.action] or kb.defaultKey
        love.graphics.setColor(0.15, 0.18, 0.22, alpha)
        love.graphics.rectangle("fill", keyBoxX, keyBoxY, keyBoxW, keyBoxH, 3, 3, 3, 3)
        if isRebinding then
            love.graphics.setColor(0.4, 0.7, 1, alpha)
            love.graphics.setLineWidth(2)
        elseif customBindings[kb.action] then
            love.graphics.setColor(0.85, 0.7, 0.3, alpha)
            love.graphics.setLineWidth(1)
        else
            love.graphics.setColor(0.4, 0.45, 0.55, alpha * 0.6)
            love.graphics.setLineWidth(1)
        end
        love.graphics.rectangle("line", keyBoxX, keyBoxY, keyBoxW, keyBoxH, 3, 3, 3, 3)
        love.graphics.setLineWidth(1)

        love.graphics.setFont(smallFont)
        if isRebinding then
            love.graphics.setColor(0.4, 0.7, 1, alpha)
            love.graphics.print("... pritisni ...", keyBoxX + 8, keyBoxY + 4)
        else
            love.graphics.setColor(customBindings[kb.action] and 1 or 0.85,
                                   customBindings[kb.action] and 0.85 or 0.85,
                                   customBindings[kb.action] and 0.3 or 0.9, alpha)
            love.graphics.print(effKey:upper(), keyBoxX + 8, keyBoxY + 4)
        end

        -- Description
        love.graphics.setColor(0.85, 0.88, 0.92, alpha)
        love.graphics.print(kb.desc, contentLeft + 140, rowY + 6)

        -- Custom badge
        if customBindings[kb.action] then
            love.graphics.setColor(0.85, 0.7, 0.3, alpha)
            love.graphics.print("★ custom", contentLeft + contentW - 80, rowY + 6)
        end

        rowPositions[#rowPositions + 1] = {
            action = kb.action,
            x = contentLeft, y = rowY, w = contentW, h = rowH - 4,
        }
        y = y + rowH
    end

    love.graphics.setScissor()

    -- Scrollbar
    local totalH = y - listY
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
    love.graphics.print(string.format("%d bližnjic  |  Persistenca v custom_keybinds.txt  |  R: reset na default",
        #filtered), panelX + 16, panelY + panelH - 20)

    love.graphics.setFont(font)
    love.graphics.pop()
    love.graphics.setColor(1, 1, 1, 1)
end

function KeybindEditor.wheelmoved(x, y)
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

function KeybindEditor.keypressed(key, scancode, isrepeat)
    if not visible and not PanelAnim.isAnimating(animState) then return false end

    -- Rebinding mode
    if rebindingKey then
        if key == "escape" then
            rebindingKey = nil
            UISound.playToggleOff()
            return true
        end
        -- Build key string with modifiers
        local keyStr = key
        if love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl") then
            keyStr = "ctrl+" .. keyStr
        end
        if love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
            keyStr = "shift+" .. keyStr
        end
        -- Save binding
        customBindings[rebindingKey] = keyStr
        saveCustomBindings()
        UISound.playSuccess()
        rebindingKey = nil
        return true
    end

    -- Search mode
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
        KeybindEditor.toggle()
        return true
    end
    if key == "/" then
        searchActive = true
        UISound.playSearchFocus()
        return true
    end
    if key == "r" then
        -- Reset to defaults
        customBindings = {}
        saveCustomBindings()
        UISound.playToggleOff()
        if _G.NotificationCenter then
            pcall(function()
                _G.NotificationCenter.system("Tipkovne bližnjice: reset na default",
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

function KeybindEditor.textinput(text)
    if not visible or not searchActive then return false end
    if #searchQuery < 30 and text:match("^[%w%s%-_]+$") then
        searchQuery = searchQuery .. text
    end
    return true
end

function KeybindEditor.mousepressed(x, y, button)
    if not visible and not PanelAnim.isAnimating(animState) then return false end
    if button ~= 1 then return false end

    local screenW = love.graphics.getWidth()
    local panelW = math.min(700, screenW - 60)
    local panelX = (screenW - panelW) / 2
    local screenH = love.graphics.getHeight()
    local panelH = math.min(600, screenH - 60)
    local panelY = (screenH - panelH) / 2

    -- Search box click
    local sbX = panelX + panelW - 200
    local sbY = panelY + 50
    if x >= sbX and x <= sbX + 184 and y >= sbY and y <= sbY + 22 then
        searchActive = true
        UISound.playSearchFocus()
        return true
    end

    -- Row click (start rebinding)
    for _, pos in ipairs(rowPositions) do
        if x >= pos.x and x <= pos.x + pos.w and
           y >= pos.y and y <= pos.y + pos.h then
            rebindingKey = pos.action
            UISound.playClick()
            return true
        end
    end

    -- Click outside panel closes
    if x < panelX or x > panelX + panelW or y < panelY or y > panelY + panelH then
        KeybindEditor.toggle()
        return true
    end
    return false
end

function KeybindEditor.mousemoved(x, y, dx, dy)
    return false
end

function KeybindEditor.getCustomBindings()
    return customBindings
end

function KeybindEditor.getEffectiveKey(action)
    return customBindings[action] or nil
end

return KeybindEditor
