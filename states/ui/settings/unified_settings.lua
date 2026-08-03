-- states/ui/settings/unified_settings.lua
-- Stronghold 2027 - Unified Settings Panel
-- Integrates all settings: audio, graphics, accessibility, localization, HD, game

local loveframes = require("libraries.loveframes")
local states = require("states.ui.states")
local AccessibilitySystem = require("objects.Config.AccessibilitySystem")
local LocalizationSystem = require("objects.Config.LocalizationSystem")
local HDShaders = require("shaders.HD_SHADERS")
local PerfWatchdog = require("objects.QA.PerformanceWatchdog")
local AudioMix = require("objects.Audio.AudioMixSystem")

local UnifiedSettings = {}

local panel = nil
local isVisible = false
local currentTab = "gameplay"

function UnifiedSettings.init()
    if panel then return end

    local w, h = love.graphics.getDimensions()
    panel = loveframes.Create("frame")
    panel:SetName("Stronghold 2027 - Settings")
    panel:SetSize(700, 550)
    panel:SetPos((w-700)/2, (h-550)/2)
    panel:SetState(states.STATE_INGAME_CONSTRUCTION)
    panel:ShowCloseButton(false)
    panel:SetVisible(false)

    -- Tab buttons
    local tabs = {"Gameplay", "Graphics", "Audio", "Accessibility", "Language"}
    local tabWidth = 130
    for i, tabName in ipairs(tabs) do
        local btn = loveframes.Create("button", panel)
        btn:SetPos(10 + (i-1) * tabWidth, 30)
        btn:SetSize(tabWidth - 5, 30)
        btn:SetText(tabName)
        btn.OnClick = function()
            currentTab = tabName:lower()
            UnifiedSettings.refresh()
        end
    end

    -- Content area
    UnifiedSettings.contentY = 70
    UnifiedSettings.refresh()
end

function UnifiedSettings.refresh()
    -- Clear existing content (simplified - in full implementation would remove old widgets)
    -- For now, just update based on current tab
    if currentTab == "gameplay" then
        UnifiedSettings._drawGameplayTab()
    elseif currentTab == "graphics" then
        UnifiedSettings._drawGraphicsTab()
    elseif currentTab == "audio" then
        UnifiedSettings._drawAudioTab()
    elseif currentTab == "accessibility" then
        UnifiedSettings._drawAccessibilityTab()
    elseif currentTab == "language" then
        UnifiedSettings._drawLanguageTab()
    end
end

function UnifiedSettings._drawGameplayTab()
    local y = UnifiedSettings.contentY

    local label = loveframes.Create("text", panel)
    label:SetPos(20, y)
    label:SetText("=== Gameplay Settings ===")
    y = y + 30

    -- Auto-save toggle
    local autosaveBtn = loveframes.Create("button", panel)
    autosaveBtn:SetPos(20, y)
    autosaveBtn:SetSize(300, 30)
    autosaveBtn:SetText("Auto-save: ON (every 5 min)")
    y = y + 40

    -- Tutorial reset
    local tutorialBtn = loveframes.Create("button", panel)
    tutorialBtn:SetPos(20, y)
    tutorialBtn:SetSize(300, 30)
    tutorialBtn:SetText("Reset Tutorial")
    tutorialBtn.OnClick = function()
        local Tutorial = require("objects.Tutorial.TutorialSystem")
        Tutorial.reset()
    end
    y = y + 40

    -- Game speed
    local speedLabel = loveframes.Create("text", panel)
    speedLabel:SetPos(20, y)
    speedLabel:SetText("Default game speed: 1x (Normal)")
end

function UnifiedSettings._drawGraphicsTab()
    local y = UnifiedSettings.contentY

    local label = loveframes.Create("text", panel)
    label:SetPos(20, y)
    label:SetText("=== Graphics Settings ===")
    y = y + 30

    -- Quality level
    local qualityBtn = loveframes.Create("button", panel)
    qualityBtn:SetPos(20, y)
    qualityBtn:SetSize(300, 30)
    local qName = PerfWatchdog.getQualityName()
    qualityBtn:SetText("Quality: " .. qName .. " (click to cycle)")
    qualityBtn.OnClick = function()
        local current = PerfWatchdog.getQuality()
        PerfWatchdog.setQuality((current % 4) + 1)
        UnifiedSettings.refresh()
    end
    y = y + 40

    -- HD shaders toggles
    local shaders = HDShaders.getList()
    for _, shader in ipairs(shaders) do
        local btn = loveframes.Create("button", panel)
        btn:SetPos(20, y)
        btn:SetSize(300, 25)
        local state = shader.enabled and "ON" or "OFF"
        btn:SetText(shader.name .. ": " .. state)
        btn.OnClick = function()
            HDShaders.enable(shader.name, not shader.enabled)
            UnifiedSettings.refresh()
        end
        y = y + 30
    end
end

function UnifiedSettings._drawAudioTab()
    local y = UnifiedSettings.contentY

    local label = loveframes.Create("text", panel)
    label:SetPos(20, y)
    label:SetText("=== Audio Settings ===")
    y = y + 30

    -- Volume sliders (as buttons for simplicity)
    local volumes = AudioMix.getAllVolumes()
    local cats = {"master", "sfx", "music", "speech", "ambient"}
    for _, cat in ipairs(cats) do
        local btn = loveframes.Create("button", panel)
        btn:SetPos(20, y)
        btn:SetSize(300, 25)
        local vol = math.floor((volumes[cat] or 0) * 100)
        btn:SetText(cat:upper() .. " Volume: " .. vol .. "% (click to adjust)")
        btn.OnClick = function()
            local newVol = ((volumes[cat] or 0) + 0.25) % 1.25
            AudioMix.setVolume(cat, newVol)
            UnifiedSettings.refresh()
        end
        y = y + 30
    end
end

function UnifiedSettings._drawAccessibilityTab()
    local y = UnifiedSettings.contentY

    local label = loveframes.Create("text", panel)
    label:SetPos(20, y)
    label:SetText("=== Accessibility Settings ===")
    y = y + 30

    local settings = AccessibilitySystem.getSettings()

    -- Colorblind mode
    local cbBtn = loveframes.Create("button", panel)
    cbBtn:SetPos(20, y)
    cbBtn:SetSize(300, 30)
    cbBtn:SetText("Colorblind: " .. settings.colorblindMode .. " (click to cycle)")
    cbBtn.OnClick = function()
        local modes = {"none", "protanopia", "deuteranopia", "tritanopia"}
        local current = settings.colorblindMode
        local idx = 1
        for i, m in ipairs(modes) do if m == current then idx = i break end end
        local nextMode = modes[(idx % #modes) + 1]
        AccessibilitySystem.setColorblindMode(nextMode)
        UnifiedSettings.refresh()
    end
    y = y + 40

    -- Font scale
    local fontBtn = loveframes.Create("button", panel)
    fontBtn:SetPos(20, y)
    fontBtn:SetSize(300, 30)
    fontBtn:SetText("Font Size: " .. settings.fontScale .. " (click to cycle)")
    fontBtn.OnClick = function()
        local scales = {"small", "medium", "large", "xlarge"}
        local current = settings.fontScale
        local idx = 1
        for i, s in ipairs(scales) do if s == current then idx = i break end end
        AccessibilitySystem.setFontScale(scales[(idx % #scales) + 1])
        UnifiedSettings.refresh()
    end
    y = y + 40

    -- Reduced motion
    local rmBtn = loveframes.Create("button", panel)
    rmBtn:SetPos(20, y)
    rmBtn:SetSize(300, 30)
    rmBtn:SetText("Reduced Motion: " .. tostring(settings.reducedMotion))
    rmBtn.OnClick = function()
        AccessibilitySystem.setReducedMotion(not settings.reducedMotion)
        UnifiedSettings.refresh()
    end
    y = y + 40

    -- High contrast
    local hcBtn = loveframes.Create("button", panel)
    hcBtn:SetPos(20, y)
    hcBtn:SetSize(300, 30)
    hcBtn:SetText("High Contrast: " .. tostring(settings.highContrast))
    hcBtn.OnClick = function()
        AccessibilitySystem.setHighContrast(not settings.highContrast)
        UnifiedSettings.refresh()
    end
end

function UnifiedSettings._drawLanguageTab()
    local y = UnifiedSettings.contentY

    local label = loveframes.Create("text", panel)
    label:SetPos(20, y)
    label:SetText("=== Language Selection ===")
    y = y + 30

    local current = LocalizationSystem.getLanguage()
    local langs = LocalizationSystem.getLanguageList()

    -- Show first 12 languages as buttons
    for i = 1, math.min(12, #langs) do
        local lang = langs[i]
        local btn = loveframes.Create("button", panel)
        local row = math.floor((i-1) / 3)
        local col = (i-1) % 3
        btn:SetPos(20 + col * 215, y + row * 35)
        btn:SetSize(210, 30)
        local marker = lang.code == current and " > " or "   "
        btn:SetText(marker .. lang.nativeName .. " (" .. lang.code .. ")")
        btn.OnClick = function()
            LocalizationSystem.setLanguage(lang.code)
            UnifiedSettings.refresh()
        end
    end
end

function UnifiedSettings.show()
    UnifiedSettings.init()
    isVisible = true
    panel:SetVisible(true)
    UnifiedSettings.refresh()
end

function UnifiedSettings.hide()
    isVisible = false
    if panel then panel:SetVisible(false) end
end

function UnifiedSettings.toggle()
    if isVisible then UnifiedSettings.hide() else UnifiedSettings.show() end
end

function UnifiedSettings.isVisible()
    return isVisible
end

return UnifiedSettings
