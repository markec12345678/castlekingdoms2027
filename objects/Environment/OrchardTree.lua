local Structure = require("objects.Structure")
local Object = require("objects.Object")
local anim = require("libraries.anim8")

local class = _G.class

local treeRaw = _G.indexQuads("tree_apple", 25, nil, true)
local treeApple = _G.indexQuads("tree_apple_apple", 25, nil, true)

local TREE_EMPTY = "Tree empty"
local TREE_APPLES = "Tree with apples"

local an = {
    [TREE_EMPTY] = treeRaw,
    [TREE_APPLES] = treeApple
}

local OrchardTree = class("OrchardTree", Structure)
function OrchardTree:initialize(gx, gy, parent, offsetY, offsetX)
    local mytype = "Static structure"
    Structure.initialize(self, gx, gy, mytype)
    self:usePallete(math.random(1, 10))
    self.parent = parent
    self.animated = true
    self.animRaw = anim.newAnimation(an[TREE_EMPTY], 0.10, nil, TREE_EMPTY)
    self.animFull = anim.newAnimation(an[TREE_APPLES], 0.10, nil, TREE_APPLES)
    self.animation = self.animFull
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.baseOffsetY = offsetY or 0
    self.additionalOffsetY = 0
    self.offsetX = offsetX or 0
    self.offsetY = self.additionalOffsetY - self.baseOffsetY
    for xx = -1, 1 do
        for yy = -1, 1 do
            if not ((xx == -1 and yy == -1) or (xx == 1 and yy == 1) or (xx == -1 and yy == 1) or (xx == 1 and yy == -1)) then
                local ccx, ccy, xxx, yyy = _G.getLocalCoordinatesFromGlobal(self.gx + xx, self.gy + yy)
                if xx == 0 and yy == 0 then
                    _G.state.map.buildingheightmap[ccx][ccy][xxx][yyy] = 17
                else
                    _G.state.map.buildingheightmap[ccx][ccy][xxx][yyy] = 14
                end
            end
        end
    end
    if _G.state.chunkObjects[self.cx][self.cy] == nil then
        _G.state.chunkObjects[self.cx][self.cy] = {}
    end
    _G.state.chunkObjects[self.cx][self.cy][self] = self
    self:shadeFromTerrainSingleTile()
end

function OrchardTree:serialize()
    local data = {}
    local structData = Structure.serialize(self)
    for k, v in pairs(structData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.animation = self.animation:serialize()
    data.animRaw = self.animRaw:serialize()
    data.animFull = self.animFull:serialize()
    data.baseOffsetY = self.baseOffsetY
    data.additionalOffsetY = self.additionalOffsetY
    data.offsetX = self.offsetX
    data.offsetY = self.offsetY
    data.animated = self.animated
    return data
end

function OrchardTree.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    local an1 = data.animRaw
    local an2 = data.animFull
    local an3 = data.animation
    obj.animRaw = _G.anim.newAnimation(an[an1.animationIdentifier], 1, nil, an1.animationIdentifier)
    obj.animRaw:deserialize(an1)
    obj.animFull = _G.anim.newAnimation(an[an2.animationIdentifier], 1, nil, an2.animationIdentifier)
    obj.animFull:deserialize(an2)
    if an3.animationIdentifier == an2.animationIdentifier then
        obj.animation = obj.animFull
    elseif an3.animationIdentifier == an1.animationIdentifier then
        obj.animation = obj.animRaw
    else
        error("Unknown animation for orchard tree: " .. tostring(an3.animationIdentifier))
    end
    if _G.state.chunkObjects[obj.cx][obj.cy] == nil then
        _G.state.chunkObjects[obj.cx][obj.cy] = {}
    end
    _G.state.chunkObjects[obj.cx][obj.cy][obj] = obj
    return obj
end

return OrchardTree
