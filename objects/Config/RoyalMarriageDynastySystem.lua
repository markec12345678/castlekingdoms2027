-- objects/Config/RoyalMarriageDynastySystem.lua
-- Castle Kingdoms 2027 v3.1.7 - Royal Marriage & Dynasty System
--
-- Manages dynastic politics: royal marriages, heirs, succession, and
-- political alliances through matrimonial diplomacy.
--
-- Features:
-- - 6 royal houses (each with traits, claims, territories)
-- - Marriage proposals (with dowry, political terms, alliance benefits)
-- - Heir system (track lineage, age, traits, succession order)
-- - Succession crisis on ruler death
-- - Inter-marriage between houses
-- - Dowry negotiations
-- - Annulments and divorces
-- - Royal children (education, betrothal)
-- - Dynasty prestige

local Dynasty = {}

-- ============================================================
-- ROYAL HOUSES
-- ============================================================
local HOUSES = {
    norman = {
        name = "Normanska dinastija",
        nameEn = "House Normandy",
        color = { 0.6, 0.2, 0.2 },
        traits = { "martial", "ambitious" },
        territory = "Normandija",
        basePower = 80,
        description = "Normani — vojaška moč in ambicije.",
    },
    plantagenet = {
        name = "Plantageneti",
        nameEn = "House Plantagenet",
        color = { 0.2, 0.5, 0.2 },
        traits = { "diplomatic", "wealthy" },
        territory = "Anjou",
        basePower = 75,
        description = "Plantageneti — bogati in diplomatični.",
    },
    habsburg = {
        name = "Habsburžani",
        nameEn = "House Habsburg",
        color = { 0.7, 0.5, 0.1 },
        traits = { "diplomatic", "long_lived" },
        territory = "Avstrija",
        basePower = 85,
        description = "Habsburžani — mojstri dinastične politike.",
    },
    capet = {
        name = "Kapetinci",
        nameEn = "House Capet",
        color = { 0.2, 0.2, 0.6 },
        traits = { "pious", "stability" },
        territory = "Francija",
        basePower = 70,
        description = "Kapetinci — verski in stabilni.",
    },
    hohenstaufen = {
        name = "Hohenstaufeni",
        nameEn = "House Hohenstaufen",
        color = { 0.3, 0.3, 0.3 },
        traits = { "imperial", "martial" },
        territory = "Švabska",
        basePower = 90,
        description = "Hohenstaufeni — cesarske ambicije.",
    },
    local_house = {
        name = "Domača dinastija",
        nameEn = "Local House",
        color = { 0.5, 0.4, 0.3 },
        traits = { "popular", "defensive" },
        territory = "Domače",
        basePower = 60,
        description = "Lokalna dinastija, blizu ljudstvu.",
    },
}

-- ============================================================
-- MARRIAGE TERMS
-- ============================================================
local MARRIAGE_TERMS = {
    basic = {
        name = "Osnovna zveza",
        nameEn = "Basic Alliance",
        allianceStrength = 30,
        duration = 0,  -- permanent
        dowryExpected = 500,
    },
    strong = {
        name = "Močna zveza",
        nameEn = "Strong Alliance",
        allianceStrength = 60,
        duration = 0,
        dowryExpected = 1500,
        tradeAgreement = true,
    },
    royal = {
        name = "Kraljevska zveza",
        nameEn = "Royal Alliance",
        allianceStrength = 90,
        duration = 0,
        dowryExpected = 5000,
        tradeAgreement = true,
        militaryAccess = true,
        successionClaim = 0.20,  -- 20% chance of claim on their throne
    },
    matrilineal = {
        name = "Matrilinearna zveza",
        nameEn = "Matrilineal Marriage",
        allianceStrength = 50,
        duration = 0,
        dowryExpected = 0,
        childrenBelongToWife = true,  -- children are of wife's dynasty
    },
}

-- ============================================================
-- STATE
-- ============================================================
Dynasty.playerHouse = "local_house"
Dynasty.ruler = nil                -- { name, age, gender, traits, health, reignYears }
Dynasty.spouse = nil               -- Married partner
Dynasty.children = {}              -- List of heirs
Dynasty.betrothals = {}            -- Engaged but not yet married
Dynasty.activeMarriages = {}       -- Active marriage alliances
Dynasty.dynastyPrestige = 50       -- 0-100
Dynasty.successionCrisis = false
Dynasty.totalMarriages = 0
Dynasty.dayTimer = 0
Dynasty.yearTimer = 0

-- ============================================================
-- INITIALIZATION
-- ============================================================
function Dynasty.init()
    Dynasty.playerHouse = "local_house"
    Dynasty.ruler = {
        name = "Kralj Branislav",
        age = 32,
        gender = "male",
        traits = { "ambitious", "pious" },
        health = 100,
        reignYears = 5,
    }
    Dynasty.spouse = nil
    Dynasty.children = {}
    Dynasty.betrothals = {}
    Dynasty.activeMarriages = {}
    Dynasty.dynastyPrestige = 50
    Dynasty.successionCrisis = false
    Dynasty.totalMarriages = 0
    Dynasty.dayTimer = 0
    Dynasty.yearTimer = 0
    print("[Dynasty] Royal Marriage & Dynasty System initialized (6 houses, 4 marriage types)")
end

-- ============================================================
-- MARRIAGE PROPOSALS
-- ============================================================
function Dynasty.canPropose(targetHouseId, termId)
    local house = HOUSES[targetHouseId]
    if not house then return false, "Neznana hiša" end
    if targetHouseId == Dynasty.playerHouse then
        return false, "Ne moreš se poročiti s svojo hišo"
    end
    local term = MARRIAGE_TERMS[termId]
    if not term then return false, "Neznan tip poroke" end
    -- Check if already married to them
    for _, m in ipairs(Dynasty.activeMarriages) do
        if m.targetHouse == targetHouseId then
            return false, "Že poročeni s to hišo"
        end
    end
    -- Need an unmarried ruler or child
    if not Dynasty.ruler or Dynasty.ruler.spouse then
        if #Dynasty.children == 0 then
            return false, "Ni nevesta/ženina na voljo"
        end
    end
    -- Check dowry
    if not _G.state or (_G.state.gold or 0) < (term.dowryExpected or 0) then
        return false, "Premalo zlata za doto"
    end
    return true
end

function Dynasty.proposeMarriage(targetHouseId, termId)
    local ok, err = Dynasty.canPropose(targetHouseId, termId)
    if not ok then return false, err end
    local term = MARRIAGE_TERMS[termId]
    local house = HOUSES[targetHouseId]
    -- Pay dowry
    _G.state.gold = _G.state.gold - (term.dowryExpected or 0)
    -- Acceptance chance based on power difference and prestige
    local powerDiff = Dynasty.dynastyPrestige - house.basePower
    local acceptChance = 0.40 + (powerDiff / 200)
    if term.dowryExpected > 1000 then acceptChance = acceptChance + 0.15 end
    acceptChance = math.max(0.10, math.min(0.90, acceptChance))
    if math.random() < acceptChance then
        -- Marriage accepted!
        local marriage = {
            id = "marriage_" .. tostring(os.time()),
            targetHouse = targetHouseId,
            targetName = house.name,
            termId = termId,
            termName = term.name,
            allianceStrength = term.allianceStrength,
            tradeAgreement = term.tradeAgreement or false,
            militaryAccess = term.militaryAccess or false,
            successionClaim = term.successionClaim or 0,
            matrilineal = term.childrenBelongToWife or false,
            marriedDay = os.time(),
            yearsMarried = 0,
        }
        table.insert(Dynasty.activeMarriages, marriage)
        Dynasty.totalMarriages = Dynasty.totalMarriages + 1
        Dynasty.dynastyPrestige = math.min(100, Dynasty.dynastyPrestige + 5)
        -- Set spouse if ruler unmarried
        if Dynasty.ruler and not Dynasty.spouse then
            Dynasty.spouse = {
                name = Dynasty.generateSpouseName(targetHouseId),
                age = Dynasty.ruler.age - math.random(-5, 5),
                gender = Dynasty.ruler.gender == "male" and "female" or "male",
                house = targetHouseId,
                traits = house.traits,
                health = 100,
            }
        end
        -- Apply diplomatic effects
        if _G.DiplomacyController then
            pcall(_G.DiplomacyController.changeRelation, targetHouseId, term.allianceStrength / 2)
        end
        if _G.NotificationCenter then
            pcall(_G.NotificationCenter.notify,
                string.format("Poroka sklenjena: %s (%s) — zaveza +%d",
                    house.name, term.name, term.allianceStrength), "important")
        end
        if _G.GameEventBus then
            pcall(_G.GameEventBus.publish, "MARRIAGE_CONCLUDED", {
                house = targetHouseId, term = termId,
            })
        end
        return true
    else
        Dynasty.dynastyPrestige = math.max(0, Dynasty.dynastyPrestige - 3)
        if _G.NotificationCenter then
            pcall(_G.NotificationCenter.notify,
                house.name .. " je zavrnila ponudbo za poroko.", "warning")
        end
        return false, "Ponudba zavrnjena"
    end
end

function Dynasty.generateSpouseName(houseId)
    local femaleNames = { "Marija", "Elizabeta", "Katarina", "Ana", "Margarita", "Sofija" }
    local maleNames = { "Friderik", "Henrik", "Ludvik", "Oton", "Viljem", "Karel" }
    if Dynasty.ruler and Dynasty.ruler.gender == "male" then
        return femaleNames[math.random(#femaleNames)]
    else
        return maleNames[math.random(#maleNames)]
    end
end

-- ============================================================
-- HEIRS & CHILDREN
-- ============================================================
function Dynasty.birthChild()
    if not Dynasty.spouse then return false, "Brez zakonca" end
    local gender = math.random() < 0.5 and "male" or "female"
    local child = {
        id = "child_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        name = Dynasty.generateChildName(gender),
        age = 0,
        gender = gender,
        traits = {},
        health = 100,
        education = "none",  -- none, scribe, warrior, courtier, religious
        motherHouse = Dynasty.spouse.house,
    }
    -- Inherit traits
    local allTraits = {}
    for _, t in ipairs(Dynasty.ruler.traits or {}) do table.insert(allTraits, t) end
    for _, t in ipairs(Dynasty.spouse.traits or {}) do table.insert(allTraits, t) end
    if #allTraits > 0 then
        child.traits = { allTraits[math.random(#allTraits)] }
    end
    table.insert(Dynasty.children, child)
    Dynasty.dynastyPrestige = math.min(100, Dynasty.dynastyPrestige + 3)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            "Radostna novica! Rodil se je " .. (gender == "male" and "sin" or "hči") ..
            " — " .. child.name, "rare")
    end
    if _G.GameEventBus then
        pcall(_G.GameEventBus.publish, "HEIR_BORN", { name = child.name, gender = gender })
    end
    return true
end

function Dynasty.generateChildName(gender)
    local maleNames = { "Branislav", "Vladislav", "Boleslav", "Svetopolk", "Miroslav", "Radoslav" }
    local femaleNames = { "Milena", "Vesna", "Dragica", "Slavica", "Radmila", "Bogdana" }
    if gender == "male" then
        return maleNames[math.random(#maleNames)]
    else
        return femaleNames[math.random(#femaleNames)]
    end
end

function Dynasty.educateChild(childId, educationType)
    for _, c in ipairs(Dynasty.children) do
        if c.id == childId then
            if c.age < 6 then return false, "Otrok premlad za izobraževanje" end
            c.education = educationType
            -- Apply trait based on education
            local eduTraits = {
                scribe = "scholarly",
                warrior = "martial",
                courtier = "diplomatic",
                religious = "pious",
            }
            if eduTraits[educationType] then
                table.insert(c.traits, eduTraits[educationType])
            end
            if _G.NotificationCenter then
                pcall(_G.NotificationCenter.notify,
                    c.name .. " se izobražuje: " .. educationType, "info")
            end
            return true
        end
    end
    return false, "Otrok ne obstaja"
end

function Dynasty.betrothChild(childId, targetHouseId)
    for _, c in ipairs(Dynasty.children) do
        if c.id == childId then
            if c.age < 12 then return false, "Otrok premlad za obljubo" end
            table.insert(Dynasty.betrothals, {
                childId = childId,
                childName = c.name,
                targetHouse = targetHouseId,
                agreedDay = os.time(),
            })
            if _G.NotificationCenter then
                pcall(_G.NotificationCenter.notify,
                    c.name .. " obljubljen(a) hiši " .. (HOUSES[targetHouseId] and HOUSES[targetHouseId].name or "?"), "info")
            end
            return true
        end
    end
    return false, "Otrok ne obstaja"
end

-- ============================================================
-- SUCCESSION
-- ============================================================
function Dynasty.getSuccessor()
    -- Oldest male child first (primogeniture)
    local maleHeirs = {}
    local femaleHeirs = {}
    for _, c in ipairs(Dynasty.children) do
        if c.age >= 16 then
            if c.gender == "male" then
                table.insert(maleHeirs, c)
            else
                table.insert(femaleHeirs, c)
            end
        end
    end
    table.sort(maleHeirs, function(a, b) return a.age > b.age end)
    table.sort(femaleHeirs, function(a, b) return a.age > b.age end)
    if #maleHeirs > 0 then return maleHeirs[1] end
    if #femaleHeirs > 0 then return femaleHeirs[1] end
    return nil
end

function Dynasty.rulerDeath()
    if not Dynasty.ruler then return end
    local successor = Dynasty.getSuccessor()
    if successor then
        -- Succession successful
        local oldName = Dynasty.ruler.name
        Dynasty.ruler = {
            name = successor.name,
            age = successor.age,
            gender = successor.gender,
            traits = successor.traits,
            health = 100,
            reignYears = 0,
        }
        -- Remove from children list
        for i, c in ipairs(Dynasty.children) do
            if c.id == successor.id then
                table.remove(Dynasty.children, i)
                break
            end
        end
        Dynasty.spouse = nil  -- spouse becomes dowager
        if _G.NotificationCenter then
            pcall(_G.NotificationCenter.notify,
                "Kralj umrl. Naslednik prevzema oblast: " .. successor.name, "important")
        end
        if _G.GameEventBus then
            pcall(_G.GameEventBus.publish, "SUCCESSION", {
                oldRuler = oldName, newRuler = successor.name,
            })
        end
    else
        -- Succession crisis!
        Dynasty.successionCrisis = true
        if _G.NotificationCenter then
            pcall(_G.NotificationCenter.notify,
                "KRALJ UMRL BREZ NASLEDNIKA! Kriza nasledstva!", "danger")
        end
        if _G.GameEventBus then
            pcall(_G.GameEventBus.publish, "SUCCESSION_CRISIS", {})
        end
        -- Trigger rebellion system
        if _G.Rebellion then
            pcall(_G.Rebellion.triggerRebellion, "succession_crisis")
        end
    end
end

-- ============================================================
-- DIVORCE & ANNULMENT
-- ============================================================
function Dynasty.divorce(marriageId)
    for i, m in ipairs(Dynasty.activeMarriages) do
        if m.id == marriageId then
            table.remove(Dynasty.activeMarriages, i)
            Dynasty.dynastyPrestige = math.max(0, Dynasty.dynastyPrestige - 10)
            -- Diplomatic hit
            if _G.DiplomacyController then
                pcall(_G.DiplomacyController.changeRelation, m.targetHouse, -30)
            end
            -- Clear spouse if it was ruler's marriage
            if Dynasty.spouse and Dynasty.spouse.house == m.targetHouse then
                Dynasty.spouse = nil
            end
            if _G.NotificationCenter then
                pcall(_G.NotificationCenter.notify,
                    "Razveza zakona z " .. m.targetName .. "!", "warning")
            end
            return true
        end
    end
    return false, "Zakon ne obstaja"
end

-- ============================================================
-- ANNUAL UPDATE
-- ============================================================
function Dynasty.processYear()
    -- Ruler ages
    if Dynasty.ruler then
        Dynasty.ruler.age = Dynasty.ruler.age + 1
        Dynasty.ruler.reignYears = Dynasty.ruler.reignYears + 1
        -- Health decline with age
        if Dynasty.ruler.age > 50 then
            Dynasty.ruler.health = math.max(0, Dynasty.ruler.health - math.random(2, 5))
        end
        -- Death check
        if Dynasty.ruler.health <= 0 or math.random() < 0.005 then
            Dynasty.rulerDeath()
        end
    end
    -- Spouse ages
    if Dynasty.spouse then
        Dynasty.spouse.age = Dynasty.spouse.age + 1
        if Dynasty.spouse.age > 50 then
            Dynasty.spouse.health = math.max(0, Dynasty.spouse.health - math.random(2, 5))
        end
        if Dynasty.spouse.health <= 0 then
            Dynasty.spouse = nil
            if _G.NotificationCenter then
                pcall(_G.NotificationCenter.notify, "Zakonec umrl.", "warning")
            end
        end
    end
    -- Children grow
    for i = #Dynasty.children, 1, -1 do
        local c = Dynasty.children[i]
        c.age = c.age + 1
        if c.age > 60 then
            -- Possible death
            if math.random() < 0.05 then
                table.remove(Dynasty.children, i)
                if _G.NotificationCenter then
                    pcall(_G.NotificationCenter.notify, c.name .. " umrl(a).", "warning")
                end
            end
        end
    end
    -- Birth chance (if married)
    if Dynasty.spouse and Dynasty.ruler and Dynasty.ruler.age < 50 then
        if math.random() < 0.40 then  -- 40% chance per year
            Dynasty.birthChild()
        end
    end
    -- Marriages age
    for _, m in ipairs(Dynasty.activeMarriages) do
        m.yearsMarried = m.yearsMarried + 1
    end
    -- Resolve old betrothals (auto-marry at age 16)
    for i = #Dynasty.betrothals, 1, -1 do
        local b = Dynasty.betrothals[i]
        for _, c in ipairs(Dynasty.children) do
            if c.id == b.childId and c.age >= 16 then
                -- Auto-marry
                Dynasty.proposeMarriage(b.targetHouse, "basic")
                table.remove(Dynasty.betrothals, i)
                break
            end
        end
    end
end

-- ============================================================
-- UPDATE
-- ============================================================
function Dynasty.update(dt)
    if not _G.state then return end
    Dynasty.dayTimer = Dynasty.dayTimer + dt
    Dynasty.yearTimer = Dynasty.yearTimer + dt
    -- Year tick (every 120 seconds = 1 game year)
    if Dynasty.yearTimer >= 120 then
        Dynasty.yearTimer = 0
        Dynasty.processYear()
    end
end

-- ============================================================
-- HELPERS
-- ============================================================
function Dynasty.getHouseInfo(houseId) return HOUSES[houseId] end
function Dynasty.getMarriageTermInfo(termId) return MARRIAGE_TERMS[termId] end
function Dynasty.getRuler() return Dynasty.ruler end
function Dynasty.getSpouse() return Dynasty.spouse end
function Dynasty.getChildren() return Dynasty.children end
function Dynasty.getActiveMarriages() return Dynasty.activeMarriages end

function Dynasty.getStats()
    return {
        playerHouse = Dynasty.playerHouse,
        rulerName = Dynasty.ruler and Dynasty.ruler.name or "—",
        rulerAge = Dynasty.ruler and Dynasty.ruler.age or 0,
        rulerHealth = Dynasty.ruler and Dynasty.ruler.health or 0,
        reignYears = Dynasty.ruler and Dynasty.ruler.reignYears or 0,
        spouseName = Dynasty.spouse and Dynasty.spouse.name or "—",
        numChildren = #Dynasty.children,
        numHeirs = (function()
            local count = 0
            for _, c in ipairs(Dynasty.children) do
                if c.age >= 16 then count = count + 1 end
            end
            return count
        end)(),
        numMarriages = #Dynasty.activeMarriages,
        numBetrothals = #Dynasty.betrothals,
        dynastyPrestige = Dynasty.dynastyPrestige,
        successionCrisis = Dynasty.successionCrisis,
        totalMarriages = Dynasty.totalMarriages,
    }
end

function Dynasty.getActiveBonuses()
    local bonuses = {
        diplomacyBonus = 0,
        tradeBonus = 0,
        militaryAccess = false,
        successionClaim = 0,
    }
    for _, m in ipairs(Dynasty.activeMarriages) do
        bonuses.diplomacyBonus = bonuses.diplomacyBonus + m.allianceStrength / 10
        if m.tradeAgreement then bonuses.tradeBonus = bonuses.tradeBonus + 0.10 end
        if m.militaryAccess then bonuses.militaryAccess = true end
        if m.successionClaim then
            bonuses.successionClaim = bonuses.successionClaim + m.successionClaim
        end
    end
    -- Prestige bonus
    bonuses.diplomacyBonus = bonuses.diplomacyBonus + (Dynasty.dynastyPrestige / 20)
    return bonuses
end

return Dynasty
