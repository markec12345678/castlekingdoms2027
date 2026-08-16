-- states/ui/hud/keybind_help.lua
-- Castle Kingdoms 2027 - Keyboard Shortcuts Help Screen
--
-- Shows all keyboard shortcuts in an organized panel.
-- Toggle with 'H' key.

local KeybindHelp = {}

local visible = false
local scrollOffset = 0  -- scroll position (0 = top)
local contentHeight = 0  -- calculated during draw

-- All keybinds organized by category
local KEYBINDS = {
    {
        category = "OSNOVNO",
        bindings = {
            { key = "ESC",       desc = "Pavza / Zapri meni" },
            { key = "H",         desc = "Pokaži/skrij pomoč (ta okno)" },
            { key = "V",         desc = "Nastavitve (game feel) | V v Ctrl+K: zgodovina dogodkov" },
            { key = "` + Shift", desc = "Odpri konzolo" },
        },
    },
    {
        category = "EKONOMIJA",
        bindings = {
            { key = "M",         desc = "Tržnica - dinamične cene 20 surovin" },
            { key = "C",         desc = "Karavane - pošiljanje trgovskih karavan" },
            { key = "Ctrl+R",    desc = "Kraljevi sistemski (987 Royal Maker sistemov + trg)" },
            { key = "Ctrl+K",    desc = "Kraljevi trg - nadzorna plošča (cene, prodaja, trendi)" },
            { key = "Ctrl+Shift+G", desc = "Tech tree - vizualni prikaz odvisnosti sistemov" },
            { key = "Ctrl+U",    desc = "Auto-save panel - status, interval, force save" },
            { key = "Shift+U",   desc = "Hitri vklop/izklop auto-save (brez panela)" },
            { key = "Ctrl+Shift+U", desc = "Skrij/prikaži auto-save overlay (brez izklopa)" },
            { key = "Click (overlay)", desc = "Klik na auto-save HUD odpre panel" },
            { key = "Drag (overlay)", desc = "Povleci auto-save HUD za premik pozicije (persisted)" },
        },
    },
    {
        category = "CTRL+R PANEL (Royal Systems)",
        bindings = {
            { key = "/ (slash)",   desc = "Iskanje sistemov po imenu" },
            { key = "← → / A D",   desc = "Prejšnja/naslednja stran" },
            { key = "↑ ↓ / W S",   desc = "Navigacija med sistemi" },
            { key = "Home / End",  desc = "Skok na prvo/zadnjo stran" },
            { key = "PgUp / PgDn", desc = "Hitra navigacija med stranimi" },
            { key = "Wheel",       desc = "Scroll med stranimi (miška)" },
            { key = "Tab",         desc = "Ciklaj kategorije (Steklar/Livar/Knigovez/...)" },
        },
    },
    {
        category = "CTRL+K PANEL (Market Dashboard)",
        bindings = {
            { key = "/ (slash)",    desc = "Iskanje produktov po imenu" },
            { key = "S",            desc = "Ciklaj sortiranje (abecedno/prodaja/cena/...)" },
            { key = "E",            desc = "Sproži test dogodek (crash/surge) na izbranem produktu" },
            { key = "Q",            desc = "Preklopi leaderboard (količina ↔ prihodek)" },
            { key = "Space",        desc = "Dodaj/odstrani produkt iz primerjave" },
            { key = "C",            desc = "Preklopi način primerjave (multi-product chart)" },
            { key = "Ctrl+X",       desc = "Počisti seznam primerjave" },
            { key = "V",            desc = "Razširi/zapri zgodovino dogodkov" },
            { key = "1-5",          desc = "Filter dogodkov (Vsi/Surge/Crash/Sezon/Manual)" },
            { key = "↑ ↓",          desc = "Scroll dogodkov (ko je expanded)" },
            { key = "PgUp / PgDn",  desc = "Hitri scroll dogodkov (10 vrstic)" },
            { key = "Home",         desc = "Skok na vrh dogodkov" },
            { key = "Wheel",        desc = "Scroll dogodkov ali sistemov (miška)" },
        },
    },
    {
        category = "CTRL+U PANEL (Auto-Save)",
        bindings = {
            { key = "Click",    desc = "Vklopi/Izklopi, Shrani zdaj, Interval presets, Reset pozicije" },
            { key = "Wheel",    desc = "Ciklaj interval (gor=krajši, dol= daljši: 1/5/15/30 min)" },
            { key = "ESC",      desc = "Zapri panel" },
            { key = "Ctrl+U",   desc = "Zapri panel (toggle)" },
        },
    },
    {
        category = "CTRL+SHIFT+G PANEL (Tech Tree)",
        bindings = {
            { key = "G",        desc = "Preklopi pogled: graf vozlišč ↔ tekstovno drevo" },
            { key = "/ (slash)", desc = "Odpri iskanje — tipkaj za filtriranje po imenu" },
            { key = "Enter",    desc = "Potrdi iskanje (filter ostane aktiven)" },
            { key = "Backspace", desc = "Briši zadnji znak iskanja" },
            { key = "Click",    desc = "Klik na vozlišče: fokusira sorodne (poudari, druga zatemni)" },
            { key = "2x Click", desc = "Dvaklik na vozlišče: odpri Royal Systems Panel (Ctrl+R) in skoči na sistem" },
            { key = "T",        desc = "Preklopi pot: direktno (1 stopnja) ↔ celotna pot (transitivno)" },
            { key = "M",        desc = "Skrij/prikaži minimap (pregledni graf v kotu, click za skok)" },
            { key = "D",        desc = "Skrij/prikaži indikator globine (barvni krožec z številko plasti)" },
            { key = "A",        desc = "Skrij/prikaži puščice smeri na povezavah (base → dependent)" },
            { key = "S",        desc = "Preklopi sortiranje verig: abecedno ↔ po globini (plitev→globok)" },
            { key = "L",        desc = "Ciklaj filter stanja: vsi → aktivni → razpoložljivi → zaklenjeni" },
            { key = "F",        desc = "Počisti fokus (ali klik ponovno na isto vozlišče)" },
            { key = "Hover",    desc = "V graf pogledu: prikaži podrobnosti odvisnosti + število odvisnikov" },
            { key = "↑ ↓",      desc = "Scroll po verigah" },
            { key = "PgUp / PgDn", desc = "Hitri scroll (150px)" },
            { key = "Home",     desc = "Skok na vrh" },
            { key = "Wheel",    desc = "Scroll (miška)" },
            { key = "ESC",      desc = "Počisti iskanje → fokus → zapri panel (zaporedno)" },
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
    scrollOffset = 0  -- reset scroll on toggle
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
    local panelW = 560
    local panelH = math.min(760, screenH - 40)
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

    -- Title (fixed, not scrolled)
    love.graphics.setColor(1, 0.9, 0.7, 1)
    love.graphics.print("Tipkovne bližnjice", panelX + 20, panelY + 15)

    -- Separator
    love.graphics.setColor(0.6, 0.5, 0.3, 0.5)
    love.graphics.setLineWidth(1)
    love.graphics.line(panelX + 20, panelY + 40, panelX + panelW - 20, panelY + 40)

    -- Content area dimensions
    local contentTop = panelY + 50
    local contentBottom = panelY + panelH - 35
    local contentAreaH = contentBottom - contentTop
    local x = panelX + 25

    -- Calculate total content height
    contentHeight = 0
    for _, section in ipairs(KEYBINDS) do
        contentHeight = contentHeight + 22  -- category header
        contentHeight = contentHeight + #section.bindings * 20  -- entries
        contentHeight = contentHeight + 8  -- gap
    end

    -- Clamp scroll offset
    local maxScroll = math.max(0, contentHeight - contentAreaH)
    if scrollOffset > maxScroll then scrollOffset = maxScroll end
    if scrollOffset < 0 then scrollOffset = 0 end

    -- Scissor clip to content area
    love.graphics.setScissor(panelX + 4, contentTop, panelW - 8, contentAreaH)

    -- Draw content with scroll offset
    local y = contentTop - scrollOffset
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

    -- Reset scissor
    love.graphics.setScissor()

    -- Scrollbar (right side of content area) if content overflows
    if contentHeight > contentAreaH then
        local sbX = panelX + panelW - 14
        local sbY = contentTop
        local sbW = 6
        local sbH = contentAreaH
        -- Track
        love.graphics.setColor(0.05, 0.04, 0.03, 1)
        love.graphics.rectangle("fill", sbX, sbY, sbW, sbH, 2, 2, 2, 2)
        -- Thumb
        local thumbH = math.max(20, (contentAreaH / contentHeight) * sbH)
        local thumbY = sbY + (scrollOffset / maxScroll) * (sbH - thumbH)
        love.graphics.setColor(0.55, 0.45, 0.25, 0.9)
        love.graphics.rectangle("fill", sbX + 1, thumbY, sbW - 2, thumbH, 2, 2, 2, 2)
    end

    -- Close hint (fixed, not scrolled)
    love.graphics.setColor(0.5, 0.5, 0.5, 1)
    local hintText = "[H] Zapri pomoč"
    if contentHeight > contentAreaH then
        hintText = hintText .. "  |  ↑↓/wheel: scroll"
    end
    love.graphics.print(hintText, panelX + panelW - 200, panelY + panelH - 25)

    love.graphics.setColor(1, 1, 1, 1)
end

-- Mouse wheel handler for scrolling
function KeybindHelp.wheelmoved(x, y)
    if not visible then return false end
    if y > 0 then
        scrollOffset = math.max(0, scrollOffset - 40)
        return true
    elseif y < 0 then
        scrollOffset = scrollOffset + 40  -- clamped in draw
        return true
    end
    return false
end

function KeybindHelp.keypressed(key)
    if key == "h" then
        KeybindHelp.toggle()
        return true
    end
    -- Scroll keys (only when visible)
    if visible then
        if key == "up" then
            scrollOffset = math.max(0, scrollOffset - 40)
            return true
        end
        if key == "down" then
            scrollOffset = scrollOffset + 40  -- clamped in draw
            return true
        end
        if key == "pageup" then
            scrollOffset = math.max(0, scrollOffset - 200)
            return true
        end
        if key == "pagedown" then
            scrollOffset = scrollOffset + 200  -- clamped in draw
            return true
        end
        if key == "home" then
            scrollOffset = 0
            return true
        end
        if key == "end" then
            -- Scroll to bottom (will be clamped in draw)
            scrollOffset = 99999
            return true
        end
    end
    return false
end

-- Castle Kingdoms 2027 v3.11.941: Mouse stubs for 100% consistency
function KeybindHelp.mousepressed(x, y, button)
    if not visible then return false end
    -- Click outside panel closes
    local screenW, screenH = love.graphics.getDimensions()
    local panelW = 560
    local panelH = math.min(760, screenH - 40)
    local panelX = (screenW - panelW) / 2
    local panelY = (screenH - panelH) / 2
    if x < panelX or x > panelX + panelW or y < panelY or y > panelY + panelH then
        KeybindHelp.toggle()
        return true
    end
    return false
end

function KeybindHelp.mousemoved(x, y, dx, dy)
    return false
end

function KeybindHelp.mousereleased(x, y, button)
    return false
end

return KeybindHelp
