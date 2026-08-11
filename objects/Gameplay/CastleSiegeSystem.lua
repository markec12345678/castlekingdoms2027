-- objects/Gameplay/CastleSiegeSystem.lua
-- Castle Kingdoms 2027 v3.0.3 - Castle Siege System
--
-- Advanced siege mechanics for attacking and defending castles.
-- Goes beyond basic siege weapons with structured siege phases,
-- wall integrity, breach points, and surrender mechanics.
--
-- Features:
-- - 4 siege phases (approach, bombardment, assault, breach)
-- - Wall integrity tracking (per wall section)
-- - Breach point system (create gaps in walls)
-- - Siege equipment deployment (ladders, towers, rams)
-- - Defender responses (boiling oil, archers, rocks)
-- - Surrender and negotiation options
-- - Siege duration tracking and attrition
-- - Supply siege (starve the defenders)

local Siege = {}

-- Siege phases
local PHASES = {
    approach = { name = "Pristop",      nameEn = "Approach",      desc = "Priprava oblegovalnih položajev" },
    bombard = { name = "Bombardiranje",  nameEn = "Bombardment",   desc = "Uničevanje zidov s katapulti/trebucheti" },
    assault = { name = "Napad",         nameEn = "Assault",        desc = "Penjanje prek zidov, oblegovalni stolpi" },
    breach = { name = "Preboj",         nameEn = "Breach",         desc = "Vdor skozi vrzeli v zidovih" },
}

Siege.PHASES = PHASES

-- Wall sections (8 cardinal directions + gate)
local WALL_SECTIONS = {
    { id = "north",     name = "Sever",     integrity = 100, maxIntegrity = 100 },
    { id = "northeast", name = "Severovzhod", integrity = 100, maxIntegrity = 100 },
    { id = "east",      name = "Vzhod",     integrity = 100, maxIntegrity = 100 },
    { id = "southeast", name = "Jugovzhod", integrity = 100, maxIntegrity = 100 },
    { id = "south",     name = "Jug",       integrity = 100, maxIntegrity = 100 },
    { id = "southwest", name = "Jugozahod", integrity = 100, maxIntegrity = 100 },
    { id = "west",      name = "Zahod",     integrity = 100, maxIntegrity = 100 },
    { id = "northwest", name = "Severozahod", integrity = 100, maxIntegrity = 100 },
    { id = "gate",      name = "Vrata",     integrity = 150, maxIntegrity = 150 },
}

Siege.WALL_SECTIONS = WALL_SECTIONS

-- Siege equipment types
local EQUIPMENT = {
    ladder = { name = "Lesenica",      cost = { wood = 10 },          deployTime = 10,  effect = "climb",     uses = 3 },
    siege_tower = { name = "Oblegovalni stolp", cost = { wood = 50, iron = 10 }, deployTime = 30,  effect = "climb_mass", uses = 1 },
    battering_ram = { name = "Oven",   cost = { wood = 30, iron = 5 }, deployTime = 20,  effect = "gate_damage", uses = 5 },
    catapult = { name = "Katapult",    cost = { wood = 50, gold = 100 }, deployTime = 45, effect = "wall_damage", uses = 10 },
    trebuchet = { name = "Trebuchet",  cost = { wood = 80, gold = 200 }, deployTime = 60, effect = "wall_damage", uses = 15 },
}

Siege.EQUIPMENT = EQUIPMENT

-- Defender responses
local DEFENSES = {
    boiling_oil = { name = "Vrelo olje",    damage = 50, range = 2, cooldown = 30, cost = { pitch = 5 } },
    archer_volley = { name = "Strelna salvno", damage = 20, range = 10, cooldown = 15, cost = {} },
    rock_drop = { name = "Padanje skal",     damage = 40, range = 3, cooldown = 20, cost = { stone = 10 } },
    sorties = { name = "Izpad",            damage = 30, range = 15, cooldown = 60, cost = {} },
}

Siege.DEFENSES = DEFENSES

local initialized = false
local activeSiege = nil  -- current siege state
local siegeHistory = {}
local maxHistory = 20

function Siege.init()
    if initialized then return end
    initialized = true
    print("[CastleSiege] Initialized with " .. #WALL_SECTIONS .. " wall sections, " .. Siege._getEquipmentCount() .. " equipment types")
end

function Siege._getEquipmentCount()
    local count = 0
    for _ in pairs(EQUIPMENT) do count = count + 1 end
    return count
end

-- Start a siege on a target
function Siege.start(targetFaction, targetKeepX, targetKeepY)
    if activeSiege then
        if _G.ModernUI then
            _G.ModernUI.notifyError("Obleganje je že v teku")
        end
        return false
    end

    -- Clone wall sections
    local walls = {}
    for i, section in ipairs(WALL_SECTIONS) do
        walls[i] = {
            id = section.id,
            name = section.name,
            integrity = section.maxIntegrity,
            maxIntegrity = section.maxIntegrity,
            breached = false,
        }
    end

    activeSiege = {
        targetFaction = targetFaction or 2,
        targetKeepX = targetKeepX or 50,
        targetKeepY = targetKeepY or 50,
        phase = "approach",
        phaseTimer = 0,
        walls = walls,
        deployedEquipment = {},
        defensesUsed = {},
        defenderMorale = 100,
        attackerMorale = 100,
        siegeDuration = 0,
        supplyCut = false,
        surrendered = false,
        startTime = os.time(),
        totalDamageDealt = 0,
        totalDamageReceived = 0,
    }

    if _G.ModernUI then
        _G.ModernUI.notifySuccess("Obleganje začeto! Faza: " .. PHASES[activeSiege.phase].name)
    end
    if _G.SoundtrackMgr then
        pcall(function() _G.SoundtrackMgr.setMood("tension") end)
    end
    if _G.GameEventBus then
        pcall(function() _G.GameEventBus.emit("siege_started", { target = targetFaction }) end)
    end

    print("[CastleSiege] Siege started on faction " .. targetFaction)
    return true
end

-- Advance to next phase
function Siege._advancePhase()
    if not activeSiege then return end
    local phaseOrder = {"approach", "bombard", "assault", "breach"}
    local idx = 1
    for i, p in ipairs(phaseOrder) do
        if p == activeSiege.phase then idx = i break end
    end
    if idx < #phaseOrder then
        activeSiege.phase = phaseOrder[idx + 1]
        activeSiege.phaseTimer = 0
        if _G.ModernUI then
            _G.ModernUI.notifyInfo("Obleganje: " .. PHASES[activeSiege.phase].name .. " — " .. PHASES[activeSiege.phase].desc)
        end
        if activeSiege.phase == "assault" and _G.SoundtrackMgr then
            pcall(function() _G.SoundtrackMgr.setMood("combat", 0.8) end)
        end
    end
end

-- Deploy siege equipment
function Siege.deployEquipment(equipType, targetSection)
    if not activeSiege then return false end
    local equip = EQUIPMENT[equipType]
    if not equip then return false end

    -- Check cost
    if _G.state and _G.state.resources then
        for res, amount in pairs(equip.cost) do
            local available = _G.state.resources[res] or 0
            if res == "gold" then available = _G.state.gold or 0 end
            if available < amount then
                if _G.ModernUI then
                    _G.ModernUI.notifyError("Ni dovolj " .. res .. " (" .. amount .. " potrebno)")
                end
                return false
            end
        end
        -- Deduct cost
        for res, amount in pairs(equip.cost) do
            if res == "gold" then
                _G.state.gold = (_G.state.gold or 0) - amount
            else
                _G.state.resources[res] = (_G.state.resources[res] or 0) - amount
            end
        end
    end

    table.insert(activeSiege.deployedEquipment, {
        type = equipType,
        targetSection = targetSection or "south",
        deployTime = equip.deployTime,
        timeRemaining = equip.deployTime,
        uses = equip.uses,
        ready = false,
    })

    if _G.ModernUI then
        _G.ModernUI.notifySuccess(equip.name .. " razporejen na " .. (targetSection or "jug"))
    end
    return true
end

-- Use defender response
function Siege.useDefense(defenseType, targetSection)
    if not activeSiege then return false end
    local defense = DEFENSES[defenseType]
    if not defense then return false end

    -- Check cooldown
    for _, used in ipairs(activeSiege.defensesUsed) do
        if used.type == defenseType and (os.time() - used.time) < defense.cooldown then
            if _G.ModernUI then
                _G.ModernUI.notifyError(defense.name .. " na cooldownu")
            end
            return false
        end
    end

    -- Apply damage to attackers (simulated)
    activeSiege.attackerMorale = math.max(0, activeSiege.attackerMorale - defense.damage / 5)
    activeSiege.totalDamageReceived = activeSiege.totalDamageReceived + defense.damage

    table.insert(activeSiege.defensesUsed, {
        type = defenseType,
        section = targetSection,
        time = os.time(),
    })

    if _G.ModernUI then
        _G.ModernUI.notifyInfo(defense.name .. "! -" .. defense.damage .. " damage napadalcem")
    end
    return true
end

-- Damage a wall section
function Siege._damageWall(sectionId, damage)
    if not activeSiege then return end
    for _, wall in ipairs(activeSiege.walls) do
        if wall.id == sectionId then
            wall.integrity = math.max(0, wall.integrity - damage)
            if wall.integrity <= 0 and not wall.breached then
                wall.breached = true
                if _G.ModernUI then
                    _G.ModernUI.notifySuccess("Preboj! " .. wall.name .. " zid uničen!")
                end
                if _G.GameEventBus then
                    pcall(function() _G.GameEventBus.emit("siege_breach", { section = sectionId }) end)
                end
                -- Check if enough breaches for breach phase
                local breachCount = 0
                for _, w in ipairs(activeSiege.walls) do
                    if w.breached then breachCount = breachCount + 1 end
                end
                if breachCount >= 2 and activeSiege.phase ~= "breach" then
                    activeSiege.phase = "breach"
                    if _G.ModernUI then
                        _G.ModernUI.notifySuccess("Faza: Preboj! Vdor v grad!")
                    end
                end
            end
            activeSiege.totalDamageDealt = activeSiege.totalDamageDealt + damage
            return
        end
    end
end

-- Cut supply (starve defenders)
function Siege.cutSupply()
    if not activeSiege or activeSiege.supplyCut then return false end
    activeSiege.supplyCut = true
    if _G.ModernUI then
        _G.ModernUI.notifyInfo("Oskrba presekana! Branitelji trpijo")
    end
    return true
end

-- Offer surrender terms
function Siege.offerSurrender()
    if not activeSiege then return false end
    -- Defender surrender chance based on morale and supply
    local surrenderChance = (100 - activeSiege.defenderMorale) / 100
    if activeSiege.supplyCut then surrenderChance = surrenderChance + 0.2 end
    -- Count breaches
    local breachCount = 0
    for _, w in ipairs(activeSiege.walls) do
        if w.breached then breachCount = breachCount + 1 end
    end
    surrenderChance = surrenderChance + breachCount * 0.1

    if math.random() < surrenderChance then
        activeSiege.surrendered = true
        if _G.ModernUI then
            _G.ModernUI.notifySuccess("Branitelji so se predali!")
        end
        Siege._end(true)
        return true
    else
        if _G.ModernUI then
            _G.ModernUI.notifyInfo("Branitelji zavrnili predajo")
        end
        activeSiege.defenderMorale = activeSiege.defenderMorale - 5  -- rejection lowers morale
        return false
    end
end

-- End siege
function Siege._end(success)
    if not activeSiege then return end
    table.insert(siegeHistory, {
        targetFaction = activeSiege.targetFaction,
        success = success,
        duration = activeSiege.siegeDuration,
        surrendered = activeSiege.surrendered,
        damageDealt = activeSiege.totalDamageDealt,
        damageReceived = activeSiege.totalDamageReceived,
        breaches = 0,
        timestamp = os.time(),
    })
    -- Count breaches
    for _, w in ipairs(activeSiege.walls) do
        if w.breached then siegeHistory[#siegeHistory].breaches = siegeHistory[#siegeHistory].breaches + 1 end
    end
    while #siegeHistory > maxHistory do table.remove(siegeHistory, 1) end

    if _G.SoundtrackMgr then
        pcall(function() _G.SoundtrackMgr.setMood(success and "victory" or "peace") end)
    end
    if _G.GameEventBus then
        pcall(function() _G.GameEventBus.emit("siege_ended", { success = success }) end)
    end

    activeSiege = nil
end

-- Update
function Siege.update(dt)
    if not initialized or not activeSiege then return end

    activeSiege.siegeDuration = activeSiege.siegeDuration + dt
    activeSiege.phaseTimer = activeSiege.phaseTimer + dt

    -- Supply cut attrition
    if activeSiege.supplyCut then
        activeSiege.defenderMorale = math.max(0, activeSiege.defenderMorale - dt * 0.5)
    end

    -- Morale checks
    if activeSiege.defenderMorale <= 0 then
        if _G.ModernUI then
            _G.ModernUI.notifySuccess("Branitelji izgubili moralo — predaja!")
        end
        Siege._end(true)
        return
    end
    if activeSiege.attackerMorale <= 0 then
        if _G.ModernUI then
            _G.ModernUI.notifyError("Napadalci izgubili moralo — obleganje spodletelo!")
        end
        Siege._end(false)
        return
    end

    -- Update deployed equipment
    for i = #activeSiege.deployedEquipment, 1, -1 do
        local equip = activeSiege.deployedEquipment[i]
        if not equip.ready then
            equip.timeRemaining = equip.timeRemaining - dt
            if equip.timeRemaining <= 0 then
                equip.ready = true
                if _G.ModernUI then
                    _G.ModernUI.notifySuccess(EQUIPMENT[equip.type].name .. " pripravljen!")
                end
            end
        else
            -- Equipment deals damage over time
            if equip.uses > 0 then
                local damagePerSecond = 0
                if equip.type == "catapult" then damagePerSecond = 5
                elseif equip.type == "trebuchet" then damagePerSecond = 8
                elseif equip.type == "battering_ram" then damagePerSecond = 10
                end
                if damagePerSecond > 0 then
                    Siege._damageWall(equip.targetSection, damagePerSecond * dt)
                end
                -- Reduce uses over time
                equip.uses = equip.uses - dt * 0.1
                if equip.uses <= 0 then
                    table.remove(activeSiege.deployedEquipment, i)
                end
            end
        end
    end

    -- Auto-advance phases based on time
    local phaseDurations = { approach = 30, bombard = 120, assault = 60, breach = 999 }
    if activeSiege.phaseTimer > (phaseDurations[activeSiege.phase] or 60) then
        if activeSiege.phase ~= "breach" then
            Siege._advancePhase()
        end
    end
end

-- Get siege state
function Siege.getState()
    if not activeSiege then return nil end
    local breachCount = 0
    local avgIntegrity = 0
    for _, w in ipairs(activeSiege.walls) do
        if w.breached then breachCount = breachCount + 1 end
        avgIntegrity = avgIntegrity + (w.integrity / w.maxIntegrity)
    end
    avgIntegrity = avgIntegrity / #activeSiege.walls * 100

    return {
        phase = activeSiege.phase,
        phaseName = PHASES[activeSiege.phase].name,
        phaseDesc = PHASES[activeSiege.phase].desc,
        phaseTimer = math.floor(activeSiege.phaseTimer),
        siegeDuration = math.floor(activeSiege.siegeDuration),
        defenderMorale = math.floor(activeSiege.defenderMorale),
        attackerMorale = math.floor(activeSiege.attackerMorale),
        avgWallIntegrity = math.floor(avgIntegrity),
        breachCount = breachCount,
        totalWalls = #activeSiege.walls,
        deployedEquipment = #activeSiege.deployedEquipment,
        supplyCut = activeSiege.supplyCut,
        surrendered = activeSiege.surrendered,
    }
end

-- Get wall sections
function Siege.getWalls()
    if not activeSiege then return {} end
    return activeSiege.walls
end

-- Get history
function Siege.getHistory(limit)
    local result = {}
    limit = limit or 10
    for i = math.max(1, #siegeHistory - limit + 1), #siegeHistory do
        table.insert(result, siegeHistory[i])
    end
    return result
end

-- Get stats
function Siege.getStats()
    local wins = 0
    local total = #siegeHistory
    for _, s in ipairs(siegeHistory) do
        if s.success then wins = wins + 1 end
    end
    return {
        activeSiege = activeSiege ~= nil,
        totalSieges = total,
        wins = wins,
        losses = total - wins,
        winRate = total > 0 and math.floor(wins / total * 100) or 0,
        equipmentTypes = Siege._getEquipmentCount(),
        defenseTypes = 4,
    }
end

return Siege
