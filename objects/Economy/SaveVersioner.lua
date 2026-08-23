-- objects/Economy/SaveVersioner.lua
-- Castle Kingdoms 2027 - Save Game Versioning & Migration
--
-- Handles versioning of saved game data for the Royal Systems ecosystem.
-- Each subsystem (royalSystems, marketDashboard, royalMarket, dynamicMarket)
-- has its own version number. When loading an old save, the migrator runs
-- the appropriate migration functions to bring the data up to the current
-- version.
--
-- Migration philosophy:
--   * Each migration function takes the OLD data and returns the NEW data.
--   * Migrations are chained: v1 -> v2 -> v3 -> ... -> currentVersion.
--   * If a field is missing (very old save), it's left as nil and the
--     subsystem's deserialize() will use defaults via its guards.
--   * Migrations never crash on missing fields - they're defensive.
--
-- Usage:
--   local SaveVersioner = require("objects.Economy.SaveVersioner")
--   -- On save:
--   data.saveVersion = SaveVersioner.CURRENT_VERSION
--   -- On load:
--   SaveVersioner.migrate(data)

local SaveVersioner = {}

-- Current save version. Increment when adding new saved fields
-- or changing the structure of any subsystem's serialized data.
SaveVersioner.CURRENT_VERSION = 1

-- Migration functions: migrations[v] takes data at version v and returns
-- data at version v+1. Chained automatically by migrate().
local migrations = {}

-- v0 -> v1: Initial versioning. Before v1, saves had no version field.
-- This migration is essentially a no-op (all fields already existed with
-- guards), but it stamps the version so future migrations can detect it.
migrations[0] = function(data)
    -- v0 saves may lack: marketDashboard, royalMarket, dynamicMarket
    -- All subsystem deserialize() functions handle missing fields gracefully,
    -- so we just ensure the version field is set.
    -- No structural changes needed.
    return data
end

-- Future migrations go here. Example:
-- migrations[1] = function(data)
--     -- v1 -> v2: rename field X to Y in royalSystems
--     if data.royalSystems then
--         for _, sys in ipairs(data.royalSystems.systems or {}) do
--             if sys.maker and sys.maker.skillLevel and not sys.maker.skill then
--                 sys.maker.skill = sys.maker.skillLevel
--                 sys.maker.skillLevel = nil
--             end
--         end
--     end
--     return data
-- end

-- Get the version number from a loaded save. Returns 0 if no version
-- field is present (very old save, pre-versioning).
local function getVersion(data)
    if type(data) ~= "table" then return 0 end
    if type(data.saveVersion) ~= "number" then return 0 end
    return data.saveVersion
end

-- Migrate loaded save data to the current version.
-- Mutates the data table in place and returns it.
-- @param data table The loaded save data
-- @return table The migrated data (same reference as input)
-- @return number The original version detected
-- @return number The final version (== CURRENT_VERSION)
function SaveVersioner.migrate(data)
    if type(data) ~= "table" then return data, 0, 0 end
    local originalVersion = getVersion(data)
    local currentVersion = originalVersion

    -- If save is from a future version (newer than CURRENT), we can't
    -- migrate forward. Downgrade gracefully: log a warning but keep the
    -- data as-is (subsystems will skip unknown fields).
    if originalVersion > SaveVersioner.CURRENT_VERSION then
        print(string.format("[SaveVersioner] WARNING: Save version %d is newer than current %d. Loading with possible data loss.",
            originalVersion, SaveVersioner.CURRENT_VERSION))
        data.saveVersion = SaveVersioner.CURRENT_VERSION
        return data, originalVersion, SaveVersioner.CURRENT_VERSION
    end

    -- Chain migrations from originalVersion up to CURRENT_VERSION
    local migrationFailed = false
    while currentVersion < SaveVersioner.CURRENT_VERSION do
        local migrator = migrations[currentVersion]
        if migrator then
            local ok, err = pcall(function()
                data = migrator(data) or data
            end)
            if not ok then
                print(string.format("[SaveVersioner] Migration v%d -> v%d failed: %s",
                    currentVersion, currentVersion + 1, tostring(err)))
                -- Stop migrating to avoid cascading failures
                migrationFailed = true
                break
            end
        end
        -- If no migrator exists for this version, assume it was a no-op
        -- (fields added with backward-compatible guards) and just bump.
        currentVersion = currentVersion + 1
    end

    -- Stamp the version we actually reached (may be < CURRENT if migration failed)
    data.saveVersion = currentVersion

    if migrationFailed then
        print(string.format("[SaveVersioner] Save partially migrated to v%d (target was v%d) due to migration failure",
            currentVersion, SaveVersioner.CURRENT_VERSION))
    elseif originalVersion < SaveVersioner.CURRENT_VERSION then
        print(string.format("[SaveVersioner] Migrated save from v%d to v%d",
            originalVersion, SaveVersioner.CURRENT_VERSION))
    elseif originalVersion == 0 then
        print(string.format("[SaveVersioner] Pre-version save detected, stamped as v%d",
            SaveVersioner.CURRENT_VERSION))
    end

    return data, originalVersion, currentVersion
end

-- Stamp the current version onto a save data table (called during serialize).
-- @param data table The save data being prepared for serialization
-- @return table The same table with saveVersion set
function SaveVersioner.stamp(data)
    data.saveVersion = SaveVersioner.CURRENT_VERSION
    return data
end

-- Get a human-readable description of the save version for debug UI.
-- @return string
function SaveVersioner.getInfo()
    return string.format("Save v%d (current)", SaveVersioner.CURRENT_VERSION)
end

-- Check if a save data table has the version field (for diagnostics).
-- @param data table
-- @return boolean
function SaveVersioner.isVersioned(data)
    return type(data) == "table" and type(data.saveVersion) == "number"
end

return SaveVersioner
