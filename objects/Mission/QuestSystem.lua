-- objects/Mission/QuestSystem.lua
-- Castle Kingdoms 2027 v2.7.6 - Quest System
--
-- Side quests that players can accept for additional rewards.
-- Quests are separate from the main campaign and can be completed in any order.
--
-- Quest types:
-- - Bounty: kill specific enemy unit type
-- - Delivery: deliver resources to a location
-- - Escort: protect a unit to a destination
-- - Investigation: scout an area
-- - Construction: build specific structures
-- - Challenge: achieve a goal within constraints

local QuestSystem = {}

local QUEST_TEMPLATES = {
    -- Bounty quests
    bounty_archers = {
        id = "bounty_archers",
        name = "Glavna cena: Lokostrelci",
        nameEn = "Bounty: Archers",
        type = "bounty",
        description = "Eliminiraj 10 sovražnikovih lokostrelcev",
        target = { unitType = "Archer", count = 10 },
        reward = { gold = 300, xp = 100 },
        minLevel = 1,
    },
    bounty_knights = {
        id = "bounty_knights",
        name = "Glavna cena: Vitezi",
        nameEn = "Bounty: Knights",
        type = "bounty",
        description = "Premagaj 5 sovražnikovih vitezov",
        target = { unitType = "Knight", count = 5 },
        reward = { gold = 600, xp = 200 },
        minLevel = 2,
    },

    -- Delivery quests
    delivery_food = {
        id = "delivery_food",
        name = "Dostava hrane",
        nameEn = "Food Delivery",
        type = "delivery",
        description = "Zberi in zadrži 200 hrane za pomoč lačnim",
        target = { resource = "food", count = 200 },
        reward = { gold = 200, popularity = 15 },
        minLevel = 1,
    },
    delivery_iron = {
        id = "delivery_iron",
        name = "Dostava železa",
        nameEn = "Iron Delivery",
        type = "delivery",
        description = "Zberi 100 železa za vojaško kampanjo",
        target = { resource = "iron", count = 100 },
        reward = { gold = 400 },
        minLevel = 2,
    },

    -- Construction quests
    build_towers = {
        id = "build_towers",
        name = "Obrambna mreža",
        nameEn = "Defense Network",
        type = "construction",
        description = "Zgradi 5 obrambnih stolpov",
        target = { buildingType = "SquareTower", count = 5 },
        reward = { gold = 500, stone = 50 },
        minLevel = 1,
    },
    build_farms = {
        id = "build_farms",
        name = "Kmetijska revolucija",
        nameEn = "Agricultural Revolution",
        type = "construction",
        description = "Zgradi 5 pšeničnih kmetij",
        target = { buildingType = "WheatFarm", count = 5 },
        reward = { gold = 250, food = 100 },
        minLevel = 1,
    },

    -- Challenge quests
    economy_challenge = {
        id = "economy_challenge",
        name = "Ekonomski izziv",
        nameEn = "Economy Challenge",
        type = "challenge",
        description = "Prisluži 2000 zlata v 10 minutah",
        target = { goldTarget = 2000, timeLimit = 600 },
        reward = { gold = 1000 },
        minLevel = 2,
    },
    population_challenge = {
        id = "population_challenge",
        name = "Rast prebivalstva",
        nameEn = "Population Growth",
        type = "challenge",
        description = "Dosegni populacijo 50",
        target = { populationTarget = 50 },
        reward = { gold = 400, popularity = 20 },
        minLevel = 1,
    },
    veteran_challenge = {
        id = "veteran_challenge",
        name = "Veteranski korpus",
        nameEn = "Veteran Corps",
        type = "challenge",
        description = "Usposobi 3 veteran (level 3+) enote",
        target = { veteranCount = 3, minLevel = 3 },
        reward = { gold = 800, xp = 300 },
        minLevel = 3,
    },
}

QuestSystem.QUEST_TEMPLATES = QUEST_TEMPLATES

local initialized = false
local activeQuests = {}  -- accepted quests being tracked
local completedQuests = {}  -- completed quest IDs
local availableQuests = {}  -- quests available to accept
local questProgress = {}  -- progress tracking per quest

function QuestSystem.init()
    if initialized then return end
    initialized = true
    QuestSystem._refreshAvailable()
    print("[QuestSystem] Initialized with " .. #availableQuests .. " available quests")
end

-- Refresh available quests (not yet accepted/completed)
function QuestSystem._refreshAvailable()
    availableQuests = {}
    for _, quest in pairs(QUEST_TEMPLATES) do
        if not completedQuests[quest.id] and not questProgress[quest.id] then
            table.insert(availableQuests, quest)
        end
    end
end

-- Accept a quest
function QuestSystem.accept(questId)
    local quest = QUEST_TEMPLATES[questId]
    if not quest then return false, "Unknown quest" end
    if completedQuests[questId] then return false, "Already completed" end
    if questProgress[questId] then return false, "Already accepted" end

    questProgress[questId] = {
        quest = quest,
        progress = 0,
        acceptedAt = os.time(),
        timeLimit = quest.target.timeLimit,
        timeElapsed = 0,
    }
    table.insert(activeQuests, questId)

    if _G.ModernUI then
        _G.ModernUI.notifySuccess("Quest sprejet: " .. quest.name)
    end
    print("[QuestSystem] Accepted: " .. quest.name)
    QuestSystem._refreshAvailable()
    return true
end

-- Abandon a quest
function QuestSystem.abandon(questId)
    if not questProgress[questId] then return false end
    questProgress[questId] = nil
    for i, id in ipairs(activeQuests) do
        if id == questId then
            table.remove(activeQuests, i)
            break
        end
    end
    if _G.ModernUI then
        _G.ModernUI.notifyInfo("Quest opuščen")
    end
    QuestSystem._refreshAvailable()
    return true
end

-- Update quest progress
function QuestSystem.update(dt)
    if not initialized then return end

    for _, questId in ipairs(activeQuests) do
        local progress = questProgress[questId]
        if progress then
            -- Update time limit
            if progress.timeLimit then
                progress.timeElapsed = (progress.timeElapsed or 0) + dt
                if progress.timeElapsed >= progress.timeLimit then
                    -- Time expired — quest failed
                    QuestSystem._fail(questId)
                end
            end

            -- Check completion
            if QuestSystem._checkCompletion(questId) then
                QuestSystem._complete(questId)
            end
        end
    end
end

-- Check if a quest's completion criteria are met
function QuestSystem._checkCompletion(questId)
    local progress = questProgress[questId]
    if not progress then return false end
    local quest = progress.quest
    local target = quest.target

    if quest.type == "bounty" then
        -- Check kill count (would need integration with combat system)
        return progress.progress >= target.count
    elseif quest.type == "delivery" then
        -- Check resource amount
        if _G.state and _G.state.resources then
            local amount = _G.state.resources[target.resource] or 0
            return amount >= target.count
        end
    elseif quest.type == "construction" then
        -- Check building count
        if _G.BuildingManager then
            local count = _G.BuildingManager.countByName(target.buildingType)
            return count >= target.count
        end
    elseif quest.type == "challenge" then
        if target.goldTarget then
            if _G.state and (_G.state.gold or 0) >= target.goldTarget then
                return true
            end
        elseif target.populationTarget then
            if _G.state and (_G.state.population or 0) >= target.populationTarget then
                return true
            end
        elseif target.veteranCount then
            return progress.progress >= target.veteranCount
        end
    end
    return false
end

-- Complete a quest
function QuestSystem._complete(questId)
    local progress = questProgress[questId]
    if not progress then return end
    local quest = progress.quest

    completedQuests[questId] = os.time()
    questProgress[questId] = nil

    -- Remove from active
    for i, id in ipairs(activeQuests) do
        if id == questId then
            table.remove(activeQuests, i)
            break
        end
    end

    -- Give rewards
    if quest.reward then
        if _G.state then
            if quest.reward.gold then
                _G.state.gold = (_G.state.gold or 0) + quest.reward.gold
            end
            if quest.reward.popularity then
                _G.state.popularity = (_G.state.popularity or 50) + quest.reward.popularity
            end
            if quest.reward.food and _G.state.resources then
                _G.state.resources.food = (_G.state.resources.food or 0) + quest.reward.food
            end
            if quest.reward.stone and _G.state.resources then
                _G.state.resources.stone = (_G.state.resources.stone or 0) + quest.reward.stone
            end
        end
    end

    if _G.ModernUI then
        local rewardText = ""
        if quest.reward then
            if quest.reward.gold then rewardText = rewardText .. quest.reward.gold .. "g " end
            if quest.reward.popularity then rewardText = rewardText .. "+" .. quest.reward.popularity .. " pop" end
        end
        _G.ModernUI.notifySuccess("Quest končan: " .. quest.name .. " (Nagrada: " .. rewardText .. ")")
    end

    if _G.GameEventBus then
        pcall(function() _G.GameEventBus.emit("quest_completed", { id = questId, quest = quest }) end)
    end

    print("[QuestSystem] Completed: " .. quest.name)
    QuestSystem._refreshAvailable()
end

-- Fail a quest (time expired)
function QuestSystem._fail(questId)
    local progress = questProgress[questId]
    if not progress then return end

    questProgress[questId] = nil
    for i, id in ipairs(activeQuests) do
        if id == questId then
            table.remove(activeQuests, i)
            break
        end
    end

    if _G.ModernUI then
        _G.ModernUI.notifyError("Quest spodletel: " .. progress.quest.name .. " (čas potekel)")
    end
    print("[QuestSystem] Failed: " .. progress.quest.name)
    QuestSystem._refreshAvailable()
end

-- Update progress for a quest (called by external systems)
function QuestSystem.updateProgress(questId, amount)
    if not questProgress[questId] then return false end
    questProgress[questId].progress = (questProgress[questId].progress or 0) + (amount or 1)
    return true
end

-- Get available quests
function QuestSystem.getAvailable()
    return availableQuests
end

-- Get active quests
function QuestSystem.getActive()
    local result = {}
    for _, questId in ipairs(activeQuests) do
        local progress = questProgress[questId]
        if progress then
            table.insert(result, {
                id = questId,
                name = progress.quest.name,
                description = progress.quest.description,
                type = progress.quest.type,
                progress = progress.progress,
                target = progress.quest.target,
                timeRemaining = progress.timeLimit and (progress.timeLimit - progress.timeElapsed) or nil,
            })
        end
    end
    return result
end

-- Get completed quests
function QuestSystem.getCompleted()
    return completedQuests
end

-- Get stats
function QuestSystem.getStats()
    return {
        available = #availableQuests,
        active = #activeQuests,
        completed = 0,
    }
end

return QuestSystem
