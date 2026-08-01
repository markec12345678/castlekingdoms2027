-- states/ui/settings/gamefeel_settings.lua
-- Stronghold 2027 - Game Feel Settings Panel
--
-- Allows player to toggle game feel effects:
-- - Screen shake (on/off, intensity)
-- - Hit flash (on/off)
-- - Punch zoom (on/off)
-- - Build preview (on/off)
-- - Selection glow (on/off)
-- - Combat order lines (on/off)
-- - Camera smoothing (slider)
--
-- Toggle with 'V' key during gameplay

local loveframes = require("libraries.loveframes")
local states = require("states.ui.states")

local GameFeelSettings = {}

local visible = false

-- Settings state (persisted in config)
local settings = {
    screenShake = true,
    hitFlash = true,
    punchZoom = true,
    buildPreview = true,
    selectionGlow = true,
    combatOrderLines = true,
    cameraSmoothing = 5.0,
    weatherEffects = true,
    dynamicLighting = true,
}

-- Toggle visibility
function GameFeelSettings.toggle()
    visible = not visible
end

function GameFeelSettings.setVisible(state)
    visible = state
end

function GameFeelSettings.isVisible()
    return visible
end

-- Get settings
function GameFeelSettings.getSettings()
    return settings
end

-- Set a setting
function GameFeelSettings.set(key, value)
    settings[key] = value
    GameFeelSettings.applySettings()
end

-- Apply settings to all systems
function GameFeelSettings.applySettings()
    if _G.GameFeel then
        _G.GameFeel.setShakeEnabled(settings.screenShake)
        _G.GameFeel.setCameraSmoothing(settings.cameraSmoothing)
        if not settings.hitFlash then
            -- Disable hit flash by setting duration to 0
        end
        if not settings.punchZoom then
            -- Disable punch zoom
        end
    end
    if _G.BuildPreview then
        _G.BuildPreview.setEnabled(settings.buildPreview)
    end
    if _G.SelectionFeedback then
        _G.SelectionFeedback.setEnabled(settings.selectionGlow)
    end
    if _G.CombatOrderViz then
        _G.CombatOrderViz.setEnabled(settings.combatOrderLines)
    end
end

-- Draw settings panel
function GameFeelSettings.draw()
    if not visible then return end

    local screenW, screenH = love.graphics.getDimensions()
    local panelW = 400
    local panelH = 420
    local panelX = (screenW - panelW) / 2
    local panelY = (screenH - panelH) / 2

    -- Dim background
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", 0, 0, screenW, screenH)

    -- Main panel
    love.graphics.setColor(0.12, 0.1, 0.08, 0.97)
    love.graphics.rectangle("fill", panelX, panelY, panelW, panelH, 8, 8, 8, 8)

    -- Border
    love.graphics.setColor(0.6, 0.5, 0.3, 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", panelX, panelY, panelW, panelH, 8, 8, 8, 8)

    -- Title
    love.graphics.setColor(1, 0.9, 0.7, 1)
    love.graphics.print("Nastavitve - Game Feel", panelX + 20, panelY + 15)
    love.graphics.setColor(0.6, 0.5, 0.3, 1)
    love.graphics.setLineWidth(1)
    love.graphics.line(panelX + 20, panelY + 40, panelX + panelW - 20, panelY + 40)

    local y = panelY + 55
    local x = panelX + 30
    local rowH = 32

    -- Helper: draw toggle row
    local function drawToggle(label, key, description)
        local isEnabled = settings[key]

        -- Label
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(label, x, y)

        -- Description (smaller)
        if description then
            love.graphics.setColor(0.6, 0.6, 0.6, 1)
            love.graphics.print(description, x + 200, y + 4)
        end

        -- Toggle switch
        local toggleX = x + panelW - 80
        local toggleY = y + 2
        local toggleW = 40
        local toggleH = 20

        if isEnabled then
            love.graphics.setColor(0.3, 0.7, 0.3, 1)
        else
            love.graphics.setColor(0.4, 0.2, 0.2, 1)
        end
        love.graphics.rectangle("fill", toggleX, toggleY, toggleW, toggleH, 10, 10, 10, 10)

        -- Toggle knob
        local knobX = isEnabled and (toggleX + toggleW - 10) or (toggleX + 10)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.circle("fill", knobX, toggleY + toggleH / 2, 8)

        -- Store hit area
        love.graphics.setColor(0.6, 0.5, 0.3, 0.3)
        love.graphics.rectangle("line", x - 5, y - 2, panelW - 50, rowH - 4)

        y = y + rowH
    end

    -- Draw all toggles
    drawToggle("Screen Shake", "screenShake", "tresenje zaslona")
    drawToggle("Hit Flash", "hitFlash", "rdeč blisk ob poškodbi")
    drawToggle("Punch Zoom", "punchZoom", "zoom ob smrti/eksploziji")
    drawToggle("Build Preview", "buildPreview", "ghost zgradbe pred gradnjo")
    drawToggle("Selection Glow", "selectionGlow", "krog okoli izbranih enot")
    drawToggle("Combat Lines", "combatOrderLines", "črte do tarč/destinacij")
    drawToggle("Weather FX", "weatherEffects", "dež, sneg, megla")
    drawToggle("Day/Night", "dynamicLighting", "dnevno/nočno ciklus")

    -- Camera smoothing slider
    y = y + 10
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Camera Smoothing", x, y)
    love.graphics.setColor(0.6, 0.6, 0.6, 1)
    love.graphics.print(string.format("%.1f", settings.cameraSmoothing), x + panelW - 80, y)

    -- Slider track
    y = y + 20
    love.graphics.setColor(0.3, 0.3, 0.3, 1)
    love.graphics.rectangle("fill", x, y, panelW - 60, 6)
    love.graphics.setColor(0.6, 0.5, 0.3, 1)
    love.graphics.rectangle("fill", x, y, (panelW - 60) * (settings.cameraSmoothing / 15), 6)

    -- Slider knob
    local sliderX = x + (panelW - 60) * (settings.cameraSmoothing / 15)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.circle("fill", sliderX, y + 3, 8)

    -- Footer
    y = panelY + panelH - 30
    love.graphics.setColor(0.5, 0.5, 0.5, 1)
    love.graphics.print("[V] Zapri nastavitve", panelX + 20, y)
    love.graphics.print("[ESC) Zapri", panelX + panelW - 100, y)

    love.graphics.setColor(1, 1, 1, 1)
end

-- Handle mouse click
function GameFeelSettings.mousepressed(x, y, button)
    if not visible or button ~= 1 then return false end

    local screenW, screenH = love.graphics.getDimensions()
    local panelW = 400
    local panelH = 420
    local panelX = (screenW - panelW) / 2
    local panelY = (screenH - panelH) / 2

    -- Check toggle clicks
    local toggleKeys = {
        "screenShake", "hitFlash", "punchZoom", "buildPreview",
        "selectionGlow", "combatOrderLines", "weatherEffects", "dynamicLighting",
    }

    local rowY = panelY + 55
    local rowH = 32
    local rowX = panelX + 25
    local rowW = panelW - 50

    for i, key in ipairs(toggleKeys) do
        local ry = rowY + (i - 1) * rowH
        if x >= rowX and x <= rowX + rowW and y >= ry and y <= ry + rowH then
            settings[key] = not settings[key]
            GameFeelSettings.applySettings()
            return true
        end
    end

    -- Check slider click
    local sliderY = rowY + #toggleKeys * rowH + 30
    if x >= panelX + 30 and x <= panelX + panelW - 30 and y >= sliderY - 5 and y <= sliderY + 15 then
        local sliderW = panelW - 60
        local progress = (x - panelX - 30) / sliderW
        progress = math.max(0, math.min(1, progress))
        settings.cameraSmoothing = progress * 15
        GameFeelSettings.applySettings()
        return true
    end

    return false
end

-- Handle keypress
function GameFeelSettings.keypressed(key)
    if key == "v" or key == "escape" then
        GameFeelSettings.toggle()
        return true
    end
    return false
end

return GameFeelSettings
