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
    activeHint = hintKey
    hintTimer = hintDuration

    -- Also show as notification
    if _G.ModernUI then
        local hint = HINTS[hintKey]
        _G.ModernUI.notifyInfo(hint.text, hintDuration)
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

-- Reset hints (new game)
function TutorialHints.reset()
    hintsShown = {}
    activeHint = nil
    hintTimer = 0
end

-- Enable/disable hints
function TutorialHints.setEnabled(state)
    enabled = state
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
