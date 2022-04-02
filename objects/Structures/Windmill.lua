local active_entities, _, tile_quads, _ = ...

local Structure = require("objects.Structure")
local Object = require("objects.Object")
local anim = require("libraries.anim8")

local tiles, quad_array = _G.indexBuildingQuads("windmill_whole", nil, 2)

local fr_windmill_fan = _G.indexQuads("anim_windmill_fan", 15)
local fr_anim_windmill_outside = _G.indexQuads("anim_windmill_outside", 15)
local fr_anim_windmill_inside = _G.indexQuads("anim_windmill_inside", 15)
local fr_anim_windmill_filling = _G.indexQuads("anim_windmill_filling", 30)

local ANIM_WINDMILL_FAN = "anim_windmill_fan"
local ANIM_WINDMILL_OUTSIDE = "anim_windmill_outside"
local ANIM_WINDMILL_INSIDE = "anim_windmill_inside"
local ANIM_WINDMILL_FILLING = "anim_windmill_filling"

local temp_anim = {_G.unpack(fr_windmill_fan)}
for _ = 1, 2 do
    for _, v in ipairs(temp_anim) do
        table.insert(fr_windmill_fan, v)
    end
end
temp_anim = {_G.unpack(fr_anim_windmill_outside)}
for _ = 1, 2 do
    for _, v in ipairs(temp_anim) do
        table.insert(fr_anim_windmill_outside, v)
    end
end
temp_anim = {_G.unpack(fr_anim_windmill_inside)}
for _ = 1, 2 do
    for _, v in ipairs(temp_anim) do
        table.insert(fr_anim_windmill_inside, v)
    end
end

local an = {
    [ANIM_WINDMILL_FAN] = fr_windmill_fan,
    [ANIM_WINDMILL_OUTSIDE] = fr_anim_windmill_outside,
    [ANIM_WINDMILL_INSIDE] = fr_anim_windmill_inside,
    [ANIM_WINDMILL_FILLING] = fr_anim_windmill_filling
}

local Windmill_blade = _G.class('Windmill_blade', Structure)
function Windmill_blade:initialize(gx, gy, parent)
    Structure.initialize(self, gx, gy, "Windmill blade")
    self.tile = tile_quads["empty"]
    self.animated = true
    self.animation = anim.newAnimation(an[ANIM_WINDMILL_FAN], 0.11, nil, ANIM_WINDMILL_FAN)
    self.parent = parent
    self.qid = 0
    self.offset_x = -60
    self.offset_y = -274

    table.insert(active_entities, self)
end
function Windmill_blade:serialize()
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
    return data
end
function Windmill_blade.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    local an_data = data.animation
    obj.animation = _G.anim.newAnimation(an[an_data.animation_identifier], 1, nil, an_data.animation_identifier)
    obj.animation:deserialize(an_data)
    table.insert(active_entities, obj)
    return obj
end
function Windmill_blade:animate(dt)
    Structure.animate(self, dt, true)
end
function Windmill_blade:activate()
    self.animation:resume()
end
function Windmill_blade:deactivate()
    self.animation:pause()
end

local Windmill_filling = _G.class('Windmill_filling', Structure)
function Windmill_filling:initialize(gx, gy, parent)
    Structure.initialize(self, gx, gy, "Windmill filling animation")
    self.tile = tile_quads["empty"]
    self.animated = false
    self.animation = anim.newAnimation(an[ANIM_WINDMILL_FILLING], 0.11, function()
        self:filling_callback()
    end, ANIM_WINDMILL_FILLING)
    self.animation:pause()
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.parent = parent
    self.qid = 0
    self.offset_x = -62
    self.offset_y = -201

    table.insert(active_entities, self)
end
function Windmill_filling:filling_callback()
    self.parent.blade_shadow:show_outside()
    self.parent:send_to_stockpile()
    self:deactivate()
end
function Windmill_filling:animate(dt)
    Structure.animate(self, dt, true)
end
function Windmill_filling:activate()
    self.animated = true
    self.parent.blade_shadow:show_inside()
    self.animation:gotoFrame(1)
    self.animation:resume()
    self:animate(_G.dt)
end
function Windmill_filling:deactivate()
    self.animation:pause()
    self.tile = tile_quads["empty"]
    if self.instancemesh then
        _G.freeVertexFromTile(self.cx, self.cy, self.vert_id)
        self.instancemesh = nil
    end
    self.animated = false
end
function Windmill_filling:serialize()
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
    return data
end
function Windmill_filling.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    local an_data = data.animation
    local callback
    if an_data.animation_identifier == ANIM_WINDMILL_FILLING then
        callback = function()
            obj:filling_callback()
        end
    end
    obj.animation = _G.anim.newAnimation(an[an_data.animation_identifier], 1, callback, an_data.animation_identifier)
    obj.animation:deserialize(an_data)
    table.insert(active_entities, obj)
    return obj
end

local Windmill_shadow = _G.class('Windmill_shadow', Structure)
function Windmill_shadow:initialize(gx, gy, parent)
    Structure.initialize(self, gx, gy, "Windmill shadow")
    self.tile = tile_quads["empty"]
    self.animated = true
    self.animation = anim.newAnimation(an[ANIM_WINDMILL_OUTSIDE], 0.11, nil, ANIM_WINDMILL_OUTSIDE)
    self.parent = parent
    self.qid = 0
    self.offset_x = -46
    self.offset_y = -243

    table.insert(active_entities, self)
end
function Windmill_shadow:serialize()
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
    return data
end
function Windmill_shadow.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    local an_data = data.animation
    obj.animation = _G.anim.newAnimation(an[an_data.animation_identifier], 1, nil, an_data.animation_identifier)
    obj.animation:deserialize(an_data)
    table.insert(active_entities, obj)
    return obj
end
function Windmill_shadow:animate(dt)
    Structure.animate(self, dt, true)
end
function Windmill_shadow:activate()
    self.animation:resume()
end
function Windmill_shadow:show_inside()
    local frame = self.animation.position
    self.animation = anim.newAnimation(an[ANIM_WINDMILL_INSIDE], 0.11, nil, ANIM_WINDMILL_INSIDE)
    self.animation:gotoFrame(frame)
end
function Windmill_shadow:show_outside()
    local frame = self.animation.position
    self.animation = anim.newAnimation(an[ANIM_WINDMILL_OUTSIDE], 0.11, nil, ANIM_WINDMILL_OUTSIDE)
    self.animation:gotoFrame(frame)
    self:animate()
end
function Windmill_shadow:deactivate()
    self.animation:pause()
end

local Windmill_alias = _G.class('Windmill_alias', Structure)
function Windmill_alias:initialize(tile, gx, gy, parent, offset_y, offset_x)
    Structure.initialize(self, gx, gy, "Windmill alias")
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
function Windmill_alias:serialize()
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
    return data
end
function Windmill_alias.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    if data.tile_key then
        obj.tile = quad_array[data.tile_key]
        obj.tile_key = data.tile_key
        obj:render()
    end
    return obj
end

local Windmill = _G.class('Windmill', Structure)
function Windmill:initialize(gx, gy, type)
    _G.JobController:add("Miller", self)
    type = type or "Windmill"
    Structure.initialize(self, gx, gy, type)
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.health = 400
    self.qid = nil
    self.tile = quad_array[tiles + 1]
    self.working = false
    self.unloading = false
    self.offset_x = 0
    local _, _, _, lh = self.tile:getViewport()
    self.offset_y = 48 - lh

    self.wheat = 0
    self.free_spots = 3
    self.worker = nil
    self.worker2 = nil
    self.worker3 = nil
    self.worker_delivered = false
    self.worker2_delivered = false
    self.worker3_delivered = false

    self.blade = Windmill_blade:new(self.gx, self.gy + 2, self)
    self.blade_shadow = Windmill_shadow:new(self.gx, self.gy + 2, self)
    self.filling_flour = Windmill_filling:new(self.gx + 1, self.gy + 2, self)

    for xx = 0, 2 do
        for yy = 0, 2 do
            local xxx = (self.gx + xx) % (_G.chunk_width)
            local yyy = (self.gy + yy) % (_G.chunk_width)
            local ccx = math.floor((self.gx + xx) / _G.chunk_width)
            local ccy = math.floor((self.gy + yy) / _G.chunk_width)
            _G.buildingheightmap[ccx][ccy][xxx][yyy] = 25
        end
    end

    for xx = -2, 4 do
        for yy = -2, 4 do
            _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrain_biome.dirt, _G.terrain_biome.abundant_grass)
        end
    end
    for xx = -1, 3 do
        for yy = -1, 3 do
            _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrain_biome.scarce_grass)
        end
    end
    for xx = 0, 2 do
        for yy = 0, 2 do
            _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrain_biome.none)
        end
    end
    for tile = 1, tiles do
        local wnd = Windmill_alias:new(quad_array[tile], self.gx, self.gy + (tiles - tile + 1), self,
            -self.offset_y + 8 * (tiles - tile + 1))
        wnd.tile_key = tile
    end
    for tile = 1, tiles do
        local wnd = Windmill_alias:new(quad_array[tiles + 1 + tile], self.gx + tile, self.gy, self,
            -self.offset_y + 8 * tile, 16)
        wnd.tile_key = tiles + 1 + tile
    end

    _G.state.map:setWalkable(self.gx + 2, self.gy + 2, false)
    Structure.render(self)
end
function Windmill:load(data)
    Object.deserialize(self, data)
    Structure.load(self, data)
    self.health = data.health
    self.working = data.working
    self.unloading = data.unloading
    self.offset_x = data.offset_x
    self.offset_y = data.offset_y
    self.wheat = data.wheat
    self.free_spots = data.free_spots
    if data.worker then
        self.worker = _G.state:dereferenceObject(data.worker)
        self.worker.workplace = self
    end
    if data.worker2 then
        self.worker2 = _G.state:dereferenceObject(data.worker2)
        self.worker2.workplace = self
    end
    if data.worker3 then
        self.worker3 = _G.state:dereferenceObject(data.worker3)
        self.worker3.workplace = self
    end
    self.worker_delivered = data.worker_delivered
    self.worker2_delivered = data.worker2_delivered
    self.worker3_delivered = data.worker3_delivered
    self.blade = _G.state:dereferenceObject(data.blade)
    self.blade.parent = self
    self.blade_shadow = _G.state:dereferenceObject(data.blade_shadow)
    self.blade_shadow.parent = self
    self.filling_flour = _G.state:dereferenceObject(data.filling_flour)
    self.filling_flour.parent = self
    self.tile = quad_array[tiles + 1]
    Structure.render(self)
end
function Windmill:serialize()
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
    data.wheat = self.wheat
    data.free_spots = self.free_spots
    if self.worker then
        data.worker = _G.state:serializeObject(self.worker)
    end
    if self.worker2 then
        data.worker2 = _G.state:serializeObject(self.worker2)
    end
    if self.worker3 then
        data.worker3 = _G.state:serializeObject(self.worker3)
    end
    data.worker_delivered = self.worker_delivered
    data.worker2_delivered = self.worker2_delivered
    data.worker3_delivered = self.worker3_delivered
    data.blade = _G.state:serializeObject(self.blade)
    data.blade_shadow = _G.state:serializeObject(self.blade_shadow)
    data.filling_flour = _G.state:serializeObject(self.filling_flour)
    return data
end
function Windmill.static:deserialize(data)
    local obj = self:allocate()
    obj:load(data)
    return obj
end
function Windmill:join(worker)
    if self.free_spots == 3 then
        self.worker = worker
        self.worker.workplace = self
        self.free_spots = self.free_spots - 1
    elseif self.free_spots == 2 then
        self.worker2 = worker
        self.worker2.workplace = self
        self.free_spots = self.free_spots - 1
    elseif self.free_spots == 1 then
        self.worker3 = worker
        self.worker3.workplace = self
        self.free_spots = self.free_spots - 1
    end
end
function Windmill:work(worker)
    if worker.state == "Going to workplace with wheat" then
        if not self.working then
            self.wheat = self.wheat + 1
            if worker == self.worker3 or worker == self.worker2 then
                worker.state = "Waiting for work"
                return
            else
                if self.wheat >= 3 then
                    if not self.working then
                        worker.state = "Working"
                        self.working = true
                        worker.tile = tile_quads["empty"]
                        worker.animated = false
                        worker.gx = self.gx + 1
                        worker.gy = self.gy + 2
                        worker.nd = {}
                        worker.waypoint_x, worker.waypoint_y = nil, nil
                        worker.move_dir = "none"
                        worker.count = 1
                        worker:job_update()
                        self.filling_flour:activate()
                        self.wheat = self.wheat - 3
                        self.blade_shadow:show_inside()
                        self.worker2_delivered, self.worker3_delivered = false, false
                        -- else
                        --     self.worker.state = "Waiting for work"
                    end
                else
                    worker.state = "Waiting for work"
                end
            end
        end
    else
        -- self.worker.state = "Waiting for work"
        -- worker.state = "Waiting for work"
        if worker == self.worker and self.wheat == 3 then
            worker.state = "Working"
            self.working = true
            worker.tile = tile_quads["empty"]
            worker.animated = false
            worker.gx = self.gx + 1
            worker.gy = self.gy + 2
            worker.nd = {}
            worker.waypoint_x, worker.waypoint_y = nil, nil
            worker.move_dir = "none"
            worker.count = 1
            worker:job_update()
            self.wheat = self.wheat - 3
            self.worker2_delivered, self.worker3_delivered = false, false
            self.filling_flour:activate()
            self.blade_shadow:show_inside()
        else
            if worker == self.worker3 and self.wheat < 4 then
                worker.state = "Go to stockpile for wheat"
                worker.nd = {}
                worker.waypoint_x, worker.waypoint_y = nil, nil
                worker.move_dir = "none"
                worker.count = 1
            end
            if worker == self.worker2 and self.wheat < 4 then
                worker.state = "Go to stockpile for wheat"
                worker.nd = {}
                worker.waypoint_x, worker.waypoint_y = nil, nil
                worker.move_dir = "none"
                worker.count = 1
            end
            if worker == self.worker and not self.worker_delivered then
                if self.wheat >= 3 then
                    worker.state = "Working"
                    self.working = true
                    worker.tile = tile_quads["empty"]
                    worker.animated = false
                    worker.gx = self.gx + 1
                    worker.gy = self.gy + 2
                    worker.nd = {}
                    worker.waypoint_x, worker.waypoint_y = nil, nil
                    worker.move_dir = "none"
                    worker.count = 1
                    worker:job_update()
                    self.wheat = self.wheat - 3
                    self.worker2_delivered, self.worker3_delivered = false, false
                    self.filling_flour:activate()
                    self.blade_shadow:show_inside()
                elseif not self.worker_delivered then
                    worker.state = "Go to stockpile for wheat"
                    worker.nd = {}
                    worker.waypoint_x, worker.waypoint_y = nil, nil
                    worker.move_dir = "none"
                    worker.count = 1
                end
            end
        end
    end
end
function Windmill:send_to_stockpile()
    local i, o, cx, cy
    self.worker.state = "Go to stockpile"
    self.worker.animated = true
    self.worker.gx = self.gx + 1
    self.worker.gy = self.gy + 4
    self.worker.fx = (self.gx + 1) * 1000 + 500
    self.worker.fy = (self.gy + 4) * 1000 + 500
    i = (self.worker.gx) % (_G.chunk_width)
    o = (self.worker.gy) % (_G.chunk_width)
    cx = math.floor(self.worker.gx / _G.chunk_width)
    cy = math.floor(self.worker.gy / _G.chunk_width)
    _G.addObjectAt(cx, cy, i, o, self.worker)
    self.working = false
    self.worker_delivered = false
end

return Windmill
