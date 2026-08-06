local Tree = require("objects.Environment.Tree")
local tileQuads = require("objects.object_quads")
local anim = require("libraries.anim8")
local Object = require("objects.Object")

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
    [STATIC_TRUNK] = { tileQuads["tree_birch_trunk (1)"] },
    [ANIM_DEAD_STATIC] = { tileQuads["tree_birch_dead (1)"] },
    [ANIM_STATIC] = _G.indexQuads("tree_birch_large", 25, nil, true),
    [ANIM_FALLING] = _G.indexQuads("tree_birch_large_falling", 7),
    [ANIM_CHOP] = _G.indexQuads("tree_birch_large_falling", 10, 7),
    [ANIM_MEDIUM_STATIC] = _G.indexQuads("tree_birch_medium", 25, nil, true),
    [ANIM_MEDIUM_FALLING] = _G.indexQuads("tree_birch_medium_falling", 8),
    [ANIM_MEDIUM_CHOP] = _G.indexQuads("tree_birch_medium_falling", 12, 8),
    [ANIM_SMALL_STATIC] = _G.indexQuads("tree_birch_small", 25, nil, true),
    [ANIM_SMALL_FALLING] = _G.indexQuads("tree_birch_small_falling", 8),
    [ANIM_SMALL_CHOP] = _G.indexQuads("tree_birch_small_falling", 10, 8),
    [ANIM_VERY_SMALL_STATIC] = _G.indexQuads("tree_birch_very_small", 25, nil, true),
    [ANIM_VERY_SMALL_FALLING] = _G.indexQuads("tree_birch_very_small_falling", 5),
    [ANIM_VERY_SMALL_CHOP] = _G.indexQuads("tree_birch_very_small_falling", 7, 6)
}

local BirchTree = _G.class("BirchTree", Tree)
function BirchTree:initialize(gx, gy, type)
    type = type or "Birch tree"
    Tree.initialize(self, gx, gy, type)
    self:usePallete(math.random(1, 10))
    self.offsetY = -136
    self.baseOffsetX = -17 - 38
    self.trunkTile = tileQuads["tree_birch_trunk (1)"]
    self.dead = false

    for xx = -1, 1 do
        for yy = -1, 1 do
            _G.terrainSetTileAt(gx + xx, gy + yy, _G.terrainBiome.dirt, _G.terrainBiome.abundantGrass)
        end
    end
    if type == "Birch tree" then
        self.health = 14
        self.animation = anim.newAnimation(an[ANIM_STATIC], 0.09, nil, ANIM_STATIC)
        self.chopAnimation = anim.newAnimation(an[ANIM_CHOP], 0.1, nil, ANIM_CHOP)
        self.fallingAnimation = anim.newAnimation(an[ANIM_FALLING], 0.13, self:cutDown(), ANIM_FALLING)
        for xx = -1, 1 do
            for yy = -1, 1 do
                _G.terrainSetTileAt(gx + xx, gy + yy, _G.terrainBiome.scarceGrass)
            end
        end
    elseif type == "Dead birch tree" then
        self.health = 5
        self.animation = anim.newAnimation(an[ANIM_DEAD_STATIC], 0.09, nil, ANIM_DEAD_STATIC)
        self.dead = true
    elseif type == "Medium birch tree" then
        self.health = 12
        self.animation = anim.newAnimation(an[ANIM_MEDIUM_STATIC], 0.09, nil, ANIM_MEDIUM_STATIC)
        self.chopAnimation = anim.newAnimation(an[ANIM_MEDIUM_CHOP], 0.1, nil, ANIM_MEDIUM_CHOP)
        self.fallingAnimation = anim.newAnimation(an[ANIM_MEDIUM_FALLING], 0.13, self:cutDown(), ANIM_MEDIUM_FALLING)
    elseif type == "Small birch tree" then
        self.health = 5
        self.animation = anim.newAnimation(an[ANIM_SMALL_STATIC], 0.09, nil, ANIM_SMALL_STATIC)
        self.chopAnimation = anim.newAnimation(an[ANIM_SMALL_CHOP], 0.1, nil, ANIM_SMALL_CHOP)
        self.fallingAnimation = anim.newAnimation(an[ANIM_SMALL_FALLING], 0.13, self:cutDown(), ANIM_SMALL_FALLING)
    elseif type == "Very small birch tree" then
        self.health = 3
        self.cuttable = false
        self.animation = anim.newAnimation(an[ANIM_VERY_SMALL_STATIC], 0.09, nil, ANIM_VERY_SMALL_STATIC)
        self.chopAnimation = anim.newAnimation(an[ANIM_VERY_SMALL_CHOP], 0.1, nil, ANIM_VERY_SMALL_CHOP)
        self.fallingAnimation = anim.newAnimation(
            an[ANIM_VERY_SMALL_FALLING], 0.13, self:cutDown(), ANIM_VERY_SMALL_FALLING)
    elseif type == "Stump" then
        self.animation = anim.newAnimation(an[STATIC_TRUNK], 0.1, nil, STATIC_TRUNK)
        self.animation:pause()
        self.stump = true
        self.animated = false -- mark for removal from list
        -- _G.state.chunkObjects[self.cx][self.cy][self] = nil
        self.type = "Stump"
        self.tile = self.trunkTile
        self:render()
    else
        error("invalid tree type: " .. tostring(type))
    end
end

function BirchTree:load(data)
    Object.deserialize(self, data)
    Tree.load(self, data)
    local anData = data.animation
    if anData then
        local callback
        if anData.animationIdentifier == ANIM_VERY_SMALL_FALLING or anData.animationIdentifier == ANIM_SMALL_FALLING or
            anData.animationIdentifier == ANIM_MEDIUM_FALLING or anData.animationIdentifier == ANIM_FALLING then
            callback = self:cutDown()
        end
        self.animation = anim.newAnimation(an[anData.animationIdentifier], 1, callback, anData.animationIdentifier)
        self.animation:deserialize(anData)
    end
    anData = data.chopAnimation
    if anData then
        self.chopAnimation = anim.newAnimation(an[anData.animationIdentifier], 1, nil, anData.animationIdentifier)
        self.chopAnimation:deserialize(anData)
    end
    anData = data.fallingAnimation
    if anData then
        local callback
        if anData.animationIdentifier == ANIM_VERY_SMALL_FALLING or anData.animationIdentifier == ANIM_SMALL_FALLING or
            anData.animationIdentifier == ANIM_MEDIUM_FALLING or anData.animationIdentifier == ANIM_FALLING then
            callback = self:cutDown()
        end
        self.fallingAnimation = anim.newAnimation(
            an[anData.animationIdentifier], 1, callback, anData.animationIdentifier)
        self.fallingAnimation:deserialize(anData)
    end
    self.trunkTile = tileQuads["tree_birch_trunk (1)"]
    if self.type == "Stump" then
        self.tile = self.trunkTile
        self:render()
    end
end

function BirchTree:serialize()
    local data = {}
    local treeData = Tree.serialize(self)
    for k, v in pairs(treeData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.offsetY = self.offsetY
    data.baseOffsetX = self.baseOffsetX
    data.dead = self.dead
    data.cuttable = self.cuttable
    data.health = self.health
    data.type = self.type
    data.animated = self.animated
    if self.animation then
        data.animation = self.animation:serialize()
    end
    if self.chopAnimation then
        data.chopAnimation = self.chopAnimation:serialize()
    end
    if self.fallingAnimation then
        data.fallingAnimation = self.fallingAnimation:serialize()
    end
    return data
end

function BirchTree.static:deserialize(data)
    local obj = self:allocate()
    data.needNewVertAsap = true
    Object.deserialize(obj, data)
    obj:load(data)
    return obj
end

return BirchTree
