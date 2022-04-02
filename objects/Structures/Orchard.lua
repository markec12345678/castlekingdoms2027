local _, _, _ = ...

local Structure = require("objects.Structure")
local Object = require("objects.Object")
local anim = require("libraries.anim8")

local class = _G.class

local tiles, quad_array = _G.indexBuildingQuads("farm (3)")
local tree_raw = _G.indexQuads("tree_apple", 25, nil, true)
local tree_apple = _G.indexQuads("tree_apple_apple", 25, nil, true)

local TREE_EMPTY = "Tree empty"
local TREE_APPLES = "Tree with apples"

local an = {
    [TREE_EMPTY] = tree_raw,
    [TREE_APPLES] = tree_apple
}

local Orchard_alias = class('Orchard_alias', Structure)
function Orchard_alias:initialize(tile, gx, gy, parent, offset_y, offset_x)
    local mytype = "Static structure"
    Structure.initialize(self, gx, gy, mytype)
    self.gx = gx
    self.gy = gy
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.parent = parent
    self.qid = 0
    self.tile = tile
    self.base_offset_y = offset_y or 0
    self.additional_offset_y = 0
    self.offset_x = offset_x or 0
    self.offset_y = self.additional_offset_y - self.base_offset_y
    for k, v in ipairs(_G.stockpile.node_list) do
        if v.gx == self.gx and v.gy == self.gy then
            table.remove(_G.stockpile.node_list, k)
            break
        end
    end
    Structure.render(self)
end
function Orchard_alias:serialize()
    local data = {}
    local struct_data = Structure.serialize(self)
    for k, v in pairs(struct_data) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.parent = _G.state:serializeObject(self.parent)
    data.tile_key = self.tile_key
    data.base_offset_y = self.base_offset_y
    data.additional_offset_y = self.additional_offset_y
    data.offset_x = self.offset_x
    data.offset_y = self.offset_y
    return data
end
function Orchard_alias.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    if data.tile_key then
        obj.tile = quad_array[data.tile_key]
        obj.tile_key = data.tile_key
        obj:render()
    end
    obj.parent = _G.state:dereferenceObject(data.parent)
    return obj
end

local Orchard_tree = class('Orchard_tree', Structure)
function Orchard_tree:initialize(gx, gy, parent, offset_y, offset_x)
    local mytype = "Static structure"
    Structure.initialize(self, gx, gy, mytype)
    self.animated = true
    self.anim_raw = anim.newAnimation(an[TREE_EMPTY], 0.10, nil, TREE_EMPTY)
    self.anim_full = anim.newAnimation(an[TREE_APPLES], 0.10, nil, TREE_APPLES)
    self.animation = self.anim_full
    self.gx = gx
    self.gy = gy
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.parent = parent
    self.qid = 0
    self.base_offset_y = offset_y or 0
    self.additional_offset_y = 0
    self.offset_x = offset_x or 0
    self.offset_y = self.additional_offset_y - self.base_offset_y
    for xx = -1, 1 do
        for yy = -1, 1 do
            if not ((xx == -1 and yy == -1) or (xx == 1 and yy == 1) or (xx == -1 and yy == 1) or (xx == 1 and yy == -1)) then
                local xxx = (self.gx + xx) % (_G.chunk_width)
                local yyy = (self.gy + yy) % (_G.chunk_width)
                local ccx = math.floor((self.gx + xx) / _G.chunk_width)
                local ccy = math.floor((self.gy + yy) / _G.chunk_width)
                if xx == 0 and yy == 0 then
                    _G.buildingheightmap[ccx][ccy][xxx][yyy] = 17
                else
                    _G.buildingheightmap[ccx][ccy][xxx][yyy] = 14
                end
            end
        end
    end
    for k, v in ipairs(_G.stockpile.node_list) do
        if v.gx == self.gx and v.gy == self.gy then
            table.remove(_G.stockpile.node_list, k)
            break
        end
    end
    if _G.state.chunk_objects[self.cx][self.cy] == nil then
        _G.state.chunk_objects[self.cx][self.cy] = {}
    end
    _G.state.chunk_objects[self.cx][self.cy][self] = self
end
function Orchard_tree:serialize()
    local data = {}
    local struct_data = Structure.serialize(self)
    for k, v in pairs(struct_data) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.animation = self.animation:serialize()
    data.anim_raw = self.anim_raw:serialize()
    data.anim_full = self.anim_full:serialize()
    data.base_offset_y = self.base_offset_y
    data.additional_offset_y = self.additional_offset_y
    data.offset_x = self.offset_x
    data.offset_y = self.offset_y
    data.animated = self.animated
    return data
end
function Orchard_tree.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    local an1 = data.anim_raw
    local an2 = data.anim_full
    local an3 = data.animation
    obj.anim_raw = _G.anim.newAnimation(an[an1.animation_identifier], 1, nil, an1.animation_identifier)
    obj.anim_raw:deserialize(an1)
    obj.anim_full = _G.anim.newAnimation(an[an2.animation_identifier], 1, nil, an2.animation_identifier)
    obj.anim_full:deserialize(an2)
    if an3.animation_identifier == an2.animation_identifier then
        obj.animation = obj.anim_full
    elseif an3.animation_identifier == an1.animation_identifier then
        obj.animation = obj.anim_raw
    else
        error("Unknown animation for orchard tree: " .. tostring(an3.animation_identifier))
    end
    if _G.state.chunk_objects[obj.cx][obj.cy] == nil then
        _G.state.chunk_objects[obj.cx][obj.cy] = {}
    end
    _G.state.chunk_objects[obj.cx][obj.cy][obj] = obj
    return obj
end

local Orchard = class('Orchard', Structure)
function Orchard:initialize(gx, gy, type)
    _G.JobController:add("OrchardFarmer", self)
    type = type or "Orchard"
    Structure.initialize(self, gx, gy, type)
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.health = 400
    self.qid = nil
    self.tile = quad_array[tiles + 1]
    self.working = false
    self.offset_x = 0
    self.offset_y = -48 - 6

    self.state = 0
    for xx = -1, 13 do
        for yy = -1, 13 do
            _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrain_biome.dirt)
        end
    end

    for xx = 0, 2 do
        for yy = 0, 2 do
            _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrain_biome.none)
        end
    end

    for tile = 1, tiles do
        local ora = Orchard_alias:new(quad_array[tile], self.gx, self.gy + (tiles - tile + 1), self,
            -self.offset_y + 8 * (tiles - tile + 1))
        ora.tile_key = tile
    end

    for tile = 1, tiles do
        local ora = Orchard_alias:new(quad_array[tiles + 1 + tile], self.gx + tile, self.gy, self,
            -self.offset_y + 8 * tile, 14)
        ora.tile_key = tiles + 1 + tile
    end
    local offset_x, offset_y = -64 - 8, 116
    self.tree1 = Orchard_tree:new(self.gx + 1, self.gy + 6, self, offset_y, offset_x)
    self.tree2 = Orchard_tree:new(self.gx + 1, self.gy + 11, self, offset_y, offset_x)

    self.tree3 = Orchard_tree:new(self.gx + 6, self.gy + 1, self, offset_y, offset_x)
    self.tree4 = Orchard_tree:new(self.gx + 6, self.gy + 6, self, offset_y, offset_x)
    self.tree5 = Orchard_tree:new(self.gx + 6, self.gy + 11, self, offset_y, offset_x)

    self.tree6 = Orchard_tree:new(self.gx + 11, self.gy + 1, self, offset_y, offset_x)
    self.tree7 = Orchard_tree:new(self.gx + 11, self.gy + 6, self, offset_y, offset_x)
    self.tree8 = Orchard_tree:new(self.gx + 11, self.gy + 11, self, offset_y, offset_x)

    for xx = 0, 2 do
        for yy = 0, 2 do
            local xxx = (self.gx + xx) % (_G.chunk_width)
            local yyy = (self.gy + yy) % (_G.chunk_width)
            local ccx = math.floor((self.gx + xx) / _G.chunk_width)
            local ccy = math.floor((self.gy + yy) / _G.chunk_width)
            _G.buildingheightmap[ccx][ccy][xxx][yyy] = 15
        end
    end

    self.free_spots = 1
    Structure.render(self)
end
function Orchard:serialize()
    local data = {}
    local struct_data = Structure.serialize(self)
    for k, v in pairs(struct_data) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.health = self.health
    data.working = self.working
    data.offset_x = self.offset_x
    data.offset_y = self.offset_y
    data.state = self.state
    data.working = self.working
    data.free_spots = self.free_spots
    if self.apple_worker then
        data.apple_worker = _G.state:serializeObject(self.apple_worker)
    end
    data.tree1 = _G.state:serializeObject(self.tree1)
    data.tree2 = _G.state:serializeObject(self.tree2)

    data.tree3 = _G.state:serializeObject(self.tree3)
    data.tree4 = _G.state:serializeObject(self.tree4)
    data.tree5 = _G.state:serializeObject(self.tree5)

    data.tree6 = _G.state:serializeObject(self.tree6)
    data.tree7 = _G.state:serializeObject(self.tree7)
    data.tree8 = _G.state:serializeObject(self.tree8)
    return data
end
function Orchard.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    obj.tile = quad_array[tiles + 1]
    if data.apple_worker then
        obj.apple_worker = _G.state:dereferenceObject(data.apple_worker)
        obj.apple_worker.workplace = obj
    end
    obj.tree1 = _G.state:dereferenceObject(data.tree1)
    obj.tree1.parent = self
    obj.tree2 = _G.state:dereferenceObject(data.tree2)
    obj.tree2.parent = self
    obj.tree3 = _G.state:dereferenceObject(data.tree3)
    obj.tree3.parent = self
    obj.tree4 = _G.state:dereferenceObject(data.tree4)
    obj.tree4.parent = self
    obj.tree5 = _G.state:dereferenceObject(data.tree5)
    obj.tree5.parent = self
    obj.tree6 = _G.state:dereferenceObject(data.tree6)
    obj.tree6.parent = self
    obj.tree7 = _G.state:dereferenceObject(data.tree7)
    obj.tree7.parent = self
    obj.tree8 = _G.state:dereferenceObject(data.tree8)
    obj.tree8.parent = self
    Structure.render(obj)
    return obj
end
function Orchard:join(worker)
    if self.free_spots == 1 then
        self.apple_worker = worker
        worker.workplace = self
        self.free_spots = self.free_spots - 1
    end
end
function Orchard:work(worker)
    if self.apple_worker == worker then
        self.apple_worker.state = "Working"
        if self.state == 0 then
            self.tree1.animation = self.tree1.anim_full
            self.tree2.animation = self.tree2.anim_full
            self.tree3.animation = self.tree3.anim_full
            self.tree4.animation = self.tree4.anim_full
            self.tree5.animation = self.tree5.anim_full
            self.tree6.animation = self.tree6.anim_full
            self.tree7.animation = self.tree7.anim_full
            self.tree8.animation = self.tree8.anim_full
            self.apple_worker:requestPath(self.gx + 1, self.gy + 7)
            self.apple_worker.state = "Going to apple tree"
            self.apple_worker.move_dir = "none"
            self.state = 1
        elseif self.state == 1 then
            self.tree1.animation = self.tree1.anim_raw
            self.apple_worker:requestPath(self.gx + 1, self.gy + 12)
            self.apple_worker.state = "Going to apple tree"
            self.apple_worker.move_dir = "none"
            self.state = 2
        elseif self.state == 2 then
            self.tree2.animation = self.tree2.anim_raw
            self.apple_worker:requestPath(self.gx + 6, self.gy + 12)
            self.apple_worker.state = "Going to apple tree"
            self.apple_worker.move_dir = "none"
            self.state = 3
        elseif self.state == 3 then
            self.tree5.animation = self.tree5.anim_raw
            self.apple_worker:requestPath(self.gx + 6, self.gy + 7)
            self.apple_worker.state = "Going to apple tree"
            self.apple_worker.move_dir = "none"
            self.state = 4
        elseif self.state == 4 then
            self.tree4.animation = self.tree4.anim_raw
            self.apple_worker:requestPath(self.gx + 6, self.gy + 2)
            self.apple_worker.state = "Going to apple tree"
            self.apple_worker.move_dir = "none"
            self.state = 5
        elseif self.state == 5 then
            self.tree3.animation = self.tree3.anim_raw
            self.apple_worker:requestPath(self.gx + 11, self.gy + 2)
            self.apple_worker.state = "Going to apple tree"
            self.apple_worker.move_dir = "none"
            self.state = 6
        elseif self.state == 6 then
            self.tree6.animation = self.tree6.anim_raw
            self.apple_worker:requestPath(self.gx + 11, self.gy + 7)
            self.apple_worker.state = "Going to apple tree"
            self.apple_worker.move_dir = "none"
            self.state = 7
        elseif self.state == 7 then
            self.tree7.animation = self.tree7.anim_raw
            self.apple_worker:requestPath(self.gx + 11, self.gy + 12)
            self.apple_worker.state = "Going to apple tree"
            self.apple_worker.move_dir = "none"
            self.state = 8
        elseif self.state == 8 then
            self.tree8.animation = self.tree8.anim_raw
            self:send_to_stockpile()
            self.state = 0
        end

    end
end
function Orchard:send_to_stockpile()
    self.apple_worker.state = "Go to foodpile"
    self.apple_worker.move_dir = "none"
    self.working = false
end

return Orchard
