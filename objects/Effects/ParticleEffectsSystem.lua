-- objects/Effects/ParticleEffectsSystem.lua
-- Castle Kingdoms 2027 v3.12.131 - Particle Effects System
--
-- Lightweight 2D particle system for UI feedback effects:
--   * Confetti — colorful falling squares (legendary achievement unlock)
--   * Sparks — bright dots flying outward (epic/rare achievement)
--   * Gold burst — gold coin circles (bonus gold earned)
--   * Screen flash — full-screen color overlay (critical toast)
--   * Screen shake — camera offset (legendary achievement, big events)
--
-- Particles are screen-space (not world-space) so they appear over the UI.
-- Screen shake affects the world view transform (applied in game.lua draw).
--
-- Usage:
--   local PES = require("objects.Effects.ParticleEffectsSystem")
--   PES.init()
--   PES.emitConfetti(screenX, screenY, 80)
--   PES.emitSparks(screenX, screenY, 30, {1, 0.8, 0.3})
--   PES.emitGold(screenX, screenY, 20)
--   PES.screenFlash({1, 0.8, 0.2}, 0.4, 0.3)
--   PES.screenShake(8, 0.5)
--   PES.update(dt)
--   PES.draw()

local ParticleEffectsSystem = {}

local initialized = false

-- Particle pool (pre-allocated for performance)
local MAX_PARTICLES = 500
local pool = {}

-- Screen shake state
local shakeIntensity = 0
local shakeDuration = 0
local shakeElapsed = 0
local shakeOffsetX = 0
local shakeOffsetY = 0

-- Screen flash state
local flashColor = {1, 1, 1}
local flashIntensity = 0
local flashDuration = 0
local flashElapsed = 0

-- Gravity for confetti/gold
local GRAVITY = 400  -- pixels per second^2

-- Initialize
function ParticleEffectsSystem.init()
    if initialized then return end
    initialized = true
    for i = 1, MAX_PARTICLES do
        pool[i] = {
            active = false,
            x = 0, y = 0,
            vx = 0, vy = 0,
            life = 0, maxLife = 0,
            size = 0,
            color = {1, 1, 1, 1},
            type = "circle",
            rotation = 0,
            rotSpeed = 0,
            gravity = 0,
            drag = 0,
        }
    end
    print("[ParticleEffectsSystem] Initialized — pool: " .. MAX_PARTICLES .. " particles")
end

-- Get a free particle from pool
local function getFreeParticle()
    for i = 1, MAX_PARTICLES do
        if not pool[i].active then
            pool[i].active = true
            return pool[i]
        end
    end
    return nil
end

-- ============================================================
-- EMITTERS
-- ============================================================

function ParticleEffectsSystem.emitConfetti(x, y, count, colors)
    if not initialized then return end
    count = count or 50
    local defaultColors = {
        {1, 0.3, 0.3}, {0.3, 1, 0.3}, {0.3, 0.5, 1},
        {1, 1, 0.3}, {1, 0.3, 1}, {0.3, 1, 1},
        {1, 0.6, 0.2}, {0.8, 0.3, 1},
    }
    colors = colors or defaultColors
    for i = 1, count do
        local p = getFreeParticle()
        if not p then break end
        local angle = math.random() * math.pi * 2
        local speed = 80 + math.random() * 200
        p.x = x + math.random(-5, 5)
        p.y = y + math.random(-5, 5)
        p.vx = math.cos(angle) * speed
        p.vy = math.sin(angle) * speed - 100
        p.maxLife = 1.5 + math.random() * 1.0
        p.life = p.maxLife
        p.size = 4 + math.random() * 4
        p.color = colors[math.random(#colors)]
        p.color[4] = 1
        p.type = "square"
        p.rotation = math.random() * math.pi * 2
        p.rotSpeed = (math.random() - 0.5) * 10
        p.gravity = GRAVITY
        p.drag = 0.3
    end
end

function ParticleEffectsSystem.emitSparks(x, y, count, color)
    if not initialized then return end
    count = count or 20
    color = color or {1, 0.85, 0.3}
    for i = 1, count do
        local p = getFreeParticle()
        if not p then break end
        local angle = math.random() * math.pi * 2
        local speed = 50 + math.random() * 150
        p.x = x
        p.y = y
        p.vx = math.cos(angle) * speed
        p.vy = math.sin(angle) * speed
        p.maxLife = 0.4 + math.random() * 0.4
        p.life = p.maxLife
        p.size = 2 + math.random() * 2
        p.color = {color[1], color[2], color[3], 1}
        p.type = "spark"
        p.rotation = 0
        p.rotSpeed = 0
        p.gravity = 0
        p.drag = 0.5
    end
end

function ParticleEffectsSystem.emitGold(x, y, amount)
    if not initialized then return end
    amount = amount or 10
    local count = math.min(30, math.max(5, math.floor(amount / 5)))
    for i = 1, count do
        local p = getFreeParticle()
        if not p then break end
        local angle = math.random() * math.pi * 2
        local speed = 60 + math.random() * 120
        p.x = x
        p.y = y
        p.vx = math.cos(angle) * speed
        p.vy = math.sin(angle) * speed - 80
        p.maxLife = 0.8 + math.random() * 0.6
        p.life = p.maxLife
        p.size = 3 + math.random() * 3
        p.color = {1, 0.85, 0.2, 1}
        p.type = "circle"
        p.rotation = 0
        p.rotSpeed = (math.random() - 0.5) * 6
        p.gravity = GRAVITY * 0.8
        p.drag = 0.2
    end
end

function ParticleEffectsSystem.screenFlash(color, intensity, duration)
    if not initialized then return end
    flashColor = color or {1, 1, 1}
    flashIntensity = intensity or 0.3
    flashDuration = duration or 0.3
    flashElapsed = 0
end

function ParticleEffectsSystem.screenShake(intensity, duration)
    if not initialized then return end
    shakeIntensity = intensity or 5
    shakeDuration = duration or 0.3
    shakeElapsed = 0
end

-- ============================================================
-- UPDATE
-- ============================================================

function ParticleEffectsSystem.update(dt)
    if not initialized then return end

    if shakeElapsed < shakeDuration then
        shakeElapsed = shakeElapsed + dt
        local t = shakeElapsed / shakeDuration
        local decay = 1 - t
        local mag = shakeIntensity * decay
        shakeOffsetX = (math.random() - 0.5) * 2 * mag
        shakeOffsetY = (math.random() - 0.5) * 2 * mag
    else
        shakeOffsetX = 0
        shakeOffsetY = 0
    end

    if flashElapsed < flashDuration then
        flashElapsed = flashElapsed + dt
    end

    for i = 1, MAX_PARTICLES do
        local p = pool[i]
        if p.active then
            p.life = p.life - dt
            if p.life <= 0 then
                p.active = false
            else
                if p.gravity > 0 then
                    p.vy = p.vy + p.gravity * dt
                end
                if p.drag > 0 then
                    local dragFactor = 1 - (p.drag * dt)
                    p.vx = p.vx * dragFactor
                    p.vy = p.vy * dragFactor
                end
                p.x = p.x + p.vx * dt
                p.y = p.y + p.vy * dt
                if p.rotSpeed ~= 0 then
                    p.rotation = p.rotation + p.rotSpeed * dt
                end
                local lifeRatio = p.life / p.maxLife
                p.color[4] = lifeRatio
            end
        end
    end
end

-- ============================================================
-- DRAW
-- ============================================================

function ParticleEffectsSystem.draw()
    if not initialized then return end

    if flashElapsed < flashDuration then
        local t = flashElapsed / flashDuration
        local alpha = flashIntensity * (1 - t)
        love.graphics.setColor(flashColor[1], flashColor[2], flashColor[3], alpha)
        local w, h = love.graphics.getDimensions()
        love.graphics.rectangle("fill", 0, 0, w, h)
    end

    for i = 1, MAX_PARTICLES do
        local p = pool[i]
        if p.active then
            love.graphics.setColor(p.color[1], p.color[2], p.color[3], p.color[4])
            if p.type == "square" then
                love.graphics.push()
                love.graphics.translate(p.x, p.y)
                love.graphics.rotate(p.rotation)
                love.graphics.rectangle("fill", -p.size / 2, -p.size / 2, p.size, p.size)
                love.graphics.pop()
            elseif p.type == "spark" then
                local len = p.size * 2
                local angle = math.atan2(p.vy, p.vx)
                love.graphics.setLineWidth(p.size)
                love.graphics.line(p.x, p.y, p.x - math.cos(angle) * len, p.y - math.sin(angle) * len)
            else
                love.graphics.circle("fill", p.x, p.y, p.size)
            end
        end
    end

    love.graphics.setColor(1, 1, 1, 1)
end

function ParticleEffectsSystem.getShakeOffset()
    return shakeOffsetX, shakeOffsetY
end

function ParticleEffectsSystem.isActive()
    if shakeElapsed < shakeDuration then return true end
    if flashElapsed < flashDuration then return true end
    for i = 1, MAX_PARTICLES do
        if pool[i].active then return true end
    end
    return false
end

function ParticleEffectsSystem.clear()
    for i = 1, MAX_PARTICLES do
        pool[i].active = false
    end
    shakeElapsed = shakeDuration
    flashElapsed = flashDuration
end

function ParticleEffectsSystem.getStats()
    local activeCount = 0
    for i = 1, MAX_PARTICLES do
        if pool[i].active then activeCount = activeCount + 1 end
    end
    return {
        activeParticles = activeCount,
        poolSize = MAX_PARTICLES,
        shakeActive = shakeElapsed < shakeDuration,
        flashActive = flashElapsed < flashDuration,
    }
end

return ParticleEffectsSystem
