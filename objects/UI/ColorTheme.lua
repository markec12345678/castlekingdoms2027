-- objects/UI/ColorTheme.lua
-- Castle Kingdoms 2027 v3.12.146 - Color Theme System
--
-- Provides customizable UI color themes:
--   * Royal Gold (default) — warm gold/amber on dark
--   * Midnight Blue — cool blue on dark navy
--   * Forest Green — green on dark green
--   * Crimson Royal — red on dark
--   * Pure Dark — minimal grayscale
--   * Royal Purple — purple on dark
--
-- Theme is persisted in color_theme.txt.
-- Access via Ctrl+Shift+T to cycle themes (T = Theme).

local ColorTheme = {}

local initialized = false
local currentThemeKey = "royal_gold"
local THEME_FILE = "color_theme.txt"

-- Theme definitions
-- Each theme defines colors used by UI panels:
--   bg       — panel background color
--   border   — panel border color
--   title    — title text color
--   accent   — accent/highlight color
--   text     — body text color
--   subtext  — secondary text color
--   success  — success/green color
--   warning  — warning/orange color
--   danger   — danger/red color
local THEMES = {
    royal_gold = {
        label = "Kraljevsko zlato",
        labelEn = "Royal Gold",
        icon = "👑",
        bg = {0.08, 0.07, 0.1, 0.98},
        border = {0.6, 0.5, 0.3, 1},
        title = {0.85, 0.75, 0.5, 1},
        accent = {0.95, 0.85, 0.3, 1},
        text = {0.85, 0.88, 0.92, 1},
        subtext = {0.55, 0.6, 0.65, 1},
        success = {0.3, 0.85, 0.4, 1},
        warning = {0.9, 0.7, 0.3, 1},
        danger = {0.9, 0.3, 0.3, 1},
        dimBg = {0, 0, 0, 0.65},
    },
    midnight_blue = {
        label = "Polnočno moder",
        labelEn = "Midnight Blue",
        icon = "🌙",
        bg = {0.04, 0.06, 0.12, 0.98},
        border = {0.3, 0.5, 0.7, 1},
        title = {0.5, 0.7, 0.95, 1},
        accent = {0.4, 0.65, 1, 1},
        text = {0.82, 0.88, 0.95, 1},
        subtext = {0.5, 0.6, 0.75, 1},
        success = {0.3, 0.8, 0.5, 1},
        warning = {0.85, 0.7, 0.3, 1},
        danger = {0.85, 0.35, 0.4, 1},
        dimBg = {0, 0, 0.05, 0.65},
    },
    forest_green = {
        label = "Gozdni zelen",
        labelEn = "Forest Green",
        icon = "🌲",
        bg = {0.05, 0.08, 0.06, 0.98},
        border = {0.3, 0.55, 0.35, 1},
        title = {0.5, 0.8, 0.5, 1},
        accent = {0.4, 0.85, 0.4, 1},
        text = {0.82, 0.9, 0.82, 1},
        subtext = {0.5, 0.65, 0.5, 1},
        success = {0.3, 0.9, 0.4, 1},
        warning = {0.9, 0.75, 0.3, 1},
        danger = {0.9, 0.35, 0.3, 1},
        dimBg = {0, 0.02, 0, 0.65},
    },
    crimson_royal = {
        label = "Škrlatno kraljevski",
        labelEn = "Crimson Royal",
        icon = "🔴",
        bg = {0.1, 0.05, 0.06, 0.98},
        border = {0.7, 0.3, 0.35, 1},
        title = {0.95, 0.6, 0.55, 1},
        accent = {0.9, 0.35, 0.4, 1},
        text = {0.92, 0.85, 0.85, 1},
        subtext = {0.6, 0.5, 0.5, 1},
        success = {0.3, 0.8, 0.4, 1},
        warning = {0.95, 0.75, 0.3, 1},
        danger = {0.95, 0.3, 0.25, 1},
        dimBg = {0.02, 0, 0, 0.65},
    },
    pure_dark = {
        label = "Čisto temen",
        labelEn = "Pure Dark",
        icon = "⚫",
        bg = {0.05, 0.05, 0.05, 0.98},
        border = {0.4, 0.4, 0.4, 1},
        title = {0.85, 0.85, 0.85, 1},
        accent = {0.7, 0.7, 0.7, 1},
        text = {0.8, 0.8, 0.8, 1},
        subtext = {0.5, 0.5, 0.5, 1},
        success = {0.4, 0.8, 0.4, 1},
        warning = {0.8, 0.7, 0.3, 1},
        danger = {0.8, 0.3, 0.3, 1},
        dimBg = {0, 0, 0, 0.65},
    },
    royal_purple = {
        label = "Kraljevski vijoličen",
        labelEn = "Royal Purple",
        icon = "🟣",
        bg = {0.08, 0.05, 0.1, 0.98},
        border = {0.5, 0.3, 0.7, 1},
        title = {0.7, 0.55, 0.9, 1},
        accent = {0.65, 0.4, 0.85, 1},
        text = {0.85, 0.82, 0.92, 1},
        subtext = {0.5, 0.45, 0.65, 1},
        success = {0.3, 0.8, 0.5, 1},
        warning = {0.9, 0.7, 0.3, 1},
        danger = {0.9, 0.3, 0.4, 1},
        dimBg = {0.02, 0, 0.03, 0.65},
    },
}

local THEME_ORDER = {"royal_gold", "midnight_blue", "forest_green", "crimson_royal", "pure_dark", "royal_purple"}

ColorTheme.THEMES = THEMES
ColorTheme.THEME_ORDER = THEME_ORDER

-- Load persisted theme
local function loadPersistedTheme()
    local ok, content = pcall(love.filesystem.read, THEME_FILE)
    if ok and content then
        content = content:gsub("%s+$", "")
        if THEMES[content] then
            currentThemeKey = content
            return true
        end
    end
    return false
end

function ColorTheme.init()
    if initialized then return end
    initialized = true
    loadPersistedTheme()
    print("[ColorTheme] Initialized — theme: " .. currentThemeKey)
end

function ColorTheme.set(key)
    if not THEMES[key] then return false end
    local previous = currentThemeKey
    currentThemeKey = key
    pcall(love.filesystem.write, THEME_FILE, key .. "\n")
    -- Notification
    if _G.NotificationCenter then
        local theme = THEMES[key]
        pcall(function()
            _G.NotificationCenter.show(
                theme.icon .. " Tema: " .. theme.label,
                "system", _G.NotificationCenter.PRIORITY.LOW, 3
            )
        end)
    end
    -- Sound
    if _G.UISoundHelper then
        pcall(function() _G.UISoundHelper.playToggleOn() end)
    end
    print("[ColorTheme] Theme changed: " .. previous .. " -> " .. key)
    return true
end

function ColorTheme.getCurrent()
    return currentThemeKey
end

function ColorTheme.getCurrentTheme()
    return THEMES[currentThemeKey]
end

function ColorTheme.cycle()
    for i, key in ipairs(THEME_ORDER) do
        if key == currentThemeKey then
            local nextKey = THEME_ORDER[(i % #THEME_ORDER) + 1]
            ColorTheme.set(nextKey)
            return nextKey
        end
    end
    return currentThemeKey
end

-- Get a specific color from current theme
function ColorTheme.getColor(colorName)
    local theme = THEMES[currentThemeKey]
    if not theme then return {1, 1, 1, 1} end
    return theme[colorName] or {1, 1, 1, 1}
end

-- Get all themes info (for UI)
function ColorTheme.getAll()
    local result = {}
    for _, key in ipairs(THEME_ORDER) do
        local theme = THEMES[key]
        result[#result + 1] = {
            key = key,
            label = theme.label,
            labelEn = theme.labelEn,
            icon = theme.icon,
            isCurrent = key == currentThemeKey,
        }
    end
    return result
end

function ColorTheme.getStats()
    return {
        current = currentThemeKey,
        totalThemes = #THEME_ORDER,
    }
end

return ColorTheme
