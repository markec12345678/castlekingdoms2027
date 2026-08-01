-- objects/Config/KenneySpriteRenderer.lua
-- Stronghold 2027 - Kenney CC0 Sprite Renderer
--
-- Hooks into the existing rendering pipeline to replace Firefly sprites
-- with Kenney CC0 sprites when useKenneyAssets is enabled.
--
-- This module provides drop-in replacement functions for:
-- - Building rendering (BuildController)
-- - Unit rendering (Unit class)
-- - UI icon rendering (ActionBarButton)
-- - Health bar rendering
--
-- When KenneyAssetLoader.isEnabled() is false, all functions fall through
-- to the original rendering code (no changes to existing behavior).

local KenneyAssetLoader = require("objects.Config.KenneyAssetLoader")

local KenneySpriteRenderer = {}

-- === BUILDING RENDERING ===

-- Draw a building using Kenney CC0 sprite
-- Call this instead of the original sprite batch draw when Kenney is enabled
-- @param buildingName string Our building name (e.g., "Barracks")
-- @param x number Screen X position
-- @param y number Screen Y position
-- @param scaleX number Scale X (default 1.0)
-- @param scaleY number Scale Y (default 1.0)
-- @return boolean true if drawn with Kenney, false if should use original
function KenneySpriteRenderer.drawBuilding(buildingName, x, y, scaleX, scaleY)
    if not KenneyAssetLoader.isEnabled() then return false end

    local image = KenneyAssetLoader.getBuildingImage(buildingName)
    if not image then return false end

    scaleX = scaleX or 1.0
    scaleY = scaleY or 1.0

    -- Kenney images are 64x64, we need to scale them to match game tile size
    -- Our tile size is typically 64x32 (isometric), so we scale to fit
    local imgW, imgH = image:getDimensions()
    local targetW = _G.tileWidth or 64
    local targetH = _G.tileHeight or 32

    -- Scale to fit tile width, maintain aspect ratio
    local scale = targetW / imgW
    local offsetX = -(imgW * scale) / 2
    local offsetY = -(imgH * scale) + targetH / 2

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(image, x + offsetX, y + offsetY, 0, scale * scaleX, scale * scaleY)
    return true
end

-- === UNIT RENDERING ===

-- Draw a unit using Kenney CC0 sprite
-- @param unitName string Our unit name (e.g., "Archer")
-- @param x number Screen X
-- @param y number Screen Y
-- @param direction string Movement direction (for future directional sprites)
-- @return boolean true if drawn, false if use original
function KenneySpriteRenderer.drawUnit(unitName, x, y, direction)
    if not KenneyAssetLoader.isEnabled() then return false end

    local image = KenneyAssetLoader.getUnitImage(unitName)
    if not image then return false end

    -- Kenney unit images are 64x64, scale to game unit size
    local imgW, imgH = image:getDimensions()
    local scale = 0.5  -- Scale down to match unit size (~32px)

    local offsetX = -(imgW * scale) / 2
    local offsetY = -(imgH * scale) / 2

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(image, x + offsetX, y + offsetY, 0, scale, scale)
    return true
end

-- === FORTIFICATION RENDERING ===

-- Draw a fortification (wall, tower, gate) using Kenney Castle Kit
-- @param fortName string Our fortification name
-- @param x number Screen X
-- @param y number Screen Y
-- @return boolean true if drawn, false if use original
function KenneySpriteRenderer.drawFortification(fortName, x, y)
    if not KenneyAssetLoader.isEnabled() then return false end

    local image = KenneyAssetLoader.getFortificationImage(fortName)
    if not image then return false end

    local imgW, imgH = image:getDimensions()
    local scale = 0.5

    local offsetX = -(imgW * scale) / 2
    local offsetY = -(imgH * scale) / 2

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(image, x + offsetX, y + offsetY, 0, scale, scale)
    return true
end

-- === UI ICON RENDERING ===

-- Draw a building icon for the action bar
-- @param buildingName string Building name
-- @param x number Screen X (center)
-- @param y number Screen Y (center)
-- @param size number Target size (width = height)
-- @return boolean true if drawn, false if use original
function KenneySpriteRenderer.drawBuildingIcon(buildingName, x, y, size)
    if not KenneyAssetLoader.isEnabled() then return false end

    local image = KenneyAssetLoader.getBuildingIcon(buildingName)
    if not image then return false end

    size = size or 48
    local imgW, imgH = image:getDimensions()
    local scale = size / math.max(imgW, imgH)

    local offsetX = -(imgW * scale) / 2
    local offsetY = -(imgH * scale) / 2

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(image, x + offsetX, y + offsetY, 0, scale, scale)
    return true
end

-- Draw a unit icon for recruitment UI
-- @param unitName string Unit name
-- @param x number Screen X (center)
-- @param y number Screen Y (center)
-- @param size number Target size
-- @return boolean true if drawn, false if use original
function KenneySpriteRenderer.drawUnitIcon(unitName, x, y, size)
    if not KenneyAssetLoader.isEnabled() then return false end

    local image = KenneyAssetLoader.getUnitIcon(unitName)
    if not image then return false end

    size = size or 48
    local imgW, imgH = image:getDimensions()
    local scale = size / math.max(imgW, imgH)

    local offsetX = -(imgW * scale) / 2
    local offsetY = -(imgH * scale) / 2

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(image, x + offsetX, y + offsetY, 0, scale, scale)
    return true
end

-- Draw a resource icon
-- @param resourceName string Resource name (wood, stone, gold, etc.)
-- @param x number Screen X (center)
-- @param y number Screen Y (center)
-- @param size number Target size
-- @return boolean true if drawn, false if use original
function KenneySpriteRenderer.drawResourceIcon(resourceName, x, y, size)
    if not KenneyAssetLoader.isEnabled() then return false end

    local image = KenneyAssetLoader.getResourceIcon(resourceName)
    if not image then return false end

    size = size or 24
    local imgW, imgH = image:getDimensions()
    local scale = size / math.max(imgW, imgH)

    local offsetX = -(imgW * scale) / 2
    local offsetY = -(imgH * scale) / 2

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(image, x + offsetX, y + offsetY, 0, scale, scale)
    return true
end

-- === BUILD PREVIEW RENDERING ===

-- Draw a building preview (ghost building) using Kenney sprite
-- @param buildingName string Building name
-- @param x number Screen X
-- @param y number Screen Y
-- @param valid boolean Is the placement valid?
-- @return boolean true if drawn, false if use original
function KenneySpriteRenderer.drawBuildPreview(buildingName, x, y, valid)
    if not KenneyAssetLoader.isEnabled() then return false end

    local image = KenneyAssetLoader.getBuildingImage(buildingName)
    if not image then return false end

    local imgW, imgH = image:getDimensions()
    local targetW = _G.tileWidth or 64
    local scale = targetW / imgW
    local offsetX = -(imgW * scale) / 2
    local offsetY = -(imgH * scale) + (_G.tileHeight or 32) / 2

    -- Green tint if valid, red if invalid
    if valid then
        love.graphics.setColor(0.3, 1.0, 0.3, 0.6)
    else
        love.graphics.setColor(1.0, 0.3, 0.3, 0.6)
    end

    love.graphics.draw(image, x + offsetX, y + offsetY, 0, scale, scale)
    love.graphics.setColor(1, 1, 1, 1)
    return true
end

-- === COMBAT OVERLAY RENDERING ===

-- Draw health bar using Kenney-style clean design
-- @param unit table The unit
-- @param x number Screen X (center of unit)
-- @param y number Screen Y (top of unit)
-- @return boolean true if drawn, false if use original
function KenneySpriteRenderer.drawHealthBar(unit, x, y)
    if not KenneyAssetLoader.isEnabled() then return false end
    if not unit or not unit.health or not unit.maxHealth then return false end

    local barWidth = 40
    local barHeight = 5
    local barX = x - barWidth / 2
    local barY = y - 50  -- above unit

    local healthPercent = math.max(0, math.min(1, unit.health / unit.maxHealth))

    -- Background
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", barX - 1, barY - 1, barWidth + 2, barHeight + 2)

    -- Health bar
    local r, g, b
    if healthPercent > 0.6 then
        r, g, b = 0.2, 0.8, 0.2
    elseif healthPercent > 0.3 then
        r, g, b = 0.9, 0.8, 0.2
    else
        r, g, b = 0.9, 0.2, 0.2
    end

    love.graphics.setColor(r, g, b, 1)
    love.graphics.rectangle("fill", barX, barY, barWidth * healthPercent, barHeight)

    -- Border
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", barX, barY, barWidth, barHeight)

    love.graphics.setColor(1, 1, 1, 1)
    return true
end

-- === BATCH RENDERING ===

-- Check if we should use Kenney rendering for buildings
-- This allows BuildController to skip the original sprite batch entirely
-- @return boolean true if Kenney is active
function KenneySpriteRenderer.isActive()
    return KenneyAssetLoader.isEnabled()
end

-- Get a list of all building names that have Kenney sprites available
function KenneySpriteRenderer.getAvailableBuildings()
    if not KenneyAssetLoader.isEnabled() then return {} end

    local KenneyAssetMapping = require("objects.Config.KenneyAssetMapping")
    local available = {}
    for name, _ in pairs(KenneyAssetMapping.buildings) do
        local image = KenneyAssetLoader.getBuildingImage(name)
        if image then
            table.insert(available, name)
        end
    end
    return available
end

-- Get stats
function KenneySpriteRenderer.getStats()
    return {
        active = KenneySpriteRenderer.isActive(),
        availableBuildings = #KenneySpriteRenderer.getAvailableBuildings(),
        loaderStats = KenneyAssetLoader.getStats(),
    }
end

return KenneySpriteRenderer
