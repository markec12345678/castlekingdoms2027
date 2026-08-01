-- objects/Feedback/BuildPreviewSystem.lua
-- Stronghold 2027 - Build Placement Preview
--
-- Shows a ghost/preview of the building before placement:
-- - Green tint if valid location
-- - Red tint if invalid (obstacle, water, etc.)
-- - Shows building footprint
-- - Shows resource cost
-- - Snaps to grid
--
-- Usage:
--   local BuildPreview = require("objects.Feedback.BuildPreviewSystem")
--   BuildPreview.init()
--   BuildPreview.setBuilding("WoodcutterHut", image, cost)
--   BuildPreview.update(dt)
--   BuildPreview.draw()

local BuildPreviewSystem = {}

local initialized = false
local enabled = true

-- Current preview state
local preview = {
    active = false,
    buildingName = nil,
    image = nil,
    cost = nil,
    gx = 0,
    gy = 0,
    valid = false,
    snapToGrid = true,
}

-- Visual settings
local config = {
    validColor = { 0.3, 1.0, 0.3, 0.5 },     -- green
    invalidColor = { 1.0, 0.3, 0.3, 0.5 },   -- red
    borderColor = { 1.0, 1.0, 1.0, 0.8 },
    footprintColor = { 0.5, 0.7, 1.0, 0.3 }, -- blue
    costTextColor = { 1.0, 0.9, 0.5, 1.0 },  -- gold
    tileSize = 32,  -- isometric tile size
}

-- Initialize
function BuildPreviewSystem.init()
    if initialized then return end
    initialized = true
    print("[BuildPreview] Initialized")
end

function BuildPreviewSystem.setEnabled(state)
    enabled = state
end

-- Set the building to preview
-- @param name string Building name (e.g., "WoodcutterHut")
-- @param image Image The building's image
-- @param cost table { wood = N, stone = N, gold = N }
function BuildPreviewSystem.setBuilding(name, image, cost)
    preview.active = true
    preview.buildingName = name
    preview.image = image
    preview.cost = cost
end

-- Clear the preview
function BuildPreviewSystem.clear()
    preview.active = false
    preview.buildingName = nil
    preview.image = nil
    preview.cost = nil
    preview.valid = false
end

-- Check if preview is active
function BuildPreviewSystem.isActive()
    return preview.active and enabled
end

-- Update preview position based on mouse
function BuildPreviewSystem.update(dt)
    if not enabled or not preview.active then return end

    -- Stronghold 2027: Skip preview when mouse is over UI
    local mx, my = love.mouse.getPosition()
    local screenH = love.graphics.getHeight()
    if my > screenH - 150 then
        -- Mouse is over action bar, don't update preview position
        return
    end

    -- Get mouse position and convert to world coords
    if _G.getTerrainTileOnMouse then
        local gx, gy = _G.getTerrainTileOnMouse(love.mouse.getPosition())
        if gx and gy then
            preview.gx = gx
            preview.gy = gy
            preview.valid = BuildPreviewSystem.isValidLocation(gx, gy)
        end
    end
end

-- Check if a location is valid for building
function BuildPreviewSystem.isValidLocation(gx, gy)
    -- Check map bounds
    if not _G.state or not _G.state.map then return false end
    if gx < 0 or gy < 0 then return false end

    -- Check if walkable (no obstacles)
    if _G.state.map.isWalkable and not _G.state.map:isWalkable(gx, gy) then
        return false
    end

    -- Check if there's already a building there
    if _G.objectFromSubclassAtGlobal then
        local existing = _G.objectFromSubclassAtGlobal(gx, gy, "Structure")
        if existing then return false end
    end

    -- Check if player can afford
    if preview.cost then
        local BalanceConfig = require("objects.Config.BalanceConfig")
        local buildingCost = BalanceConfig.buildings[preview.buildingName]
        if buildingCost then
            -- Check each resource (nil-safe)
            local gold = _G.state.gold or 0
            -- Note: wood/stone would come from stockpile, simplified here
            if buildingCost.gold and gold < buildingCost.gold then
                return false
            end
        end
    end

    return true
end

-- Draw the preview
function BuildPreviewSystem.draw()
    if not enabled or not preview.active then return end
    if not _G.state then return end

    local gx, gy = preview.gx, preview.gy

    -- Convert world to screen (isometric)
    local screenX = gx * config.tileSize - gy * config.tileSize
    local screenY = (gx + gy) * (config.tileSize / 2)

    -- Apply camera offset
    if _G.state.viewXview then
        screenX = screenX - _G.state.viewXview
    end
    if _G.state.viewYview then
        screenY = screenY - _G.state.viewYview
    end

    -- Determine color based on validity
    local color = preview.valid and config.validColor or config.invalidColor

    -- Draw footprint (tile outline)
    love.graphics.setColor(config.footprintColor)
    love.graphics.setLineWidth(2)
    -- Isometric diamond
    local diamondPoints = {
        screenX, screenY - config.tileSize / 2,  -- top
        screenX + config.tileSize, screenY,       -- right
        screenX, screenY + config.tileSize / 2,  -- bottom
        screenX - config.tileSize, screenY,       -- left
    }
    love.graphics.polygon("line", diamondPoints)

    -- Fill footprint with color
    love.graphics.setColor(color[1], color[2], color[3], color[4] * 0.5)
    love.graphics.polygon("fill", diamondPoints)

    -- Draw building image (if available)
    if preview.image then
        love.graphics.setColor(color[1], color[2], color[3], 0.7)
        local imgW = preview.image:getWidth()
        local imgH = preview.image:getHeight()
        love.graphics.draw(preview.image, screenX - imgW / 2, screenY - imgH / 2)
    end

    -- Draw border around footprint
    love.graphics.setColor(config.borderColor)
    love.graphics.setLineWidth(2)
    love.graphics.polygon("line", diamondPoints)

    -- Draw building name
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(preview.buildingName or "Building", screenX - 30, screenY - config.tileSize - 20)

    -- Draw cost (if available)
    if preview.cost then
        local costY = screenY - config.tileSize
        local costX = screenX - 40

        love.graphics.setColor(config.costTextColor)
        if preview.cost.wood then
            love.graphics.print("Wood: " .. preview.cost.wood, costX, costY)
            costY = costY + 15
        end
        if preview.cost.stone then
            love.graphics.print("Stone: " .. preview.cost.stone, costX, costY)
            costY = costY + 15
        end
        if preview.cost.gold then
            love.graphics.print("Gold: " .. preview.cost.gold, costX, costY)
        end
    end

    -- Draw validity indicator
    if not preview.valid then
        love.graphics.setColor(1, 0.3, 0.3, 1)
        love.graphics.print("✗ Invalid", screenX - 20, screenY + config.tileSize)
    else
        love.graphics.setColor(0.3, 1, 0.3, 1)
        love.graphics.print("✓ Valid", screenX - 20, screenY + config.tileSize)
    end

    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
end

-- Get current preview info
function BuildPreviewSystem.getInfo()
    return {
        active = preview.active,
        buildingName = preview.buildingName,
        gx = preview.gx,
        gy = preview.gy,
        valid = preview.valid,
        cost = preview.cost,
    }
end

-- Hook into BuildController
-- Call this when player selects a building to construct
function BuildPreviewSystem.onBuildingSelected(buildingName, image)
    local BalanceConfig = require("objects.Config.BalanceConfig")
    local cost = BalanceConfig.buildings[buildingName]
    BuildPreviewSystem.setBuilding(buildingName, image, cost)
end

-- Hook into BuildController
-- Call this when player cancels building or places it
function BuildPreviewSystem.onBuildingDeselected()
    BuildPreviewSystem.clear()
end

return BuildPreviewSystem
