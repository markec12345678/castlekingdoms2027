local active_entities, _, tile_quads, _ = ...
local Structure = require("objects.Structure")
local Object = require("objects.Object")

local tiles, quad_array = _G.indexBuildingQuads("woodcutter_hut", true)

local fr_woodcutter_sawing = _G.indexQuads("anim_woodcutter_saw", 19, nil, true)
local fr_plank_stack = _G.indexQuads("anim_woodcutter_planks", 3)
local fr_log_stack = _G.indexQuads("anim_woodcutter_logs", 3)

local AN_HUT_SAWING = "Sawing"
local AN_HUT_PLANKS = "Plank stack"
local AN_HUT_LOGS = "Log stack"

local an = {
    [AN_HUT_SAWING] = fr_woodcutter_sawing,
    [AN_HUT_PLANKS] = fr_plank_stack,
    [AN_HUT_LOGS] = fr_log_stack
}

local WoodcutterHut_log_stack = _G.class('WoodcutterHut_log_stack', Structure)
function WoodcutterHut_log_stack:initialize(gx, gy, parent, offset_x, offset_y)
    local mytype = "Animation"
    Structure.initialize(self, gx, gy, mytype)
    self.tile = tile_quads["empty"]
    self.animated = false
    self.animation = _G.anim.newAnimation(an[AN_HUT_LOGS], 0.11, nil, AN_HUT_LOGS)
    self.animation:pause()
    self.quantity = 0
    self.gx = gx
    self.gy = gy
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.parent = parent
    self.qid = 0
    self.offset_x = -51
    self.offset_y = -50

    table.insert(active_entities, self)
end
function WoodcutterHut_log_stack:serialize()
    local data = {}
    local struct_data = Structure.serialize(self)
    for k, v in pairs(struct_data) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.animation = self.animation:serialize()
    data.animated = self.animated
    data.quantity = self.quantity
    data.offset_x = self.offset_x
    data.offset_y = self.offset_y
    return data
end
function WoodcutterHut_log_stack.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    local an_data = data.animation
    local callback = function()
        if not obj.parent.stack.animated then
            obj.parent.stack:activate()
        else
            obj.parent.stack:stack()
        end
        local took_log = obj.parent.log_stack:take()
        if not took_log then
            obj.parent:send_to_stockpile()
            obj:deactivate()
        end
    end
    obj.animation = _G.anim.newAnimation(an[an_data.animation_identifier], 1, callback, an_data.animation_identifier)
    obj.animation:deserialize(an_data)
    table.insert(active_entities, obj)
    return obj
end
function WoodcutterHut_log_stack:stack()
    self.quantity = self.quantity + 1
    self.animation:gotoFrame(self.quantity)
    self:animate(_G.dt, true)
end
function WoodcutterHut_log_stack:animate(dt)
    Structure.animate(self, dt, true)
end
function WoodcutterHut_log_stack:activate()
    self.animated = true
    self.quantity = 1
    self.animation:gotoFrame(1)
    self.animation:pause()
    self:animate()
end
function WoodcutterHut_log_stack:deactivate()
    self.animation:pause()
    self.quantity = 0
    self.tile = tile_quads["empty"]
    if self.instancemesh then
        _G.freeVertexFromTile(self.cx, self.cy, self.vert_id)
        self.instancemesh = nil
    end
    self.animated = false
end
function WoodcutterHut_log_stack:take()
    if self.quantity == 0 then
        return false
    end
    self.quantity = self.quantity - 1
    if self.quantity == 0 then
        self:deactivate()
        return true
    end
    self.animation:gotoFrame(self.quantity)
    self:animate(_G.dt, true)
    return true
end

local WoodcutterHut_plank_stack = _G.class('WoodcutterHut_plank_stack', Structure)
function WoodcutterHut_plank_stack:initialize(gx, gy, parent, offset_x, offset_y)
    local mytype = "Animation"
    Structure.initialize(self, gx, gy, mytype)
    self.tile = tile_quads["empty"]
    self.animated = false
    self.animation = _G.anim.newAnimation(an[AN_HUT_PLANKS], 0.11, nil, AN_HUT_PLANKS)
    self.animation:pause()
    self.quantity = 0
    self.gx = gx
    self.gy = gy
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.parent = parent
    self.qid = 0
    self.offset_x = -23
    self.offset_y = -52

    table.insert(active_entities, self)
end
function WoodcutterHut_plank_stack:serialize()
    local data = {}
    local struct_data = Structure.serialize(self)
    for k, v in pairs(struct_data) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.animation = self.animation:serialize()
    data.animated = self.animated
    data.quantity = self.quantity
    data.offset_x = self.offset_x
    data.offset_y = self.offset_y
    return data
end
function WoodcutterHut_plank_stack.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    local an_data = data.animation
    obj.animation = _G.anim.newAnimation(an[an_data.animation_identifier], 1, callback, an_data.animation_identifier)
    obj.animation:deserialize(an_data)
    table.insert(active_entities, obj)
    return obj
end
function WoodcutterHut_plank_stack:stack()
    self.quantity = self.quantity + 1
    self.animation:gotoFrame(self.quantity)
    self:animate(_G.dt, true)
end
function WoodcutterHut_plank_stack:animate(dt)
    Structure.animate(self, dt, true)
end
function WoodcutterHut_plank_stack:activate()
    self.animated = true
    self.quantity = 1
    self.animation:gotoFrame(1)
    self.animation:pause()
    self:animate()
end
function WoodcutterHut_plank_stack:deactivate()
    self.animation:pause()
    self.quantity = 0
    self.tile = tile_quads["empty"]
    if self.instancemesh then
        _G.freeVertexFromTile(self.cx, self.cy, self.vert_id)
        self.instancemesh = nil
    end
    self.animated = false
end
function WoodcutterHut_plank_stack:take()
    self.quantity = self.quantity - 3
    if self.quantity == 0 then
        self:deactivate()
        self.parent.unloading = false
        return
    end
    self.animation:gotoFrame(self.quantity)
end

local WoodcutterHut_sawing = _G.class('WoodcutterHut_sawing', Structure)
function WoodcutterHut_sawing:initialize(gx, gy, parent, offset_x, offset_y)
    local mytype = "Animation"
    Structure.initialize(self, gx, gy, mytype)
    self.tile = tile_quads["empty"]
    self.animated = false
    self.animation = _G.anim.newAnimation(an[AN_HUT_SAWING], 0.11, nil, AN_HUT_SAWING)
    self.animation:pause()
    self.gx = gx
    self.gy = gy
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.parent = parent
    self.qid = 0
    self.offset_x = -35
    self.offset_y = -44
    self:setCallback()

    table.insert(active_entities, self)
end
function WoodcutterHut_sawing:animate(dt)
    Structure.animate(self, _G.dt, true)
end
function WoodcutterHut_sawing:activate()
    self.animated = true
    self.animation:gotoFrame(1)
    self.animation:resume()
    self:animate(_G.dt)
end
function WoodcutterHut_sawing:deactivate()
    self.animation:pause()
    self.tile = tile_quads["empty"]
    if self.instancemesh then
        _G.freeVertexFromTile(self.cx, self.cy, self.vert_id)
        self.instancemesh = nil
    end
    self.animated = false
end
function WoodcutterHut_sawing:serialize()
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
function WoodcutterHut_sawing:setCallback()
    local parent = self.parent
    self.animation.onLoop = function()
        if not parent.stack.animated then
            parent.stack:activate()
        else
            parent.stack:stack()
        end
        local took_log = parent.log_stack:take()
        if not took_log then
            parent:send_to_stockpile()
            self:deactivate()
        end
    end
end
function WoodcutterHut_sawing.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    local an_data = data.animation
    print("parent imm", obj.parent)
    obj.animation = _G.anim.newAnimation(an[an_data.animation_identifier], 1, nil, an_data.animation_identifier)
    obj.animation:deserialize(an_data)
    table.insert(active_entities, obj)
    return obj
end

local WoodcutterHut_alias = _G.class('WoodcutterHut_alias', Structure)
function WoodcutterHut_alias:initialize(tile, gx, gy, parent, offset_y, offset_x)
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
function WoodcutterHut_alias:serialize()
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
function WoodcutterHut_alias.static:deserialize(data)
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

local WoodcutterHut = _G.class('WoodcutterHut', Structure)
function WoodcutterHut:initialize(gx, gy, type)
    _G.JobController:add("Woodcutter", self)
    local mytype = "Static structure"
    Structure.initialize(self, gx, gy, mytype)
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.health = 400
    self.qid = nil
    self.tile = quad_array[tiles + 1]
    self.working = false
    self.unloading = false
    self.offset_x = 0
    self.offset_y = -32
    self.free_spots = 1
    self.worker = nil

    self.stack = WoodcutterHut_plank_stack:new(self.gx, self.gy + 2, self, self.offset_x, self.offset_y)
    self.sawing_obj = WoodcutterHut_sawing:new(self.gx, self.gy, self, self.offset_x, self.offset_y)
    self.log_stack = WoodcutterHut_log_stack:new(self.gx + 2, self.gy + 1, self, self.offset_x, self.offset_y)
    -- self.stack:deactivate()

    for xx = -1, 3 do
        for yy = -1, 3 do
            _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrain_biome.scarce_grass)
        end
    end

    _G.terrainSetTileAt(self.gx - 2, self.gy, _G.terrain_biome.scarce_grass)
    _G.terrainSetTileAt(self.gx - 2, self.gy + 1, _G.terrain_biome.scarce_grass)
    _G.terrainSetTileAt(self.gx - 2, self.gy + 2, _G.terrain_biome.scarce_grass)

    _G.terrainSetTileAt(self.gx, self.gy - 2, _G.terrain_biome.scarce_grass)
    _G.terrainSetTileAt(self.gx + 1, self.gy - 2, _G.terrain_biome.scarce_grass)
    _G.terrainSetTileAt(self.gx + 2, self.gy - 2, _G.terrain_biome.scarce_grass)

    _G.terrainSetTileAt(self.gx + 4, self.gy, _G.terrain_biome.scarce_grass)
    _G.terrainSetTileAt(self.gx + 4, self.gy + 1, _G.terrain_biome.scarce_grass)
    _G.terrainSetTileAt(self.gx + 4, self.gy + 2, _G.terrain_biome.scarce_grass)

    _G.terrainSetTileAt(self.gx, self.gy + 4, _G.terrain_biome.scarce_grass)
    _G.terrainSetTileAt(self.gx + 1, self.gy + 4, _G.terrain_biome.scarce_grass)
    _G.terrainSetTileAt(self.gx + 2, self.gy + 4, _G.terrain_biome.scarce_grass)

    for xx = 0, 2 do
        for yy = 0, 2 do
            local xxx = (self.gx + xx) % (chunk_width)
            local yyy = (self.gy + yy) % (chunk_width)
            local ccx = math.floor((self.gx + xx) / chunk_width)
            local ccy = math.floor((self.gy + yy) / chunk_width)
            _G.buildingheightmap[ccx][ccy][xxx][yyy] = 14
            _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrain_biome.none)
        end
    end
    for tile = 1, tiles do
        local wht = WoodcutterHut_alias:new(quad_array[tile], self.gx, self.gy + (tiles - tile + 1), self,
            -self.offset_y + 8 * (tiles - tile + 1))
        wht.tile_key = tile
    end
    for tile = 1, tiles do
        local wht = WoodcutterHut_alias:new(quad_array[tiles + 1 + tile], self.gx + tile, self.gy, self,
            -self.offset_y + 8 * tile, 16)
        wht.tile_key = tiles + 1 + tile
    end

    Structure.render(self)
end
function WoodcutterHut:join(worker)
    if self.free_spots == 1 then
        self.worker = worker
        self.worker.workplace = self
        self.free_spots = self.free_spots - 1
    end
end
function WoodcutterHut:work(worker)
    self.log_stack:activate()
    self.log_stack:stack()
    self.log_stack:stack()
    worker.state = "Working"
    worker.tile = tile_quads["empty"]
    worker.animated = false
    worker.gx = self.gx + 1
    worker.gy = self.gy + 2
    worker:job_update()
    -- self.lifter.tile = tile_quads[139]

    if not self.working and self.worker.state == "Working" then
        self.working = true
        self.sawing_obj:activate()
    end
end
function WoodcutterHut:send_to_stockpile()
    local i, o, cx, cy
    self.worker.state = "Go to stockpile"
    self.worker.animated = true
    self.worker.gx = self.gx + 1
    self.worker.gy = self.gy + 3
    self.worker.fx = (self.gx + 1) * 1000 + 500
    self.worker.fy = (self.gy + 3) * 1000 + 500
    i = (self.worker.gx) % (chunk_width)
    o = (self.worker.gy) % (chunk_width)
    cx = math.floor(self.worker.gx / chunk_width)
    cy = math.floor(self.worker.gy / chunk_width)
    addObjectAt(cx, cy, i, o, self.worker)
    self.stack:deactivate()
    self.working = false
end
function WoodcutterHut:load(data)
    Object.deserialize(self, data)
    Structure.load(self, data)
    -- TODO: Make woodcutter able to be serialized with anim
    -- self.worker = _G.state:dereferenceObject(data.worker)
    self.stack = _G.state:dereferenceObject(data.stack)
    self.stack.parent = self
    self.sawing_obj = _G.state:dereferenceObject(data.sawing_obj)
    self.sawing_obj.parent = self
    self.sawing_obj:setCallback()
    self.log_stack = _G.state:dereferenceObject(data.log_stack)
    self.log_stack.parent = self
    self.health = data.health
    self.offset_x = data.offset_x
    self.offset_y = data.offset_y
    self.tile = quad_array[tiles + 1]
    Structure.render(self)
end
function WoodcutterHut:serialize()
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
    -- data.worker = _G.state:serializeObject(self.worker)
    data.stack = _G.state:serializeObject(self.stack)
    data.sawing_obj = _G.state:serializeObject(self.sawing_obj)
    data.log_stack = _G.state:serializeObject(self.log_stack)
    return data
end
function WoodcutterHut.static:deserialize(data)
    local obj = self:allocate()
    obj:load(data)
    return obj
end

return WoodcutterHut
