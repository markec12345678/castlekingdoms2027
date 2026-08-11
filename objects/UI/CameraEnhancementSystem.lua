-- objects/UI/CameraEnhancementSystem.lua
-- Castle Kingdoms 2027 v2.8.9 - Camera Enhancement System
--
-- Advanced camera controls with smooth scrolling, zoom levels,
-- cinematic modes, and saved positions for quick navigation.
--
-- Features:
-- - Smooth camera movement (lerp-based)
-- - 5 zoom levels with mouse wheel support
-- - Cinematic camera mode (slow pan, dramatic zoom)
-- - Saved camera positions (quick jump to key locations)
-- - Edge scrolling with configurable speed
-- - Focus follow (camera follows selected unit)
-- - Screenshot mode (clean UI-free view)

local CameraEnhanced = {}

local initialized = false
local currentZoom = 1.0
local targetZoom = 1.0
local targetX = 0
local targetY = 0
local smoothing = 0.15  -- lerp factor (0=instant, 1=very slow)
local edgeScrollEnabled = true
local edgeScrollSpeed = 400
local edgeScrollMargin = 5
local focusUnit = nil
local cinematicMode = false
local cinematicProgress = 0
local cinematicDuration = 10
local cinematicPath = {}
local screenshotMode = false
local savedPositions = {}
local maxSavedPositions = 10

-- Zoom levels
local ZOOM_LEVELS = {
    { label = "Very Close",  zoom = 2.5 },
    { label = "Close",       zoom = 2.0 },
    { label = "Normal",      zoom = 1.5 },
    { label = "Far",         zoom = 1.0 },
    { label = "Very Far",    zoom = 0.7 },
}

CameraEnhanced.ZOOM_LEVELS = ZOOM_LEVELS
local currentZoomIndex = 3  -- default Normal

function CameraEnhanced.init()
    if initialized then return end
    initialized = true
    print("[CameraEnhanced] Initialized")
end

-- Set camera target position (smooth movement)
function CameraEnhanced.setTarget(x, y)
    targetX = x
    targetY = y
end

-- Instant jump to position
function CameraEnhanced.jumpTo(x, y)
    targetX = x
    targetY = y
    if _G.state then
        _G.state.viewXview = x
        _G.state.viewYview = y
    end
end

-- Zoom to specific level
function CameraEnhanced.setZoom(zoom)
    targetZoom = math.max(0.5, math.min(3.0, zoom))
end

-- Cycle zoom levels
function CameraEnhanced.cycleZoom()
    currentZoomIndex = (currentZoomIndex % #ZOOM_LEVELS) + 1
    targetZoom = ZOOM_LEVELS[currentZoomIndex].zoom
    if _G.ModernUI then
        _G.ModernUI.notifyInfo("Zoom: " .. ZOOM_LEVELS[currentZoomIndex].label)
    end
    return targetZoom
end

-- Zoom in/out by step
function CameraEnhanced.zoomIn(step)
    step = step or 0.25
    targetZoom = math.min(3.0, targetZoom + step)
    -- Update zoom index
    for i, level in ipairs(ZOOM_LEVELS) do
        if math.abs(level.zoom - targetZoom) < 0.1 then
            currentZoomIndex = i
            break
        end
    end
end

function CameraEnhanced.zoomOut(step)
    step = step or 0.25
    targetZoom = math.max(0.5, targetZoom - step)
    for i, level in ipairs(ZOOM_LEVELS) do
        if math.abs(level.zoom - targetZoom) < 0.1 then
            currentZoomIndex = i
            break
        end
    end
end

-- Mouse wheel zoom
function CameraEnhanced.wheelmoved(y)
    if y > 0 then
        CameraEnhanced.zoomIn()
    elseif y < 0 then
        CameraEnhanced.zoomOut()
    end
end

-- Save current camera position
function CameraEnhanced.savePosition(label)
    if not _G.state then return false end
    local pos = {
        x = _G.state.viewXview or 0,
        y = _G.state.viewYview or 0,
        zoom = currentZoom,
        label = label or ("Pozicija " .. (#savedPositions + 1)),
        timestamp = os.time(),
    }
    table.insert(savedPositions, pos)
    if #savedPositions > maxSavedPositions then
        table.remove(savedPositions, 1)
    end
    if _G.ModernUI then
        _G.ModernUI.notifySuccess("Kamera shranjena: " .. pos.label)
    end
    return true
end

-- Jump to saved position
function CameraEnhanced.jumpToSaved(index)
    if not savedPositions[index] then return false end
    local pos = savedPositions[index]
    CameraEnhanced.setTarget(pos.x, pos.y)
    targetZoom = pos.zoom
    if _G.ModernUI then
        _G.ModernUI.notifyInfo("Kamera: " .. pos.label)
    end
    return true
end

-- Focus on a unit (camera follows)
function CameraEnhanced.focusUnit(unit)
    focusUnit = unit
    if unit and _G.ModernUI then
        _G.ModernUI.notifyInfo("Kamera sledi enoti")
    end
end

-- Clear focus
function CameraEnhanced.clearFocus()
    focusUnit = nil
end

-- Center on keep
function CameraEnhanced.centerOnKeep()
    if not _G.state or not _G.state.keepX then return false end
    local sx = _G.IsoToScreenX(_G.state.keepX, _G.state.keepY)
    local sy = _G.IsoToScreenY(_G.state.keepX, _G.state.keepY)
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    CameraEnhanced.setTarget(sx - screenWidth / 2, sy - screenHeight / 2)
    if _G.ModernUI then
        _G.ModernUI.notifyInfo("Kamera: center na gradu")
    end
    return true
end

-- Center on granary
function CameraEnhanced.centerOnGranary()
    if not _G.state or not _G.state.granaryX then return false end
    local sx = _G.IsoToScreenX(_G.state.granaryX, _G.state.granaryY)
    local sy = _G.IsoToScreenY(_G.state.granaryX, _G.state.granaryY)
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    CameraEnhanced.setTarget(sx - screenWidth / 2, sy - screenHeight / 2)
    return true
end

-- Start cinematic mode
function CameraEnhanced.startCinematic(duration)
    cinematicMode = true
    cinematicProgress = 0
    cinematicDuration = duration or 10
    -- Build a cinematic path around the keep
    cinematicPath = {}
    if _G.state and _G.state.keepX then
        local kx, ky = _G.state.keepX, _G.state.keepY
        local radius = 30
        local steps = 8
        for i = 0, steps do
            local angle = (i / steps) * math.pi * 2
            local gx = kx + math.cos(angle) * radius
            local gy = ky + math.sin(angle) * radius
            local sx = _G.IsoToScreenX(gx, gy)
            local sy = _G.IsoToScreenY(gx, gy)
            table.insert(cinematicPath, { x = sx, y = sy, zoom = 1.5 + math.sin(angle) * 0.5 })
        end
    end
    if _G.ModernUI then
        _G.ModernUI.notifySuccess("Cinematic način začet (" .. cinematicDuration .. "s)")
    end
    -- Hide UI for cinematic
    screenshotMode = true
    return true
end

-- Stop cinematic
function CameraEnhanced.stopCinematic()
    cinematicMode = false
    screenshotMode = false
    if _G.ModernUI then
        _G.ModernUI.notifyInfo("Cinematic način končan")
    end
end

-- Toggle screenshot mode (hide UI)
function CameraEnhanced.toggleScreenshotMode()
    screenshotMode = not screenshotMode
    if _G.ModernUI then
        _G.ModernUI.notifyInfo(screenshotMode and "Screenshot način: UI skrit" or "Screenshot način: UI vidni")
    end
    return screenshotMode
end

-- Edge scrolling
function CameraEnhanced._updateEdgeScroll(dt)
    if not edgeScrollEnabled then return end
    if cinematicMode then return end
    local mx, my = love.mouse.getPosition()
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    local scrollX = 0
    local scrollY = 0

    if mx < edgeScrollMargin then scrollX = -edgeScrollSpeed * dt
    elseif mx > screenWidth - edgeScrollMargin then scrollX = edgeScrollSpeed * dt end
    if my < edgeScrollMargin then scrollY = -edgeScrollSpeed * dt
    elseif my > screenHeight - edgeScrollMargin then scrollY = edgeScrollSpeed * dt end

    if scrollX ~= 0 or scrollY ~= 0 then
        targetX = (targetX or 0) + scrollX
        targetY = (targetY or 0) + scrollY
    end
end

-- Update camera smoothing
function CameraEnhanced.update(dt)
    if not initialized then return end
    if not _G.state then return end

    -- Cinematic mode
    if cinematicMode then
        cinematicProgress = cinematicProgress + dt
        if cinematicProgress >= cinematicDuration or #cinematicPath == 0 then
            CameraEnhanced.stopCinematic()
        else
            local progress = cinematicProgress / cinematicDuration
            local pathIdx = math.floor(progress * #cinematicPath) + 1
            pathIdx = math.min(pathIdx, #cinematicPath)
            local point = cinematicPath[pathIdx]
            if point then
                local screenWidth = love.graphics.getWidth()
                local screenHeight = love.graphics.getHeight()
                targetX = point.x - screenWidth / 2
                targetY = point.y - screenHeight / 2
                targetZoom = point.zoom
            end
        end
    else
        -- Edge scrolling
        CameraEnhanced._updateEdgeScroll(dt)

        -- Focus follow
        if focusUnit and focusUnit.gx and focusUnit.gy then
            local sx = _G.IsoToScreenX(focusUnit.gx, focusUnit.gy)
            local sy = _G.IsoToScreenY(focusUnit.gx, focusUnit.gy)
            local screenWidth = love.graphics.getWidth()
            local screenHeight = love.graphics.getHeight()
            targetX = sx - screenWidth / 2
            targetY = sy - screenHeight / 2
        end
    end

    -- Smooth camera position (lerp)
    local currentX = _G.state.viewXview or 0
    local currentY = _G.state.viewYview or 0
    local newX = currentX + (targetX - currentX) * smoothing
    local newY = currentY + (targetY - currentY) * smoothing
    _G.state.viewXview = newX
    _G.state.viewYview = newY

    -- Smooth zoom (lerp)
    currentZoom = currentZoom + (targetZoom - currentZoom) * smoothing
    if _G.state.scaleX then
        _G.state.scaleX = currentZoom
    end
end

-- Get stats
function CameraEnhanced.getStats()
    return {
        zoom = currentZoom,
        targetZoom = targetZoom,
        zoomLabel = ZOOM_LEVELS[currentZoomIndex].label,
        smoothing = smoothing,
        edgeScroll = edgeScrollEnabled,
        focusUnit = focusUnit ~= nil,
        cinematicMode = cinematicMode,
        cinematicProgress = cinematicMode and (cinematicProgress / cinematicDuration * 100) or 0,
        screenshotMode = screenshotMode,
        savedPositions = #savedPositions,
    }
end

-- Get saved positions
function CameraEnhanced.getSavedPositions()
    return savedPositions
end

-- Set smoothing
function CameraEnhanced.setSmoothing(value)
    smoothing = math.max(0.01, math.min(1.0, value))
end

-- Toggle edge scroll
function CameraEnhanced.toggleEdgeScroll()
    edgeScrollEnabled = not edgeScrollEnabled
    if _G.ModernUI then
        _G.ModernUI.notifyInfo("Edge scroll: " .. (edgeScrollEnabled and "ON" or "OFF"))
    end
    return edgeScrollEnabled
end

-- Is screenshot mode active (for other systems to hide UI)
function CameraEnhanced.isScreenshotMode()
    return screenshotMode
end

return CameraEnhanced
