-- objects/Combat/UnitVeterancySystem.lua
-- Castle Kingdoms 2027 - Unit Veterancy System
-- Units gain XP from combat, level up, and receive stat bonuses

local Veterancy = {}

local LEVELS = {
    [1] = { name = "Novinec",   xpReq = 0,   hpBonus = 0,    dmgBonus = 0,    spdBonus = 0,    color = {0.7, 0.7, 0.7} },
    [2] = { name = "Izkusen",   xpReq = 50,  hpBonus = 0.10, dmgBonus = 0.10, spdBonus = 0.05, color = {0.3, 0.8, 0.3} },
    [3] = { name = "Veteran",   xpReq = 150, hpBonus = 0.25, dmgBonus = 0.20, spdBonus = 0.10, color = {0.3, 0.5, 1.0} },
    [4] = { name = "Elite",     xpReq = 350, hpBonus = 0.40, dmgBonus = 0.35, spdBonus = 0.15, color = {0.8, 0.3, 1.0} },
    [5] = { name = "Legendarni",xpReq = 700, hpBonus = 0.60, dmgBonus = 0.50, spdBonus = 0.20, color = {1.0, 0.8, 0.2} },
}

Veterancy.LEVELS = LEVELS
local MAX_LEVEL = 5
local unitData = {}
local initialized = false

function Veterancy.init()
    if initialized then return end
    initialized = true
    print("[Veterancy] Initialized (" .. MAX_LEVEL .. " levels)")
end

function Veterancy.register(unit)
    if not unit then return end
    local id = tostring(unit)
    if unitData[id] then return end
    unitData[id] = {
        xp = 0, level = 1,
        baseHealth = unit.maxHealth or unit.health or 100,
        baseDamage = unit.baseDamage or unit.damage or 10,
        baseSpeed = unit.baseSpeed or 1.0,
        unit = unit,
    }
    unit.veterancyLevel = 1
    unit.xp = 0
end

function Veterancy.awardXP(unit, amount)
    if not unit then return end
    local id = tostring(unit)
    if not unitData[id] then Veterancy.register(unit) end
    local data = unitData[id]
    data.xp = data.xp + amount
    if unit.xp then unit.xp = data.xp end

    local newLevel = data.level
    for i = MAX_LEVEL, 1, -1 do
        if data.xp >= LEVELS[i].xpReq then newLevel = i break end
    end
    if newLevel > data.level then
        Veterancy._levelUp(unit, data, newLevel)
    end
end

function Veterancy._levelUp(unit, data, newLevel)
    local oldLevel = data.level
    data.level = newLevel
    unit.veterancyLevel = newLevel
    local def = LEVELS[newLevel]
    if def then
        if unit.maxHealth then
            local ratio = unit.health / unit.maxHealth
            unit.maxHealth = math.floor(data.baseHealth * (1 + def.hpBonus))
            unit.health = math.floor(unit.maxHealth * ratio)
        end
        if unit.damage then unit.damage = math.floor(data.baseDamage * (1 + def.dmgBonus)) end
        if unit.speed then unit.speed = data.baseSpeed * (1 + def.spdBonus) end
    end
    if _G.VisualPolish and _G.state then
        local sx = _G.IsoToScreenX(unit.gx, unit.gy) - _G.state.viewXview
        local sy = _G.IsoToScreenY(unit.gx, unit.gy) - _G.state.viewYview
        _G.VisualPolish.spawnEffect(sx, sy, "magic", 15)
    end
    if newLevel >= 4 and _G.VoiceOver then _G.VoiceOver.notify("unit_veteran", def.name) end
    if _G.GameEventBus then _G.GameEventBus.emit("unit_levelup", {oldLevel=oldLevel, newLevel=newLevel, name=def.name}) end
    print(string.format("[Veterancy] Level up: %d -> %d (%s)", oldLevel, newLevel, def.name))
end

function Veterancy.onKill(killer, victim)
    if not killer then return end
    -- Castle Kingdoms 2027 v2.3.3: Improved XP formula
    -- Base XP + bonus for victim maxHealth + bonus for victim veterancy level
    local xp = 15  -- Base XP per kill (was 10)
    if victim and victim.maxHealth then
        xp = xp + math.floor(victim.maxHealth / 8)  -- Was /10, now more generous
    end
    if victim and victim.veterancyLevel and victim.veterancyLevel > 1 then
        xp = xp + victim.veterancyLevel * 15  -- Was *10, now *15
    end
    -- Castle Kingdoms 2027 v2.3.3: Bonus XP if killer is low-level (catch-up mechanic)
    local killerLevel = Veterancy.getLevel(killer)
    if killerLevel <= 2 then
        xp = math.floor(xp * 1.25)  -- 25% bonus XP for novices
    end
    Veterancy.awardXP(killer, xp)
end

function Veterancy.onDamageDealt(attacker, damage)
    if not attacker then return end
    -- Castle Kingdoms 2027 v2.3.3: Increased XP per damage (was /5, now /4)
    -- This rewards aggressive play and tanks (who deal steady damage)
    local xp = math.floor((damage or 0) / 4)
    if xp > 0 then Veterancy.awardXP(attacker, xp) end
end

-- Castle Kingdoms 2027 v2.3.3: New - award XP for taking damage (defensive veterancy)
-- Tanks and frontline units level up by surviving, not just killing
function Veterancy.onDamageTaken(victim, damage)
    if not victim then return end
    local xp = math.floor((damage or 0) / 8)
    if xp > 0 then Veterancy.awardXP(victim, xp) end
end

function Veterancy.getLevel(unit)
    if not unit then return 1 end
    local d = unitData[tostring(unit)]
    return d and d.level or 1
end

function Veterancy.getXP(unit)
    if not unit then return 0 end
    local d = unitData[tostring(unit)]
    return d and d.xp or 0
end

function Veterancy.getProgress(unit)
    if not unit then return 0, 0 end
    local d = unitData[tostring(unit)]
    if not d then return 0, 0 end
    if d.level >= MAX_LEVEL then return 1, 0 end
    local cur = LEVELS[d.level].xpReq
    local nxt = LEVELS[d.level + 1].xpReq
    return math.max(0, math.min(1, (d.xp - cur) / (nxt - cur))), nxt - d.xp
end

function Veterancy.drawUnit(unit)
    if not unit or not unit.veterancyLevel or unit.veterancyLevel < 2 then return end
    if not _G.state or not _G.state.viewXview then return end
    local sx = _G.IsoToScreenX(unit.gx, unit.gy) - _G.state.viewXview
    local sy = _G.IsoToScreenY(unit.gx, unit.gy) - _G.state.viewYview
    local def = LEVELS[unit.veterancyLevel]
    if not def then return end

    love.graphics.setColor(def.color[1], def.color[2], def.color[3], 1)
    local starY = sy - 45
    for i = 1, unit.veterancyLevel - 1 do
        local starX = sx - (unit.veterancyLevel - 2) * 5 + (i - 1) * 10
        love.graphics.circle("fill", starX, starY, 4)
    end

    -- XP bar for selected
    if _G.Commander and _G.Commander.selectedUnits then
        for _, sel in ipairs(_G.Commander.selectedUnits) do
            if sel == unit and unit.veterancyLevel < MAX_LEVEL then
                local progress = Veterancy.getProgress(unit)
                local barW, barH = 30, 3
                local barX, barY = sx - barW/2, sy - 55
                love.graphics.setColor(0, 0, 0, 0.7)
                love.graphics.rectangle("fill", barX-1, barY-1, barW+2, barH+2)
                love.graphics.setColor(def.color[1], def.color[2], def.color[3], 1)
                love.graphics.rectangle("fill", barX, barY, barW * progress, barH)
                break
            end
        end
    end
    love.graphics.setColor(1, 1, 1, 1)
end

function Veterancy.drawSelected()
    if not _G.Commander or not _G.Commander.selectedUnits then return end
    for _, unit in ipairs(_G.Commander.selectedUnits) do Veterancy.drawUnit(unit) end
end

function Veterancy.getStats()
    local total, totalXP, levels = 0, 0, {}
    for _, d in pairs(unitData) do
        total = total + 1
        totalXP = totalXP + d.xp
        levels[d.level] = (levels[d.level] or 0) + 1
    end
    return { trackedUnits = total, totalXP = totalXP, levelCounts = levels }
end

function Veterancy.cleanup(activeUnits)
    local ids = {}
    for _, u in ipairs(activeUnits) do ids[tostring(u)] = true end
    for id, _ in pairs(unitData) do if not ids[id] then unitData[id] = nil end end
end

return Veterancy
