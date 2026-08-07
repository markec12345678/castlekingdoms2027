-- objects/Config/AccessibilitySystem.lua
-- Castle Kingdoms 2027 - Accessibility System
--
-- Provides accessibility options:
-- - Colorblind modes (protanopia, deuteranopia, tritanopia)
-- - Font scaling (small, medium, large, extra large)
-- - High contrast mode
-- - Reduced motion (disable screen shake, animations)
-- - Subtitles for speech
-- - Visual indicators for audio cues
-- - Configurable input delays
-- - Key remapping support
--
-- Usage:
--   local A11y = require("objects.Config.AccessibilitySystem")
--   A11y.init()
--   A11y.setColorblindMode("deuteranopia")
--   A11y.setFontScale("large")

local AccessibilitySystem = {}

local COLORBLIND_MODES = {
    none = {
        name = "None (Normal)",
        matrix = nil,
    },
    protanopia = {
        name = "Protanopia (Red-blind)",
        -- Color matrix: simulates red blindness
        matrix = {
            {0.567, 0.433, 0},
            {0.558, 0.442, 0},
            {0,     0.242, 0.758},
        },
    },
    deuteranopia = {
        name = "Deuteranopia (Green-blind)",
        matrix = {
            {0.625, 0.375, 0},
            {0.7,   0.3,   0},
            {0,     0.3,   0.7},
        },
    },
    tritanopia = {
        name = "Tritanopia (Blue-blind)",
        matrix = {
            {0.95, 0.05, 0},
            {0,    0.433, 0.567},
            {0,    0.475, 0.525},
        },
    },
}

local FONT_SCALES = {
    small = { name = "Small",       scale = 0.85 },
    medium = { name = "Medium",     scale = 1.0 },
    large = { name = "Large",       scale = 1.25 },
    xlarge = { name = "Extra Large", scale = 1.5 },
}

AccessibilitySystem.COLORBLIND_MODES = COLORBLIND_MODES
AccessibilitySystem.FONT_SCALES = FONT_SCALES

local settings = {
    colorblindMode = "none",
    fontScale = "medium",
    highContrast = false,
    reducedMotion = false,
    subtitlesEnabled = true,
    visualIndicators = true,
    inputDelay = 0,  -- milliseconds
    autoPauseOnFocusLoss = true,
}

local initialized = false
local colorblindShader = nil

-- Initialize
function AccessibilitySystem.init()
    if initialized then return end
    initialized = true

    -- Load saved settings
    AccessibilitySystem._loadSettings()

    -- Create colorblind shader if needed
    AccessibilitySystem._updateColorblindShader()

    print("[AccessibilitySystem] Initialized")
    print(string.format("[AccessibilitySystem] Colorblind: %s | Font: %s | High contrast: %s | Reduced motion: %s",
        settings.colorblindMode, settings.fontScale,
        tostring(settings.highContrast), tostring(settings.reducedMotion)))
end

-- Set colorblind mode
function AccessibilitySystem.setColorblindMode(mode)
    if not COLORBLIND_MODES[mode] then
        print("[AccessibilitySystem] Unknown colorblind mode: " .. tostring(mode))
        return false
    end

    settings.colorblindMode = mode
    AccessibilitySystem._updateColorblindShader()
    AccessibilitySystem._saveSettings()
    print("[AccessibilitySystem] Colorblind mode: " .. mode)
    return true
end

-- Get current colorblind mode
function AccessibilitySystem.getColorblindMode()
    return settings.colorblindMode
end

-- Update colorblind shader
function AccessibilitySystem._updateColorblindShader()
    local mode = COLORBLIND_MODES[settings.colorblindMode]
    if not mode or not mode.matrix then
        colorblindShader = nil
        return
    end

    -- Create color matrix shader
    local m = mode.matrix
    local shaderCode = string.format([[
        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
        {
            vec4 texel = Texel(texture, texture_coords);
            vec3 rgb = texel.rgb;
            vec3 result = vec3(
                dot(rgb, vec3(%.4f, %.4f, %.4f)),
                dot(rgb, vec3(%.4f, %.4f, %.4f)),
                dot(rgb, vec3(%.4f, %.4f, %.4f))
            );
            return vec4(result, texel.a);
        }
    ]], m[1][1], m[2][1], m[3][1],
        m[1][2], m[2][2], m[3][2],
        m[1][3], m[2][3], m[3][3])

    local ok, shader = pcall(love.graphics.newShader, shaderCode)
    if ok then
        colorblindShader = shader
    else
        print("[AccessibilitySystem] Failed to create colorblind shader: " .. tostring(shader))
        colorblindShader = nil
    end
end

-- Get colorblind shader (for rendering)
function AccessibilitySystem.getColorblindShader()
    return colorblindShader
end

-- Apply colorblind shader (call before drawing scene)
function AccessibilitySystem.applyColorblindShader()
    if colorblindShader then
        love.graphics.setShader(colorblindShader)
    end
end

-- Reset shader
function AccessibilitySystem.resetShader()
    love.graphics.setShader()
end

-- Set font scale
function AccessibilitySystem.setFontScale(scale)
    if not FONT_SCALES[scale] then
        print("[AccessibilitySystem] Unknown font scale: " .. tostring(scale))
        return false
    end

    settings.fontScale = scale
    AccessibilitySystem._saveSettings()
    print("[AccessibilitySystem] Font scale: " .. scale .. " (" .. FONT_SCALES[scale].scale .. "x)")
    return true
end

-- Get font scale multiplier
function AccessibilitySystem.getFontScaleMultiplier()
    return FONT_SCALES[settings.fontScale].scale
end

-- Get font scale setting
function AccessibilitySystem.getFontScale()
    return settings.fontScale
end

-- Toggle high contrast mode
function AccessibilitySystem.setHighContrast(enabled)
    settings.highContrast = enabled
    AccessibilitySystem._saveSettings()
    print("[AccessibilitySystem] High contrast: " .. tostring(enabled))
end

function AccessibilitySystem.isHighContrast()
    return settings.highContrast
end

-- Toggle reduced motion
function AccessibilitySystem.setReducedMotion(enabled)
    settings.reducedMotion = enabled
    AccessibilitySystem._saveSettings()

    -- Apply to GameFeel system
    if _G.GameFeel then
        _G.GameFeel.setReducedMotion(enabled)
    end

    print("[AccessibilitySystem] Reduced motion: " .. tostring(enabled))
end

function AccessibilitySystem.isReducedMotion()
    return settings.reducedMotion
end

-- Toggle subtitles
function AccessibilitySystem.setSubtitlesEnabled(enabled)
    settings.subtitlesEnabled = enabled
    AccessibilitySystem._saveSettings()
    print("[AccessibilitySystem] Subtitles: " .. tostring(enabled))
end

function AccessibilitySystem.areSubtitlesEnabled()
    return settings.subtitlesEnabled
end

-- Toggle visual indicators (for audio cues)
function AccessibilitySystem.setVisualIndicators(enabled)
    settings.visualIndicators = enabled
    AccessibilitySystem._saveSettings()
    print("[AccessibilitySystem] Visual indicators: " .. tostring(enabled))
end

function AccessibilitySystem.areVisualIndicatorsEnabled()
    return settings.visualIndicators
end

-- Set input delay (for motor accessibility)
function AccessibilitySystem.setInputDelay(ms)
    settings.inputDelay = math.max(0, math.min(500, ms))
    AccessibilitySystem._saveSettings()
end

function AccessibilitySystem.getInputDelay()
    return settings.inputDelay
end

-- Toggle auto-pause on focus loss
function AccessibilitySystem.setAutoPauseOnFocusLoss(enabled)
    settings.autoPauseOnFocusLoss = enabled
    AccessibilitySystem._saveSettings()
end

function AccessibilitySystem.isAutoPauseOnFocusLoss()
    return settings.autoPauseOnFocusLoss
end

-- Get all settings
function AccessibilitySystem.getSettings()
    return settings
end

-- Get list of colorblind modes
function AccessibilitySystem.getColorblindModes()
    local list = {}
    for code, mode in pairs(COLORBLIND_MODES) do
        table.insert(list, { code = code, name = mode.name })
    end
    table.sort(list, function(a, b) return a.code < b.code end)
    return list
end

-- Get list of font scales
function AccessibilitySystem.getFontScales()
    local list = {}
    for code, scale in pairs(FONT_SCALES) do
        table.insert(list, { code = code, name = scale.name, scale = scale.scale })
    end
    table.sort(list, function(a, b) return a.scale < b.scale end)
    return list
end

-- Save settings
function AccessibilitySystem._saveSettings()
    local file = love.filesystem.newFile("accessibility_settings.json")
    if file:open("w") then
        local lines = {"return {"}
        for k, v in pairs(settings) do
            if type(v) == "string" then
                table.insert(lines, string.format('  %s = "%s",', k, v))
            elseif type(v) == "boolean" then
                table.insert(lines, string.format('  %s = %s,', k, tostring(v)))
            else
                table.insert(lines, string.format('  %s = %s,', k, tostring(v)))
            end
        end
        table.insert(lines, "}")
        file:write(table.concat(lines, "\n"))
        file:close()
    end
end

-- Load settings
function AccessibilitySystem._loadSettings()
    local file = love.filesystem.newFile("accessibility_settings.json")
    if file:open("r") then
        local content = file:read()
        file:close()

        if content then
            local ok, chunk = pcall(load, content)
            if ok and chunk then
                local dataOk, data = pcall(chunk)
                if dataOk and type(data) == "table" then
                    for k, v in pairs(data) do
                        settings[k] = v
                    end
                end
            end
        end
    end
end

-- Reset to defaults
function AccessibilitySystem.resetToDefaults()
    settings = {
        colorblindMode = "none",
        fontScale = "medium",
        highContrast = false,
        reducedMotion = false,
        subtitlesEnabled = true,
        visualIndicators = true,
        inputDelay = 0,
        autoPauseOnFocusLoss = true,
    }
    AccessibilitySystem._updateColorblindShader()
    AccessibilitySystem._saveSettings()
    print("[AccessibilitySystem] Reset to defaults")
end

-- Get stats
function AccessibilitySystem.getStats()
    return {
        colorblindMode = settings.colorblindMode,
        fontScale = settings.fontScale,
        highContrast = settings.highContrast,
        reducedMotion = settings.reducedMotion,
        subtitlesEnabled = settings.subtitlesEnabled,
        visualIndicators = settings.visualIndicators,
    }
end

return AccessibilitySystem
