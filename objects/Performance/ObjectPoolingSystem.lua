-- objects/Performance/ObjectPoolingSystem.lua
-- Castle Kingdoms 2027 - Object Pooling System
-- Reuses objects instead of creating/destroying (performance optimization)

local ObjectPool = {}

local pools = {}
local initialized = false

-- Pool configuration per object type
local POOL_CONFIG = {
    projectile = { max = 200,  initial = 50  },
    particle   = { max = 500,  initial = 100 },
    damageNumber = { max = 100, initial = 20 },
    waypointFloat = { max = 50,  initial = 10 },
    effect     = { max = 300,  initial = 50  },
}

function ObjectPool.init()
    if initialized then return end
    initialized = true

    -- Pre-allocate pools
    for typeName, config in pairs(POOL_CONFIG) do
        pools[typeName] = {
            active = {},
            inactive = {},
            max = config.max,
            created = 0,
            reused = 0,
        }
        -- Pre-allocate initial objects
        for _ = 1, config.initial do
            table.insert(pools[typeName].inactive, {})
        end
        pools[typeName].created = config.initial
    end

    local totalPooled = 0
    for _, pool in pairs(pools) do
        totalPooled = totalPooled + #pool.inactive
    end
    print("[ObjectPool] Initialized (" .. totalPooled .. " pre-allocated objects)")
end

-- Get an object from the pool (or create new)
function ObjectPool.acquire(typeName)
    if not initialized then ObjectPool.init() end
    local pool = pools[typeName]
    if not pool then
        -- Create new pool for unknown type
        pools[typeName] = { active = {}, inactive = {}, max = 100, created = 0, reused = 0 }
        pool = pools[typeName]
    end

    local obj
    if #pool.inactive > 0 then
        -- Reuse from pool
        obj = table.remove(pool.inactive)
        pool.reused = pool.reused + 1
    else
        -- Create new if under max
        if pool.created < pool.max then
            obj = {}
            pool.created = pool.created + 1
        else
            -- Pool exhausted, reuse oldest active
            if #pool.active > 0 then
                obj = table.remove(pool.active, 1)
                pool.reused = pool.reused + 1
            else
                obj = {}  -- Emergency fallback
            end
        end
    end

    -- Mark as active
    table.insert(pool.active, obj)
    return obj
end

-- Return an object to the pool
function ObjectPool.release(typeName, obj)
    if not initialized or not obj then return end
    local pool = pools[typeName]
    if not pool then return end

    -- Remove from active
    for i, activeObj in ipairs(pool.active) do
        if activeObj == obj then
            table.remove(pool.active, i)
            break
        end
    end

    -- Reset object fields
    for k in pairs(obj) do
        obj[k] = nil
    end

    -- Return to inactive pool
    table.insert(pool.inactive, obj)
end

-- Release all active objects of a type
function ObjectPool.releaseAll(typeName)
    if not initialized then return end
    local pool = pools[typeName]
    if not pool then return end

    for _, obj in ipairs(pool.active) do
        for k in pairs(obj) do obj[k] = nil end
        table.insert(pool.inactive, obj)
    end
    pool.active = {}
end

-- Get pool stats
function ObjectPool.getStats()
    local stats = {}
    local totalActive = 0
    local totalInactive = 0
    local totalReused = 0

    for typeName, pool in pairs(pools) do
        stats[typeName] = {
            active = #pool.active,
            inactive = #pool.inactive,
            max = pool.max,
            created = pool.created,
            reused = pool.reused,
        }
        totalActive = totalActive + #pool.active
        totalInactive = totalInactive + #pool.inactive
        totalReused = totalReused + pool.reused
    end

    stats.total = {
        active = totalActive,
        inactive = totalInactive,
        reused = totalReused,
    }

    return stats
end

-- Print pool stats
function ObjectPool.printStats()
    local stats = ObjectPool.getStats()
    print("\n" .. string.rep("=", 50))
    print("OBJECT POOL STATS")
    print(string.rep("=", 50))
    print(string.format("%-15s %8s %8s %8s %8s", "Type", "Active", "Inactive", "Created", "Reused"))
    print(string.rep("-", 50))
    for typeName, s in pairs(stats) do
        if typeName ~= "total" then
            print(string.format("%-15s %8d %8d %8d %8d",
                typeName, s.active, s.inactive, s.created, s.reused))
        end
    end
    print(string.rep("-", 50))
    print(string.format("%-15s %8d %8d %8s %8d",
        "TOTAL", stats.total.active, stats.total.inactive, "-", stats.total.reused))
    print(string.rep("=", 50))
end

-- Register a new pool type
function ObjectPool.registerType(typeName, maxSize, initialSize)
    if pools[typeName] then return end
    pools[typeName] = {
        active = {},
        inactive = {},
        max = maxSize or 100,
        created = 0,
        reused = 0,
    }

    -- Pre-allocate
    for _ = 1, (initialSize or 10) do
        table.insert(pools[typeName].inactive, {})
    end
    pools[typeName].created = initialSize or 10

    print("[ObjectPool] Registered type: " .. typeName .. " (max: " .. (maxSize or 100) .. ")")
end

return ObjectPool
