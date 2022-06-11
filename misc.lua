local IsoX, IsoY = _G.IsoX, _G.IsoY
local tileWidth, tileHeight = _G.tileWidth, _G.tileHeight
require("libraries.CameraHandler")

function ScreenToIsoX(globalX, globalY)
    return (((globalX - IsoX) / (tileWidth / 2)) + ((globalY - IsoY) / (tileHeight / 2))) / 2;
end

function ScreenToIsoY(globalX, globalY)
    return (((globalY - IsoY) / (tileHeight / 2)) - ((globalX - IsoX) / (tileWidth / 2))) / 2;
end

function _G.IsoToScreenX(xx, yy)
    return IsoX + ((xx - yy) * tileWidth / 2);
end

function _G.IsoToScreenY(xx, yy)
    return IsoY + ((xx + yy) * tileHeight / 2);
end

function _G.ogIsoToScreenX(xx, yy)
    return ((xx - yy) * tileWidth / 2);
end

function _G.ogIsoToScreenY(xx, yy)
    return ((xx + yy) * tileHeight / 2);
end

function _G.getLocalCoordinatesFromGlobal(gx, gy)
    local cx = math.floor(gx / _G.chunkWidth)
    local cy = math.floor(gy / _G.chunkWidth)
    local x = gx % _G.chunkWidth
    local y = gy % _G.chunkWidth
    return cx, cy, x, y
end

function _G.math.round(x, deci)
    -- deci = 10 ^ (deci or 0)
    -- return math.floor(n * deci + .5) / deci
    return x >= 0 and math.floor(x + 0.5) or math.ceil(x - 0.5)
end

-- use this instead of table.remove for arrays
function _G.arrayRemove(t, fnKeep)
    local j, n = 1, #t
    for i = 1, n do
        if (fnKeep(t, i, j)) then
            if (i ~= j) then
                t[j] = t[i]
                t[i] = nil
            end
            j = j + 1
        else
            _G.removeObjectAt(t[i].cx, t[i].cy, t[i].i, t[i].o, t[i])
            t[i] = nil
        end
    end
    return t
end



local function update()
    ---------------------------------------
    local defMX, defMY = love.mouse.getPosition();
    mx = (defMX - 16 - _G.ScreenWidth / 2) / _G.state.scaleX + _G.state.viewXview
    my = (defMY - 8 - _G.ScreenHeight / 2) / _G.state.scaleX + _G.state.viewYview
    LocalX = math.round(ScreenToIsoX(mx, my))
    LocalY = math.round(ScreenToIsoY(mx, my))
    CenterX = math.round(ScreenToIsoX(_G.state.viewXview, _G.state.viewYview))
    CenterY = math.round(ScreenToIsoY(_G.state.viewXview, _G.state.viewYview))

    -- Used for culling animations
    local TX, TY = 0, 0
    TX = (TX - _G.ScreenWidth / 2) / _G.state.scaleX + _G.state.viewXview - 16
    TY = (TY - _G.ScreenHeight / 2) / _G.state.scaleX + _G.state.viewYview - 8
    _G.TopLeftX = TX
    _G.TopLeftY = TY

    local BX, BY = love.graphics.getWidth(), love.graphics.getHeight() + 100
    BX = (BX - _G.ScreenWidth / 2) / _G.state.scaleX + _G.state.viewXview - 16
    BY = (BY - _G.ScreenHeight / 2) / _G.state.scaleX + _G.state.viewYview - 8
    _G.BottomRightX = BX
    _G.BottomRightY = BY

    ---------------------------------------
    _G.xchunk = math.floor(CenterX / (_G.chunkWidth));
    _G.ychunk = math.floor(CenterY / (_G.chunkWidth));
    local GX, GY = _G.getTerrainTileOnMouse(-50, -50)
    _G.state.topLeftChunkX = math.floor(GX / _G.chunkWidth)
    _G.state.topLeftChunkY = math.floor(GY / _G.chunkWidth)
    GX, GY = _G.getTerrainTileOnMouse(love.graphics.getWidth() + 50, love.graphics.getHeight() + 50)
    _G.state.bottomRightChunkX = math.floor(GX / _G.chunkWidth)
    _G.state.bottomRightChunkY = math.floor(GY / _G.chunkWidth)
    _G.currentChunkX = _G.xchunk;
    _G.currentChunkY = _G.ychunk;
    handleCamera()
end

function _G.manhattanDistance(x1, y1, x2, y2)
    local dx = math.abs(x1 - x2)
    local dy = math.abs(y1 - y2)
    return (dx + dy)
end

local function scale(y)
    if y > 0 and _G.state.scaleX < 4 then
        _G.state.scaleX = _G.state.scaleX + 0.1;
    elseif y < 0 and _G.state.scaleX > 0.3 then
        _G.state.scaleX = _G.state.scaleX - 0.1;
    end
    love.audio.setPosition((_G.state.viewXview) / 100, (_G.state.viewYview) / 100, getZFromZoom())
end

local function draw()
    local gx, gy = LocalX, LocalY
    local prevI = (gx - 1) % (chunkWidth)
    local prevO = (gy + 1) % (chunkWidth)
    local prevCx = math.floor((gx - 1) / chunkWidth)
    local prevCy = math.floor((gy + 1) / chunkWidth)

    local prevShadow, prevHeight, prevHeight_2, prevTileheight = 0, 0, 0, 0
    if _G.state.map.terrain[prevCx] and _G.state.map.terrain[prevCx][prevCy] then
        prevHeight = _G.state.map.heightmap[prevCx][prevCy][prevI][prevO] or 0
        prevHeight_2 = 75 * prevHeight / (40 + prevHeight)
        prevShadow = _G.shadowmap[prevCx][prevCy][prevI][prevO] or 0
        prevTileheight = _G.buildingheightmap[prevCx][prevCy][prevI][prevO] or 0
    end
    mx, my = love.mouse.getPosition()
    love.graphics.print("FPS: " .. tostring(love.timer.getFPS()) .. "\nMax FPS: " .. tostring(_G.previousFrameTime), 10,
        love.graphics.getHeight() - 40)
end

local tableOfFunctions = {
    update = update,
    scale = scale,
    draw = draw
}
return tableOfFunctions
