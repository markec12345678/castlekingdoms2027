-- objects/Economy/TradeGuildSystem.lua
-- Castle Kingdoms 2027 v3.0.9 - Trade Guild System
--
-- Manages medieval trade guilds: membership, perks, rivalries, and guild hall
-- construction. Guilds provide economic bonuses and unlock specialist units.
--
-- Features:
-- - 5 guild types (Merchant, Smith, Carpenter, Mason, Brewer)
-- - 4 membership tiers (Apprentice, Journeyman, Master, Guildmaster)
-- - Guild perks (production bonuses, exclusive units, trade discounts)
-- - Guild hall construction (upgradeable)
-- - Inter-guild rivalry and alliances
-- - Guild quests and contracts
-- - Guild treasury and member dues

local TradeGuild = {}

-- ============================================================
-- GUILD DEFINITIONS
-- ============================================================
local GUILDS = {
    merchants = {
        name = "Trgovski ceh",
        nameEn = "Merchant Guild",
        color = { 0.85, 0.7, 0.2 },
        emblem = "⚖",
        primaryResource = "gold",
        perk = {
            tradeDiscount = 0.15,      -- 15% cheaper trades
            marketFeeReduction = 0.50, -- 50% lower market fees
            caravanSpeedBonus = 1.25,
        },
        specialistUnit = "caravan_master",
        description = "Povezuje trgovce, zniža tržnine in poveča hitrost karavan.",
        hallCost = { gold = 800, wood = 200, stone = 100 },
        weeklyDues = 20,
    },
    smiths = {
        name = "Ceh kovačev",
        nameEn = "Smith Guild",
        color = { 0.7, 0.3, 0.1 },
        emblem = "⚒",
        primaryResource = "iron",
        perk = {
            weaponQualityBonus = 0.30,  -- 30% better weapons
            armorQualityBonus = 0.25,
            productionMultiplier = 1.40, -- 40% faster smithing
        },
        specialistUnit = "master_smith",
        description = "Izboljša kakovost orožja in oklepov, hitrejša proizvodnja.",
        hallCost = { gold = 1000, wood = 150, stone = 200, iron = 50 },
        weeklyDues = 25,
    },
    carpenters = {
        name = "Ceh tesarjev",
        nameEn = "Carpenter Guild",
        color = { 0.55, 0.35, 0.15 },
        emblem = "🪓",
        primaryResource = "wood",
        perk = {
            woodProductionBonus = 0.50,
            constructionSpeedBonus = 0.30,
            siegeEngineDiscount = 0.20,
        },
        specialistUnit = "master_carpenter",
        description = "Poveča proizvodnjo lesa in pospeši gradnjo zgradb in oblegovalnih strojev.",
        hallCost = { gold = 600, wood = 300, stone = 50 },
        weeklyDues = 15,
    },
    masons = {
        name = "Ceh zidarski",
        nameEn = "Mason Guild",
        color = { 0.45, 0.45, 0.50 },
        emblem = "⛏",
        primaryResource = "stone",
        perk = {
            stoneProductionBonus = 0.50,
            buildingHealthBonus = 0.40,
            fortificationDiscount = 0.25,
        },
        specialistUnit = "master_mason",
        description = "Poveča proizvodnjo kamna, zgradbe bolj odporne, ceneje utrdbe.",
        hallCost = { gold = 700, wood = 100, stone = 400 },
        weeklyDues = 18,
    },
    brewers = {
        name = "Ceh pivovarov",
        nameEn = "Brewer Guild",
        color = { 0.75, 0.55, 0.10 },
        emblem = "🍺",
        primaryResource = "food",
        perk = {
            foodProductionBonus = 0.20,
            happinessBonus = 10,
            moraleBonus = 15,
            aleExportValue = 1.5,
        },
        specialistUnit = "master_brewer",
        description = "Poveča srečo in moralo, dodatna proizvodnja hrane in izvoz piva.",
        hallCost = { gold = 500, wood = 200, food = 100 },
        weeklyDues = 12,
    },
}

-- ============================================================
-- MEMBERSHIP TIERS
-- ============================================================
local TIERS = {
    apprentice = {
        name = "Vajenec",
        nameEn = "Apprentice",
        requirement = { gold = 50, days = 7 },
        perkMultiplier = 0.30,
        maxMembers = 20,
    },
    journeyman = {
        name = "Pomočnik",
        nameEn = "Journeyman",
        requirement = { gold = 200, days = 30 },
        perkMultiplier = 0.60,
        maxMembers = 10,
    },
    master = {
        name = "Mojster",
        nameEn = "Master",
        requirement = { gold = 800, days = 90 },
        perkMultiplier = 1.00,
        maxMembers = 5,
    },
    guildmaster = {
        name = "Starešina ceha",
        nameEn = "Guildmaster",
        requirement = { gold = 2500, days = 365 },
        perkMultiplier = 1.50,
        maxMembers = 1,
    },
}

-- ============================================================
-- STATE
-- ============================================================
TradeGuild.guildHalls = {}        -- Built guild halls
TradeGuild.memberships = {}       -- Player's guild memberships { [guildId] = tierId }
TradeGuild.guildReputation = {}   -- Reputation with each guild (-100 to +100)
TradeGuild.activeContracts = {}   -- Guild contracts/quests
TradeGuild.guildTreasury = {}     -- Treasury per guild
TradeGuild.rivalries = {}         -- Pairs of rival guilds
TradeGuild.alliances = {}         -- Pairs of allied guilds
TradeGuild.weeklyTimer = 0        -- Timer for weekly dues
TradeGuild.memberCounts = {}      -- Member count per tier per guild

-- ============================================================
-- INITIALIZATION
-- ============================================================
function TradeGuild.init()
    TradeGuild.guildHalls = {}
    TradeGuild.memberships = {}
    TradeGuild.guildReputation = {
        merchants = 0, smiths = 0, carpenters = 0, masons = 0, brewers = 0,
    }
    TradeGuild.activeContracts = {}
    TradeGuild.guildTreasury = {
        merchants = 0, smiths = 0, carpenters = 0, masons = 0, brewers = 0,
    }
    TradeGuild.rivalries = {
        { "smiths", "carpenters" },  -- both use wood/iron
        { "masons", "carpenters" },  -- both use wood
    }
    TradeGuild.alliances = {
        { "smiths", "masons" },      -- both work with stone/iron
        { "merchants", "brewers" },  -- trade partnership
    }
    TradeGuild.weeklyTimer = 0
    TradeGuild.memberCounts = {}
    print("[TradeGuild] Trade Guild System initialized (5 guilds, 4 tiers)")
end

-- ============================================================
-- GUILD HALL CONSTRUCTION
-- ============================================================
function TradeGuild.canBuildHall(guildId)
    local def = GUILDS[guildId]
    if not def then return false, "Neznan ceh" end
    -- Check if already built
    for _, hall in ipairs(TradeGuild.guildHalls) do
        if hall.guildId == guildId then
            return false, "Cehovska dvorana že zgrajena"
        end
    end
    -- Check resources
    if not _G.state then return false, "Brez stanja" end
    local cost = def.hallCost
    if _G.state.gold < (cost.gold or 0) then return false, "Premalo zlata" end
    if _G.state.resources then
        for res, amt in pairs(cost) do
            if res ~= "gold" then
                if (_G.state.resources[res] or 0) < amt then
                    return false, "Premalo " .. res
                end
            end
        end
    end
    -- Check reputation (must be neutral or better)
    if (TradeGuild.guildReputation[guildId] or 0) < -20 then
        return false, "Premajhen ugled pri cehu"
    end
    return true
end

function TradeGuild.buildHall(guildId, x, y)
    local ok, err = TradeGuild.canBuildHall(guildId)
    if not ok then return false, err end
    local def = GUILDS[guildId]
    -- Deduct resources
    local cost = def.hallCost
    _G.state.gold = _G.state.gold - (cost.gold or 0)
    if _G.state.resources then
        for res, amt in pairs(cost) do
            if res ~= "gold" then
                _G.state.resources[res] = (_G.state.resources[res] or 0) - amt
            end
        end
    end
    -- Register hall
    table.insert(TradeGuild.guildHalls, {
        guildId = guildId,
        x = x or 0,
        y = y or 0,
        level = 1,
        builtDay = os.time(),
    })
    -- Auto-join as apprentice
    TradeGuild.joinGuild(guildId, "apprentice")
    -- Notify
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Cehovska dvorana zgrajena: " .. def.name, "success")
    end
    if _G.GameEventBus then
        pcall(_G.GameEventBus.publish, "GUILD_HALL_BUILT", { guildId = guildId })
    end
    return true
end

function TradeGuild.upgradeHall(guildId)
    for _, hall in ipairs(TradeGuild.guildHalls) do
        if hall.guildId == guildId then
            if hall.level >= 3 then return false, "Dvorana je že na najvišji stopnji" end
            local cost = hall.level * 500
            if _G.state and _G.state.gold >= cost then
                _G.state.gold = _G.state.gold - cost
                hall.level = hall.level + 1
                if _G.NotificationCenter then
                    pcall(_G.NotificationCenter.notify, "Cehovska dvorana nadgrajena na stopnjo " .. hall.level, "info")
                end
                return true
            end
            return false, "Premalo zlata"
        end
    end
    return false, "Dvorana ne obstaja"
end

-- ============================================================
-- MEMBERSHIP MANAGEMENT
-- ============================================================
function TradeGuild.joinGuild(guildId, tierId)
    local tier = TIERS[tierId]
    if not tier then return false, "Neznana stopnja" end
    -- Check if hall exists
    local hasHall = false
    for _, hall in ipairs(TradeGuild.guildHalls) do
        if hall.guildId == guildId then hasHall = true; break end
    end
    if not hasHall then return false, "Najprej zgradi cehovsko dvorano" end
    -- Check current tier
    local current = TradeGuild.memberships[guildId]
    if current then
        local curIdx = TradeGuild.tierIndex(current)
        local newIdx = TradeGuild.tierIndex(tierId)
        if newIdx <= curIdx then
            return false, "Že višja ali enaka stopnja"
        end
    end
    -- Check cost
    if not _G.state or _G.state.gold < (tier.requirement.gold or 0) then
        return false, "Premalo zlata za včlanitev"
    end
    _G.state.gold = _G.state.gold - (tier.requirement.gold or 0)
    -- Set membership
    TradeGuild.memberships[guildId] = tierId
    -- Boost reputation
    TradeGuild.guildReputation[guildId] = (TradeGuild.guildReputation[guildId] or 0) + 10
    -- Notify
    local def = GUILDS[guildId]
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            "Včlanjen v " .. (def and def.name or "ceh") .. " kot " .. tier.name, "success")
    end
    if _G.GameEventBus then
        pcall(_G.GameEventBus.publish, "GUILD_JOINED", { guildId = guildId, tier = tierId })
    end
    return true
end

function TradeGuild.leaveGuild(guildId)
    if TradeGuild.memberships[guildId] then
        TradeGuild.memberships[guildId] = nil
        TradeGuild.guildReputation[guildId] = (TradeGuild.guildReputation[guildId] or 0) - 5
        if _G.NotificationCenter then
            local def = GUILDS[guildId]
            pcall(_G.NotificationCenter.notify, "Zapustil " .. (def and def.name or "ceh"), "info")
        end
        return true
    end
    return false
end

function TradeGuild.tierIndex(tierId)
    local order = { "apprentice", "journeyman", "master", "guildmaster" }
    for i, t in ipairs(order) do
        if t == tierId then return i end
    end
    return 0
end

function TradeGuild.canUpgradeTier(guildId)
    local current = TradeGuild.memberships[guildId]
    if not current then return false, "Nisi član" end
    local idx = TradeGuild.tierIndex(current)
    if idx >= 4 then return false, "Že na najvišji stopnji" end
    local order = { "apprentice", "journeyman", "master", "guildmaster" }
    local next_tier = TIERS[order[idx + 1]]
    -- Check reputation
    if (TradeGuild.guildReputation[guildId] or 0) < (idx * 20) then
        return false, "Premajhen ugled"
    end
    -- Check gold
    if _G.state and _G.state.gold < (next_tier.requirement.gold or 0) then
        return false, "Premalo zlata"
    end
    return true, order[idx + 1]
end

function TradeGuild.upgradeTier(guildId)
    local ok, nextTier = TradeGuild.canUpgradeTier(guildId)
    if not ok then return false, nextTier end
    return TradeGuild.joinGuild(guildId, nextTier)
end

-- ============================================================
-- GUILD PERKS
-- ============================================================
function TradeGuild.getActivePerks()
    local perks = {
        tradeDiscount = 0,
        marketFeeReduction = 0,
        caravanSpeedBonus = 1.0,
        weaponQualityBonus = 0,
        armorQualityBonus = 0,
        productionMultiplier = 1.0,
        woodProductionBonus = 0,
        constructionSpeedBonus = 0,
        siegeEngineDiscount = 0,
        stoneProductionBonus = 0,
        buildingHealthBonus = 0,
        fortificationDiscount = 0,
        foodProductionBonus = 0,
        happinessBonus = 0,
        moraleBonus = 0,
    }
    for guildId, tierId in pairs(TradeGuild.memberships) do
        local def = GUILDS[guildId]
        local tier = TIERS[tierId]
        if def and tier then
            local mult = tier.perkMultiplier
            for perkKey, perkVal in pairs(def.perk or {}) do
                if type(perkVal) == "number" then
                    if perkKey:find("Bonus") or perkKey:find("Discount") or perkKey:find("Reduction") then
                        -- Additive bonuses (multiplied by tier factor)
                        perks[perkKey] = (perks[perkKey] or 0) + perkVal * mult
                    elseif perkKey:find("Multiplier") then
                        -- Multiplicative
                        perks[perkKey] = perks[perkKey] * (1 + (perkVal - 1) * mult)
                    else
                        perks[perkKey] = (perks[perkKey] or 0) + perkVal * mult
                    end
                end
            end
            -- Apply hall level bonus
            for _, hall in ipairs(TradeGuild.guildHalls) do
                if hall.guildId == guildId then
                    local hallBonus = 1 + (hall.level - 1) * 0.10
                    for k, v in pairs(perks) do
                        if type(v) == "number" and k ~= "caravanSpeedBonus" and k:find("Multiplier") == nil then
                            perks[k] = v * hallBonus
                        end
                    end
                end
            end
        end
    end
    return perks
end

-- ============================================================
-- REPUTATION
-- ============================================================
function TradeGuild.changeReputation(guildId, delta)
    TradeGuild.guildReputation[guildId] = math.max(-100, math.min(100,
        (TradeGuild.guildReputation[guildId] or 0) + delta))
end

function TradeGuild.getReputationLevel(guildId)
    local rep = TradeGuild.guildReputation[guildId] or 0
    if rep >= 75 then return "exalted", "Oboževan"
    elseif rep >= 50 then return "honored", "Spoštovan"
    elseif rep >= 25 then return "friendly", "Prijateljski"
    elseif rep >= -25 then return "neutral", "Nevtralen"
    elseif rep >= -50 then return "unfriendly", "Neprijateljski"
    elseif rep >= -75 then return "hostile", "Sovražen"
    else return "hated", "Osovražen" end
end

-- ============================================================
-- GUILD CONTRACTS / QUESTS
-- ============================================================
local CONTRACT_TYPES = {
    delivery = {
        name = "Dostava blaga",
        reward = { gold = 200, reputation = 5 },
        timeLimit = 300,  -- 5 min
        description = "Dostavi 50 lesa cehu v roku 5 minut.",
    },
    production_quota = {
        name = "Proizvodna kvota",
        reward = { gold = 500, reputation = 10 },
        timeLimit = 600,
        description = "Proizvedi 100 železa v 10 minutah.",
    },
    recruitment = {
        name = "Rekrutacija",
        reward = { gold = 300, reputation = 8 },
        timeLimit = 480,
        description = "Rekrutiraj 10 novih članov za ceh.",
    },
    sabotage_rival = {
        name = "Sabotaža rivala",
        reward = { gold = 800, reputation = 15 },
        timeLimit = 720,
        description = "Zmanjšaj ugled rivalnega ceha za 20 točk.",
    },
    specialty_craft = {
        name = "Posebna obrt",
        reward = { gold = 1000, reputation = 20 },
        timeLimit = 900,
        description = "Izdelaj redko mojstrsko delo za ceh.",
    },
}

function TradeGuild.generateContract(guildId)
    if not TradeGuild.memberships[guildId] then return nil end
    local contractTypes = {}
    for k, _ in pairs(CONTRACT_TYPES) do
        table.insert(contractTypes, k)
    end
    local typeId = contractTypes[math.random(#contractTypes)]
    local def = CONTRACT_TYPES[typeId]
    local contract = {
        id = tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        guildId = guildId,
        type = typeId,
        reward = def.reward,
        timeLimit = def.timeLimit,
        timeRemaining = def.timeLimit,
        progress = 0,
        completed = false,
        failed = false,
    }
    table.insert(TradeGuild.activeContracts, contract)
    return contract
end

function TradeGuild.completeContract(contractId)
    for _, c in ipairs(TradeGuild.activeContracts) do
        if c.id == contractId and not c.completed and not c.failed then
            c.completed = true
            -- Award rewards
            if _G.state then
                _G.state.gold = (_G.state.gold or 0) + (c.reward.gold or 0)
            end
            TradeGuild.changeReputation(c.guildId, c.reward.reputation or 5)
            if _G.NotificationCenter then
                pcall(_G.NotificationCenter.notify,
                    "Cehovska pogodba končana! +" .. (c.reward.gold or 0) .. " zlata", "success")
            end
            if _G.GameEventBus then
                pcall(_G.GameEventBus.publish, "GUILD_CONTRACT_COMPLETE", { contractId = contractId })
            end
            return true
        end
    end
    return false
end

function TradeGuild.failContract(contractId)
    for _, c in ipairs(TradeGuild.activeContracts) do
        if c.id == contractId and not c.completed and not c.failed then
            c.failed = true
            TradeGuild.changeReputation(c.guildId, -10)
            if _G.NotificationCenter then
                pcall(_G.NotificationCenter.notify, "Cehovska pogodba spodletela!", "warning")
            end
            return true
        end
    end
    return false
end

-- ============================================================
-- WEEKLY DUES
-- ============================================================
function TradeGuild.collectWeeklyDues()
    local totalCollected = 0
    for guildId, tierId in pairs(TradeGuild.memberships) do
        local def = GUILDS[guildId]
        local tier = TIERS[tierId]
        if def and tier then
            local dues = def.weeklyDues * TradeGuild.tierIndex(tierId)
            -- Add to guild treasury
            TradeGuild.guildTreasury[guildId] = (TradeGuild.guildTreasury[guildId] or 0) + dues
            totalCollected = totalCollected + dues
            -- Player pays dues (small reputation gain for paying on time)
            TradeGuild.changeReputation(guildId, 2)
        end
    end
    if totalCollected > 0 and _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Tedenske cehovnine: %d zlata", totalCollected), "info")
    end
    return totalCollected
end

function TradeGuild.withdrawFromTreasury(guildId, amount)
    if not TradeGuild.memberships[guildId] then return false, "Nisi član" end
    local tier = TradeGuild.memberships[guildId]
    if tier ~= "guildmaster" then return false, "Samo starešina lahko dvigne zakladnico" end
    if (TradeGuild.guildTreasury[guildId] or 0) < amount then
        return false, "Premalo sredstev v zakladnici"
    end
    TradeGuild.guildTreasury[guildId] = TradeGuild.guildTreasury[guildId] - amount
    if _G.state then
        _G.state.gold = (_G.state.gold or 0) + amount
    end
    return true
end

-- ============================================================
-- INTER-GUILD DIPLOMACY
-- ============================================================
function TradeGuild.areRivals(guildA, guildB)
    for _, pair in ipairs(TradeGuild.rivalries) do
        if (pair[1] == guildA and pair[2] == guildB) or
           (pair[1] == guildB and pair[2] == guildA) then
            return true
        end
    end
    return false
end

function TradeGuild.areAllies(guildA, guildB)
    for _, pair in ipairs(TradeGuild.alliances) do
        if (pair[1] == guildA and pair[2] == guildB) or
           (pair[1] == guildB and pair[2] == guildA) then
            return true
        end
    end
    return false
end

function TradeGuild.formAlliance(guildA, guildB)
    if TradeGuild.areRivals(guildA, guildB) then
        return false, "Cehova sta rivala"
    end
    if TradeGuild.areAllies(guildA, guildB) then
        return false, "Cehova sta že zaveznika"
    end
    table.insert(TradeGuild.alliances, { guildA, guildB })
    return true
end

-- ============================================================
-- UPDATE
-- ============================================================
function TradeGuild.update(dt)
    if not _G.state then return end
    -- Weekly timer (every 5 min real time = 1 week game time)
    TradeGuild.weeklyTimer = TradeGuild.weeklyTimer + dt
    if TradeGuild.weeklyTimer >= 300 then  -- 5 minutes
        TradeGuild.weeklyTimer = 0
        TradeGuild.collectWeeklyDues()
        -- Generate new contracts
        for guildId, _ in pairs(TradeGuild.memberships) do
            if math.random() < 0.5 then
                TradeGuild.generateContract(guildId)
            end
        end
    end
    -- Update contract timers
    for _, c in ipairs(TradeGuild.activeContracts) do
        if not c.completed and not c.failed then
            c.timeRemaining = c.timeRemaining - dt
            if c.timeRemaining <= 0 then
                TradeGuild.failContract(c.id)
            end
        end
    end
    -- Clean up old contracts
    for i = #TradeGuild.activeContracts, 1, -1 do
        local c = TradeGuild.activeContracts[i]
        if c.completed or c.failed then
            c.cleanupTimer = (c.cleanupTimer or 60) - dt
            if c.cleanupTimer <= 0 then
                table.remove(TradeGuild.activeContracts, i)
            end
        end
    end
end

-- ============================================================
-- HELPERS
-- ============================================================
function TradeGuild.getGuildInfo(guildId) return GUILDS[guildId] end
function TradeGuild.getTierInfo(tierId) return TIERS[tierId] end
function TradeGuild.getContractTypeInfo(typeId) return CONTRACT_TYPES[typeId] end

function TradeGuild.getStats()
    local stats = {
        numHalls = #TradeGuild.guildHalls,
        memberships = {},
        reputation = {},
        treasury = {},
        activeContracts = #TradeGuild.activeContracts,
    }
    for guildId, tier in pairs(TradeGuild.memberships) do
        stats.memberships[guildId] = tier
    end
    for guildId, rep in pairs(TradeGuild.guildReputation) do
        local _, name = TradeGuild.getReputationLevel(guildId)
        stats.reputation[guildId] = { value = rep, level = name }
    end
    for guildId, t in pairs(TradeGuild.guildTreasury) do
        stats.treasury[guildId] = t
    end
    return stats
end

return TradeGuild
