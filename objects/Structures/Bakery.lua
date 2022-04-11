local active_entities, _, tile_quads, _ = ...

local Structure = require("objects.Structure")
local Object = require("objects.Object")
local anim = require("libraries.anim8")

local tiles, quad_array = _G.indexBuildingQuads("bakery_workshop (18)", true)

local ANIM_BAKING_BREAD = "Baking_Bread"
local ANIM_BAKING_BREAD_PART2 = "Baking_Bread_Part2"
local ANIM_BREAD_STACK = "Bread_Stack"

local an = {
    [ANIM_BAKING_BREAD] = _G.indexQuads("anim_baker", 53),
    [ANIM_BAKING_BREAD_PART2] = _G.indexQuads("anim_baker", 64, 54),
    [ANIM_BREAD_STACK] = _G.indexQuads("anim_baker_bread", 4)
}

local Bakery_bread_stack = _G.class('Bakery_bread_stack', Structure)
function Bakery_bread_stack:initialize(gx, gy, parent)
    Structure.initialize(self, gx, gy, "Bakery bread stack")
    self.tile = tile_quads["empty"]
    self.animated = false
    self.animation = anim.newAnimation(an[ANIM_BREAD_STACK], 0.11, nil, ANIM_BREAD_STACK)
    self.animation:pause()
    self.quantity = 0
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.parent = parent
    self.offset_x = -24
    self.offset_y = -94

    table.insert(active_entities, self)
end
function Bakery_bread_stack:serialize()
    local data = {}
    local struct_data = Structure.serialize(self)
    for k, v in pairs(struct_data) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.animation = self.animation:serialize()
    data.animated = self.animated
    data.offset_x = self.offset_x
    data.offset_y = self.offset_y
    data.quantity = self.quantity
    data.parent = _G.state:serializeObject(self.parent)
    return data
end
function Bakery_bread_stack.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    obj.parent = _G.state:dereferenceObject(data.parent)
    obj.parent.stack = obj
    local an_data = data.animation
    obj.animation = _G.anim.newAnimation(an[an_data.animation_identifier], 1, nil, an_data.animation_identifier)
    obj.animation:deserialize(an_data)
    table.insert(active_entities, obj)
    return obj
end
function Bakery_bread_stack:stack()
    self.quantity = self.quantity + 1
    self.animation:gotoFrame(self.quantity)
    self:animate(_G.dt, true)
end
function Bakery_bread_stack:animate(dt)
    Structure.animate(self, dt, true)
end
function Bakery_bread_stack:activate()
    self.animated = true
    self.quantity = 1
    self.animation:gotoFrame(1)
    self.animation:pause()
    self:animate()
end
function Bakery_bread_stack:deactivate()
    self.animation:pause()
    self.quantity = 0
    self.tile = tile_quads["empty"]
    if self.instancemesh then
        _G.freeVertexFromTile(self.cx, self.cy, self.vert_id)
        self.instancemesh = nil
    end
    self.animated = false
end
function Bakery_bread_stack:take()
    self.quantity = self.quantity - 4
    if self.quantity == 0 then
        self:deactivate()
        self.parent.unloading = false
        return
    end
    self.animation:gotoFrame(self.quantity)
end

local Bakery_cooking = _G.class('Bakery_cooking', Structure)
function Bakery_cooking:initialize(gx, gy, parent)
    Structure.initialize(self, gx, gy, "Bakery cooking")
    self.tile = tile_quads["empty"]
    self.animated = false
    self.animation = anim.newAnimation(an[ANIM_BAKING_BREAD], 0.11, self:bake_callback_1(), ANIM_BAKING_BREAD)
    self.animation:pause()
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.parent = parent
    self.offset_x = -36
    self.offset_y = -88

    table.insert(active_entities, self)
end
function Bakery_cooking:serialize()
    local data = {}
    local struct_data = Structure.serialize(self)
    for k, v in pairs(struct_data) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.animation = self.animation:serialize()
    data.animated = self.animated
    data.offset_x = self.offset_x
    data.offset_y = self.offset_y
    data.parent = _G.state:serializeObject(self.parent)
    return data
end
function Bakery_cooking.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    obj.parent = _G.state:dereferenceObject(data.parent)
    obj.parent.cooking_obj = obj
    local callback
    local an_data = data.animation
    if an_data.animation_identifier == ANIM_BAKING_BREAD then
        callback = obj:bake_callback_1()
    elseif an_data.animation_identifier == ANIM_BAKING_BREAD_PART2 then
        callback = obj:bake_callback_2()
    end
    obj.animation = _G.anim.newAnimation(an[an_data.animation_identifier], 1, callback, an_data.animation_identifier)
    obj.animation:deserialize(an_data)
    table.insert(active_entities, obj)
    return obj
end
function Bakery_cooking:bake_callback_1()
    return function()
        if not self.parent.stack.animated then
            self.parent.stack:activate()
        else
            self.parent.stack:stack()
        end
        self.animation = anim.newAnimation(an[ANIM_BAKING_BREAD_PART2], 0.11, self:bake_callback_2(),
            ANIM_BAKING_BREAD_PART2)
    end
end
function Bakery_cooking:bake_callback_2()
    return function()
        self.animation = anim.newAnimation(an[ANIM_BAKING_BREAD], 0.11, self:bake_callback_1(), ANIM_BAKING_BREAD)
        if self.parent.stack.quantity == 4 then
            self.parent:send_to_stockpile()
            self:deactivate()
        end
    end
end
function Bakery_cooking:animate()
    Structure.animate(self, _G.dt, true)
end
function Bakery_cooking:activate()
    self.animated = true
    self.animation:gotoFrame(1)
    self.animation:resume()
    self:animate(_G.dt)
end
function Bakery_cooking:deactivate()
    self.animation:pause()
    self.tile = tile_quads["empty"]
    if self.instancemesh then
        _G.freeVertexFromTile(self.cx, self.cy, self.vert_id)
        self.instancemesh = nil
    end
    self.animated = false
end

local Bakery_alias = _G.class('Bakery_alias', Structure)
function Bakery_alias:initialize(tile, gx, gy, parent, offset_y, offset_x)
    local mytype = "Static structure"
    Structure.initialize(self, gx, gy, mytype)
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.parent = parent
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
function Bakery_alias:serialize()
    local data = {}
    local struct_data = Structure.serialize(self)
    for k, v in pairs(struct_data) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.tile_key = self.tile_key
    data.base_offset_y = self.base_offset_y
    data.additional_offset_y = self.additional_offset_y
    data.offset_x = self.offset_x
    data.offset_y = self.offset_y
    data.parent = _G.state:serializeObject(self.parent)
    return data
end
function Bakery_alias.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    obj.parent = _G.state:dereferenceObject(data.parent)
    if data.tile_key then
        obj.tile = quad_array[data.tile_key]
        obj.tile_key = data.tile_key
        obj:render()
    end
    return obj
end

local Bakery = _G.class('Bakery', Structure)
function Bakery:initialize(gx, gy)
    _G.JobController:add("Baker", self)
    Structure.initialize(self, gx, gy, "Bakery")
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.health = 400
    self.tile = quad_array[tiles + 1]
    self.working = false
    self.unloading = false
    self.offset_x = 0
    self.offset_y = 64 - 131
    self.free_spots = 1
    self.worker = nil
    self.cooking_obj = Bakery_cooking:new(self.gx + 3, self.gy + 2, self)
    self.stack = Bakery_bread_stack:new(self.gx + 3, self.gy + 3, self)

    for xx = -2, 5 do
        for yy = -2, 5 do
            _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrain_biome.dirt, _G.terrain_biome.abundant_grass)
        end
    end
    for xx = -1, 4 do
        for yy = -1, 4 do
            _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrain_biome.scarce_grass)
        end
    end
    for xx = 0, 3 do
        for yy = 0, 3 do
            _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrain_biome.none)
            local ccx, ccy, xxx, yyy = _G.getLocalCoordinatesFromGlobal(self.gx + xx, self.gy + yy)
            _G.buildingheightmap[ccx][ccy][xxx][yyy] = 17
        end
    end
    for tile = 1, tiles do
        local bkr = Bakery_alias:new(quad_array[tile], self.gx, self.gy + (tiles - tile + 1), self,
            -self.offset_y + 8 * (tiles - tile + 1))
        bkr.tile_key = tile
    end
    for tile = 1, tiles do
        local bkr = Bakery_alias:new(quad_array[tiles + 1 + tile], self.gx + tile, self.gy, self,
            -self.offset_y + 8 * tile, 16)
        bkr.tile_key = tiles + 1 + tile
    end

    Structure.render(self)
end
function Bakery:load(data)
    Object.deserialize(self, data)
    Structure.load(self, data)
    if data.worker then
        self.worker = _G.state:dereferenceObject(data.worker)
        self.worker.workplace = self
    end
    self.tile = quad_array[tiles + 1]
    Structure.render(self)
end
function Bakery:serialize()
    local data = {}
    local struct_data = Structure.serialize(self)
    for k, v in pairs(struct_data) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.health = self.health
    data.working = self.working
    data.unloading = self.unloading
    data.offset_x = self.offset_x
    data.offset_y = self.offset_y
    data.free_spots = self.free_spots
    if self.worker then
        data.worker = _G.state:serializeObject(self.worker)
    end
    return data
end
function Bakery.static:deserialize(data)
    local obj = self:allocate()
    obj:load(data)
    return obj
end
function Bakery:join(worker)
    if self.free_spots == 1 then
        self.worker = worker
        self.worker.workplace = self
        self.free_spots = self.free_spots - 1
    end
end
function Bakery:work(worker)
    if self.worker.state == "Going to workplace with flour" then
        self.worker.state = "Working"
        self.working = true
        worker.tile = tile_quads["empty"]
        worker.animated = false
        worker.gx = self.gx + 1
        worker.gy = self.gy + 2
        worker:job_update()
        self.cooking_obj:activate()
    else
        self.worker.state = "Working"
        if not self.working and self.worker.state == "Working" then
            self.worker.state = "Go to stockpile for flour"
        end
    end
end
function Bakery:send_to_stockpile()
    local i, o, cx, cy
    self.worker.state = "Go to granary"
    self.worker.animated = true
    self.worker.gx = self.gx + 1
    self.worker.gy = self.gy + 4
    self.worker.fx = self.worker.gx * 1000 + 500
    self.worker.fy = self.worker.gy * 1000 + 500
    i = (self.worker.gx) % (_G.chunk_width)
    o = (self.worker.gy) % (_G.chunk_width)
    cx = math.floor(self.worker.gx / _G.chunk_width)
    cy = math.floor(self.worker.gy / _G.chunk_width)
    _G.addObjectAt(cx, cy, i, o, self.worker)
    self.working = false
    self.worker.need_new_vert_asap = true
    self.cooking_obj:deactivate()
    self.stack:take()
end

return Bakery
