-- objects/Steam/LeaderboardSystem.lua
-- Castle Kingdoms 2027 v2.8.2 - Leaderboard System
--
-- Tracks and compares player scores across multiple categories.
-- Local leaderboard with optional Steam integration (future).
--
-- Leaderboard categories:
-- - Total Score: overall game performance
-- - Speed Run: fastest mission completion
-- - Economy: highest gold accumulated
-- - Military: most enemies killed
-- - Builder: most buildings constructed
-- - Diplomat: most alliances formed
-- - Survivor: longest survival time
-- - Tournament: tournament wins

local Leaderboard = {}

-- Category definitions
local CATEGORIES = {
    total_score = {
        name = "Skupni rezultat",
        nameEn = "Total Score",
        icon = "★",
        color = {1.0, 0.8, 0.2},
        format = "number",
    },
    speed_run = {
        name = "Najhitrejša misija",
        nameEn = "Speed Run",
        icon = "⚡",
        color = {0.3, 0.8, 1.0},
        format = "time",  -- lower is better
    },
    economy = {
        name = "Ekonomija",
        nameEn = "Economy",
        icon = "$",
        color = {0.3, 0.9, 0.3},
        format = "number",
    },
    military = {
        name = "Vojaški",
        nameEn = "Military",
        icon = "⚔",
        color = {0.9, 0.3, 0.3},
        format = "number",
    },
    builder = {
        name = "Graditelj",
        nameEn = "Builder",
        icon = "🏗",
        color = {0.8, 0.6, 0.3},
        format = "number",
    },
    diplomat = {
        name = "Diplomat",
        nameEn = "Diplomat",
        icon = "D",
        color = {0.3, 0.5, 0.9},
        format = "number",
    },
    survivor = {
        name = "Preživeli",
        nameEn = "Survivor",
        icon = "⏳",
        color = {0.7, 0.7, 0.7},
        format = "time",  -- higher is better
    },
    tournament = {
        name = "Turnirski",
        nameEn = "Tournament",
        icon = "🏆",
        color = {0.9, 0.7, 0.1},
        format = "number",
    },
}

Leaderboard.CATEGORIES = CATEGORIES

local initialized = false
local entries = {}  -- [category] = { {name, score, timestamp, difficulty}, ... }
local maxEntriesPerCategory = 20
local playerStats = {}  -- player's personal bests per category

function Leaderboard.init()
    if initialized then return end
    initialized = true
    -- Initialize empty entries for each category
    for catId, _ in pairs(CATEGORIES) do
        entries[catId] = {}
    end
    Leaderboard._load()
    print("[Leaderboard] Initialized with " .. Leaderboard._getCategoryCount() .. " categories")
end

function Leaderboard._getCategoryCount()
    local count = 0
    for _ in pairs(CATEGORIES) do count = count + 1 end
    return count
end

-- Submit a score to the leaderboard
function Leaderboard.submit(category, name, score, difficulty)
    if not CATEGORIES[category] then return false end
    if not name or not score then return false end

    local entry = {
        name = name,
        score = score,
        difficulty = difficulty or "normal",
        timestamp = os.time(),
        dateStr = os.date("%Y-%m-%d %H:%M"),
    }

    -- Check if this is a new personal best
    local isPersonalBest = false
    if not playerStats[category] or
       (CATEGORIES[category].format == "time" and score < playerStats[category]) or
       (CATEGORIES[category].format ~= "time" and score > (playerStats[category] or 0)) then
        isPersonalBest = true
        playerStats[category] = score
    end

    -- Add to entries
    table.insert(entries[category], entry)

    -- Sort entries
    if CATEGORIES[category].format == "time" then
        -- Lower is better (speed run)
        table.sort(entries[category], function(a, b) return a.score < b.score end)
    else
        -- Higher is better
        table.sort(entries[category], function(a, b) return a.score > b.score end)
    end

    -- Trim to max entries
    while #entries[category] > maxEntriesPerCategory do
        table.remove(entries[category])
    end

    -- Find rank
    local rank = 0
    for i, e in ipairs(entries[category]) do
        if e == entry then
            rank = i
            break
        end
    end

    -- Notify
    if _G.ModernUI then
        if rank <= 3 then
            local medal = rank == 1 and "🥇 1. mesto!" or rank == 2 and "🥈 2. mesto!" or "🥉 3. mesto!"
            _G.ModernUI.notifySuccess("Leaderboard: " .. CATEGORIES[category].name .. " — " .. medal)
        elseif isPersonalBest then
            _G.ModernUI.notifyInfo("Nov osebni rekord: " .. CATEGORIES[category].name)
        end
    end

    -- Save
    Leaderboard._save()

    -- Fire event
    if _G.GameEventBus then
        pcall(function() _G.GameEventBus.emit("leaderboard_submit", {
            category = category,
            rank = rank,
            score = score,
            isPersonalBest = isPersonalBest,
        }) end)
    end

    print(string.format("[Leaderboard] %s: %s scored %d — rank #%d", category, name, score, rank))
    return rank, isPersonalBest
end

-- Get leaderboard entries for a category
function Leaderboard.getEntries(category, limit)
    if not entries[category] then return {} end
    limit = limit or 10
    local result = {}
    for i = 1, math.min(limit, #entries[category]) do
        local e = entries[category][i]
        table.insert(result, {
            rank = i,
            name = e.name,
            score = e.score,
            difficulty = e.difficulty,
            date = e.dateStr,
            formatted = Leaderboard._formatScore(category, e.score),
        })
    end
    return result
end

-- Format score for display
function Leaderboard._formatScore(category, score)
    local cat = CATEGORIES[category]
    if not cat then return tostring(score) end
    if cat.format == "time" then
        local mins = math.floor(score / 60)
        local secs = math.floor(score % 60)
        return string.format("%02d:%02d", mins, secs)
    else
        return tostring(math.floor(score))
    end
end

-- Get player's personal best for a category
function Leaderboard.getPersonalBest(category)
    return playerStats[category]
end

-- Get player's rank in a category
function Leaderboard.getPlayerRank(category, playerName)
    if not entries[category] then return nil end
    for i, e in ipairs(entries[category]) do
        if e.name == playerName then
            return i
        end
    end
    return nil
end

-- Get all categories with player's best
function Leaderboard.getAllBests()
    local result = {}
    for catId, cat in pairs(CATEGORIES) do
        table.insert(result, {
            id = catId,
            name = cat.name,
            icon = cat.icon,
            color = cat.color,
            personalBest = playerStats[catId],
            formattedBest = playerStats[catId] and Leaderboard._formatScore(catId, playerStats[catId]) or "—",
            entryCount = entries[catId] and #entries[catId] or 0,
        })
    end
    return result
end

-- Get total stats
function Leaderboard.getStats()
    local totalEntries = 0
    local personalBests = 0
    for catId, _ in pairs(CATEGORIES) do
        if entries[catId] then
            totalEntries = totalEntries + #entries[catId]
        end
        if playerStats[catId] then
            personalBests = personalBests + 1
        end
    end
    return {
        totalCategories = Leaderboard._getCategoryCount(),
        totalEntries = totalEntries,
        personalBests = personalBests,
    }
end

-- Generate fake AI entries for leaderboard (for single-player feel)
function Leaderboard._generateAIEntries()
    local aiNames = {"Sir Aldric", "Lord Valdemar", "Lady Elara", "Baron Westmar",
                     "Knight Roland", "Duke Edmond", "Countess Isabelle", "Sir Gareth"}
    for catId, cat in pairs(CATEGORIES) do
        for i = 1, 5 do
            local name = aiNames[math.random(#aiNames)]
            local score
            if cat.format == "time" then
                score = math.random(120, 600)  -- 2-10 minutes
            else
                score = math.random(500, 5000)
            end
            local entry = {
                name = name,
                score = score,
                difficulty = "normal",
                timestamp = os.time() - math.random(86400, 604800),  -- 1-7 days ago
                dateStr = os.date("%Y-%m-%d %H:%M", os.time() - math.random(86400, 604800)),
            }
            table.insert(entries[catId], entry)
        end
        -- Sort
        if cat.format == "time" then
            table.sort(entries[catId], function(a, b) return a.score < b.score end)
        else
            table.sort(entries[catId], function(a, b) return a.score > b.score end)
        end
    end
end

-- Save to file
function Leaderboard._save()
    local file = love.filesystem.newFile("leaderboard.json")
    if file:open("w") then
        local lines = {"return {"}
        -- Save entries
        table.insert(lines, "  entries = {")
        for catId, catEntries in pairs(entries) do
            table.insert(lines, "    ['" .. catId .. "'] = {")
            for _, e in ipairs(catEntries) do
                table.insert(lines, string.format("      {name=%q, score=%d, difficulty=%q, timestamp=%d, dateStr=%q},",
                    e.name, e.score, e.difficulty, e.timestamp, e.dateStr or ""))
            end
            table.insert(lines, "    },")
        end
        table.insert(lines, "  },")
        -- Save personal stats
        table.insert(lines, "  playerStats = {")
        for catId, score in pairs(playerStats) do
            table.insert(lines, string.format("    ['%s'] = %d,", catId, score))
        end
        table.insert(lines, "  },")
        table.insert(lines, "}")
        file:write(table.concat(lines, "\n"))
        file:close()
    end
end

-- Load from file
function Leaderboard._load()
    local file = love.filesystem.newFile("leaderboard.json")
    if file:open("r") then
        local content = file:read()
        file:close()
        if content then
            local ok, chunk = pcall(load, content)
            if ok and chunk then
                local dataOk, data = pcall(chunk)
                if dataOk and type(data) == "table" then
                    if data.entries then
                        for catId, catEntries in pairs(data.entries) do
                            entries[catId] = catEntries
                        end
                    end
                    if data.playerStats then
                        playerStats = data.playerStats
                    end
                    -- If no entries, generate AI entries
                    local hasEntries = false
                    for _, catEntries in pairs(entries) do
                        if #catEntries > 0 then hasEntries = true break end
                    end
                    if not hasEntries then
                        Leaderboard._generateAIEntries()
                        Leaderboard._save()
                    end
                    return
                end
            end
        end
    end
    -- No save file — generate AI entries
    Leaderboard._generateAIEntries()
    Leaderboard._save()
end

-- Clear all entries (reset)
function Leaderboard.reset()
    for catId, _ in pairs(CATEGORIES) do
        entries[catId] = {}
    end
    playerStats = {}
    Leaderboard._generateAIEntries()
    Leaderboard._save()
    print("[Leaderboard] Reset — new AI entries generated")
end

return Leaderboard
