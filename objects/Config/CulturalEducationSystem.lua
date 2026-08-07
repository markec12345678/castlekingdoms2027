-- objects/Config/CulturalEducationSystem.lua
-- Castle Kingdoms 2027 v3.1.6 - Cultural & Education System
--
-- Manages literacy, scholarship, art patronage, and cultural achievements.
-- Educated populations generate more research, art, and prestige.
--
-- Features:
-- - 5 educational institutions (scriptorium, library, academy, university, observatory)
-- - 6 art forms (manuscripts, paintings, sculptures, music, poetry, architecture)
-- - Literacy rate (0-100%, affects research speed)
-- - Cultural prestige (affects diplomacy and tourism income)
-- - Famous scholars and artists (random NPC visitors)
-- - Cultural buildings grant passive bonuses
-- - Patronage system (commission artworks)
-- - Cultural achievements (milestones)
-- - Knowledge points (currency for research)

local Culture = {}

-- ============================================================
-- EDUCATIONAL INSTITUTIONS
-- ============================================================
local INSTITUTIONS = {
    scriptorium = {
        name = "Skriptorij",
        nameEn = "Scriptorium",
        cost = { gold = 300, wood = 100, stone = 50 },
        upkeep = 10,
        literacyGain = 0.5,    -- per day
        knowledgePerDay = 1.0,
        capacity = 5,           -- monks/scribes
        minPopulation = 50,
        description = "Samostansko kopiranje knjig.",
    },
    library = {
        name = "Knjižnica",
        nameEn = "Library",
        cost = { gold = 800, wood = 200, stone = 200 },
        upkeep = 25,
        literacyGain = 1.0,
        knowledgePerDay = 2.5,
        capacity = 20,
        minPopulation = 150,
        description = "Javna zbirka rokopisov in knjig.",
    },
    academy = {
        name = "Akademija",
        nameEn = "Academy",
        cost = { gold = 2000, wood = 300, stone = 500 },
        upkeep = 60,
        literacyGain = 2.0,
        knowledgePerDay = 5.0,
        capacity = 50,
        minPopulation = 300,
        description = "Višja ustanova za učenjake.",
    },
    university = {
        name = "Univerza",
        nameEn = "University",
        cost = { gold = 5000, wood = 500, stone = 1000 },
        upkeep = 150,
        literacyGain = 4.0,
        knowledgePerDay = 12.0,
        capacity = 200,
        minPopulation = 600,
        description = "Najvišja izobrazba, proizvaja učenjake.",
    },
    observatory = {
        name = "Observatorij",
        nameEn = "Observatory",
        cost = { gold = 3000, wood = 100, stone = 800, iron = 100 },
        upkeep = 80,
        literacyGain = 1.5,
        knowledgePerDay = 8.0,
        capacity = 10,
        minPopulation = 400,
        description = "Astronomska opazovalnica, napredna znanost.",
    },
}

-- ============================================================
-- ART FORMS
-- ============================================================
local ART_FORMS = {
    manuscript = {
        name = "Rokopis",
        nameEn = "Manuscript",
        cost = { gold = 100, knowledge = 5 },
        prestigeReward = 5,
        tourismBonus = 0.5,
        duration = 30,
        description = "Iluminiran rokopis z verskimi motivi.",
    },
    painting = {
        name = "Slika",
        nameEn = "Painting",
        cost = { gold = 300, knowledge = 10 },
        prestigeReward = 12,
        tourismBonus = 1.0,
        duration = 45,
        description = "Oljna slika portreta ali krajine.",
    },
    sculpture = {
        name = "Kip",
        nameEn = "Sculpture",
        cost = { gold = 800, stone = 100, knowledge = 20 },
        prestigeReward = 25,
        tourismBonus = 2.0,
        duration = 90,
        description = "Marmorni ali bronast kip vladarja.",
    },
    music = {
        name = "Glasba",
        nameEn = "Music",
        cost = { gold = 200, knowledge = 8 },
        prestigeReward = 8,
        happinessBonus = 5,
        duration = 60,
        description = "Kompozicija za dvorni orkester.",
    },
    poetry = {
        name = "Poezija",
        nameEn = "Poetry",
        cost = { gold = 50, knowledge = 15 },
        prestigeReward = 6,
        happinessBonus = 3,
        duration = 90,
        description = "Ep ali zbirka pesmi v latinščini.",
    },
    architecture = {
        name = "Arhitektura",
        nameEn = "Architecture",
        cost = { gold = 2000, stone = 500, knowledge = 50 },
        prestigeReward = 50,
        tourismBonus = 5.0,
        duration = 180,
        description = "Velika gradnja — katedrala, palača, most.",
    },
}

-- ============================================================
-- FAMOUS FIGURES (visitors)
-- ============================================================
local FAMOUS_FIGURES = {
    { name = "Tomaž Akvinski", type = "scholar", bonus = { knowledge = 50 }, stayDuration = 60 },
    { name = "Hildegarda Bingenska", type = "scholar", bonus = { knowledge = 40, faith = 20 }, stayDuration = 90 },
    { name = "Roger Bacon", type = "scientist", bonus = { knowledge = 60 }, stayDuration = 45 },
    { name = "Dante Alighieri", type = "poet", bonus = { prestige = 30, happiness = 10 }, stayDuration = 120 },
    { name = "Giotto", type = "painter", bonus = { prestige = 25 }, stayDuration = 90 },
    { name = "Leonardo Fibonacci", type = "mathematician", bonus = { knowledge = 70 }, stayDuration = 60 },
    { name = "Albert Veliki", type = "scholar", bonus = { knowledge = 55, faith = 15 }, stayDuration = 75 },
    { name = "Frančišek Asiški", type = "saint", bonus = { faith = 50, happiness = 15 }, stayDuration = 30 },
}

-- ============================================================
-- CULTURAL ACHIEVEMENTS
-- ============================================================
local ACHIEVEMENTS = {
    first_library = {
        name = "Prva knjižnica",
        requirement = function() return Culture.countInstitutions("library") >= 1 end,
        reward = { prestige = 10, knowledge = 20 },
    },
    scholar_patron = {
        name = "Pokrovitelj učenjakov",
        requirement = function() return Culture.totalScholarsHosted >= 5 end,
        reward = { prestige = 25, knowledge = 50 },
    },
    renaissance_court = {
        name = "Renesančni dvor",
        requirement = function() return Culture.totalArtworks >= 10 end,
        reward = { prestige = 50, happiness = 10 },
    },
    university_founded = {
        name = "Univerza ustanovljena",
        requirement = function() return Culture.countInstitutions("university") >= 1 end,
        reward = { prestige = 30, knowledge = 100 },
    },
    literacy_50 = {
        name = "50% pismenost",
        requirement = function() return Culture.literacyRate >= 50 end,
        reward = { prestige = 20, knowledgeMultiplier = 1.25 },
    },
    literacy_100 = {
        name = "100% pismenost",
        requirement = function() return Culture.literacyRate >= 100 end,
        reward = { prestige = 100, knowledgeMultiplier = 1.50 },
    },
}

-- ============================================================
-- STATE
-- ============================================================
Culture.institutions = {}          -- Built institutions
Culture.artworks = {}              -- Commissioned artworks
Culture.literacyRate = 5           -- starting literacy %
Culture.knowledgePoints = 0
Culture.culturalPrestige = 0
Culture.tourismIncome = 0          -- per day
Culture.famousVisitors = {}        -- Currently visiting
Culture.totalScholarsHosted = 0
Culture.totalArtworks = 0
Culture.achievementsUnlocked = {}
Culture.dayTimer = 0
Culture.visitorTimer = 0

-- ============================================================
-- INITIALIZATION
-- ============================================================
function Culture.init()
    Culture.institutions = {}
    Culture.artworks = {}
    Culture.literacyRate = 5
    Culture.knowledgePoints = 0
    Culture.culturalPrestige = 0
    Culture.tourismIncome = 0
    Culture.famousVisitors = {}
    Culture.totalScholarsHosted = 0
    Culture.totalArtworks = 0
    Culture.achievementsUnlocked = {}
    Culture.dayTimer = 0
    Culture.visitorTimer = 0
    print("[Culture] Cultural & Education System initialized (5 institutions, 6 art forms)")
end

-- ============================================================
-- INSTITUTION CONSTRUCTION
-- ============================================================
function Culture.canBuild(institutionId)
    local def = INSTITUTIONS[institutionId]
    if not def then return false, "Neznana ustanova" end
    if not _G.state then return false, "Brez stanja" end
    if _G.state.gold < (def.cost.gold or 0) then return false, "Premalo zlata" end
    if _G.state.resources then
        for res, amt in pairs(def.cost) do
            if res ~= "gold" and (_G.state.resources[res] or 0) < amt then
                return false, "Premalo " .. res
            end
        end
    end
    local pop = (_G.state.population or _G.state.maxPopulation or 100)
    if pop < (def.minPopulation or 0) then
        return false, "Premajhna populacija"
    end
    return true
end

function Culture.buildInstitution(institutionId, x, y)
    local ok, err = Culture.canBuild(institutionId)
    if not ok then return false, err end
    local def = INSTITUTIONS[institutionId]
    _G.state.gold = _G.state.gold - (def.cost.gold or 0)
    if _G.state.resources then
        for res, amt in pairs(def.cost) do
            if res ~= "gold" then
                _G.state.resources[res] = (_G.state.resources[res] or 0) - amt
            end
        end
    end
    table.insert(Culture.institutions, {
        type = institutionId,
        x = x or 0,
        y = y or 0,
        builtDay = os.time(),
    })
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Ustanova zgrajena: " .. def.name, "success")
    end
    if _G.GameEventBus then
        pcall(_G.GameEventBus.publish, "INSTITUTION_BUILT", { type = institutionId })
    end
    Culture.checkAchievements()
    return true
end

function Culture.countInstitutions(institutionType)
    local count = 0
    for _, inst in ipairs(Culture.institutions) do
        if not institutionType or inst.type == institutionType then
            count = count + 1
        end
    end
    return count
end

-- ============================================================
-- ART COMMISSIONING
-- ============================================================
function Culture.commissionArtwork(artType)
    local def = ART_FORMS[artType]
    if not def then return false, "Neznana umetnost" end
    if not _G.state then return false, "Brez stanja" end
    -- Check costs
    if (_G.state.gold or 0) < (def.cost.gold or 0) then
        return false, "Premalo zlata"
    end
    if Culture.knowledgePoints < (def.cost.knowledge or 0) then
        return false, "Premalo znanja"
    end
    if def.cost.stone and _G.state.resources and
       (_G.state.resources.stone or 0) < def.cost.stone then
        return false, "Premalo kamna"
    end
    -- Pay costs
    _G.state.gold = _G.state.gold - (def.cost.gold or 0)
    Culture.knowledgePoints = Culture.knowledgePoints - (def.cost.knowledge or 0)
    if def.cost.stone and _G.state.resources then
        _G.state.resources.stone = (_G.state.resources.stone or 0) - def.cost.stone
    end
    -- Create artwork (in progress)
    local artwork = {
        id = "art_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        type = artType,
        name = def.name,
        daysRemaining = def.duration,
        totalDays = def.duration,
        prestigeReward = def.prestigeReward,
        tourismBonus = def.tourismBonus or 0,
        happinessBonus = def.happinessBonus or 0,
        completed = false,
    }
    table.insert(Culture.artworks, artwork)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            "Naročeno umetniško delo: " .. def.name .. " (" .. def.duration .. " dni)", "info")
    end
    return true, artwork.id
end

function Culture.updateArtworks()
    for i = #Culture.artworks, 1, -1 do
        local a = Culture.artworks[i]
        if not a.completed then
            a.daysRemaining = a.daysRemaining - 1
            if a.daysRemaining <= 0 then
                a.completed = true
                -- Apply rewards
                Culture.culturalPrestige = Culture.culturalPrestige + a.prestigeReward
                Culture.tourismIncome = Culture.tourismIncome + a.tourismBonus
                if a.happinessBonus > 0 and _G.state and _G.state.happiness then
                    _G.state.happiness = math.min(100, _G.state.happiness + a.happinessBonus)
                end
                Culture.totalArtworks = Culture.totalArtworks + 1
                if _G.NotificationCenter then
                    pcall(_G.NotificationCenter.notify,
                        string.format("Umetniško delo končano: %s (+%d prestiž)", a.name, a.prestigeReward),
                        "success")
                end
                if _G.GameEventBus then
                    pcall(_G.GameEventBus.publish, "ARTWORK_COMPLETED", { type = a.type, prestige = a.prestigeReward })
                end
                Culture.checkAchievements()
            end
        else
            -- Old completed artworks slowly decay (clean up after 30 days)
            a.cleanupTimer = (a.cleanupTimer or 1800) - 1
            if a.cleanupTimer <= 0 then
                table.remove(Culture.artworks, i)
            end
        end
    end
end

-- ============================================================
-- FAMOUS VISITORS
-- ============================================================
function Culture.spawnVisitor()
    if #Culture.famousVisitors >= 3 then return end
    local fig = FAMOUS_FIGURES[math.random(#FAMOUS_FIGURES)]
    local visitor = {
        id = "visitor_" .. tostring(os.time()),
        name = fig.name,
        type = fig.type,
        bonus = fig.bonus,
        daysRemaining = fig.stayDuration,
    }
    table.insert(Culture.famousVisitors, visitor)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Slavni %s prispe: %s!", fig.type, fig.name), "rare")
    end
end

function Culture.updateVisitors()
    for i = #Culture.famousVisitors, 1, -1 do
        local v = Culture.famousVisitors[i]
        v.daysRemaining = v.daysRemaining - 1
        if v.daysRemaining <= 0 then
            -- Apply final bonus
            if v.bonus.knowledge then
                Culture.knowledgePoints = Culture.knowledgePoints + v.bonus.knowledge
            end
            if v.bonus.prestige then
                Culture.culturalPrestige = Culture.culturalPrestige + v.bonus.prestige
            end
            if v.bonus.faith and _G.Religion then
                pcall(function() _G.Religion.addFaith(v.bonus.faith) end)
            end
            if v.bonus.happiness and _G.state and _G.state.happiness then
                _G.state.happiness = math.min(100, _G.state.happiness + v.bonus.happiness)
            end
            Culture.totalScholarsHosted = Culture.totalScholarsHosted + 1
            if _G.NotificationCenter then
                pcall(_G.NotificationCenter.notify,
                    v.name .. " odhaja. Bonusi pridobljeni!", "info")
            end
            table.remove(Culture.famousVisitors, i)
            Culture.checkAchievements()
        end
    end
end

-- ============================================================
-- KNOWLEDGE & LITERACY
-- ============================================================
function Culture.calculateDailyKnowledge()
    local total = 0
    for _, inst in ipairs(Culture.institutions) do
        local def = INSTITUTIONS[inst.type]
        if def then total = total + def.knowledgePerDay end
    end
    -- Famous visitors add knowledge
    for _, v in ipairs(Culture.famousVisitors) do
        if v.type == "scholar" or v.type == "scientist" or v.type == "mathematician" then
            total = total + 2
        end
    end
    -- Literacy bonus
    local litBonus = 1 + (Culture.literacyRate / 200)  -- up to +50%
    return total * litBonus
end

function Culture.updateLiteracy()
    local gain = 0
    for _, inst in ipairs(Culture.institutions) do
        local def = INSTITUTIONS[inst.type]
        if def then gain = gain + def.literacyGain end
    end
    Culture.literacyRate = math.min(100, Culture.literacyRate + gain)
    Culture.checkAchievements()
end

function Culture.spendKnowledge(amount)
    if Culture.knowledgePoints >= amount then
        Culture.knowledgePoints = Culture.knowledgePoints - amount
        return true
    end
    return false
end

-- ============================================================
-- ACHIEVEMENTS
-- ============================================================
function Culture.checkAchievements()
    for id, ach in pairs(ACHIEVEMENTS) do
        if not Culture.achievementsUnlocked[id] then
            local ok = pcall(ach.requirement)
            if ok and ach.requirement() then
                Culture.achievementsUnlocked[id] = true
                -- Apply rewards
                if ach.reward.prestige then
                    Culture.culturalPrestige = Culture.culturalPrestige + ach.reward.prestige
                end
                if ach.reward.knowledge then
                    Culture.knowledgePoints = Culture.knowledgePoints + ach.reward.knowledge
                end
                if ach.reward.happiness and _G.state and _G.state.happiness then
                    _G.state.happiness = math.min(100, _G.state.happiness + ach.reward.happiness)
                end
                if _G.NotificationCenter then
                    pcall(_G.NotificationCenter.notify,
                        "KULTURNI DOSEŽEK: " .. ach.name, "rare")
                end
                if _G.GameEventBus then
                    pcall(_G.GameEventBus.publish, "CULTURAL_ACHIEVEMENT", { id = id, name = ach.name })
                end
            end
        end
    end
end

-- ============================================================
-- TOURISM INCOME
-- ============================================================
function Culture.collectTourismIncome()
    if Culture.tourismIncome > 0 and _G.state then
        _G.state.gold = (_G.state.gold or 0) + math.floor(Culture.tourismIncome)
    end
end

-- ============================================================
-- UPDATE
-- ============================================================
function Culture.update(dt)
    if not _G.state then return end
    Culture.dayTimer = Culture.dayTimer + dt
    Culture.visitorTimer = Culture.visitorTimer + dt
    if Culture.dayTimer >= 30 then
        Culture.dayTimer = 0
        -- Daily knowledge gain
        Culture.knowledgePoints = Culture.knowledgePoints + Culture.calculateDailyKnowledge()
        Culture.updateLiteracy()
        Culture.updateArtworks()
        Culture.updateVisitors()
        Culture.collectTourismIncome()
    end
    -- Visitor spawns every 3-5 minutes
    if Culture.visitorTimer >= 180 then
        Culture.visitorTimer = 0
        -- Need at least one institution to attract visitors
        if #Culture.institutions > 0 and math.random() < 0.4 then
            Culture.spawnVisitor()
        end
    end
end

-- ============================================================
-- HELPERS
-- ============================================================
function Culture.getInstitutionInfo(id) return INSTITUTIONS[id] end
function Culture.getArtFormInfo(id) return ART_FORMS[id] end

function Culture.getStats()
    return {
        literacyRate = Culture.literacyRate,
        knowledgePoints = Culture.knowledgePoints,
        culturalPrestige = Culture.culturalPrestige,
        tourismIncome = Culture.tourismIncome,
        numInstitutions = #Culture.institutions,
        numArtworks = #Culture.artworks,
        completedArtworks = Culture.totalArtworks,
        activeVisitors = #Culture.famousVisitors,
        totalScholarsHosted = Culture.totalScholarsHosted,
        achievementsUnlocked = #Culture.achievementsUnlocked,
    }
end

function Culture.getActiveBonuses()
    return {
        knowledgeMultiplier = 1 + (Culture.literacyRate / 200),
        prestigeBonus = Culture.culturalPrestige,
        happinessFromArt = 0,  -- applied immediately on completion
        tourismGold = Culture.tourismIncome,
    }
end

return Culture
