local Structure = require("objects.Structure")
local Object = require("objects.Object")
local tileQuads = require("objects.object_quads")


local ArcheryTarget = _G.class("ArcheryTarget", Structure)

ArcheryTarget.static.WIDTH = 1
ArcheryTarget.static.LENGTH = 1
ArcheryTarget.static.HEIGHT = 17
ArcheryTarget.static.DESTRUCTIBLE = true

function ArcheryTarget:initialize(gx, gy)
    Structure.initialize(self, gx, gy, "ArcheryTarget")
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.health = 1000
    self.tile = tileQuads["barracks_target_actual (1)"]
    self.offsetX = 0
    self.offsetY = -45
    self:applyBuildingHeightMap()
end

function ArcheryTarget:onClick()
    -- local ActionBar = require("states.ui.ActionBar")
    -- TODO: ActionBar:switchMode("Barracks")
end

function ArcheryTarget:load(data)
    Object.deserialize(self, data)
    Structure.load(self, data)
    if self.parent then
        self.parent = _G.state:dereferenceObject(self.parent)
    end
    self.tile = tileQuads["barracks_target_actual (1)"]
    Structure.render(self)
end

function ArcheryTarget:serialize()
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

function ArcheryTarget.static:deserialize(data)
    local obj = self:allocate()
    obj:load(data)
    return obj
end

return ArcheryTarget
