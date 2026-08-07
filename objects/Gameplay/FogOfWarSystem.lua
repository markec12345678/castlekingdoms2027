-- objects/Gameplay/FogOfWarSystem.lua
-- Castle Kingdoms 2027 - Fog of War

local FogOfWar = {}
local TILE_HIDDEN = 0
local TILE_EXPLORED = 1
local TILE_VISIBLE = 2
FogOfWar.TILE_HIDDEN = TILE_HIDDEN
FogOfWar.TILE_EXPLORED = TILE_EXPLORED
FogOfWar.TILE_VISIBLE = TILE_VISIBLE

local exploredTiles = {}
local visibleTiles = {}
local mapWidth = 256
local mapHeight = 256
local visionRange = 10
local initialized = false

function FogOfWar.init(w, h)
    if initialized then
        if w and h and (w ~= mapWidth or h ~= mapHeight) then initialized = false else return end
    end
    mapWidth = w or 256
    mapHeight = h or 256
    exploredTiles = {}
    visibleTiles = {}
    initialized = true
    print("[FogOfWar] Initialized " .. mapWidth .. "x" .. mapHeight)
end

function FogOfWar.setVisionRange(r) visionRange = math.max(1, math.min(50, r or 10)) end
function FogOfWar.getVisionRange() return visionRange end

function FogOfWar.revealArea(gx, gy, range)
    if not initialized then return end
    local r = range or visionRange
    if _G.WeatherGameplay then r = r * _G.WeatherGameplay.getVisionRangeMultiplier() end
    r = math.floor(r)
    for dy = -r, r do
        for dx = -r, r do
            local tx, ty = gx+dx, gy+dy
            if tx >= 0 and ty >= 0 and tx < mapWidth and ty < mapHeight then
                if dx*dx + dy*dy <= r*r then
                    local key = tx .. "," .. ty
                    exploredTiles[key] = TILE_EXPLORED
                    visibleTiles[key] = TILE_VISIBLE
                end
            end
        end
    end
end

function FogOfWar.clearVisible() visibleTiles = {} end

function FogOfWar.updateVisibility()
    if not initialized then return end
    FogOfWar.clearVisible()
    if _G.state and _G.state.gameObjectList then
        for _, obj in ipairs(_G.state.gameObjectList) do
            if obj.gx and obj.gy and (not obj.faction or obj.faction == 1) then
                local range = visionRange
                if obj.class and obj.class.name then
                    local n = obj.class.name
                    if n:match("Tower") or n:match("Keep") or n:match("Fortress") then range = visionRange * 1.5 end
                end
                FogOfWar.revealArea(obj.gx, obj.gy, range)
            end
        end
    end
end

function FogOfWar.getTileState(gx, gy)
    if not initialized then return TILE_VISIBLE end
    local key = gx .. "," .. gy
    if visibleTiles[key] then return TILE_VISIBLE end
    if exploredTiles[key] then return TILE_EXPLORED end
    return TILE_HIDDEN
end

function FogOfWar.isVisible(gx, gy) return FogOfWar.getTileState(gx, gy) == TILE_VISIBLE end
function FogOfWar.isExplored(gx, gy) return FogOfWar.getTileState(gx, gy) >= TILE_EXPLORED end

function FogOfWar.getStats()
    local e, v = 0, 0
    for _ in pairs(exploredTiles) do e = e + 1 end
    for _ in pairs(visibleTiles) do v = v + 1 end
    local t = mapWidth * mapHeight
    return { explored=e, visible=v, total=t, exploredPercent=t>0 and math.floor(e/t*100) or 0 }
end

function FogOfWar.revealAll()
    for y = 0, mapHeight-1 do
        for x = 0, mapWidth-1 do
            local key = x .. "," .. y
            exploredTiles[key] = TILE_EXPLORED
            visibleTiles[key] = TILE_VISIBLE
        end
    end
end

function FogOfWar.reset() exploredTiles = {} visibleTiles = {} end

return FogOfWar
