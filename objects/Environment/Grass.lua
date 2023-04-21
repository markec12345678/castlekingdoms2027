local _, _, _, _ = ...
local Object = require("objects.Object")

local tilesGrass = _G.indexQuads("abundant_grass_1x1", 16)

local Grass = _G.class("Grass", Object)
function Grass:place(gx, gy, type, biome, grassType)
    local cx, cy, i, o = _G.getLocalCoordinatesFromGlobal(gx, gy)
    _G.removeObjectAt(cx, cy, i, o, nil)
    _G.terrainSetTileAt(gx, gy, biome, grassType)
    _G.state.map:setWalkable(gx, gy, 0)
end

return Grass
