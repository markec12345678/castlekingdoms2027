local _, _, tile_quads, _, Tree = ...
local anim = require("libraries.anim8")

local fr_dead_static = {tile_quads["tree_pine_dead (1)"]}

local fr_static = indexQuads("tree_pine_large", 25, nil, true)
local fr_falling = indexQuads("tree_pine_large_falling", 7)
local fr_chop = indexQuads("tree_pine_large_falling", 10, 7)

local fr_medium_static = indexQuads("tree_pine_medium", 25, nil, true)
local fr_medium_falling = indexQuads("tree_pine_medium_falling", 8)
local fr_medium_chop = indexQuads("tree_pine_medium_falling", 12, 8)

local fr_small_static = indexQuads("tree_pine_small", 25, nil, true)
local fr_small_falling = indexQuads("tree_pine_small_falling", 8)
local fr_small_chop = indexQuads("tree_pine_small_falling", 10, 8)

local fr_very_small_static = indexQuads("tree_pine_very_small", 25, nil, true)
local fr_very_small_falling = indexQuads("tree_pine_very_small_falling", 5)
local fr_very_small_chop = indexQuads("tree_pine_very_small_falling", 7, 6)

local PineTree = class('PineTree', Tree)
function PineTree:initialize(gx, gy, type)
    type = type or "Pine tree"
    Tree.initialize(self, gx, gy, type)
    self.offset_y = -166
    self.base_offset_x = -3 - 38
    self.trunk_tile = tile_quads["tree_pine_trunk (1)"]
    self.dead = false

    for xx = -1, 1 do
        for yy = -1, 1 do
            _G.terrainSetTileAt(gx + xx, gy + yy, _G.terrain_biome.dirt)
        end
    end
    if type == "Pine tree" then
        self.health = 6
        self.animation = anim.newAnimation(fr_static, 0.1)
        self.chop_animation = anim.newAnimation(fr_chop, 0.1)
        self.falling_animation = anim.newAnimation(fr_falling, 0.13, self.cut_down)
        for xx = -1, 1 do
            for yy = -1, 1 do
                _G.terrainSetTileAt(gx + xx, gy + yy, _G.terrain_biome.scarce_grass)
            end
        end
    elseif type == "Dead pine tree" then
        self.health = 4
        self.animation = anim.newAnimation(fr_dead_static, 0.1)
        self.dead = true
    elseif type == "Medium pine tree" then
        self.health = 4
        self.animation = anim.newAnimation(fr_medium_static, 0.1)
        self.chop_animation = anim.newAnimation(fr_medium_chop, 0.1)
        self.falling_animation = anim.newAnimation(fr_medium_falling, 0.13, self.cut_down)
    elseif type == "Small pine tree" then
        self.health = 2
        self.animation = anim.newAnimation(fr_small_static, 0.1)
        self.chop_animation = anim.newAnimation(fr_small_chop, 0.1)
        self.falling_animation = anim.newAnimation(fr_small_falling, 0.13, self.cut_down)
    elseif type == "Very small pine tree" then
        self.health = 1
        self.cuttable = false
        self.animation = anim.newAnimation(fr_very_small_static, 0.1)
        self.chop_animation = anim.newAnimation(fr_very_small_chop, 0.1)
        self.falling_animation = anim.newAnimation(fr_very_small_falling, 0.13, self.cut_down)
    end
end

return PineTree
