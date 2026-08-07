-- states/ui/hud/mission_end_screen.lua
-- Castle Kingdoms 2027 - Mission End Screen
--
-- Shows win/lose screen when mission objectives are completed/failed:
-- - Victory: gold banner, stats, "Continue" button
-- - Defeat: dark overlay, stats, "Retry" button
-- - Shows: time taken, units lost, buildings built, gold earned
--
-- Hooks into MissionFramework.onMissionWon/onMissionLost

local MissionEndScreen = {}

local visible = false
local result = nil  -- "victory" or "defeat"
local stats = {}
local animTime = 0
local fadeIn = 0

-- Configuration
local config = {
    fadeSpeed = 2.0,
    bannerColor = { 1, 0.85, 0.3 },  -- gold for victory
    defeatColor = { 0.8, 0.2, 0.2 }, -- red for defeat
    bgColor = { 0, 0, 0, 0.7 },
}

-- Show the end screen
function MissionEndScreen.show(resultType, missionStats)
    visible = true
    result = resultType
    stats = missionStats or {}
    animTime = 0
    fadeIn = 0
end

-- Hide the end screen
function MissionEndScreen.hide()
    visible = false
    result = nil
end

function MissionEndScreen.isVisible()
    return visible
end

function MissionEndScreen.update(dt)
    if not visible then return end
    animTime = animTime + dt
    fadeIn = math.min(1, fadeIn + dt * config.fadeSpeed)
end

function MissionEndScreen.draw()
    if not visible then return end

    local screenW, screenH = love.graphics.getDimensions()
    local alpha = fadeIn

    -- Background overlay
    love.graphics.setColor(0, 0, 0, alpha * 0.7)
    love.graphics.rectangle("fill", 0, 0, screenW, screenH)

    -- Panel
    local panelW = 500
    local panelH = 400
    local panelX = (screenW - panelW) / 2
    local panelY = (screenH - panelH) / 2

    -- Slide-in animation
    local slideY = panelY + (1 - alpha) * 50
    panelY = slideY

    -- Panel background
    love.graphics.setColor(0.1, 0.08, 0.06, alpha * 0.97)
    love.graphics.rectangle("fill", panelX, panelY, panelW, panelH, 8, 8, 8, 8)

    -- Border (color based on result)
    local borderColor = result == "victory" and config.bannerColor or config.defeatColor
    love.graphics.setColor(borderColor[1], borderColor[2], borderColor[3], alpha)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", panelX, panelY, panelW, panelH, 8, 8, 8, 8)

    -- Title
    local title = result == "victory" and "MISIJA USPEŠNA!" or "MISIJA NEUSPEŠNA"
    love.graphics.setColor(borderColor[1], borderColor[2], borderColor[3], alpha)
    local titleFont = love.graphics.getFont()
    local titleW = titleFont:getWidth(title)
    love.graphics.print(title, panelX + (panelW - titleW) / 2, panelY + 30)

    -- Separator
    love.graphics.setColor(borderColor[1], borderColor[2], borderColor[3], alpha * 0.5)
    love.graphics.setLineWidth(1)
    love.graphics.line(panelX + 50, panelY + 65, panelX + panelW - 50, panelY + 65)

    -- Stats
    local y = panelY + 85
    local x = panelX + 50
    love.graphics.setColor(1, 1, 1, alpha)

    local statLines = {
        { label = "Trajanje:", value = string.format("%d:%02d", math.floor((stats.time or 0) / 60), math.floor((stats.time or 0) % 60)) },
        { label = "Zgradbe postavljene:", value = tostring(stats.buildingsBuilt or 0) },
        { label = "Enote rekrutirane:", value = tostring(stats.unitsRecruited or 0) },
        { label = "Sovražnikovi izgubljeni:", value = tostring(stats.enemiesKilled or 0) },
        { label = "Tvoje izgube:", value = tostring(stats.unitsLost or 0) },
        { label = "Zlato prisluženo:", value = tostring(stats.goldEarned or 0) },
    }

    for _, stat in ipairs(statLines) do
        love.graphics.setColor(0.7, 0.7, 0.7, alpha)
        love.graphics.print(stat.label, x, y)
        love.graphics.setColor(1, 1, 1, alpha)
        love.graphics.print(stat.value, x + 250, y)
        y = y + 25
    end

    -- Mission name
    if stats.missionName then
        y = y + 15
        love.graphics.setColor(0.5, 0.5, 0.5, alpha)
        love.graphics.print("Misija: " .. stats.missionName, x, y)
    end

    -- Buttons
    y = panelY + panelH - 70

    -- Continue / Retry button
    local btnText = result == "victory" and "Nadaljuj" or "Poskusi znova"
    local btnW = 180
    local btnH = 40
    local btnX = panelX + (panelW - btnW) / 2

    -- Button background
    love.graphics.setColor(borderColor[1] * 0.3, borderColor[2] * 0.3, borderColor[3] * 0.3, alpha)
    love.graphics.rectangle("fill", btnX, y, btnW, btnH, 4, 4, 4, 4)
    love.graphics.setColor(borderColor[1], borderColor[2], borderColor[3], alpha)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", btnX, y, btnW, btnH, 4, 4, 4, 4)

    -- Button text
    love.graphics.setColor(1, 1, 1, alpha)
    local btnTextW = titleFont:getWidth(btnText)
    love.graphics.print(btnText, btnX + (btnW - btnTextW) / 2, y + 10)

    -- Exit to menu button
    y = y + 50
    love.graphics.setColor(0.3, 0.3, 0.3, alpha * 0.8)
    love.graphics.rectangle("fill", btnX + 20, y, 140, 30, 4, 4, 4, 4)
    love.graphics.setColor(0.7, 0.7, 0.7, alpha)
    love.graphics.print("Glavni meni", btnX + 40, y + 7)

    love.graphics.setColor(1, 1, 1, 1)
end

-- Handle mouse click
function MissionEndScreen.mousepressed(x, y, button)
    if not visible or button ~= 1 then return false end
    if fadeIn < 0.5 then return false end  -- ignore clicks during fade-in

    local screenW, screenH = love.graphics.getDimensions()
    local panelW = 500
    local panelH = 400
    local panelX = (screenW - panelW) / 2
    local panelY = (screenH - panelH) / 2

    -- Continue / Retry button
    local btnY = panelY + panelH - 70
    local btnW = 180
    local btnH = 40
    local btnX = panelX + (panelW - btnW) / 2

    if x >= btnX and x <= btnX + btnW and y >= btnY and y <= btnY + btnH then
        MissionEndScreen.hide()
        if result == "victory" then
            -- Load next mission or return to menu
            if _G.MissionFramework and _G.MissionFramework.currentMission then
                local nextMission = _G.MissionFramework.currentMission.nextMission
                if nextMission then
                    _G.MissionFramework.loadMission(nextMission)
                    _G.MissionFramework.startMission()
                else
                    -- No next mission - show credits
                    local Credits = require("states.ui.hud.credits_screen")
                    Credits.show()
                end
            end
        else
            -- Retry - restart current mission
            if _G.MissionFramework and _G.MissionFramework.currentMission then
                _G.MissionFramework.loadMission(_G.MissionFramework.currentMission.key)
                _G.MissionFramework.startMission()
            end
        end
        return true
    end

    -- Exit to menu button
    btnY = panelY + panelH - 20
    if x >= btnX + 20 and x <= btnX + 160 and y >= btnY and y <= btnY + 30 then
        MissionEndScreen.hide()
        -- Return to main menu
        local Gamestate = require("libraries.gamestate")
        local startMenu = require("states.start_menu")
        Gamestate.switch(startMenu)
        return true
    end

    return false
end

return MissionEndScreen
