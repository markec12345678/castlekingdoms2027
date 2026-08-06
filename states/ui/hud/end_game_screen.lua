-- states/ui/hud/end_game_screen.lua
-- Stronghold 2027 - End Game Screen
-- Victory/defeat screen with game statistics summary

local loveframes = require("libraries.loveframes")
local states = require("states.ui.states")

local EndGameScreen = {}

local panel = nil
local isVisible = false
local gameResult = nil  -- "victory" or "defeat"
local gameStats = {}

function EndGameScreen.init()
    if panel then return end

    local w, h = love.graphics.getDimensions()
    panel = loveframes.Create("frame")
    panel:SetName("")
    panel:SetSize(600, 500)
    panel:SetPos((w-600)/2, (h-500)/2)
    panel:SetState(states.STATE_INGAME_CONSTRUCTION)
    panel:ShowCloseButton(false)
    panel:SetVisible(false)
    panel:SetDraggable(false)

    -- Title
    EndGameScreen.titleText = loveframes.Create("text", panel)
    EndGameScreen.titleText:SetPos(50, 30)
    EndGameScreen.titleText:SetSize(500, 50)

    -- Stats display
    EndGameScreen.statsText = loveframes.Create("text", panel)
    EndGameScreen.statsText:SetPos(50, 100)
    EndGameScreen.statsText:SetSize(500, 300)

    -- Buttons
    EndGameScreen.restartBtn = loveframes.Create("button", panel)
    EndGameScreen.restartBtn:SetPos(50, 430)
    EndGameScreen.restartBtn:SetSize(150, 40)
    EndGameScreen.restartBtn:SetText("Nova igra")
    EndGameScreen.restartBtn.OnClick = function()
        EndGameScreen.hide()
        local Gamestate = require("libraries.gamestate")
        local startMenu = require("states.start_menu")
        Gamestate.switch(startMenu)
    end

    EndGameScreen.continueBtn = loveframes.Create("button", panel)
    EndGameScreen.continueBtn:SetPos(225, 430)
    EndGameScreen.continueBtn:SetSize(150, 40)
    EndGameScreen.continueBtn:SetText("Nadaljuj")
    EndGameScreen.continueBtn.OnClick = function()
        EndGameScreen.hide()
    end

    EndGameScreen.creditsBtn = loveframes.Create("button", panel)
    EndGameScreen.creditsBtn:SetPos(400, 430)
    EndGameScreen.creditsBtn:SetSize(150, 40)
    EndGameScreen.creditsBtn:SetText("Zasluge")
    EndGameScreen.creditsBtn.OnClick = function()
        EndGameScreen.hide()
        local CreditsScreen = require("states.ui.hud.credits_screen")
        CreditsScreen.show()
    end

    print("[EndGameScreen] Initialized")
end

function EndGameScreen.show(result, stats)
    EndGameScreen.init()
    gameResult = result or "victory"
    gameStats = stats or {}
    isVisible = true
    panel:SetVisible(true)

    -- Set title
    if gameResult == "victory" then
        EndGameScreen.titleText:SetText("ZMAGA!")
        if _G.DynamicMusic then _G.DynamicMusic.triggerVictory() end
        if _G.VoiceOver then _G.VoiceOver.battleWon() end
    else
        EndGameScreen.titleText:SetText("PORAZ")
        if _G.DynamicMusic then _G.DynamicMusic.triggerDefeat() end
        if _G.VoiceOver then _G.VoiceOver.battleLost() end
    end

    -- Build stats text
    local lines = {}
    table.insert(lines, "=== Statistika igre ===")
    table.insert(lines, "")
    table.insert(lines, "Trajanje: " .. EndGameScreen._formatTime(gameStats.duration or 0))
    table.insert(lines, "Zgrajene zgradbe: " .. tostring(gameStats.buildingsBuilt or 0))
    table.insert(lines, "Usposobljene enote: " .. tostring(gameStats.unitsTrained or 0))
    table.insert(lines, "Ubite enote: " .. tostring(gameStats.unitsKilled or 0))
    table.insert(lines, "Izgubljene enote: " .. tostring(gameStats.unitsLost or 0))

    local kd = (gameStats.unitsLost or 0) > 0
        and (gameStats.unitsKilled or 0) / (gameStats.unitsLost or 0)
        or (gameStats.unitsKilled or 0)
    table.insert(lines, string.format("K/D razmerje: %.2f", kd))

    table.insert(lines, "")
    table.insert(lines, "Zasluzeno zlata: " .. tostring(gameStats.goldEarned or 0))
    table.insert(lines, "Trgovine: " .. tostring(gameStats.tradesCompleted or 0))
    table.insert(lines, "Zavezništva: " .. tostring(gameStats.alliancesFormed or 0))
    table.insert(lines, "")
    table.insert(lines, "Maks. populacija: " .. tostring(gameStats.maxPopulation or 0))
    table.insert(lines, "Maks. zlato: " .. tostring(gameStats.maxGold or 0))

    if gameStats.noCasualties then
        table.insert(lines, "")
        table.insert(lines, "Brez izgub! (dosezek: Flawless)")
    end

    if gameStats.duration and gameStats.duration < 600 then
        table.insert(lines, "Hitra zmaga! (dosezek: Speed Runner)")
    end

    EndGameScreen.statsText:SetText(table.concat(lines, "\n"))

    -- Emit event
    if _G.GameEventBus then
        _G.GameEventBus.emit(gameResult == "victory" and "victory" or "defeat", gameStats)
    end

    print("[EndGameScreen] Showing: " .. gameResult)
end

function EndGameScreen._formatTime(seconds)
    local m = math.floor(seconds / 60)
    local s = math.floor(seconds % 60)
    return string.format("%dm %ds", m, s)
end

function EndGameScreen.hide()
    isVisible = false
    if panel then panel:SetVisible(false) end
end

function EndGameScreen.isVisible()
    return isVisible
end

return EndGameScreen
