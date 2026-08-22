-- objects/Feedback/TutorialHints.lua
-- Castle Kingdoms 2027 - Contextual Tutorial Hints
--
-- Shows helpful tips to new players based on game state:
-- - First time placing a building
-- - First time recruiting a unit
-- - First time combat
-- - Low food warning
-- - Low gold warning
-- - Enemy approaching
--
-- Hints are shown once per session (tracked in localStorage-like state).

local TutorialHints = {}

local enabled = true
local hintsShown = {}  -- track which hints have been shown
local activeHint = nil
local hintTimer = 0
local hintDuration = 8.0  -- seconds

-- v3.12.132: Persistence file
local SHOWN_FILE = "tutorial_hints_shown.txt"
local ENABLED_FILE = "tutorial_enabled.txt"

-- v3.12.132: Load persisted state on require
local function loadPersistedState()
    -- Load shown hints
    local ok, content = pcall(love.filesystem.read, SHOWN_FILE)
    if ok and content then
        for line in content:gmatch("[^\n]+") do
            local key = line:gsub("^%s+", ""):gsub("%s+$", "")
            if key ~= "" then
                hintsShown[key] = true
            end
        end
    end
    -- Load enabled state
    local ok2, content2 = pcall(love.filesystem.read, ENABLED_FILE)
    if ok2 and content2 then
        content2 = content2:gsub("%s+$", "")
        if content2 == "false" then enabled = false end
    end
end
loadPersistedState()

-- Hint definitions
local HINTS = {
    first_game_start = {
        text = "Dobrodošli v Castle Kingdoms 2027! Pritisni F12 za kampanjsko misijo.",
        priority = 1,
    },
    first_build = {
        text = "Klikni na zgradbo v gradbenem meniju spodaj, nato klikni na tla za postavitev.",
        priority = 2,
    },
    first_unit_recruit = {
        text = "Zgradite vojašnico za rekrutiranje vojaških enot!",
        priority = 3,
    },
    first_combat = {
        text = "Levi klik za izbiro enot, desni klik na sovražnika za napad!",
        priority = 4,
    },
    first_market = {
        text = "Pritisni M za odprtje tržnice z dinamičnimi cenami.",
        priority = 5,
    },
    first_caravan = {
        text = "Pritisni C za pošiljanje trgovskih karavan k AI frakcijam!",
        priority = 6,
    },
    first_settings = {
        text = "Pritisni V za nastavitve grafike, zvoka in game feel efektov.",
        priority = 7,
    },
    low_food = {
        text = "Opozorilo: Nizke zaloge hrane! Zgradi kmetijo ali sadovnjak.",
        priority = 10,
    },
    low_gold = {
        text = "Opozorilo: Nizko zlato! Postavi davke ali trguj na tržnici.",
        priority = 10,
    },
    enemy_approaching = {
        text = "Sovražnik se približuje! Pripravi obrambo!",
        priority = 20,
    },
    ai_spawned = {
        text = "AI nasprotnik ustvarjen! Pritisni F10 za AI debug info.",
        priority = 8,
    },
    weather_tip = {
        text = "Pritisni F5 za spreminjanje vremena. Letni časi vplivajo na proizvodnjo!",
        priority = 9,
    },
    -- Castle Kingdoms 2027 v2.5.7: 5 new tutorial hints
    veterancy_tip = {
        text = "Tvoje enote pridobivajo XP iz bojev! 5 stopenj veterancy z bonusi.",
        priority = 11,
    },
    formation_tip = {
        text = "Ctrl+G za preklop formacije! Line, column, wedge, scatter, box.",
        priority = 12,
    },
    festival_tip = {
        text = "Ctrl+F za zagon turnirja! Festivali povečujejo popularnost.",
        priority = 13,
    },
    diplomacy_tip = {
        text = "F9 za diplomacijo! Sklepaj zavezništva ali napoveduj vojno.",
        priority = 14,
    },
    siege_tip = {
        text = "Ctrl+B za ustvarjanje katapulta! Oblegovalna orožja uničujejo zgradbe.",
        priority = 15,
    },

    -- v3.12.132: New hints for modern UI panels (added when they were created)
    royal_systems_panel = {
        text = "Ctrl+R odpre Kraljeve sisteme — 990 proizvodnih sistemov z iskanjem, kategorijami in sortiranjem!",
        priority = 20,
    },
    market_dashboard = {
        text = "Ctrl+K odpre Nadzorno ploščo trga — cene, prodaja, trendi, dogodki!",
        priority = 21,
    },
    autosave_panel = {
        text = "Ctrl+U odpre Auto-Save panel — status, interval, force save, nastavitve!",
        priority = 22,
    },
    tech_tree_panel = {
        text = "Ctrl+Shift+G odpre Tech Tree graf — 891 odvisnosti v 165 verigah z barvno kodiranjem!",
        priority = 23,
    },
    keybind_help = {
        text = "F1 odpre Tipkovne bližnjice — vse tipke organizirane po kategorijah z iskanjem!",
        priority = 24,
    },
    toast_history = {
        text = "N odpre Zgodovino obvestil — vsa pretekla obvestila z iskanjem in filtri!",
        priority = 25,
    },
    achievement_panel = {
        text = "Ctrl+Shift+A odpre Dosežke — 26 dosežkov z rarity barvami, progress bari in tooltipi!",
        priority = 26,
    },
    stats_panel = {
        text = "Ctrl+Shift+I odpre Statistiko — 4 zavihki z grafi, lestvicami in realno-časnim pregledom!",
        priority = 27,
    },
    ui_sfx_toggle = {
        text = "F2 preklopi UI zvoke — zvok za vse panele (odpiranje, klik, tab switch, dosežki)!",
        priority = 28,
    },
    first_royal_system = {
        text = "Aktiviral si svoj prvi Royal sistem! Odklenjen dosežek: Kraljevi pionir (★).",
        priority = 30,
    },
    first_market_event = {
        text = "Sprožil si prvi tržni dogodek! Cene se bodo spreminjale 60s — izkoristi priložnost!",
        priority = 31,
    },
    first_bookmark = {
        text = "Označil si prvi zaznamek v Tech Tree! B za zaznamovanje, Shift+B za filter zaznamovanih.",
        priority = 32,
    },
}

-- Show a hint (if not already shown this session)
function TutorialHints.show(hintKey, force)
    if not enabled then return end
    if not HINTS[hintKey] then return end
    if hintsShown[hintKey] and not force then return end

    -- Don't override higher priority hints
    if activeHint and HINTS[activeHint] and HINTS[hintKey].priority < HINTS[activeHint].priority then
        return
    end

    hintsShown[hintKey] = true
    -- v3.12.132: Persist shown state
    pcall(love.filesystem.append, SHOWN_FILE, hintKey .. "\n")
    activeHint = hintKey
    hintTimer = hintDuration

    -- Also show as notification
    if _G.ModernUI then
        local hint = HINTS[hintKey]
        _G.ModernUI.notifyInfo(hint.text, hintDuration)
    end
    -- v3.12.132: Also send to NotificationCenter as a low-priority toast
    if _G.NotificationCenter then
        local hint = HINTS[hintKey]
        pcall(function()
            _G.NotificationCenter.system("💡 " .. hint.text, _G.NotificationCenter.PRIORITY.LOW, hintDuration)
        end)
    end
end

-- Update hint timer
function TutorialHints.update(dt)
    if not activeHint then return end
    hintTimer = hintTimer - dt
    if hintTimer <= 0 then
        activeHint = nil
    end
end

-- Draw hint (if active)
function TutorialHints.draw()
    if not enabled or not activeHint then return end
    -- Hints are shown via ModernUI notifications, no separate drawing needed
end

-- Reset hints (new game) — v3.12.132: also clears persisted file
function TutorialHints.reset()
    hintsShown = {}
    activeHint = nil
    hintTimer = 0
    -- Clear persisted shown file
    pcall(love.filesystem.write, SHOWN_FILE, "")
    print("[TutorialHints] Reset all hints (persisted file cleared)")
end

-- Enable/disable hints — v3.12.132: persists state
function TutorialHints.setEnabled(state)
    enabled = state
    pcall(love.filesystem.write, ENABLED_FILE, tostring(state) .. "\n")
end

-- v3.12.132: Get all hints with shown status (for tutorial panel)
function TutorialHints.getAll()
    local result = {}
    for key, hint in pairs(HINTS) do
        result[#result + 1] = {
            key = key,
            text = hint.text,
            priority = hint.priority,
            shown = hintsShown[key] == true,
        }
    end
    -- Sort by priority
    table.sort(result, function(a, b) return a.priority < b.priority end)
    return result
end

-- v3.12.132: Get hint info by key
function TutorialHints.getHint(hintKey)
    if not HINTS[hintKey] then return nil end
    return {
        key = hintKey,
        text = HINTS[hintKey].text,
        priority = HINTS[hintKey].priority,
        shown = hintsShown[hintKey] == true,
    }
end

-- v3.12.132: Mark a hint as shown without showing the toast (used by tutorial panel)
function TutorialHints.markShown(hintKey)
    if not HINTS[hintKey] then return false end
    if not hintsShown[hintKey] then
        hintsShown[hintKey] = true
        pcall(love.filesystem.append, SHOWN_FILE, hintKey .. "\n")
    end
    return true
end

-- v3.12.132: Unmark a hint as shown (re-show next time)
function TutorialHints.unmarkShown(hintKey)
    if not HINTS[hintKey] then return false end
    hintsShown[hintKey] = nil
    -- Rebuild persisted file
    local lines = {}
    for k, _ in pairs(hintsShown) do
        lines[#lines + 1] = k
    end
    pcall(love.filesystem.write, SHOWN_FILE, table.concat(lines, "\n") .. "\n")
    return true
end

-- v3.12.132: Get stats
function TutorialHints.getStats()
    local total = 0
    local shownCount = 0
    for key, _ in pairs(HINTS) do
        total = total + 1
        if hintsShown[key] then shownCount = shownCount + 1 end
    end
    return {
        totalHints = total,
        shownHints = shownCount,
        remainingHints = total - shownCount,
        enabled = enabled,
    }
end

-- Check if a hint has been shown
function TutorialHints.wasShown(hintKey)
    return hintsShown[hintKey] == true
end

-- === AUTOMATIC TRIGGERS ===

-- Call when game starts
function TutorialHints.onGameStart()
    TutorialHints.show("first_game_start")
    TutorialHints.show("first_settings")
    TutorialHints.show("weather_tip")
end

-- Call when player places first building
function TutorialHints.onBuildingPlaced(buildingName)
    if not TutorialHints.wasShown("first_build") then
        TutorialHints.show("first_build")
    end
    if buildingName == "Market" and not TutorialHints.wasShown("first_market") then
        TutorialHints.show("first_market")
    end
    if buildingName == "Barracks" and not TutorialHints.wasShown("first_unit_recruit") then
        TutorialHints.show("first_unit_recruit")
    end
end

-- Call when player recruits first unit
function TutorialHints.onUnitRecruited(unitType)
    if unitType ~= "Peasant" and not TutorialHints.wasShown("first_combat") then
        TutorialHints.show("first_combat")
    end
end

-- Call when AI faction is spawned
function TutorialHints.onAISpawned()
    TutorialHints.show("ai_spawned")
end

-- Call when enemy approaches
function TutorialHints.onEnemyApproaching()
    TutorialHints.show("enemy_approaching")
end

-- Call periodically to check resource levels
function TutorialHints.checkResources()
    if not _G.state then return end

    -- Castle Kingdoms 2027 v2.5.7: Fixed food check (was using gold as placeholder)
    local gold = _G.state.gold or 0
    local food = 0
    if _G.state.resources and _G.state.resources.food then
        food = _G.state.resources.food
    elseif _G.state.food then
        food = _G.state.food
    end

    -- Check every 30 seconds (called from update)
    if gold < 100 and not TutorialHints.wasShown("low_gold") then
        TutorialHints.show("low_gold")
    end
    -- Castle Kingdoms 2027 v2.5.7: Added low food hint
    if food < 20 and not TutorialHints.wasShown("low_food") then
        TutorialHints.show("low_food")
    end
end

return TutorialHints
