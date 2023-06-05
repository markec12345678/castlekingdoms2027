-- mocks for LÖVE functions
local unpack = _G.unpack or table.unpack

local font = {
    getAscent = function() return 10 end,
    getBaseline = function() return 10 end,
    getDPIScale = function() return 1 end,
    getDescent = function() return 10 end,
    getFilter = function() return end,
    getHeight = function() return 1000 end,
    getKerning = function() return end,
    getLineHeight = function() return 10 end,
    getWidth = function() return 2000 end,
    getWrap = function() return true end,
    hasGlyphs = function() return false end,
    setFallbacks = function(a, ...) return end,
    setFilter = function(a, b, c) return end,
    setLineHeight = function(x) return end,
    getDimensions = function() return 6000, 6000 end,
    setWrap = function() return end,
}

local Quadmt = {
    __eq = function(a, b)
        if #a ~= #b then
            return false
        end
        for i, v in ipairs(a) do
            if b[i] ~= v then
                return false
            end
        end
        return true
    end,
    __tostring = function(self)
        local buffer = {}
        for i, v in ipairs(self) do
            buffer[i] = tostring(v)
        end
        return "quad: {" .. table.concat(buffer, ",") .. "}"
    end,
    getViewport = function(self)
        return unpack(self)
    end
}

Quadmt.__index = Quadmt
love.graphics = {
    clear = function() end,
    draw = function() end,
    flushBatch = function() end,
    newQuad = function(...)
        return setmetatable({ ... }, Quadmt)
    end,
    newImage = function(filename)
        if type(filename) ~= "string" then error("love.graphics.newImage expects a string, but got a " .. filename) end
        local fileExists = love.filesystem.getInfo(filename)
        if not fileExists then error("trying to load file: " .. tostring(filename) .. " but it doesn't exist") end
        return font
    end,
    newShader = function() return {} end,
    newFont = function() return font end,
    newImageFont = function() return font end,
    getLastDrawq = function() end,
    setDefaultFilter = function() end,
    reset = function() end,
    push = function() end,
    translate = function() end,
    setBackgroundColor = function() end,
    pop = function() end,
    scale = function() end,
    isActive = function() return false end,
    newMesh = function()
        return {
            attachAttribute = function() end,
            detachAttribute = function() end,
            flush = function() end,
            getDrawMode = function() end,
            getDrawRange = function() end,
            getImage = function() end,
            getTexture = function() end,
            getVertex = function() end,
            getVertexAttribute = function() end,
            getVertexCount = function() end,
            getVertexFormat = function() end,
            getVertexMap = function() end,
            getVertices = function() end,
            hasVertexColors = function() end,
            isAttributeEnabled = function() end,
            setAttributeEnabled = function() end,
            setDrawMode = function() end,
            setDrawRange = function() end,
            setImage = function() end,
            setTexture = function() end,
            setVertex = function() end,
            setVertexAttribute = function() end,
            setVertexColors = function() end,
            setVertexMap = function() end,
            setVertices = function() end,
        }
    end,
    newSpriteBatch = function()
        return {
            add = function(a, b, c, d, e, f) end,
            attachAttribute = function(a, b, c, d, e, f) end,
            clear = function(a, b, c, d, e, f) end,
            flush = function(a, b, c, d, e, f) end,
            getBufferSize = function(a, b, c, d, e, f) end,
            getCount = function(a, b, c, d, e, f) end,
            getImage = function(a, b, c, d, e, f) end,
            getTexture = function(a, b, c, d, e, f) end,
            set = function(a, b, c, d, e, f) end,
            setColor = function(a, b, c, d, e, f) end,
            setImage = function(a, b, c, d, e, f) end,
            setTexture = function(a, b, c, d, e, f) end,
        }
    end,
    print = function() end,
    printf = function() end,
    getHeight = function() return 1920 end,
    getWidth = function() return 1080 end,
    getDimensions = function() return 1920, 1080 end,
}

love.window = {
    getMode = function() return 1920, 1080, true end,
    setFullscreen = function() return end,
    getFullscreenModes = function(a) return { { width = 1920, height = 1080 } } end
}

love.audio = {
    getActiveEffects = function() return {} end,
    getActiveSourceCount = function() return 0 end,
    getDistanceModel = function() return {} end,
    getDopplerScale = function() return 1 end,
    getEffect = function() end,
    getMaxSceneEffects = function() end,
    getMaxSourceEffects = function() end,
    getNumSources = function() end,
    getOrientation = function() end,
    getPosition = function() end,
    getRecordingDevices = function() return 0 end,
    getSourceCount = function() return 1 end,
    getVelocity = function() end,
    getVolume = function() return 100 end,
    isEffectsSupported = function() end,
    newQueueableSource = function() end,
    newSource = function()
        return {
            setVolumeLimits = function(a) end,
            getVolumeLimits = function(a) end,
            play = function() end,
            setRelative = function(a) end,
            setPosition = function(a) end,
            setPitch = function(a) end,
            setVolume = function(a) end,
        }
    end,
    pause = function() end,
    play = function() end,
    resume = function() end,
    rewind = function() end,
    setDistanceModel = function() end,
    setDopplerScale = function() end,
    setEffect = function() end,
    setMixWithSystem = function() end,
    setOrientation = function() end,
    setPosition = function() end,
    setVelocity = function() end,
    setVolume = function() end,
}

love.mouse.newCursor = function(a, b, c) return {} end
love.mouse.setCursor = function(a) end
