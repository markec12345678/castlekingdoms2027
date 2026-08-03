-- objects/AI/PathfindingOptimizer.lua
-- Stronghold 2027 - Pathfinding Optimizer
-- Improves pathfinding performance with caching and JPS hints

local PathOpt = {}

local initialized = false
local pathCache = {}
local maxCacheSize = 500
local cacheHits = 0
local cacheMisses = 0
local useJPS = true  -- Jump Point Search hint
local gridCache = nil
local lastGridUpdate = 0

function PathOpt.init()
    if initialized then return end
    initialized = true
    print("[PathOpt] Initialized (cache: " .. maxCacheSize .. ", JPS: " .. tostring(useJPS) .. ")")
end

-- Get cached path or compute new one
function PathOpt.getPath(startX, startY, endX, endY, finder)
    if not initialized then PathOpt.init() end

    -- Create cache key
    local key = startX .. "," .. startY .. "->" .. endX .. "," .. endY

    -- Check cache
    if pathCache[key] then
        cacheHits = cacheHits + 1
        return pathCache[key]
    end

    cacheMisses = cacheMisses + 1

    -- Compute path using original finder
    local path = nil
    if finder then
        path = finder(startX, startY, endX, endY)
    end

    -- Cache the result
    if path and #pathCache < maxCacheSize then
        pathCache[key] = path
    elseif #pathCache >= maxCacheSize then
        -- Clear oldest entries (simple FIFO)
        local firstKey = next(pathCache)
        if firstKey then pathCache[firstKey] = nil end
        pathCache[key] = path
    end

    return path
end

-- Invalidate cache for a specific area (when terrain changes)
function PathOpt.invalidateArea(gx, gy, radius)
    local r = radius or 3
    local invalidated = 0

    for key, _ in pairs(pathCache) do
        -- Parse start/end from key
        local sx, sy, ex, ey = key:match("(%d+),(%d+)->(%d+),(%d+)")
        if sx then
            sx, sy, ex, ey = tonumber(sx), tonumber(sy), tonumber(ex), tonumber(ey)
            -- Check if path passes through invalidated area
            local distStart = math.abs(sx - gx) + math.abs(sy - gy)
            local distEnd = math.abs(ex - gx) + math.abs(ey - gy)
            if distStart < r * 5 or distEnd < r * 5 then
                pathCache[key] = nil
                invalidated = invalidated + 1
            end
        end
    end

    if invalidated > 0 then
        print("[PathOpt] Invalidated " .. invalidated .. " cached paths near (" .. gx .. "," .. gy .. ")")
    end
end

-- Clear entire cache
function PathOpt.clearCache()
    local count = 0
    for _ in pairs(pathCache) do count = count + 1 end
    pathCache = {}
    print("[PathOpt] Cache cleared (" .. count .. " paths)")
end

-- JPS (Jump Point Search) direction hints
-- Instead of exploring all 8 neighbors, JPS "jumps" in directions
-- until it hits an obstacle or forced neighbor, reducing explored nodes
function PathOpt.getJPSDirections(currentX, currentY, parentX, parentY)
    if not useJPS or not parentX then
        -- No parent — explore all 8 directions
        return {
            {1, 0}, {-1, 0}, {0, 1}, {0, -1},
            {1, 1}, {1, -1}, {-1, 1}, {-1, -1}
        }
    end

    -- Direction from parent to current
    local dx = currentX > parentX and 1 or (currentX < parentX and -1 or 0)
    local dy = currentY > parentY and 1 or (currentY < parentY and -1 or 0)

    local directions = {}

    if dx ~= 0 and dy ~= 0 then
        -- Diagonal movement — prune perpendicular directions
        table.insert(directions, {dx, 0})
        table.insert(directions, {0, dy})
        table.insert(directions, {dx, dy})
        -- Forced neighbors
        table.insert(directions, {-dx, dy})
        table.insert(directions, {dx, -dy})
    else
        -- Straight movement
        table.insert(directions, {dx, dy})
        -- Forced neighbors
        if dx ~= 0 then
            table.insert(directions, {dx, 1})
            table.insert(directions, {dx, -1})
        else
            table.insert(directions, {1, dy})
            table.insert(directions, {-1, dy})
        end
    end

    return directions
end

-- Check if a tile is walkable (with caching)
function PathOpt.isWalkable(gx, gy)
    if not _G.state or not _G.state.map then return false end

    -- Use cached walkability if available
    local key = gx .. "," .. gy
    if gridCache and gridCache[key] ~= nil then
        return gridCache[key]
    end

    -- Check actual walkability
    local walkable = false
    pcall(function()
        if _G.state.map.getWalkable then
            walkable = _G.state.map:getWalkable(gx, gy) == 0
        end
    end)

    -- Cache result
    if not gridCache then gridCache = {} end
    if #gridCache < 10000 then
        gridCache[key] = walkable
    end

    return walkable
end

-- Update grid cache (call when terrain changes)
function PathOpt.updateGridCache()
    gridCache = {}
    lastGridUpdate = love.timer.getTime()
    PathOpt.clearCache()
end

-- Get stats
function PathOpt.getStats()
    local cacheSize = 0
    for _ in pairs(pathCache) do cacheSize = cacheSize + 1 end

    local hitRate = 0
    local total = cacheHits + cacheMisses
    if total > 0 then hitRate = cacheHits / total * 100 end

    return {
        cacheSize = cacheSize,
        maxCacheSize = maxCacheSize,
        cacheHits = cacheHits,
        cacheMisses = cacheMisses,
        hitRate = math.floor(hitRate) .. "%",
        jpsEnabled = useJPS,
    }
end

function PathOpt.setJPS(enabled)
    useJPS = enabled
    print("[PathOpt] JPS: " .. tostring(enabled))
end

return PathOpt
