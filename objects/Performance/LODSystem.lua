-- objects/Performance/LODSystem.lua
-- Castle Kingdoms 2027 v3.12.165 - Level of Detail System
--
-- Reduces CPU/GPU load when many units are on screen by:
--   * Skipping animation updates for far-away units
--   * Reducing update frequency for distant units (every 2nd, 3rd frame)
--   * Skipping particle effects for off-screen units
--   * Simplifying draw calls for tiny units (single sprite instead of animated)
--
-- LOD levels:
--   * LOD_HIGH (0-15 tiles from camera): full detail, every frame
--   * LOD_MED  (15-30 tiles): every 2nd frame, no particles
--   * LOD_LOW  (30-60 tiles): every 3rd frame, simplified animation
--   * LOD_OFF  (60+ tiles): no animation, no draw (off-screen)
--
-- Threshold scaling (auto-adapt to unit count):
--   * < 50 units: relax thresholds (everything LOD_HIGH)
--   * 50-100 units: standard thresholds
--   * 100-200 units: tighten thresholds (more LOD_MED/LOW)
--   * 200+ units: aggressive (skip more distant units)
--
-- Toggle debug visualization with Ctrl+Shift+O (off by default)
--
-- Public API:
--   LODSystem.update(dt)             - update LOD levels for all units
--   LODSystem.getLOD(unit)           - get current LOD level (0-3)
--   LODSystem.shouldUpdate(unit)     - should this unit be updated this frame?
--   LODSystem.shouldAnimate(unit)    - should this unit animate this frame?
--   LODSystem.shouldDraw(unit)       - should this unit be drawn?
--   LODSystem.getStats()             - debug info
--   LODSystem.toggle()               - toggle debug visualization

local LODSystem = {}

-- LOD levels (constants)
local LOD_HIGH = 0  -- Full detail
local LOD_MED  = 1  -- Reduced update rate
local LOD_LOW  = 2  -- Minimal updates
local LOD_OFF  = 3  -- Skip entirely

-- Per-unit LOD cache: unit → { level, lastUpdateFrame, lastAnimFrame }
local unitLOD = {}

-- Frame counter (incremented each update)
local frameCounter = 0

-- Debug visualization
local VISIBLE = false
local VISIBILITY_FILE = "lod_system_visible.txt"

-- Stats
local stats = {
    totalUnits = 0,
    byLOD = { [LOD_HIGH] = 0, [LOD_MED] = 0, [LOD_LOW] = 0, [LOD_OFF] = 0 },
    skippedUpdates = 0,
    skippedAnimations = 0,
    skippedDraws = 0,
}

-- ============================================================
-- Persistence
-- ============================================================

local function loadVisibility()
    local ok, content = pcall(love.filesystem.read, VISIBILITY_FILE)
    if ok and content then
        content = content:gsub("%s+$", "")
        if content == "1" or content == "true" then
            VISIBLE = true
        end
    end
end

local function saveVisibility()
    pcall(love.filesystem.write, VISIBILITY_FILE, VISIBLE and "1" or "0")
end

loadVisibility()

-- ============================================================
-- Auto-scaling thresholds based on unit count
-- ============================================================

-- Get current thresholds based on total unit count
-- Returns table with tile distances for each LOD level
local function getCurrentThresholds()
    if not _G.state or not _G.state.gameObjectList then
        return { high = 999, med = 999, low = 999 }  -- everything LOD_HIGH
    end

    local count = 0
    for _, unit in ipairs(_G.state.gameObjectList) do
        if unit and not unit.toBeDeleted and unit.health and unit.health > 0 then
            count = count + 1
        end
    end

    -- Auto-scale based on unit count
    if count < 50 then
        -- Very few units - everything is high detail
        return { high = 999, med = 999, low = 999 }
    elseif count < 100 then
        -- Standard thresholds
        return { high = 15, med = 30, low = 60 }
    elseif count < 200 then
        -- Tighter thresholds
        return { high = 10, med = 20, low = 40 }
    else
        -- Aggressive (200+ units)
        return { high = 7, med = 15, low = 30 }
    end
end

-- ============================================================
-- Distance calculation
-- ============================================================

-- Calculate distance from unit to camera center (in tiles)
local function getCameraDistance(unit)
    if not unit or not unit.gx or not unit.gy then
        return math.huge
    end
    if not _G.state then return math.huge end

    -- Camera center in world coordinates
    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()
    local screenCenterX = screenW / 2 + (_G.state.viewXview or 0)
    local screenCenterY = screenH / 2 + (_G.state.viewYview or 0)

    -- Convert screen center to world (iso)
    -- Reverse of IsoToScreenX: worldX = (screenX - screenY/2) / 32 (approx)
    -- For simplicity, just compare unit screen pos to screen center
    if not _G.IsoToScreenX or not _G.IsoToScreenY then
        return math.huge
    end

    local unitScreenX = _G.IsoToScreenX(unit.gx, unit.gy)
    local unitScreenY = _G.IsoToScreenY(unit.gx, unit.gy)
    local dx = unitScreenX - screenCenterX
    local dy = unitScreenY - screenCenterY
    -- Convert pixel distance to approximate tile distance (32px = 1 tile)
    return math.sqrt(dx * dx + dy * dy) / 32
end

-- ============================================================
-- LOD determination
-- ============================================================

-- Determine LOD level for a unit based on distance and unit count
local function determineLOD(unit, thresholds)
    local dist = getCameraDistance(unit)

    if dist < thresholds.high then
        return LOD_HIGH
    elseif dist < thresholds.med then
        return LOD_MED
    elseif dist < thresholds.low then
        return LOD_LOW
    else
        return LOD_OFF
    end
end

-- ============================================================
-- Public API
-- ============================================================

-- Update LOD levels for all units
function LODSystem.update(dt)
    -- Reset stats
    stats.totalUnits = 0
    stats.byLOD = { [LOD_HIGH] = 0, [LOD_MED] = 0, [LOD_LOW] = 0, [LOD_OFF] = 0 }
    stats.skippedUpdates = 0
    stats.skippedAnimations = 0
    stats.skippedDraws = 0

    frameCounter = frameCounter + 1

    if not _G.state or not _G.state.gameObjectList then return end

    local thresholds = getCurrentThresholds()

    -- Update LOD for each unit
    for _, unit in ipairs(_G.state.gameObjectList) do
        if unit and not unit.toBeDeleted and unit.health and unit.health > 0 then
            local lod = determineLOD(unit, thresholds)
            if not unitLOD[unit] then
                unitLOD[unit] = { level = lod, lastUpdateFrame = 0, lastAnimFrame = 0 }
            else
                unitLOD[unit].level = lod
            end

            stats.totalUnits = stats.totalUnits + 1
            stats.byLOD[lod] = stats.byLOD[lod] + 1
        elseif unitLOD[unit] and (unit.toBeDeleted or not unit.health or unit.health <= 0) then
            -- Clean up dead units
            unitLOD[unit] = nil
        end
    end
end

-- Get current LOD level for a unit (0=HIGH, 1=MED, 2=LOW, 3=OFF)
function LODSystem.getLOD(unit)
    if not unit or not unitLOD[unit] then
        return LOD_HIGH  -- default to highest detail
    end
    return unitLOD[unit].level
end

-- Should this unit be updated this frame?
-- LOD_HIGH: every frame
-- LOD_MED: every 2nd frame
-- LOD_LOW: every 3rd frame
-- LOD_OFF: every 6th frame (very minimal)
function LODSystem.shouldUpdate(unit)
    if not unit or not unitLOD[unit] then return true end
    local lod = unitLOD[unit].level
    local skip
    if lod == LOD_HIGH then
        skip = false
    elseif lod == LOD_MED then
        skip = (frameCounter % 2 ~= 0)
    elseif lod == LOD_LOW then
        skip = (frameCounter % 3 ~= 0)
    else  -- LOD_OFF
        skip = (frameCounter % 6 ~= 0)
    end

    if skip then
        stats.skippedUpdates = stats.skippedUpdates + 1
        return false
    end
    return true
end

-- Should this unit be animated this frame?
-- LOD_HIGH: every frame
-- LOD_MED: every 2nd frame
-- LOD_LOW: every 4th frame
-- LOD_OFF: never
function LODSystem.shouldAnimate(unit)
    if not unit or not unitLOD[unit] then return true end
    local lod = unitLOD[unit].level
    local skip
    if lod == LOD_HIGH then
        skip = false
    elseif lod == LOD_MED then
        skip = (frameCounter % 2 ~= 0)
    elseif lod == LOD_LOW then
        skip = (frameCounter % 4 ~= 0)
    else  -- LOD_OFF
        skip = true
    end

    if skip then
        stats.skippedAnimations = stats.skippedAnimations + 1
        return false
    end
    return true
end

-- Should this unit be drawn?
-- LOD_HIGH, LOD_MED, LOD_LOW: yes
-- LOD_OFF: only if within screen bounds (basic culling)
function LODSystem.shouldDraw(unit)
    if not unit or not unitLOD[unit] then return true end
    local lod = unitLOD[unit].level

    if lod == LOD_OFF then
        -- Off-screen units: skip draw entirely
        -- (this is a strong culling - if you can't see it, don't draw)
        stats.skippedDraws = stats.skippedDraws + 1
        return false
    end
    return true
end

-- Get simplified draw mode (for LOD_LOW)
-- When true, draw a single static sprite instead of animated
function LODSystem.shouldSimplifyDraw(unit)
    if not unit or not unitLOD[unit] then return false end
    local lod = unitLOD[unit].level
    return lod == LOD_LOW
end

-- Get LOD level name (for debug)
function LODSystem.getLODName(level)
    if level == LOD_HIGH then return "HIGH"
    elseif level == LOD_MED then return "MED"
    elseif level == LOD_LOW then return "LOW"
    else return "OFF" end
end

-- Draw debug visualization (LOD circles around units)
function LODSystem.draw()
    if not VISIBLE then return end
    if not _G.state or not _G.state.gameObjectList then return end

    for _, unit in ipairs(_G.state.gameObjectList) do
        if unit and unit.gx and unit.gy and not unit.toBeDeleted then
            local lod = LODSystem.getLOD(unit)
            local color
            if lod == LOD_HIGH then
                color = { 0.3, 0.9, 0.3, 0.5 }  -- green
            elseif lod == LOD_MED then
                color = { 0.9, 0.85, 0.3, 0.5 }  -- yellow
            elseif lod == LOD_LOW then
                color = { 0.95, 0.6, 0.2, 0.5 }  -- orange
            else
                color = { 0.6, 0.3, 0.3, 0.3 }  -- dark red (off)
            end

            if _G.IsoToScreenX and _G.IsoToScreenY and _G.state then
                local sx = _G.IsoToScreenX(unit.gx, unit.gy) - (_G.state.viewXview or 0)
                local sy = _G.IsoToScreenY(unit.gx, unit.gy) - (_G.state.viewYview or 0)
                love.graphics.setColor(color[1], color[2], color[3], color[4])
                love.graphics.circle("line", sx, sy, 8)
            end
        end
    end
end

-- Toggle debug visualization
function LODSystem.toggle()
    VISIBLE = not VISIBLE
    saveVisibility()
    if _G.NotificationCenter then
        pcall(function()
            _G.NotificationCenter.system("LOD debug: " .. (VISIBLE and "VKLOPLJEN" or "IZKLOPLJEN"))
        end)
    end
    if _G.UISoundHelper then
        pcall(function() _G.UISoundHelper.playToggleOn() end)
    end
end

function LODSystem.isVisible()
    return VISIBLE
end

function LODSystem.setVisible(state)
    VISIBLE = state and true or false
    saveVisibility()
end

-- Get stats for debugging
function LODSystem.getStats()
    return {
        totalUnits = stats.totalUnits,
        lodHigh = stats.byLOD[LOD_HIGH],
        lodMed = stats.byLOD[LOD_MED],
        lodLow = stats.byLOD[LOD_LOW],
        lodOff = stats.byLOD[LOD_OFF],
        skippedUpdates = stats.skippedUpdates,
        skippedAnimations = stats.skippedAnimations,
        skippedDraws = stats.skippedDraws,
        visible = VISIBLE,
        frameCounter = frameCounter,
    }
end

-- Reset (for new game)
function LODSystem.reset()
    unitLOD = {}
    frameCounter = 0
    stats.totalUnits = 0
    stats.byLOD = { [LOD_HIGH] = 0, [LOD_MED] = 0, [LOD_LOW] = 0, [LOD_OFF] = 0 }
    stats.skippedUpdates = 0
    stats.skippedAnimations = 0
    stats.skippedDraws = 0
end

-- Expose constants
LODSystem.LOD_HIGH = LOD_HIGH
LODSystem.LOD_MED = LOD_MED
LODSystem.LOD_LOW = LOD_LOW
LODSystem.LOD_OFF = LOD_OFF

return LODSystem
