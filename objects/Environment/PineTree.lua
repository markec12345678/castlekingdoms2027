local _, _, tile_quads, _, Tree = ...
local anim = require("libraries.anim8")
local Object = require('objects.Object')

local STATIC_TRUNK = "Static Trunk"
local ANIM_DEAD_STATIC = "Dead_Static"
local ANIM_STATIC = "Static"
local ANIM_FALLING = "Falling"
local ANIM_CHOP = "Chop"
local ANIM_MEDIUM_STATIC = "Medium_Static"
local ANIM_MEDIUM_FALLING = "Medium_Falling"
local ANIM_MEDIUM_CHOP = "Medium_Chop"
local ANIM_SMALL_STATIC = "Small_Static"
local ANIM_SMALL_FALLING = "Small_Falling"
local ANIM_SMALL_CHOP = "Small_Chop"
local ANIM_VERY_SMALL_STATIC = "Very_Small_Static"
local ANIM_VERY_SMALL_FALLING = "Very_Small_Falling"
local ANIM_VERY_SMALL_CHOP = "Very_Small_Chop"

local an = {
    [STATIC_TRUNK] = {tile_quads["tree_pine_trunk (1)"]},
    [ANIM_DEAD_STATIC] = {tile_quads["tree_pine_dead (1)"]},
    [ANIM_STATIC] = _G.indexQuads("tree_pine_large", 25, nil, true),
    [ANIM_FALLING] = _G.indexQuads("tree_pine_large_falling", 7),
    [ANIM_CHOP] = _G.indexQuads("tree_pine_large_falling", 10, 7),
    [ANIM_MEDIUM_STATIC] = _G.indexQuads("tree_pine_medium", 25, nil, true),
    [ANIM_MEDIUM_FALLING] = _G.indexQuads("tree_pine_medium_falling", 8),
    [ANIM_MEDIUM_CHOP] = _G.indexQuads("tree_pine_medium_falling", 12, 8),
    [ANIM_SMALL_STATIC] = _G.indexQuads("tree_pine_small", 25, nil, true),
    [ANIM_SMALL_FALLING] = _G.indexQuads("tree_pine_small_falling", 8),
    [ANIM_SMALL_CHOP] = _G.indexQuads("tree_pine_small_falling", 10, 8),
    [ANIM_VERY_SMALL_STATIC] = _G.indexQuads("tree_pine_very_small", 25, nil, true),
    [ANIM_VERY_SMALL_FALLING] = _G.indexQuads("tree_pine_very_small_falling", 5),
    [ANIM_VERY_SMALL_CHOP] = _G.indexQuads("tree_pine_very_small_falling", 7, 6)
}

local PineTree = _G.class('PineTree', Tree)
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
        self.health = 14
        self.animation = anim.newAnimation(an[ANIM_STATIC], 0.09, nil, ANIM_STATIC)
        self.chop_animation = anim.newAnimation(an[ANIM_CHOP], 0.1, nil, ANIM_CHOP)
        self.falling_animation = anim.newAnimation(an[ANIM_FALLING], 0.13, self:cut_down(), ANIM_FALLING)
        for xx = -1, 1 do
            for yy = -1, 1 do
                _G.terrainSetTileAt(gx + xx, gy + yy, _G.terrain_biome.scarce_grass)
            end
        end
    elseif type == "Dead pine tree" then
        self.health = 5
        self.animation = anim.newAnimation(an[ANIM_DEAD_STATIC], 0.09, nil, ANIM_DEAD_STATIC)
        self.dead = true
    elseif type == "Medium pine tree" then
        self.health = 12
        self.animation = anim.newAnimation(an[ANIM_MEDIUM_STATIC], 0.09, nil, ANIM_MEDIUM_STATIC)
        self.chop_animation = anim.newAnimation(an[ANIM_MEDIUM_CHOP], 0.1, nil, ANIM_MEDIUM_CHOP)
        self.falling_animation = anim.newAnimation(an[ANIM_MEDIUM_FALLING], 0.13, self:cut_down(), ANIM_MEDIUM_FALLING)
    elseif type == "Small pine tree" then
        self.health = 5
        self.animation = anim.newAnimation(an[ANIM_SMALL_STATIC], 0.09, nil, ANIM_SMALL_STATIC)
        self.chop_animation = anim.newAnimation(an[ANIM_SMALL_CHOP], 0.1, nil, ANIM_SMALL_CHOP)
        self.falling_animation = anim.newAnimation(an[ANIM_SMALL_FALLING], 0.13, self:cut_down(), ANIM_SMALL_FALLING)
    elseif type == "Very small pine tree" then
        self.health = 3
        self.cuttable = false
        self.animation = anim.newAnimation(an[ANIM_VERY_SMALL_STATIC], 0.09, nil, ANIM_VERY_SMALL_STATIC)
        self.chop_animation = anim.newAnimation(an[ANIM_VERY_SMALL_CHOP], 0.1, nil, ANIM_VERY_SMALL_CHOP)
        self.falling_animation = anim.newAnimation(an[ANIM_VERY_SMALL_FALLING], 0.13, self:cut_down(),
            ANIM_VERY_SMALL_FALLING)
    elseif type == "Stump" then
        self.animation = anim.newAnimation(an[STATIC_TRUNK], 0.1, nil, STATIC_TRUNK)
        self.animation:pause()
        self.stump = true
        self.animated = false -- mark for removal from list
        -- _G.state.chunk_objects[self.cx][self.cy][self] = nil
        self.type = "Stump"
        self.tile = self.trunk_tile
        self:render()
    end
end
function PineTree:load(data)
    Object.deserialize(self, data)
    Tree.load(self, data)
    local an_data = data.animation
    if an_data then
        local callback
        if an_data.animation_identifier == ANIM_VERY_SMALL_FALLING or an_data.animation_identifier == ANIM_SMALL_FALLING or
            an_data.animation_identifier == ANIM_MEDIUM_FALLING or an_data.animation_identifier == ANIM_FALLING then
            callback = self:cut_down()
        end
        self.animation = anim.newAnimation(an[an_data.animation_identifier], 1, callback, an_data.animation_identifier)
        self.animation:deserialize(an_data)
    end
    an_data = data.chop_animation
    if an_data then
        self.chop_animation = anim.newAnimation(an[an_data.animation_identifier], 1, nil, an_data.animation_identifier)
        self.chop_animation:deserialize(an_data)
    end
    an_data = data.falling_animation
    if an_data then
        local callback
        if an_data.animation_identifier == ANIM_VERY_SMALL_FALLING or an_data.animation_identifier == ANIM_SMALL_FALLING or
            an_data.animation_identifier == ANIM_MEDIUM_FALLING or an_data.animation_identifier == ANIM_FALLING then
            callback = self:cut_down()
        end
        self.falling_animation = anim.newAnimation(an[an_data.animation_identifier], 1, callback,
            an_data.animation_identifier)
        self.falling_animation:deserialize(an_data)
    end
    self.trunk_tile = tile_quads["tree_pine_trunk (1)"]
    if self.type == "Stump" then
        self.tile = self.trunk_tile
        self:render()
    end
end
function PineTree:serialize()
    local data = {}
    local tree_data = Tree.serialize(self)
    for k, v in pairs(tree_data) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.offset_y = self.offset_y
    data.base_offset_x = self.base_offset_x
    data.dead = self.dead
    data.cuttable = self.cuttable
    data.health = self.health
    data.type = self.type
    data.animated = self.animated
    if self.animation then
        data.animation = self.animation:serialize()
    end
    if self.chop_animation then
        data.chop_animation = self.chop_animation:serialize()
    end
    if self.falling_animation then
        data.falling_animation = self.falling_animation:serialize()
    end
    return data
end

function PineTree.static:deserialize(data)
    local obj = self:allocate()
    data.need_new_vert_asap = true
    Object.deserialize(obj, data)
    obj:load(data)
    return obj
end

return PineTree
