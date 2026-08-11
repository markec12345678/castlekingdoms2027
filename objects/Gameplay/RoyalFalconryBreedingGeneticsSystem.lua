-- objects/Gameplay/RoyalFalconryBreedingGeneticsSystem.lua
-- Castle Kingdoms 2027 v3.4.4 - Royal Falconry Breeding & Genetics System
--
-- Advanced breeding system for falcons with genetic traits inheritance.
-- Builds on the basic Falconer system with deeper genetics mechanics.
--
-- Features:
-- - 8 genetic traits (speed, strength, intelligence, aggression, loyalty, vision, stamina, size)
-- - 6 raptor bloodlines (royal, wild, mountain, desert, northern, imperial)
-- - Trait inheritance (parents pass traits to offspring)
-- - Mutation system (rare random improvements)
-- - Bloodline purity tracking
-- - Genetic diversity management
-- - Champion breeding program
-- - Lineage tracking (family trees)
-- - Breeding contracts with other falconers

local Genetics = {}

-- ============================================================
-- GENETIC TRAITS
-- ============================================================
local TRAITS = {
    speed = {
        name = "Hitrost",
        nameEn = "Speed",
        minValue = 1,
        maxValue = 100,
        description = "Vpliva na lovski uspeh pri hitri divjadi.",
    },
    strength = {
        name = "Moč",
        nameEn = "Strength",
        minValue = 1,
        maxValue = 100,
        description = "Omogoča lov večje divjadi.",
    },
    intelligence = {
        name = "Inteligenca",
        nameEn = "Intelligence",
        minValue = 1,
        maxValue = 100,
        description = "Hitrejše urjenje in boljše odločanje.",
    },
    aggression = {
        name = "Agresivnost",
        nameEn = "Aggression",
        minValue = 1,
        maxValue = 100,
        description = "Večja agresivnost pri lovu, vendar težje urjenje.",
    },
    loyalty = {
        name = "Zvestoba",
        nameEn = "Loyalty",
        minValue = 1,
        maxValue = 100,
        description = "Manjša verjetnost pobega.",
    },
    vision = {
        name = "Vid",
        nameEn = "Vision",
        minValue = 1,
        maxValue = 100,
        description = "Boljše zaznavanje plena od daleč.",
    },
    stamina = {
        name = "Vzdržljivost",
        nameEn = "Stamina",
        minValue = 1,
        maxValue = 100,
        description = "Daljši lov brez utrujenosti.",
    },
    size = {
        name = "Velikost",
        nameEn = "Size",
        minValue = 1,
        maxValue = 100,
        description = "Večje ptice lahko lovijo večji plen.",
    },
}

-- ============================================================
-- BLOODLINES
-- ============================================================
local BLOODLINES = {
    royal = {
        name = "Kraljevska krvna linija",
        nameEn = "Royal Bloodline",
        traitBonus = { loyalty = 15, size = 10 },
        rarity = 5,
        description = "Najplemenitejša linija, zvestoba in velikost.",
    },
    wild = {
        name = "Divja krvna linija",
        nameEn = "Wild Bloodline",
        traitBonus = { aggression = 20, speed = 10 },
        rarity = 2,
        description = "Divja a hitra, težja za urjenje.",
    },
    mountain = {
        name = "Gorska krvna linija",
        nameEn = "Mountain Bloodline",
        traitBonus = { stamina = 20, strength = 10 },
        rarity = 3,
        description = "Vzdržljiva in močna.",
    },
    desert = {
        name = "Puščavska krvna linija",
        nameEn = "Desert Bloodline",
        traitBonus = { vision = 20, speed = 15 },
        rarity = 4,
        description = "Izjemno oster vid in hitrost.",
    },
    northern = {
        name = "Severna krvna linija",
        nameEn = "Northern Bloodline",
        traitBonus = { size = 15, strength = 15, stamina = 10 },
        rarity = 4,
        description = "Velike in močne ptice s severa.",
    },
    imperial = {
        name = "Cesarska krvna linija",
        nameEn = "Imperial Bloodline",
        traitBonus = { intelligence = 20, loyalty = 10, vision = 10 },
        rarity = 5,
        description = "Najredkejša, najinteligentnejša linija.",
    },
}

-- ============================================================
-- STATE
-- ============================================================
Genetics.registeredBirds = {}            -- Birds with genetic data
Genetics.lineageTree = {}                -- Family trees
Genetics.activeBreedings = {}            -- Breeding pairs
Genetics.champions = {}                  -- Champion birds
Genetics.totalBred = 0
Genetics.totalMutations = 0
Genetics.totalChampions = 0
Genetics.dayTimer = 0

-- ============================================================
-- INITIALIZATION
-- ============================================================
function Genetics.init()
    Genetics.registeredBirds = {}
    Genetics.lineageTree = {}
    Genetics.activeBreedings = {}
    Genetics.champions = {}
    Genetics.totalBred = 0
    Genetics.totalMutations = 0
    Genetics.totalChampions = 0
    Genetics.dayTimer = 0
    print("[Genetics] Royal Falconry Breeding & Genetics System initialized (8 traits, 6 bloodlines)")
end

-- ============================================================
-- BIRD REGISTRATION
-- ============================================================
function Genetics.registerBird(birdId, bloodline, parentTraits)
    local bloodlineDef = BLOODLINES[bloodline] or BLOODLINES.wild
    -- Generate traits
    local traits = {}
    for traitId, traitDef in pairs(TRAITS) do
        local baseValue = math.random(30, 60)
        -- Apply bloodline bonus
        if bloodlineDef.traitBonus and bloodlineDef.traitBonus[traitId] then
            baseValue = baseValue + bloodlineDef.traitBonus[traitId]
        end
        -- Inherit from parents (average + variation)
        if parentTraits then
            local parentAvg = ((parentTraits[traitId] or 50) + (parentTraits[traitId] or 50)) / 2
            baseValue = math.floor((baseValue + parentAvg) / 2 + math.random(-10, 10))
        end
        -- Mutation chance (5%)
        if math.random() < 0.05 then
            local mutation = math.random(5, 20)
            if math.random() < 0.5 then mutation = -mutation end
            baseValue = baseValue + mutation
            Genetics.totalMutations = Genetics.totalMutations + 1
            if mutation > 0 and _G.NotificationCenter then
                pcall(_G.NotificationCenter.notify,
                    string.format("Mutacija! %s +%d", traitDef.name, mutation), "rare")
            end
        end
        traits[traitId] = math.max(traitDef.minValue, math.min(traitDef.maxValue, baseValue))
    end
    local bird = {
        id = birdId,
        bloodline = bloodline,
        traits = traits,
        generation = parentTraits and 2 or 1,
        parents = nil,
        registeredDay = os.time(),
    }
    Genetics.registeredBirds[birdId] = bird
    -- Check for champion potential
    Genetics.checkChampion(bird)
    return bird
end

function Genetics.checkChampion(bird)
    -- Champion: average trait > 75
    local total = 0
    local count = 0
    for _, value in pairs(bird.traits) do
        total = total + value
        count = count + 1
    end
    local average = total / count
    if average >= 75 then
        table.insert(Genetics.champions, {
            birdId = bird.id,
            averageTrait = math.floor(average),
            bloodline = bird.bloodline,
            crowned = os.time(),
        })
        Genetics.totalChampions = Genetics.totalChampions + 1
        if _G.NotificationCenter then
            pcall(_G.NotificationCenter.notify,
                string.format("ŠAMPION vzrejen! Povprečje: %d (linija: %s)",
                    math.floor(average), BLOODLINES[bird.bloodline].name), "rare")
        end
        if _G.GameEventBus then
            pcall(_G.GameEventBus.publish, "CHAMPION_BRED", {
                birdId = bird.id, average = math.floor(average),
            })
        end
    end
end

-- ============================================================
-- BREEDING
-- ============================================================
function Genetics.canBreed(birdId1, birdId2)
    local bird1 = Genetics.registeredBirds[birdId1]
    local bird2 = Genetics.registeredBirds[birdId2]
    if not bird1 or not bird2 then return false, "Ptica ni registrirana" end
    -- Check bloodline compatibility (same bloodline = purer, different = more diverse)
    -- Both options are valid
    -- Check for inbreeding (same parents)
    if bird1.parents and bird2.parents then
        for _, p1 in ipairs(bird1.parents) do
            for _, p2 in ipairs(bird2.parents) do
                if p1 == p2 then
                    return false, "Preveč sorodne ptice (inbreeding)"
                end
            end
        end
    end
    return true
end

function Genetics.startBreeding(birdId1, birdId2)
    local ok, err = Genetics.canBreed(birdId1, birdId2)
    if not ok then return false, err end
    local bird1 = Genetics.registeredBirds[birdId1]
    local bird2 = Genetics.registeredBirds[birdId2]
    -- Determine offspring bloodline
    local offspringBloodline = bird1.bloodline
    if bird1.bloodline ~= bird2.bloodline then
        -- Mixed bloodline — choose one randomly
        offspringBloodline = math.random() < 0.5 and bird1.bloodline or bird2.bloodline
    end
    local breeding = {
        id = "breeding_" .. tostring(os.time()),
        parent1 = birdId1,
        parent2 = birdId2,
        offspringBloodline = offspringBloodline,
        daysRemaining = 60,  -- 60 days for genetic breeding
        started = os.time(),
    }
    table.insert(Genetics.activeBreedings, breeding)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Genetska vzreja začeta (linija: %s)",
                BLOODLINES[offspringBloodline].name), "info")
    end
    return true
end

function Genetics.completeBreeding(breeding)
    local bird1 = Genetics.registeredBirds[breeding.parent1]
    local bird2 = Genetics.registeredBirds[breeding.parent2]
    if not bird1 or not bird2 then return end
    -- Combine parent traits
    local combinedTraits = {}
    for traitId, _ in pairs(TRAITS) do
        local t1 = bird1.traits[traitId] or 50
        local t2 = bird2.traits[traitId] or 50
        combinedTraits[traitId] = math.floor((t1 + t2) / 2)
    end
    -- Create offspring
    local offspringId = "bird_gen_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999))
    local offspring = Genetics.registerBird(offspringId, breeding.offspringBloodline, combinedTraits)
    offspring.parents = { breeding.parent1, breeding.parent2 }
    offspring.generation = math.max(bird1.generation, bird2.generation) + 1
    -- Add to lineage tree
    if not Genetics.lineageTree[breeding.parent1] then
        Genetics.lineageTree[breeding.parent1] = { children = {} }
    end
    table.insert(Genetics.lineageTree[breeding.parent1].children, offspringId)
    if not Genetics.lineageTree[breeding.parent2] then
        Genetics.lineageTree[breeding.parent2] = { children = {} }
    end
    table.insert(Genetics.lineageTree[breeding.parent2].children, offspringId)
    Genetics.totalBred = Genetics.totalBred + 1
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Mladič vzrejen: generacija %d (linija: %s)",
                offspring.generation, BLOODLINES[offspring.bloodline].name), "success")
    end
    return offspring
end

-- ============================================================
-- BLOODLINE PURITY
-- ============================================================
function Genetics.getBloodlinePurity(birdId)
    local bird = Genetics.registeredBirds[birdId]
    if not bird then return 0 end
    -- Purity = how many ancestors had the same bloodline
    -- For simplicity, return based on generation and parents
    if not bird.parents then return 100 end  -- wild-caught = pure
    local purity = 100
    if bird.parents then
        -- Each mixed breeding reduces purity
        for _, parentId in ipairs(bird.parents) do
            local parent = Genetics.registeredBirds[parentId]
            if parent and parent.bloodline ~= bird.bloodline then
                purity = purity - 25
            end
        end
    end
    return math.max(0, purity)
end

-- ============================================================
-- TRAIT QUERIES
-- ============================================================
function Genetics.getBirdTraits(birdId)
    local bird = Genetics.registeredBirds[birdId]
    if not bird then return nil end
    return bird.traits
end

function Genetics.getTraitAverage(birdId)
    local traits = Genetics.getBirdTraits(birdId)
    if not traits then return 0 end
    local total, count = 0, 0
    for _, v in pairs(traits) do
        total = total + v
        count = count + 1
    end
    return total / count
end

function Genetics.getBestTrait(birdId)
    local traits = Genetics.getBirdTraits(birdId)
    if not traits then return nil, 0 end
    local bestTrait, bestValue = nil, 0
    for traitId, value in pairs(traits) do
        if value > bestValue then
            bestTrait = traitId
            bestValue = value
        end
    end
    return bestTrait, bestValue
end

-- ============================================================
-- BREEDING CONTRACTS
-- ============================================================
function Genetics.arrangeBreedingContract(targetFaction, birdId, fee)
    fee = fee or 500
    if not _G.state or (_G.state.gold or 0) < fee then
        return false, "Premalo zlata"
    end
    _G.state.gold = _G.state.gold - fee
    -- Diplomatic boost
    if _G.DiplomacyController then
        pcall(_G.DiplomacyController.changeRelation, targetFaction, 10)
    end
    -- Chance of receiving a new bird
    if math.random() < 0.70 then
        local bloodlines = {}
        for id, _ in pairs(BLOODLINES) do
            table.insert(bloodlines, id)
        end
        local newBloodline = bloodlines[math.random(#bloodlines)]
        local newBirdId = "bird_contract_" .. tostring(os.time())
        Genetics.registerBird(newBirdId, newBloodline, nil)
        if _G.NotificationCenter then
            pcall(_G.NotificationCenter.notify,
                string.format("Ptiica prejeta iz pogodbe! (linija: %s)",
                    BLOODLINES[newBloodline].name), "success")
        end
    end
    return true
end

-- ============================================================
-- UPDATE
-- ============================================================
function Genetics.update(dt)
    if not _G.state then return end
    Genetics.dayTimer = Genetics.dayTimer + dt
    if Genetics.dayTimer >= 30 then
        Genetics.dayTimer = 0
        -- Process breedings
        for i = #Genetics.activeBreedings, 1, -1 do
            local b = Genetics.activeBreedings[i]
            b.daysRemaining = b.daysRemaining - 1
            if b.daysRemaining <= 0 then
                Genetics.completeBreeding(b)
                table.remove(Genetics.activeBreedings, i)
            end
        end
    end
end

-- ============================================================
-- HELPERS
-- ============================================================
function Genetics.getTraitInfo(traitId) return TRAITS[traitId] end
function Genetics.getBloodlineInfo(bloodlineId) return BLOODLINES[bloodlineId] end

function Genetics.getStats()
    local totalAverage = 0
    local count = 0
    for _, bird in pairs(Genetics.registeredBirds) do
        totalAverage = totalAverage + Genetics.getTraitAverage(bird.id)
        count = count + 1
    end
    return {
        numBirds = count,
        activeBreedings = #Genetics.activeBreedings,
        totalBred = Genetics.totalBred,
        totalMutations = Genetics.totalMutations,
        totalChampions = Genetics.totalChampions,
        averageTraitValue = count > 0 and math.floor(totalAverage / count) or 0,
        numChampions = #Genetics.champions,
    }
end

return Genetics
