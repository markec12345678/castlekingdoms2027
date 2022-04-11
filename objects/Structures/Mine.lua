local active_entities, _, tile_quads, _ = ...
local Structure = require("objects.Structure")
local Object = require("objects.Object")
local anim = require("libraries.anim8")

local tiles, quad_array = _G.indexBuildingQuads("iron_mine")
local fr_pouring = _G.indexQuads("anim_iron_miner_pour", 20)
local fr_bucket = _G.indexQuads("anim_iron_miner_pull", 8)
local fr_casting_iron = _G.indexQuads("anim_iron_miner_cast", 24)
local fr_miner_going_down = _G.indexQuads("anim_iron_miner_hole", 38)
local fr_miner_going_up = _G.reverse(_G.indexQuads("anim_iron_miner_hole", 38))
local fr_miner_pulling = _G.indexQuads("anim_iron_miner_rope", 12)
local fr_stack = _G.indexQuads("anim_iron_miner_stack", 8)
-- extra 2 loops on this animation
local fr_tunnel_glow = _G.indexQuads("anim_iron_miner_glow", 8, nil, true)
local temp_anim = {_G.unpack(fr_tunnel_glow)}
for _ = 1, 2 do
    for _, v in ipairs(temp_anim) do
        table.insert(fr_tunnel_glow, v)
    end
end

local function reverse_table(t)
    local reversed = {}
    local count = #t
    for idx, v in ipairs(t) do
        reversed[count + 1 - idx] = v
    end
    return reversed
end

local fr_chimney_glow = _G.indexQuads("anim_iron_miner_chimney_glow", 8, nil)
local fr_reverse_chimney_glow = reverse_table(fr_chimney_glow)
local fr_chimney_smoke = _G.indexQuads("anim_iron_miner_smoke", 28)

local ANIM_POURING = "Pouring"
local ANIM_POURING_2 = "Pouring 2"
local ANIM_BUCKET = "Bucket"
local ANIM_CASTING_IRON = "Casting_Iron"
local ANIM_MINER_GOING_DOWN = "Miner_Going_Down"
local ANIM_MINER_GOING_UP = "Miner_Going_Up"
local ANIM_MINER_PULLING = "Miner_Pulling"
local ANIM_STACK = "Stack"
local ANIM_TUNNEL_GLOW = "Tunnel_Glow"
local ANIM_CHIMNEY_GLOW = "Chimney_Glow"
local ANIM_REVERSE_CHIMNEY_GLOW = "Reverse_Chimney_Glow"
local ANIM_CHIMNEY_SMOKE = "Chimney_Smoke"

local an = {
    [ANIM_POURING] = fr_pouring,
    [ANIM_POURING_2] = {tile_quads["anim_iron_miner_pour (20)"]},
    [ANIM_BUCKET] = fr_bucket,
    [ANIM_CASTING_IRON] = fr_casting_iron,
    [ANIM_MINER_GOING_DOWN] = fr_miner_going_down,
    [ANIM_MINER_GOING_UP] = fr_miner_going_up,
    [ANIM_MINER_PULLING] = fr_miner_pulling,
    [ANIM_STACK] = fr_stack,
    [ANIM_TUNNEL_GLOW] = fr_tunnel_glow,
    [ANIM_CHIMNEY_GLOW] = fr_chimney_glow,
    [ANIM_REVERSE_CHIMNEY_GLOW] = fr_reverse_chimney_glow,
    [ANIM_CHIMNEY_SMOKE] = fr_chimney_smoke
}

local Mine_going_down = _G.class('Mine_going_down', Structure)
function Mine_going_down:initialize(gx, gy, parent, offset_x, offset_y)
    Structure.initialize(self, gx, gy, "Iron mine up/down")
    self.going_anim_offset_x, self.going_anim_offset_y = 13 + offset_x - 48, 6 + offset_y - 32 - 16
    self.tunnel_anim_offset_x, self.tunnel_anim_offset_y = 13 + offset_x - 48, -72
    self.animated = true
    self.animation = anim.newAnimation(an[ANIM_MINER_GOING_DOWN], 0.11, self:callback_1(), ANIM_MINER_GOING_DOWN)
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.parent = parent
    self.offset_x = 13 + offset_x - 48
    self.offset_y = 6 + offset_y - 32 - 16

    table.insert(active_entities, self)
end
function Mine_going_down:serialize()
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
    data.going_anim_offset_x = self.going_anim_offset_x
    data.going_anim_offset_y = self.going_anim_offset_y
    data.tunnel_anim_offset_x = self.tunnel_anim_offset_x
    data.tunnel_anim_offset_y = self.tunnel_anim_offset_y
    data.parent = _G.state:serializeObject(self.parent)
    return data
end
function Mine_going_down.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    obj.parent = _G.state:dereferenceObject(data.parent)
    obj.parent.going_down = obj
    local callback
    local an_data = data.animation
    if an_data.animation_identifier == ANIM_MINER_GOING_DOWN then
        callback = obj:callback_1()
    elseif an_data.animation_identifier == ANIM_TUNNEL_GLOW then
        callback = obj:callback_2()
    elseif an_data.animation_identifier == ANIM_MINER_GOING_UP then
        callback = obj:callback_3()
    end
    obj.animation = _G.anim.newAnimation(an[an_data.animation_identifier], 1, callback, an_data.animation_identifier)
    obj.animation:deserialize(an_data)
    table.insert(active_entities, obj)
    return obj
end
function Mine_going_down:callback_1()
    return function()
        self.offset_x, self.offset_y = self.tunnel_anim_offset_x, self.tunnel_anim_offset_y
        self.animation = anim.newAnimation(an[ANIM_TUNNEL_GLOW], 0.11, self:callback_2(), ANIM_TUNNEL_GLOW)
    end
end
function Mine_going_down:callback_2()
    return function()
        self.offset_x, self.offset_y = self.going_anim_offset_x, self.going_anim_offset_y
        self.animation = anim.newAnimation(an[ANIM_MINER_GOING_UP], 0.11, self:callback_3(), ANIM_MINER_GOING_UP)
    end
end
function Mine_going_down:callback_3()
    return function()
        self.animation:pause()
        self:deactivate()
        self.parent.puller:activate()
        self.parent.bucket:activate()
    end
end
function Mine_going_down:animate(dt)
    Structure.animate(self, dt, true)
end
function Mine_going_down:activate()
    self.animated = true
    self.animation = anim.newAnimation(an[ANIM_MINER_GOING_DOWN], 0.11, self:callback_1(), ANIM_MINER_GOING_DOWN)
    self:animate()
end
function Mine_going_down:deactivate()
    self.animation:pause()
    self.tile = tile_quads["empty"]
    if self.instancemesh then
        _G.freeVertexFromTile(self.cx, self.cy, self.vert_id)
        self.instancemesh = nil
    end
    self.animated = false
end

local Mine_puller = _G.class('Mine_puller', Structure)
function Mine_puller:initialize(gx, gy, parent, offset_x, offset_y)
    Structure.initialize(self, gx, gy, "Mine puller")
    self.animated = true
    self.animation = anim.newAnimation(an[ANIM_MINER_PULLING], 0.11, self:pull_callback(), ANIM_MINER_PULLING)
    self.animation:pause()
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.parent = parent
    self.offset_x = 13 + offset_x + 32 + 32 - 48
    self.offset_y = -2 + offset_y - 32 + 8

    table.insert(active_entities, self)
end
function Mine_puller:serialize()
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
function Mine_puller.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    obj.parent = _G.state:dereferenceObject(data.parent)
    obj.parent.puller = obj
    local callback
    local an_data = data.animation
    if an_data.animation_identifier == ANIM_MINER_PULLING then
        callback = obj:pull_callback()
    end
    obj.animation = _G.anim.newAnimation(an[an_data.animation_identifier], 1, callback, an_data.animation_identifier)
    obj.animation:deserialize(an_data)
    table.insert(active_entities, obj)
    return obj
end
function Mine_puller:pull_callback()
    return function()
        self.animation:pause()
        self.parent.pourer:activate()
        self:deactivate()
        self.parent.bucket:deactivate()
    end
end
function Mine_puller:animate(dt)
    Structure.animate(self, dt, true)
end
function Mine_puller:activate()
    self.animated = true
    self.animation:resume()
    self:animate()
end
function Mine_puller:deactivate()
    self.animation:pause()
    self.tile = tile_quads["empty"]
    if self.instancemesh then
        _G.freeVertexFromTile(self.cx, self.cy, self.vert_id)
        self.instancemesh = nil
    end
    self.animated = false
end
local Mine_bucket = _G.class('Mine_bucket', Structure)
function Mine_bucket:initialize(gx, gy, parent, offset_x, offset_y)
    local mytype = "Hook"
    Structure.initialize(self, gx, gy, mytype)
    self.animated = true
    self.animation = anim.newAnimation(an[ANIM_BUCKET], 0.19, nil, ANIM_BUCKET)
    self.animation:pause()
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.parent = parent
    self.offset_x = -3 + offset_x + 48 + 32 - 48
    self.offset_y = -8 + offset_y - 32

    table.insert(active_entities, self)
end
function Mine_bucket:serialize()
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
function Mine_bucket.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    obj.parent = _G.state:dereferenceObject(data.parent)
    obj.parent.bucket = obj
    local an_data = data.animation
    obj.animation = _G.anim.newAnimation(an[an_data.animation_identifier], 1, nil, an_data.animation_identifier)
    obj.animation:deserialize(an_data)
    table.insert(active_entities, obj)
    return obj
end
function Mine_bucket:animate(dt)
    Structure.animate(self, dt, true)
end
function Mine_bucket:activate()
    self.animated = true
    self.animation:gotoFrame(1)
    self.animation:resume()
    self:animate()
end
function Mine_bucket:deactivate()
    self.animation:pause()
    self.tile = tile_quads["empty"]
    if self.instancemesh then
        _G.freeVertexFromTile(self.cx, self.cy, self.vert_id)
        self.instancemesh = nil
    end
    self.animated = false
end

local Mine_pourer = _G.class('Mine_pourer', Structure)
function Mine_pourer:initialize(gx, gy, parent, offset_x, offset_y)
    Structure.initialize(self, gx, gy, "Mine pouring")
    self.animated = true
    self.animation = anim.newAnimation(an[ANIM_POURING], 0.11, self:pour_callback_1(), ANIM_POURING)
    self.animation:pause()
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.parent = parent
    self.offset_x = 13 + offset_x + 48 + 32 - 48
    self.offset_y = -13 + offset_y - 16

    table.insert(active_entities, self)
end
function Mine_pourer:pour_callback_1()
    return function()
        self.animation = anim.newAnimation(an[ANIM_POURING_2], 0.1, self:pour_callback_2(), ANIM_POURING_2)
        self.parent.casting:activate()
        if self.parent.stack.quantity < 7 then
            self.parent.going_down:activate()
        else
            self.parent.unloading = true
            self.parent:send_to_stockpile()
        end
    end
end
function Mine_pourer:pour_callback_2()
    return function()
        self:deactivate()
    end
end
function Mine_pourer:serialize()
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
function Mine_pourer.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    obj.parent = _G.state:dereferenceObject(data.parent)
    obj.parent.pourer = obj
    local callback
    local an_data = data.animation
    if an_data.animation_identifier == ANIM_POURING then
        callback = obj:pour_callback_1()
    elseif an_data.animation_identifier == ANIM_POURING_2 then
        callback = obj:pour_callback_2()
    end
    obj.animation = _G.anim.newAnimation(an[an_data.animation_identifier], 1, callback, an_data.animation_identifier)
    obj.animation:deserialize(an_data)
    table.insert(active_entities, obj)
    return obj
end
function Mine_pourer:animate(dt)
    Structure.animate(self, dt, true)
end
function Mine_pourer:activate()
    self.animation = anim.newAnimation(an[ANIM_POURING], 0.11, self:pour_callback_1(), ANIM_POURING)
    self.animated = true
    self.animation:gotoFrame(1)
    self.animation:resume()
    self:animate()
end
function Mine_pourer:deactivate()
    self.animation:pause()
    self.tile = tile_quads["empty"]
    if self.instancemesh then
        _G.freeVertexFromTile(self.cx, self.cy, self.vert_id)
        self.instancemesh = nil
    end
    self.animated = false
end
local Mine_casting = _G.class('Mine_casting', Structure)
function Mine_casting:initialize(gx, gy, parent, offset_x, offset_y)
    Structure.initialize(self, gx, gy, "Mine casting")
    self.cast_x, self.cast_y = 49 + offset_x - 16 - 48, 11 + offset_y - 64
    self.chimney_x, self.chimney_y = -15, -96
    self.smoke_x, self.smoke_y = -10, -165
    self.animated = true
    self.animation = anim.newAnimation(an[ANIM_CHIMNEY_GLOW], 0.11, self:cast_callback_1(), ANIM_CHIMNEY_GLOW)
    self.animation:pause()
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.parent = parent
    self.offset_x, self.offset_y = self.chimney_x, self.chimney_y

    table.insert(active_entities, self)
end
function Mine_casting:cast_callback_1()
    return function()
        self.offset_x, self.offset_y = self.smoke_x, self.smoke_y
        self.animation = anim.newAnimation(an[ANIM_CHIMNEY_SMOKE], 0.11, self:cast_callback_2(), ANIM_CHIMNEY_SMOKE)
    end
end
function Mine_casting:cast_callback_2()
    return function()
        self.offset_x, self.offset_y = self.chimney_x, self.chimney_y
        self.animation = anim.newAnimation(an[ANIM_REVERSE_CHIMNEY_GLOW], 0.11, self:cast_callback_3(),
            ANIM_REVERSE_CHIMNEY_GLOW)
    end
end
function Mine_casting:cast_callback_3()
    return function()
        self.offset_x, self.offset_y = self.cast_x, self.cast_y
        self.animation = anim.newAnimation(an[ANIM_CASTING_IRON], 0.11, self:cast_callback_4(), ANIM_CASTING_IRON)
    end
end
function Mine_casting:cast_callback_4()
    return function()
        if not self.parent.stack.animated then
            self.parent.stack:activate()
        end
        self.parent.stack:stack()
        self.animation = anim.newAnimation(an[ANIM_CHIMNEY_GLOW], 0.11, self:cast_callback_1(), ANIM_CHIMNEY_GLOW)
        self.animation:pause()
        self:deactivate()
    end
end
function Mine_casting:serialize()
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
    data.cast_x, data.cast_y = self.cast_x, self.cast_y
    data.chimney_x, data.chimney_y = self.chimney_x, self.chimney_y
    data.smoke_x, data.smoke_y = self.smoke_x, self.smoke_y
    data.parent = _G.state:serializeObject(self.parent)
    return data
end
function Mine_casting.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    obj.parent = _G.state:dereferenceObject(data.parent)
    obj.parent.casting = obj
    local callback
    local an_data = data.animation
    if an_data.animation_identifier == ANIM_CHIMNEY_GLOW then
        callback = obj:cast_callback_1()
    elseif an_data.animation_identifier == ANIM_CHIMNEY_SMOKE then
        callback = obj:cast_callback_2()
    elseif an_data.animation_identifier == ANIM_REVERSE_CHIMNEY_GLOW then
        callback = obj:cast_callback_3()
    elseif an_data.animation_identifier == ANIM_CASTING_IRON then
        callback = obj:cast_callback_4()
    end
    obj.animation = _G.anim.newAnimation(an[an_data.animation_identifier], 1, callback, an_data.animation_identifier)
    obj.animation:deserialize(an_data)
    table.insert(active_entities, obj)
    return obj
end
function Mine_casting:animate(dt)
    Structure.animate(self, dt, true)
end
function Mine_casting:activate()
    self.animated = true
    self.animation:gotoFrame(1)
    self.animation:resume()
    self:animate()
end
function Mine_casting:deactivate()
    self.animation:pause()
    self.tile = tile_quads["empty"]
    if self.instancemesh then
        _G.freeVertexFromTile(self.cx, self.cy, self.vert_id)
        self.instancemesh = nil
    end
    self.animated = false
end
local Mine_stack = _G.class('Mine_stack', Structure)
function Mine_stack:initialize(gx, gy, parent, offset_x, offset_y)
    Structure.initialize(self, gx, gy, "Mine stack")
    self.animated = true
    self.animation = anim.newAnimation(an[ANIM_STACK], 0.11, nil, ANIM_STACK)
    self.animation:pause()
    self.quantity = 0
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.parent = parent
    self.offset_x = 49 + offset_x - 16 - 48
    self.offset_y = 11 + offset_y - 32 - 8 + 3

    table.insert(active_entities, self)
end
function Mine_stack:serialize()
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
function Mine_stack.static:deserialize(data)
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
function Mine_stack:stack()
    self.quantity = self.quantity + 1
    self.animation:gotoFrame(self.quantity)
end
function Mine_stack:animate(dt)
    Structure.animate(self, dt, true)
end
function Mine_stack:activate()
    self.animated = true
    self.animation:gotoFrame(1)
    self.animation:pause()
    self:animate()
end
function Mine_stack:deactivate()
    self.animation:pause()
    self.tile = tile_quads["empty"]
    if self.instancemesh then
        _G.freeVertexFromTile(self.cx, self.cy, self.vert_id)
        self.instancemesh = nil
    end
    self.animated = false
end
function Mine_stack:take()
    self.quantity = self.quantity - 1
    if self.quantity == 0 then
        self:deactivate()
        self.parent.unloading = false
        return
    end
    self.animation:gotoFrame(self.quantity)
end
local Mine_alias = _G.class('Mine_alias', Structure)
function Mine_alias:initialize(tile, gx, gy, parent, offset_y, offset_x)
    Structure.initialize(self, gx, gy, "Mine alias")
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
    self:render()
end
function Mine_alias:serialize()
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
function Mine_alias.static:deserialize(data)
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

local Mine = _G.class('Mine', Structure)
function Mine:initialize(gx, gy)
    _G.JobController:add("Miner", self)
    Structure.initialize(self, gx, gy, "Mine")
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.health = 400
    self.tile = quad_array[tiles + 1]
    self.working = false
    self.unloading = false
    self.offset_x = 0
    self.offset_y = -64 + 16 + 4
    self.free_spots = 1
    self.worker = nil

    self.pourer = Mine_pourer:new(self.gx + 1, self.gy + 1, self, self.offset_x - 64 - 16, self.offset_y)
    self.pourer:deactivate()
    self.going_down = Mine_going_down:new(self.gx + 3, self.gy + 3, self, self.offset_x, self.offset_y)
    self.going_down:deactivate()
    self.puller = Mine_puller:new(self.gx + 2, self.gy + 1, self, self.offset_x - 64 - 16, self.offset_y)
    self.puller:deactivate()
    self.bucket = Mine_bucket:new(self.gx + 2, self.gy + 2, self, self.offset_x - 64 - 16, self.offset_y)
    self.bucket:deactivate()
    self.casting = Mine_casting:new(self.gx + 2, self.gy + 3, self, self.offset_x, self.offset_y)
    self.casting:deactivate()
    self.stack = Mine_stack:new(self.gx + 3, self.gy + 2, self, self.offset_x, self.offset_y)
    self.stack:deactivate()

    for tile = 1, tiles do
        local mni = Mine_alias:new(quad_array[tile], self.gx, self.gy + (tiles - tile + 1), self,
            -self.offset_y + 8 * (tiles - tile + 1))
        mni.tile_key = tile
    end

    for tile = 1, tiles do
        local mni = Mine_alias:new(quad_array[tiles + 1 + tile], self.gx + tile, self.gy, self,
            -self.offset_y + 8 * tile, 16)
        mni.tile_key = tiles + 1 + tile
    end

    for xx = 0, 3 do
        for yy = 0, 3 do
            _G.removeObjectFromClassAtGlobal(self.gx + xx, self.gy + yy, "Iron")
            _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrain_biome.none)
        end
    end

    Mine_alias:new(tile_quads["empty"], self.gx + 1, self.gy + 3, self, 12 + 8 * 4, 16)
    Mine_alias:new(tile_quads["empty"], self.gx + 3, self.gy + 1, self, 12 + 8 * 4, 16)

    self:render()
end
function Mine:join(worker)
    if self.free_spots == 1 then
        self.worker = worker
        worker.workplace = self
        self.free_spots = self.free_spots - 1
    end
end
function Mine:work(worker)
    if self.unloading then
        self.worker.state = "Go to stockpile"
        self.stack:take()
        return
    end
    worker.state = "Working"
    worker.tile = tile_quads["empty"]
    worker.animated = false
    worker.gx = self.gx + 1
    worker.gy = self.gy + 2
    worker:job_update()

    if not self.working and self.worker.state == "Working" then
        self.working = true
        self.going_down:activate()
    end
end
function Mine:send_to_stockpile()
    local i, o, cx, cy
    self.worker.state = "Go to stockpile"
    self.worker.animated = true
    self.worker.gx = self.gx - 1
    self.worker.gy = self.gy + 1
    self.worker.fx = (self.gx - 1) * 1000 + 500
    self.worker.fy = (self.gy + 1) * 1000 + 500
    i = (self.worker.gx) % (_G.chunk_width)
    o = (self.worker.gy) % (_G.chunk_width)
    cx = math.floor(self.worker.gx / _G.chunk_width)
    cy = math.floor(self.worker.gy / _G.chunk_width)
    _G.addObjectAt(cx, cy, i, o, self.worker)
    self.stack:take()
    self.going_down:deactivate()
    self.working = false
end
function Mine:load(data)
    Object.deserialize(self, data)
    Structure.load(self, data)
    if data.worker then
        self.worker = _G.state:dereferenceObject(data.worker)
        self.worker.workplace = self
    end
    self.tile = quad_array[tiles + 1]
    Structure.render(self)
end
function Mine:serialize()
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
function Mine.static:deserialize(data)
    local obj = self:allocate()
    obj:load(data)
    return obj
end

return Mine
