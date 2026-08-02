-- objects/Modding/ModLoader.lua
-- Stronghold 2027 - Mod Loader
--
-- Loads mods from the /mods directory. Each mod has a manifest.lua file
-- that declares its metadata and entry points.
--
-- Mod structure:
--   mods/
--     my_mod/
--       manifest.lua    -- Required: mod metadata
--       init.lua        -- Required: entry point
--       buildings/      -- Optional: custom building definitions
--       maps/           -- Optional: custom maps
--       units/          -- Optional: custom unit definitions
--       scripts/        -- Optional: custom scripts
--       assets/         -- Optional: custom assets
--
-- Manifest format (manifest.lua):
--   return {
--     name = "My Mod",
--     version = "1.0.0",
--     author = "Author Name",
--     description = "Mod description",
--     dependencies = { "other_mod >= 1.0" },
--     entryPoint = "init",  -- file to load (without .lua)
--   }
--
-- Usage:
--   local ModLoader = require("objects.Modding.ModLoader")
--   ModLoader.init()
--   ModLoader.loadAll()
--   ModLoader.update(dt)

local ModLoader = {}

local mods = {}          -- loaded mods: {modId = {manifest, loaded, enabled, ...}}
local loadOrder = {}     -- order in which mods were loaded
local initialized = false

-- Callbacks for game systems to register custom content
ModLoader.onBuildingRegistered = nil    -- function(buildingDef)
ModLoader.onUnitRegistered = nil        -- function(unitDef)
ModLoader.onMapRegistered = nil         -- function(mapDef)
ModLoader.onScriptLoaded = nil          -- function(modId, scriptName)

-- Initialize mod loader
function ModLoader.init()
    if initialized then return end
    initialized = true
    print("[ModLoader] Initialized")
end

-- Scan the mods directory for available mods
function ModLoader.scanMods()
    local modDirs = {}
    local files = love.filesystem.getDirectoryItems("mods")

    for _, dir in ipairs(files) do
        local manifestPath = "mods/" .. dir .. "/manifest.lua"
        if love.filesystem.getInfo(manifestPath, "file") then
            table.insert(modDirs, dir)
        end
    end

    return modDirs
end

-- Load a mod's manifest
function ModLoader.loadManifest(modId)
    local manifestPath = "mods/" .. modId .. "/manifest.lua"
    local ok, chunk = pcall(love.filesystem.load, manifestPath)
    if not ok then
        print("[ModLoader] Failed to load manifest for " .. modId .. ": " .. tostring(chunk))
        return nil
    end

    local manifestOk, manifest = pcall(chunk)
    if not manifestOk or type(manifest) ~= "table" then
        print("[ModLoader] Invalid manifest for " .. modId)
        return nil
    end

    return manifest
end

-- Load a single mod
function ModLoader.loadMod(modId)
    if mods[modId] then
        print("[ModLoader] Mod already loaded: " .. modId)
        return false
    end

    local manifest = ModLoader.loadManifest(modId)
    if not manifest then return false end

    -- Validate required fields
    if not manifest.name then
        print("[ModLoader] Mod " .. modId .. " missing 'name' in manifest")
        return false
    end

    if not manifest.version then
        print("[ModLoader] Mod " .. modId .. " missing 'version' in manifest")
        return false
    end

    -- Register mod
    mods[modId] = {
        id = modId,
        manifest = manifest,
        loaded = false,
        enabled = true,
        loadTime = 0,
    }

    -- Load entry point
    if manifest.entryPoint then
        local entryPath = "mods/" .. modId .. "/" .. manifest.entryPoint
        local ok, chunk = pcall(love.filesystem.load, entryPath)
        if ok then
            local loadOk, err = pcall(chunk, ModLoader, modId)
            if loadOk then
                mods[modId].loaded = true
                print(string.format("[ModLoader] Loaded mod: %s v%s by %s",
                    manifest.name, manifest.version, manifest.author or "Unknown"))
            else
                print("[ModLoader] Error in mod " .. modId .. " entry point: " .. tostring(err))
                mods[modId].enabled = false
            end
        else
            print("[ModLoader] Failed to load entry point for " .. modId .. ": " .. tostring(chunk))
            mods[modId].enabled = false
        end
    end

    -- Load custom buildings
    ModLoader._loadCustomBuildings(modId)

    -- Load custom units
    ModLoader._loadCustomUnits(modId)

    -- Load custom maps
    ModLoader._loadCustomMaps(modId)

    -- Load custom scripts
    ModLoader._loadCustomScripts(modId)

    table.insert(loadOrder, modId)
    return true
end

-- Load custom buildings from mod
function ModLoader._loadCustomBuildings(modId)
    local buildingsDir = "mods/" .. modId .. "/buildings"
    if not love.filesystem.getInfo(buildingsDir, "directory") then return end

    local files = love.filesystem.getDirectoryItems(buildingsDir)
    for _, file in ipairs(files) do
        if file:match("%.lua$") then
            local path = buildingsDir .. "/" .. file
            local ok, chunk = pcall(love.filesystem.load, path)
            if ok then
                local defOk, buildingDef = pcall(chunk)
                if defOk and type(buildingDef) == "table" then
                    buildingDef._modId = modId
                    if ModLoader.onBuildingRegistered then
                        ModLoader.onBuildingRegistered(buildingDef)
                    end
                    print("[ModLoader] " .. modId .. ": registered building " .. tostring(buildingDef.name))
                end
            end
        end
    end
end

-- Load custom units from mod
function ModLoader._loadCustomUnits(modId)
    local unitsDir = "mods/" .. modId .. "/units"
    if not love.filesystem.getInfo(unitsDir, "directory") then return end

    local files = love.filesystem.getDirectoryItems(unitsDir)
    for _, file in ipairs(files) do
        if file:match("%.lua$") then
            local path = unitsDir .. "/" .. file
            local ok, chunk = pcall(love.filesystem.load, path)
            if ok then
                local defOk, unitDef = pcall(chunk)
                if defOk and type(unitDef) == "table" then
                    unitDef._modId = modId
                    if ModLoader.onUnitRegistered then
                        ModLoader.onUnitRegistered(unitDef)
                    end
                    print("[ModLoader] " .. modId .. ": registered unit " .. tostring(unitDef.name))
                end
            end
        end
    end
end

-- Load custom maps from mod
function ModLoader._loadCustomMaps(modId)
    local mapsDir = "mods/" .. modId .. "/maps"
    if not love.filesystem.getInfo(mapsDir, "directory") then return end

    local files = love.filesystem.getDirectoryItems(mapsDir)
    for _, file in ipairs(files) do
        if file:match("%.lua$") then
            local path = mapsDir .. "/" .. file
            local ok, chunk = pcall(love.filesystem.load, path)
            if ok then
                local defOk, mapDef = pcall(chunk)
                if defOk and type(mapDef) == "table" then
                    mapDef._modId = modId
                    if ModLoader.onMapRegistered then
                        ModLoader.onMapRegistered(mapDef)
                    end
                    print("[ModLoader] " .. modId .. ": registered map " .. tostring(mapDef.name))
                end
            end
        end
    end
end

-- Load custom scripts from mod
function ModLoader._loadCustomScripts(modId)
    local scriptsDir = "mods/" .. modId .. "/scripts"
    if not love.filesystem.getInfo(scriptsDir, "directory") then return end

    local files = love.filesystem.getDirectoryItems(scriptsDir)
    for _, file in ipairs(files) do
        if file:match("%.lua$") then
            local scriptName = file:gsub("%.lua$", "")
            local path = scriptsDir .. "/" .. file
            local ok, chunk = pcall(love.filesystem.load, path)
            if ok then
                local loadOk = pcall(chunk)
                if loadOk and ModLoader.onScriptLoaded then
                    ModLoader.onScriptLoaded(modId, scriptName)
                end
            end
        end
    end
end

-- Load all available mods
function ModLoader.loadAll()
    local availableMods = ModLoader.scanMods()
    print(string.format("[ModLoader] Found %d mods", #availableMods))

    for _, modId in ipairs(availableMods) do
        ModLoader.loadMod(modId)
    end

    print(string.format("[ModLoader] Loaded %d/%d mods", ModLoader.getLoadedCount(), #availableMods))
end

-- Enable a mod
function ModLoader.enableMod(modId)
    if not mods[modId] then return false end
    mods[modId].enabled = true
    print("[ModLoader] Enabled mod: " .. modId)
    return true
end

-- Disable a mod
function ModLoader.disableMod(modId)
    if not mods[modId] then return false end
    mods[modId].enabled = false
    print("[ModLoader] Disabled mod: " .. modId)
    return true
end

-- Reload a mod (for hot-reload during development)
function ModLoader.reloadMod(modId)
    if not mods[modId] then return false end
    mods[modId] = nil
    -- Remove from loadOrder
    for i, id in ipairs(loadOrder) do
        if id == modId then
            table.remove(loadOrder, i)
            break
        end
    end
    return ModLoader.loadMod(modId)
end

-- Get all loaded mods
function ModLoader.getMods()
    return mods
end

-- Get a specific mod
function ModLoader.getMod(modId)
    return mods[modId]
end

-- Get number of loaded mods
function ModLoader.getLoadedCount()
    local count = 0
    for _, mod in pairs(mods) do
        if mod.loaded then count = count + 1 end
    end
    return count
end

-- Get load order
function ModLoader.getLoadOrder()
    return loadOrder
end

-- Update (call every frame) - for mod-defined update functions
function ModLoader.update(dt)
    for _, modId in ipairs(loadOrder) do
        local mod = mods[modId]
        if mod and mod.enabled and mod.update then
            pcall(mod.update, dt)
        end
    end
end

-- Get mod statistics
function ModLoader.getStats()
    local stats = {
        total = 0,
        loaded = 0,
        enabled = 0,
        disabled = 0,
    }
    for _, mod in pairs(mods) do
        stats.total = stats.total + 1
        if mod.loaded then stats.loaded = stats.loaded + 1 end
        if mod.enabled then stats.enabled = stats.enabled + 1
        else stats.disabled = stats.disabled + 1 end
    end
    return stats
end

-- Create a sample mod (for documentation/testing)
function ModLoader.createSampleMod()
    local sampleDir = "mods/sample_mod"
    love.filesystem.createDirectory(sampleDir)

    -- Write manifest
    local manifest = [[return {
    name = "Sample Mod",
    version = "1.0.0",
    author = "Stronghold 2027 Team",
    description = "A sample mod demonstrating the modding API.",
    entryPoint = "init",
}
]]
    local file = love.filesystem.newFile(sampleDir .. "/manifest.lua")
    file:open("w")
    file:write(manifest)
    file:close()

    -- Write init.lua
    local init = [[-- Sample Mod - Entry Point
-- This mod demonstrates the Stronghold 2027 modding API.

local ModAPI = {}

function ModAPI.init()
    print("[Sample Mod] Initialized!")
    print("[Sample Mod] This mod does nothing, but shows how mods work.")
end

-- Return the mod API table
return ModAPI
]]
    local initFile = love.filesystem.newFile(sampleDir .. "/init.lua")
    initFile:open("w")
    initFile:write(init)
    initFile:close()

    print("[ModLoader] Created sample mod in mods/sample_mod/")
end

return ModLoader
