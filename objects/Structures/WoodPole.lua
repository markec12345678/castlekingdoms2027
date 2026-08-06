local Structure = require("objects.Structure")
local Object = require("objects.Object")

local tileQuads = require("objects.object_quads")
local WoodPole = _G.class("WoodPole", Structure)

WoodPole.static.WIDTH = 1
WoodPole.static.LENGTH = 1
WoodPole.static.HEIGHT = 17
WoodPole.static.DESTRUCTIBLE = true

function WoodPole:initialize(gx, gy)
    Structure.initialize(self, gx, gy, "WoodPole")
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.health = 1000
    self.tile = tileQuads["barracks_pole_actual"]
    self.offsetX = 0
    self.offsetY = -93
    self:applyBuildingHeightMap()
end

function WoodPole:onClick()
    -- local ActionBar = require("states.ui.ActionBar")
    -- TODO: ActionBar:switchMode("Barracks")
end

function WoodPole:load(data)
    Object.deserialize(self, data)
    Structure.load(self, data)
    if self.parent then
        self.parent = _G.state:dereferenceObject(self.parent)
    end
    self.tile = tileQuads["barracks_pole_actual"]
    Structure.render(self)
end

function WoodPole:serialize()
    local data = {}
    local structData = Structure.serialize(self)
    for k, v in pairs(structData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.health = self.health
    data.offsetX = self.offsetX
    data.offsetY = self.offsetY
    if self.parent then
        data.parent = _G.state:serializeObject(self.parent)
    end
    return data
end

function WoodPole.static:deserialize(data)
    local obj = self:allocate()
    obj:load(data)
    return obj
end

return WoodPole
