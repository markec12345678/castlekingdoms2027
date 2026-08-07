-- objects/Environment/NormalMapGenerator.lua
-- Castle Kingdoms 2027 - Generates normal maps from terrain heightmap data
--
-- Converts heightmap elevation data into a normal map texture that can
-- be used with the normal_mapping.glsl shader for dynamic terrain lighting.
--
-- Algorithm: Sobel filter on heightmap to compute surface normals.

local NormalMapGenerator = {}

local normalCanvas = nil
local normalImageData = nil
local lastUpdate = 0
local updateInterval = 0.5  -- Update normal map every 0.5 seconds

-- Generate normal map from heightmap
-- @param heightmap table 2D array of elevation values [cx][cy][x][y]
-- @param chunkWidth number Width of a chunk
-- @param chunkHeight number Height of a chunk
-- @param chunksWide number Number of chunks horizontally
-- @param chunksHigh number Number of chunks vertically
-- @return Image Normal map image
function NormalMapGenerator.generate(heightmap, chunkWidth, chunkHeight, chunksWide, chunksHigh)
    if not heightmap then return nil end

    local totalWidth = chunkWidth * chunksWide
    local totalHeight = chunkHeight * chunksHigh

    -- Limit size for performance (normal map doesn't need full resolution)
    local maxDim = 512
    local scaleX = 1
    local scaleY = 1
    if totalWidth > maxDim then scaleX = totalWidth / maxDim end
    if totalHeight > maxDim then scaleY = totalHeight / maxDim end

    local mapWidth = math.floor(totalWidth / scaleX)
    local mapHeight = math.floor(totalHeight / scaleY)

    if mapWidth < 1 then mapWidth = 1 end
    if mapHeight < 1 then mapHeight = 1 end

    -- Create image data for normal map
    local imageData = love.image.newImageData(mapWidth, mapHeight)

    -- Sobel filter strength
    local strength = 2.0

    -- Generate normals
    for py = 0, mapHeight - 1 do
        for px = 0, mapWidth - 1 do
            -- Sample heightmap at this position and neighbors
            local gx = px * scaleX
            local gy = py * scaleY

            -- Get heights at neighboring positions
            local hL = NormalMapGenerator.sampleHeight(heightmap, chunkWidth, chunkHeight, gx - 1, gy)
            local hR = NormalMapGenerator.sampleHeight(heightmap, chunkWidth, chunkHeight, gx + 1, gy)
            local hD = NormalMapGenerator.sampleHeight(heightmap, chunkWidth, chunkHeight, gx, gy - 1)
            local hU = NormalMapGenerator.sampleHeight(heightmap, chunkWidth, chunkHeight, gx, gy + 1)

            -- Sobel filter to compute normal
            local dx = (hL - hR) * strength
            local dy = (hD - hU) * strength
            local dz = 1.0

            -- Normalize
            local len = math.sqrt(dx * dx + dy * dy + dz * dz)
            if len > 0 then
                dx = dx / len
                dy = dy / len
                dz = dz / len
            end

            -- Convert from -1..1 to 0..1 range
            local r = (dx + 1) * 0.5
            local g = (dy + 1) * 0.5
            local b = (dz + 1) * 0.5

            imageData:setPixel(px, py, r, g, b, 1.0)
        end
    end

    -- Create image from image data
    local normalImage = love.graphics.newImage(imageData)
    normalImage:setFilter("linear", "linear")

    NormalMapGenerator.normalImage = normalImage
    NormalMapGenerator.normalImageData = imageData

    return normalImage
end

-- Sample height at world position (with bounds checking)
function NormalMapGenerator.sampleHeight(heightmap, chunkWidth, chunkHeight, gx, gy)
    if not heightmap then return 0 end
    if gx < 0 then gx = 0 end
    if gy < 0 then gy = 0 end

    local cx = math.floor(gx / chunkWidth)
    local cy = math.floor(gy / chunkHeight)
    local x = gx % chunkWidth
    local y = gy % chunkHeight

    -- Bounds check
    if not heightmap[cx] or not heightmap[cx][cy] then return 0 end
    if not heightmap[cx][cy][x] or not heightmap[cx][cy][x][y] then return 0 end

    local height = heightmap[cx][cy][x][y]
    return height or 0
end

-- Get the current normal map image
function NormalMapGenerator.getNormalMap()
    return NormalMapGenerator.normalImage
end

-- Update normal map (throttled for performance)
function NormalMapGenerator.update(dt, heightmap, chunkWidth, chunkHeight, chunksWide, chunksHigh)
    lastUpdate = lastUpdate + dt
    if lastUpdate < updateInterval then return end
    lastUpdate = 0

    pcall(function()
        NormalMapGenerator.generate(heightmap, chunkWidth, chunkHeight, chunksWide, chunksHigh)
    end)
end

-- Force immediate regeneration
function NormalMapGenerator.forceUpdate(heightmap, chunkWidth, chunkHeight, chunksWide, chunksHigh)
    lastUpdate = updateInterval
    NormalMapGenerator.update(0, heightmap, chunkWidth, chunkHeight, chunksWide, chunksHigh)
end

-- Set update interval (how often to regenerate)
function NormalMapGenerator.setUpdateInterval(seconds)
    updateInterval = seconds
end

return NormalMapGenerator
