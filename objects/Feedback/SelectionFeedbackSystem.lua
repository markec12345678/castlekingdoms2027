-- objects/Feedback/SelectionFeedbackSystem.lua
-- Stronghold 2027 - Unit Selection Visual Feedback
--
-- Provides visual feedback for selected units:
-- - Glowing ring under selected units
-- - Health bar always visible for selected units
-- - Selection rectangle visual
-- - Hover highlight on units
-- - Group selection count
--
-- Usage:
--   local Selection = require("objects.Feedback.SelectionFeedbackSystem")
--   Selection.init()
--   Selection.update(dt)
--   Selection.draw()

local SelectionFeedbackSystem = {}

local initialized = false
local enabled = true

-- Selection box (for drag-select)
local selectionBox = {
    active = false,
    startX = 0,
    startY = 0,
    endX = 0,
    endY = 0,
}

-- Animation state
local animTime = 0

-- Configuration
local config = {
    -- Selection ring
    ringColor = { 0.3, 0.8, 1.0, 0.8 },      -- cyan
    ringColorHover = { 1.0, 1.0, 0.3, 0.5 }, -- yellow
    ringRadius = 25,
    ringWidth = 2,

    -- Selection box
    boxColor = { 0.3, 0.8, 1.0, 0.3 },       -- cyan fill
    boxBorderColor = { 0.3, 0.8, 1.0, 0.8 }, -- cyan border
    boxBorderWidth = 2,

    -- Pulse animation
    pulseSpeed = 3.0,
    pulseAmount = 0.2,  -- 20% size variation

    -- Group count
    countColor = { 1, 1, 1, 1 },
    countBgColor = { 0, 0, 0, 0.7 },
}

-- Initialize
function SelectionFeedbackSystem.init()
    if initialized then return end
    initialized = true
    print("[SelectionFeedback] Initialized")
end

function SelectionFeedbackSystem.setEnabled(state)
    enabled = state
end

-- Start selection box (on mouse down)
function SelectionFeedbackSystem.startBox(x, y)
    selectionBox.active = true
    selectionBox.startX = x
    selectionBox.startY = y
    selectionBox.endX = x
    selectionBox.endY = y
end

-- Update selection box (on mouse drag)
function SelectionFeedbackSystem.updateBox(x, y)
    if not selectionBox.active then return end
    selectionBox.endX = x
    selectionBox.endY = y
end

-- End selection box (on mouse up)
function SelectionFeedbackSystem.endBox()
    selectionBox.active = false
end

-- Is selection box active?
function SelectionFeedbackSystem.isBoxActive()
    return selectionBox.active
end

-- Get selection box rectangle
function SelectionFeedbackSystem.getBoxRect()
    if not selectionBox.active then return nil end
    return {
        x = math.min(selectionBox.startX, selectionBox.endX),
        y = math.min(selectionBox.startY, selectionBox.endY),
        w = math.abs(selectionBox.endX - selectionBox.startX),
        h = math.abs(selectionBox.endY - selectionBox.startY),
    }
end

-- Update animation
function SelectionFeedbackSystem.update(dt)
    if not enabled then return end
    animTime = animTime + dt
end

-- Draw selection feedback
function SelectionFeedbackSystem.draw()
    if not enabled then return end
    if not _G.state or not _G.state.gameObjectList then return end

    -- Draw selection rings for selected units
    if _G.Commander and _G.Commander.selectedUnits then
        for _, unit in ipairs(_G.Commander.selectedUnits) do
            if unit and not unit.toBeDeleted and unit.gx and unit.gy then
                SelectionFeedbackSystem.drawSelectionRing(unit)
            end
        end
    end

    -- Draw hover ring for unit under mouse
    SelectionFeedbackSystem.drawHoverRing()

    -- Draw selection box
    if selectionBox.active then
        SelectionFeedbackSystem.drawSelectionBox()
    end
end

-- Draw selection ring under a unit
function SelectionFeedbackSystem.drawSelectionRing(unit)
    -- Convert world to screen (isometric)
    local screenX = unit.gx * 32 - unit.gy * 32
    local screenY = (unit.gx + unit.gy) * 16

    -- Apply camera offset
    if _G.state.viewXview then
        screenX = screenX - _G.state.viewXview
    end
    if _G.state.viewYview then
        screenY = screenY - _G.state.viewYview
    end

    -- Apply scale
    local scale = _G.state.scaleX or 1
    screenX = screenX * scale
    screenY = screenY * scale

    -- Pulsing effect
    local pulse = 1 + math.sin(animTime * config.pulseSpeed) * config.pulseAmount
    local radius = config.ringRadius * scale * pulse

    -- Draw outer ring (glow)
    love.graphics.setColor(config.ringColor[1], config.ringColor[2], config.ringColor[3], config.ringColor[4] * 0.3)
    love.graphics.setLineWidth(config.ringWidth * 3)
    love.graphics.circle("line", screenX, screenY + 10, radius)

    -- Draw inner ring (solid)
    love.graphics.setColor(config.ringColor[1], config.ringColor[2], config.ringColor[3], config.ringColor[4])
    love.graphics.setLineWidth(config.ringWidth)
    love.graphics.circle("line", screenX, screenY + 10, radius)

    -- Draw direction indicator (small triangle pointing in movement direction)
    if unit.moveDir and unit.moveDir ~= "none" then
        local angle = 0
        if unit.moveDir == "north" then angle = -math.pi / 2
        elseif unit.moveDir == "south" then angle = math.pi / 2
        elseif unit.moveDir == "east" then angle = 0
        elseif unit.moveDir == "west" then angle = math.pi
        elseif unit.moveDir == "northeast" then angle = -math.pi / 4
        elseif unit.moveDir == "northwest" then angle = -3 * math.pi / 4
        elseif unit.moveDir == "southeast" then angle = math.pi / 4
        elseif unit.moveDir == "southwest" then angle = 3 * math.pi / 4
        end

        local indicatorX = screenX + math.cos(angle) * radius
        local indicatorY = screenY + 10 + math.sin(angle) * radius

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.circle("fill", indicatorX, indicatorY, 3 * scale)
    end

    love.graphics.setColor(1, 1, 1, 1)
end

-- Draw hover ring for unit under mouse
function SelectionFeedbackSystem.drawHoverRing()
    -- Get mouse position
    local mouseX, mouseY = love.mouse.getPosition()

    -- Stronghold 2027: Skip hover ring when mouse is over UI (action bar, top UI)
    local screenH = love.graphics.getHeight()
    if mouseY > screenH - 150 or mouseY < 80 then
        return  -- Mouse is over UI, don't draw hover ring
    end
    -- Also skip when any UI panel is open
    if _G.DynamicMarketUI and _G.DynamicMarketUI.isVisible and _G.DynamicMarketUI.isVisible() then return end
    if _G.CaravanUI and _G.CaravanUI.isVisible and _G.CaravanUI.isVisible() then return end
    if _G.GameFeelSettings and _G.GameFeelSettings.isVisible and _G.GameFeelSettings.isVisible() then return end

    -- Find unit under mouse (simplified)
    if not _G.state or not _G.state.gameObjectList then return end

    for _, unit in ipairs(_G.state.gameObjectList) do
        if unit and not unit.toBeDeleted and unit.gx and unit.gy then
            -- Convert to screen
            local screenX = unit.gx * 32 - unit.gy * 32
            local screenY = (unit.gx + unit.gy) * 16

            if _G.state.viewXview then
                screenX = screenX - _G.state.viewXview
            end
            if _G.state.viewYview then
                screenY = screenY - _G.state.viewYview
            end

            local scale = _G.state.scaleX or 1
            screenX = screenX * scale
            screenY = screenY * scale

            -- Check if mouse is near unit
            local dx = mouseX - screenX
            local dy = mouseY - (screenY + 10)
            local distSq = dx * dx + dy * dy
            local hoverRadius = config.ringRadius * scale

            if distSq < hoverRadius * hoverRadius then
                -- Check if already selected
                local isSelected = false
                if _G.Commander and _G.Commander.selectedUnits then
                    for _, sel in ipairs(_G.Commander.selectedUnits) do
                        if sel == unit then
                            isSelected = true
                            break
                        end
                    end
                end

                -- Only draw hover ring if not already selected
                if not isSelected then
                    love.graphics.setColor(config.ringColorHover[1], config.ringColorHover[2],
                                          config.ringColorHover[3], config.ringColorHover[4])
                    love.graphics.setLineWidth(1.5)
                    love.graphics.circle("line", screenX, screenY + 10, hoverRadius)
                    love.graphics.setColor(1, 1, 1, 1)
                end
                return  -- only one unit can be hovered
            end
        end
    end
end

-- Draw selection box (drag-select rectangle)
function SelectionFeedbackSystem.drawSelectionBox()
    local rect = SelectionFeedbackSystem.getBoxRect()
    if not rect or rect.w < 2 or rect.h < 2 then return end

    -- Fill
    love.graphics.setColor(config.boxColor[1], config.boxColor[2], config.boxColor[3], config.boxColor[4])
    love.graphics.rectangle("fill", rect.x, rect.y, rect.w, rect.h)

    -- Border
    love.graphics.setColor(config.boxBorderColor[1], config.boxBorderColor[2],
                          config.boxBorderColor[3], config.boxBorderColor[4])
    love.graphics.setLineWidth(config.boxBorderWidth)
    love.graphics.rectangle("line", rect.x, rect.y, rect.w, rect.h)

    -- Corner indicators
    local cornerSize = 8
    love.graphics.setColor(1, 1, 1, 1)
    -- Top-left
    love.graphics.line(rect.x, rect.y, rect.x + cornerSize, rect.y)
    love.graphics.line(rect.x, rect.y, rect.x, rect.y + cornerSize)
    -- Top-right
    love.graphics.line(rect.x + rect.w, rect.y, rect.x + rect.w - cornerSize, rect.y)
    love.graphics.line(rect.x + rect.w, rect.y, rect.x + rect.w, rect.y + cornerSize)
    -- Bottom-left
    love.graphics.line(rect.x, rect.y + rect.h, rect.x + cornerSize, rect.y + rect.h)
    love.graphics.line(rect.x, rect.y + rect.h, rect.x, rect.y + rect.h - cornerSize)
    -- Bottom-right
    love.graphics.line(rect.x + rect.w, rect.y + rect.h, rect.x + rect.w - cornerSize, rect.y + rect.h)
    love.graphics.line(rect.x + rect.w, rect.y + rect.h, rect.x + rect.w, rect.y + rect.h - cornerSize)

    love.graphics.setColor(1, 1, 1, 1)
end

-- Get info for debug
function SelectionFeedbackSystem.getInfo()
    local selectedCount = 0
    if _G.Commander and _G.Commander.selectedUnits then
        selectedCount = #_G.Commander.selectedUnits
    end
    return {
        enabled = enabled,
        selectedCount = selectedCount,
        boxActive = selectionBox.active,
    }
end

return SelectionFeedbackSystem
