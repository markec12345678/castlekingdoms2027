-- objects/Mission/DailyChallengeSystem.lua
-- Castle Kingdoms 2027 v2.6.3 - Daily Challenge System
--
-- Generates daily challenges that refresh every 24 hours.
-- Players can complete challenges for bonus gold and achievement progress.
--
-- Challenge types:
-- - Economic: gather X resources, earn X gold
-- - Military: kill X enemies, win X battles
-- - Building: build X structures
-- - Diplomatic: form X alliances, complete X trades

local DailyChallenge = {}

local CHALLENGE_TEMPLATES = {
    -- Economic challenges
    { id = "gather_wood",    type = "economic", desc = "Zberi {target} lesa",         target = 500,  reward = { gold = 200 } },
    { id = "gather_stone",   type = "economic", desc = "Zberi {target} kamna",        target = 300,  reward = { gold = 150 } },
    { id = "gather_food",    type = "economic", desc = "Zberi {target} hrane",        target = 400,  reward = { gold = 180 } },
    { id = "gather_gold",    type = "economic", desc = "Prisluži {target} zlata",     target = 1000, reward = { gold = 300 } },
    { id = "gather_iron",    type = "economic", desc = "Zberi {target} železa",       target = 100,  reward = { gold = 250 } },

    -- Military challenges
    { id = "kill_enemies",   type = "military", desc = "Premagaj {target} sovražnikov", target = 20, reward = { gold = 400 } },
    { id = "win_battles",    type = "military", desc = "Zmagaj v {target} bitkah",      target = 3,  reward = { gold = 500 } },
    { id = "train_units",    type = "military", desc = "Usposobi {target} enot",        target = 15, reward = { gold = 200 } },
    { id = "siege_destroy",  type = "military", desc = "Uniči {target} zgradb z oblegovalnimi orožji", target = 5, reward = { gold = 350 } },

    -- Building challenges
    { id = "build_structures", type = "building", desc = "Zgradi {target} zgradb",      target = 10, reward = { gold = 250 } },
    { id = "build_towers",     type = "building", desc = "Zgradi {target} obrambne stolpe", target = 3, reward = { gold = 200 } },

    -- Diplomatic challenges
    { id = "form_alliances",  type = "diplomatic", desc = "Skleni {target} zavezništev", target = 2, reward = { gold = 300 } },
    { id = "complete_trades",  type = "diplomatic", desc = "Zaključi {target} trgovin",   target = 5, reward = { gold = 250 } },
    { id = "send_tributes",    type = "diplomatic", desc = "Pošlji {target} daril",       target = 3, reward = { gold = 200 } },
}

DailyChallenge.CHALLENGE_TEMPLATES = CHALLENGE_TEMPLATES

local initialized = false
local currentChallenges = {}
local lastRefreshDate = nil
local completedToday = {}

function DailyChallenge.init()
    if initialized then return end
    initialized = true
    DailyChallenge._loadProgress()
    DailyChallenge._refreshIfNeeded()
    print("[DailyChallenge] Initialized with " .. #currentChallenges .. " active challenges")
end

-- Get today's date string (YYYY-MM-DD)
function DailyChallenge._getTodayDate()
    return os.date("%Y-%m-%d")
end

-- Check if challenges need to be refreshed (new day)
function DailyChallenge._refreshIfNeeded()
    local today = DailyChallenge._getTodayDate()
    if lastRefreshDate ~= today then
        DailyChallenge._generateDailyChallenges()
        lastRefreshDate = today
        completedToday = {}
        DailyChallenge._saveProgress()
        print("[DailyChallenge] Refreshed for " .. today)
    end
end

-- Generate 3 random daily challenges (one from each category)
function DailyChallenge._generateDailyChallenges()
    currentChallenges = {}
    local categories = {"economic", "military", "building", "diplomatic"}

    -- Pick 3 random categories (without repeat)
    local selected = {}
    while #selected < 3 and #selected < #categories do
        local idx = math.random(#categories)
        local cat = categories[idx]
        local alreadySelected = false
        for _, s in ipairs(selected) do
            if s == cat then alreadySelected = true break end
        end
        if not alreadySelected then
            table.insert(selected, cat)
        end
    end

    -- For each selected category, pick a random challenge template
    for _, cat in ipairs(selected) do
        local candidates = {}
        for _, template in ipairs(CHALLENGE_TEMPLATES) do
            if template.type == cat then
                table.insert(candidates, template)
            end
        end
        if #candidates > 0 then
            local template = candidates[math.random(#candidates)]
            -- Vary the target slightly for replayability
            local variance = math.random(80, 120) / 100  -- 0.8x to 1.2x
            local target = math.floor(template.target * variance)
            table.insert(currentChallenges, {
                id = template.id,
                type = template.type,
                description = string.gsub(template.desc, "{target}", tostring(target)),
                target = target,
                progress = 0,
                completed = false,
                reward = template.reward,
            })
        end
    end
end

-- Get current daily challenges
function DailyChallenge.getChallenges()
    return currentChallenges
end

-- Update progress for a challenge type
function DailyChallenge.updateProgress(challengeType, amount)
    if not initialized then return end
    amount = amount or 1
    for _, challenge in ipairs(currentChallenges) do
        if challenge.type == challengeType and not challenge.completed then
            challenge.progress = math.min(challenge.target, challenge.progress + amount)
            if challenge.progress >= challenge.target then
                challenge.completed = true
                DailyChallenge._completeChallenge(challenge)
            end
            DailyChallenge._saveProgress()
            return challenge
        end
    end
end

-- Complete a challenge and give rewards
function DailyChallenge._completeChallenge(challenge)
    print("[DailyChallenge] Completed: " .. challenge.description)
    -- Give rewards
    if _G.state and challenge.reward then
        if challenge.reward.gold then
            _G.state.gold = (_G.state.gold or 0) + challenge.reward.gold
        end
    end
    -- Show notification
    if _G.ModernUI then
        _G.ModernUI.notifySuccess("Dnevni izziv končan! +" .. (challenge.reward.gold or 0) .. " zlata")
    end
    -- Fire event
    if _G.GameEventBus then
        pcall(function() _G.GameEventBus.emit("daily_challenge_complete", challenge) end)
    end
end

-- Get summary stats
function DailyChallenge.getStats()
    local completed = 0
    local total = #currentChallenges
    for _, c in ipairs(currentChallenges) do
        if c.completed then completed = completed + 1 end
    end
    return {
        total = total,
        completed = completed,
        date = lastRefreshDate,
    }
end

-- Force refresh (for testing)
function DailyChallenge.forceRefresh()
    lastRefreshDate = nil
    DailyChallenge._refreshIfNeeded()
end

-- Save progress to file
function DailyChallenge._saveProgress()
    local data = {
        date = lastRefreshDate,
        challenges = currentChallenges,
        completedToday = completedToday,
    }
    local file = love.filesystem.newFile("daily_challenges.json")
    if file:open("w") then
        -- Simple serialization
        local lines = {"return {"}
        table.insert(lines, string.format("  date = %q,", lastRefreshDate or ""))
        table.insert(lines, "  challenges = {")
        for _, c in ipairs(currentChallenges) do
            table.insert(lines, string.format("    {id=%q, type=%q, description=%q, target=%d, progress=%d, completed=%s},",
                c.id, c.type, c.description, c.target, c.progress, tostring(c.completed)))
        end
        table.insert(lines, "  },")
        table.insert(lines, "}")
        file:write(table.concat(lines, "\n"))
        file:close()
    end
end

-- Load progress from file
function DailyChallenge._loadProgress()
    local file = love.filesystem.newFile("daily_challenges.json")
    if file:open("r") then
        local content = file:read()
        file:close()
        if content then
            local ok, chunk = pcall(load, content)
            if ok and chunk then
                local dataOk, data = pcall(chunk)
                if dataOk and type(data) == "table" then
                    lastRefreshDate = data.date
                    currentChallenges = data.challenges or {}
                    completedToday = data.completedToday or {}
                    return
                end
            end
        end
    end
end

return DailyChallenge
