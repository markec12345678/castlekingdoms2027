-- objects/Environment/HDRenderPipeline.lua
-- Stronghold 2027 - HD Render Pipeline
--
-- Integrates all HD rendering systems:
-- - Normal mapping for terrain (dynamic sun lighting)
-- - Dynamic point lights (torches, fires, buildings)
-- - Screen-space ambient occlusion (SSAO)
-- - HDR tone mapping (ACES filmic)
-- - Bloom, color grading, vignette (existing HD shaders)
--
-- Usage:
--   local HDRenderPipeline = require("objects.Environment.HDRenderPipeline")
--   HDRenderPipeline.init()
--   HDRenderPipeline.update(dt)
--   HDRenderPipeline.beginCapture()  -- before drawing world
--   HDRenderPipeline.endCapture()    -- after drawing world, applies shaders
--   HDRenderPipeline.drawLights()    -- draw light overlays

local HDRenderPipeline = {}

local HDShaders = require("shaders.HD_SHADERS")
local NormalMapGenerator = require("objects.Environment.NormalMapGenerator")

local initialized = false
local enabled = true

-- Render canvases
local sceneCanvas = nil    -- Main scene render target
local ssaoCanvas = nil     -- SSAO result
local lightCanvas = nil    -- Point lights result
local canvasWidth = 0
local canvasHeight = 0

-- Shaders
local shaders = {}

-- Point lights
local pointLights = {}
local maxLights = 32

-- Sun/light direction for normal mapping
local sunDirection = { 0.5, -0.3, 0.8 }

-- Initialize
function HDRenderPipeline.init()
    if initialized then return end
    initialized = true

    -- Initialize HD shaders first (bloom, color_grading, vignette, dynamic_lighting)
    HDShaders.init()

    -- Load new HD shaders
    local ok1, nm = pcall(love.graphics.newShader, "shaders/normal_mapping.glsl")
    if ok1 then shaders.normal_mapping = nm else print("[HDRenderPipeline] Warning: normal_mapping shader failed") end

    local ok2, pl = pcall(love.graphics.newShader, "shaders/point_lights.glsl")
    if ok2 then shaders.point_lights = pl else print("[HDRenderPipeline] Warning: point_lights shader failed") end

    local ok3, ssao = pcall(love.graphics.newShader, "shaders/ssao.glsl")
    if ok3 then shaders.ssao = ssao else print("[HDRenderPipeline] Warning: ssao shader failed") end

    local ok4, tm = pcall(love.graphics.newShader, "shaders/tonemap.glsl")
    if ok4 then shaders.tonemap = tm else print("[HDRenderPipeline] Warning: tonemap shader failed") end

    -- Create canvases
    HDRenderPipeline.resizeCanvases()

    -- Enable HD shaders
    HDShaders.enable("bloom", true)
    HDShaders.enable("color_grading", true)
    HDShaders.enable("vignette", true)
    HDShaders.enable("dynamic_lighting", true)

    local shaderCount = 0
    for _ in pairs(shaders) do shaderCount = shaderCount + 1 end

    print(string.format("[HDRenderPipeline] Initialized (%d new shaders loaded)", shaderCount))
end

-- Resize canvases to match screen
function HDRenderPipeline.resizeCanvases()
    canvasWidth, canvasHeight = love.graphics.getDimensions()

    -- Use half resolution for performance-intensive effects
    local halfW = math.floor(canvasWidth / 2)
    local halfH = math.floor(canvasHeight / 2)

    sceneCanvas = love.graphics.newCanvas(canvasWidth, canvasHeight)
    ssaoCanvas = love.graphics.newCanvas(halfW, halfH)
    lightCanvas = love.graphics.newCanvas(canvasWidth, canvasHeight)
end

-- Enable/disable HD pipeline
function HDRenderPipeline.setEnabled(state)
    enabled = state
end

function HDRenderPipeline.isEnabled()
    return enabled
end

-- Set sun direction (for normal mapping)
function HDRenderPipeline.setSunDirection(x, y, z)
    local len = math.sqrt(x * x + y * y + z * z)
    if len > 0 then
        sunDirection = { x / len, y / len, z / len }
    end
end

-- Add a dynamic point light
-- @param id string Unique identifier
-- @param x number Screen X position
-- @param y number Screen Y position
-- @param radius number Light radius (in pixels)
-- @param color table {r, g, b} (0-1)
-- @param intensity number Light intensity (0-1)
function HDRenderPipeline.addLight(id, x, y, radius, color, intensity)
    pointLights[id] = {
        x = x,
        y = y,
        radius = radius or 100,
        color = color or { 1.0, 0.8, 0.5 },
        intensity = intensity or 1.0,
    }
end

-- Remove a light
function HDRenderPipeline.removeLight(id)
    pointLights[id] = nil
end

-- Update a light's position
function HDRenderPipeline.updateLight(id, x, y)
    if pointLights[id] then
        pointLights[id].x = x
        pointLights[id].y = y
    end
end

-- Clear all lights
function HDRenderPipeline.clearLights()
    pointLights = {}
end

-- Get number of active lights
function HDRenderPipeline.getLightCount()
    local count = 0
    for _ in pairs(pointLights) do count = count + 1 end
    return count
end

-- Begin scene capture (render world to canvas)
function HDRenderPipeline.beginCapture()
    if not initialized or not enabled then return false end

    -- Render to scene canvas
    love.graphics.setCanvas(sceneCanvas)
    love.graphics.clear(0, 0, 0, 0)
    return true
end

-- End scene capture and apply HD effects
function HDRenderPipeline.endCapture()
    if not initialized or not enabled then return nil end

    love.graphics.setCanvas()

    local currentCanvas = sceneCanvas

    -- 1. Apply normal mapping (if normal map is available)
    if shaders.normal_mapping and NormalMapGenerator.getNormalMap() then
        local normalMap = NormalMapGenerator.getNormalMap()
        local tempCanvas = love.graphics.newCanvas(canvasWidth, canvasHeight)

        love.graphics.setCanvas(tempCanvas)
        love.graphics.clear()

        local shader = shaders.normal_mapping
        love.graphics.setShader(shader)
        shader:send("screen", { canvasWidth, canvasHeight })
        shader:send("normalMap", normalMap)

        -- Get sun color from dynamic_lighting settings
        local sunColor = HDShaders.getParam("dynamic_lighting", "sunColor") or { 1.0, 0.9, 0.7 }
        local ambientIntensity = HDShaders.getParam("dynamic_lighting", "ambientIntensity") or 1.0

        shader:send("lightDir", sunDirection)
        shader:send("lightColor", sunColor)
        shader:send("lightIntensity", 0.8)
        shader:send("ambientColor", { 0.5, 0.5, 0.6 })
        shader:send("ambientIntensity", ambientIntensity)

        love.graphics.draw(currentCanvas)
        love.graphics.setShader()
        love.graphics.setCanvas()

        currentCanvas = tempCanvas
    end

    -- 2. Apply SSAO (screen-space ambient occlusion)
    if shaders.ssao then
        local tempCanvas = love.graphics.newCanvas(canvasWidth, canvasHeight)

        love.graphics.setCanvas(tempCanvas)
        love.graphics.clear()

        local shader = shaders.ssao
        love.graphics.setShader(shader)
        shader:send("screen", { canvasWidth, canvasHeight })
        shader:send("radius", 2.0)
        shader:send("intensity", 0.6)
        shader:send("bias", 0.02)

        love.graphics.draw(currentCanvas)
        love.graphics.setShader()
        love.graphics.setCanvas()

        currentCanvas = tempCanvas
    end

    -- 3. Apply point lights (torches, fires)
    if shaders.point_lights and HDRenderPipeline.getLightCount() > 0 then
        local tempCanvas = love.graphics.newCanvas(canvasWidth, canvasHeight)

        love.graphics.setCanvas(tempCanvas)
        love.graphics.clear()

        local shader = shaders.point_lights
        love.graphics.setShader(shader)

        -- Prepare light arrays
        local positions = {}
        local colors = {}
        local intensities = {}
        local count = 0

        for id, light in pairs(pointLights) do
            if count < maxLights then
                count = count + 1
                positions[count] = { light.x, light.y, light.radius }
                colors[count] = light.color
                intensities[count] = light.intensity
            end
        end

        -- Fill remaining slots with zeros
        for i = count + 1, maxLights do
            positions[i] = { 0, 0, 0 }
            colors[i] = { 0, 0, 0 }
            intensities[i] = 0
        end

        shader:send("screen", { canvasWidth, canvasHeight })
        shader:send("lightPositions", unpack(positions))
        shader:send("lightColors", unpack(colors))
        shader:send("lightIntensities", unpack(intensities))
        shader:send("lightCount", count)
        shader:send("viewOffset", { 0, 0 })
        shader:send("zoom", 1.0)

        love.graphics.draw(currentCanvas)
        love.graphics.setShader()
        love.graphics.setCanvas()

        currentCanvas = tempCanvas
    end

    -- 4. Apply HD shaders (bloom, color_grading, vignette, dynamic_lighting)
    currentCanvas = HDShaders.apply(currentCanvas)

    -- 5. Apply tone mapping (ACES filmic)
    if shaders.tonemap then
        local tempCanvas = love.graphics.newCanvas(canvasWidth, canvasHeight)

        love.graphics.setCanvas(tempCanvas)
        love.graphics.clear()

        local shader = shaders.tonemap
        love.graphics.setShader(shader)
        shader:send("exposure", 1.0)
        shader:send("gamma", 2.2)

        love.graphics.draw(currentCanvas)
        love.graphics.setShader()
        love.graphics.setCanvas()

        currentCanvas = tempCanvas
    end

    return currentCanvas
end

-- Draw the final composited result to screen
function HDRenderPipeline.drawResult(canvas)
    if not canvas then return end
    love.graphics.draw(canvas)
end

-- Update pipeline (called every frame)
function HDRenderPipeline.update(dt)
    if not initialized then return end

    -- Update normal map if heightmap is available
    if _G.state and _G.state.map and _G.state.map.heightmap then
        NormalMapGenerator.update(dt, _G.state.map.heightmap, _G.chunkWidth or 32, _G.chunkHeight or 32, _G.chunksWide or 8, _G.chunksHigh or 8)
    end

    -- Update sun direction based on time of day
    local timeOfDay = HDShaders.getParam("dynamic_lighting", "timeOfDay") or 0.5
    local angle = (timeOfDay - 0.25) * math.pi * 2
    HDRenderPipeline.setSunDirection(
        math.cos(angle) * 0.7,
        -math.sin(angle) * 0.5,
        0.8
    )
end

-- Draw light overlays (for visual debugging without shader)
function HDRenderPipeline.drawLightOverlays()
    if not initialized or not enabled then return end

    for id, light in pairs(pointLights) do
        -- Draw radial gradient light
        love.graphics.setColor(light.color[1], light.color[2], light.color[3], 0.3 * light.intensity)
        love.graphics.circle("fill", light.x, light.y, light.radius)
    end

    love.graphics.setColor(1, 1, 1, 1)
end

-- Get debug info
function HDRenderPipeline.getInfo()
    local shaderCount = 0
    for _ in pairs(shaders) do shaderCount = shaderCount + 1 end

    return {
        enabled = enabled,
        canvasSize = { canvasWidth, canvasHeight },
        shaderCount = shaderCount,
        lightCount = HDRenderPipeline.getLightCount(),
        normalMapAvailable = NormalMapGenerator.getNormalMap() ~= nil,
    }
end

-- Auto-detect light sources from game objects
function HDRenderPipeline.autoDetectLights()
    if not _G.state or not _G.state.gameObjectList then return end

    HDRenderPipeline.clearLights()

    for _, obj in ipairs(_G.state.gameObjectList) do
        if obj.class and obj.class.name and obj.gx and obj.gy then
            local name = obj.class.name

            -- Convert world to screen position
            local screenX, screenY
            if _G.IsoToScreenX and _G.IsoToScreenY then
                screenX = _G.IsoToScreenX(obj.gx, obj.gy) - (_G.state.viewXview or 0)
                screenY = _G.IsoToScreenY(obj.gx, obj.gy) - (_G.state.viewYview or 0)
            else
                screenX = obj.gx * 32
                screenY = obj.gy * 32
            end

            -- Buildings with fire/light
            if name == "Campfire" then
                HDRenderPipeline.addLight("obj_" .. tostring(obj), screenX, screenY, 80, { 1.0, 0.6, 0.2 }, 0.9)
            elseif name == "Bakery" or name == "Brewery" then
                HDRenderPipeline.addLight("obj_" .. tostring(obj), screenX, screenY, 60, { 1.0, 0.7, 0.3 }, 0.7)
            elseif name == "Inn" then
                HDRenderPipeline.addLight("obj_" .. tostring(obj), screenX, screenY, 70, { 1.0, 0.8, 0.5 }, 0.6)
            elseif name == "Chapel" or name == "Church" or name == "Cathedral" then
                local timeOfDay = HDShaders.getParam("dynamic_lighting", "timeOfDay") or 0.5
                if timeOfDay < 0.2 or timeOfDay > 0.8 then
                    HDRenderPipeline.addLight("obj_" .. tostring(obj), screenX, screenY, 100, { 0.9, 0.85, 0.6 }, 0.5)
                end
            end
        end
    end
end

return HDRenderPipeline
