local active_entities, _, tile_quads, _ = ...

local Structure = require("objects.Structure")
local Object = require("objects.Object")
local anim = require("libraries.anim8")
local tiles, quad_array = _G.indexBuildingQuads("stone_quarry")

local fr_lifter_part1 = _G.indexQuads("anim_quarry_lower", 17)
local fr_lifter_part2 = _G.indexQuads("anim_quarry_lower", 20 + 18, 18)
local fr_lifter_part3 = _G.indexQuads("anim_quarry_lower", 31 + 18 + 20, 18 + 20)
local fr_hook_part1 = _G.indexQuads("anim_quarry_hook", 47)
table.insert(fr_hook_part1, 1, tile_quads["anim_quarry_hook_empty (1)"])
local fr_hook_part2 = _G.indexQuads("anim_quarry_hook", 17 + 45, 48)
local fr_shaper = _G.indexQuads("anim_quarry_cut", 131)

table.remove(fr_shaper, 2)
table.remove(fr_shaper, 2)
table.remove(fr_shaper, 2)
table.remove(fr_shaper, 2)
table.remove(fr_shaper, 2)

local fr_puller_part2 = _G.indexQuads("anim_quarry_pull", 42 + 20, 20)
local fr_puller_part1 = _G.indexQuads("anim_quarry_pull", 19)

local ANIM_LIFTER_PART1 = "lifter_part1"
local ANIM_LIFTER_PART2 = "lifter_part2"
local ANIM_LIFTER_PART3 = "lifter_part3"
local ANIM_LIFTER_PART4 = "lifter_part4"
local ANIM_HOOK_PART1 = "hook_part1"
local ANIM_HOOK_PART2 = "hook_part2"
local ANIM_SHAPER = "shaper"
local ANIM_PULLER_PART1 = "puller_part1"
local ANIM_PULLER_PART2 = "puller_part1"

local an = {
    [ANIM_LIFTER_PART1] = fr_lifter_part1,
    [ANIM_LIFTER_PART2] = fr_lifter_part2,
    [ANIM_LIFTER_PART3] = fr_lifter_part3,
    [ANIM_LIFTER_PART4] = fr_lifter_part1,
    [ANIM_HOOK_PART1] = fr_hook_part1,
    [ANIM_HOOK_PART2] = fr_hook_part2,
    [ANIM_SHAPER] = fr_shaper,
    [ANIM_PULLER_PART1] = fr_puller_part1,
    [ANIM_PULLER_PART2] = fr_puller_part2
}

local Quarry_lifter = _G.class('Quarry_lifter', Structure)
function Quarry_lifter:initialize(gx, gy, parent)
    local mytype = "Lifter"
    Structure.initialize(self, gx, gy, mytype)
    self.animated = true
    self.animation = anim.newAnimation(an[ANIM_LIFTER_PART1], 0.10, self:lifter_callback_1(), ANIM_LIFTER_PART1)
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.parent = parent
    self.offset_x = -2
    self.offset_y = -93
    table.insert(active_entities, self)
end
function Quarry_lifter:serialize()
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
function Quarry_lifter.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    obj.parent = _G.state:dereferenceObject(data.parent)
    obj.parent.lifter = obj
    local callback
    local an_data = data.animation
    if an_data.animation_identifier == ANIM_LIFTER_PART1 then
        callback = obj:lifter_callback_1()
    elseif an_data.animation_identifier == ANIM_LIFTER_PART2 then
        callback = obj:lifter_callback_2()
    elseif an_data.animation_identifier == ANIM_LIFTER_PART3 then
        callback = obj:lifter_callback_3()
    elseif an_data.animation_identifier == ANIM_LIFTER_PART4 then
        callback = obj:lifter_callback_4()
    end
    obj.animation = _G.anim.newAnimation(an[an_data.animation_identifier], 1, callback, an_data.animation_identifier)
    obj.animation:deserialize(an_data)
    table.insert(active_entities, obj)
    return obj
end
function Quarry_lifter:lifter_callback_1()
    return function()
        self.parent.puller:activate()
        self.parent.hook:activate()
        self.animation = anim.newAnimation(an[ANIM_LIFTER_PART2], 0.10, self:lifter_callback_2(), ANIM_LIFTER_PART2)
    end
end
function Quarry_lifter:lifter_callback_2()
    return function()
        self.animation = anim.newAnimation(an[ANIM_LIFTER_PART3], 0.10, self:lifter_callback_3(), ANIM_LIFTER_PART3)
    end
end
function Quarry_lifter:lifter_callback_3()
    return function()
        self.animation = anim.newAnimation(an[ANIM_LIFTER_PART4], 0.10, self:lifter_callback_4(), ANIM_LIFTER_PART4)
        self.animation:pause()
    end
end
function Quarry_lifter:lifter_callback_4()
    return function()
        self.animation:gotoFrame(1)
    end
end
function Quarry_lifter:animate(dt)
    Structure.animate(self, dt, true)
end
function Quarry_lifter:start()
    self.animated = true
    self.animation = anim.newAnimation(an[ANIM_LIFTER_PART1], 0.11, self:lifter_callback_1(), ANIM_LIFTER_PART1)
    self.animation:pause()
    self:animate()
end
function Quarry_lifter:activate()
    self.animated = true
    self.animation = anim.newAnimation(an[ANIM_LIFTER_PART1], 0.11, self:lifter_callback_1(), ANIM_LIFTER_PART1)
    self:animate()
end
function Quarry_lifter:deactivate()
    self.animation:pause()
    self.tile = tile_quads["empty"]
    if self.instancemesh then
        _G.freeVertexFromTile(self.cx, self.cy, self.vert_id)
        self.instancemesh = nil
    end
    self.animated = false
end

local Quarry_hook = _G.class('Quarry_hook', Structure)
function Quarry_hook:initialize(gx, gy, parent)
    local mytype = "Hook"
    Structure.initialize(self, gx, gy, mytype)
    self.animated = true
    self.animation = anim.newAnimation(an[ANIM_HOOK_PART1], 0.11, self:hook_callback_1(), ANIM_HOOK_PART1)
    self.animation:pause()
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.parent = parent
    self.offset_x = -2
    self.offset_y = -116
    table.insert(active_entities, self)
end
function Quarry_hook:hook_callback_1()
    return function()
        self.parent.shaper:activate()
        self.animation = anim.newAnimation(an[ANIM_HOOK_PART2], 0.12, self:hook_callback_2(), ANIM_HOOK_PART2)
    end
end
function Quarry_hook:hook_callback_2()
    return function()
        self.animation = anim.newAnimation(an[ANIM_HOOK_PART1], 0.11, self:hook_callback_1(), ANIM_HOOK_PART1)
        self.animation:pause()
    end
end
function Quarry_hook:animate(dt)
    Structure.animate(self, dt, true)
end
function Quarry_hook:activate()
    self.animated = true
    self.animation:gotoFrame(2)
    self.animation:resume()
    self:animate()
end
function Quarry_hook:serialize()
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
function Quarry_hook.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    obj.parent = _G.state:dereferenceObject(data.parent)
    obj.parent.hook = obj
    local callback
    local an_data = data.animation
    if an_data.animation_identifier == ANIM_HOOK_PART1 then
        callback = obj:hook_callback_1()
    elseif an_data.animation_identifier == ANIM_HOOK_PART2 then
        callback = obj:hook_callback_2()
    end
    obj.animation = _G.anim.newAnimation(an[an_data.animation_identifier], 1, callback, an_data.animation_identifier)
    obj.animation:deserialize(an_data)
    table.insert(active_entities, obj)
    return obj
end

local Quarry_shaper = _G.class('Quarry_shaper', Structure)
function Quarry_shaper:initialize(gx, gy, parent)
    local mytype = "Shaper"
    Structure.initialize(self, gx, gy, mytype)
    self.animated = true
    self.animation = anim.newAnimation(an[ANIM_SHAPER], 0.05, self:shaper_callback(), ANIM_SHAPER)
    self.animation:pause()
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.parent = parent
    self.offset_x = -31
    self.offset_y = -79
    table.insert(active_entities, self)
end
function Quarry_shaper:shaper_callback()
    return function()
        self.parent.lifter:activate()
        self.animation:gotoFrame(1)
        self.animation:pause()
        self.parent.stone_quantity = self.parent.stone_quantity + 1
        if self.parent.stone_quantity == 3 then
            self.parent:send_to_stockpile()
        end
    end
end
function Quarry_shaper:animate(dt)
    Structure.animate(self, dt, true)
end
function Quarry_shaper:start()
    self.animated = true
    self.animation:pause()
    self:animate()
end
function Quarry_shaper:activate()
    self.animated = true
    self.animation:resume()
    self:animate()
end
function Quarry_shaper:deactivate()
    self.animation:pause()
    self.tile = tile_quads["empty"]
    if self.instancemesh then
        _G.freeVertexFromTile(self.cx, self.cy, self.vert_id)
        self.instancemesh = nil
    end
    self.animated = false
end
function Quarry_shaper:serialize()
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
function Quarry_shaper.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    obj.parent = _G.state:dereferenceObject(data.parent)
    obj.parent.shaper = obj
    local callback
    local an_data = data.animation
    if an_data.animation_identifier == ANIM_SHAPER then
        callback = obj:shaper_callback()
    end
    obj.animation = _G.anim.newAnimation(an[an_data.animation_identifier], 1, callback, an_data.animation_identifier)
    obj.animation:deserialize(an_data)
    table.insert(active_entities, obj)
    return obj
end

local Quarry_puller = _G.class('Quarry_puller', Structure)
function Quarry_puller:initialize(gx, gy, parent, offset_x, offset_y)
    local mytype = "Puller"
    Structure.initialize(self, gx, gy, mytype)
    self.animated = true
    self.animation = anim.newAnimation(an[ANIM_PULLER_PART1], 0.11, self:puller_callback_1(), ANIM_PULLER_PART1)
    self.animation:pause()
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.parent = parent
    self.offset_x = 92 + offset_x - 16 - 16
    self.offset_y = 58 + offset_y - 32 - 16
    table.insert(active_entities, self)
end
function Quarry_puller:puller_callback_1()
    return function()
        self.animation = anim.newAnimation(an[ANIM_PULLER_PART2], 0.11, self:puller_callback_2(), ANIM_PULLER_PART2)
    end
end
function Quarry_puller:puller_callback_2()
    return function()
        self.animation = anim.newAnimation(an[ANIM_PULLER_PART1], 0.11, self:puller_callback_1(), ANIM_PULLER_PART1)
        self.animation:gotoFrame(1)
        self.animation:pause()
    end
end
function Quarry_puller:animate(dt)
    Structure.animate(self, dt, true)
end
function Quarry_puller:start()
    self.animated = true
    self.animation:pause()
    self:animate()
end
function Quarry_puller:activate()
    self.animated = true
    self.animation:resume()
    self:animate()
end
function Quarry_puller:deactivate()
    self.animation:pause()
    self.quantity = 0
    self.tile = tile_quads["empty"]
    if self.instancemesh then
        _G.freeVertexFromTile(self.cx, self.cy, self.vert_id)
        self.instancemesh = nil
    end
    self.animated = false
end
function Quarry_puller:serialize()
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
function Quarry_puller.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    obj.parent = _G.state:dereferenceObject(data.parent)
    obj.parent.puller = obj
    local callback
    local an_data = data.animation
    if an_data.animation_identifier == ANIM_PULLER_PART1 then
        callback = obj:puller_callback_1()
    elseif an_data.animation_identifier == ANIM_PULLER_PART2 then
        callback = obj:puller_callback_2()
    end
    obj.animation = _G.anim.newAnimation(an[an_data.animation_identifier], 1, callback, an_data.animation_identifier)
    obj.animation:deserialize(an_data)
    table.insert(active_entities, obj)
    return obj
end

local Quarry_alias = _G.class('Quarry_alias', Structure)
function Quarry_alias:initialize(tile, gx, gy, parent, offset_y, offset_x)
    Structure.initialize(self, gx, gy, "Quarry alias")
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
function Quarry_alias:serialize()
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
function Quarry_alias.static:deserialize(data)
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

local Quarry = _G.class('Quarry', Structure)
function Quarry:initialize(gx, gy)
    _G.JobController:add("Stonemason", self)
    Structure.initialize(self, gx, gy, "Quarry")
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.health = 400
    self.tile = quad_array[tiles + 1]
    self.stone_quantity = 0
    self.working = false
    self.offset_x = 0
    self.offset_y = -7 * 16 - 6
    self.free_spots = 3
    self.lift_worker = nil
    self.pull_worker = nil
    self.shape_worker = nil
    self.lifter = Quarry_lifter:new(self.gx + 3, self.gy + 5, self, self.offset_x - 64 - 16)
    self.lifter:deactivate()
    self.shaper = Quarry_shaper:new(self.gx + 1, self.gy + 5, self, self.offset_x - 64 - 16, self.offset_y)
    self.shaper:deactivate()
    self.puller = Quarry_puller:new(self.gx + 4, self.gy + 2, self, self.offset_x - 64 - 16, self.offset_y)
    self.puller:deactivate()
    self.hook = Quarry_hook:new(self.gx + 2, self.gy + 5, self, self.offset_x - 64 - 16)

    for xx = 0, 5 do
        for yy = 0, 5 do
            _G.removeObjectFromClassAtGlobal(self.gx + xx, self.gy + yy, "Stone")
        end
    end
    for xx = 0, 5 do
        for yy = 0, 5 do
            _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrain_biome.none)
        end
    end

    for tile = 1, tiles do
        local qur = Quarry_alias:new(quad_array[tile], self.gx, self.gy + (tiles - tile + 1), self,
            -self.offset_y + 8 * (tiles - tile + 1))
        qur.tile_key = tile
    end

    for tile = 1, tiles do
        local qur = Quarry_alias:new(quad_array[tiles + 1 + tile], self.gx + tile, self.gy, self,
            -self.offset_y + 8 * tile, 14)
        qur.tile_key = tiles + 1 + tile
    end

    Quarry_alias:new(tile_quads["empty"], self.gx + 5, self.gy + 1, self, 12 + 8 * 4, 16)
    Quarry_alias:new(tile_quads["empty"], self.gx + 5, self.gy + 2, self, 12 + 8 * 4, 16)
    Quarry_alias:new(tile_quads["empty"], self.gx + 5, self.gy + 3, self, 12 + 8 * 4, 16)
    Quarry_alias:new(tile_quads["empty"], self.gx + 5, self.gy + 4, self, 12 + 8 * 4, 16)
    Quarry_alias:new(tile_quads["empty"], self.gx + 5, self.gy + 5, self, 12 + 8 * 4, 16)
    Quarry_alias:new(tile_quads["empty"], self.gx + 1, self.gy + 5, self, 12 + 8 * 4, 16)
    Quarry_alias:new(tile_quads["empty"], self.gx + 2, self.gy + 5, self, 12 + 8 * 4, 16)
    Quarry_alias:new(tile_quads["empty"], self.gx + 3, self.gy + 5, self, 12 + 8 * 4, 16)
    Quarry_alias:new(tile_quads["empty"], self.gx + 4, self.gy + 5, self, 12 + 8 * 4, 16)

    Structure.render(self)
end
function Quarry:join(worker)
    if self.free_spots == 3 then
        self.lift_worker = worker
        worker.workplace = self
        self.free_spots = self.free_spots - 1
    elseif self.free_spots == 2 then
        self.pull_worker = worker
        worker.workplace = self
        self.free_spots = self.free_spots - 1
    elseif self.free_spots == 1 then
        self.shape_worker = worker
        worker.workplace = self
        self.free_spots = self.free_spots - 1
    end
end
function Quarry:work(worker)
    if self.lift_worker == worker then
        worker.state = "Working"
        worker.tile = tile_quads["empty"]
        worker.animated = false
        worker.gx = self.gx + 3
        worker.gy = self.gy + 2
        worker:job_update()
        self.lifter:start()
    elseif self.pull_worker == worker then
        worker.state = "Working"
        worker.tile = tile_quads["empty"]
        worker.animated = false
        worker.gx = self.gx + 4
        worker.gy = self.gy + 3
        worker:job_update()
        self.puller:start()
        self.puller.tile = tile_quads["anim_quarry_pull (1)"]
    elseif self.shape_worker == worker then
        worker.state = "Working"
        worker.tile = tile_quads["empty"]
        worker.animated = false
        worker.gx = self.gx + 3
        worker.gy = self.gy + 4
        self.shaper:start()
        worker:job_update()
        self.shaper.tile = tile_quads["anim_quarry_cut (1)"]
    end
    if self.shape_worker and self.shape_worker.state == "Working" and not self.working and self.lift_worker.state ==
        "Working" and self.pull_worker.state == "Working" then
        self.working = true
        self.lifter:activate()
    end
end
function Quarry:send_to_stockpile()
    self.stone_quantity = 0
    local i, o, cx, cy
    self.lift_worker.state = "Go to stockpile"
    self.lift_worker.animated = true
    self.lift_worker.gx = self.gx + 6
    self.lift_worker.gy = self.gy + 2
    self.lift_worker.fx = (self.gx + 6) * 1000 + 500
    self.lift_worker.fy = (self.gy + 2) * 1000 + 500
    i = (self.lift_worker.gx) % (_G.chunk_width)
    o = (self.lift_worker.gy) % (_G.chunk_width)
    cx = math.floor(self.lift_worker.gx / _G.chunk_width)
    cy = math.floor(self.lift_worker.gy / _G.chunk_width)
    _G.addObjectAt(cx, cy, i, o, self.lift_worker)

    self.pull_worker.state = "Go to stockpile"
    self.pull_worker.animated = true
    self.pull_worker.gx = self.gx + 5
    self.pull_worker.gy = self.gy - 1
    self.pull_worker.fx = (self.gx + 5) * 1000 + 500
    self.pull_worker.fy = (self.gy - 1) * 1000 + 500
    i = (self.pull_worker.gx) % (_G.chunk_width)
    o = (self.pull_worker.gy) % (_G.chunk_width)
    cx = math.floor(self.pull_worker.gx / _G.chunk_width)
    cy = math.floor(self.pull_worker.gy / _G.chunk_width)
    _G.addObjectAt(cx, cy, i, o, self.pull_worker)

    self.shape_worker.state = "Go to stockpile"
    self.shape_worker.animated = true
    self.shape_worker.gx = self.gx + 1
    self.shape_worker.gy = self.gy + 6
    self.shape_worker.fx = (self.gx + 1) * 1000 + 500
    self.shape_worker.fy = (self.gy + 6) * 1000 + 500
    i = (self.shape_worker.gx) % (_G.chunk_width)
    o = (self.shape_worker.gy) % (_G.chunk_width)
    cx = math.floor(self.shape_worker.gx / _G.chunk_width)
    cy = math.floor(self.shape_worker.gy / _G.chunk_width)
    _G.addObjectAt(cx, cy, i, o, self.shape_worker)

    self.lifter:deactivate()
    self.puller:deactivate()
    self.shaper:deactivate()
    self.working = false
end
function Quarry:load(data)
    Object.deserialize(self, data)
    Structure.load(self, data)
    self.health = data.health
    self.stone_quantity = data.stone_quantity
    self.working = data.working
    self.offset_x = data.offset_x
    self.offset_y = data.offset_y
    self.free_spots = data.free_spots
    if data.lift_worker then
        self.lift_worker = _G.state:dereferenceObject(data.lift_worker)
        self.lift_worker.workplace = self
    end
    if data.pull_worker then
        self.pull_worker = _G.state:dereferenceObject(data.pull_worker)
        self.pull_worker.workplace = self
    end
    if data.shape_worker then
        self.shape_worker = _G.state:dereferenceObject(data.shape_worker)
        self.shape_worker.workplace = self
    end
    self.tile = quad_array[tiles + 1]
    Structure.render(self)
end
function Quarry:serialize()
    local data = {}
    local struct_data = Structure.serialize(self)
    for k, v in pairs(struct_data) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end

    data.health = self.health
    data.stone_quantity = self.stone_quantity
    data.working = self.working
    data.offset_x = self.offset_x
    data.offset_y = self.offset_y
    data.free_spots = self.free_spots
    if self.lift_worker then
        data.lift_worker = _G.state:serializeObject(self.lift_worker)
    end
    if self.pull_worker then
        data.pull_worker = _G.state:serializeObject(self.pull_worker)
    end
    if self.shape_worker then
        data.shape_worker = _G.state:serializeObject(self.shape_worker)
    end
    return data
end
function Quarry.static:deserialize(data)
    local obj = self:allocate()
    obj:load(data)
    return obj
end

return Quarry
