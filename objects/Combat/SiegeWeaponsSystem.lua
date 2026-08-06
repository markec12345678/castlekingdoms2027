-- objects/Combat/SiegeWeaponsSystem.lua
-- Stronghold 2027 - Siege Weapons
-- Catapults, trebuchets, siege towers, battering rams

local Siege = {}

local SIEGE_TYPES = {
    catapult = {
        name = "Catapult",
        cost = { gold = 200, wood = 50, iron = 20 },
        buildTime = 45,
        health = 150,
        damage = 80,
        range = 15,
        cooldown = 8.0,
        splashRadius = 3,
        speed = 0.5,
        description = "Long-range siege weapon. Deals area damage to buildings.",
        icon = "assets/ui/unit_ui/catapult_icon.png",
        iconScale = 0.5,
    },
    trebuchet = {
        name = "Trebuchet",
        cost = { gold = 350, wood = 80, iron = 30 },
        buildTime = 60,
        health = 120,
        damage = 120,
        range = 20,
        cooldown = 12.0,
        splashRadius = 4,
        speed = 0.3,
        description = "Devastating long-range weapon. Slow but powerful.",
        icon = "assets/ui/unit_ui/treb_icon.png",
        iconScale = 0.5,
    },
    siege_tower = {
        name = "Siege Tower",
        cost = { gold = 250, wood = 100 },
        buildTime = 50,
        health = 300,
        damage = 0,
        range = 0,
        cooldown = 0,
        splashRadius = 0,
        speed = 0.4,
        description = "Mobile tower for scaling walls. High health, no attack.",
        icon = "assets/ui/unit_ui/tower_icon.png",
        iconScale = 0.5,
    },
    battering_ram = {
        name = "Battering Ram",
        cost = { gold = 150, wood = 60, iron = 15 },
        buildTime = 35,
        health = 250,
        damage = 200,
        range = 1.5,
        cooldown = 5.0,
        splashRadius = 0,
        speed = 0.6,
        description = "Melee siege weapon. Devastates gates and walls.",
        icon = "assets/ui/unit_ui/ram_icon.png",
        iconScale = 0.5,
    },
}

Siege.SIEGE_TYPES = SIEGE_TYPES

local activeSiegeWeapons = {}
local initialized = false
local loadedIcons = {}  -- cache of loaded Image objects

local function getIcon(path)
    if not path then return nil end
    if loadedIcons[path] then return loadedIcons[path] end
    -- Check if file exists before loading to avoid errors
    local info = love.filesystem.getInfo(path)
    if not info then return nil end
    local ok, img = pcall(love.graphics.newImage, path)
    if ok and img then
        loadedIcons[path] = img
        return img
    end
    return nil
end

function Siege.init()
    if initialized then return end
    initialized = true
    -- Preload all siege weapon icons
    for _, def in pairs(SIEGE_TYPES) do
        getIcon(def.icon)
    end
    print("[SiegeWeapons] Initialized with " .. Siege._getTypeCount() .. " siege weapon types")
end

function Siege._getTypeCount()
    local count = 0
    for _ in pairs(SIEGE_TYPES) do count = count + 1 end
    return count
end

function Siege.create(siegeType, gx, gy, faction)
    local def = SIEGE_TYPES[siegeType]
    if not def then
        print("[SiegeWeapons] Unknown type: " .. tostring(siegeType))
        return nil
    end

    local weapon = {
        id = #activeSiegeWeapons + 1,
        type = siegeType,
        def = def,
        gx = gx,
        gy = gy,
        faction = faction or 1,
        health = def.health,
        maxHealth = def.health,
        targetGx = nil,
        targetGy = nil,
        cooldownTimer = 0,
        state = "idle", -- idle, moving, attacking
        moveTargetGx = nil,
        moveTargetGy = nil,
    }

    table.insert(activeSiegeWeapons, weapon)
    print(string.format("[SiegeWeapons] Created %s at (%d,%d) faction=%d", def.name, gx, gy, faction))
    return weapon
end

function Siege.remove(id)
    for i, w in ipairs(activeSiegeWeapons) do
        if w.id == id then
            table.remove(activeSiegeWeapons, i)
            return true
        end
    end
    return false
end

function Siege.getOrderTo(gx, gy)
    for _, w in ipairs(activeSiegeWeapons) do
        if w.faction == 1 then
            w.moveTargetGx = gx
            w.moveTargetGy = gy
            w.state = "moving"
        end
    end
end

function Siege.attackTarget(id, targetGx, targetGy)
    for _, w in ipairs(activeSiegeWeapons) do
        if w.id == id then
            w.targetGx = targetGx
            w.targetGy = targetGy
            w.state = "attacking"
            return true
        end
    end
    return false
end

function Siege.update(dt)
    for _, w in ipairs(activeSiegeWeapons) do
        if w.state == "moving" and w.moveTargetGx then
            -- Move towards target
            local dx = w.moveTargetGx - w.gx
            local dy = w.moveTargetGy - w.gy
            local dist = math.sqrt(dx*dx + dy*dy)
            if dist > 0.5 then
                local speed = w.def.speed * dt
                w.gx = w.gx + (dx / dist) * speed
                w.gy = w.gy + (dy / dist) * speed
            else
                w.state = "idle"
                w.moveTargetGx = nil
                w.moveTargetGy = nil
            end

        elseif w.state == "attacking" and w.targetGx then
            w.cooldownTimer = w.cooldownTimer - dt
            if w.cooldownTimer <= 0 then
                local dx = w.targetGx - w.gx
                local dy = w.targetGy - w.gy
                local dist = math.sqrt(dx*dx + dy*dy)
                if dist <= w.def.range then
                    Siege._fire(w)
                    w.cooldownTimer = w.def.cooldown
                else
                    -- Move closer
                    local speed = w.def.speed * dt
                    w.gx = w.gx + (dx / dist) * speed
                    w.gy = w.gy + (dy / dist) * speed
                end
            end
        end
    end
end

function Siege._fire(weapon)
    -- Create projectile effect
    if _G.CombatIntegration and _G.CombatIntegration.spawnProjectile then
        _G.CombatIntegration.spawnProjectile(
            weapon.gx, weapon.gy,
            weapon.targetGx, weapon.targetGy,
            weapon.def.damage,
            weapon.def.splashRadius
        )
    end

    -- Play SFX
    if _G.SFXLibrary then
        _G.SFXLibrary.playCombat("army_charge", weapon.gx, weapon.gy)
    end

    -- Screen shake
    if _G.GameFeel then
        -- Stronghold 2027 v2.4.0: Use shake() (addShake doesn't exist)
        pcall(function() _G.GameFeel.shake(5, 0.3) end)
    end

    print(string.format("[SiegeWeapons] %s fired at (%.0f,%.0f) dmg=%d",
        weapon.def.name, weapon.targetGx, weapon.targetGy, weapon.def.damage))
end

function Siege.getAll()
    return activeSiegeWeapons
end

function Siege.getByFaction(faction)
    local result = {}
    for _, w in ipairs(activeSiegeWeapons) do
        if w.faction == faction then
            table.insert(result, w)
        end
    end
    return result
end

function Siege.getCount()
    return #activeSiegeWeapons
end

function Siege.draw()
    for _, w in ipairs(activeSiegeWeapons) do
        if _G.state and _G.state.viewXview then
            local sx = _G.IsoToScreenX(w.gx, w.gy) - _G.state.viewXview
            local sy = _G.IsoToScreenY(w.gx, w.gy) - _G.state.viewYview

            -- Stronghold 2027 v2.3.3: Draw siege weapon using real sprite icon
            local icon = getIcon(w.def.icon)
            if icon then
                -- Tint by faction (subtle color overlay for enemy units)
                if w.faction == 1 then
                    love.graphics.setColor(1, 1, 1, 1)
                else
                    -- Slight red tint for enemy siege weapons
                    love.graphics.setColor(1, 0.85, 0.85, 1)
                end
                local scale = w.def.iconScale or 0.5
                local iw, ih = icon:getDimensions()
                -- Center icon on tile center
                love.graphics.draw(icon, sx - (iw * scale) / 2, sy - (ih * scale) / 2, 0, scale, scale)
            else
                -- Fallback: colored circle (placeholder) if icon fails to load
                local color = w.faction == 1 and {0.3, 0.5, 0.9} or {0.9, 0.3, 0.3}
                love.graphics.setColor(color[1], color[2], color[3], 1)
                love.graphics.circle("fill", sx, sy, 15)
                love.graphics.setColor(0, 0, 0, 1)
                love.graphics.circle("line", sx, sy, 15)
            end

            -- Health bar (above the weapon)
            local hp = w.health / w.maxHealth
            love.graphics.setColor(1, 0, 0, 1)
            love.graphics.rectangle("fill", sx - 15, sy - 25, 30, 4)
            love.graphics.setColor(0, 1, 0, 1)
            love.graphics.rectangle("fill", sx - 15, sy - 25, 30 * hp, 4)

            -- Label (weapon name, 4 chars)
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.print(w.def.name:sub(1, 4), sx - 10, sy + 18)
        end
    end
    love.graphics.setColor(1, 1, 1, 1)
end

return Siege
