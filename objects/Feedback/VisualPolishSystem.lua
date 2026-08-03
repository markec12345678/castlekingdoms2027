-- objects/Feedback/VisualPolishSystem.lua
-- Stronghold 2027 - Visual Polish
-- UI animations, particle effects, smooth transitions

local VisualPolish = {}

local initialized = false
local particles = {}
local uiAnimations = {}
local maxParticles = 200

function VisualPolish.init()
    if initialized then return end
    initialized = true
    print("[VisualPolish] Initialized")
end

-- Spawn particle effect at position
-- @param x number Screen X
-- @param y number Screen Y
-- @param effectType string "spark", "smoke", "blood", "dust", "gold"
-- @param count number Particle count (default 10)
function VisualPolish.spawnEffect(x, y, effectType, count)
    if not initialized then return end
    if #particles > maxParticles then return end

    count = count or 10
    local colors = {
        spark = {1, 0.8, 0.3},
        smoke = {0.3, 0.3, 0.3},
        blood = {0.8, 0.1, 0.1},
        dust = {0.6, 0.5, 0.4},
        gold = {1, 0.85, 0.2},
        fire = {1, 0.5, 0.1},
        magic = {0.3, 0.6, 1},
    }

    local color = colors[effectType] or {1, 1, 1}

    for i = 1, count do
        local angle = math.random() * math.pi * 2
        local speed = math.random(20, 80)
        table.insert(particles, {
            x = x,
            y = y,
            vx = math.cos(angle) * speed,
            vy = math.sin(angle) * speed - 30,  -- Slight upward bias
            life = 1.0,
            maxLife = 0.5 + math.random() * 0.5,
            size = math.random(2, 5),
            color = color,
            gravity = effectType == "smoke" and -10 or 100,
            type = effectType,
        })
    end
end

-- Spawn hit effect (sparks + blood)
function VisualPolish.spawnHitEffect(x, y)
    VisualPolish.spawnEffect(x, y, "spark", 5)
    VisualPolish.spawnEffect(x, y, "blood", 3)
end

-- Spawn build effect (dust)
function VisualPolish.spawnBuildEffect(x, y)
    VisualPolish.spawnEffect(x, y, "dust", 8)
end

-- Spawn gold effect
function VisualPolish.spawnGoldEffect(x, y)
    VisualPolish.spawnEffect(x, y, "gold", 6)
end

-- Spawn fire effect
function VisualPolish.spawnFireEffect(x, y)
    VisualPolish.spawnEffect(x, y, "fire", 4)
    VisualPolish.spawnEffect(x, y, "smoke", 2)
end

-- Spawn death effect
function VisualPolish.spawnDeathEffect(x, y)
    VisualPolish.spawnEffect(x, y, "blood", 8)
    VisualPolish.spawnEffect(x, y, "dust", 4)
end

-- Animate UI element (fade in/out, slide, scale)
-- @param element table UI element with x, y, alpha
-- @param animType string "fadeIn", "fadeOut", "slideIn", "slideOut", "scaleIn"
-- @param duration number Seconds
-- @param onComplete function Callback
function VisualPolish.animate(element, animType, duration, onComplete)
    if not element then return end

    local anim = {
        element = element,
        type = animType,
        duration = duration or 0.3,
        timer = 0,
        onComplete = onComplete,
        startX = element.x or 0,
        startY = element.y or 0,
        startAlpha = element.alpha or 1,
        startScale = element.scale or 1,
    }

    if animType == "fadeIn" then
        element.alpha = 0
    elseif animType == "fadeOut" then
        element.alpha = 1
    elseif animType == "slideIn" then
        element.x = anim.startX - 50
        element.alpha = 0
    elseif animType == "slideOut" then
        -- Slide to right
    elseif animType == "scaleIn" then
        element.scale = 0.5
        element.alpha = 0
    end

    table.insert(uiAnimations, anim)
end

-- Update particles and animations
function VisualPolish.update(dt)
    if not initialized then return end

    -- Update particles
    for i = #particles, 1, -1 do
        local p = particles[i]
        p.x = p.x + p.vx * dt
        p.y = p.y + p.vy * dt
        p.vy = p.vy + p.gravity * dt
        p.life = p.life - dt / p.maxLife
        p.size = p.size * (1 - dt * 0.5)

        if p.life <= 0 or p.size < 0.5 then
            table.remove(particles, i)
        end
    end

    -- Update UI animations
    for i = #uiAnimations, 1, -1 do
        local anim = uiAnimations[i]
        anim.timer = anim.timer + dt
        local progress = math.min(1, anim.timer / anim.duration)
        local eased = progress < 0.5 and 2 * progress * progress
                       or 1 - ((-2 * progress + 2) ^ 2) / 2  -- easeInOutQuad

        if anim.type == "fadeIn" then
            anim.element.alpha = eased
        elseif anim.type == "fadeOut" then
            anim.element.alpha = 1 - eased
        elseif anim.type == "slideIn" then
            anim.element.x = anim.startX - 50 + 50 * eased
            anim.element.alpha = eased
        elseif anim.type == "slideOut" then
            anim.element.x = anim.startX + 50 * eased
            anim.element.alpha = 1 - eased
        elseif anim.type == "scaleIn" then
            anim.element.scale = 0.5 + 0.5 * eased
            anim.element.alpha = eased
        end

        if progress >= 1 then
            if anim.onComplete then
                pcall(anim.onComplete)
            end
            table.remove(uiAnimations, i)
        end
    end
end

-- Draw all particles
function VisualPolish.draw()
    if not initialized then return end

    for _, p in ipairs(particles) do
        local alpha = math.max(0, p.life)
        love.graphics.setColor(p.color[1], p.color[2], p.color[3], alpha)

        if p.type == "smoke" then
            love.graphics.circle("fill", p.x, p.y, p.size * 1.5)
        else
            love.graphics.circle("fill", p.x, p.y, p.size)
        end
    end

    love.graphics.setColor(1, 1, 1, 1)
end

-- Get stats
function VisualPolish.getStats()
    return {
        activeParticles = #particles,
        activeAnimations = #uiAnimations,
        maxParticles = maxParticles,
    }
end

return VisualPolish
