-- shaders/HD_SHADERS.lua
-- Castle Kingdoms 2027 - HD Shader Manager
-- Loads and manages modern post-processing shaders
--
-- Usage:
--   local HDShaders = require("shaders.HD_SHADERS")
--   HDShaders.init()
--   HDShaders.enable("bloom", true)
--   HDShaders.apply(canvas)

local HDShaders = {}

local shaders = {}
local enabled = {}
local shaderOrder = { "bloom", "color_grading", "vignette", "dynamic_lighting" }

-- Default settings (configurable via config.ini)
local defaults = {
    bloom = {
        enabled = true,
        intensity = 0.6,
        threshold = 0.7
    },
    color_grading = {
        enabled = true,
        shadows = { 0.9, 0.85, 0.8 },      -- Warm shadows
        midtones = { 1.0, 0.98, 0.92 },    -- Neutral midtones
        highlights = { 1.05, 1.0, 0.95 },  -- Bright highlights
        saturation = 1.15,
        contrast = 1.05,
        brightness = 0.0
    },
    vignette = {
        enabled = true,
        intensity = 0.3,
        radius = 0.85
    },
    dynamic_lighting = {
        enabled = false,  -- Disabled by default (requires day/night cycle)
        timeOfDay = 0.5,
        ambientIntensity = 1.0,
        sunColor = { 1.0, 0.9, 0.7 },
        sunPosition = { 0.7, 0.3 }
    }
}

function HDShaders.init()
    if _G.testMode then return end

    -- Load all shaders
    local ok1, bloom = pcall(love.graphics.newShader, "shaders/bloom.glsl")
    if ok1 then shaders.bloom = bloom else print("Warning: bloom shader failed to load") end

    local ok2, cg = pcall(love.graphics.newShader, "shaders/color_grading.glsl")
    if ok2 then shaders.color_grading = cg else print("Warning: color_grading shader failed to load") end

    local ok3, vig = pcall(love.graphics.newShader, "shaders/vignette.glsl")
    if ok3 then shaders.vignette = vig else print("Warning: vignette shader failed to load") end

    local ok4, dl = pcall(love.graphics.newShader, "shaders/dynamic_lighting.glsl")
    if ok4 then shaders.dynamic_lighting = dl else print("Warning: dynamic_lighting shader failed to load") end

    -- Apply defaults
    for name, settings in pairs(defaults) do
        enabled[name] = settings.enabled
    end

    print(string.format("HD Shaders initialized: %d/%d loaded successfully",
        HDShaders.countLoaded(), #shaderOrder))
end

function HDShaders.countLoaded()
    local count = 0
    for _, name in ipairs(shaderOrder) do
        if shaders[name] then count = count + 1 end
    end
    return count
end

function HDShaders.enable(name, state)
    if defaults[name] then
        enabled[name] = state
        return true
    end
    return false
end

function HDShaders.isEnabled(name)
    return enabled[name] == true and shaders[name] ~= nil
end

function HDShaders.setParam(name, param, value)
    if defaults[name] and defaults[name][param] ~= nil then
        defaults[name][param] = value
        return true
    end
    return false
end

function HDShaders.getParam(name, param)
    if defaults[name] then
        return defaults[name][param]
    end
    return nil
end

function HDShaders.apply(canvas)
    if _G.testMode then return canvas end

    local currentCanvas = canvas
    local w, h = love.graphics.getDimensions()

    for _, name in ipairs(shaderOrder) do
        if HDShaders.isEnabled(name) then
            local shader = shaders[name]
            local settings = defaults[name]

            -- Create temp canvas
            local tempCanvas = love.graphics.newCanvas(w, h)
            love.graphics.setCanvas(tempCanvas)
            love.graphics.clear()

            -- Set shader uniforms
            if name == "bloom" then
                shader:send("screen", { w, h })
                shader:send("intensity", settings.intensity)
                shader:send("threshold", settings.threshold)
            elseif name == "color_grading" then
                shader:send("shadows", settings.shadows)
                shader:send("midtones", settings.midtones)
                shader:send("highlights", settings.highlights)
                shader:send("saturation", settings.saturation)
                shader:send("contrast", settings.contrast)
                shader:send("brightness", settings.brightness)
            elseif name == "vignette" then
                shader:send("screen", { w, h })
                shader:send("intensity", settings.intensity)
                shader:send("radius", settings.radius)
            elseif name == "dynamic_lighting" then
                shader:send("screen", { w, h })
                shader:send("timeOfDay", settings.timeOfDay)
                shader:send("ambientIntensity", settings.ambientIntensity)
                shader:send("sunColor", settings.sunColor)
                shader:send("sunPosition", settings.sunPosition)
            end

            -- Apply shader
            love.graphics.setShader(shader)
            love.graphics.draw(currentCanvas)
            love.graphics.setShader()
            love.graphics.setCanvas()

            currentCanvas = tempCanvas
        end
    end

    return currentCanvas
end

function HDShaders.getList()
    local list = {}
    for _, name in ipairs(shaderOrder) do
        table.insert(list, {
            name = name,
            loaded = shaders[name] ~= nil,
            enabled = HDShaders.isEnabled(name),
            settings = defaults[name]
        })
    end
    return list
end

function HDShaders.preset(name)
    -- Apply preset configurations
    if name == "cinematic" then
        HDShaders.setParam("bloom", "intensity", 0.8)
        HDShaders.setParam("bloom", "threshold", 0.6)
        HDShaders.setParam("vignette", "intensity", 0.4)
        HDShaders.setParam("color_grading", "saturation", 1.2)
        HDShaders.setParam("color_grading", "contrast", 1.1)
        HDShaders.enable("bloom", true)
        HDShaders.enable("vignette", true)
        HDShaders.enable("color_grading", true)
    elseif name == "realistic" then
        HDShaders.setParam("bloom", "intensity", 0.3)
        HDShaders.setParam("bloom", "threshold", 0.8)
        HDShaders.setParam("vignette", "intensity", 0.15)
        HDShaders.setParam("color_grading", "saturation", 1.0)
        HDShaders.setParam("color_grading", "contrast", 1.0)
    elseif name == "vibrant" then
        HDShaders.setParam("bloom", "intensity", 0.7)
        HDShaders.setParam("bloom", "threshold", 0.5)
        HDShaders.setParam("vignette", "intensity", 0.2)
        HDShaders.setParam("color_grading", "saturation", 1.4)
        HDShaders.setParam("color_grading", "contrast", 1.15)
    elseif name == "minimal" then
        HDShaders.enable("bloom", false)
        HDShaders.enable("vignette", false)
        HDShaders.enable("color_grading", false)
        HDShaders.enable("dynamic_lighting", false)
    elseif name == "all_on" then
        HDShaders.enable("bloom", true)
        HDShaders.enable("vignette", true)
        HDShaders.enable("color_grading", true)
        HDShaders.enable("dynamic_lighting", true)
    end
end

return HDShaders
