local _, _, tileQuads, _, Tree = ...
local anim = require("libraries.anim8")
local indexQuads = _G.indexQuads

local frDeadStatic = {tileQuads["tree_oak_dead (1)"]}

local frStatic = indexQuads("tree_oak_large", 25, nil, true)
local frFalling = indexQuads("tree_oak_large_falling", 7)
local frChop = indexQuads("tree_oak_large_falling", 17, 7)

local frMediumStatic = indexQuads("tree_oak_medium", 25, nil, true)
local frMediumFalling = indexQuads("tree_oak_medium_falling", 8)
local frMediumChop = indexQuads("tree_oak_medium_falling", 12, 8)

local frSmallStatic = indexQuads("tree_oak_small", 25, nil, true)
local frSmallFalling = indexQuads("tree_oak_small_falling", 8)
local frSmallChop = indexQuads("tree_oak_small_falling", 10, 8)

local frVerySmallStatic = indexQuads("tree_oak_very_small", 25, nil, true)
local frVerySmallFalling = indexQuads("tree_oak_very_small_falling", 5)
local frVerySmallChop = indexQuads("tree_oak_very_small_falling", 7, 6)

local OakTree = _G.class('OakTree', Tree)
function OakTree:initialize(gx, gy, type)
    type = type or "Oak tree"
    Tree.initialize(self, gx, gy, type)
    self.offsetY = -144
    self.baseOffsetX = -73
    self.offsetX = self.baseOffsetX
    self.trunkTile = tileQuads["tree_oak_trunk (1)"]
    self.trunkOffsetY = -166 + 10
    self.trunkOffsetX = -41 - 20

    if type == "Oak tree" then
        self.health = 10
        self.animation = anim.newAnimation(frStatic, 0.1)
        self.chopAnimation = anim.newAnimation(frChop, 0.1)
        self.fallingAnimation = anim.newAnimation(frFalling, 0.13, self:cutDown())
        for xx = -1, 1 do
            for yy = -1, 1 do
                _G.terrainSetTileAt(gx + xx, gy + yy, _G.terrainBiome.dirt)
            end
        end
    elseif type == "Dead oak tree" then
        self.health = 4
        self.animation = anim.newAnimation(frDeadStatic, 0.1)
        self.dead = true
    elseif type == "Medium oak tree" then
        self.health = 6
        self.animation = anim.newAnimation(frMediumStatic, 0.1)
        self.chopAnimation = anim.newAnimation(frMediumChop, 0.1)
        self.fallingAnimation = anim.newAnimation(frMediumFalling, 0.13, self:cutDown())
        for xx = -1, 1 do
            for yy = -1, 1 do
                _G.terrainSetTileAt(gx + xx, gy + yy, _G.terrainBiome.dirt)
            end
        end
    elseif type == "Small oak tree" then
        self.health = 3
        self.animation = anim.newAnimation(frSmallStatic, 0.1)
        self.chopAnimation = anim.newAnimation(frSmallChop, 0.1)
        self.fallingAnimation = anim.newAnimation(frSmallFalling, 0.13, self:cutDown())
    elseif type == "Very small oak tree" then
        self.health = 2
        self.cuttable = true
        self.animation = anim.newAnimation(frVerySmallStatic, 0.1)
        self.chopAnimation = anim.newAnimation(frVerySmallChop, 0.1)
        self.fallingAnimation = anim.newAnimation(frVerySmallFalling, 0.13, self:cutDown())
    end
end

return OakTree
