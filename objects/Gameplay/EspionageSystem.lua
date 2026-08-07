-- objects/Gameplay/EspionageSystem.lua
-- Castle Kingdoms 2027 v2.6.7 - Espionage & Intelligence System
--
-- Spy on enemy factions, gather intelligence, sabotage buildings.
-- Spies are trained at the Inn and can be sent on missions.
--
-- Mission types:
-- - Scout: reveal enemy territory and army composition
-- - Sabotage: destroy an enemy building
-- - Steal Gold: steal resources from enemy
-- - Assassinate: kill an enemy unit (Lord, Knight)
-- - Counter-spy: protect against enemy spies

local Espionage = {}

-- Mission definitions
local MISSIONS = {
    scout = {
        name = "Izvidnica",
        nameEn = "Scout",
        cost = { gold = 100 },
        duration = 30,  -- seconds
        successRate = 0.90,  -- 90% base success
        description = "Razkrij sovražnikovo ozemlje in sestavo vojske",
        reward = { intel = true },
    },
    sabotage = {
        name = "Sabotaža",
        nameEn = "Sabotage",
        cost = { gold = 300 },
        duration = 60,
        successRate = 0.60,
        description = "Uniči sovražnikovo zgradbo",
        reward = { destroyBuilding = true },
    },
    steal_gold = {
        name = "Kraja zlata",
        nameEn = "Steal Gold",
        cost = { gold = 50 },
        duration = 45,
        successRate = 0.75,
        description = "Ukradi zlato iz sovražnikove zakladnice",
        reward = { goldMin = 200, goldMax = 800 },
    },
    assassinate = {
        name = "Atentat",
        nameEn = "Assassinate",
        cost = { gold = 500 },
        duration = 90,
        successRate = 0.40,
        description = "Ubij sovražnikovega viteza ali gospodarja",
        reward = { killUnit = true },
    },
    counter_spy = {
        name = "Protio-bveščevalno",
        nameEn = "Counter-spy",
        cost = { gold = 150 },
        duration = 0,
        successRate = 1.0,
        description = "Zaščiti pred sovražnikovimi vohuni (24h)",
        reward = { protection = 86400 },  -- 24 hours in seconds
    },
}

Espionage.MISSIONS = MISSIONS

local initialized = false
local activeSpies = {}  -- list of active spy missions
local availableSpies = 0  -- number of spies available
local maxSpies = 3  -- max spies (based on Inns)
local protectionTimer = 0  -- counter-spy protection remaining
local intelGathered = {}  -- gathered intelligence per faction

function Espionage.init()
    if initialized then return end
    initialized = true
    print("[Espionage] Initialized with " .. Espionage._getMissionCount() .. " mission types")
end

function Espionage._getMissionCount()
    local count = 0
    for _ in pairs(MISSIONS) do count = count + 1 end
    return count
end

-- Count available Inns (each Inn = 1 spy slot)
function Espionage._updateMaxSpies()
    local innCount = 0
    if _G.state and _G.state.gameObjectList then
        for _, obj in ipairs(_G.state.gameObjectList) do
            if (not obj.faction or obj.faction == 1) and obj.class and obj.class.name == "Inn" then
                innCount = innCount + 1
            end
        end
    end
    maxSpies = math.min(5, innCount)  -- max 5 spies
end

-- Get current stats
function Espionage.getStats()
    Espionage._updateMaxSpies()
    return {
        availableSpies = availableSpies,
        maxSpies = maxSpies,
        activeSpies = #activeSpies,
        protectionActive = protectionTimer > 0,
        protectionRemaining = protectionTimer,
    }
end

-- Train a new spy (costs gold, takes time)
function Espionage.trainSpy()
    Espionage._updateMaxSpies()
    if availableSpies >= maxSpies then
        if _G.ModernUI then
            _G.ModernUI.notifyError("Dosežen maksimum vohunov (" .. maxSpies .. ")")
        end
        return false
    end
    if not _G.state or (_G.state.gold or 0) < 250 then
        if _G.ModernUI then
            _G.ModernUI.notifyError("Potrebnih 250 zlata za usposabljanje vohuna")
        end
        return false
    end
    _G.state.gold = (_G.state.gold or 0) - 250
    availableSpies = availableSpies + 1
    if _G.ModernUI then
        _G.ModernUI.notifySuccess("Vohun usposobljen! (" .. availableSpies .. "/" .. maxSpies .. ")")
    end
    if _G.VoiceOver then
        pcall(function() _G.VoiceOver.notify("unit_trained", "Vohun") end)
    end
    print("[Espionage] Spy trained (" .. availableSpies .. "/" .. maxSpies .. ")")
    return true
end

-- Send a spy on a mission
function Espionage.sendMission(missionType, targetFaction)
    if not MISSIONS[missionType] then
        return false, "Unknown mission type"
    end
    if availableSpies <= 0 then
        if _G.ModernUI then
            _G.ModernUI.notifyError("Ni razpoložljivih vohunov")
        end
        return false, "No spies available"
    end

    local mission = MISSIONS[missionType]
    if _G.state and mission.cost.gold and (_G.state.gold or 0) < mission.cost.gold then
        if _G.ModernUI then
            _G.ModernUI.notifyError("Ni dovolj zlata (" .. mission.cost.gold .. ")")
        end
        return false, "Not enough gold"
    end

    -- Deduct cost and spy
    if _G.state and mission.cost.gold then
        _G.state.gold = (_G.state.gold or 0) - mission.cost.gold
    end
    availableSpies = availableSpies - 1

    -- Create mission
    local spy = {
        missionType = missionType,
        targetFaction = targetFaction or 2,
        progress = 0,
        duration = mission.duration,
        successRate = mission.successRate,
    }
    table.insert(activeSpies, spy)

    if _G.ModernUI then
        _G.ModernUI.notifyInfo("Vohun poslan: " .. mission.name .. " (" .. mission.duration .. "s)")
    end
    print("[Espionage] Mission started: " .. mission.name)
    return true
end

-- Update active spy missions
function Espionage.update(dt)
    if not initialized then return end

    -- Update protection timer
    if protectionTimer > 0 then
        protectionTimer = protectionTimer - dt
        if protectionTimer <= 0 then
            protectionTimer = 0
            if _G.ModernUI then
                _G.ModernUI.notifyInfo("Protivohunska zaščita je potekla")
            end
        end
    end

    -- Update active spies
    for i = #activeSpies, 1, -1 do
        local spy = activeSpies[i]
        spy.progress = spy.progress + dt
        if spy.progress >= spy.duration then
            Espionage._completeMission(spy)
            table.remove(activeSpies, i)
        end
    end
end

-- Complete a spy mission
function Espionage._completeMission(spy)
    local mission = MISSIONS[spy.missionType]
    local success = math.random() < spy.successRate

    if success then
        print("[Espionage] Mission SUCCESS: " .. mission.name)
        if _G.ModernUI then
            _G.ModernUI.notifySuccess("Vohunska misija uspešna: " .. mission.name)
        end

        -- Apply rewards
        if spy.missionType == "scout" then
            -- Reveal enemy territory (fog of war)
            if _G.FogOfWar then
                pcall(function() _G.FogOfWar.revealFaction(spy.targetFaction) end)
            end
            -- Store intel
            intelGathered[spy.targetFaction] = {
                timestamp = os.time(),
                units = Espionage._countEnemyUnits(spy.targetFaction),
                buildings = Espionage._countEnemyBuildings(spy.targetFaction),
            }
        elseif spy.missionType == "steal_gold" then
            local stolen = math.random(mission.reward.goldMin, mission.reward.goldMax)
            if _G.state then
                _G.state.gold = (_G.state.gold or 0) + stolen
            end
            if _G.ModernUI then
                _G.ModernUI.notifySuccess("Ukradeno " .. stolen .. " zlata!")
            end
        elseif spy.missionType == "sabotage" then
            if _G.ModernUI then
                _G.ModernUI.notifySuccess("Sovražnikova zgradba uničena!")
            end
            if _G.GameEventBus then
                pcall(function() _G.GameEventBus.emit("sabotage_success", { faction = spy.targetFaction }) end)
            end
        elseif spy.missionType == "assassinate" then
            if _G.ModernUI then
                _G.ModernUI.notifySuccess("Sovražnikovi vodja eliminiran!")
            end
            if _G.GameEventBus then
                pcall(function() _G.GameEventBus.emit("assassination_success", { faction = spy.targetFaction }) end)
            end
        elseif spy.missionType == "counter_spy" then
            protectionTimer = mission.reward.protection
            if _G.ModernUI then
                _G.ModernUI.notifySuccess("Protivohunska zaščita aktivna (24h)")
            end
        end

        -- Fire event
        if _G.GameEventBus then
            pcall(function() _G.GameEventBus.emit("espionage_success", { mission = spy.missionType }) end)
        end
    else
        print("[Espionage] Mission FAILED: " .. mission.name)
        if _G.ModernUI then
            _G.ModernUI.notifyError("Vohun ujet! Misija spodletela: " .. mission.name)
        end
        if _G.GameEventBus then
            pcall(function() _G.GameEventBus.emit("espionage_failure", { mission = spy.missionType }) end)
        end
    end
end

-- Count enemy units for intel
function Espionage._countEnemyUnits(faction)
    if not _G.state or not _G.state.gameObjectList then return 0 end
    local count = 0
    for _, obj in ipairs(_G.state.gameObjectList) do
        if obj.faction == faction and obj._combatAttached then
            count = count + 1
        end
    end
    return count
end

-- Count enemy buildings for intel
function Espionage._countEnemyBuildings(faction)
    if not _G.state or not _G.state.gameObjectList then return 0 end
    local count = 0
    for _, obj in ipairs(_G.state.gameObjectList) do
        if obj.faction == faction and obj.class and obj.class.name then
            count = count + 1
        end
    end
    return count
end

-- Get gathered intel
function Espionage.getIntel(faction)
    return intelGathered[faction]
end

-- Get all active missions
function Espionage.getActiveMissions()
    local result = {}
    for _, spy in ipairs(activeSpies) do
        local mission = MISSIONS[spy.missionType]
        table.insert(result, {
            missionType = spy.missionType,
            name = mission.name,
            targetFaction = spy.targetFaction,
            progress = spy.progress,
            duration = spy.duration,
            percent = (spy.progress / spy.duration) * 100,
        })
    end
    return result
end

-- Get all mission types with info
function Espionage.getAllMissions()
    local result = {}
    for missionId, mission in pairs(MISSIONS) do
        table.insert(result, {
            id = missionId,
            name = mission.name,
            nameEn = mission.nameEn,
            cost = mission.cost,
            duration = mission.duration,
            successRate = mission.successRate,
            description = mission.description,
        })
    end
    return result
end

return Espionage
