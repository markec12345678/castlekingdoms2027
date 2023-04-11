local activeEntities, _, _ = ...

local tileQuads = require("objects.object_quads")
local Structure = require("objects.Structure")
local Object = require("objects.Object")
local Maypole = _G.class("Maypole", Structure)

local ANIM_EMPTY = "Empty"
local ANIM_FULL = "Full"

local an = {
    [ANIM_EMPTY] = _G.indexQuads("anim_maypole_empty", 20),
    [ANIM_FULL] = _G.indexQuads("anim_maypole_full", 32),
}

local MaypoleAlias = _G.class("MaypoleAlias", Structure)
function MaypoleAlias:initialize(tile, gx, gy, parent, offsetY, offsetX)
    Structure.initialize(self, gx, gy, "MaypoleAlias")
    self.tile = tile
    self.parent = parent
    self.offsetX = offsetX
    self.offsetY = offsetY
    self:render()
end

local MaypolePillar = _G.class("MaypolePillar", Structure)
function MaypolePillar:initialize(gx, gy, parent)
    Structure.initialize(self, gx, gy, "MaypolePillar")
    self.tile = tileQuads["empty"]
    self.parent = parent
    self.offsetX = 32
    self.offsetY = -74
    self.animated = true
    self.animation = anim.newAnimation(an[ANIM_FULL], 0.11, self:animCallback(), ANIM_FULL)
    self:render()
    _G.registerAnimatedEntity(self)
end

function MaypolePillar:animCallback()
end

Maypole.static.WIDTH = 3
Maypole.static.LENGTH = 3
Maypole.static.HEIGHT = 0
Maypole.static.ALIAS_NAME = "MaypoleAlias"
Maypole.static.DESTRUCTIBLE = true
function Maypole:initialize(gx, gy)
    Structure.initialize(self, gx, gy, "Maypole")
    local tileKey = "anim_maypole_full (1)"
    self.tile = tileQuads["empty"]
    self.offsetY = -96 + 16
    self.animated = true

    for xx = -2, 4 do
        for yy = -2, 4 do
            _G.terrainSetTileAt(gx + xx, gy + yy, _G.terrainBiome.scarceGrass)
        end
    end

    for xx = 0, self.class.WIDTH - 1 do
        for yy = 0, self.class.LENGTH - 1 do
            if not _G.objectFromSubclassAtGlobal(self.gx + xx, self.gy + yy, "Structure") then
                MaypoleAlias:new(tileQuads["empty"], self.gx + xx, self.gy + yy, self, 0, 0)
            end
        end
    end

    self.pillar = MaypolePillar:new(self.gx, self.gy + self.class.LENGTH + 1, self)

    self:applyBuildingHeightMap(true)
end

function Maypole:destroy()
    Structure.destroy(self)
end

function Maypole:serialize()
    local data = {}
    local structData = Structure.serialize(self)
    for k, v in pairs(structData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    return data
end

function Maypole.static:deserialize(data)
    local obj = self:new(data.gx, data.gy)
    Object.deserialize(obj, data)
    return obj
end

return Maypole
