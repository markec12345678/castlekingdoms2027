-- objects/Config/PrestigeSystem.lua
-- Stronghold 2027 v2.7.9 - Prestige & Ranking System
--
-- Tracks player prestige points earned through achievements, victories,
-- and milestones. Prestige unlocks cosmetic options and bonuses.
--
-- Prestige sources:
-- - Mission victories (10-50 points based on difficulty)
-- - Campaign completion (100 points)
-- - Skirmish trail completion (50 points)
-- - Achievements (5-50 points based on rarity)
-- - Special milestones (first victory, flawless, speed run)
-- - Multiplayer wins (25 points each)
-- - Daily challenges (5 points each)
-- - Technology research (2 points each)

local Prestige = {}

local initialized = false
local currentPrestige = 0
local totalPrestigeEarned = 0  -- lifetime total (doesn't decrease)
local prestigeHistory = {}
local prestigeRank = "Novice"

-- Prestige ranks (thresholds)
local RANKS = {
    { name = "Novice",           threshold = 0,    color = {0.6, 0.6, 0.6} },
    { name = "Squire",           threshold = 50,   color = {0.5, 0.7, 0.3} },
    { name = "Knight",           threshold = 150,  color = {0.3, 0.6, 0.9} },
    { name = "Baron",            threshold = 300,  color = {0.7, 0.5, 0.2} },
    { name = "Count",            threshold = 500,  color = {0.8, 0.4, 0.8} },
    { name = "Duke",             threshold = 800,  color = {0.9, 0.6, 0.1} },
    { name = "King",             threshold = 1200, color = {1.0, 0.8, 0.2} },
    { name = "Emperor",          threshold = 2000, color = {1.0, 0.3, 0.3} },
    { name = "Legend",           threshold = 3500, color = {0.9, 0.1, 0.9} },
}

Prestige.RANKS = RANKS

-- Prestige point values per action
local POINT_VALUES = {
    -- Mission victories
    mission_victory_easy = 10,
    mission_victory_medium = 20,
    mission_victory_hard = 35,
    mission_victory_brutal = 50,
    mission_victory_legendary = 75,
    -- Campaign
    campaign_complete = 100,
    skirmish_trail_complete = 50,
    coop_complete = 75,
    -- Achievements by rarity
    achievement_common = 5,
    achievement_rare = 15,
    achievement_epic = 30,
    achievement_legendary = 50,
    -- Special
    first_victory = 25,
    flawless_victory = 40,
    speed_run = 35,
    storm_lord = 30,
    -- Multiplayer
    multiplayer_win = 25,
    -- Daily
    daily_challenge = 5,
    -- Technology
    technology_researched = 2,
    -- Other
    spy_success = 3,
    trade_route_profit = 1,  -- per 100g profit
    festival_held = 2,
}

Prestige.POINT_VALUES = POINT_VALUES

function Prestige.init()
    if initialized then return end
    initialized = true
    Prestige._load()
    Prestige._updateRank()
    print("[Prestige] Initialized — Rank: " .. prestigeRank .. " (" .. currentPrestige .. " points)")
end

-- Award prestige points
function Prestige.award(actionType, amount)
    if not initialized then return 0 end
    local points = POINT_VALUES[actionType] or 0
    if amount then
        -- For scaled awards (e.g., trade profit)
        points = math.floor(points * amount)
    end
    if points <= 0 then return 0 end

    currentPrestige = currentPrestige + points
    totalPrestigeEarned = totalPrestigeEarned + points

    -- Record history
    table.insert(prestigeHistory, {
        action = actionType,
        points = points,
        timestamp = os.time(),
        totalAfter = currentPrestige,
    })
    -- Limit history
    while #prestigeHistory > 50 do
        table.remove(prestigeHistory, 1)
    end

    -- Check for rank up
    local oldRank = prestigeRank
    Prestige._updateRank()
    if prestigeRank ~= oldRank then
        if _G.ModernUI then
            _G.ModernUI.notifySuccess("PROMOCIJA! " .. prestigeRank .. " (" .. currentPrestige .. " točk)")
        end
        if _G.GameEventBus then
            pcall(function() _G.GameEventBus.emit("prestige_rank_up", {
                newRank = prestigeRank,
                totalPoints = currentPrestige,
            }) end)
        end
        print("[Prestige] RANK UP! " .. prestigeRank)
    end

    -- Save
    Prestige._save()

    return points
end

-- Update current rank based on prestige
function Prestige._updateRank()
    prestigeRank = RANKS[1].name
    for i = #RANKS, 1, -1 do
        if currentPrestige >= RANKS[i].threshold then
            prestigeRank = RANKS[i].name
            break
        end
    end
end

-- Get current rank info
function Prestige.getRank()
    for i, rank in ipairs(RANKS) do
        if rank.name == prestigeRank then
            local nextRank = RANKS[i + 1]
            return {
                name = rank.name,
                color = rank.color,
                currentPoints = currentPrestige,
                threshold = rank.threshold,
                nextRank = nextRank and nextRank.name or nil,
                nextThreshold = nextRank and nextRank.threshold or nil,
                pointsToNext = nextRank and (nextRank.threshold - currentPrestige) or 0,
                rankIndex = i,
                totalRanks = #RANKS,
            }
        end
    end
    return nil
end

-- Get all ranks with progress
function Prestige.getAllRanks()
    local result = {}
    for _, rank in ipairs(RANKS) do
        table.insert(result, {
            name = rank.name,
            threshold = rank.threshold,
            color = rank.color,
            achieved = currentPrestige >= rank.threshold,
        })
    end
    return result
end

-- Get stats
function Prestige.getStats()
    local rankInfo = Prestige.getRank()
    return {
        currentPrestige = currentPrestige,
        totalEarned = totalPrestigeEarned,
        rank = prestigeRank,
        rankInfo = rankInfo,
        historyCount = #prestigeHistory,
    }
end

-- Get recent history
function Prestige.getHistory(limit)
    local result = {}
    limit = limit or 10
    for i = #prestigeHistory, math.max(1, #prestigeHistory - limit + 1), -1 do
        table.insert(result, prestigeHistory[i])
    end
    return result
end

-- Get rank color for UI
function Prestige.getRankColor()
    for _, rank in ipairs(RANKS) do
        if rank.name == prestigeRank then
            return rank.color
        end
    end
    return {0.6, 0.6, 0.6}
end

-- Check if player has reached a specific rank
function Prestige.hasRank(rankName)
    for _, rank in ipairs(RANKS) do
        if rank.name == rankName then
            return currentPrestige >= rank.threshold
        end
    end
    return false
end

-- Get prestige bonus (applied to various game systems)
function Prestige.getPrestigeBonus()
    -- Each rank gives +2% bonus to gold income
    local rankInfo = Prestige.getRank()
    if not rankInfo then return 1.0 end
    return 1.0 + (rankInfo.rankIndex - 1) * 0.02
end

-- Save to file
function Prestige._save()
    local file = love.filesystem.newFile("prestige.json")
    if file:open("w") then
        local lines = {"return {"}
        table.insert(lines, string.format("  current = %d,", currentPrestige))
        table.insert(lines, string.format("  total = %d,", totalPrestigeEarned))
        table.insert(lines, "  history = {")
        for _, entry in ipairs(prestigeHistory) do
            table.insert(lines, string.format("    {action=%q, points=%d, timestamp=%d},",
                entry.action, entry.points, entry.timestamp))
        end
        table.insert(lines, "  },")
        table.insert(lines, "}")
        file:write(table.concat(lines, "\n"))
        file:close()
    end
end

-- Load from file
function Prestige._load()
    local file = love.filesystem.newFile("prestige.json")
    if file:open("r") then
        local content = file:read()
        file:close()
        if content then
            local ok, chunk = pcall(load, content)
            if ok and chunk then
                local dataOk, data = pcall(chunk)
                if dataOk and type(data) == "table" then
                    currentPrestige = data.current or 0
                    totalPrestigeEarned = data.total or 0
                    prestigeHistory = data.history or {}
                    return
                end
            end
        end
    end
end

return Prestige
