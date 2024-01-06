local Object = require("objects.Object")

---@class Structure : Object
---@field animation table
---@field animated boolean
---@field onClick function onClick function, if declared will enable hovertext tooltip
---@field tile userdata
local Structure = _G.class("Structure", Object)
function Structure:initialize(gx, gy, type)
    Object.initialize(self, gx, gy, type)
    self.sleeping = false
    self.restoreExitPoint = false
    _G.addObjectAt(self.cx, self.cy, self.i, self.o, self)
end

---@param self Object|Structure
function Structure:destroy()
    Object.destroy(self)
end

function Structure:getAverageShadowValue()
    local parent = self.parent
    local gx, gy
    local width = self.class.WIDTH
    local length = self.class.LENGTH
    if parent then
        if parent["_ref"] then
            parent = _G.state:dereferenceObject(parent)
        end
        gx, gy = parent.gx, parent.gy
        width, length = parent.class.WIDTH, parent.class.LENGTH
    else
        gx, gy = self.gx, self.gy
    end
    if width and length then
        local totalShadow = 0
        local count = 0
        for x = 0, width do
            for y = 0, length do
                local cx, cy, i, o = _G.getLocalCoordinatesFromGlobal(gx + x, gy + y)
                count = count + 1
                totalShadow = totalShadow + (_G.state.map.shadowmap[cx][cy][i][o] or 0)
            end
        end
        return totalShadow / count
    end
    return 0
end

function Structure:calculateShadowValue()
    local cx, cy, i, o
    local parent = self.parent
    if parent and parent["_ref"] then
        parent = _G.state:dereferenceObject(parent)
    end
    local thisTileheight = self.class.HEIGHT or (parent and parent.class.HEIGHT) or 0
    if parent then
        cx, cy, i, o = parent.cx, parent.cy, parent.i, parent.o
    else
        cx, cy, i, o = self.cx, self.cy, self.i, self.o
    end
    local elevationOffsetY = _G.state.map.heightmap[cx][cy][i][o] or 0
    local elevationValue = 75 * elevationOffsetY / (40 + elevationOffsetY)
    local shadowValue = self:getAverageShadowValue()

    if shadowValue < thisTileheight * 0.8 + elevationValue then
        self.shadowValue = 1
    else
        shadowValue = math.min((shadowValue - elevationValue - thisTileheight) / 40, 0.6)
        self.shadowValue = math.min(0.825, 1 - shadowValue)
    end
end

function Structure:shadeFromTerrainSingleTile()
    Object.calculateShadowValue(self)
    if self.tile then
        self:render()
    elseif self.animation then
        self:animate(_G.dt, true)
    end
end

function Structure:shadeFromTerrain()
    self:calculateShadowValue()
    if self.tile then
        self:render()
    elseif self.animation then
        self:animate(_G.dt, true)
    end
end

function Structure:animate(dt, forceUpdate)
    dt = dt or _G.dt
    if not self.animation or not self.animated then
        return
    end
    local updated = self.animation:update(dt) or forceUpdate
    -- animation might have called a callback and deleted itself
    if not self.animation or not self.animated then
        return
    end
    if not self.instancemesh and _G.state.objectMesh then
        local offsetX, offsetY = 0, 0
        if _G.quadOffset[self.animation:getQuad()] then
            offsetX, offsetY = _G.quadOffset[self.animation:getQuad()][1] or 0,
                _G.quadOffset[self.animation:getQuad()][2] or 0
        end
        local instancemesh = _G.state.objectMesh[self.cx][self.cy]
        local quad, x, y, _, _, _, _, _, _, _ = self.animation:getFrameInfo(self.x + (self.offsetX or 0) + offsetX,
            self.y + (self.offsetY or 0) + offsetY - _G.state.map.walkingHeightmap[self.gx][self.gy])
        if not quad then return end
        local elevationOffsetY = 0
        if _G.state.map.heightmap[self.cx][self.cy][self.i][self.o] then
            elevationOffsetY = _G.state.map.heightmap[self.cx][self.cy][self.i][self.o] * 2
        end
        y = y - elevationOffsetY
        local qx, qy, qw, qh = quad:getViewport()
        self.vertId = _G.getFreeVertexFromTile(self.cx, self.cy, self.i, self.o)
        if self.vertId then
            self.instancemesh = instancemesh
            self.instancemesh:setVertex(self.vertId, x, y, qx, qy, qw, qh, self.shadowValue)
        end
        return
    end
    if self.instancemesh and updated then
        local offsetX, offsetY = 0, 0
        if _G.quadOffset[self.animation:getQuad()] then
            offsetX, offsetY = _G.quadOffset[self.animation:getQuad()][1] or 0,
                _G.quadOffset[self.animation:getQuad()][2] or 0
        end
        local quad, x, y, _, _, _, _, _, _, _ = self.animation:getFrameInfo(self.x + (self.offsetX or 0) + offsetX,
            self.y + (self.offsetY or 0) + offsetY - _G.state.map.walkingHeightmap[self.gx][self.gy])
        local elevationOffsetY = 0
        if _G.state.map.heightmap[self.cx][self.cy][self.i][self.o] then
            elevationOffsetY = _G.state.map.heightmap[self.cx][self.cy][self.i][self.o] * 2
        end
        y = y - elevationOffsetY
        if quad then
            local qx, qy, qw, qh = quad:getViewport()
            self.instancemesh:setVertex(self.vertId, x, y, qx, qy, qw, qh, self.shadowValue)
        end
        return
    end
end

function Structure:serialize()
    local data = {}
    if self.float then
        data.float = _G.state:serializeObject(self.float)
    end
    local objectData = Object.serialize(self)
    for k, v in pairs(objectData) do
        if type(v) ~= "function" and type(v) ~= "userdata" and k ~= "float" then
            data[k] = v
        end
    end
    if data.className then
        data.sleeping = self.sleeping
        data.restoreExitPoint = self.restoreExitPoint
    end
    return data
end

function Structure:respawnWorker(worker, state)
    worker.state = state
    worker.animated = true
    worker.gx = self.spawnpointGX
    worker.gy = self.spawnpointGY
    worker.fx = worker.gx * 1000 + 500
    worker.fy = worker.gy * 1000 + 500
    local cx, cy, i, o
    i = (worker.gx) % (_G.chunkWidth)
    o = (worker.gy) % (_G.chunkWidth)
    cx = math.floor(worker.gx / _G.chunkWidth)
    cy = math.floor(worker.gy / _G.chunkWidth)
    worker.locationsCx = { cx }
    worker.locationsCy = { cy }
    worker.locationsI = { i }
    worker.locationsO = { o }
    _G.addObjectAt(cx, cy, i, o, worker)
    worker.needNewVertAsap = true
end

function Structure:findExitPointTo(structure, foundCallback)
    local entryPoints = {}
    if structure == "Stockpile" then
        for _, v in ipairs(_G.stockpile.nodeList) do
            entryPoints[#entryPoints + 1] = { x = v.gx, y = v.gy }
        end
        if not next(entryPoints) then
            -- TODO: Stockpile is unreachable, do something about it!
            foundCallback(false)
            return
        end
    elseif structure == "Granary" then
        for _, v in ipairs(_G.foodpile.nodeList) do
            entryPoints[#entryPoints + 1] = { x = v.gx, y = v.gy }
        end
        if not next(entryPoints) then
            -- TODO: Granary is unreachable, do something about it!
            foundCallback(false)
            return
        end
    elseif structure == "Armoury" then
        for _, v in ipairs(_G.weaponpile.nodeList) do
            entryPoints[#entryPoints + 1] = { x = v.gx, y = v.gy }
        end
        if not next(entryPoints) then
            -- TODO: Granary is unreachable, do something about it!
            foundCallback(false)
            return
        end
    else
        entryPoints = structure:getEntryPoints()
    end
    self.restoreExitPoint = true
    _G.finder:requestPathToMultipleGoalsWithWalkableTargetArea(
        self.gx + math.ceil(self.class.WIDTH / 2),
        self.gy + math.ceil(self.class.LENGTH / 2),
        entryPoints,
        self:getStructureAreaPoints(),
        function(path)
            if path then
                self:setSpawnPoint(path[1][1], path[1][2])
                foundCallback(true, path)
            else
                self:setSpawnPoint(-1, -1)
                foundCallback(false)
            end
            self.restoreExitPoint = false
        end
    )
end

---@private
function Structure:getStructureAreaPoints()
    local area = {}
    for x = 0, self.class.WIDTH - 1 do
        for y = 0, self.class.LENGTH - 1 do
            area[#area + 1] = { self.gx + x, self.gy + y }
        end
    end
    return area
end

function Structure:getEntryPoints()
    local endNodes = {}
    for x = -1, self.class.WIDTH do
        if x ~= -1 then
            if _G.state.map:isWalkable(x + self.gx, self.gy - 1) then
                endNodes[#endNodes + 1] = { x = x + self.gx, y = self.gy - 1 }
            end
        end
        if x ~= self.class.WIDTH then
            if _G.state.map:isWalkable(x + self.gx, self.gy + self.class.LENGTH) then
                endNodes[#endNodes + 1] = { x = x + self.gx, y = self.gy + self.class.LENGTH }
            end
        end
    end
    for y = -1, self.class.LENGTH do
        if y ~= -1 then
            if _G.state.map:isWalkable(self.gx - 1, y + self.gy) then
                endNodes[#endNodes + 1] = { x = self.gx - 1, y = y + self.gy }
            end
        end
        if y ~= self.class.LENGTH then
            if _G.state.map:isWalkable(self.gx + self.class.WIDTH, y + self.gy) then
                endNodes[#endNodes + 1] = { x = self.gx + self.class.WIDTH, y = y + self.gy }
            end
        end
    end
    return endNodes
end

function Structure:shadeWithAliases()
    for xx = 0, self.class.WIDTH - 1 do
        for yy = 0, self.class.LENGTH - 1 do
            local buildingX = self.gx + xx
            local buildingY = self.gy + yy
            local buildings = _G.allObjectsFromSubclassAtGlobal(buildingX, buildingY, Object)
            for i, v in ipairs(buildings) do
                if v.parent == self and v.tile then
                    v.shadowValue = self.shadowValue
                    v:render()
                end
            end
        end
    end
end

function Structure:setSpawnPoint(gx, gy)
    self.spawnpointGX, self.spawnpointGY = gx, gy
end

function Structure:applyBuildingHeightMap(skipNoneBiome, skipWalkable)
    for xx = 0, self.class.WIDTH - 1 do
        for yy = 0, self.class.LENGTH - 1 do
            local buildingX = self.gx + xx
            local buildingY = self.gy + yy
            if not skipNoneBiome then
                _G.terrainSetTileAt(buildingX, buildingY, _G.terrainBiome.none)
            end
            local ccx, ccy, xxx, yyy = _G.getLocalCoordinatesFromGlobal(buildingX, buildingY)
            _G.state.map.buildingheightmap[ccx][ccy][xxx][yyy] = self.class.HEIGHT
            if not skipWalkable then
                _G.state.map:setWalkable(buildingX, buildingY, 1)
            end
        end
    end
    self:shadeFromTerrain()
    self:render()
end

function Structure:load(data)
    Object.initialize(self, data.gx, data.gy, data.type)
    if data.float then
        self.float = _G.state:dereferenceObject(data.float)
        data.float = nil
    end
end

return Structure
