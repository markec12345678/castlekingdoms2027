local config = require("config_file")

math.randomseed(os.time())
math.random()
math.random()
math.random()
_G.OPTIONS = {
    SFX_VOLUME = config.sound.effects / 100,
    SPEECH_VOLUME = config.sound.speech / 100,
    MUSIC_VOLUME = config.sound.music / 100
}

_G.version = "0.5.0-dev"
_G.classes = {}
_G.anim = require("libraries.anim8")
_G.class = require("libraries.middleclass").class
_G.inspect = require("libraries.inspect")
_G.ffi = require("ffi")
_G.PROF_CAPTURE = false
_G.prof = require("libraries.jprof")
_G.prof.connect()
_G.bus = require("libraries.eventbus")
-- Whether the game is currently paused
_G.paused = false
_G.MAX_FPS = 60
_G.CURRENT_PLAYLIST_INDEX = 0
_G.CURRENT_MUSIC = nil
_G.speedModifier = 1
_G.quadOffset = {}

function _G.reverse(t)
    local n = #t
    local i = 1
    while i < n do
        t[i], t[n] = t[n], t[i]
        i = i + 1
        n = n - 1
    end
    return t
end

function _G.getClassByName(className)
    return _G.classes[className]
end

function _G.indexBuildingQuads(quadString, trimLast, lastWidthOffset)
    local tileQuads = require("objects.object_quads")
    trimLast = trimLast or lastWidthOffset or false
    lastWidthOffset = lastWidthOffset or 0
    if trimLast and lastWidthOffset == 0 then
        lastWidthOffset = 8
    end
    -- NOTE: Probably wont work for non-square buildings
    local resultArray = {}
    local quad = tileQuads[quadString]
    local x, y, w, h = quad:getViewport()
    local totalTilesWide = math.ceil((w - lastWidthOffset) / _G.tileWidth)
    local middleCount = 0
    for i = 1, totalTilesWide - 1 do
        resultArray[#resultArray + 1] = love.graphics.newQuad(x + 16 * (i - 1), y, _G.tileWidth / 2, h, _G.imageW,
            _G.imageH)
        middleCount = i
    end
    resultArray[#resultArray + 1] = love.graphics.newQuad(x + 16 * (middleCount), y, _G.tileWidth, h, _G.imageW,
        _G.imageH)
    for i = middleCount + 2, middleCount + totalTilesWide do
        if trimLast and i == middleCount + totalTilesWide then
            resultArray[#resultArray + 1] = love.graphics.newQuad(x + 16 * (i), y, _G.tileWidth / 2 - lastWidthOffset,
                h, _G.imageW, _G.imageH)
        else
            resultArray[#resultArray + 1] = love.graphics.newQuad(x + 16 * (i), y, _G.tileWidth / 2, h, _G.imageW,
                _G.imageH)
        end
    end

    return totalTilesWide - 1, resultArray
end

function _G.indexQuads(string, endAmount, start, reverse)
    local tileQuads = require("objects.object_quads")
    start = start or 1
    local tempArray = {}
    for i = start, endAmount do
        tempArray[#tempArray + 1] = tileQuads[string .. " (" .. tostring(i) .. ")"]
    end
    if reverse then
        for i = 2, endAmount do
            tempArray[#tempArray + 1] = tileQuads[string .. " (" .. tostring(endAmount - i) .. ")"]
        end
    end
    return tempArray
end

function _G.addReverse(tempArray)
    local endAmount = #tempArray
    for i = endAmount, 2, -1 do
        tempArray[#tempArray + 1] = tempArray[i]
    end
    return tempArray
end

function _G.newAutotable(dim)
    local MT = {}
    for i = 1, dim do
        MT[i] = {
            __index = function(t, k)
                if i < dim then
                    t[k] = setmetatable({}, MT[i + 1])
                    return t[k]
                end
            end
        }
    end

    return setmetatable({}, MT[1])
end

----Tiles
function _G.getFreeVertexFromTile(cx, cy, localX, localY, lastVertexFirst)
    lastVertexFirst = lastVertexFirst or false
    local vertId = _G.state.verticesPerTile * (localX + localY * chunkWidth) + 1
    local chunkVertices = _G.state.objectMeshVertIdMap[cx][cy]
    if lastVertexFirst then
        for i = 3, _G.state.verticesPerTile - 1 do
            if not chunkVertices[vertId + i] then
                _G.state.objectMeshVertIdMap[cx][cy][vertId + i] = true
                return vertId + i
            end
        end
    else
        for i = _G.state.verticesPerTile - 1, 3, -1 do
            if not chunkVertices[vertId + i] then
                _G.state.objectMeshVertIdMap[cx][cy][vertId + i] = true
                return vertId + i
            end
        end
    end
    return false
end

function _G.getTerrainVertex(cx, cy, localX, localY)
    local vertId = _G.state.verticesPerTile * (localX + localY * chunkWidth) + 3
    _G.state.objectMeshVertIdMap[cx][cy][vertId] = true
    return vertId
end

function _G.getChevronVertexLeft(cx, cy, localX, localY)
    local vertId = _G.state.verticesPerTile * (localX + localY * chunkWidth) + 1
    _G.state.objectMeshVertIdMap[cx][cy][vertId] = true
    return vertId
end

function _G.getChevronVertexRight(cx, cy, localX, localY)
    local vertId = _G.state.verticesPerTile * (localX + localY * chunkWidth) + 2
    _G.state.objectMeshVertIdMap[cx][cy][vertId] = true
    return vertId
end

function _G.freeVertexFromTile(cx, cy, vertId)
    if not vertId then
        return
    end
    chunkVertices = _G.state.objectMeshVertIdMap[cx][cy]
    if chunkVertices then
        _G.state.objectMesh[cx][cy]:setVertex(vertId)
        chunkVertices[vertId] = false
    else
        return true
    end
end

_G.SAVEGAME_DIR = "saves"
_G.tileWidth = 32
_G.tileHeight = 16
_G.chunkWidth = 64
_G.chunkHeight = 64
-- UI
_G.TOOLTIP_DELAY = 0.1
-- Whether the game has loaded into the map
_G.loaded = false
----Chunks
_G.xchunk = 0
_G.ychunk = 0
_G.chunksWide = 8
_G.chunksHigh = 8
_G.currentChunkX = 0
_G.currentChunkY = 0
_G.CenterX = 0
_G.CenterY = 0
----Offset
_G.IsoX = 0
_G.IsoY = -1400
----View
_G.scrollSpeed = 700
_G.windowWidth, _G.windowHeight = love.window.getMode()
----Mouse
_G.mx = 0
_G.my = 0
_G.LocalX = 0
_G.LocalY = 0
----Version, title and window information
local _
_G.ScreenWidth, _G.ScreenHeight, _ = love.window.getMode()
----Pathfinding data structures
_G.channel = {}
_G.channel.request = love.thread.getChannel("request")
_G.channel.receive = love.thread.getChannel("receive")
_G.channel.mapUpdate = love.thread.getChannel("mapUpdate1")
_G.channel2 = {}
_G.channel2.mapUpdate = love.thread.getChannel("mapUpdate2")

function _G.string.startsWith(str, start)
    return str:sub(1, #start) == start
end

function _G.string.endsWith(str, ending)
    return ending == "" or str:sub(- #ending) == ending
end

--- Play a sound from the origin of an object.
--- @param obj table
--- @param sfx table
--- @param disallowMultipleSources? boolean Allow multiple effect so play simultaneously
function _G.playSfx(obj, sfx, disallowMultipleSources)
    if type(sfx) == "table" then
        sfx = sfx[math.random(#sfx)]
    end
    local _, volumeLimit = sfx:getVolumeLimits()
    if not disallowMultipleSources then
        sfx = sfx:clone()
    end
    sfx:setRelative(false)
    sfx:setPosition((obj.x + (obj.cx - obj.cy) * _G.chunkWidth * _G.tileWidth * 0.5) / 100,
        (obj.y + (obj.cx + obj.cy) * _G.chunkHeight * _G.tileHeight * 0.5) / 100, 4.1)
    sfx:setPitch(1 + love.math.random(-10, 10) / 100)
    sfx:play()
end

--- Play a sound through UI
--- @param sfx table
--- @param pitchNum? number
--- @param disallowMultipleSources? boolean Forbid multiple effect so play simultaneously
function _G.playInterfaceSfx(sfx, pitchNum, disallowMultipleSources)
    if type(sfx) == "table" then
        sfx = sfx[math.random(#sfx)]
    end
    local _, volumeLimit = sfx:getVolumeLimits()
    if not disallowMultipleSources then
        sfx = sfx:clone()
    end
    sfx:setVolume(_G.OPTIONS.SFX_VOLUME * volumeLimit)
    sfx:setPitch(pitchNum or (1 + love.math.random(-10, 10) / 100))
    sfx:setRelative(true)
    sfx:play()
end

function _G.playSpeech(speech)
    local speechFx = require("sounds.speech")
    local sfx = speechFx[speech]
    local _, volumeLimit = sfx:getVolumeLimits()
    sfx:setVolume(_G.OPTIONS.SPEECH_VOLUME * volumeLimit)
    sfx:setPitch(1 + love.math.random(-5, 5) / 100)
    sfx:play()
end

function _G.manualGc(timeBudget, safetynetMegabytes, disableOtherwise)
    local startTime = love.timer.getTime()
    while love.timer.getTime() - startTime < timeBudget do
        collectgarbage("step", 1)
    end
    -- safety net
    if safetynetMegabytes and collectgarbage("count") / 1024 > safetynetMegabytes then
        collectgarbage("collect")
    end
    -- don't collect gc outside this margin
    if disableOtherwise then
        collectgarbage("stop")
    end
end
