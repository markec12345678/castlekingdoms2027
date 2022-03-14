local active_entities, object, tile_quads, object_batch = ...
local Structure = require("objects.Structure")
local Object = require("objects.Object")

local tiles, quad_array = _G.indexBuildingQuads("woodcutter_hut", true)

local fr_woodcutter_sawing = _G.indexQuads("anim_woodcutter_saw", 19, nil, true)
local fr_plank_stack = _G.indexQuads("anim_woodcutter_planks", 3)
local fr_log_stack = _G.indexQuads("anim_woodcutter_logs", 3)

local WoodcutterHut_log_stack = class('WoodcutterHut_log_stack', Structure)
function WoodcutterHut_log_stack:initialize(gx, gy, parent, offset_x, offset_y)
    local mytype = "Animation"
    Structure.initialize(self, gx, gy, mytype)
    self.tile = tile_quads["empty"]
    self.animated = false
    self.animation = anim.newAnimation(fr_log_stack, 0.11)
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

local WoodcutterHut_plank_stack = class('WoodcutterHut_plank_stack', Structure)
function WoodcutterHut_plank_stack:initialize(gx, gy, parent, offset_x, offset_y)
    local mytype = "Animation"
    Structure.initialize(self, gx, gy, mytype)
    self.tile = tile_quads["empty"]
    self.animated = false
    self.animation = anim.newAnimation(fr_plank_stack, 0.11)
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

local WoodcutterHut_sawing = class('WoodcutterHut_sawing', Structure)
function WoodcutterHut_sawing:initialize(gx, gy, parent, offset_x, offset_y)
    local mytype = "Animation"
    Structure.initialize(self, gx, gy, mytype)
    self.tile = tile_quads["empty"]
    self.animated = false
    self.part1_end = function()
        if not self.parent.stack.animated then
            self.parent.stack:activate()
        else
            self.parent.stack:stack()
        end
        local took_log = self.parent.log_stack:take()
        if not took_log then
            self.parent:send_to_stockpile()
            self:deactivate()
        end
    end
    self.animation = anim.newAnimation(fr_woodcutter_sawing, 0.11, self.part1_end)
    self.animation:pause()
    self.gx = gx
    self.gy = gy
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.parent = parent
    self.qid = 0
    self.offset_x = -35
    self.offset_y = -44

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

local WoodcutterHut = class('WoodcutterHut', Structure)
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
        WoodcutterHut_alias:new(quad_array[tile], self.gx, self.gy + (tiles - tile + 1), self,
            -self.offset_y + 8 * (tiles - tile + 1))
    end
    for tile = 1, tiles do
        WoodcutterHut_alias:new(quad_array[tiles + 1 + tile], self.gx + tile, self.gy, self, -self.offset_y + 8 * tile,
            16)
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
function WoodcutterHut:serialize()
    local data = {}
    local struct_data = Structure.serialize(self)
    for k, v in pairs(struct_data) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.health = self.health
    data.offset_x = self.offset_x
    data.offset_y = self.offset_y
    return data
end
function WoodcutterHut.static:deserialize(data)
    local obj = self:new(data.gx, data.gy, data.type)
    Object.deserialize(obj, data)
    return obj
end

return WoodcutterHut
