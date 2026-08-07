-- objects/Network/CoopCampaignFramework.lua
-- Castle Kingdoms 2027 - Co-op Campaign Framework
-- Allows 2 players to play campaign missions together

local CoopCampaign = {}

local initialized = false
local isCoopActive = false
local player1Faction = 1
local player2Faction = 2
local sharedVision = true
local sharedResources = false

-- Co-op mission modifications
local COOP_MODIFIERS = {
    enemyStrengthMultiplier = 1.5,   -- Enemies are 50% stronger in co-op
    resourceBonusPerPlayer = 1.2,    -- 20% more resources per player
    sharedVisionDefault = true,      -- Players see each other's units
    sharedResourcesDefault = false,  -- Resources are separate by default
    reviveTime = 30,                 -- Seconds to revive fallen ally
}

CoopCampaign.MODIFIERS = COOP_MODIFIERS

function CoopCampaign.init()
    if initialized then return end
    initialized = true
    print("[CoopCampaign] Initialized (2-player co-op support)")
end

function CoopCampaign.start(missionId)
    if not initialized then CoopCampaign.init() end

    isCoopActive = true
    print("[CoopCampaign] Starting co-op mission: " .. tostring(missionId))

    -- Apply co-op modifiers
    local BalanceConfig = require("objects.Config.BalanceConfig")
    if BalanceConfig.combat then
        -- Increase enemy health for co-op balance
        for unitName, stats in pairs(BalanceConfig.combat.units or {}) do
            -- Only modify AI units (not player units)
            if unitName ~= "Lord" and unitName ~= "Peasant" then
                stats.health = math.floor((stats.health or 100) * COOP_MODIFIERS.enemyStrengthMultiplier)
            end
        end
    end

    -- Give resource bonus to both players
    if _G.state then
        _G.state.gold = (_G.state.gold or 0) + 200  -- Co-op bonus gold
        if _G.state.resources then
            _G.state.resources.wood = (_G.state.resources.wood or 0) + 20
            _G.state.resources.stone = (_G.state.resources.stone or 0) + 10
        end
    end

    -- Set up shared vision if enabled
    if sharedVision then
        local DiplomacyController = require("objects.Network.DiplomacyController")
        DiplomacyController.init()
        DiplomacyController.setMyPlayerId(player1Faction)
        DiplomacyController._setRelation(player1Faction, player2Faction, "allied")
    end

    -- Emit event
    if _G.GameEventBus then
        _G.GameEventBus.emit("coop_started", {
            missionId = missionId,
            player1 = player1Faction,
            player2 = player2Faction,
            sharedVision = sharedVision,
            sharedResources = sharedResources,
        })
    end

    if _G.VoiceOver then
        _G.VoiceOver.notify("coop_started", "Kooperativna kampanja zaceta!")
    end

    return true
end

function CoopCampaign.stop()
    if not isCoopActive then return end
    isCoopActive = false

    if _G.GameEventBus then
        _G.GameEventBus.emit("coop_ended")
    end

    print("[CoopCampaign] Co-op ended")
end

function CoopCampaign.isActive()
    return isCoopActive
end

function CoopCampaign.setSharedVision(enabled)
    sharedVision = enabled
    print("[CoopCampaign] Shared vision: " .. tostring(enabled))
end

function CoopCampaign.setSharedResources(enabled)
    sharedResources = enabled
    print("[CoopCampaign] Shared resources: " .. tostring(enabled))
end

function CoopCampaign.hasSharedVision()
    return sharedVision
end

function CoopCampaign.hasSharedResources()
    return sharedResources
end

-- Check if a player is an ally in co-op
function CoopCampaign.isAlly(factionA, factionB)
    if not isCoopActive then return false end
    return (factionA == player1Faction and factionB == player2Faction)
        or (factionA == player2Faction and factionB == player1Faction)
end

-- Share resources between co-op players
function CoopCampaign.shareResource(resourceType, amount, fromFaction, toFaction)
    if not isCoopActive or not sharedResources then return false end
    if not CoopCampaign.isAlly(fromFaction, toFaction) then return false end

    -- In single-machine co-op, both players share the same state
    -- In network co-op, this would send a network message
    if _G.GameEventBus then
        _G.GameEventBus.emit("resource_shared", {
            type = resourceType,
            amount = amount,
            from = fromFaction,
            to = toFaction,
        })
    end

    return true
end

-- Get co-op info
function CoopCampaign.getInfo()
    return {
        active = isCoopActive,
        player1 = player1Faction,
        player2 = player2Faction,
        sharedVision = sharedVision,
        sharedResources = sharedResources,
        enemyMultiplier = COOP_MODIFIERS.enemyStrengthMultiplier,
        resourceBonus = COOP_MODIFIERS.resourceBonusPerPlayer,
    }
end

-- Get list of co-op compatible missions
function CoopCampaign.getCoopMissions()
    return {
        -- Original 5 co-op missions
        { id = "mission1", name = "Vrnitev v Fernhaven", difficulty = 1, era = "Fernhaven Saga" },
        { id = "mission2", name = "Prvi branilci", difficulty = 2, era = "Fernhaven Saga" },
        { id = "mission5", name = "Kralj banditov", difficulty = 3, era = "Fernhaven Saga" },
        { id = "mission8", name = "Katedrala", difficulty = 4, era = "Fernhaven Saga" },
        { id = "mission10", name = "Prestol Valdemarja", difficulty = 5, era = "Fernhaven Saga" },
        -- Castle Kingdoms 2027 v2.5.3: 5 new historical co-op missions (Norman Conquest)
        { id = "mission11", name = "Hastings 1066 (Co-op)", difficulty = 3, era = "Norman Conquest" },
        { id = "mission13", name = "Pustošenje severa (Co-op)", difficulty = 4, era = "Norman Conquest" },
        { id = "mission17", name = "Škotska kampanja (Co-op)", difficulty = 4, era = "Norman Conquest" },
        { id = "mission18", name = "Danska invazija (Co-op)", difficulty = 5, era = "Norman Conquest" },
        { id = "mission20", name = "Obramba Normandije (Co-op)", difficulty = 5, era = "Norman Conquest" },
    }
end

return CoopCampaign
