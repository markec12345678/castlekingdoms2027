local buildings = require("objects.buildings")
local Events = require "objects.Enums.Events"

---@class BuildingManager
---@field private buildings table<string, table<integer, Object>>
---@field private initialize function
local BuildingManager = _G.class("BuildingManager")
function BuildingManager:initialize()
    self.buildings = {}
    for k, _ in pairs(buildings) do
        self.buildings[k] = {}
    end
end

---register a building in the building manager
---@param building Object
function BuildingManager:add(building)
    self.buildings[building.class.name][building.id] = building
    _G.bus.emit(Events.OnBuildingPlaced, building.class.name, building.gx, building.gy)
end

---prints how many of each buildings exist
function BuildingManager:print()
    print("_____________________")
    for k, _ in pairs(self.buildings) do
        print(string.format("%s: %d", k, self:count(k)))
    end
end

---register a building in the building manager
---@param building Object
---@return boolean whether the building existed in the building manager
function BuildingManager:remove(building)
    if self.buildings[building.class.name] and self.buildings[building.class.name][building.id] then
        self.buildings[building.class.name][building.id] = nil
        _G.bus.emit(Events.OnBuildingDestroyed, building.class.name)
        return true
    end
    return false
end

---@param buildingClass {name: string}|string
---@return table listOfBuildings list of player owned buildings
function BuildingManager:getPlayerBuildings(buildingClass)
    buildingClass = type(buildingClass) == "string" and buildingClass or buildingClass.name
    -- create a new list so the original doesn't get modified
    local list = {}
    for _, v in pairs(self.buildings[buildingClass]) do
        list[#list + 1] = v
    end
    return list
end

---@return integer positiveBuildings count of player owned positive buildings
function BuildingManager:getCountOfPositiveBuildings()
    local count = 0
    count = count + #self:getPlayerBuildings("LargeGarden")
    count = count + #self:getPlayerBuildings("MediumGarden")
    count = count + #self:getPlayerBuildings("SmallGarden")
    count = count + #self:getPlayerBuildings("SmallPond")
    count = count + #self:getPlayerBuildings("LargePond")
    count = count + #self:getPlayerBuildings("Maypole")
    return count
end

---@param buildingClass {name: string}|string
---@return integer count total count of a specific building class
function BuildingManager:count(buildingClass)
    if type(buildingClass) == "table" then
        buildingClass = buildingClass.name
    end
    local count = 0
    for _, v in pairs(self.buildings[buildingClass]) do
        count = count + 1
    end
    return count
end

function BuildingManager:serialize()
    local data = {}
    local list = {}
    for _, v in pairs(self.buildings) do
        for _, sv in pairs(v) do
            list[#list + 1] = _G.state:serializeObject(sv)
        end
    end
    data.rawlist = list
    return data
end

---Builds an indexed list of all buildings that are managed by the building manager.
---@return table buildingList   list of all active buildings
function BuildingManager:listAllActiveBuildings(withoutWalls)
    local buildingList = {}
    for type, typeBuildings in pairs(self.buildings) do
        if not (withoutWalls and (type == "WalkableWoodenWall" or type == "WoodenWall")) then
            for key, building in pairs(typeBuildings) do
                table.insert(buildingList, building)
            end
        end
    end
    return buildingList
end

--- As the name suggests, returns a random key, value pair of any of the table's properties
---@param table table table to choose a key from
---@return any k the randomly chosen key
---@return any v the randomly chosen value at that key
local function getRandomTableKey(table)
    local function tableLength(T)
        local count = 0
        for k, v in pairs(T) do
            count = count + 1
        end
        return count
    end

    local keyCount = tableLength(table)
    local randomKey = math.random(1, keyCount)

    local i = 0
    for k, v in pairs(table) do
        i = i + 1
        if i == randomKey then
            return k, v
        end
    end
end

---chooses at random a placed building and returns its object
---@return table randomBuilding the randomly chosen building object
function BuildingManager:getRandomBuilding()
    local buildingsToChooseFrom = _G.BuildingManager:listAllActiveBuildings(true)
    local _, randomBuilding = getRandomTableKey(buildingsToChooseFrom)

    return randomBuilding
end

function BuildingManager:deserialize(data)
    for _, v in ipairs(data.rawlist) do
        local building = _G.state:dereferenceObject(v)
        self:add(building)
    end
end

---@type BuildingManager
local manager = BuildingManager:new()
return manager
