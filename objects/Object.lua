---@class Object
---@field parent Object|nil
---@field class {name: string, WIDTH: integer, HEIGHT: integer, LENGTH: integer, DESTRUCTIBLE: boolean, HOVERTEXT: string, unserializable: boolean}
---@field cx integer chunk x position
---@field cy integer chunk y position
---@field i integer local to chunk x position
---@field o integer local to chunk y position
---@field id integer unique identifier of the instance
---@field static table static class table
---@field tile userdata the tile quad if the object is a static building
---@field offsetY number Y offset of the sprite
---@field offsetX number X offset of the sprite
---@field deserialize fun(object:table, data:table)
local Object = _G.class("Object")
local chunkWidth, tileWidth = _G.chunkWidth, _G.tileWidth
local chunkHeight, tileHeight = _G.chunkHeight, _G.tileHeight

function Object:initialize(gx, gy, type)
    self.i = (gx) % (chunkWidth)
    self.o = (gy) % (chunkWidth)
    self.cx = math.floor(gx / chunkWidth)
    self.cy = math.floor(gy / chunkWidth)
    self.x = _G.IsoX + (self.i - self.o) * tileWidth * 0.5
    self.y = _G.IsoY + (self.i + self.o) * tileHeight * 0.5
    self.gx = gx
    self.gy = gy
    self.type = type
    self.toBeDeleted = false
    self:calculateShadowValue()
end

function Object:registerAsActiveEntity()
    table.insert(_G.state.activeEntities, self)
end

function Object:isVisibleOnScreen()
    if not
        (self.x + (self.cx - self.cy) * chunkWidth * tileWidth * 0.5 < _G.TopLeftX or self.x + (self.cx - self.cy) *
            chunkWidth * tileWidth * 0.5 > _G.BottomRightX or
            self.y + (self.cx + self.cy) * chunkHeight * tileHeight * 0.5 <
            _G.TopLeftY or self.y + (self.cx + self.cy) * chunkHeight * tileHeight * 0.5 > _G.BottomRightY) then
        return true
    end
    return false
end

function Object:update()
end

function Object:render()
    if self.toBeDeleted then return end
    if self.vertId then
        return self:updateVertex()
    end
    if _G.state.objectMesh then
        local offsetX, offsetY = 0, 0
        if _G.quadOffset[self.tile] then
            offsetX, offsetY = _G.quadOffset[self.tile][1] or 0, _G.quadOffset[self.tile][2] or 0
        end
        local elevationOffsetY = 0
        if _G.state.map.heightmap[self.cx][self.cy][self.i][self.o] then
            elevationOffsetY = _G.state.map.heightmap[self.cx][self.cy][self.i][self.o] * 2
        end
        local x, y = self.x + (self.offsetX or 0) + offsetX, self.y + (self.offsetY or 0) + offsetY - elevationOffsetY
        local qx, qy, qw, qh = self.tile:getViewport()

        local newVert = _G.getFreeVertexFromTile(self.cx, self.cy, self.i, self.o, true)
        if newVert ~= false then
            self.vertId = newVert
            self.lastI, self.lastO = self.i, self.o
        else
            error("Object did not receive Vertex for rendering, it should be of highest priority:" ..
                tostring(self) .. "\n coordinates: " .. tostring(self.gx) .. ", " .. tostring(self.gy))
        end
        self.instancemesh = _G.state.objectMesh[self.cx][self.cy]
        if (not self.instancemesh) then
            error("Object haveno instance mesh " ..
                tostring(self) .. "\n coordinates: " .. tostring(self.gx) .. ", " .. tostring(self.gy))
        end

        self.instancemesh:setVertex(self.vertId, x, y, qx, qy, qw, qh, self.shadowValue)
    end
end

function Object:renderAlias()
    if self.vertId then
        return self:updateVertex()
    end
    if _G.state.objectMesh then
        local offsetX, offsetY = 0, 0
        if _G.quadOffset[self.tile] then
            offsetX, offsetY = _G.quadOffset[self.tile][1] or 0, _G.quadOffset[self.tile][2] or 0
        end
        local elevationOffsetY = 0
        if _G.state.map.heightmap[self.cx][self.cy][self.i][self.o] then
            elevationOffsetY = _G.state.map.heightmap[self.cx][self.cy][self.i][self.o] * 2
        end
        local x, y = self.x + (self.offsetX or 0) + offsetX, self.y + (self.offsetY or 0) + offsetY - elevationOffsetY
        local qx, qy, qw, qh = self.tile:getViewport()
        local cx, cy, xx, yy = _G.getLocalCoordinatesFromGlobal(self.gx - 1, self.gy - 1)
        local newVert = _G.getFreeVertexFromTile(cx, cy, xx, yy, true)
        if newVert ~= false then
            self.vertId = newVert
            self.lastI, self.lastO = self.i, self.o
        else
            print("Object did not receive Vertex for rendering, it should be of highest priority")
            return
        end
        self.instancemesh = _G.state.objectMesh[self.cx][self.cy]
        self.instancemesh:setVertex(self.vertId, x, y, qx, qy, qw, qh, self.shadowValue)
    end
end

function Object:destroy()
    if self.vertId then
        _G.freeVertexFromTile(self.cx, self.cy, self.vertId)
    end
    _G.removeObjectAt(self.cx, self.cy, self.i, self.o, self)
    _G.state.chunkObjects[self.cx][self.cy][self] = nil
    self.toBeDeleted = true
end

function Object:updateVertex()
    if _G.state.objectMesh and self.tile then
        local offsetX, offsetY = 0, 0
        if _G.quadOffset[self.tile] then
            offsetX, offsetY = _G.quadOffset[self.tile][1] or 0, _G.quadOffset[self.tile][2] or 0
        end
        local elevationOffsetY = 0
        if _G.state.map.heightmap[self.cx][self.cy][self.i][self.o] then
            elevationOffsetY = _G.state.map.heightmap[self.cx][self.cy][self.i][self.o] * 2
        end
        local x, y = self.x + (self.offsetX or 0) + offsetX, self.y + (self.offsetY or 0) + offsetY - elevationOffsetY
        local qx, qy, qw, qh = self.tile:getViewport()
        self.instancemesh = _G.state.objectMesh[self.cx][self.cy]
        self.instancemesh:setVertex(self.vertId, x, y, qx, qy, qw, qh, self.shadowValue)
    end
end

function Object:calculateShadowValue()
    local cx, cy, i, o = self.cx, self.cy, self.i, self.o
    local elevationOffsetY = _G.state.map.heightmap[cx][cy][i][o] or 0
    local elevationValue = 75 * elevationOffsetY / (40 + elevationOffsetY)
    local shadowValue = _G.state.map.shadowmap[cx][cy][i][o] or 0
    local isInShadow = shadowValue > elevationOffsetY or shadowValue > elevationValue
    if isInShadow then
        self.shadowValue = math.min((shadowValue - elevationValue) / 40, 0.6)
        self.shadowValue = math.max(0.8, 1 - self.shadowValue)
    else
        self.shadowValue = 1
    end
end

function Object:shadeFromTerrain()
    self:calculateShadowValue()
    if self.tile then
        self:updateVertex()
    end
end

function Object:serialize()
    local data = {}
    data.id = self.id
    data.i = self.i
    data.o = self.o
    data.cx = self.cx
    data.cy = self.cy
    data.x = self.x
    data.y = self.y
    data.gx = self.gx
    data.gy = self.gy
    data.type = self.type
    data.shadowValue = self.shadowValue
    data.toBeDeleted = self.toBeDeleted
    data.className = self.class.name
    if self.class.unserializable then
        return {}
    end
    if data.className ~= "ApothecaryAlias" and
        data.className ~= "ArcheryTargetAlias" and
        data.className ~= "ArmorerAlias" and
        data.className ~= "ArmouryAlias" and
        data.className ~= "BakeryAlias" and
        data.className ~= "BarracksAlias" and
        data.className ~= "BigResidenceAlias" and
        data.className ~= "BlacksmithAlias" and
        data.className ~= "BreweryAlias" and
        data.className ~= "CampfireAlias" and
        data.className ~= "CathedralAlias" and
        data.className ~= "ChapelAlias" and
        data.className ~= "ChurchAlias" and
        data.className ~= "DairyFarmAlias" and
        data.className ~= "DefenseTowerAlias" and
        data.className ~= "EngineersGuildAlias" and
        data.className ~= "FlatAlias" and
        data.className ~= "FletcherAlias" and
        data.className ~= "GranaryAlias" and
        data.className ~= "HopsFarmAlias" and
        data.className ~= "HouseAlias" and
        data.className ~= "InnAlias" and
        data.className ~= "LargeGardenAlias" and
        data.className ~= "LargePondAlias" and
        data.className ~= "MarketAlias" and
        data.className ~= "MaypoleAlias" and
        data.className ~= "MediumGardenAlias" and
        data.className ~= "MeleeTargetAlias" and
        data.className ~= "MineAlias" and
        data.className ~= "OrchardAlias" and
        data.className ~= "OxTetherAlias" and
        data.className ~= "PerimeterTowerAlias" and
        data.className ~= "PoleturnerAlias" and
        data.className ~= "PitchRigAlias" and
        data.className ~= "QuarryAlias" and
        data.className ~= "ResidenceAlias" and
        data.className ~= "RoundTowerAlias" and
        data.className ~= "SmallGardenAlias" and
        data.className ~= "SmallPondAlias" and
        data.className ~= "SquareTowerAlias" and
        data.className ~= "StockpileAlias" and
        data.className ~= "StoneBarracksAlias" and
        data.className ~= "StoneGateEastAlias" and
        data.className ~= "StoneGateEastAlias" and
        data.className ~= "StoneGateEastBigAlias" and
        data.className ~= "StoneGateSouthBigAlias" and
        data.className ~= "TunnelersGuildAlias" and
        data.className ~= "WheatFarmAlias" and
        data.className ~= "WoodPoleAlias" and
        data.className ~= "WoodcutterHutAlias" and
        data.className ~= "WoodenDefenseTowerAlias" and
        data.className ~= "WoodenGateAlias" and
        data.className ~= "WoodenGateEastBigAlias" and
        data.className ~= "WoodenGateSouthBigAlias" and
        data.className ~= "WoodenPerimeterTowerAlias" and
        data.className ~= "WoodenTowerAlias" and
        string.find(data.className or tostring(self.class), "Alias") then
        return {}
    end
    return data
end

function Object.static.deserialize(self, load)
    for k, v in pairs(load) do
        if k ~= "id" then
            self[k] = v
        end
    end
end

return Object
