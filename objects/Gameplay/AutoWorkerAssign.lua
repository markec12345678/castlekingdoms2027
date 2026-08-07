-- objects/Gameplay/AutoWorkerAssign.lua
-- Castle Kingdoms 2027 - Auto Worker Assignment
-- Automatically assigns available workers to buildings that need them

local AutoWorker = {}

local initialized = false
local updateTimer = 0
local updateInterval = 5.0  -- Check every 5 seconds
local isEnabled = true

-- Buildings that need workers
local WORKER_BUILDINGS = {
    "Woodcutter", "Quarry", "IronMine", "PitchRig",
    "WheatFarm", "Orchard", "DairyFarm", "HopsFarm", "HunterHut",
    "Windmill", "Bakery", "Brewery", "Inn",
    "Fletcher", "Poleturner", "Blacksmith", "Armorer",
    "Market", "EngineersGuild", "TunnelersGuild",
}

function AutoWorker.init()
    if initialized then return end
    initialized = true
    print("[AutoWorker] Initialized (auto-assigns idle workers)")
end

function AutoWorker.setEnabled(enabled)
    isEnabled = enabled
    print("[AutoWorker] " .. (enabled and "Enabled" or "Disabled"))
end

function AutoWorker.isEnabled()
    return isEnabled
end

function AutoWorker.update(dt)
    if not initialized or not isEnabled then return end

    updateTimer = updateTimer + dt
    if updateTimer < updateInterval then return end
    updateTimer = 0

    AutoWorker._assignWorkers()
end

function AutoWorker._assignWorkers()
    if not _G.state or not _G.state.gameObjectList then return end

    -- Find buildings that need workers
    local needyBuildings = {}
    for _, obj in ipairs(_G.state.gameObjectList) do
        if obj.class and obj.class.name then
            local name = obj.class.name
            for _, wName in ipairs(WORKER_BUILDINGS) do
                if name == wName then
                    -- Check if building needs workers
                    local needsWorkers = false
                    if obj.workers and obj.maxWorkers then
                        needsWorkers = obj.workers < obj.maxWorkers
                    elseif obj.workerCount and obj.maxWorkerCount then
                        needsWorkers = obj.workerCount < obj.maxWorkerCount
                    end

                    if needsWorkers then
                        table.insert(needyBuildings, obj)
                    end
                    break
                end
            end
        end
    end

    -- If there are needy buildings, try to assign workers
    if #needyBuildings == 0 then return end

    -- Check if we have available population
    if _G.state.population and _G.state.maxPopulation then
        local available = _G.state.maxPopulation - _G.state.population
        if available <= 0 then
            -- No available workers
            if _G.VoiceOver and math.random() < 0.3 then
                _G.VoiceOver.notify("not_enough_workers")
            end
            return
        end
    end

    -- Sort by priority (military > food > wood > other)
    table.sort(needyBuildings, function(a, b)
        local prioA = AutoWorker._getPriority(a.class.name)
        local prioB = AutoWorker._getPriority(b.class.name)
        return prioA > prioB
    end)

    -- Assign to highest priority building
    local target = needyBuildings[1]
    if target and target.assignWorker then
        pcall(function() target:assignWorker() end)
    elseif target and target.addWorker then
        pcall(function() target:addWorker() end)
    end
end

function AutoWorker._getPriority(buildingName)
    local priorities = {
        -- Military (highest)
        Blacksmith = 10, Armorer = 9, Fletcher = 8, Poleturner = 7,
        -- Food
        Bakery = 6, Windmill = 5, WheatFarm = 4, Orchard = 4, DairyFarm = 4,
        HunterHut = 3, Brewery = 3, Inn = 3,
        -- Resources
        Woodcutter = 2, Quarry = 2, IronMine = 1, PitchRig = 1,
        Market = 1,
    }
    return priorities[buildingName] or 0
end

-- Manually trigger assignment
function AutoWorker.assignNow()
    AutoWorker._assignWorkers()
end

-- Castle Kingdoms 2027 v2.4.1: Assign a worker to a specific building
-- @param building object The building to assign a worker to
-- @return boolean True if worker was assigned
function AutoWorker.assignToBuilding(building)
    if not building then return false end
    -- Try common worker assignment methods
    if building.assignWorker then
        local ok = pcall(function() building:assignWorker() end)
        return ok
    elseif building.addWorker then
        local ok = pcall(function() building:addWorker() end)
        return ok
    end
    return false
end

function AutoWorker.getStats()
    if not _G.state then return { needyBuildings = 0 } end
    local needy = 0
    for _, obj in ipairs(_G.state.gameObjectList or {}) do
        if obj.class and obj.class.name then
            for _, wName in ipairs(WORKER_BUILDINGS) do
                if obj.class.name == wName then
                    if obj.workers and obj.maxWorkers and obj.workers < obj.maxWorkers then
                        needy = needy + 1
                    end
                    break
                end
            end
        end
    end
    return {
        needyBuildings = needy,
        enabled = isEnabled,
        updateInterval = updateInterval,
    }
end

return AutoWorker
