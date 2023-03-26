local buildings = require("objects.buildings")

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

function BuildingManager:deserialize(data)
    for _, v in ipairs(data.rawlist) do
        local building = _G.state:dereferenceObject(v)
        self:add(building)
    end
end

---@type BuildingManager
local manager = BuildingManager:new()
return manager
