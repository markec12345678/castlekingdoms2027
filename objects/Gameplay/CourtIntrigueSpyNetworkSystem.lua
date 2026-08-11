-- objects/Gameplay/CourtIntrigueSpyNetworkSystem.lua
-- Castle Kingdoms 2027 v3.2.5 - Court Intrigue & Spy Network System
--
-- Advanced espionage system: spy network management, infiltration, sabotage,
-- assassination, and counter-intelligence.
--
-- Features:
-- - 6 spy types (courtesan, monk, merchant, jester, servant, master spy)
-- - 8 mission types (infiltrate, sabotage, assassinate, steal, forge, blackmail, spread rumors, recon)
-- - Spy network (manage multiple spies)
-- - Counter-intelligence (catch enemy spies)
-- - Spy skill progression
-- - Cover system (spies can be discovered)
-- - Blackmail material
-- - Court rumors

local Intrigue = {}

-- ============================================================
-- SPY TYPES
-- ============================================================
local SPY_TYPES = {
    courtesan = {
        name = "Dvorna dama",
        nameEn = "Courtesan",
        baseSkill = 60,
        coverBonus = 30,
        cost = 500,
        upkeep = 20,
        missions = { "spread_rumors", "blackmail", "steal" },
        description = "Dostop do zasebnih dogodkov na dvoru.",
    },
    monk = {
        name = "Menih",
        nameEn = "Monk",
        baseSkill = 50,
        coverBonus = 40,
        cost = 200,
        upkeep = 5,
        missions = { "infiltrate", "forge", "recon" },
        description = "Vstopi v samostan, dostop do dokumentov.",
    },
    merchant = {
        name = "Trgovec",
        nameEn = "Merchant",
        baseSkill = 55,
        coverBonus = 25,
        cost = 300,
        upkeep = 10,
        missions = { "recon", "steal", "sabotage" },
        description = "Potuje prosto, zbirá informacije.",
    },
    jester = {
        name = "Norček",
        nameEn = "Jester",
        baseSkill = 65,
        coverBonus = 50,
        cost = 400,
        upkeep = 15,
        missions = { "spread_rumors", "blackmail", "assassinate" },
        description = "Nihče ne sumi neumnega norčka.",
    },
    servant = {
        name = "Služabnik",
        nameEn = "Servant",
        baseSkill = 45,
        coverBonus = 35,
        cost = 100,
        upkeep = 3,
        missions = { "infiltrate", "steal", "sabotage" },
        description = "Neopazen v vsakdanjem delu.",
    },
    master_spy = {
        name = "Mojster vohun",
        nameEn = "Master Spy",
        baseSkill = 90,
        coverBonus = 60,
        cost = 2000,
        upkeep = 50,
        missions = { "infiltrate", "sabotage", "assassinate", "steal", "forge", "blackmail", "spread_rumors", "recon" },
        description = "Profesionalni vohun z vsemi spretnostmi.",
    },
}

-- ============================================================
-- MISSION TYPES
-- ============================================================
local MISSION_TYPES = {
    infiltrate = {
        name = "Infiltriraj",
        nameEn = "Infiltrate",
        duration = 30,        -- days
        baseSuccess = 0.70,
        detectionChance = 0.20,
        reward = { info = 50 },
        description = "Vstopi v sovražnikovo notranjost.",
    },
    sabotage = {
        name = "Sabotaža",
        nameEn = "Sabotage",
        duration = 14,
        baseSuccess = 0.55,
        detectionChance = 0.30,
        reward = { goldDamage = 500 },
        description = "Poškoduj sovražnikove zgradbe ali zaloge.",
    },
    assassinate = {
        name = "Atentat",
        nameEn = "Assassinate",
        duration = 7,
        baseSuccess = 0.30,
        detectionChance = 0.50,
        reward = { targetKilled = true },
        description = "Ubij cilj (visoko tveganje).",
    },
    steal = {
        name = "Kraja",
        nameEn = "Steal",
        duration = 10,
        baseSuccess = 0.65,
        detectionChance = 0.25,
        reward = { gold = 300 },
        description = "Ukradi zlato ali dokumente.",
    },
    forge = {
        name = "Ponarejanje",
        nameEn = "Forge",
        duration = 14,
        baseSuccess = 0.60,
        detectionChance = 0.20,
        reward = { forgedDocument = true },
        description = "Ponarej pismo ali dokument.",
    },
    blackmail = {
        name = "Izsiljevanje",
        nameEn = "Blackmail",
        duration = 21,
        baseSuccess = 0.50,
        detectionChance = 0.35,
        reward = { gold = 1000, leverage = 1 },
        description = "Pridobi kompromitativne informacije.",
    },
    spread_rumors = {
        name = "Širjenje govoric",
        nameEn = "Spread Rumors",
        duration = 7,
        baseSuccess = 0.80,
        detectionChance = 0.15,
        reward = { targetHappinessLoss = 10 },
        description = "Poškoduj sovražnikov ugled.",
    },
    recon = {
        name = "Izvidnica",
        nameEn = "Reconnaissance",
        duration = 5,
        baseSuccess = 0.85,
        detectionChance = 0.10,
        reward = { info = 100 },
        description = "Zberi informacije o sovražniku.",
    },
}

-- ============================================================
-- STATE
-- ============================================================
Intrigue.spies = {}                    -- Player's spies
Intrigue.activeMissions = {}           -- Ongoing missions
Intrigue.caughtEnemySpies = {}         -- Captured enemy spies
Intrigue.blackmailMaterial = {}        -- Collected blackmail
Intrigue.rumorsSpread = {}             -- Rumors player has spread
Intrigue.counterIntelLevel = 30        -- 0-100, chance to catch enemy spies
Intrigue.totalMissionsRun = 0
Intrigue.totalSuccesses = 0
Intrigue.totalFailures = 0
Intrigue.totalSpiesLost = 0
Intrigue.totalEnemySpiesCaught = 0
Intrigue.dayTimer = 0

-- ============================================================
-- INITIALIZATION
-- ============================================================
function Intrigue.init()
    Intrigue.spies = {}
    Intrigue.activeMissions = {}
    Intrigue.caughtEnemySpies = {}
    Intrigue.blackmailMaterial = {}
    Intrigue.rumorsSpread = {}
    Intrigue.counterIntelLevel = 30
    Intrigue.totalMissionsRun = 0
    Intrigue.totalSuccesses = 0
    Intrigue.totalFailures = 0
    Intrigue.totalSpiesLost = 0
    Intrigue.totalEnemySpiesCaught = 0
    Intrigue.dayTimer = 0
    print("[Intrigue] Court Intrigue & Spy Network System initialized (6 spy types, 8 missions)")
end

-- ============================================================
-- SPY RECRUITMENT
-- ============================================================
function Intrigue.canRecruit(spyType)
    local def = SPY_TYPES[spyType]
    if not def then return false, "Neznan tip vohuna" end
    if not _G.state or (_G.state.gold or 0) < def.cost then
        return false, "Premalo zlata"
    end
    return true
end

function Intrigue.recruitSpy(spyType, customName)
    local ok, err = Intrigue.canRecruit(spyType)
    if not ok then return false, err end
    local def = SPY_TYPES[spyType]
    _G.state.gold = _G.state.gold - def.cost
    local spy = {
        id = "spy_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        type = spyType,
        name = customName or ("Vohun " .. math.random(1, 999)),
        skill = def.baseSkill + math.random(-10, 15),
        cover = def.coverBonus,
        maxCover = 100,
        status = "idle",  -- idle, on_mission, captured, dead, extracted
        missionsCompleted = 0,
        missionsFailed = 0,
        recruitedDay = os.time(),
    }
    table.insert(Intrigue.spies, spy)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Vohun rekrutiran: %s (%s, spretnost %d)",
                spy.name, def.name, spy.skill), "success")
    end
    return true, spy.id
end

function Intrigue.findSpy(spyId)
    for _, s in ipairs(Intrigue.spies) do
        if s.id == spyId then return s end
    end
    return nil
end

-- ============================================================
-- MISSION MANAGEMENT
-- ============================================================
function Intrigue.canStartMission(spyId, missionType, targetFaction)
    local spy = Intrigue.findSpy(spyId)
    if not spy then return false, "Vohun ne obstaja" end
    if spy.status ~= "idle" then return false, "Vohun ni prost" end
    local def = MISSION_TYPES[missionType]
    if not def then return false, "Neznana misija" end
    -- Check if spy can do this mission
    local spyDef = SPY_TYPES[spy.type]
    if spyDef and spyDef.missions then
        local canDo = false
        for _, m in ipairs(spyDef.missions) do
            if m == missionType then canDo = true; break end
        end
        if not canDo then return false, "Ta vohun ne more izvesti te misije" end
    end
    return true
end

function Intrigue.startMission(spyId, missionType, targetFaction)
    local ok, err = Intrigue.canStartMission(spyId, missionType, targetFaction)
    if not ok then return false, err end
    local spy = Intrigue.findSpy(spyId)
    local def = MISSION_TYPES[missionType]
    -- Calculate success chance
    local successChance = def.baseSuccess + (spy.skill / 200)
    successChance = math.max(0.05, math.min(0.95, successChance))
    -- Detection chance
    local detectionChance = def.detectionChance - (spy.cover / 200)
    detectionChance = math.max(0.02, detectionChance)
    local mission = {
        id = "mission_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        spyId = spyId,
        spyName = spy.name,
        missionType = missionType,
        missionName = def.name,
        targetFaction = targetFaction or "unknown",
        daysRemaining = def.duration,
        totalDays = def.duration,
        successChance = successChance,
        detectionChance = detectionChance,
        reward = def.reward,
        started = os.time(),
    }
    spy.status = "on_mission"
    table.insert(Intrigue.activeMissions, mission)
    Intrigue.totalMissionsRun = Intrigue.totalMissionsRun + 1
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Misija začeta: %s (%s → %s, %.0f%% uspeha)",
                def.name, spy.name, tostring(targetFaction), successChance * 100), "info")
    end
    return true, mission.id
end

function Intrigue.resolveMission(mission)
    local spy = Intrigue.findSpy(mission.spyId)
    if not spy then return end
    -- Roll success
    local success = math.random() < mission.successChance
    local detected = math.random() < mission.detectionChance
    if success and not detected then
        -- Mission succeeded
        Intrigue.totalSuccesses = Intrigue.totalSuccesses + 1
        spy.missionsCompleted = spy.missionsCompleted + 1
        spy.skill = math.min(100, spy.skill + 2)
        spy.cover = math.max(0, spy.cover - 5)
        spy.status = "idle"
        -- Apply rewards
        local r = mission.reward or {}
        if r.gold and _G.state then
            _G.state.gold = (_G.state.gold or 0) + r.gold
        end
        if r.goldDamage and _G.DiplomacyController then
            -- Damage enemy economy
            pcall(_G.DiplomacyController.changeRelation, mission.targetFaction, -5)
        end
        if r.targetHappinessLoss and _G.DiplomacyController then
            pcall(_G.DiplomacyController.changeRelation, mission.targetFaction, -3)
        end
        if r.leverage then
            table.insert(Intrigue.blackmailMaterial, {
                target = mission.targetFaction,
                acquiredDay = os.time(),
                value = 50,
            })
        end
        if r.forgedDocument then
            table.insert(Intrigue.blackmailMaterial, {
                target = mission.targetFaction,
                acquiredDay = os.time(),
                value = 30,
                type = "forged",
            })
        end
        if _G.NotificationCenter then
            pcall(_G.NotificationCenter.notify,
                string.format("MISIJA USPELA: %s (%s)", mission.missionName, spy.name), "success")
        end
        if _G.GameEventBus then
            pcall(_G.GameEventBus.publish, "SPY_MISSION_SUCCESS", {
                missionType = mission.missionType, target = mission.targetFaction,
            })
        end
    else
        -- Mission failed
        Intrigue.totalFailures = Intrigue.totalFailures + 1
        spy.missionsFailed = spy.missionsFailed + 1
        if detected then
            -- Spy caught
            spy.status = "captured"
            Intrigue.totalSpiesLost = Intrigue.totalSpiesLost + 1
            -- Diplomatic hit
            if _G.DiplomacyController then
                pcall(_G.DiplomacyController.changeRelation, mission.targetFaction, -20)
            end
            if _G.NotificationCenter then
                pcall(_G.NotificationCenter.notify,
                    string.format("VOHUN UJET! %s pri %s", spy.name, tostring(mission.targetFaction)), "danger")
            end
            if _G.GameEventBus then
                pcall(_G.GameEventBus.publish, "SPY_CAPTURED", {
                    spyName = spy.name, target = mission.targetFaction,
                })
            end
        else
            -- Just failed, spy returns
            spy.status = "idle"
            spy.cover = math.max(0, spy.cover - 15)
            if _G.NotificationCenter then
                pcall(_G.NotificationCenter.notify,
                    string.format("Misija spodletela: %s", mission.missionName), "warning")
            end
        end
    end
end

-- ============================================================
-- COUNTER-INTELLIGENCE
-- ============================================================
function Intrigue.checkForEnemySpies()
    -- Random chance of enemy spy infiltration
    if math.random() < 0.05 then
        -- Enemy spy infiltrated
        local caught = math.random() < (Intrigue.counterIntelLevel / 100)
        if caught then
            Intrigue.totalEnemySpiesCaught = Intrigue.totalEnemySpiesCaught + 1
            table.insert(Intrigue.caughtEnemySpies, {
                capturedDay = os.time(),
                faction = "unknown",
                interrogated = false,
            })
            if _G.NotificationCenter then
                pcall(_G.NotificationCenter.notify,
                    "Ujet sovražnikov vohun!", "success")
            end
        else
            -- Enemy spy succeeded — small damage
            if _G.state and _G.state.gold then
                local stolen = math.random(50, 300)
                _G.state.gold = math.max(0, _G.state.gold - stolen)
            end
            if _G.NotificationCenter then
                pcall(_G.NotificationCenter.notify,
                    "Sovražnikov vohun ukradel zlato!", "warning")
            end
        end
    end
end

function Intrigue.interrogateSpy(spyIdx)
    local spy = Intrigue.caughtEnemySpies[spyIdx]
    if not spy or spy.interrogated then return false end
    spy.interrogated = true
    -- Gain counter-intel boost
    Intrigue.counterIntelLevel = math.min(100, Intrigue.counterIntelLevel + 5)
    -- Random info
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            "Vohun zaslišan. +5 protiobveščevalne ravni.", "info")
    end
    return true
end

function Intrigue.buildCounterIntel()
    if not _G.state or (_G.state.gold or 0) < 800 then
        return false, "Premalo zlata"
    end
    _G.state.gold = _G.state.gold - 800
    Intrigue.counterIntelLevel = math.min(100, Intrigue.counterIntelLevel + 15)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Protiobveščevalna mreža okrepita!", "success")
    end
    return true
end

-- ============================================================
-- BLACKMAIL
-- ============================================================
function Intrigue.useBlackmail(idx)
    local material = Intrigue.blackmailMaterial[idx]
    if not material then return false end
    -- Apply leverage — gain gold or relation
    local gain = material.value * 10
    if _G.state then
        _G.state.gold = (_G.state.gold or 0) + gain
    end
    -- Damage relations
    if _G.DiplomacyController and material.target then
        pcall(_G.DiplomacyController.changeRelation, material.target, -10)
    end
    table.remove(Intrigue.blackmailMaterial, idx)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Izsiljevanje uporabljeno! +%d zlata", gain), "success")
    end
    return true
end

-- ============================================================
-- UPDATE
-- ============================================================
function Intrigue.update(dt)
    if not _G.state then return end
    Intrigue.dayTimer = Intrigue.dayTimer + dt
    if Intrigue.dayTimer >= 30 then
        Intrigue.dayTimer = 0
        -- Process active missions
        for i = #Intrigue.activeMissions, 1, -1 do
            local m = Intrigue.activeMissions[i]
            m.daysRemaining = m.daysRemaining - 1
            if m.daysRemaining <= 0 then
                Intrigue.resolveMission(m)
                table.remove(Intrigue.activeMissions, i)
            end
        end
        -- Check for enemy spies
        Intrigue.checkForEnemySpies()
        -- Pay upkeep
        local totalUpkeep = 0
        for _, s in ipairs(Intrigue.spies) do
            if s.status == "idle" or s.status == "on_mission" then
                local def = SPY_TYPES[s.type]
                if def then totalUpkeep = totalUpkeep + def.upkeep end
            end
        end
        if totalUpkeep > 0 and _G.state then
            _G.state.gold = math.max(0, (_G.state.gold or 0) - totalUpkeep)
        end
        -- Counter-intel slowly decays
        if Intrigue.counterIntelLevel > 30 then
            Intrigue.counterIntelLevel = Intrigue.counterIntelLevel - 0.5
        end
    end
end

-- ============================================================
-- HELPERS
-- ============================================================
function Intrigue.getSpyTypeInfo(typeId) return SPY_TYPES[typeId] end
function Intrigue.getMissionTypeInfo(typeId) return MISSION_TYPES[typeId] end
function Intrigue.getSpies() return Intrigue.spies end

function Intrigue.getStats()
    return {
        numSpies = #Intrigue.spies,
        activeMissions = #Intrigue.activeMissions,
        totalMissions = Intrigue.totalMissionsRun,
        totalSuccesses = Intrigue.totalSuccesses,
        totalFailures = Intrigue.totalFailures,
        totalSpiesLost = Intrigue.totalSpiesLost,
        totalEnemySpiesCaught = Intrigue.totalEnemySpiesCaught,
        counterIntelLevel = Intrigue.counterIntelLevel,
        blackmailMaterial = #Intrigue.blackmailMaterial,
        caughtEnemySpies = #Intrigue.caughtEnemySpies,
    }
end

return Intrigue
