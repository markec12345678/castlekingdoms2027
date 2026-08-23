-- objects/Structures/BuildingSpriteOverride.lua
-- Castle Kingdoms 2027 v3.12.212 - HD Building Sprite Override System
--
-- Allows HD building sprites to be loaded from assets/buildings/hd/
-- without modifying individual building Lua files.
-- Falls back to original sprite if HD version is not found.
--
-- Design:
--   * Lookup: assets/buildings/hd/<BuildingName>.png
--   * Each HD sprite is 256x256 (or larger for big buildings)
--   * Cached after first load
--   * Toggle with Command Palette (separate from HD terrain)
--
-- Buildings supported (71 total in objects/Structures/):
--   Apothecary, Bakery, Barracks, Blacksmith, Brewery, Cathedral,
--   Chapel, Church, DairyFarm, DefenseTower, EngineersGuild, Flat,
--   Fletcher, Fortress, Granary, HopsFarm, House, HunterHut, Inn,
--   Keep, Market, Maypole, Mine, Orchard, OxTether, PerimeterTower,
--   PitchRig, Poleturner, Quarry, Residence, RoundTower, SaxonHall,
--   Stable, Stockpile, StoneBarracks, StoneGate, StoneGateBig,
--   StoneGateEast, StoneWall, StoneStairs, StoneBattlements, etc.
--
-- Public API:
--   BuildingOverride.init()                 - preload all HD sprites
--   BuildingOverride.get(buildingName)      - get HD Image or nil
--   BuildingOverride.has(buildingName)      - check if HD exists
--   BuildingOverride.toggle()                - toggle HD on/off
--   BuildingOverride.isEnabled()             - check if HD enabled
--   BuildingOverride.getStats()              - debug info

local BuildingOverride = {}

-- Cache: buildingName → love.Image (or nil if not found)
local spriteCache = {}

-- Cache: buildingName → true (checked, not found — avoid re-checking disk)
local checkedCache = {}

-- HD enabled state (default: false)
local HD_ENABLED = false
local VISIBILITY_FILE = "buildings_hd_enabled.txt"

-- HD sprite directory
local HD_DIR = "assets/buildings/hd"

-- HD sprite size (256x256 for standard buildings, 512x512 for large)
local HD_SIZE = 256

-- Key buildings to support (most visible in game)
local KEY_BUILDINGS = {
    "Keep",
    "Stockpile",
    "Granary",
    "Barracks",
    "StoneBarracks",
    "Market",
    "Armoury",
    "Inn",
    "Cathedral",
    "Church",
    "Chapel",
    "Blacksmith",
    "Bakery",
    "Brewery",
    "Fletcher",
    "Poleturner",
    "Quarry",
    "Mine",
    "House",
    "Residence",
    "BigResidence",
    "Flat",
    "Stable",
    "Fortress",
    "RoundTower",
    "SquareTower",
    "DefenseTower",
    "PerimeterTower",
    "StoneWall",
    "StoneGate",
    "StoneGateBig",
    "StoneGateEast",
    "StoneStairs",
    "StoneBattlements",
    "EngineersGuild",
    "HunterHut",
    "DairyFarm",
    "HopsFarm",
    "Orchard",
    "OxTether",
    "PitchRig",
    "Maypole",
    "Campfire",
    "Apothecary",
    "Armorer",
    "SaxonHall",
    "LargeGarden",
    "MediumGarden",
    "SmallGarden",
    "LargePond",
    "SmallPond",
}

-- ============================================================
-- Persistence
-- ============================================================

local function loadVisibility()
    local ok, content = pcall(love.filesystem.read, VISIBILITY_FILE)
    if ok and content then
        content = content:gsub("%s+$", "")
        if content == "1" or content == "true" then
            HD_ENABLED = true
        end
    end
end

local function saveVisibility()
    pcall(love.filesystem.write, VISIBILITY_FILE, HD_ENABLED and "1" or "0")
end

loadVisibility()

-- ============================================================
-- Public API
-- ============================================================

-- Try to load HD sprite for a building
-- @param buildingName string (e.g. "Keep", "Barracks")
-- @return love.Image or nil if not found
function BuildingOverride.get(buildingName)
    if not buildingName then return nil end
    if not HD_ENABLED then return nil end

    -- Already checked?
    if checkedCache[buildingName] then
        return spriteCache[buildingName]
    end
    checkedCache[buildingName] = true

    -- Try to load from HD directory
    local path = HD_DIR .. "/" .. buildingName .. ".png"
    local ok, imageData = pcall(love.image.newImageData, path)
    if ok and imageData then
        local ok2, image = pcall(love.graphics.newImage, imageData)
        if ok2 and image then
            image:setFilter("linear", "linear")
            spriteCache[buildingName] = image
            return image
        end
    end

    -- Not found — return nil (building will use original sprite)
    return nil
end

-- Check if HD sprite exists for a building
function BuildingOverride.has(buildingName)
    if not buildingName then return false end
    if checkedCache[buildingName] then
        return spriteCache[buildingName] ~= nil
    end
    local result = BuildingOverride.get(buildingName)
    return result ~= nil
end

-- Preload all HD sprites
function BuildingOverride.init()
    local count = 0
    for _, name in ipairs(KEY_BUILDINGS) do
        local sprite = BuildingOverride.get(name)
        if sprite then
            count = count + 1
        end
    end
    print(string.format("[BuildingOverride] Initialized (%d HD building sprites loaded)", count))
    return count
end

-- Toggle HD on/off
function BuildingOverride.toggle()
    HD_ENABLED = not HD_ENABLED
    saveVisibility()
    if HD_ENABLED then
        BuildingOverride.init()
    end
    if _G.NotificationCenter then
        pcall(function()
            _G.NotificationCenter.system("HD Buildings: " .. (HD_ENABLED and "VKLOPLJEN" or "IZKLOPLJEN"))
        end)
    end
    if _G.UISoundHelper then
        pcall(function() _G.UISoundHelper.playToggleOn() end)
    end
end

function BuildingOverride.isEnabled()
    return HD_ENABLED
end

function BuildingOverride.setEnabled(state)
    HD_ENABLED = state and true or false
    saveVisibility()
end

function BuildingOverride.getHDSize()
    return HD_SIZE
end

function BuildingOverride.getKeyBuildings()
    return KEY_BUILDINGS
end

function BuildingOverride.getAvailableHD()
    local available = {}
    for _, name in ipairs(KEY_BUILDINGS) do
        if BuildingOverride.has(name) then
            table.insert(available, name)
        end
    end
    return available
end

function BuildingOverride.getStats()
    local loadedCount = 0
    for _, name in ipairs(KEY_BUILDINGS) do
        if checkedCache[name] and spriteCache[name] then
            loadedCount = loadedCount + 1
        end
    end
    return {
        hdEnabled = HD_ENABLED,
        totalBuildings = #KEY_BUILDINGS,
        loadedSprites = loadedCount,
        hdDir = HD_DIR,
        hdSize = HD_SIZE,
    }
end

function BuildingOverride.reset()
    for name, image in pairs(spriteCache) do
        if image and image.release then
            pcall(function() image:release() end)
        end
    end
    spriteCache = {}
    checkedCache = {}
end

return BuildingOverride
