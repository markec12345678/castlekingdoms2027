-- objects/Network/DiplomaticRelationsSystem.lua
-- Stronghold 2027 v2.6.8 - Diplomatic Relations System
--
-- Deep diplomatic system managing relations between factions.
-- Tracks reputation, history of actions, and enables complex diplomatic actions.
--
-- Relation levels:
-- - Hostile (-100 to -50): active warfare, no diplomacy
-- - Unfriendly (-49 to -20): no trade, limited interaction
-- - Neutral (-19 to 19): default state, basic trade
-- - Friendly (20 to 49): trade bonuses, mutual defense
-- - Allied (50 to 100): full alliance, shared vision

local DiplomaticRelations = {}

local initialized = false
local factionRelations = {}  -- [fromFaction][toFaction] = { score, history, actions }
local relationModifiers = {
    trade_completed = 3,
    tribute_sent = 5,
    alliance_formed = 20,
    peace_proposed = 10,
    war_declared = -30,
    assassination_attempt = -40,
    sabotage = -25,
    border_violation = -10,
    shared_enemy = 8,  -- fighting common enemy
}

function DiplomaticRelations.init()
    if initialized then return end
    initialized = true
    print("[DiplomaticRelations] Initialized")
end

-- Get relation level name from score
function DiplomaticRelations.getLevelName(score)
    if not score then return "Neutral" end
    if score >= 50 then return "Allied"
    elseif score >= 20 then return "Friendly"
    elseif score >= -19 then return "Neutral"
    elseif score >= -49 then return "Unfriendly"
    else return "Hostile" end
end

-- Get relation score between two factions
function DiplomaticRelations.getRelation(fromFaction, toFaction)
    if not factionRelations[fromFaction] then return 0 end
    if not factionRelations[fromFaction][toFaction] then return 0 end
    return factionRelations[fromFaction][toFaction].score
end

-- Set relation score (clamped -100 to 100)
function DiplomaticRelations._setRelation(fromFaction, toFaction, score)
    if not factionRelations[fromFaction] then factionRelations[fromFaction] = {} end
    if not factionRelations[fromFaction][toFaction] then
        factionRelations[fromFaction][toFaction] = { score = 0, history = {} }
    end
    -- Clamp score
    score = math.max(-100, math.min(100, score))
    factionRelations[fromFaction][toFaction].score = score
    -- Mirror relation (if A likes B, B likes A slightly less)
    if fromFaction ~= toFaction then
        if not factionRelations[toFaction] then factionRelations[toFaction] = {} end
        if not factionRelations[toFaction][fromFaction] then
            factionRelations[toFaction][fromFaction] = { score = 0, history = {} }
        end
        -- Mirror with 80% weight (not perfect symmetry)
        local mirroredScore = score * 0.8
        factionRelations[toFaction][fromFaction].score = math.max(-100, math.min(100, mirroredScore))
    end
end

-- Modify relation by action type
function DiplomaticRelations.modifyRelation(fromFaction, toFaction, action, amount)
    local baseModifier = relationModifiers[action] or 0
    if amount then baseModifier = amount end

    local currentScore = DiplomaticRelations.getRelation(fromFaction, toFaction)
    local newScore = currentScore + baseModifier
    DiplomaticRelations._setRelation(fromFaction, toFaction, newScore)

    -- Record in history
    if not factionRelations[fromFaction] then factionRelations[fromFaction] = {} end
    if not factionRelations[fromFaction][toFaction] then
        factionRelations[fromFaction][toFaction] = { score = 0, history = {} }
    end
    table.insert(factionRelations[fromFaction][toFaction].history, {
        action = action,
        modifier = baseModifier,
        timestamp = os.time(),
    })
    -- Limit history to 20 entries
    while #factionRelations[fromFaction][toFaction].history > 20 do
        table.remove(factionRelations[fromFaction][toFaction].history, 1)
    end

    -- Notify if significant change
    if math.abs(baseModifier) >= 10 and _G.ModernUI then
        local levelName = DiplomaticRelations.getLevelName(newScore)
        local sign = baseModifier >= 0 and "+" or ""
        _G.ModernUI.notifyInfo(string.format("Odnos z frakcijo %d: %s%d (%s)",
            toFaction, sign, baseModifier, levelName))
    end

    -- Fire event
    if _G.GameEventBus then
        pcall(function()
            _G.GameEventBus.emit("diplomatic_relation_changed", {
                from = fromFaction,
                to = toFaction,
                action = action,
                modifier = baseModifier,
                newScore = newScore,
            })
        end)
    end

    return newScore
end

-- Check if a diplomatic action is allowed
function DiplomaticRelations.canDoAction(fromFaction, toFaction, action)
    local score = DiplomaticRelations.getRelation(fromFaction, toFaction)
    local level = DiplomaticRelations.getLevelName(score)

    if action == "trade" then
        return score >= -19, level ~= "Hostile" and level ~= "Unfriendly"
    elseif action == "alliance" then
        return score >= 20, level == "Friendly" or level == "Allied"
    elseif action == "tribute" then
        return score >= -19, level ~= "Hostile"
    elseif action == "war" then
        return true, true  -- can always declare war
    elseif action == "peace" then
        return score >= -49, level ~= "Hostile"
    end
    return false, false
end

-- Get all relations for a faction
function DiplomaticRelations.getAllRelations(faction)
    local result = {}
    if not factionRelations[faction] then return result end
    for toFaction, data in pairs(factionRelations[faction]) do
        table.insert(result, {
            targetFaction = toFaction,
            score = data.score,
            level = DiplomaticRelations.getLevelName(data.score),
            historyCount = #data.history,
        })
    end
    return result
end

-- Get relation history
function DiplomaticRelations.getHistory(fromFaction, toFaction)
    if not factionRelations[fromFaction] then return {} end
    if not factionRelations[fromFaction][toFaction] then return {} end
    return factionRelations[fromFaction][toFaction].history
end

-- Get trade bonus based on relation
function DiplomaticRelations.getTradeBonus(fromFaction, toFaction)
    local score = DiplomaticRelations.getRelation(fromFaction, toFaction)
    if score >= 50 then return 1.3  -- Allied: +30% trade profit
    elseif score >= 20 then return 1.15  -- Friendly: +15%
    elseif score >= -19 then return 1.0  -- Neutral: normal
    else return 0.8 end  -- Unfriendly/Hostile: -20%
end

-- Get defense pact status (allies defend each other)
function DiplomaticRelations.hasDefensePact(fromFaction, toFaction)
    local score = DiplomaticRelations.getRelation(fromFaction, toFaction)
    return score >= 50  -- Allied
end

-- Get shared vision status
function DiplomaticRelations.hasSharedVision(fromFaction, toFaction)
    local score = DiplomaticRelations.getRelation(fromFaction, toFaction)
    return score >= 50  -- Allied
end

-- Decay relations toward neutral over time (called periodically)
function DiplomaticRelations.update(dt)
    -- Slow decay toward 0 (neutral) for all relations
    -- Called every few seconds, small decay
    for fromFaction, targets in pairs(factionRelations) do
        for toFaction, data in pairs(targets) do
            if data.score > 0 then
                data.score = math.max(0, data.score - 0.01 * dt)
            elseif data.score < 0 then
                data.score = math.min(0, data.score + 0.01 * dt)
            end
        end
    end
end

-- Get stats
function DiplomaticRelations.getStats()
    local totalRelations = 0
    local allied = 0
    local hostile = 0
    for _, targets in pairs(factionRelations) do
        for _, data in pairs(targets) do
            totalRelations = totalRelations + 1
            if data.score >= 50 then allied = allied + 1
            elseif data.score < -50 then hostile = hostile + 1 end
        end
    end
    return {
        totalRelations = totalRelations,
        allied = allied,
        hostile = hostile,
    }
end

return DiplomaticRelations
