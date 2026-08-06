-- objects/Feedback/GameFeelSystem.lua
-- Stronghold 2027 - Game Feel System
--
-- Adds "juice" to the game:
-- - Screen shake on explosions/combat
-- - Smooth camera movement (lerp toward target)
-- - Hit flash on damaged units
-- - Punch zoom on important events
--
-- All effects are OPTIONAL and can be disabled in settings.

local GameFeelSystem = {}

local initialized = false
local enabled = true

local shake = {
    intensity = 0, duration = 0, maxDuration = 0,
    offsetX = 0, offsetY = 0, decay = 8.0,
}

local camera = {
    currentX = 0, currentY = 0, targetX = 0, targetY = 0,
    currentZoom = 1.0, targetZoom = 1.0, smoothFactor = 5.0,
}

local punchZoom = {
    active = false, intensity = 0, duration = 0, maxDuration = 0, decay = 6.0,
}

local hitFlashes = {}

local config = {
    maxShakeIntensity = 15.0,
    maxShakeDuration = 0.5,
    maxPunchZoom = 0.05,
    maxPunchDuration = 0.3,
    hitFlashDuration = 0.2,
    hitFlashColor = { 1, 0.2, 0.2 },
    cameraSmooth = 5.0,
    enabledByDefault = true,
}

function GameFeelSystem.init()
    if initialized then return end
    initialized = true
    enabled = config.enabledByDefault
    print("[GameFeel] Initialized (screen shake, camera smooth, hit flash)")
end

function GameFeelSystem.setEnabled(state) enabled = state end
function GameFeelSystem.isEnabled() return enabled end

-- === SCREEN SHAKE ===

function GameFeelSystem.shake(intensity, duration)
    if not enabled then return end
    intensity = math.min(intensity, config.maxShakeIntensity)
    duration = math.min(duration or 0.3, config.maxShakeDuration)
    if intensity > shake.intensity * (shake.duration / math.max(0.001, shake.maxDuration)) then
        shake.intensity = intensity
        shake.duration = duration
        shake.maxDuration = duration
    end
end

function GameFeelSystem.shakeSmall() GameFeelSystem.shake(2.0, 0.15) end
function GameFeelSystem.shakeMedium() GameFeelSystem.shake(5.0, 0.25) end
function GameFeelSystem.shakeLarge() GameFeelSystem.shake(10.0, 0.4) end
function GameFeelSystem.shakeExplosion() GameFeelSystem.shake(15.0, 0.5) end

-- === PUNCH ZOOM ===

function GameFeelSystem.punchZoomIn(intensity, duration)
    if not enabled then return end
    intensity = math.min(math.abs(intensity or 0.03), config.maxPunchZoom)
    duration = math.min(duration or 0.2, config.maxPunchDuration)
    punchZoom.active = true
    punchZoom.intensity = intensity
    punchZoom.duration = duration
    punchZoom.maxDuration = duration
end

function GameFeelSystem.punchZoomOut(intensity, duration)
    if not enabled then return end
    intensity = -math.min(math.abs(intensity or 0.03), config.maxPunchZoom)
    duration = math.min(duration or 0.2, config.maxPunchDuration)
    punchZoom.active = true
    punchZoom.intensity = intensity
    punchZoom.duration = duration
    punchZoom.maxDuration = duration
end

-- === HIT FLASH ===

function GameFeelSystem.flash(unit, intensity)
    if not enabled or not unit then return end
    intensity = intensity or 0.5
    hitFlashes[unit] = {
        intensity = intensity,
        duration = config.hitFlashDuration,
        maxDuration = config.hitFlashDuration,
    }
end

function GameFeelSystem.getFlashIntensity(unit)
    if not enabled then return 0 end
    local flash = hitFlashes[unit]
    if not flash then return 0 end
    return flash.intensity * (flash.duration / math.max(0.001, flash.maxDuration))
end

-- === CAMERA ===

function GameFeelSystem.setCameraTarget(x, y)
    camera.targetX = x
    camera.targetY = y
end

function GameFeelSystem.setCameraZoom(zoom)
    camera.targetZoom = zoom
end

function GameFeelSystem.snapCamera(x, y)
    camera.currentX = x
    camera.currentY = y
    camera.targetX = x
    camera.targetY = y
end

function GameFeelSystem.getCameraPosition()
    return camera.currentX, camera.currentY
end

function GameFeelSystem.getCameraZoom()
    local zoom = camera.currentZoom
    if punchZoom.active then
        local progress = punchZoom.duration / math.max(0.001, punchZoom.maxDuration)
        zoom = zoom + (punchZoom.intensity * progress)
    end
    return zoom
end

-- === UPDATE ===

function GameFeelSystem.update(dt)
    if not enabled then return end

    -- Update screen shake
    if shake.duration > 0 then
        shake.duration = shake.duration - dt
        local progress = shake.duration / math.max(0.001, shake.maxDuration)
        local currentIntensity = shake.intensity * progress
        shake.offsetX = (math.random() - 0.5) * 2 * currentIntensity
        shake.offsetY = (math.random() - 0.5) * 2 * currentIntensity
        if shake.duration <= 0 then
            shake.intensity = 0
            shake.offsetX = 0
            shake.offsetY = 0
        end
    end

    -- Update punch zoom
    if punchZoom.active then
        punchZoom.duration = punchZoom.duration - dt
        if punchZoom.duration <= 0 then
            punchZoom.active = false
            punchZoom.intensity = 0
        end
    end

    -- Update camera smoothing
    local lerpFactor = 1 - math.exp(-config.cameraSmooth * dt)
    camera.currentX = camera.currentX + (camera.targetX - camera.currentX) * lerpFactor
    camera.currentY = camera.currentY + (camera.targetY - camera.currentY) * lerpFactor
    camera.currentZoom = camera.currentZoom + (camera.targetZoom - camera.currentZoom) * lerpFactor

    -- Update hit flashes
    for unit, flash in pairs(hitFlashes) do
        flash.duration = flash.duration - dt
        if flash.duration <= 0 then
            hitFlashes[unit] = nil
        end
    end
end

-- === APPLY TRANSFORM ===

function GameFeelSystem.applyCameraTransform()
    if not enabled then return end
    local x, y = GameFeelSystem.getCameraPosition()
    local zoom = GameFeelSystem.getCameraZoom()
    x = x + shake.offsetX
    y = y + shake.offsetY
    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()
    love.graphics.translate(screenW / 2, screenH / 2)
    love.graphics.scale(zoom)
    love.graphics.translate(-x, -y)
end

-- === COMBAT HOOKS ===

function GameFeelSystem.onUnitDamaged(unit, damage, attacker)
    GameFeelSystem.flash(unit, math.min(1.0, damage / 30))
    if damage > 20 then
        GameFeelSystem.shakeSmall()
    end
end

function GameFeelSystem.onUnitDeath(unit, killer)
    GameFeelSystem.shakeMedium()
    GameFeelSystem.punchZoomOut(0.02, 0.2)
end

function GameFeelSystem.onBuildingDestroyed(building)
    GameFeelSystem.shakeLarge()
    GameFeelSystem.punchZoomOut(0.03, 0.3)
end

function GameFeelSystem.onExplosion(gx, gy, radius)
    GameFeelSystem.shakeExplosion()
    GameFeelSystem.punchZoomIn(0.04, 0.25)
end

-- === SETTINGS ===

function GameFeelSystem.setShakeEnabled(state)
    if not state then
        shake.intensity = 0
        shake.duration = 0
        shake.offsetX = 0
        shake.offsetY = 0
    end
    config.shakeEnabled = state
end

function GameFeelSystem.setCameraSmoothing(factor)
    config.cameraSmooth = factor or 5.0
end

function GameFeelSystem.getStats()
    local flashCount = 0
    for _ in pairs(hitFlashes) do flashCount = flashCount + 1 end
    return {
        enabled = enabled,
        shakeActive = shake.duration > 0,
        shakeIntensity = shake.intensity * (shake.duration / math.max(0.001, shake.maxDuration)),
        punchZoomActive = punchZoom.active,
        cameraZoom = camera.currentZoom,
        hitFlashCount = flashCount,
    }
end

return GameFeelSystem
