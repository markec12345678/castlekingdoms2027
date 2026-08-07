-- objects/Network/DiplomacyController.lua
-- Castle Kingdoms 2027 - Diplomacy System
--
-- Manages relationships between players in multiplayer games:
-- - Alliances (mutual defense, shared vision)
-- - Wars (combat enabled, no trade)
-- - Peace (neutral, trade allowed)
-- - Tributes (one-time resource payments)
-- - Treaties (timed non-aggression pacts)
--
-- Usage:
--   local DiplomacyController = require("objects.Network.DiplomacyController")
--   DiplomacyController.init()
--   DiplomacyController.update(dt)
--   DiplomacyController.declareWar(targetPlayerId)
--   DiplomacyController.proposeAlliance(targetPlayerId)

local DiplomacyController = {}

-- Relationship states
local RELATION = {
    NEUTRAL    = "neutral",     -- Default, trade allowed
    ALLIED     = "allied",      -- Mutual defense, shared vision
    AT_WAR     = "war",         -- Combat enabled
    TRUCE      = "truce",       -- Temporary peace (timed)
    PROPOSED_ALLIANCE = "proposed_alliance",  -- Waiting for response
    PROPOSED_PEACE = "proposed_peace",         -- Waiting for response
}

DiplomacyController.RELATION = RELATION

-- State: relationships[playerId][otherPlayerId] = {relation, treatyEndTime, ...}
local relationships = {}
local myPlayerId = 1
local pendingProposals = {}  -- Proposals waiting for my response
local initialized = false

-- Callbacks
DiplomacyController.onRelationChange = nil  -- function(playerId, otherId, newRelation)
DiplomacyController.onProposalReceived = nil -- function(proposal)
DiplomacyController.onTributeReceived = nil  -- function(fromId, resources)

-- Initialize
function DiplomacyController.init()
    if initialized then return end
    initialized = true
    relationships = {}
    pendingProposals = {}
    print("[DiplomacyController] Initialized")
end

-- Set my player ID
function DiplomacyController.setMyPlayerId(id)
    myPlayerId = id
end

function DiplomacyController.getMyPlayerId()
    return myPlayerId
end

-- Get relationship between two players
function DiplomacyController.getRelation(playerA, playerB)
    if playerA == playerB then return RELATION.ALLIED end  -- Self

    if not relationships[playerA] then return RELATION.NEUTRAL end
    local rel = relationships[playerA][playerB]
    if not rel then return RELATION.NEUTRAL end

    -- Check if truce has expired
    if rel.relation == RELATION.TRUCE and rel.treatyEndTime then
        if os.time() > rel.treatyEndTime then
            return RELATION.NEUTRAL
        end
    end

    return rel.relation
end

-- Get all relationships for a player
function DiplomacyController.getMyRelations()
    if not relationships[myPlayerId] then return {} end
    return relationships[myPlayerId]
end

-- Set relationship (internal, used by network sync)
function DiplomacyController._setRelation(playerA, playerB, relation, duration)
    if not relationships[playerA] then relationships[playerA] = {} end
    if not relationships[playerB] then relationships[playerB] = {} end

    local endTime = nil
    if duration then
        endTime = os.time() + duration
    end

    relationships[playerA][playerB] = {
        relation = relation,
        treatyEndTime = endTime,
        timestamp = os.time(),
    }
    -- Relationships are symmetric
    relationships[playerB][playerA] = {
        relation = relation,
        treatyEndTime = endTime,
        timestamp = os.time(),
    }

    if DiplomacyController.onRelationChange then
        DiplomacyController.onRelationChange(playerA, playerB, relation)
    end
end

-- Declare war on another player
function DiplomacyController.declareWar(targetPlayerId)
    if targetPlayerId == myPlayerId then return false end

    DiplomacyController._setRelation(myPlayerId, targetPlayerId, RELATION.AT_WAR)
    print(string.format("[DiplomacyController] War declared on player %d", targetPlayerId))
    return true
end

-- Propose alliance to another player
function DiplomacyController.proposeAlliance(targetPlayerId)
    if targetPlayerId == myPlayerId then return false end

    local current = DiplomacyController.getRelation(myPlayerId, targetPlayerId)
    if current == RELATION.ALLIED then return false end  -- Already allied

    DiplomacyController._setRelation(myPlayerId, targetPlayerId, RELATION.PROPOSED_ALLIANCE)
    print(string.format("[DiplomacyController] Alliance proposed to player %d", targetPlayerId))
    return true
end

-- Propose peace (end war)
function DiplomacyController.proposePeace(targetPlayerId)
    if targetPlayerId == myPlayerId then return false end

    local current = DiplomacyController.getRelation(myPlayerId, targetPlayerId)
    if current ~= RELATION.AT_WAR then return false end  -- Not at war

    DiplomacyController._setRelation(myPlayerId, targetPlayerId, RELATION.PROPOSED_PEACE)
    print(string.format("[DiplomacyController] Peace proposed to player %d", targetPlayerId))
    return true
end

-- Accept a proposal
function DiplomacyController.acceptProposal(fromPlayerId)
    local current = DiplomacyController.getRelation(myPlayerId, fromPlayerId)

    if current == RELATION.PROPOSED_ALLIANCE then
        DiplomacyController._setRelation(myPlayerId, fromPlayerId, RELATION.ALLIED)
        print(string.format("[DiplomacyController] Alliance formed with player %d", fromPlayerId))
        return true
    elseif current == RELATION.PROPOSED_PEACE then
        -- Peace = truce for 5 minutes (300 seconds)
        DiplomacyController._setRelation(myPlayerId, fromPlayerId, RELATION.TRUCE, 300)
        print(string.format("[DiplomacyController] Truce formed with player %d (5 min)", fromPlayerId))
        return true
    end

    return false
end

-- Reject a proposal
function DiplomacyController.rejectProposal(fromPlayerId)
    local current = DiplomacyController.getRelation(myPlayerId, fromPlayerId)

    if current == RELATION.PROPOSED_ALLIANCE or current == RELATION.PROPOSED_PEACE then
        -- Revert to neutral or war
        DiplomacyController._setRelation(myPlayerId, fromPlayerId, RELATION.NEUTRAL)
        print(string.format("[DiplomacyController] Rejected proposal from player %d", fromPlayerId))
        return true
    end

    return false
end

-- Break alliance
function DiplomacyController.breakAlliance(targetPlayerId)
    local current = DiplomacyController.getRelation(myPlayerId, targetPlayerId)
    if current ~= RELATION.ALLIED then return false end

    DiplomacyController._setRelation(myPlayerId, targetPlayerId, RELATION.NEUTRAL)
    print(string.format("[DiplomacyController] Alliance broken with player %d", targetPlayerId))
    return true
end

-- Send tribute (resources) to another player
function DiplomacyController.sendTribute(targetPlayerId, resources)
    if targetPlayerId == myPlayerId then return false end

    -- Verify we have the resources
    if not _G.state or not _G.state.resources then return false end

    for resourceType, amount in pairs(resources) do
        local available = _G.state.resources[resourceType] or 0
        if available < amount then
            print(string.format("[DiplomacyController] Not enough %s for tribute", resourceType))
            return false
        end
    end

    -- Deduct resources
    for resourceType, amount in pairs(resources) do
        _G.state.resources[resourceType] = _G.state.resources[resourceType] - amount
    end

    print(string.format("[DiplomacyController] Tribute sent to player %d", targetPlayerId))

    -- Castle Kingdoms 2027 v2.3.5: Tributes improve relations
    -- Calculate relation improvement based on tribute value
    local tributeValue = 0
    for resourceType, amount in pairs(resources) do
        -- Rough value estimation: gold=1, others=2 per unit
        if resourceType == "gold" then
            tributeValue = tributeValue + amount
        else
            tributeValue = tributeValue + amount * 2
        end
    end
    -- Every 50 gold value = +1 relation improvement
    local improvement = math.max(1, math.floor(tributeValue / 50))
    DiplomacyController.improveRelations(targetPlayerId, improvement)

    if DiplomacyController.onTributeReceived then
        DiplomacyController.onTributeReceived(myPlayerId, resources)
    end

    -- Fire event
    if _G.GameEventBus then
        pcall(function() _G.GameEventBus.emit("tribute_sent", {
            targetPlayerId = targetPlayerId,
            resources = resources,
            improvement = improvement
        }) end)
    end

    return true
end

-- Check if can attack another player
function DiplomacyController.canAttack(targetPlayerId)
    local relation = DiplomacyController.getRelation(myPlayerId, targetPlayerId)
    return relation == RELATION.AT_WAR
end

-- Check if can trade with another player
function DiplomacyController.canTrade(targetPlayerId)
    local relation = DiplomacyController.getRelation(myPlayerId, targetPlayerId)
    return relation == RELATION.NEUTRAL or relation == RELATION.ALLIED or relation == RELATION.TRUCE
end

-- Castle Kingdoms 2027 v2.3.4: Improve relations with a faction (trade bonus)
-- @param targetPlayerId number Target faction/player ID
-- @param amount number Relation improvement amount (default 5)
function DiplomacyController.improveRelations(targetPlayerId, amount)
    amount = amount or 5
    local current = DiplomacyController.getRelation(myPlayerId, targetPlayerId)
    -- Only improve if currently neutral (don't change war/alliance status via trade)
    if current == RELATION.NEUTRAL then
        -- Track relationship score (internal, for future alliance proposals)
        if not relationshipScores then relationshipScores = {} end
        if not relationshipScores[myPlayerId] then relationshipScores[myPlayerId] = {} end
        relationshipScores[myPlayerId][targetPlayerId] =
            (relationshipScores[myPlayerId][targetPlayerId] or 0) + amount
        print(string.format("[Diplomacy] Relations with player %d improved by %d (total: %d)",
            targetPlayerId, amount, relationshipScores[myPlayerId][targetPlayerId]))
    end
end

-- Check if has shared vision (allies see each other's units)
function DiplomacyController.hasSharedVision(targetPlayerId)
    local relation = DiplomacyController.getRelation(myPlayerId, targetPlayerId)
    return relation == RELATION.ALLIED
end

-- Check if mutual defense (attacking ally = attacking me)
function DiplomacyController.hasMutualDefense(targetPlayerId)
    local relation = DiplomacyController.getRelation(myPlayerId, targetPlayerId)
    return relation == RELATION.ALLIED
end

-- Update (called every frame)
function DiplomacyController.update(dt)
    -- Check for expired truces
    if not relationships[myPlayerId] then return end

    local now = os.time()
    for otherId, rel in pairs(relationships[myPlayerId]) do
        if rel.relation == RELATION.TRUCE and rel.treatyEndTime and now > rel.treatyEndTime then
            -- Truce expired, revert to neutral
            DiplomacyController._setRelation(myPlayerId, otherId, RELATION.NEUTRAL)
            print(string.format("[DiplomacyController] Truce with player %d expired", otherId))
        end
    end
end

-- Get diplomatic status summary
function DiplomacyController.getStatus()
    local summary = {}
    if not relationships[myPlayerId] then return summary end

    for otherId, rel in pairs(relationships[myPlayerId]) do
        local relation = rel.relation
        if relation == RELATION.TRUCE and rel.treatyEndTime then
            if os.time() > rel.treatyEndTime then
                relation = RELATION.NEUTRAL
            end
        end
        summary[otherId] = {
            relation = relation,
            treatyEndTime = rel.treatyEndTime,
            timeRemaining = rel.treatyEndTime and math.max(0, rel.treatyEndTime - os.time()) or nil,
        }
    end
    return summary
end

-- Reset (for new game)
function DiplomacyController.reset()
    relationships = {}
    pendingProposals = {}
    print("[DiplomacyController] Reset")
end

-- Serialize for network sync
function DiplomacyController.serialize()
    return {
        playerId = myPlayerId,
        relationships = relationships[myPlayerId] or {},
    }
end

-- Deserialize from network sync
function DiplomacyController.deserialize(data)
    if not data or not data.relationships then return end

    if not relationships[data.playerId] then
        relationships[data.playerId] = {}
    end

    for otherId, rel in pairs(data.relationships) do
        relationships[data.playerId][otherId] = rel
    end
end

return DiplomacyController
