local Structure = require("objects.Structure")
local Object = require("objects.Object")


local MeleeTarget = _G.class("MeleeTarget", Structure)
local tileQuads = require("objects.object_quads")

MeleeTarget.static.WIDTH = 1
MeleeTarget.static.LENGTH = 1
MeleeTarget.static.HEIGHT = 17
MeleeTarget.static.DESTRUCTIBLE = true

function MeleeTarget:initialize(gx, gy)
    Structure.initialize(self, gx, gy, "MeleeTarget")
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.health = 1000
    self.tile = tileQuads["barracks_trainer_actual"]
    self.offsetX = 0
    self.offsetY = -27
    self:applyBuildingHeightMap()
end

function MeleeTarget:onClick()
    -- local ActionBar = require("states.ui.ActionBar")
    -- TODO: ActionBar:switchMode("Barracks")
end

function MeleeTarget:load(data)
    Object.deserialize(self, data)
    Structure.load(self, data)
    if self.parent then
        self.parent = _G.state:dereferenceObject(self.parent)
    end
    self.tile = tileQuads["barracks_trainer_actual"]
    Structure.render(self)
end

function MeleeTarget:serialize()
    local data = {}
    local structData = Structure.serialize(self)
    for k, v in pairs(structData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    if self.parent then
        data.parent = _G.state:serializeObject(self.parent)
    end
    data.health = self.health
    data.offsetX = self.offsetX
    data.offsetY = self.offsetY
    return data
end

function MeleeTarget.static:deserialize(data)
    local obj = self:allocate()
    obj:load(data)
    return obj
end

return MeleeTarget
