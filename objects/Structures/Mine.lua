local tileQuads = require("objects.object_quads")
local Structure = require("objects.Structure")
local Object = require("objects.Object")
local anim = require("libraries.anim8")
local Iron = require("objects.Environment.Iron")
local NotEnoughWorkersFloat = require("objects.Structures.NotEnoughWorkersFloat")

local tiles, quadArray = _G.indexBuildingQuads("iron_mine")
local frPouring = _G.indexQuads("anim_iron_miner_pour", 20)
local frBucket = _G.indexQuads("anim_iron_miner_pull", 8)
local frCastingIron = _G.indexQuads("anim_iron_miner_cast", 24)
local frMinerGoingDown = _G.indexQuads("anim_iron_miner_hole", 38)
local frMinerGoingUp = _G.reverse(_G.indexQuads("anim_iron_miner_hole", 38))
local frMinerPulling = _G.indexQuads("anim_iron_miner_rope", 12)
local frStack = _G.indexQuads("anim_iron_miner_stack", 8)
-- extra 2 loops on this animation
local frTunnelGlow = _G.indexQuads("anim_iron_miner_glow", 8, nil, true)
local tempAnim = { _G.unpack(frTunnelGlow) }
for _ = 1, 2 do
    for _, v in ipairs(tempAnim) do
        table.insert(frTunnelGlow, v)
    end
end

local function reverseTable(t)
    local reversed = {}
    local count = #t
    for idx, v in ipairs(t) do
        reversed[count + 1 - idx] = v
    end
    return reversed
end

local ironFx = {
    ["pull"] = { _G.fx["iron_pull5"],
        _G.fx["iron_pull6"],
        _G.fx["iron_pull7"] },
    ["strain"] = { _G.fx["iron_straining1"],
        _G.fx["iron_straining2"],
        _G.fx["iron_straining3"] },
    ["irondump"] = { _G.fx["iron_dump1"],
        _G.fx["iron_dump2"], },
    ["ironcook"] = { _G.fx["iron_boil1"] },
    ["ironpour"] = { _G.fx["iron_pour1"],
        _G.fx["iron_pour2"], },
}

local frChimneyGlow = _G.indexQuads("anim_iron_miner_chimney_glow", 8, nil)
local frReverseChimneyGlow = reverseTable(frChimneyGlow)
local frChimneySmoke = _G.indexQuads("anim_iron_miner_smoke", 28)

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
    [ANIM_POURING] = frPouring,
    [ANIM_POURING_2] = { tileQuads["anim_iron_miner_pour (20)"] },
    [ANIM_BUCKET] = frBucket,
    [ANIM_CASTING_IRON] = frCastingIron,
    [ANIM_MINER_GOING_DOWN] = frMinerGoingDown,
    [ANIM_MINER_GOING_UP] = frMinerGoingUp,
    [ANIM_MINER_PULLING] = frMinerPulling,
    [ANIM_STACK] = frStack,
    [ANIM_TUNNEL_GLOW] = frTunnelGlow,
    [ANIM_CHIMNEY_GLOW] = frChimneyGlow,
    [ANIM_REVERSE_CHIMNEY_GLOW] = frReverseChimneyGlow,
    [ANIM_CHIMNEY_SMOKE] = frChimneySmoke
}

local MineGoingDown = _G.class("MineGoingDown", Structure)
function MineGoingDown:initialize(gx, gy, parent, offsetX, offsetY)
    self.parent = parent
    Structure.initialize(self, gx, gy, "Iron mine up/down")
    self.goingAnimOffsetX, self.goingAnimOffsetY = 13 + offsetX - 48, 6 + offsetY - 32 - 16
    self.tunnelAnimOffsetX, self.tunnelAnimOffsetY = 13 + offsetX - 48, -72
    self.animated = true
    self.animation = anim.newAnimation(an[ANIM_MINER_GOING_DOWN], 0.11, self:callback_1(), ANIM_MINER_GOING_DOWN)
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.offsetX = 13 + offsetX - 48
    self.offsetY = 6 + offsetY - 32 - 16

    self:registerAsActiveEntity()
end

function MineGoingDown:serialize()
    local data = {}
    local structData = Structure.serialize(self)
    for k, v in pairs(structData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.animation = self.animation:serialize()
    data.animated = self.animated
    data.offsetX = self.offsetX
    data.offsetY = self.offsetY
    data.goingAnimOffsetX = self.goingAnimOffsetX
    data.goingAnimOffsetY = self.goingAnimOffsetY
    data.tunnelAnimOffsetX = self.tunnelAnimOffsetX
    data.tunnelAnimOffsetY = self.tunnelAnimOffsetY
    data.parent = _G.state:serializeObject(self.parent)
    return data
end

function MineGoingDown.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    obj.parent = _G.state:dereferenceObject(data.parent)
    obj.parent.goingDown = obj
    local callback
    local anData = data.animation
    if anData.animationIdentifier == ANIM_MINER_GOING_DOWN then
        callback = obj:callback_1()
    elseif anData.animationIdentifier == ANIM_TUNNEL_GLOW then
        callback = obj:callback_2()
    elseif anData.animationIdentifier == ANIM_MINER_GOING_UP then
        callback = obj:callback_3()
    end
    obj.animation = _G.anim.newAnimation(an[anData.animationIdentifier], 1, callback, anData.animationIdentifier)
    obj.animation:deserialize(anData)

    return obj
end

function MineGoingDown:callback_1()
    return function()
        self.offsetX, self.offsetY = self.tunnelAnimOffsetX, self.tunnelAnimOffsetY
        self.animation = anim.newAnimation(an[ANIM_TUNNEL_GLOW], 0.11, self:callback_2(), ANIM_TUNNEL_GLOW)
        -- no sound
    end
end

function MineGoingDown:callback_2()
    return function()
        self.offsetX, self.offsetY = self.goingAnimOffsetX, self.goingAnimOffsetY
        self.animation = anim.newAnimation(an[ANIM_MINER_GOING_UP], 0.11, self:callback_3(), ANIM_MINER_GOING_UP)
        -- no sound
    end
end

function MineGoingDown:callback_3()
    return function()
        self.animation:pause()
        self:deactivate()
        self.parent.puller:activate()
        self.parent.bucket:activate()

        local wait = 100
        local temp = 0
        _G.playSfx(self, ironFx["pull"])
    end
end

function MineGoingDown:animate(dt)
    Structure.animate(self, dt, true)
end

function MineGoingDown:activate()
    self.animated = true
    self.animation = anim.newAnimation(an[ANIM_MINER_GOING_DOWN], 0.11, self:callback_1(), ANIM_MINER_GOING_DOWN)
    self:animate()
end

function MineGoingDown:deactivate()
    self.animation:pause()
    self.tile = tileQuads["empty"]
    if self.instancemesh then
        _G.freeVertexFromTile(self.cx, self.cy, self.vertId)
        self.instancemesh = nil
    end
    self.animated = false
end

local MinePuller = _G.class("MinePuller", Structure)
function MinePuller:initialize(gx, gy, parent, offsetX, offsetY)
    self.parent = parent
    Structure.initialize(self, gx, gy, "Mine puller")
    self.animated = true
    self.animation = anim.newAnimation(an[ANIM_MINER_PULLING], 0.11, self:pullCallback(), ANIM_MINER_PULLING)
    self.animation:pause()
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.offsetX = 13 + offsetX + 32 + 32 - 48
    self.offsetY = -2 + offsetY - 32 + 8

    self:registerAsActiveEntity()
end

function MinePuller:serialize()
    local data = {}
    local structData = Structure.serialize(self)
    for k, v in pairs(structData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.animation = self.animation:serialize()
    data.animated = self.animated
    data.offsetX = self.offsetX
    data.offsetY = self.offsetY
    data.parent = _G.state:serializeObject(self.parent)
    return data
end

function MinePuller.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    obj.parent = _G.state:dereferenceObject(data.parent)
    obj.parent.puller = obj
    local callback
    local anData = data.animation
    if anData.animationIdentifier == ANIM_MINER_PULLING then
        callback = obj:pullCallback()
    end
    obj.animation = _G.anim.newAnimation(an[anData.animationIdentifier], 1, callback, anData.animationIdentifier)
    obj.animation:deserialize(anData)

    return obj
end

function MinePuller:pullCallback()
    return function()
        self.animation:pause()
        self.parent.pourer:activate()
        self:deactivate()
        self.parent.bucket:deactivate()
    end
end

function MinePuller:animate(dt)
    Structure.animate(self, dt, true)
end

function MinePuller:activate()
    self.animated = true
    self.animation:resume()
    self:animate()
end

function MinePuller:deactivate()
    self.animation:pause()
    self.tile = tileQuads["empty"]
    if self.instancemesh then
        _G.freeVertexFromTile(self.cx, self.cy, self.vertId)
        self.instancemesh = nil
    end
    self.animated = false
end

local MineBucket = _G.class("MineBucket", Structure)
function MineBucket:initialize(gx, gy, parent, offsetX, offsetY)
    local mytype = "Hook"
    self.parent = parent
    Structure.initialize(self, gx, gy, mytype)
    self.animated = true
    self.animation = anim.newAnimation(an[ANIM_BUCKET], 0.19, nil, ANIM_BUCKET)
    self.animation:pause()
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.offsetX = -3 + offsetX + 48 + 32 - 48
    self.offsetY = -8 + offsetY - 32

    self:registerAsActiveEntity()
end

function MineBucket:serialize()
    local data = {}
    local structData = Structure.serialize(self)
    for k, v in pairs(structData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.animation = self.animation:serialize()
    data.animated = self.animated
    data.offsetX = self.offsetX
    data.offsetY = self.offsetY
    data.parent = _G.state:serializeObject(self.parent)
    return data
end

function MineBucket.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    obj.parent = _G.state:dereferenceObject(data.parent)
    obj.parent.bucket = obj
    local anData = data.animation
    obj.animation = _G.anim.newAnimation(an[anData.animationIdentifier], 1, nil, anData.animationIdentifier)
    obj.animation:deserialize(anData)

    return obj
end

function MineBucket:animate(dt)
    Structure.animate(self, dt, true)
end

function MineBucket:activate()
    self.animated = true
    self.animation:gotoFrame(1)
    self.animation:resume()
    self:animate()
end

function MineBucket:deactivate()
    self.animation:pause()
    self.tile = tileQuads["empty"]
    if self.instancemesh then
        _G.freeVertexFromTile(self.cx, self.cy, self.vertId)
        self.instancemesh = nil
    end
    self.animated = false
end

local MinePourer = _G.class("MinePourer", Structure)
function MinePourer:initialize(gx, gy, parent, offsetX, offsetY)
    self.parent = parent
    Structure.initialize(self, gx, gy, "Mine pouring")
    self.animated = true
    self.animation = anim.newAnimation(an[ANIM_POURING], 0.11, self:pourCallback_1(), ANIM_POURING)
    self.animation:pause()
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.offsetX = 13 + offsetX + 48 + 32 - 48
    self.offsetY = -13 + offsetY - 16

    self:registerAsActiveEntity()
end

function MinePourer:pourCallback_1()
    return function()
        self.animation = anim.newAnimation(an[ANIM_POURING_2], 0.1, self:pourCallback_2(), ANIM_POURING_2)
        self.parent.casting:activate()
        if self.parent.stack.quantity < 7 then
            self.parent.goingDown:activate()
        else
            self.parent.unloading = true
            self.parent:findExitPointTo("Stockpile", function(found, path)
                if found then
                    self.parent:sendToStockpile()
                else
                    print("No path found to stockpile!")
                end
            end)
        end
    end
end

function MinePourer:pourCallback_2()
    return function()
        self:deactivate()
    end
end

function MinePourer:serialize()
    local data = {}
    local structData = Structure.serialize(self)
    for k, v in pairs(structData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.animation = self.animation:serialize()
    data.animated = self.animated
    data.offsetX = self.offsetX
    data.offsetY = self.offsetY
    data.parent = _G.state:serializeObject(self.parent)
    return data
end

function MinePourer.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    obj.parent = _G.state:dereferenceObject(data.parent)
    obj.parent.pourer = obj
    local callback
    local anData = data.animation
    if anData.animationIdentifier == ANIM_POURING then
        callback = obj:pourCallback_1()
    elseif anData.animationIdentifier == ANIM_POURING_2 then
        callback = obj:pourCallback_2()
    end
    obj.animation = _G.anim.newAnimation(an[anData.animationIdentifier], 1, callback, anData.animationIdentifier)
    obj.animation:deserialize(anData)

    return obj
end

function MinePourer:animate(dt)
    local prevPosition = self.animation.position
    Structure.animate(self, dt, true)
    local newPosition = self.animation.position
    if self.animation.status == "playing" and self.animation.animationIdentifier == ANIM_POURING and prevPosition ~= newPosition then
        if (self.animation.position == 13 or (prevPosition < 13 and newPosition > 13)) then
            _G.playSfx(self, ironFx["irondump"])
        end
    end
end

function MinePourer:activate()
    self.animation = anim.newAnimation(an[ANIM_POURING], 0.11, self:pourCallback_1(), ANIM_POURING)
    self.animated = true
    self.animation:gotoFrame(1)
    self.animation:resume()
    _G.playSfx(self, ironFx["strain"])
    self:animate()
end

function MinePourer:deactivate()
    self.animation:pause()
    self.tile = tileQuads["empty"]
    if self.instancemesh then
        _G.freeVertexFromTile(self.cx, self.cy, self.vertId)
        self.instancemesh = nil
    end
    self.animated = false
end

local MineCasting = _G.class("MineCasting", Structure)
function MineCasting:initialize(gx, gy, parent, offsetX, offsetY)
    self.parent = parent
    Structure.initialize(self, gx, gy, "Mine casting")
    self.castX, self.castY = 49 + offsetX - 16 - 48, 11 + offsetY - 64
    self.chimneyX, self.chimneyY = -15, -96
    self.smokeX, self.smokeY = -10, -165
    self.animated = true
    self.animation = anim.newAnimation(an[ANIM_CHIMNEY_GLOW], 0.11, self:castCallback_1(), ANIM_CHIMNEY_GLOW)
    self.animation:pause()
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.offsetX, self.offsetY = self.chimneyX, self.chimneyY

    self:registerAsActiveEntity()
end

--- Animation: Chimney Smoke
function MineCasting:castCallback_1()
    return function()
        self.offsetX, self.offsetY = self.smokeX, self.smokeY
        self.animation = anim.newAnimation(an[ANIM_CHIMNEY_SMOKE], 0.11, self:castCallback_2(), ANIM_CHIMNEY_SMOKE)
        _G.playSfx(self, ironFx["ironcook"])
    end
end

--- Animation: Pour Iron 1
function MineCasting:castCallback_2()
    return function()
        self.offsetX, self.offsetY = self.chimneyX, self.chimneyY
        self.animation = anim.newAnimation(
            an[ANIM_REVERSE_CHIMNEY_GLOW], 0.11, self:castCallback_3(), ANIM_REVERSE_CHIMNEY_GLOW)
    end
end

--- Animation: Pour Iron 2
function MineCasting:castCallback_3()
    return function()
        self.offsetX, self.offsetY = self.castX, self.castY
        self.animation = anim.newAnimation(an[ANIM_CASTING_IRON], 0.11, self:castCallback_4(), ANIM_CASTING_IRON)
        _G.playSfx(self, ironFx["ironpour"])
    end
end

--- Animation: Place Iron
function MineCasting:castCallback_4()
    return function()
        if not self.parent.stack.animated then
            self.parent.stack:activate()
        end
        self.parent.stack:stack()
        self.animation = anim.newAnimation(an[ANIM_CHIMNEY_GLOW], 0.11, self:castCallback_1(), ANIM_CHIMNEY_GLOW)
        self.animation:pause()
        self:deactivate()
    end
end

function MineCasting:serialize()
    local data = {}
    local structData = Structure.serialize(self)
    for k, v in pairs(structData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.animation = self.animation:serialize()
    data.animated = self.animated
    data.offsetX = self.offsetX
    data.offsetY = self.offsetY
    data.castX, data.castY = self.castX, self.castY
    data.chimneyX, data.chimneyY = self.chimneyX, self.chimneyY
    data.smokeX, data.smokeY = self.smokeX, self.smokeY
    data.parent = _G.state:serializeObject(self.parent)
    return data
end

function MineCasting.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    obj.parent = _G.state:dereferenceObject(data.parent)
    obj.parent.casting = obj
    local callback
    local anData = data.animation
    if anData.animationIdentifier == ANIM_CHIMNEY_GLOW then
        callback = obj:castCallback_1()
    elseif anData.animationIdentifier == ANIM_CHIMNEY_SMOKE then
        callback = obj:castCallback_2()
    elseif anData.animationIdentifier == ANIM_REVERSE_CHIMNEY_GLOW then
        callback = obj:castCallback_3()
    elseif anData.animationIdentifier == ANIM_CASTING_IRON then
        callback = obj:castCallback_4()
    end
    obj.animation = _G.anim.newAnimation(an[anData.animationIdentifier], 1, callback, anData.animationIdentifier)
    obj.animation:deserialize(anData)

    return obj
end

function MineCasting:animate(dt)
    Structure.animate(self, dt, true)
end

function MineCasting:activate()
    self.animated = true
    self.animation:gotoFrame(1)
    self.animation:resume()
    self:animate()
end

function MineCasting:deactivate()
    self.animation:pause()
    self.tile = tileQuads["empty"]
    if self.instancemesh then
        _G.freeVertexFromTile(self.cx, self.cy, self.vertId)
        self.instancemesh = nil
    end
    self.animated = false
end

local MineStack = _G.class("MineStack", Structure)
function MineStack:initialize(gx, gy, parent, offsetX, offsetY)
    self.parent = parent
    Structure.initialize(self, gx, gy, "Mine stack")
    self.animated = true
    self.animation = anim.newAnimation(an[ANIM_STACK], 0.11, nil, ANIM_STACK)
    self.animation:pause()
    self.quantity = 0
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.offsetX = 49 + offsetX - 16 - 48
    self.offsetY = 11 + offsetY - 32 - 8 + 3

    self:registerAsActiveEntity()
end

function MineStack:serialize()
    local data = {}
    local structData = Structure.serialize(self)
    for k, v in pairs(structData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.animation = self.animation:serialize()
    data.animated = self.animated
    data.offsetX = self.offsetX
    data.offsetY = self.offsetY
    data.quantity = self.quantity
    data.parent = _G.state:serializeObject(self.parent)
    return data
end

function MineStack.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    obj.parent = _G.state:dereferenceObject(data.parent)
    obj.parent.stack = obj
    local anData = data.animation
    obj.animation = _G.anim.newAnimation(an[anData.animationIdentifier], 1, nil, anData.animationIdentifier)
    obj.animation:deserialize(anData)

    return obj
end

function MineStack:stack()
    self.quantity = self.quantity + 1
    self.animation:gotoFrame(self.quantity)
end

function MineStack:animate(dt)
    Structure.animate(self, dt, true)
end

function MineStack:activate()
    self.animated = true
    self.animation:gotoFrame(1)
    self.animation:pause()
    self:animate()
end

function MineStack:deactivate()
    self.quantity = 0
    self.animation:pause()
    self.tile = tileQuads["empty"]
    if self.instancemesh then
        _G.freeVertexFromTile(self.cx, self.cy, self.vertId)
        self.instancemesh = nil
    end
    self.animated = false
end

function MineStack:take()
    self.quantity = self.quantity - 1
    if self.quantity == 0 then
        self:deactivate()
        self.parent.unloading = false
        return
    end
    self.animation:gotoFrame(self.quantity)
end

local MineAlias = _G.class("MineAlias", Structure)
function MineAlias:initialize(tile, gx, gy, parent, offsetY, offsetX)
    self.parent = parent
    Structure.initialize(self, gx, gy, "Mine alias")
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.tile = tile
    self.baseOffsetY = offsetY or 0
    self.additionalOffsetY = 0
    self.offsetX = offsetX or 0
    self.offsetY = self.additionalOffsetY - self.baseOffsetY
    self:render()
end

function MineAlias:serialize()
    local data = {}
    local structData = Structure.serialize(self)
    for k, v in pairs(structData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.tileKey = self.tileKey
    data.baseOffsetY = self.baseOffsetY
    data.additionalOffsetY = self.additionalOffsetY
    data.offsetX = self.offsetX
    data.offsetY = self.offsetY
    data.parent = _G.state:serializeObject(self.parent)
    return data
end

function MineAlias.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    obj.parent = _G.state:dereferenceObject(data.parent)
    if data.tileKey then
        obj.tile = quadArray[data.tileKey]
        obj.tileKey = data.tileKey
        obj:render()
    end
    return obj
end

local Mine = _G.class("Mine", Structure)
Mine.static.WIDTH = 4
Mine.static.LENGTH = 4
Mine.static.HEIGHT = 16
Mine.static.ALIAS_NAME = "MineAlias"
Mine.static.DESTRUCTIBLE = true
function Mine:initialize(gx, gy, irons)
    _G.JobController:add("Miner", self)
    Structure.initialize(self, gx, gy, "Mine")
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.health = 400
    self.tile = quadArray[tiles + 1]
    self.working = false
    self.unloading = false
    self.offsetX = 0
    self.offsetY = -64 + 16 + 4
    self.freeSpots = 1
    self.worker = nil
    self.irons = irons

    self.pourer = MinePourer:new(self.gx + 1, self.gy + 1, self, self.offsetX - 64 - 16, self.offsetY)
    self.pourer:deactivate()
    self.goingDown = MineGoingDown:new(self.gx + 3, self.gy + 3, self, self.offsetX, self.offsetY)
    self.goingDown:deactivate()
    self.puller = MinePuller:new(self.gx + 2, self.gy + 1, self, self.offsetX - 64 - 16, self.offsetY)
    self.puller:deactivate()
    self.bucket = MineBucket:new(self.gx + 2, self.gy + 2, self, self.offsetX - 64 - 16, self.offsetY)
    self.bucket:deactivate()
    self.casting = MineCasting:new(self.gx + 2, self.gy + 3, self, self.offsetX, self.offsetY)
    self.casting:deactivate()
    self.stack = MineStack:new(self.gx + 3, self.gy + 2, self, self.offsetX, self.offsetY)
    self.stack:deactivate()

    for tile = 1, tiles do
        local mni = MineAlias:new(
            quadArray[tile], self.gx, self.gy + (tiles - tile + 1), self, -self.offsetY + 8 * (tiles - tile + 1))
        mni.tileKey = tile
    end

    for tile = 1, tiles do
        local mni = MineAlias:new(
            quadArray[tiles + 1 + tile], self.gx + tile, self.gy, self, -self.offsetY + 8 * tile, 16)
        mni.tileKey = tiles + 1 + tile
    end

    for xx = 0, 3 do
        for yy = 0, 3 do
            _G.removeObjectFromClassAtGlobal(self.gx + xx, self.gy + yy, "Iron")
            _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrainBiome.none)
        end
    end

    MineAlias:new(tileQuads["empty"], self.gx + 1, self.gy + 3, self, 12 + 8 * 4, 16)
    MineAlias:new(tileQuads["empty"], self.gx + 3, self.gy + 1, self, 12 + 8 * 4, 16)
    MineAlias:new(tileQuads["empty"], self.gx + 1, self.gy + 2, self, 12 + 8 * 4, 16)
    self:applyBuildingHeightMap()

    self.float = NotEnoughWorkersFloat:new(self.gx + self.class.WIDTH - 1, self.gy + self.class.LENGTH - 1, 7, -112)
end

function Mine:destroy()
    if self.worker then
        self.worker:quitJob()
    end
    self.float:destroy()
    Structure.destroy(self.pourer)
    self.pourer.toBeDeleted = true
    Structure.destroy(self.goingDown)
    self.goingDown.toBeDeleted = true
    Structure.destroy(self.puller)
    self.puller.toBeDeleted = true
    Structure.destroy(self.bucket)
    self.bucket.toBeDeleted = true
    Structure.destroy(self.casting)
    self.casting.toBeDeleted = true
    Structure.destroy(self.stack)
    self.stack.toBeDeleted = true

    for xx = 0, 3 do
        for yy = 0, 3 do
            for i, ironTable in ipairs(self.irons) do
                if ironTable.x == xx and ironTable.y == yy then
                    Iron:new(self.gx + xx, self.gy + yy)
                end
            end
        end
    end

    Structure.destroy(self)
end

function Mine:leave(sleepInsteadOfLeaving)
    if self.worker then
        _G.JobController:add("Miner", self)
        if sleepInsteadOfLeaving then
            self.worker:quitJob()
        else
            self.worker:leaveVillage()
        end
        self.worker = nil
        self.freeSpots = 1
        self.float:activate()
        self.pourer:deactivate()
        self.goingDown:deactivate()
        self.puller:deactivate()
        self.bucket:deactivate()
        self.casting:deactivate()
        self.stack:deactivate()
        return true
    end
end

function Mine:join(worker)
    if self.health == -1 then
        _G.JobController:remove("Miner", self)
        worker:quitJob()
        return
    end
    if self.freeSpots == 1 then
        self.worker = worker
        worker.workplace = self
        self.freeSpots = self.freeSpots - 1
    end
    if self.freeSpots == 0 then
        self.float:deactivate()
    end
end

function Mine:work(worker)
    if self.unloading then
        self.worker.state = "Go to stockpile"
        self.stack:take()
        return
    end
    worker.state = "Working"
    worker.tile = tileQuads["empty"]
    worker.animated = false
    worker.gx = self.gx + 1
    worker.gy = self.gy + 2
    worker:jobUpdate()

    if not self.working and self.worker.state == "Working" then
        self.working = true
        self.goingDown:activate()
    end
end

function Mine:sendToStockpile()
    self:respawnWorker(self.worker, "Go to stockpile")
    self.stack:take()
    self.goingDown:deactivate()
    self.working = false
end

function Mine:load(data)
    Object.deserialize(self, data)
    Structure.load(self, data)
    if data.worker then
        self.worker = _G.state:dereferenceObject(data.worker)
        self.worker.workplace = self
    end
    self.tile = quadArray[tiles + 1]
    Structure.render(self)
end

function Mine:serialize()
    local data = {}
    local structData = Structure.serialize(self)
    for k, v in pairs(structData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.health = self.health
    data.working = self.working
    data.unloading = self.unloading
    data.offsetX = self.offsetX
    data.offsetY = self.offsetY
    data.freeSpots = self.freeSpots
    data.irons = self.irons
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
