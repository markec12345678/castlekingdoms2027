local Object = require("objects.Object")
local anim = require("libraries.anim8")
local tileQuads = require("objects.object_quads")

local fallFx = { _G.fx["liltreefall"], _G.fx["bigtreefall1"], _G.fx["bigtreefall2"] }

local quadOffset = require("objects.quad_offset")
local STATIC_TRUNK = "Static Trunk"
local Tree = _G.class("Tree", Object)
function Tree:initialize(gx, gy, type)
    Object.initialize(self, gx, gy, type)
    self.offsetY = self.offsetY or -166
    self.baseOffsetX = self.baseOffsetX or (-3 - 38)
    self.offsetX = self.baseOffsetX
    self.falling = false
    self.chop = false
    self.stump = false
    self.animated = true
    self.marked = false
    self.tile = nil
    self.cuttable = true
    self.tree = true
    self.active = false
    self.offsetTimer = 0
    self.instancemesh = nil
    self.updateTimer = 0
    self.chunkKey = false
    self.trunkTile = tileQuads["empty"]
    for xx = -1, 1 do
        for yy = -1, 1 do
            if not ((xx == -1 and yy == -1) or (xx == 1 and yy == 1) or (xx == -1 and yy == 1) or (xx == 1 and yy == -1)) then
                local ccx, ccy, xxx, yyy = _G.getLocalCoordinatesFromGlobal(self.gx + xx, self.gy + yy)
                if xx == 0 and yy == 0 then
                    _G.state.map.buildingheightmap[ccx][ccy][xxx][yyy] = 19
                else
                    _G.state.map.buildingheightmap[ccx][ccy][xxx][yyy] = 14
                end
            end
        end
    end
    if self.gx < 512 and self.gx >= 0 and self.gy < 512 and self.gy >= 0 then
        _G.state.map:setWalkable(self.gx, self.gy, 1)
    end
    if _G.state.chunkObjects[self.cx][self.cy] == nil then
        _G.state.chunkObjects[self.cx][self.cy] = {}
    end
    _G.state.chunkObjects[self.cx][self.cy][self] = self
    _G.addObjectAt(self.cx, self.cy, self.i, self.o, self)
    self:shadeFromTerrain()
end

function Tree:finish()
    -- Object was deleted by arrayRemove, so we need to readd it
    _G.addObjectAt(self.cx, self.cy, self.i, self.o, self)
    self.animation = anim.newAnimation({ self.trunkTile }, 0.1, nil, STATIC_TRUNK)
    self.animation:pause()
    self.stump = true
    self.animated = false -- mark for removal from list
    self.type = "Stump"
    _G.state.map:setWalkable(self.gx, self.gy, 0)
    self.tile = self.trunkTile
    if self.trunkOffsetY and self.trunkOffsetX then
        self.offsetY = self.trunkOffsetY
        self.offsetX = self.trunkOffsetX
    end

    self:render()
    for xx = -1, 1 do
        for yy = -1, 1 do
            _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrainBiome.dirt, _G.terrainBiome.scarceGrass)
        end
    end
    for xx = -1, 1 do
        for yy = -1, 1 do
            if not ((xx == -1 and yy == -1) or (xx == 1 and yy == 1) or (xx == -1 and yy == 1) or (xx == 1 and yy == -1)) then
                local ccx, ccy, xxx, yyy = _G.getLocalCoordinatesFromGlobal(self.gx + xx, self.gy + yy)
                _G.state.map.buildingheightmap[ccx][ccy][xxx][yyy] = 0
                -- TODO: Force a shadow refresh here
            end
        end
    end
end

function Tree:cutDown()
    return function()
        self.toBeDeleted = true
        self.falling = false
        self.chop = true
        self.animation = self.chopAnimation
        self.animation:pause()
        self:destroy()
    end
end

function Tree:render()
    if not self.instancemesh then
        self:animate()
    end
    if _G.state.objectMesh then
        local offsetX, offsetY = 0, 0
        if quadOffset[self.tile] then
            offsetX, offsetY = quadOffset[self.tile][1] or 0, quadOffset[self.tile][2] or 0
        end
        local x, y = self.x + (self.offsetX or 0) + offsetX, self.y + (self.offsetY or 0) + offsetY
        local qx, qy, qw, qh = self.tile:getViewport()
        self.instancemesh:setVertex(self.vertId, x, y, self:inferZ(), qx, qy, qw, qh, 1, 1, 1, self.pallete)
    end
end

function Tree:calculateShadowValue()
    local cx, cy, i, o = self.cx, self.cy, self.i, self.o
    local elevationOffsetY = _G.state.map.heightmap[cx][cy][i][o] or 0
    local elevationValue = 75 * elevationOffsetY / (40 + elevationOffsetY)
    local shadowValue = _G.state.map.shadowmap[cx][cy][i][o] or 0
    local thisTileheight = _G.state.map.buildingheightmap[cx][cy][i][o] or 0
    if shadowValue < thisTileheight + elevationValue then
        self.shadowValue = 1
    else
        shadowValue = math.min((shadowValue - elevationValue - thisTileheight) / 40, 0.6)
        self.shadowValue = math.min(0.85, 1 - shadowValue)
    end
end

function Tree:shadeFromTerrain()
    self:calculateShadowValue()
    if self.animation then
        self:animate(_G.dt, true)
    end
end

function Tree:update(dt)
    if self.falling then
        self:animate(dt)
    end
end

function Tree:animate(dt, forceUpdate)
    if not self.animation then
        return
    end
    local updated, ticked = false, false
    if _G.state.scaleX > 0.6 then
        updated = self.animation:update(dt)
        ticked = true
        self.offsetTimer = self.offsetTimer + 1
        if self.offsetTimer > 4 then
            self.offsetX = self.baseOffsetX
        end
    elseif _G.state.scaleX >= 0.5 then
        self.updateTimer = self.updateTimer + 1
        if self.updateTimer == 4 then
            updated = self.animation:update(dt * 4)
            ticked = true
            self.updateTimer = 0
        end
    end
    if self.falling and not ticked then
        updated = self.animation:update(dt)
        if not Object.isVisibleOnScreen(self) then
            return -- no need to update vertex if we can't see it
        end
    end
    updated = updated or self.offsetX ~= self.previousOffsetX
    self.previousOffsetX = self.offsetX
    if self.instancemesh and (updated or forceUpdate) then
        self.lastUpdated = 0
        local offsetX, offsetY = 0, 0
        if quadOffset[self.animation:getQuad()] then
            offsetX, offsetY = quadOffset[self.animation:getQuad()][1] or 0,
                quadOffset[self.animation:getQuad()][2] or 0
        end
        local quad, x, y, _, _, _, _, _, _, _ = self.animation:getFrameInfo(
            self.x + (self.offsetX or 0) + offsetX,
            self.y + (self.offsetY or 0) + offsetY - _G.state.map.walkingHeightmap[self.gx][self.gy])

        local elevationOffsetY = 0
        if _G.state.map.heightmap[self.cx][self.cy][self.i][self.o] then
            elevationOffsetY = _G.state.map.heightmap[self.cx][self.cy][self.i][self.o] * 2
        end
        y = y - elevationOffsetY
        local qx, qy, qw, qh = quad:getViewport()
        self.instancemesh:setVertex(self.vertId, x, y, self:inferZ(), qx, qy, qw, qh, self.shadowValue, 1, 1, self.pallete)
        return
    end
    if not self.instancemesh and _G.state.objectMesh then
        local offsetX, offsetY = 0, 0
        if quadOffset[self.animation:getQuad()] then
            offsetX, offsetY = quadOffset[self.animation:getQuad()][1] or 0,
                quadOffset[self.animation:getQuad()][2] or 0
        end
        local instancemesh = _G.state.objectMesh[self.cx][self.cy]
        local quad, x, y, _, _, _, _, _, _, _ = self.animation:getFrameInfo(
            self.x + (self.offsetX or 0) + offsetX,
            self.y + (self.offsetY or 0) + offsetY - _G.state.map.walkingHeightmap[self.gx][self.gy])
        local elevationOffsetY = 0
        if _G.state.map.heightmap[self.cx][self.cy][self.i][self.o] then
            elevationOffsetY = _G.state.map.heightmap[self.cx][self.cy][self.i][self.o] * 2
        end
        y = y - elevationOffsetY
        local qx, qy, qw, qh = quad:getViewport()
        self.vertId = _G.getFreeVertexFromTile(self.cx, self.cy, self)
        if self.vertId then
            self.instancemesh = instancemesh
            self.instancemesh:setVertex(self.vertId, x, y, self:inferZ(), qx, qy, qw, qh, 1, 1, 1, self.pallete)
        end
    end
end

function Tree:cut()
    if self.health > 0 then
        self.offsetX = self.baseOffsetX + 4
        self.offsetTimer = 0
        self.health = self.health - 1
    elseif self.health <= 0 and self.falling == false and self.chop == false and self.stump == false then
        self.offsetX = self.baseOffsetX - 8
        self.offsetTimer = 0
        if self.dead then
            self:finish()
            return 2
        else
            self.animation = self.fallingAnimation
            _G.playSfx(self, fallFx)
            self.falling = true
            -- We need to animate the falling even if the chunk isn't in the view
            self:registerAsActiveEntity()
            if (self.cx > _G.currentChunkX + 1) or (self.cx < _G.currentChunkX - 1) or (self.cy > _G.currentChunkY + 1) or
                (self.cy < _G.currentChunkY - 1) then
                self.chop = true
                self.falling = false
            end
        end
    end
    if self.chop then
        if self.animation:getTotalFrames() ~= self.animation:getCurrentFrame() then
            self.animation:gotoFrame(self.animation:getCurrentFrame() + 1)
            self:animate(_G.dt, true)
        else
            self:finish()
            self.chop = false
            return 2
        end
    end
end

function Tree:serialize()
    local data = {}
    local objectData = Object.serialize(self)
    for k, v in pairs(objectData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.offsetY = self.offsetY
    data.baseOffsetX = self.baseOffsetX
    data.offsetX = self.offsetX
    data.falling = self.falling
    data.chop = self.chop
    data.stump = self.stump
    data.type = self.type
    data.animated = self.animated
    data.marked = self.marked
    data.cuttable = self.cuttable
    data.tree = self.tree
    data.active = self.active
    data.offsetTimer = self.offsetTimer
    data.updateTimer = self.updateTimer
    data.chunkKey = self.chunkKey
    return data
end

function Tree:load(data)
    Object.initialize(self, data.gx, data.gy, data.type)
end

function Tree.static:deserialize(data)
    local obj = self:new(data.gx, data.gy, data.type)
    Object.deserialize(obj, data)
    return obj
end

function Tree:destroy()
    local cx, cy, x, y = _G.getLocalCoordinatesFromGlobal(self.gx - 1, self.gy + 1)
    _G.state.Terrain:scheduleTerrainUpdate(cx, cy, x, y)
    cx, cy, x, y = _G.getLocalCoordinatesFromGlobal(self.gx, self.gy)
    _G.state.Terrain:scheduleTerrainUpdate(cx, cy, x, y)

    for xx = -1, 1 do
        for yy = -1, 1 do
            if not ((xx == -1 and yy == -1) or (xx == 1 and yy == 1) or (xx == -1 and yy == 1) or (xx == 1 and yy == -1)) then
                local ccx, ccy, xxx, yyy = _G.getLocalCoordinatesFromGlobal(self.gx + xx, self.gy + yy)
                if xx == 0 and yy == 0 then
                    _G.state.map.buildingheightmap[ccx][ccy][xxx][yyy] = 0
                else
                    _G.state.map.buildingheightmap[ccx][ccy][xxx][yyy] = 0
                end
            end
        end
    end
    _G.state.map.shadowmap[cx][cy][x][y] = 0
end

return Tree
