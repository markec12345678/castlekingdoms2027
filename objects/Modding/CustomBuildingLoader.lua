-- objects/Modding/CustomBuildingLoader.lua
-- Stronghold 2027 - Custom Building Loader
--
-- Registers custom buildings defined by mods. Custom buildings can:
-- - Have custom costs, build times, production rates
-- - Use existing or custom sprites
-- - Be placed in the action bar
-- - Have custom production logic
--
-- Custom building definition format:
--   {
--     name = "CustomWorkshop",
--     displayName = "Custom Workshop",
--     description = "A custom production building",
--     cost = { wood = 50, stone = 20 },
--     buildTime = 25,
--     size = { w = 2, h = 2 },
--     category = "industry",  -- castle, farms, industry, house, etc.
--     icon = "mods/my_mod/assets/workshop_icon.png",
--     sprite = "mods/my_mod/assets/workshop_sprite.png",
--     production = {
--       input = { wood = 5 },
--       output = { gold = 10 },
--       rate = 5.0,  -- production cycle in seconds
--     },
--     workers = 3,
--     tier = 1,
--   }

local CustomBuildingLoader = {}

local customBuildings = {}  -- {name = buildingDef}
local initialized = false

-- Initialize
function CustomBuildingLoader.init()
    if initialized then return end
    initialized = true
    print("[CustomBuildingLoader] Initialized")
end

-- Register a custom building
function CustomBuildingLoader.register(buildingDef)
    if not buildingDef or not buildingDef.name then
        print("[CustomBuildingLoader] Invalid building definition (missing name)")
        return false
    end

    if customBuildings[buildingDef.name] then
        print("[CustomBuildingLoader] Building already registered: " .. buildingDef.name)
        return false
    end

    -- Validate required fields
    local required = {"displayName", "cost", "buildTime"}
    for _, field in ipairs(required) do
        if buildingDef[field] == nil then
            print("[CustomBuildingLoader] Missing field '" .. field .. "' in building " .. buildingDef.name)
            return false
        end
    end

    -- Set defaults
    buildingDef.size = buildingDef.size or {w = 1, h = 1}
    buildingDef.category = buildingDef.category or "custom"
    buildingDef.workers = buildingDef.workers or 1
    buildingDef.tier = buildingDef.tier or 1

    -- Register in BalanceConfig.buildings if it exists
    local BalanceConfig = require("objects.Config.BalanceConfig")
    if BalanceConfig and BalanceConfig.buildings then
        BalanceConfig.buildings[buildingDef.name] = buildingDef.cost
    end

    customBuildings[buildingDef.name] = buildingDef
    print(string.format("[CustomBuildingLoader] Registered: %s (%s)",
        buildingDef.name, buildingDef.displayName))

    return true
end

-- Unregister a custom building
function CustomBuildingLoader.unregister(name)
    if not customBuildings[name] then return false end
    customBuildings[name] = nil
    print("[CustomBuildingLoader] Unregistered: " .. name)
    return true
end

-- Get a custom building definition
function CustomBuildingLoader.get(name)
    return customBuildings[name]
end

-- Get all custom buildings
function CustomBuildingLoader.getAll()
    return customBuildings
end

-- Get buildings by category
function CustomBuildingLoader.getByCategory(category)
    local results = {}
    for name, def in pairs(customBuildings) do
        if def.category == category then
            results[name] = def
        end
    end
    return results
end

-- Get building count
function CustomBuildingLoader.getCount()
    local count = 0
    for _ in pairs(customBuildings) do
        count = count + 1
    end
    return count
end

-- Check if a building is custom (registered by a mod)
function CustomBuildingLoader.isCustom(name)
    return customBuildings[name] ~= nil
end

-- Get all custom building names for action bar registration
function CustomBuildingLoader.getNames()
    local names = {}
    for name, _ in pairs(customBuildings) do
        table.insert(names, name)
    end
    return names
end

return CustomBuildingLoader
