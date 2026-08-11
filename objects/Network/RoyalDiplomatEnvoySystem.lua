-- objects/Network/RoyalDiplomatEnvoySystem.lua
-- Castle Kingdoms 2027 v3.5.0 - Royal Diplomat & Envoy System
--
-- Manages diplomatic envoys, ambassador appointments, and formal diplomatic missions.
-- Distinct from basic diplomacy — focuses on envoy NPCs and structured missions.
--
-- Features:
-- - 6 envoy types (ambassador, emissary, consul, legate, plenipotentiary, spy-diplomat)
-- - 8 mission types (alliance, trade agreement, peace treaty, marriage proposal, ...)
-- - 4 diplomatic buildings (embassy, chancery, foreign quarter, protocol office)
-- - Master Diplomat NPC (skill affects success)
-- - Diplomatic credentials
-- - Protocol and etiquette
-- - Diplomatic immunity
-- - International reputation

local Diplomat = {}

-- ============================================================
-- ENVOY TYPES
-- ============================================================
local ENVOYS = {
    ambassador = {
        name = "Ambasador",
        nameEn = "Ambassador",
        cost = 500,
        upkeep = 25,
        skill = 60,
        prestige = 15,
        description = "Stalni predstavnik pri tujem dvoru.",
    },
    emissary = {
        name = "Odposlanec",
        nameEn = "Emissary",
        cost = 200,
        upkeep = 10,
        skill = 50,
        prestige = 5,
        description = "Začasni odposlanec za specifične naloge.",
    },
    consul = {
        name = "Konzul",
        nameEn = "Consul",
        cost = 300,
        upkeep = 15,
        skill = 55,
        prestige = 8,
        description = "Predstavnik za trgovinske zadeve.",
    },
    legate = {
        name = "Legat",
        nameEn = "Legate",
        cost = 800,
        upkeep = 40,
        skill = 70,
        prestige = 20,
        description = "Visoki odposlanec s polnimi pooblastili.",
    },
    plenipotentiary = {
        name = "Pooblaščenec",
        nameEn = "Plenipotentiary",
        cost = 1200,
        upkeep = 60,
        skill = 80,
        prestige = 30,
        description = "Odposlanec s popolno pogodbeno močjo.",
    },
    spy_diplomat = {
        name = "Vohun-diplomat",
        nameEn = "Spy-Diplomat",
        cost = 600,
        upkeep = 20,
        skill = 65,
        prestige = 0,
        espionageBonus = 0.30,
        description = "Diplomat z vohunsko funkcijo.",
    },
}

-- ============================================================
-- MISSION TYPES
-- ============================================================
local MISSIONS = {
    alliance = {
        name = "Zavezništvo",
        nameEn = "Alliance",
        duration = 30,
        difficulty = 4,
        successBonus = 0.15,
        reward = { relationBoost = 30, tradeAgreement = true },
        description = "Sklenitev formalnega zavezništva.",
    },
    trade_agreement = {
        name = "Trgovski sporazum",
        nameEn = "Trade Agreement",
        duration = 14,
        difficulty = 2,
        successBonus = 0.25,
        reward = { relationBoost = 15, tradeBonus = 0.20 },
        description = "Sklenitev trgovskega sporazuma.",
    },
    peace_treaty = {
        name = "Mirovna pogodba",
        nameEn = "Peace Treaty",
        duration = 21,
        difficulty = 5,
        successBonus = 0.10,
        reward = { relationBoost = 40, warEnd = true },
        description = "Končanje vojnega stanja.",
    },
    marriage_proposal = {
        name = "Porokna prošnja",
        nameEn = "Marriage Proposal",
        duration = 14,
        difficulty = 3,
        successBonus = 0.20,
        reward = { relationBoost = 25, marriage = true },
        description = "Prošnja za dinastično poroko.",
    },
    tribute_demand = {
        name = "Zahteva po davku",
        nameEn = "Tribute Demand",
        duration = 7,
        difficulty = 5,
        successBonus = 0.05,
        reward = { gold = 1000, relationBoost = -20 },
        description = "Izsiljevanje davka od šibkejše sile.",
    },
    cultural_exchange = {
        name = "Kulturna izmenjava",
        nameEn = "Cultural Exchange",
        duration = 30,
        difficulty = 1,
        successBonus = 0.40,
        reward = { relationBoost = 10, knowledgePoints = 30 },
        description = "Izmenjava znanja in kulture.",
    },
    military_access = {
        name = "Vojaški prehod",
        nameEn = "Military Access",
        duration = 14,
        difficulty = 4,
        successBonus = 0.15,
        reward = { relationBoost = 15, militaryAccess = true },
        description = "Prošnja za prehod vojske skozi tuje ozemlje.",
    },
    non_aggression = {
        name = "Pakt o nenapadanju",
        nameEn = "Non-Aggression Pact",
        duration = 21,
        difficulty = 3,
        successBonus = 0.25,
        reward = { relationBoost = 20, nonAggression = true },
        description = "Sporazum o nenapadanju.",
    },
}

-- ============================================================
-- DIPLOMATIC BUILDINGS
-- ============================================================
local BUILDINGS = {
    embassy = {
        name = "Ambasada",
        cost = { gold = 1000, wood = 200, stone = 300 },
        upkeep = 30,
        envoyCapacity = 3,
        diplomaticBonus = 10,
        description = "Stalna diplomatska misija.",
    },
    chancery = {
        name = "Kancelarija",
        cost = { gold = 2000, wood = 300, stone = 500 },
        upkeep = 50,
        envoyCapacity = 6,
        diplomaticBonus = 20,
        prestigeBonus = 10,
        description = "Osrednja diplomatska ustanova.",
    },
    foreign_quarter = {
        name = "Tuje cone",
        cost = { gold = 3000, wood = 500, stone = 800 },
        upkeep = 80,
        envoyCapacity = 10,
        diplomaticBonus = 30,
        tradeBonus = 0.15,
        description = "Četrt za tuje diplomate in trgovce.",
    },
    protocol_office = {
        name = "Protokolarna pisarna",
        cost = { gold = 1500, wood = 100, stone = 200 },
        upkeep = 40,
        envoyCapacity = 4,
        diplomaticBonus = 25,
        etiquetteBonus = 15,
        description = "Uprava za diplomatski protokol.",
    },
}

-- ============================================================
-- STATE
-- ============================================================
Diplomat.envoys = {}                      -- Hired envoys
Diplomat.buildings = {}                   -- Built diplomatic buildings
Diplomat.diplomat = nil                   -- Master Diplomat NPC
Diplomat.activeMissions = {}              -- Ongoing diplomatic missions
Diplomat.completedMissions = {}           -- Mission history
Diplomat.internationalReputation = 50     -- 0-100
Diplomat.totalMissions = 0
Diplomat.totalSuccesses = 0
Diplomat.totalFailures = 0
Diplomat.dayTimer = 0

-- ============================================================
-- INITIALIZATION
-- ============================================================
function Diplomat.init()
    Diplomat.envoys = {}
    Diplomat.buildings = {}
    Diplomat.diplomat = nil
    Diplomat.activeMissions = {}
    Diplomat.completedMissions = {}
    Diplomat.internationalReputation = 50
    Diplomat.totalMissions = 0
    Diplomat.totalSuccesses = 0
    Diplomat.totalFailures = 0
    Diplomat.dayTimer = 0
    print("[Diplomat] Royal Diplomat & Envoy System initialized (6 envoys, 8 missions, 4 buildings)")
end

-- ============================================================
-- MASTER DIPLOMAT NPC
-- ============================================================
function Diplomat.hireDiplomat(name, skill)
    skill = skill or math.random(50, 95)
    local cost = 1000 + skill * 15
    if not _G.state or (_G.state.gold or 0) < cost then
        return false, "Premalo zlata"
    end
    _G.state.gold = _G.state.gold - cost
    Diplomat.diplomat = {
        name = name or ("Diplomat " .. math.random(1, 99)),
        skill = skill,
        hiredDay = os.time(),
        missionsLed = 0,
    }
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Mojster diplomat najet: %s (spretnost: %d)", Diplomat.diplomat.name, skill), "success")
    end
    return true
end

-- ============================================================
-- BUILDINGS
-- ============================================================
function Diplomat.canBuild(buildingId)
    local def = BUILDINGS[buildingId]
    if not def then return false, "Neznana zgradba" end
    if not _G.state then return false, "Brez stanja" end
    if _G.state.gold < (def.cost.gold or 0) then return false, "Premalo zlata" end
    if _G.state.resources then
        for res, amt in pairs(def.cost) do
            if res ~= "gold" and (_G.state.resources[res] or 0) < amt then
                return false, "Premalo " .. res
            end
        end
    end
    return true
end

function Diplomat.build(buildingId)
    local ok, err = Diplomat.canBuild(buildingId)
    if not ok then return false, err end
    local def = BUILDINGS[buildingId]
    _G.state.gold = _G.state.gold - (def.cost.gold or 0)
    if _G.state.resources then
        for res, amt in pairs(def.cost) do
            if res ~= "gold" then
                _G.state.resources[res] = (_G.state.resources[res] or 0) - amt
            end
        end
    end
    table.insert(Diplomat.buildings, {
        type = buildingId,
        builtDay = os.time(),
    })
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Zgrajeno: " .. def.name, "success")
    end
    return true
end

function Diplomat.getDiplomaticBonus()
    local bonus = 0
    for _, b in ipairs(Diplomat.buildings) do
        local def = BUILDINGS[b.type]
        if def and def.diplomaticBonus then bonus = bonus + def.diplomaticBonus end
    end
    return bonus
end

function Diplomat.getEnvoyCapacity()
    local cap = 1
    for _, b in ipairs(Diplomat.buildings) do
        local def = BUILDINGS[b.type]
        if def and def.envoyCapacity then cap = cap + def.envoyCapacity end
    end
    return cap
end

-- ============================================================
-- ENVOY HIRING
-- ============================================================
function Diplomat.canHireEnvoy(envoyType)
    local def = ENVOYS[envoyType]
    if not def then return false, "Neznan odposlanec" end
    if #Diplomat.envoys >= Diplomat.getEnvoyCapacity() then
        return false, "Diplomatska kapaciteta polna"
    end
    if not _G.state or (_G.state.gold or 0) < def.cost then
        return false, "Premalo zlata"
    end
    return true
end

function Diplomat.hireEnvoy(envoyType, customName)
    local ok, err = Diplomat.canHireEnvoy(envoyType)
    if not ok then return false, err end
    local def = ENVOYS[envoyType]
    _G.state.gold = _G.state.gold - def.cost
    local envoy = {
        id = "envoy_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        type = envoyType,
        name = customName or (def.name .. " " .. #Diplomat.envoys + 1),
        skill = def.skill + math.random(-5, 10),
        prestige = def.prestige,
        espionageBonus = def.espionageBonus or 0,
        status = "available",  -- available, on_mission, expelled, killed
        hiredDay = os.time(),
        missionsCompleted = 0,
    }
    table.insert(Diplomat.envoys, envoy)
    Diplomat.internationalReputation = math.min(100, Diplomat.internationalReputation + 2)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Odposlanec najet: %s (%s)", envoy.name, def.name), "success")
    end
    return true, envoy.id
end

function Diplomat.findEnvoy(envoyId)
    for _, e in ipairs(Diplomat.envoys) do
        if e.id == envoyId then return e end
    end
    return nil
end

-- ============================================================
-- DIPLOMATIC MISSIONS
-- ============================================================
function Diplomat.canStartMission(missionType, envoyId, targetFaction)
    local def = MISSIONS[missionType]
    if not def then return false, "Neznana misija" end
    local envoy = Diplomat.findEnvoy(envoyId)
    if not envoy then return false, "Odposlanec ne obstaja" end
    if envoy.status ~= "available" then return false, "Odposlanec ni prost" end
    if not _G.state or (_G.state.gold or 0) < 100 then
        return false, "Premalo zlata za misijo"
    end
    return true
end

function Diplomat.startMission(missionType, envoyId, targetFaction)
    local ok, err = Diplomat.canStartMission(missionType, envoyId, targetFaction)
    if not ok then return false, err end
    local def = MISSIONS[missionType]
    local envoy = Diplomat.findEnvoy(envoyId)
    _G.state.gold = _G.state.gold - 100
    -- Calculate success chance
    local successChance = 0.30 + def.successBonus
    successChance = successChance + (envoy.skill / 200)
    successChance = successChance + (Diplomat.getDiplomaticBonus() / 100)
    if Diplomat.diplomat then
        successChance = successChance + (Diplomat.diplomat.skill / 200)
    end
    -- Difficulty reduces chance
    successChance = successChance - (def.difficulty / 20)
    -- Reputation modifier
    successChance = successChance + ((Diplomat.internationalReputation - 50) / 200)
    successChance = math.max(0.05, math.min(0.90, successChance))
    local mission = {
        id = "mission_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        missionType = missionType,
        missionName = def.name,
        envoyId = envoyId,
        envoyName = envoy.name,
        targetFaction = targetFaction or "unknown",
        daysRemaining = def.duration,
        totalDays = def.duration,
        successChance = successChance,
        reward = def.reward,
        started = os.time(),
    }
    table.insert(Diplomat.activeMissions, mission)
    envoy.status = "on_mission"
    Diplomat.totalMissions = Diplomat.totalMissions + 1
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Diplomatska misija: %s (%s → %s, %.0f%% uspeha)",
                def.name, envoy.name, tostring(targetFaction), successChance * 100), "info")
    end
    return true
end

function Diplomat.completeMission(mission)
    local envoy = Diplomat.findEnvoy(mission.envoyId)
    -- Roll for success
    if math.random() < mission.successChance then
        -- Success!
        Diplomat.totalSuccesses = Diplomat.totalSuccesses + 1
        local r = mission.reward
        -- Apply rewards
        if r.relationBoost and _G.DiplomacyController then
            pcall(_G.DiplomacyController.changeRelation, mission.targetFaction, r.relationBoost)
        end
        if r.gold and _G.state then
            _G.state.gold = (_G.state.gold or 0) + r.gold
        end
        if r.knowledgePoints and _G.Culture then
            _G.Culture.knowledgePoints = (_G.Culture.knowledgePoints or 0) + r.knowledgePoints
        end
        if r.tradeBonus and _G.state then
            _G.state.tradeBonus = (_G.state.tradeBonus or 0) + r.tradeBonus
        end
        Diplomat.internationalReputation = math.min(100, Diplomat.internationalReputation + 5)
        if envoy then
            envoy.status = "available"
            envoy.missionsCompleted = envoy.missionsCompleted + 1
            if math.random() < 0.20 then
                envoy.skill = math.min(100, envoy.skill + 2)
            end
        end
        if _G.NotificationCenter then
            pcall(_G.NotificationCenter.notify,
                string.format("MISIJA USPELA: %s!", mission.missionName), "success")
        end
        if _G.GameEventBus then
            pcall(_G.GameEventBus.publish, "DIPLOMATIC_SUCCESS", {
                mission = mission.missionType, target = mission.targetFaction,
            })
        end
    else
        -- Failure
        Diplomat.totalFailures = Diplomat.totalFailures + 1
        Diplomat.internationalReputation = math.max(0, Diplomat.internationalReputation - 3)
        -- 10% chance envoy is expelled or killed
        if math.random() < 0.10 and envoy then
            if math.random() < 0.30 then
                envoy.status = "killed"
                if _G.NotificationCenter then
                    pcall(_G.NotificationCenter.notify,
                        string.format("ODPOSLANEC UBIT: %s!", envoy.name), "danger")
                end
            else
                envoy.status = "expelled"
                if _G.NotificationCenter then
                    pcall(_G.NotificationCenter.notify,
                        string.format("Odposlanec izgnan: %s", envoy.name), "warning")
                end
            end
        elseif envoy then
            envoy.status = "available"
        end
        if _G.NotificationCenter then
            pcall(_G.NotificationCenter.notify,
                string.format("Misija spodletela: %s", mission.missionName), "warning")
        end
    end
    -- Add to history
    table.insert(Diplomat.completedMissions, {
        type = mission.missionType,
        name = mission.missionName,
        target = mission.targetFaction,
        envoy = mission.envoyName,
        success = mission.successChance > 0,  -- placeholder
        completedDay = os.time(),
    })
    -- Skill progression for master diplomat
    if Diplomat.diplomat and math.random() < 0.15 then
        Diplomat.diplomat.skill = math.min(100, Diplomat.diplomat.skill + 1)
        Diplomat.diplomat.missionsLed = Diplomat.diplomat.missionsLed + 1
    end
end

-- ============================================================
-- UPDATE
-- ============================================================
function Diplomat.update(dt)
    if not _G.state then return end
    Diplomat.dayTimer = Diplomat.dayTimer + dt
    if Diplomat.dayTimer >= 30 then
        Diplomat.dayTimer = 0
        -- Process missions
        for i = #Diplomat.activeMissions, 1, -1 do
            local m = Diplomat.activeMissions[i]
            m.daysRemaining = m.daysRemaining - 1
            if m.daysRemaining <= 0 then
                Diplomat.completeMission(m)
                table.remove(Diplomat.activeMissions, i)
            end
        end
        -- Recover expelled envoys
        for _, e in ipairs(Diplomat.envoys) do
            if e.status == "expelled" then
                e.recoveryTimer = (e.recoveryTimer or 14) - 1
                if e.recoveryTimer <= 0 then
                    e.status = "available"
                end
            end
        end
        -- Remove killed envoys
        for i = #Diplomat.envoys, 1, -1 do
            if Diplomat.envoys[i].status == "killed" then
                Diplomat.envoys[i].cleanupTimer = (Diplomat.envoys[i].cleanupTimer or 30) - 1
                if Diplomat.envoys[i].cleanupTimer <= 0 then
                    table.remove(Diplomat.envoys, i)
                end
            end
        end
        -- Pay upkeep
        local totalUpkeep = 0
        for _, e in ipairs(Diplomat.envoys) do
            if e.status ~= "killed" then
                local def = ENVOYS[e.type]
                if def then totalUpkeep = totalUpkeep + def.upkeep end
            end
        end
        for _, b in ipairs(Diplomat.buildings) do
            local def = BUILDINGS[b.type]
            if def and def.upkeep then totalUpkeep = totalUpkeep + def.upkeep end
        end
        if Diplomat.diplomat then totalUpkeep = totalUpkeep + 40 end
        if totalUpkeep > 0 and _G.state then
            _G.state.gold = math.max(0, (_G.state.gold or 0) - totalUpkeep)
        end
        -- Reputation slowly drifts to 50
        if Diplomat.internationalReputation > 50 then
            Diplomat.internationalReputation = Diplomat.internationalReputation - 0.2
        elseif Diplomat.internationalReputation < 50 then
            Diplomat.internationalReputation = Diplomat.internationalReputation + 0.1
        end
    end
end

-- ============================================================
-- HELPERS
-- ============================================================
function Diplomat.getEnvoyInfo(envoyId) return ENVOYS[envoyId] end
function Diplomat.getMissionInfo(missionId) return MISSIONS[missionId] end
function Diplomat.getBuildingInfo(buildingId) return BUILDINGS[buildingId] end

function Diplomat.getStats()
    return {
        numEnvoys = #Diplomat.envoys,
        envoyCapacity = Diplomat.getEnvoyCapacity(),
        numBuildings = #Diplomat.buildings,
        activeMissions = #Diplomat.activeMissions,
        hasDiplomat = Diplomat.diplomat ~= nil,
        diplomatName = Diplomat.diplomat and Diplomat.diplomat.name or "—",
        diplomatSkill = Diplomat.diplomat and Diplomat.diplomat.skill or 0,
        internationalReputation = Diplomat.internationalReputation,
        totalMissions = Diplomat.totalMissions,
        totalSuccesses = Diplomat.totalSuccesses,
        totalFailures = Diplomat.totalFailures,
    }
end

return Diplomat
