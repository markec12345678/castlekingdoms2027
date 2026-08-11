-- objects/Modding/ModdingAPI.lua
-- Castle Kingdoms 2027 v2.8.5 - Enhanced Modding API
--
-- Provides a comprehensive API for modders to hook into game systems.
-- Mods can register callbacks, add content, and modify game behavior
-- without touching core code.
--
-- API sections:
-- - Events: register/unregister callbacks for game events
-- - Content: register custom buildings, units, resources, recipes
-- - Hooks: intercept and modify game functions
-- - Data: read/write mod-specific persistent data
-- - UI: add custom UI elements, buttons, panels
-- - Config: register mod settings

local ModAPI = {}

local initialized = false
local registeredMods = {}  -- [modId] = { name, version, callbacks }
local eventCallbacks = {}  -- [eventName] = { {modId, callback}, ... }
local customContent = {
    buildings = {},
    units = {},
    resources = {},
    recipes = {},
    technologies = {},
    missions = {},
}
local hooks = {}  -- [hookName] = { {modId, callback}, ... }
local modData = {}  -- [modId] = { key = value, ... }

function ModAPI.init()
    if initialized then return end
    initialized = true
    print("[ModAPI] Initialized — ready for mod registration")
end

-- Register a mod with the API
function ModAPI.registerMod(modId, name, version)
    if not modId then return false end
    registeredMods[modId] = {
        id = modId,
        name = name or modId,
        version = version or "1.0.0",
        callbacks = {},
        registeredAt = os.time(),
    }
    modData[modId] = {}
    print("[ModAPI] Mod registered: " .. (name or modId) .. " v" .. (version or "1.0.0"))
    return true
end

-- Unregister a mod
function ModAPI.unregisterMod(modId)
    if not registeredMods[modId] then return false end
    -- Remove all callbacks for this mod
    for eventName, callbacks in pairs(eventCallbacks) do
        for i = #callbacks, 1, -1 do
            if callbacks[i].modId == modId then
                table.remove(callbacks, i)
            end
        end
    end
    -- Remove hooks
    for hookName, hookList in pairs(hooks) do
        for i = #hookList, 1, -1 do
            if hookList[i].modId == modId then
                table.remove(hookList, i)
            end
        end
    end
    registeredMods[modId] = nil
    print("[ModAPI] Mod unregistered: " .. modId)
    return true
end

-- === EVENTS ===

-- Register a callback for a game event
function ModAPI.on(modId, eventName, callback)
    if not registeredMods[modId] then return false end
    if not eventCallbacks[eventName] then
        eventCallbacks[eventName] = {}
    end
    table.insert(eventCallbacks[eventName], {
        modId = modId,
        callback = callback,
    })
    return true
end

-- Unregister a specific callback
function ModAPI.off(modId, eventName)
    if not eventCallbacks[eventName] then return false end
    for i = #eventCallbacks[eventName], 1, -1 do
        if eventCallbacks[eventName][i].modId == modId then
            table.remove(eventCallbacks[eventName], i)
        end
    end
    return true
end

-- Emit an event to all registered mods
function ModAPI.emit(eventName, data)
    if not eventCallbacks[eventName] then return end
    for _, entry in ipairs(eventCallbacks[eventName]) do
        pcall(entry.callback, data or {})
    end
end

-- === HOOKS ===

-- Register a hook to intercept game functions
function ModAPI.addHook(modId, hookName, callback)
    if not registeredMods[modId] then return false end
    if not hooks[hookName] then
        hooks[hookName] = {}
    end
    table.insert(hooks[hookName], {
        modId = modId,
        callback = callback,
    })
    return true
end

-- Execute hooks and allow modification of data
function ModAPI.runHooks(hookName, data)
    if not hooks[hookName] then return data end
    local result = data
    for _, entry in ipairs(hooks[hookName]) do
        local ok, modified = pcall(entry.callback, result)
        if ok and modified then
            result = modified
        end
    end
    return result
end

-- === CONTENT REGISTRATION ===

-- Register a custom building
function ModAPI.registerBuilding(modId, buildingDef)
    if not registeredMods[modId] then return false end
    if not buildingDef or not buildingDef.name then return false end
    buildingDef.modId = modId
    customContent.buildings[buildingDef.name] = buildingDef
    print("[ModAPI] Building registered: " .. buildingDef.name .. " (by " .. modId .. ")")
    -- Integrate with CustomBuildingLoader if available
    local CustomBuildingLoader = _G.CustomBuildingLoader
    if CustomBuildingLoader and CustomBuildingLoader.register then
        pcall(function() CustomBuildingLoader.register(buildingDef) end)
    end
    return true
end

-- Register a custom unit
function ModAPI.registerUnit(modId, unitDef)
    if not registeredMods[modId] then return false end
    if not unitDef or not unitDef.name then return false end
    unitDef.modId = modId
    customContent.units[unitDef.name] = unitDef
    print("[ModAPI] Unit registered: " .. unitDef.name .. " (by " .. modId .. ")")
    return true
end

-- Register a custom resource
function ModAPI.registerResource(modId, resourceDef)
    if not registeredMods[modId] then return false end
    if not resourceDef or not resourceDef.name then return false end
    resourceDef.modId = modId
    customContent.resources[resourceDef.name] = resourceDef
    print("[ModAPI] Resource registered: " .. resourceDef.name .. " (by " .. modId .. ")")
    return true
end

-- Register a custom recipe (production chain)
function ModAPI.registerRecipe(modId, recipeDef)
    if not registeredMods[modId] then return false end
    if not recipeDef or not recipeDef.name then return false end
    recipeDef.modId = modId
    customContent.recipes[recipeDef.name] = recipeDef
    print("[ModAPI] Recipe registered: " .. recipeDef.name .. " (by " .. modId .. ")")
    return true
end

-- Register a custom technology
function ModAPI.registerTechnology(modId, techDef)
    if not registeredMods[modId] then return false end
    if not techDef or not techDef.id then return false end
    techDef.modId = modId
    customContent.technologies[techDef.id] = techDef
    print("[ModAPI] Technology registered: " .. techDef.id .. " (by " .. modId .. ")")
    return true
end

-- Register a custom mission
function ModAPI.registerMission(modId, missionDef)
    if not registeredMods[modId] then return false end
    if not missionDef or not missionDef.key then return false end
    missionDef.modId = modId
    customContent.missions[missionDef.key] = missionDef
    print("[ModAPI] Mission registered: " .. missionDef.key .. " (by " .. modId .. ")")
    return true
end

-- === DATA PERSISTENCE ===

-- Set mod-specific data
function ModAPI.setData(modId, key, value)
    if not registeredMods[modId] then return false end
    if not modData[modId] then modData[modId] = {} end
    modData[modId][key] = value
    return true
end

-- Get mod-specific data
function ModAPI.getData(modId, key, default)
    if not modData[modId] then return default end
    return modData[modId][key] or default
end

-- Save mod data to file
function ModAPI.saveData(modId)
    if not modData[modId] then return false end
    local path = "mods/" .. modId .. "/data.json"
    local file = love.filesystem.newFile(path)
    if file:open("w") then
        -- Simple serialization
        local lines = {"return {"}
        for k, v in pairs(modData[modId]) do
            if type(v) == "string" then
                table.insert(lines, string.format("  %s = %q,", k, v))
            elseif type(v) == "number" then
                table.insert(lines, string.format("  %s = %d,", k, v))
            elseif type(v) == "boolean" then
                table.insert(lines, string.format("  %s = %s,", k, tostring(v)))
            end
        end
        table.insert(lines, "}")
        file:write(table.concat(lines, "\n"))
        file:close()
        return true
    end
    return false
end

-- Load mod data from file
function ModAPI.loadData(modId)
    local path = "mods/" .. modId .. "/data.json"
    local file = love.filesystem.newFile(path)
    if file:open("r") then
        local content = file:read()
        file:close()
        if content then
            local ok, chunk = pcall(load, content)
            if ok and chunk then
                local dataOk, data = pcall(chunk)
                if dataOk and type(data) == "table" then
                    modData[modId] = data
                    return true
                end
            end
        end
    end
    return false
end

-- === QUERY FUNCTIONS ===

-- Get all registered mods
function ModAPI.getRegisteredMods()
    local result = {}
    for modId, mod in pairs(registeredMods) do
        table.insert(result, {
            id = mod.id,
            name = mod.name,
            version = mod.version,
        })
    end
    return result
end

-- Get all custom content
function ModAPI.getCustomContent()
    return {
        buildings = customContent.buildings,
        units = customContent.units,
        resources = customContent.resources,
        recipes = customContent.recipes,
        technologies = customContent.technologies,
        missions = customContent.missions,
    }
end

-- Get stats
function ModAPI.getStats()
    local modCount = 0
    local eventCount = 0
    local hookCount = 0
    local contentCount = 0
    for _ in pairs(registeredMods) do modCount = modCount + 1 end
    for _, callbacks in pairs(eventCallbacks) do
        eventCount = eventCount + #callbacks
    end
    for _, hookList in pairs(hooks) do
        hookCount = hookCount + #hookList
    end
    for _, items in pairs(customContent) do
        for _ in pairs(items) do contentCount = contentCount + 1 end
    end
    return {
        registeredMods = modCount,
        totalCallbacks = eventCount,
        totalHooks = hookCount,
        totalContent = contentCount,
        customBuildings = ModAPI._countTable(customContent.buildings),
        customUnits = ModAPI._countTable(customContent.units),
        customResources = ModAPI._countTable(customContent.resources),
        customRecipes = ModAPI._countTable(customContent.recipes),
        customTechnologies = ModAPI._countTable(customContent.technologies),
        customMissions = ModAPI._countTable(customContent.missions),
    }
end

function ModAPI._countTable(tbl)
    local count = 0
    for _ in pairs(tbl) do count = count + 1 end
    return count
end

return ModAPI
