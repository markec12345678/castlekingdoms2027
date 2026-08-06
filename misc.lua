local IsoX, IsoY = _G.IsoX, _G.IsoY
local tileWidth, tileHeight = _G.tileWidth, _G.tileHeight
local loveframes = require("libraries.loveframes")
local camera = require("objects.Controllers.CameraController")
local easingFunctions = require("libraries.easing")

function ScreenToIsoX(globalX, globalY)
    return (((globalX - IsoX) / (tileWidth / 2)) + ((globalY - IsoY) / (tileHeight / 2))) / 2
end

function ScreenToIsoY(globalX, globalY)
    return (((globalY - IsoY) / (tileHeight / 2)) - ((globalX - IsoX) / (tileWidth / 2))) / 2
end

function _G.IsoToScreenX(xx, yy)
    return IsoX + ((xx - yy) * tileWidth / 2)
end

function _G.IsoToScreenY(xx, yy)
    return IsoY + ((xx + yy) * tileHeight / 2)
end

function _G.ogIsoToScreenX(xx, yy)
    return ((xx - yy) * tileWidth / 2)
end

function _G.ogIsoToScreenY(xx, yy)
    return ((xx + yy) * tileHeight / 2)
end

function _G.isChunkCoordinateInsideMap(cx, cy)
    return (cx >= 0) and (cy >= 0) and (cx < _G.chunksWide) and (cy < _G.chunksWide)
end

function _G.isGlobalCoordInsideMap(gx, gy)
    local cx, cy, _x, _y = _G.getLocalCoordinatesFromGlobal(gx, gy)
    return _G.isChunkCoordinateInsideMap(cx, cy)
end

function _G.getLocalCoordinatesFromGlobal(gx, gy)
    local cx = math.floor(gx / _G.chunkWidth)
    local cy = math.floor(gy / _G.chunkWidth)
    local x = math.floor(gx % _G.chunkWidth)
    local y = math.floor(gy % _G.chunkWidth)
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
            t[i] = nil
        end
    end
    return t
end

function _G.removeFromProjectilesArray(t, fnKeep)
    local j, n = 1, #t
    for i = 1, n do
        if (fnKeep(t, i, j)) then
            if (i ~= j) then
                t[j] = t[i]
                t[i] = nil
            end
            j = j + 1
        else
            t[i] = nil
        end
    end
    return t
end

function _G.removeFromObjectsArray(t, fnKeep)
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

local startScale = 1
local targetScale = 1
local easeTimer = 0

local function update()
    if startScale ~= targetScale then
        easeTimer = easeTimer + love.timer.getDelta()
        if easeTimer > 0.2 then
            easeTimer = 0.2
            startScale = targetScale
        end
        _G.state.scaleX = easingFunctions.outCubic(easeTimer, startScale, targetScale - startScale, 0.2)
    end
    ---------------------------------------
    local CenterX, CenterY
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
    _G.xchunk = math.floor(CenterX / (_G.chunkWidth))
    _G.ychunk = math.floor(CenterY / (_G.chunkWidth))
    local GX, GY = _G.getTerrainTileOnMouse(-50, -50)
    _G.state.topLeftChunkX = math.floor(GX / _G.chunkWidth)
    _G.state.topLeftChunkY = math.floor(GY / _G.chunkWidth)
    GX, GY = _G.getTerrainTileOnMouse(love.graphics.getWidth() + 50, love.graphics.getHeight() + 50)
    _G.state.bottomRightChunkX = math.floor(GX / _G.chunkWidth)
    _G.state.bottomRightChunkY = math.floor(GY / _G.chunkWidth)
    _G.currentChunkX = _G.xchunk
    _G.currentChunkY = _G.ychunk
    camera.handleCamera()
end

function _G.manhattanDistance(x1, y1, x2, y2)
    local dx = math.abs(x1 - x2)
    local dy = math.abs(y1 - y2)
    return (dx + dy)
end

local scrollOnceMore = false

local function scale(y)
    if scrollOnceMore then
        scrollOnceMore = false
        return
    end
    startScale = _G.state.scaleX
    if y > 0 and _G.state.scaleX < 4 then
        easeTimer = 0
        if _G.state.scaleX >= 1 then
            targetScale = _G.state.scaleX + 0.25 * math.abs(y)
        elseif _G.state.scaleX >= 2 then
            targetScale = _G.state.scaleX + 0.5 * math.abs(y)
        elseif _G.state.scaleX >= 3 then
            targetScale = _G.state.scaleX + 1 * math.abs(y)
        else
            targetScale = math.min(_G.state.scaleX + 0.1 * math.abs(y), 1)
        end
        if targetScale > 4 then
            targetScale = 4
        end
    elseif y < 0 and _G.state.scaleX > 0.3 then
        easeTimer = 0
        if _G.state.scaleX == 1 then
            targetScale = _G.state.scaleX - 0.25 * math.abs(y)
        elseif _G.state.scaleX > 1 then
            targetScale = math.max(_G.state.scaleX - 0.5 * math.abs(y), 1)
        elseif _G.state.scaleX >= 2 then
            targetScale = math.max(_G.state.scaleX - 0.5 * math.abs(y), 1)
        elseif _G.state.scaleX >= 3 then
            targetScale = math.max(_G.state.scaleX - 1 * math.abs(y), 1)
        else
            targetScale = _G.state.scaleX - 0.1 * math.abs(y)
        end
        if targetScale < 0.3 then
            targetScale = 0.3
        end
    end
    if targetScale == 1 and math.abs(startScale - targetScale) < 0.4 then
        scrollOnceMore = true
    end
    love.audio.setPosition((_G.state.viewXview) / 100, (_G.state.viewYview) / 100, camera.getZFromZoom())
end

local function draw()
    if _G.MissionStart then
        _G.MissionController:Display()
    end
    if _G.speedModifier ~= 1 then
        love.graphics.print("Speed Modifier: " .. tostring(_G.speedModifier) .. "x", 10,
            10)
    end
    love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 10,
        love.graphics.getHeight() - 30)
    love.graphics.print(tostring(_G.TimeController:getCurrentMonth()) .. " " .. tostring(_G.TimeController:getCurrentYear()), loveframes.font_times_new_normal_large_48,
        (love.graphics.getWidth() / 2) -
        60, 10, 0, 1, 1)
    love.graphics.print(
        tostring(_G.MissionController.goalsList), loveframes.font_times_new_normal_large,
        (love.graphics.getWidth() / 2) +
        (love.graphics.getWidth() / 2) - 300, 10, 0, 1, 1)
end

local tableOfFunctions = {
    update = update,
    scale = scale,
    draw = draw
}
return tableOfFunctions
