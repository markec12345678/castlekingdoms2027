-- states/ui/hud/keybind_help.lua
-- Castle Kingdoms 2027 - Keyboard Shortcuts Help Screen
--
-- Shows all keyboard shortcuts in an organized panel.
-- Toggle with 'H' key.

local KeybindHelp = {}

local PanelAnim = require("states.ui.hud.PanelAnimations")
local UISound = require("objects.Audio.UISoundHelper")

local visible = false
local scrollOffset = 0  -- scroll position (0 = top)
local contentHeight = 0  -- calculated during draw
local hoveredBinding = nil  -- { key, desc, category, y } set during mousemoved
local rowPositions = {}  -- populated during draw for hit-testing
local searchActive = false  -- when true, typing filters keybinds
local searchQuery = ""  -- current search text

-- v3.12.126: Panel animation state (fade-in/out + slide-down)
local animState = PanelAnim.createState({
    duration = 0.18,
    slideDir = "down",
    slideDist = 18,
    easing = "easeOut",
})

local SEARCH_FILE = "keybind_help_search.txt"

-- Load persisted search query on init
local function loadSearchQuery()
    local ok, content = pcall(love.filesystem.read, SEARCH_FILE)
    if ok and content then
        content = content:gsub("%s+$", "")  -- trim trailing whitespace/newline
        if content ~= "" then
            searchQuery = content
        end
    end
end

-- Save search query to file
local function saveSearchQuery()
    pcall(love.filesystem.write, SEARCH_FILE, searchQuery .. "\n")
end

-- Load on init
loadSearchQuery()

-- All keybinds organized by category
local KEYBINDS = {
    {
        category = "OSNOVNO",
        bindings = {
            { key = "ESC",       desc = "Pavza / Zapri meni" },
            { key = "F1",        desc = "Pokaži/skrij pomoč (to okno)" },
            { key = "F2",        desc = "Toggle UI zvokovne efekta (v3.12.130)" },
            { key = "Space",     desc = "Pavza / nadaljuj igro (v3.12.139)" },
            { key = "1/2/3/4",    desc = "Hitrost igre: 1x/2x/3x/5x (v3.12.139)" },
            { key = "H",         desc = "Center view to keep (original keybind)" },
            { key = "H (hold)",  desc = "Pomoč overlay - kontekstualni nasveti + tips (v3.12.143)" },
            { key = "V",         desc = "Nastavitve (game feel) | V v Ctrl+K: zgodovina dogodkov" },
            { key = "N",         desc = "Toast zgodovina - pokaži vsa pretekla obvestila (v3.12.127)" },
            { key = "Ctrl+Shift+A", desc = "Dosežki - modern achievement panel z animacijami (v3.12.128)" },
            { key = "Ctrl+Shift+I", desc = "Statistika - pregled, proizvodnja, trg, lestvice z grafi (v3.12.129)" },
            { key = "Ctrl+Shift+O", desc = "Tutorial manager - vsi hinti z reset/toggle funkcijami (v3.12.132)" },
            { key = "Ctrl+Shift+F", desc = "Težavnost - 5 stopnj (peaceful/easy/normal/hard/brutal) z modifierji (v3.12.133)" },
            { key = "Ctrl+Shift+K", desc = "Urejevalnik tipk - customizacija bližnjic z persistenco (v3.12.144)" },
            { key = "Ctrl+Shift+E", desc = "Nastavitve - vse na enem mestu (igra/UI/prikaz/igralec) (v3.12.145)" },
            { key = "Ctrl+A",    desc = "Dosežki - stari loveframes achievement gallery" },
            { key = "` + Shift", desc = "Odpri konzolo" },
            { key = "Shift+R",   desc = "Ponastavi vse nastavitve (zbriše 16 persisted datotek, zahteva restart)" },
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
            { key = "2x Click",  desc = "Dvaklik na produkt: odpri Royal Systems Panel na sistemu ki ga proizvaja" },
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
            { key = "Shift+Click", desc = "Dodaj/odstrani vozlišče iz multi-izbire (primerjaj več sistemov)" },
            { key = "C",        desc = "Počisti multi-izbiro in fokus" },
            { key = "2x Click", desc = "Dvaklik na vozlišče: odpri Royal Systems Panel (Ctrl+R) in skoči na sistem" },
            { key = "T",        desc = "Preklopi pot: direktno (1 stopnja) ↔ celotna pot (transitivno)" },
            { key = "M",        desc = "Skrij/prikaži minimap (pregledni graf v kotu, click za skok)" },
            { key = "D",        desc = "Skrij/prikaži indikator globine (barvni krožec z številko plasti)" },
            { key = "A",        desc = "Skrij/prikaži puščice smeri na povezavah (base → dependent)" },
            { key = "S",        desc = "Preklopi sortiranje verig: abecedno ↔ po globini (plitev→globok)" },
            { key = "L",        desc = "Ciklaj filter stanja: vsi → aktivni → razpoložljivi → zaklenjeni" },
            { key = "Tab",      desc = "Naslednje vozlišče (keyboard navigacija, auto-scroll + fokus)" },
            { key = "Shift+Tab", desc = "Prejšnje vozlišče (keyboard navigacija nazaj)" },
            { key = "B",        desc = "Dodaj/odstrani zaznamek (★) na hovered/selected vozlišču" },
            { key = "Shift+B",  desc = "Preklopi filter: prikaži samo zaznamovana vozlišča" },
            { key = "E",        desc = "Izvozi konfiguracijo (filtri, sort, focus, bookmarks) v odložišče" },
            { key = "Shift+E",  desc = "Uvozi konfiguracijo iz odložišča" },
            { key = "P",        desc = "Ciklaj preset (Vsi → Aktivni → Razpoložljivi → Zaklenjeni → Zaznamovani → Custom...)" },
            { key = "Shift+P",  desc = "Shrani trenutno konfiguracijo kot custom preset (persisted)" },
            { key = "Shift+X",  desc = "Izbriši trenutno izbran custom preset (built-in ni mogoče brisati)" },
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
    if not visible then
        visible = true
        PanelAnim.open(animState)
        UISound.playPanelOpen()
    else
        PanelAnim.close(animState)
        UISound.playPanelClose()
        -- visible stays true until close animation completes
    end
    scrollOffset = 0  -- reset scroll on toggle
    searchActive = false
    searchQuery = ""
    hoveredBinding = nil
end

function KeybindHelp.setVisible(state)
    if state and not visible then
        visible = true
        PanelAnim.open(animState)
    elseif not state and visible then
        PanelAnim.close(animState)
    end
end

function KeybindHelp.isVisible()
    -- During close animation, visible flag is still true but we want input routing
    -- to continue until close finishes (so ESC key during close is processed here)
    return visible or PanelAnim.isAnimating(animState)
end

-- v3.12.126: Update animation state
function KeybindHelp.update(dt)
    if not visible and not PanelAnim.isAnimating(animState) then return end
    PanelAnim.update(animState, dt)
    -- Auto-clear visibility once close animation completes
    if animState.phase == "closed" then
        visible = false
    end
end

function KeybindHelp.draw()
    if not visible and not PanelAnim.isAnimating(animState) then return end

    -- v3.12.126: Apply panel animation (alpha + slide offset)
    local alpha = PanelAnim.getProgress(animState)
    local offsetX, offsetY = PanelAnim.getOffset(animState)

    local screenW, screenH = love.graphics.getDimensions()
    local panelW = 560
    local panelH = math.min(760, screenH - 40)
    local panelX = (screenW - panelW) / 2
    local panelY = (screenH - panelH) / 2

    -- Dim background (fades in/out)
    love.graphics.setColor(0, 0, 0, 0.6 * alpha)
    love.graphics.rectangle("fill", 0, 0, screenW, screenH)

    -- Panel (with slide offset)
    love.graphics.push("all")
    love.graphics.translate(offsetX, offsetY)

    love.graphics.setColor(0.1, 0.08, 0.06, 0.97 * alpha)
    love.graphics.rectangle("fill", panelX, panelY, panelW, panelH, 8, 8, 8, 8)

    -- Border
    love.graphics.setColor(0.6, 0.5, 0.3, alpha)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", panelX, panelY, panelW, panelH, 8, 8, 8, 8)

    -- Title (fixed, not scrolled)
    love.graphics.setColor(1, 0.9, 0.7, 1)
    love.graphics.print("Tipkovne bližnjice", panelX + 20, panelY + 15)

    -- Separator
    love.graphics.setColor(0.6, 0.5, 0.3, 0.5)
    love.graphics.setLineWidth(1)
    love.graphics.line(panelX + 20, panelY + 40, panelX + panelW - 20, panelY + 40)

    -- Search bar (fixed, not scrolled)
    love.graphics.setColor(0.5, 0.5, 0.5, 1)
    love.graphics.print("Iskanje:", panelX + 20, panelY + 48)
    love.graphics.setColor(0.15, 0.12, 0.08, 1)
    love.graphics.rectangle("fill", panelX + 90, panelY + 46, 300, 20, 3, 3, 3, 3)
    if searchActive then
        love.graphics.setColor(0.9, 0.8, 0.4, 1)
        love.graphics.rectangle("line", panelX + 90, panelY + 46, 300, 20, 3, 3, 3, 3)
    end
    love.graphics.setColor(0.9, 0.9, 0.9, 1)
    local searchDisplay = searchQuery
    if searchActive then searchDisplay = searchDisplay .. "_" end
    love.graphics.print(searchDisplay, panelX + 96, panelY + 49)
    -- Search hint
    if not searchActive and searchQuery == "" then
        love.graphics.setColor(0.4, 0.4, 0.4, 1)
        love.graphics.print("(pritisni / za iskanje)", panelX + 96, panelY + 49)
    end

    -- Content area dimensions (adjusted for search bar)
    local contentTop = panelY + 72
    local contentBottom = panelY + panelH - 35
    local contentAreaH = contentBottom - contentTop
    local x = panelX + 25

    -- Build filtered list based on search query
    local query = searchQuery:lower()
    local filteredSections = {}
    for _, section in ipairs(KEYBINDS) do
        if query == "" then
            filteredSections[#filteredSections + 1] = section
        else
            local filteredBindings = {}
            for _, binding in ipairs(section.bindings) do
                if binding.key:lower():find(query, 1, true) or binding.desc:lower():find(query, 1, true) then
                    filteredBindings[#filteredBindings + 1] = binding
                end
            end
            if #filteredBindings > 0 then
                filteredSections[#filteredSections + 1] = {
                    category = section.category,
                    bindings = filteredBindings,
                }
            end
        end
    end

    -- Results count
    local totalResults = 0
    for _, s in ipairs(filteredSections) do
        totalResults = totalResults + #s.bindings
    end
    if query ~= "" then
        love.graphics.setColor(0.6, 0.7, 0.5, 1)
        love.graphics.print(string.format("Rezultati: %d", totalResults), panelX + 400, panelY + 49)
    end

    -- Calculate total content height (based on filtered sections)
    contentHeight = 0
    for _, section in ipairs(filteredSections) do
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
    rowPositions = {}  -- reset for this frame
    for _, section in ipairs(filteredSections) do
        -- Category header
        love.graphics.setColor(0.7, 0.6, 0.4, 1)
        love.graphics.print(section.category, x, y)
        y = y + 22

        -- Bindings
        for _, binding in ipairs(section.bindings) do
            -- Record row position for hover hit-testing
            rowPositions[#rowPositions + 1] = {
                x = x, y = y, w = panelW - 50, h = 20,
                key = binding.key, desc = binding.desc, category = section.category,
            }

            -- Key (highlighted)
            local isHovered = hoveredBinding and hoveredBinding.key == binding.key
                           and hoveredBinding.category == section.category
            local isClickable = isClickablePanel(binding.key)
            if isHovered then
                love.graphics.setColor(0.25, 0.2, 0.1, 0.8)
                love.graphics.rectangle("fill", x, y, panelW - 50, 20, 2, 2, 2, 2)
                if isClickable then
                    love.graphics.setColor(0.5, 1, 0.5, 1)  -- green for clickable
                else
                    love.graphics.setColor(1, 1, 0.5, 1)  -- yellow for normal hover
                end
            else
                love.graphics.setColor(1, 0.85, 0.3, 1)
            end
            love.graphics.print(binding.key, x + 15, y)

            -- Description
            love.graphics.setColor(isHovered and 1 or 0.8, isHovered and 1 or 0.8, isHovered and 1 or 0.8, 1)
            love.graphics.print(binding.desc, x + 130, y)

            -- Click-to-open hint for panel shortcuts
            if isHovered and isClickable then
                love.graphics.setColor(0.4, 0.9, 0.4, 0.8)
                love.graphics.print("→ klik", x + panelW - 80, y)
            end

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
    local hintText = "[H] Zapri pomoč  |  /: iskanje  |  Hover: podrobnosti  |  Shift+R: Reset nastavitev"
    if contentHeight > contentAreaH then
        hintText = hintText .. "  |  ↑↓/wheel: scroll"
    end
    love.graphics.print(hintText, panelX + panelW - 200, panelY + panelH - 25)

    -- Hover tooltip (drawn after scissor reset, so it's not clipped)
    if hoveredBinding then
        local mx, my = love.mouse.getPosition()
        local ttW = 340
        local ttH = 80
        local ttX = mx + 16
        local ttY = my + 16
        -- Keep tooltip on screen
        if ttX + ttW > screenW then ttX = mx - ttW - 16 end
        if ttY + ttH > screenH then ttY = my - ttH - 16 end

        -- Tooltip background
        love.graphics.setColor(0.08, 0.06, 0.04, 0.97)
        love.graphics.rectangle("fill", ttX, ttY, ttW, ttH, 6, 6, 6, 6)
        love.graphics.setColor(0.6, 0.5, 0.3, 0.8)
        love.graphics.setLineWidth(1)
        love.graphics.rectangle("line", ttX, ttY, ttW, ttH, 6, 6, 6, 6)

        -- Category badge
        love.graphics.setColor(0.5, 0.6, 0.4, 1)
        love.graphics.print("[" .. hoveredBinding.category .. "]", ttX + 10, ttY + 6)

        -- Key (large, highlighted)
        love.graphics.setColor(1, 0.85, 0.3, 1)
        love.graphics.print(hoveredBinding.key, ttX + 10, ttY + 26)

        -- Description (wrapped if needed)
        love.graphics.setColor(0.85, 0.85, 0.85, 1)
        local desc = hoveredBinding.desc or ""
        -- Simple word wrap
        local maxW = ttW - 20
        local font = love.graphics.getFont()
        local words = {}
        for w in desc:gmatch("%S+") do words[#words + 1] = w end
        local line = ""
        local lineY = ttY + 46
        for _, w in ipairs(words) do
            local test = line == "" and w or (line .. " " .. w)
            if font:getWidth(test) > maxW then
                if line ~= "" then
                    love.graphics.print(line, ttX + 10, lineY)
                    lineY = lineY + 14
                end
                line = w
            else
                line = test
            end
        end
        if line ~= "" then
            love.graphics.print(line, ttX + 10, lineY)
        end

        -- Click-to-open hint for panel shortcuts
        if isClickablePanel(hoveredBinding.key) then
            love.graphics.setColor(0.4, 0.9, 0.4, 1)
            love.graphics.print("→ Klik za odprtje panela", ttX + 10, ttY + ttH - 16)
        end
    end

    -- v3.12.126: Close the slide-offset transform
    love.graphics.pop()

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

function KeybindHelp.keypressed(key, scancode, isrepeat)
    if not visible then return false end

    -- Search mode: handle text input keys
    if searchActive then
        if key == "escape" then
            searchActive = false
            searchQuery = ""
            saveSearchQuery()
            scrollOffset = 0
            return true
        end
        if key == "return" then
            searchActive = false  -- exit search mode but keep query
            saveSearchQuery()
            return true
        end
        if key == "backspace" then
            searchQuery = searchQuery:sub(1, -2)
            saveSearchQuery()
            scrollOffset = 0
            return true
        end
        -- Don't process other keys in search mode
        return true
    end

    -- Normal mode
    if key == "h" then
        KeybindHelp.toggle()
        return true
    end
    -- Shift+R: Reset all persisted UI settings
    if key == "r" and (love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")) then
        local PERSISTED_FILES = {
            "royal_systems_sort.txt",
            "royal_systems_category.txt",
            "royal_systems_search.txt",
            "market_dashboard_search.txt",
            "market_dashboard_sort.txt",
            "market_dashboard_leaderboard.txt",
            "market_dashboard_comparison.txt",
            "market_dashboard_eventlog.txt",
            "market_dashboard_eventfilter.txt",
            "tech_tree_search.txt",
            "tech_tree_config.txt",
            "tech_tree_bookmarks.txt",
            "tech_tree_multiselect.txt",
            "tech_tree_custom_presets.txt",
            "keybind_help_search.txt",
            "autosave_overlay_settings.txt",
        }
        local deleted = 0
        for _, f in ipairs(PERSISTED_FILES) do
            if love.filesystem.getInfo(f) then
                pcall(love.filesystem.remove, f)
                deleted = deleted + 1
            end
        end
        -- Reset local state
        searchQuery = ""
        searchActive = false
        scrollOffset = 0
        hoveredBinding = nil
        print(string.format("[KeybindHelp] Reset all settings: %d files deleted. Restart game to apply.", deleted))
        -- Close help panel to show it took effect
        KeybindHelp.toggle()
        return true
    end
    -- Activate search with /
    if key == "/" then
        searchActive = true
        searchQuery = ""
        scrollOffset = 0
        return true
    end
    -- Scroll keys (only when visible and not in search mode)
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
    return false
end

-- Map of keybind keys to panel module paths for click-to-open
local PANEL_SHORTCUTS = {
    ["Ctrl+R"]         = "states.ui.hud.royal_systems_panel",
    ["Ctrl+K"]          = "states.ui.hud.market_dashboard",
    ["Ctrl+U"]          = "states.ui.hud.autosave_panel",
    ["Ctrl+Shift+G"]    = "states.ui.hud.tech_tree_panel",
}

-- Check if a binding key is a panel shortcut (clickable)
local function isClickablePanel(key)
    return PANEL_SHORTCUTS[key] ~= nil
end

-- Open the panel referenced by a keybind key
local function openPanel(key)
    local modulePath = PANEL_SHORTCUTS[key]
    if not modulePath then return false end
    local ok, mod = pcall(require, modulePath)
    if ok and mod and mod.toggle then
        KeybindHelp.toggle()  -- close help first
        mod.toggle()
        return true
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
    -- Check if click is on a binding row (click-to-open panels)
    if button == 1 then  -- left click
        for _, row in ipairs(rowPositions) do
            if x >= row.x and x <= row.x + row.w and y >= row.y and y <= row.y + row.h then
                -- Check the row is within the visible content area
                local contentTop = panelY + 72
                local contentBottom = panelY + panelH - 35
                if y >= contentTop and y <= contentBottom then
                    if isClickablePanel(row.key) then
                        openPanel(row.key)
                        return true
                    end
                end
                break
            end
        end
    end
    return false
end

function KeybindHelp.mousemoved(x, y, dx, dy)
    if not visible then
        hoveredBinding = nil
        return false
    end
    -- Check if mouse is over any binding row
    hoveredBinding = nil
    for _, row in ipairs(rowPositions) do
        if x >= row.x and x <= row.x + row.w and y >= row.y and y <= row.y + row.h then
            -- Also check the row is within the visible content area
            local screenH = love.graphics.getHeight()
            local panelH = math.min(760, screenH - 40)
            local panelY = (screenH - panelH) / 2
            local contentTop = panelY + 50
            local contentBottom = panelY + panelH - 35
            if y >= contentTop and y <= contentBottom then
                hoveredBinding = { key = row.key, desc = row.desc, category = row.category }
            end
            break
        end
    end
    return false
end

function KeybindHelp.mousereleased(x, y, button)
    return false
end

function KeybindHelp.textinput(text)
    if not visible then return false end
    if searchActive then
        -- Only accept printable characters
        if text:match("^[%w _+/-]$") then
            searchQuery = searchQuery .. text
            saveSearchQuery()
            scrollOffset = 0
        end
        return true
    end
    return false
end

return KeybindHelp
