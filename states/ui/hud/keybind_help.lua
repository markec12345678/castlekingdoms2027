-- states/ui/hud/keybind_help.lua
-- Castle Kingdoms 2027 - Keyboard Shortcuts Help Screen
--
-- Shows all keyboard shortcuts in an organized panel.
-- Toggle with 'H' key.

local KeybindHelp = {}

local visible = false

-- All keybinds organized by category
local KEYBINDS = {
    {
        category = "OSNOVNO",
        bindings = {
            { key = "ESC",       desc = "Pavza / Zapri meni" },
            { key = "H",         desc = "Pokaži/skrij pomoč (ta okno)" },
            { key = "V",         desc = "Nastavitve (game feel, audio, grafika)" },
            { key = "` + Shift", desc = "Odpri konzolo" },
        },
    },
    {
        category = "EKONOMIJA",
        bindings = {
            { key = "M",         desc = "Tržnica - dinamične cene 20 surovin" },
            { key = "C",         desc = "Karavane - pošiljanje trgovskih karavan" },
        },
    },
    {
        category = "BOJ",
        bindings = {
            { key = "Levi klik",      desc = "Izberi enoto (klik) ali skupino (drag)" },
            { key = "Desni klik",     desc = "Premakni enoto ali napadi sovražnika" },
            { key = "F8",             desc = "Combat test scenarij (spawn enote)" },
            { key = "F9",             desc = "Combat statistike v konzolo" },
        },
    },
    {
        category = "AI",
        bindings = {
            { key = "F7",  desc = "Spawn AI nasprotnik (random osebnost/težavnost)" },
            { key = "F10", desc = "AI debug info v konzolo" },
        },
    },
    {
        category = "VREME & ČAS",
        bindings = {
            { key = "F5", desc = "Spremeni vreme (clear → rain → snow → storm)" },
            { key = "F6", desc = "Spremeni čas dneva (dawn → day → dusk → night)" },
        },
    },
    {
        category = "PERFORMANCE",
        bindings = {
            { key = "F3",  desc = "Performance overlay (FPS, timing breakdown)" },
            { key = "F11", desc = "Economy debug info v konzolo" },
        },
    },
    {
        category = "KAMPANJA",
        bindings = {
            { key = "F12", desc = "Naloži kampanjsko misijo 1" },
        },
    },
    {
        category = "HITRE TIPKE",
        bindings = {
            { key = "S",     desc = "Screenshot" },
            { key = "+",     desc = "Pospeši igro" },
            { key = "-",     desc = "Upočasni igro" },
            { key = "Space", desc = "Pavza" },
        },
    },
}

function KeybindHelp.toggle()
    visible = not visible
end

function KeybindHelp.setVisible(state)
    visible = state
end

function KeybindHelp.isVisible()
    return visible
end

function KeybindHelp.draw()
    if not visible then return end

    local screenW, screenH = love.graphics.getDimensions()
    local panelW = 520
    local panelH = 580
    local panelX = (screenW - panelW) / 2
    local panelY = (screenH - panelH) / 2

    -- Dim background
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", 0, 0, screenW, screenH)

    -- Panel
    love.graphics.setColor(0.1, 0.08, 0.06, 0.97)
    love.graphics.rectangle("fill", panelX, panelY, panelW, panelH, 8, 8, 8, 8)

    -- Border
    love.graphics.setColor(0.6, 0.5, 0.3, 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", panelX, panelY, panelW, panelH, 8, 8, 8, 8)

    -- Title
    love.graphics.setColor(1, 0.9, 0.7, 1)
    love.graphics.print("Tipkovne bližnjice", panelX + 20, panelY + 15)

    -- Separator
    love.graphics.setColor(0.6, 0.5, 0.3, 0.5)
    love.graphics.setLineWidth(1)
    love.graphics.line(panelX + 20, panelY + 40, panelX + panelW - 20, panelY + 40)

    local y = panelY + 55
    local x = panelX + 25

    for _, section in ipairs(KEYBINDS) do
        -- Category header
        love.graphics.setColor(0.7, 0.6, 0.4, 1)
        love.graphics.print(section.category, x, y)
        y = y + 22

        -- Bindings
        for _, binding in ipairs(section.bindings) do
            -- Key (highlighted)
            love.graphics.setColor(1, 0.85, 0.3, 1)
            love.graphics.print(binding.key, x + 15, y)

            -- Description
            love.graphics.setColor(0.8, 0.8, 0.8, 1)
            love.graphics.print(binding.desc, x + 130, y)

            y = y + 20
        end

        y = y + 8
    end

    -- Close hint
    love.graphics.setColor(0.5, 0.5, 0.5, 1)
    love.graphics.print("[H] Zapri pomoč", panelX + panelW - 120, panelY + panelH - 25)

    love.graphics.setColor(1, 1, 1, 1)
end

function KeybindHelp.keypressed(key)
    if key == "h" then
        KeybindHelp.toggle()
        return true
    end
    return false
end

return KeybindHelp
