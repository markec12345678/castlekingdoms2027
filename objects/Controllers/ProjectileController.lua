-- objects/Controllers/ProjectileController.lua
-- Stronghold 2027 - Projectile System
--
-- Manages all projectiles (arrows, bolts, catapult rocks, etc.)
-- Separates projectile logic from main CombatController for performance
--
-- Usage:
--   local ProjectileController = require("objects.Controllers.ProjectileController")
--   ProjectileController:initialize()
--   ProjectileController:spawnArrow(source, target, damage)
--   ProjectileController:update(dt)

local COMBAT = require("objects.Enums.Combat")

local ProjectileController = _G.class("ProjectileController")

function ProjectileController:initialize()
    self.projectiles = {}
    self.nextId = 1

    print("ProjectileController initialized")
end

-- Spawn an arrow from archer to target
function ProjectileController:spawnArrow(source, target, damage)
    local projectile = {
        id = self.nextId,
        type = "arrow",
        source = source,
        target = target,
        startX = source.gx,
        startY = source.gy,
        targetX = target.gx,
        targetY = target.gy,
        currentX = source.gx,
        currentY = source.gy,
        progress = 0,
        speed = 10,  -- tiles per second
        damage = damage or 12,
        arcHeight = 2,  -- visual arc for arrow
        onHitCallback = nil,
    }
    table.insert(self.projectiles, projectile)
    self.nextId = self.nextId + 1
    return projectile
end

-- Spawn a bolt (crossbow) - faster, no arc
function ProjectileController:spawnBolt(source, target, damage)
    local projectile = {
        id = self.nextId,
        type = "bolt",
        source = source,
        target = target,
        startX = source.gx,
        startY = source.gy,
        targetX = target.gx,
        targetY = target.gy,
        currentX = source.gx,
        currentY = source.gy,
        progress = 0,
        speed = 15,  -- faster than arrow
        damage = damage or 25,
        arcHeight = 0.5,  -- minimal arc
        onHitCallback = nil,
    }
    table.insert(self.projectiles, projectile)
    self.nextId = self.nextId + 1
    return projectile
end

-- Spawn a catapult rock
function ProjectileController:spawnRock(source, target, damage)
    local projectile = {
        id = self.nextId,
        type = "rock",
        source = source,
        target = target,
        startX = source.gx,
        startY = source.gy,
        targetX = target.gx,
        targetY = target.gy,
        currentX = source.gx,
        currentY = source.gy,
        progress = 0,
        speed = 4,  -- slow
        damage = damage or 100,
        arcHeight = 8,  -- high arc
        splashRadius = 3,  -- AoE damage
        onHitCallback = nil,
    }
    table.insert(self.projectiles, projectile)
    self.nextId = self.nextId + 1
    return projectile
end

-- Update all projectiles
function ProjectileController:update(dt)
    for i = #self.projectiles, 1, -1 do
        local proj = self.projectiles[i]
        proj.progress = proj.progress + proj.speed * dt

        if proj.progress >= 1 then
            -- Projectile hit target
            self:onProjectileHit(proj)
            table.remove(self.projectiles, i)
        else
            -- Update current position
            proj.currentX = proj.startX + (proj.targetX - proj.startX) * proj.progress
            proj.currentY = proj.startY + (proj.targetY - proj.startY) * proj.progress
        end
    end
end

-- Handle projectile hit
function ProjectileController:onProjectileHit(proj)
    -- Check if target still alive
    if not proj.target or proj.target.toBeDeleted then
        return
    end

    -- Apply direct damage
    if proj.target.health and proj.target.health > 0 then
        proj.target.health = proj.target.health - proj.damage

        -- Fire callback if set
        if proj.onHitCallback then
            proj.onHitCallback(proj.target, proj.damage)
        end

        -- Splash damage for catapult rocks
        if proj.splashRadius and proj.splashRadius > 0 then
            self:applySplashDamage(proj.targetX, proj.targetY, proj.splashRadius, proj.damage * 0.5, proj.source)
        end
    end
end

-- Apply splash damage to all units in radius
function ProjectileController:applySplashDamage(centerX, centerY, radius, damage, source)
    if not _G.state or not _G.state.gameObjectList then return end

    local radiusSq = radius * radius

    for _, unit in ipairs(_G.state.gameObjectList) do
        if unit and unit.health and unit.health > 0 and not unit.toBeDeleted then
            local dx = unit.gx - centerX
            local dy = unit.gy - centerY
            local distSq = dx * dx + dy * dy

            if distSq <= radiusSq then
                -- Damage falloff with distance
                local distFactor = 1 - (math.sqrt(distSq) / radius)
                local actualDamage = damage * distFactor
                unit.health = unit.health - actualDamage
            end
        end
    end
end

-- Draw all projectiles
function ProjectileController:draw()
    for _, proj in ipairs(self.projectiles) do
        -- Calculate visual position with arc
        local arcOffset = 0
        if proj.arcHeight > 0 then
            -- Parabolic arc: 4 * h * t * (1 - t) peaks at t=0.5
            arcOffset = 4 * proj.arcHeight * proj.progress * (1 - proj.progress)
        end

        -- Convert world coords to screen (simplified isometric)
        local screenX = proj.currentX * 32 - proj.currentY * 32
        local screenY = (proj.currentX * 16 + proj.currentY * 16) - arcOffset * 16

        -- Apply view offset
        screenX = screenX - (_G.state.viewXview or 0)
        screenY = screenY - (_G.state.viewYview or 0)

        -- Draw based on type
        if proj.type == "arrow" then
            love.graphics.setColor(0.7, 0.5, 0.3, 1)
            love.graphics.circle("fill", screenX, screenY, 2)
        elseif proj.type == "bolt" then
            love.graphics.setColor(0.3, 0.3, 0.3, 1)
            love.graphics.circle("fill", screenX, screenY, 3)
        elseif proj.type == "rock" then
            love.graphics.setColor(0.5, 0.5, 0.5, 1)
            love.graphics.circle("fill", screenX, screenY, 6)
        end
    end

    love.graphics.setColor(1, 1, 1, 1)
end

-- Get projectile count
function ProjectileController:getCount()
    return #self.projectiles
end

-- Clear all projectiles (e.g., on game load)
function ProjectileController:clear()
    self.projectiles = {}
end

return ProjectileController:new()
