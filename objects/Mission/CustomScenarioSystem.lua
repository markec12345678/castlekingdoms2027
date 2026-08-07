-- objects/Mission/CustomScenarioSystem.lua
-- Stronghold 2027 v2.8.1 - Custom Scenario Editor
--
-- Allows players to create, save, and share custom game scenarios.
-- Scenarios define starting conditions, objectives, events, and AI opponents.
--
-- Scenario features:
-- - Define starting resources, population, and buildings
-- - Set custom objectives (destroy, gather, protect, survive)
-- - Configure AI opponents (personality, difficulty, starting units)
-- - Add timed events (reinforcements, attacks, weather changes)
-- - Export/import scenarios as JSON-compatible files
-- - Share via Steam Workshop (future) or file copy

local Scenario = {}

-- Scenario template
local DEFAULT_SCENARIO = {
    name = "Novi scenarij",
    description = "Opis scenarija",
    author = "Igralec",
    version = "1.0.0",
    -- Starting conditions
    startingResources = {
        gold = 500,
        wood = 50,
        stone = 20,
        food = 30,
        iron = 0,
    },
    startingPopulation = 5,
    startingBuildings = {},  -- { {name, gx, gy}, ... }
    -- Map
    map = "fernhaven",
    mapSize = "medium",
    -- Objectives
    objectives = {},  -- { {type, target, count, description}, ... }
    -- AI opponents
    opponents = {},   -- { {personality, difficulty, startX, startY, startingUnits}, ... }
    -- Events
    events = {},      -- { {time, type, data}, ... }
    -- Settings
    timeLimit = 0,    -- 0 = no limit
    allowTrade = true,
    allowDiplomacy = true,
    allowEspionage = true,
    fogOfWar = true,
    -- Win/lose conditions
    winCondition = "destroy_keep",  -- destroy_keep, gather_resources, survive_time, kill_lord
    winTarget = 1,
    loseCondition = "lose_keep",    -- lose_keep, lose_population, time_limit
    loseTarget = 0,
}

Scenario.DEFAULT_SCENARIO = DEFAULT_SCENARIO

local initialized = false
local currentScenario = nil  -- scenario being edited
local savedScenarios = {}  -- list of saved scenario metadata
local playtestMode = false

function Scenario.init()
    if initialized then return end
    initialized = true
    Scenario._loadSavedList()
    print("[Scenario] Initialized — " .. #savedScenarios .. " saved scenarios")
end

-- Create a new scenario from template
function Scenario.create(name, description)
    local scenario = {}
    -- Deep copy default
    for k, v in pairs(DEFAULT_SCENARIO) do
        if type(v) == "table" then
            scenario[k] = {}
            for k2, v2 in pairs(v) do
                scenario[k][k2] = v2
            end
        else
            scenario[k] = v
        end
    end
    scenario.name = name or "Novi scenarij"
    scenario.description = description or ""
    scenario.created = os.time()
    scenario.id = "scenario_" .. os.time()
    currentScenario = scenario
    return scenario
end

-- Set starting resources
function Scenario.setStartingResources(resources)
    if not currentScenario then return false end
    if type(resources) ~= "table" then return false end
    currentScenario.startingResources = resources
    return true
end

-- Set starting population
function Scenario.setStartingPopulation(pop)
    if not currentScenario then return false end
    currentScenario.startingPopulation = pop or 5
    return true
end

-- Add a starting building
function Scenario.addStartingBuilding(name, gx, gy)
    if not currentScenario then return false end
    table.insert(currentScenario.startingBuildings, {
        name = name,
        gx = gx,
        gy = gy,
    })
    return true
end

-- Remove a starting building by index
function Scenario.removeStartingBuilding(index)
    if not currentScenario then return false end
    if not currentScenario.startingBuildings[index] then return false end
    table.remove(currentScenario.startingBuildings, index)
    return true
end

-- Add an objective
function Scenario.addObjective(objType, target, count, description)
    if not currentScenario then return false end
    table.insert(currentScenario.objectives, {
        type = objType or "gather_resources",
        target = target,
        count = count or 1,
        description = description or "",
        critical = true,
    })
    return true
end

-- Remove an objective by index
function Scenario.removeObjective(index)
    if not currentScenario then return false end
    if not currentScenario.objectives[index] then return false end
    table.remove(currentScenario.objectives, index)
    return true
end

-- Add an AI opponent
function Scenario.addOpponent(personality, difficulty, startX, startY)
    if not currentScenario then return false end
    table.insert(currentScenario.opponents, {
        personality = personality or "balanced",
        difficulty = difficulty or "medium",
        startX = startX or math.random(30, 80),
        startY = startY or math.random(30, 80),
        startingUnits = {},
    })
    return true
end

-- Add starting units to an opponent
function Scenario.addOpponentUnit(opponentIndex, unitType, count)
    if not currentScenario then return false end
    local opp = currentScenario.opponents[opponentIndex]
    if not opp then return false end
    table.insert(opp.startingUnits, {
        type = unitType,
        count = count or 1,
    })
    return true
end

-- Add a timed event
function Scenario.addEvent(time, eventType, data)
    if not currentScenario then return false end
    table.insert(currentScenario.events, {
        time = time or 60,
        type = eventType or "enemy_attack",
        data = data or {},
    })
    -- Sort events by time
    table.sort(currentScenario.events, function(a, b) return a.time < b.time end)
    return true
end

-- Set win/lose conditions
function Scenario.setWinCondition(condition, target)
    if not currentScenario then return false end
    currentScenario.winCondition = condition
    currentScenario.winTarget = target or 1
    return true
end

function Scenario.setLoseCondition(condition, target)
    if not currentScenario then return false end
    currentScenario.loseCondition = condition
    currentScenario.loseTarget = target or 0
    return true
end

-- Set map
function Scenario.setMap(mapName, mapSize)
    if not currentScenario then return false end
    currentScenario.map = mapName or "fernhaven"
    currentScenario.mapSize = mapSize or "medium"
    return true
end

-- Set settings
function Scenario.setSettings(settings)
    if not currentScenario then return false end
    if type(settings) ~= "table" then return false end
    for k, v in pairs(settings) do
        currentScenario[k] = v
    end
    return true
end

-- Save the current scenario to file
function Scenario.save(filename)
    if not currentScenario then return false end
    local name = filename or currentScenario.name
    -- Sanitize filename
    name = name:gsub("[^%w_]", "_"):lower()
    local path = "scenarios/" .. name .. ".scenario"
    love.filesystem.createDirectory("scenarios")

    local file = love.filesystem.newFile(path)
    if file:open("w") then
        -- Simple Lua table serialization
        local lines = {"return {"}
        Scenario._serializeTable(currentScenario, lines, 1)
        table.insert(lines, "}")
        file:write(table.concat(lines, "\n"))
        file:close()

        -- Update saved list
        Scenario._loadSavedList()
        print("[Scenario] Saved: " .. path)
        if _G.ModernUI then
            _G.ModernUI.notifySuccess("Scenarij shranjen: " .. name)
        end
        return true
    end
    return false
end

-- Serialize a table recursively
function Scenario._serializeTable(tbl, lines, depth)
    local indent = string.rep("  ", depth)
    for k, v in pairs(tbl) do
        local key = type(k) == "string" and k or "[" .. tostring(k) .. "]"
        if type(v) == "table" then
            table.insert(lines, indent .. key .. " = {")
            Scenario._serializeTable(v, lines, depth + 1)
            table.insert(lines, indent .. "},")
        elseif type(v) == "string" then
            table.insert(lines, indent .. key .. " = " .. string.format("%q", v) .. ",")
        elseif type(v) == "number" or type(v) == "boolean" then
            table.insert(lines, indent .. key .. " = " .. tostring(v) .. ",")
        end
    end
end

-- Load a scenario from file
function Scenario.load(filename)
    local name = filename:gsub("[^%w_]", "_"):lower()
    local path = "scenarios/" .. name .. ".scenario"
    local file = love.filesystem.newFile(path)
    if file:open("r") then
        local content = file:read()
        file:close()
        if content then
            local ok, chunk = pcall(load, content)
            if ok and chunk then
                local dataOk, data = pcall(chunk)
                if dataOk and type(data) == "table" then
                    currentScenario = data
                    print("[Scenario] Loaded: " .. path)
                    return data
                end
            end
        end
    end
    return nil
end

-- Load list of saved scenarios
function Scenario._loadSavedList()
    savedScenarios = {}
    local files = love.filesystem.getDirectoryItems("scenarios")
    for _, file in ipairs(files) do
        if file:match("%.scenario$") then
            local name = file:gsub("%.scenario$", "")
            table.insert(savedScenarios, {
                filename = name,
                path = "scenarios/" .. file,
            })
        end
    end
end

-- Get list of saved scenarios
function Scenario.getSavedList()
    Scenario._loadSavedList()
    return savedScenarios
end

-- Delete a saved scenario
function Scenario.delete(filename)
    local name = filename:gsub("[^%w_]", "_"):lower()
    local path = "scenarios/" .. name .. ".scenario"
    local success = love.filesystem.remove(path)
    if success then
        Scenario._loadSavedList()
        print("[Scenario] Deleted: " .. path)
    end
    return success
end

-- Get current scenario being edited
function Scenario.getCurrent()
    return currentScenario
end

-- Start playtest of current scenario
function Scenario.startPlaytest()
    if not currentScenario then return false end
    playtestMode = true
    -- Apply scenario to game state
    if _G.state then
        -- Set resources
        if currentScenario.startingResources then
            _G.state.gold = currentScenario.startingResources.gold or 500
            if _G.state.resources then
                for res, amount in pairs(currentScenario.startingResources) do
                    if res ~= "gold" then
                        _G.state.resources[res] = amount
                    end
                end
            end
        end
        -- Set population
        _G.state.population = currentScenario.startingPopulation or 5
    end
    if _G.ModernUI then
        _G.ModernUI.notifySuccess("Playtest začet: " .. currentScenario.name)
    end
    print("[Scenario] Playtest started: " .. currentScenario.name)
    return true
end

-- Stop playtest
function Scenario.stopPlaytest()
    playtestMode = false
    if _G.ModernUI then
        _G.ModernUI.notifyInfo("Playtest končan")
    end
    return true
end

-- Check if in playtest mode
function Scenario.isPlaytesting()
    return playtestMode
end

-- Get scenario summary for display
function Scenario.getSummary()
    if not currentScenario then return nil end
    return {
        name = currentScenario.name,
        description = currentScenario.description,
        author = currentScenario.author,
        map = currentScenario.map,
        objectives = #currentScenario.objectives,
        opponents = #currentScenario.opponents,
        events = #currentScenario.events,
        timeLimit = currentScenario.timeLimit,
        winCondition = currentScenario.winCondition,
    }
end

-- Export scenario as string (for sharing)
function Scenario.export()
    if not currentScenario then return nil end
    local lines = {"return {"}
    Scenario._serializeTable(currentScenario, lines, 1)
    table.insert(lines, "}")
    return table.concat(lines, "\n")
end

-- Import scenario from string
function Scenario.import(data)
    if not data then return false end
    local ok, chunk = pcall(load, data)
    if ok and chunk then
        local dataOk, scenario = pcall(chunk)
        if dataOk and type(scenario) == "table" then
            currentScenario = scenario
            print("[Scenario] Imported: " .. (scenario.name or "unknown"))
            return true
        end
    end
    return false
end

return Scenario
