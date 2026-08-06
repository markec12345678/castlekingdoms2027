-- states/ui/settings/gamefeel_settings.lua
-- Stronghold 2027 - Full Settings Panel
--
-- Comprehensive settings with:
-- - 3 tabs: Game Feel, Audio, Graphics
-- - Tooltips for each setting
-- - Reset to Defaults button
-- - FPS limiter and VSync
-- - Volume controls (Master/Music/SFX/Ambient/Speech)
-- - Settings persistence (settings.json)
--
-- Toggle with 'V' key during gameplay or Options button in main menu.

local SettingsPersistence = require("objects.Config.SettingsPersistence")

local GameFeelSettings = {}

local visible = false
local currentTab = "gamefeel"  -- gamefeel, audio, graphics

-- Tooltip state
local tooltip = {
    visible = false,
    text = "",
    x = 0,
    y = 0,
}

-- Setting definitions with tooltips
local SETTING_DEFS = {
    -- Game Feel tab
    screenShake = {
        label = "Screen Shake",
        tooltip = "Tresenje zaslona med bojem in ob eksplozijah. Izklopi če občutljiv na motion sickness.",
        tab = "gamefeel",
        type = "toggle",
    },
    hitFlash = {
        label = "Hit Flash",
        tooltip = "Rdeči blisk na enoti ko utrpi poškodbo. Pomaga videti kdo je napaden.",
        tab = "gamefeel",
        type = "toggle",
    },
    punchZoom = {
        label = "Punch Zoom",
        tooltip = "Hitri zoom in/out ob smrti enote ali uničenju zgradbe. Daje občutek 'weight'.",
        tab = "gamefeel",
        type = "toggle",
    },
    buildPreview = {
        label = "Build Preview",
        tooltip = "Prikaz ghost zgradbe pred postavitvijo. Zelena = valid, rdeča = neveljavna lokacija.",
        tab = "gamefeel",
        type = "toggle",
    },
    selectionGlow = {
        label = "Selection Glow",
        tooltip = "Svetleči krog pod izbranimi enotami. Rumeni krog ob hoverju miške.",
        tab = "gamefeel",
        type = "toggle",
    },
    combatOrderLines = {
        label = "Combat Lines",
        tooltip = "Rdeče črte do attack tarč, rumene do destinacij. Samo za izbrane enote.",
        tab = "gamefeel",
        type = "toggle",
    },
    weatherEffects = {
        label = "Weather Effects",
        tooltip = "Dež, sneg, megla in nevihta. Vpliva na atmosfero in hitrost enot.",
        tab = "gamefeel",
        type = "toggle",
    },
    dynamicLighting = {
        label = "Day/Night Cycle",
        tooltip = "Dnevno/nočni ciklus z dinamično osvetlitvijo. Bakle svetlijo ponoči.",
        tab = "gamefeel",
        type = "toggle",
    },
    cameraSmoothing = {
        label = "Camera Smoothing",
        tooltip = "Koliko časa potrebuje kamera za doseg target pozicije. 0 = instant, 15 = zelo smooth.",
        tab = "gamefeel",
        type = "slider",
        min = 0,
        max = 15,
        step = 0.5,
    },

    -- Audio tab
    masterVolume = {
        label = "Master Volume",
        tooltip = "Skupna glasnost vseh zvokov. Vpliva na vse ostale volumen nastavitve.",
        tab = "audio",
        type = "slider",
        min = 0,
        max = 1.0,
        step = 0.05,
    },
    musicVolume = {
        label = "Music Volume",
        tooltip = "Glasnost glasbe v ozadju.",
        tab = "audio",
        type = "slider",
        min = 0,
        max = 1.0,
        step = 0.05,
    },
    sfxVolume = {
        label = "SFX Volume",
        tooltip = "Glasnost zvočnih efektov (meči, puščice, gradnja, UI kliki).",
        tab = "audio",
        type = "slider",
        min = 0,
        max = 1.0,
        step = 0.05,
    },
    ambientVolume = {
        label = "Ambient Volume",
        tooltip = "Glasnost okoljskih zvokov (veter, ptice, ogenj, dež).",
        tab = "audio",
        type = "slider",
        min = 0,
        max = 1.0,
        step = 0.05,
    },
    speechVolume = {
        label = "Speech Volume",
        tooltip = "Glasnost govora enot in advisorja.",
        tab = "audio",
        type = "slider",
        min = 0,
        max = 1.0,
        step = 0.05,
    },

    -- Graphics tab
    fpsLimit = {
        label = "FPS Limit",
        tooltip = "Omejitev framov na sekundo. 0 = neomejeno. 60 = standard. 144 = za 144Hz monitorje.",
        tab = "graphics",
        type = "slider",
        min = 0,
        max = 144,
        step = 30,
    },
    vsync = {
        label = "VSync",
        tooltip = "Vertikalna sinhronizacija. Preprečuje tearing. Lahko doda input lag.",
        tab = "graphics",
        type = "toggle",
    },
    showFps = {
        label = "Show FPS",
        tooltip = "Prikaže FPS counter v zgornjem kotu zaslona.",
        tab = "graphics",
        type = "toggle",
    },
    useKenneyAssets = {
        label = "CC0 Asseti (Kenney)",
        tooltip = "Uporabi CC0 (public domain) Kenney assete namesto originalnih. Popolna neodvisnost od Firefly Studios. Brez atribucije, komercialno brezplačno.",
        tab = "graphics",
        type = "toggle",
    },
}

-- Tab definitions
local TABS = {
    { id = "gamefeel", label = "Game Feel" },
    { id = "audio",    label = "Audio" },
    { id = "graphics", label = "Graphics" },
}

-- === Public API ===

function GameFeelSettings.toggle()
    visible = not visible
    if visible then
        SettingsPersistence.applyAll()
    end
end

function GameFeelSettings.setVisible(state)
    visible = state
end

function GameFeelSettings.isVisible()
    return visible
end

function GameFeelSettings.getSettings()
    return SettingsPersistence.getAll()
end

function GameFeelSettings.set(key, value)
    SettingsPersistence.set(key, value)
    SettingsPersistence.applyAll()
    SettingsPersistence.save()
end

function GameFeelSettings.applySettings()
    SettingsPersistence.applyAll()
end

function GameFeelSettings.resetToDefaults()
    SettingsPersistence.reset()
    SettingsPersistence.applyAll()
    if _G.ModernUI then
        _G.ModernUI.notifySuccess("Nastavitve ponastavljene na privzete vrednosti")
    end
end

-- === Drawing ===

function GameFeelSettings.draw()
    if not visible then return end

    local screenW, screenH = love.graphics.getDimensions()
    local panelW = 480
    local panelH = 520
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
    love.graphics.print("Nastavitve", panelX + 20, panelY + 15)

    -- Tabs
    local tabY = panelY + 40
    local tabX = panelX + 20
    local tabW = 130
    for _, tab in ipairs(TABS) do
        local isActive = currentTab == tab.id
        if isActive then
            love.graphics.setColor(0.4, 0.35, 0.25, 1)
        else
            love.graphics.setColor(0.2, 0.18, 0.15, 1)
        end
        love.graphics.rectangle("fill", tabX, tabY, tabW, 28, 4, 4, 4, 4)
        love.graphics.setColor(0.6, 0.5, 0.3, 1)
        love.graphics.setLineWidth(1)
        love.graphics.rectangle("line", tabX, tabY, tabW, 28, 4, 4, 4, 4)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(tab.label, tabX + 15, tabY + 6)
        tabX = tabX + tabW + 5
    end

    -- Separator
    love.graphics.setColor(0.6, 0.5, 0.3, 0.5)
    love.graphics.setLineWidth(1)
    love.graphics.line(panelX + 20, panelY + 75, panelX + panelW - 20, panelY + 75)

    -- Content area
    local contentY = panelY + 85
    local contentX = panelX + 30
    local rowH = 35

    -- Draw settings for current tab
    local settings = SettingsPersistence.getAll()
    local rowIdx = 0

    for key, def in pairs(SETTING_DEFS) do
        if def.tab == currentTab then
            rowIdx = rowIdx + 1
            local y = contentY + (rowIdx - 1) * rowH

            -- Label
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.print(def.label, contentX, y + 2)

            -- Value display for sliders
            if def.type == "slider" then
                local value = settings[key] or 0
                local displayValue = value
                if key:match("Volume") then
                    displayValue = string.format("%d%%", value * 100)
                elseif key == "fpsLimit" then
                    displayValue = value == 0 and "Unlimited" or tostring(value)
                elseif key == "cameraSmoothing" then
                    displayValue = string.format("%.1f", value)
                end
                love.graphics.setColor(0.7, 0.7, 0.7, 1)
                love.graphics.print(tostring(displayValue), contentX + 200, y + 2)
            end

            -- Draw control
            if def.type == "toggle" then
                GameFeelSettings.drawToggle(contentX + panelW - 100, y, settings[key] or false, key)
            elseif def.type == "slider" then
                GameFeelSettings.drawSlider(contentX + 260, y + 2, panelW - 300, settings[key] or 0, def, key)
            end

            -- Hover detection for tooltip
            local mx, my = love.mouse.getPosition()
            if mx >= contentX and mx <= contentX + panelW - 50 and my >= y and my <= y + rowH then
                tooltip.visible = true
                tooltip.text = def.tooltip
                tooltip.x = mx
                tooltip.y = my
            end
        end
    end

    -- Reset button
    local resetY = panelY + panelH - 60
    love.graphics.setColor(0.4, 0.2, 0.2, 1)
    love.graphics.rectangle("fill", contentX, resetY, 140, 30, 4, 4, 4, 4)
    love.graphics.setColor(0.8, 0.5, 0.5, 1)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", contentX, resetY, 140, 30, 4, 4, 4, 4)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Reset to Defaults", contentX + 15, resetY + 7)

    -- Close hint
    love.graphics.setColor(0.5, 0.5, 0.5, 1)
    love.graphics.print("[V] Zapri", panelX + panelW - 80, resetY + 7)

    -- Draw tooltip
    if tooltip.visible and tooltip.text ~= "" then
        GameFeelSettings.drawTooltip(tooltip.x, tooltip.y, tooltip.text)
    end

    -- Reset tooltip
    tooltip.visible = false

    love.graphics.setColor(1, 1, 1, 1)
end

-- Draw a toggle switch
function GameFeelSettings.drawToggle(x, y, isEnabled, key)
    local w = 40
    local h = 20

    if isEnabled then
        love.graphics.setColor(0.3, 0.7, 0.3, 1)
    else
        love.graphics.setColor(0.4, 0.2, 0.2, 1)
    end
    love.graphics.rectangle("fill", x, y + 5, w, h, 10, 10, 10, 10)

    local knobX = isEnabled and (x + w - 10) or (x + 10)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.circle("fill", knobX, y + 5 + h / 2, 8)
end

-- Draw a slider
function GameFeelSettings.drawSlider(x, y, w, value, def, key)
    local h = 6

    -- Track
    love.graphics.setColor(0.3, 0.3, 0.3, 1)
    love.graphics.rectangle("fill", x, y + 7, w, h)

    -- Fill
    local progress = (value - (def.min or 0)) / ((def.max or 1) - (def.min or 0))
    progress = math.max(0, math.min(1, progress))
    love.graphics.setColor(0.6, 0.5, 0.3, 1)
    love.graphics.rectangle("fill", x, y + 7, w * progress, h)

    -- Knob
    local knobX = x + w * progress
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.circle("fill", knobX, y + 10, 8)
end

-- Draw tooltip
function GameFeelSettings.drawTooltip(mx, my, text)
    local font = love.graphics.getFont()
    local textW = font:getWidth(text)
    local textH = font:getHeight()
    local padding = 8
    local tx = mx + 15
    local ty = my + 15

    -- Keep on screen
    local screenW = love.graphics.getWidth()
    if tx + textW + padding * 2 > screenW then
        tx = mx - textW - padding * 2 - 15
    end

    -- Background
    love.graphics.setColor(0.05, 0.05, 0.08, 0.95)
    love.graphics.rectangle("fill", tx, ty, textW + padding * 2, textH + padding, 4, 4, 4, 4)

    -- Border
    love.graphics.setColor(0.6, 0.5, 0.3, 0.8)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", tx, ty, textW + padding * 2, textH + padding, 4, 4, 4, 4)

    -- Text
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(text, tx + padding, ty + padding / 2)
end

-- === Mouse handling ===

function GameFeelSettings.mousepressed(x, y, button)
    if not visible or button ~= 1 then return false end

    local screenW, screenH = love.graphics.getDimensions()
    local panelW = 480
    local panelH = 520
    local panelX = (screenW - panelW) / 2
    local panelY = (screenH - panelH) / 2

    -- Tab clicks
    local tabY = panelY + 40
    local tabX = panelX + 20
    local tabW = 130
    for _, tab in ipairs(TABS) do
        if x >= tabX and x <= tabX + tabW and y >= tabY and y <= tabY + 28 then
            currentTab = tab.id
            return true
        end
        tabX = tabX + tabW + 5
    end

    -- Content clicks
    local contentY = panelY + 85
    local contentX = panelX + 30
    local rowH = 35
    local settings = SettingsPersistence.getAll()

    local rowIdx = 0
    for key, def in pairs(SETTING_DEFS) do
        if def.tab == currentTab then
            rowIdx = rowIdx + 1
            local rowY = contentY + (rowIdx - 1) * rowH

            if x >= contentX and x <= contentX + panelW - 50 and y >= rowY and y <= rowY + rowH then
                if def.type == "toggle" then
                    -- Toggle
                    GameFeelSettings.set(key, not settings[key])
                    return true
                elseif def.type == "slider" then
                    -- Slider click
                    local sliderX = contentX + 260
                    local sliderW = panelW - 300
                    if x >= sliderX and x <= sliderX + sliderW then
                        local progress = (x - sliderX) / sliderW
                        progress = math.max(0, math.min(1, progress))
                        local value = (def.min or 0) + progress * ((def.max or 1) - (def.min or 0))
                        -- Snap to step
                        if def.step then
                            value = math.floor(value / def.step + 0.5) * def.step
                        end
                        GameFeelSettings.set(key, value)
                        return true
                    end
                end
            end
        end
    end

    -- Reset button
    local resetY = panelY + panelH - 60
    if x >= contentX and x <= contentX + 140 and y >= resetY and y <= resetY + 30 then
        GameFeelSettings.resetToDefaults()
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
