-- objects/Units/UnitSpriteOverride.lua
-- Castle Kingdoms 2027 v3.12.226 - HD Unit Sprite Override System
--
-- Allows HD unit sprites to be loaded from assets/units/hd/
-- without modifying individual Unit Lua files.
-- Falls back to original sprite if HD version is not found.
--
-- Design:
--   * Lookup: assets/units/hd/<UnitName>.png
--   * Each HD sprite is 128x128 (2x original 64x64)
--   * Cached after first load
--   * Toggle with Command Palette
--
-- Units supported (combat + animals):
--   Archer, Crossbowman, Spearman, Pikeman, Maceman, Swordsman,
--   Knight, Lord, Ladderman, Engineer, Peasant, Healer, Hunter,
--   Chicken, Cow, Deer, Bear, Rabbit, Ox
--
-- Public API:
--   UnitOverride.init()                 - preload all HD sprites
--   UnitOverride.get(unitName)          - get HD Image or nil
--   UnitOverride.has(unitName)          - check if HD exists
--   UnitOverride.toggle()               - toggle HD on/off
--   UnitOverride.isEnabled()            - check if HD enabled
--   UnitOverride.getStats()             - debug info

local UnitOverride = {}

local spriteCache = {}
local checkedCache = {}
local HD_ENABLED = false
local VISIBILITY_FILE = "units_hd_enabled.txt"
local HD_DIR = "assets/units/hd"
local HD_SIZE = 128

-- Combat units + animals
local KEY_UNITS = {
    "Archer",
    "Crossbowman",
    "Spearman",
    "Pikeman",
    "Maceman",
    "Swordsman",
    "Knight",
    "Lord",
    "Ladderman",
    "Engineer",
    "Peasant",
    "Healer",
    "Hunter",
    "Chicken",
    "Cow",
    "Deer",
    "Bear",
    "Rabbit",
    "Ox",
    "Soldier",
}

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

function UnitOverride.get(unitName)
    if not unitName then return nil end
    if not HD_ENABLED then return nil end
    if checkedCache[unitName] then
        return spriteCache[unitName]
    end
    checkedCache[unitName] = true
    local path = HD_DIR .. "/" .. unitName .. ".png"
    local ok, imageData = pcall(love.image.newImageData, path)
    if ok and imageData then
        local ok2, image = pcall(love.graphics.newImage, imageData)
        if ok2 and image then
            image:setFilter("linear", "linear")
            spriteCache[unitName] = image
            return image
        end
    end
    return nil
end

function UnitOverride.has(unitName)
    if not unitName then return false end
    if checkedCache[unitName] then
        return spriteCache[unitName] ~= nil
    end
    return UnitOverride.get(unitName) ~= nil
end

function UnitOverride.init()
    local count = 0
    for _, name in ipairs(KEY_UNITS) do
        if UnitOverride.get(name) then
            count = count + 1
        end
    end
    print(string.format("[UnitOverride] Initialized (%d HD unit sprites)", count))
    return count
end

function UnitOverride.toggle()
    HD_ENABLED = not HD_ENABLED
    saveVisibility()
    if HD_ENABLED then
        UnitOverride.init()
    end
    if _G.NotificationCenter then
        pcall(function()
            _G.NotificationCenter.system("HD Units: " .. (HD_ENABLED and "VKLOPLJEN" or "IZKLOPLJEN"))
        end)
    end
    if _G.UISoundHelper then
        pcall(function() _G.UISoundHelper.playToggleOn() end)
    end
end

function UnitOverride.isEnabled()
    return HD_ENABLED
end

function UnitOverride.setEnabled(state)
    HD_ENABLED = state and true or false
    saveVisibility()
end

function UnitOverride.getHDSize()
    return HD_SIZE
end

function UnitOverride.getKeyUnits()
    return KEY_UNITS
end

function UnitOverride.getAvailableHD()
    local available = {}
    for _, name in ipairs(KEY_UNITS) do
        if UnitOverride.has(name) then
            table.insert(available, name)
        end
    end
    return available
end

function UnitOverride.getStats()
    local loadedCount = 0
    for _, name in ipairs(KEY_UNITS) do
        if checkedCache[name] and spriteCache[name] then
            loadedCount = loadedCount + 1
        end
    end
    return {
        hdEnabled = HD_ENABLED,
        totalUnits = #KEY_UNITS,
        loadedSprites = loadedCount,
        hdDir = HD_DIR,
        hdSize = HD_SIZE,
    }
end

function UnitOverride.reset()
    for name, image in pairs(spriteCache) do
        if image and image.release then
            pcall(function() image:release() end)
        end
    end
    spriteCache = {}
    checkedCache = {}
end

return UnitOverride
