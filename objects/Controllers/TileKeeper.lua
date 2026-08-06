-- This class keeps track of the terrain tiles vertices
-- since 0.7, vertices can shift within the buffer
-- and when that shift happens we need to update the tile
-- to take into account it's newly assigned vertex id (onVertChange)
-- There's 2 tilekeeper instances per chunk, one for tiles and one for cliffs
local TileKeeper = _G.class("TileKeeper")
function TileKeeper:initialize(chunkX, chunkY, vertexKeeper)
    self.cx, self.cy = chunkX, chunkY
    self.vertexKeeper = vertexKeeper
    self.vertToData = {}
    self.tileVertices = {}
    for i = 0, _G.chunkWidth - 1, 1 do
        self.tileVertices[i] = {}
        for o = 0, _G.chunkWidth - 1, 1 do
            self.tileVertices[i][o] = nil
        end
    end
end

function TileKeeper:onVertChange(oldVert, newVert)
    local data = self.vertToData[oldVert]
    if not data then
        print(love.timer.getDelta(), self.typ)
        return
    end
    local localX, localY = data[1], data[2]
    local instancemesh = _G.state.objectMesh[self.cx][self.cy]
    local x, y, z, qx, qy, qw, qh, sv, sx, pl = instancemesh:getVertex(oldVert)
    instancemesh:setVertex(newVert, x, y, z, qx, qy, qw, qh, sv, sx, pl)
    instancemesh:setVertex(oldVert)
    self.vertToData[newVert] = self.vertToData[oldVert]
    self.vertToData[oldVert] = nil
    self.tileVertices[localX][localY] = newVert
end

function TileKeeper:getTerrainVert(x, y)
    local cx, cy = self.cx, self.cy
    if self.tileVertices[x][y] then
        return self.tileVertices[x][y]
    end
    self.tileVertices[x][y] = self.vertexKeeper:allocate(self)
    self.vertToData[self.tileVertices[x][y]] = { x, y }
    return self.tileVertices[x][y]
end

function TileKeeper:free(vertId)
    local cx, cy = self.cx, self.cy
    local data = self.vertToData[vertId]
    if not data then
        return
    end
    self.vertexKeeper:free(vertId)
    _G.state.objectMesh[cx][cy]:setVertex(vertId)
    local x, y = data[1], data[2]
    self.vertToData[vertId] = nil
    self.tileVertices[x][y] = nil
end

return TileKeeper
