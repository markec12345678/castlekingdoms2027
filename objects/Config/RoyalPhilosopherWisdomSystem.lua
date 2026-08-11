-- objects/Config/RoyalPhilosopherWisdomSystem.lua
-- Castle Kingdoms 2027 v3.4.6 - Royal Philosopher & Wisdom System
--
-- Manages court philosophers, wisdom traditions, and philosophical schools.
-- Philosophy provides research bonuses, happiness, and unique insights.
--
-- Features:
-- - 6 philosophical schools (Stoicism, Platonism, Aristotelianism, Scholasticism, Mysticism, Humanism)
-- - 8 wisdom topics (ethics, politics, metaphysics, logic, aesthetics, epistemology, theology, natural philosophy)
-- - Philosopher NPC (skill affects insight quality)
-- - Academy buildings
-- - Philosophical debates
-- - Wisdom publications
-- - Student mentoring
-- - Court advisor role

local Philosophy = {}

-- ============================================================
-- PHILOSOPHICAL SCHOOLS
-- ============================================================
local SCHOOLS = {
    stoicism = {
        name = "Stoicizem",
        nameEn = "Stoicism",
        happinessBonus = 8,
        resilienceBonus = 15,
        description = "Vrlina in samokontrola.",
        keyFigure = "Seneka",
    },
    platonism = {
        name = "Platonizem",
        nameEn = "Platonism",
        knowledgeBonus = 0.20,
        prestigeBonus = 10,
        description = "Svet idej in idealna država.",
        keyFigure = "Platon",
    },
    aristotelianism = {
        name = "Aristotelizem",
        nameEn = "Aristotelianism",
        researchBonus = 0.25,
        logicBonus = 20,
        description = "Empirizem in logika.",
        keyFigure = "Aristotel",
    },
    scholasticism = {
        name = "Sholastika",
        nameEn = "Scholasticism",
        faithBonus = 15,
        knowledgeBonus = 0.15,
        description = "Združitev vere in razuma.",
        keyFigure = "Tomaž Akvinski",
    },
    mysticism = {
        name = "Misticizem",
        nameEn = "Mysticism",
        faithBonus = 25,
        happinessBonus = 5,
        description = "Neposredna izkušnja božjega.",
        keyFigure = "Hildegarda",
    },
    humanism = {
        name = "Humanizem",
        nameEn = "Humanism",
        happinessBonus = 12,
        cultureBonus = 20,
        description = "Človek v središču, klasične vrednote.",
        keyFigure = "Petrarka",
    },
}

-- ============================================================
-- WISDOM TOPICS
-- ============================================================
local TOPICS = {
    ethics = {
        name = "Etika",
        nameEn = "Ethics",
        difficulty = 3,
        researchTime = 30,
        description = "Študija morale in vrlin.",
    },
    politics = {
        name = "Politika",
        nameEn = "Politics",
        difficulty = 4,
        researchTime = 40,
        description = "Upravljanje države in oblasti.",
    },
    metaphysics = {
        name = "Metafizika",
        nameEn = "Metaphysics",
        difficulty = 5,
        researchTime = 60,
        description = "Narava realnosti in bivanja.",
    },
    logic = {
        name = "Logika",
        nameEn = "Logic",
        difficulty = 4,
        researchTime = 35,
        description = "Pravila sklepanja in argumentacije.",
    },
    aesthetics = {
        name = "Estetika",
        nameEn = "Aesthetics",
        difficulty = 3,
        researchTime = 25,
        description = "Študija lepote in umetnosti.",
    },
    epistemology = {
        name = "Epistemologija",
        nameEn = "Epistemology",
        difficulty = 5,
        researchTime = 50,
        description = "Teorija znanja in spoznanja.",
    },
    theology = {
        name = "Teologija",
        nameEn = "Theology",
        difficulty = 5,
        researchTime = 55,
        description = "Študija božjega in vere.",
    },
    natural_philosophy = {
        name = "Naravna filozofija",
        nameEn = "Natural Philosophy",
        difficulty = 4,
        researchTime = 45,
        description = "Študija narave in fizike.",
    },
}

-- ============================================================
-- ACADEMY BUILDINGS
-- ============================================================
local BUILDINGS = {
    study_room = {
        name = "Študijska soba",
        cost = { gold = 400, wood = 100, stone = 50 },
        upkeep = 10,
        capacity = 1,
        researchBonus = 5,
        description = "Soba za samostudij.",
    },
    academy = {
        name = "Akademija",
        cost = { gold = 2000, wood = 300, stone = 400 },
        upkeep = 50,
        capacity = 5,
        researchBonus = 15,
        prestigeBonus = 10,
        description = "Filozofska šola za študente.",
    },
    grand_university = {
        name = "Velika univerza",
        cost = { gold = 8000, wood = 500, stone = 1500 },
        upkeep = 150,
        capacity = 20,
        researchBonus = 30,
        prestigeBonus = 25,
        description = "Najvišja ustanova za znanost in filozofijo.",
    },
}

-- ============================================================
-- STATE
-- ============================================================
Philosophy.activeSchool = nil             -- Currently adopted school
Philosophy.buildings = {}                 -- Built academies
Philosophy.philosopher = nil              -- Hired philosopher NPC
Philosophy.activeResearch = {}            -- Ongoing research
Philosophy.completedWorks = {}            -- Published works
Philosophy.students = {}                  -- Mentored students
Philosophy.totalWorks = 0
Philosophy.totalStudents = 0
Philosophy.dayTimer = 0

-- ============================================================
-- INITIALIZATION
-- ============================================================
function Philosophy.init()
    Philosophy.activeSchool = nil
    Philosophy.buildings = {}
    Philosophy.philosopher = nil
    Philosophy.activeResearch = {}
    Philosophy.completedWorks = {}
    Philosophy.students = {}
    Philosophy.totalWorks = 0
    Philosophy.totalStudents = 0
    Philosophy.dayTimer = 0
    print("[Philosophy] Royal Philosopher & Wisdom System initialized (6 schools, 8 topics, 3 buildings)")
end

-- ============================================================
-- PHILOSOPHER NPC
-- ============================================================
function Philosophy.hirePhilosopher(name, skill, school)
    skill = skill or math.random(50, 95)
    local cost = 800 + skill * 15
    if not _G.state or (_G.state.gold or 0) < cost then
        return false, "Premalo zlata"
    end
    _G.state.gold = _G.state.gold - cost
    Philosophy.philosopher = {
        name = name or ("Filozof " .. math.random(1, 99)),
        skill = skill,
        school = school or "aristotelianism",
        hiredDay = os.time(),
        worksPublished = 0,
        studentsMentored = 0,
    }
    -- Auto-adopt philosopher's school
    if not Philosophy.activeSchool then
        Philosophy.adoptSchool(school or "aristotelianism")
    end
    if _G.NotificationCenter then
        local schoolDef = SCHOOLS[school or "aristotelianism"]
        pcall(_G.NotificationCenter.notify,
            string.format("Filozof najet: %s (%s, spretnost: %d)",
                Philosophy.philosopher.name, schoolDef and schoolDef.name or "?", skill), "success")
    end
    return true
end

-- ============================================================
-- SCHOOL ADOPTION
-- ============================================================
function Philosophy.adoptSchool(schoolId)
    local def = SCHOOLS[schoolId]
    if not def then return false, "Neznana šola" end
    Philosophy.activeSchool = schoolId
    -- Apply immediate bonuses
    if def.happinessBonus and _G.state and _G.state.happiness then
        _G.state.happiness = math.min(100, _G.state.happiness + def.happinessBonus)
    end
    if def.faithBonus and _G.Religion then
        pcall(_G.Religion.addFaith, def.faithBonus)
    end
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Sprejeta šola: %s (ključna osebnost: %s)",
                def.name, def.keyFigure), "important")
    end
    if _G.GameEventBus then
        pcall(_G.GameEventBus.publish, "SCHOOL_ADOPTED", { school = schoolId })
    end
    return true
end

-- ============================================================
-- BUILDINGS
-- ============================================================
function Philosophy.canBuild(buildingId)
    local def = BUILDINGS[buildingId]
    if not def then return false, "Neznana zgradba" end
    if not _G.state then return false, "Brez stanja" end
    if _G.state.gold < (def.cost.gold or 0) then return false, "Premalo zlata" end
    if _G.state.resources then
        for res, amt in pairs(def.cost) do
            if res ~= "gold" and (_G.state.resources[res] or 0) < amt then
                return false, "Premalo " .. res
            end
        end
    end
    return true
end

function Philosophy.build(buildingId)
    local ok, err = Philosophy.canBuild(buildingId)
    if not ok then return false, err end
    local def = BUILDINGS[buildingId]
    _G.state.gold = _G.state.gold - (def.cost.gold or 0)
    if _G.state.resources then
        for res, amt in pairs(def.cost) do
            if res ~= "gold" then
                _G.state.resources[res] = (_G.state.resources[res] or 0) - amt
            end
        end
    end
    table.insert(Philosophy.buildings, {
        type = buildingId,
        builtDay = os.time(),
    })
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Zgrajeno: " .. def.name, "success")
    end
    return true
end

function Philosophy.getResearchBonus()
    local bonus = 0
    for _, b in ipairs(Philosophy.buildings) do
        local def = BUILDINGS[b.type]
        if def and def.researchBonus then bonus = bonus + def.researchBonus end
    end
    -- School bonus
    if Philosophy.activeSchool and SCHOOLS[Philosophy.activeSchool] then
        local schoolDef = SCHOOLS[Philosophy.activeSchool]
        if schoolDef.researchBonus then
            bonus = bonus + schoolDef.researchBonus * 100
        end
    end
    return bonus
end

function Philosophy.getPrestigeBonus()
    local bonus = 0
    for _, b in ipairs(Philosophy.buildings) do
        local def = BUILDINGS[b.type]
        if def and def.prestigeBonus then bonus = bonus + def.prestigeBonus end
    end
    if Philosophy.activeSchool and SCHOOLS[Philosophy.activeSchool] then
        local schoolDef = SCHOOLS[Philosophy.activeSchool]
        if schoolDef.prestigeBonus then bonus = bonus + schoolDef.prestigeBonus end
    end
    return bonus
end

-- ============================================================
-- RESEARCH
-- ============================================================
function Philosophy.canResearch(topicId)
    local def = TOPICS[topicId]
    if not def then return false, "Neznana tema" end
    if not Philosophy.philosopher then return false, "Potreben filozof" end
    -- Need at least a study room
    if #Philosophy.buildings == 0 then
        return false, "Potrebna študijska zgradba"
    end
    -- Check if already researching this topic
    for _, r in ipairs(Philosophy.activeResearch) do
        if r.topic == topicId then
            return false, "Že raziskuješ to temo"
        end
    end
    return true
end

function Philosophy.startResearch(topicId)
    local ok, err = Philosophy.canResearch(topicId)
    if not ok then return false, err end
    local def = TOPICS[topicId]
    local research = {
        id = "research_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        topic = topicId,
        topicName = def.name,
        daysRemaining = def.researchTime,
        totalDays = def.researchTime,
        difficulty = def.difficulty,
        started = os.time(),
    }
    table.insert(Philosophy.activeResearch, research)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Raziskava začeta: %s (%d dni)", def.name, def.researchTime), "info")
    end
    return true
end

function Philosophy.completeResearch(research)
    -- Calculate quality
    local quality = 1.0
    local bonus = Philosophy.getResearchBonus()
    quality = quality + (bonus / 100)
    if Philosophy.philosopher then
        quality = quality + (Philosophy.philosopher.skill / 200)
    end
    -- Difficulty reduces quality
    quality = quality - (research.difficulty / 50)
    quality = math.max(0.5, math.min(2.0, quality))
    local work = {
        id = "work_" .. tostring(os.time()),
        topic = research.topic,
        topicName = research.topicName,
        quality = quality,
        publishedDay = os.time(),
    }
    table.insert(Philosophy.completedWorks, work)
    Philosophy.totalWorks = Philosophy.totalWorks + 1
    -- Apply bonuses
    if _G.state and _G.state.happiness then
        _G.state.happiness = math.min(100, _G.state.happiness + math.floor(5 * quality))
    end
    -- Knowledge bonus
    if _G.Culture and _G.Culture.knowledgePoints then
        _G.Culture.knowledgePoints = _G.Culture.knowledgePoints + math.floor(20 * quality)
    end
    -- Philosopher skill progression
    if Philosophy.philosopher then
        Philosophy.philosopher.worksPublished = Philosophy.philosopher.worksPublished + 1
        if math.random() < 0.30 then
            Philosophy.philosopher.skill = math.min(100, Philosophy.philosopher.skill + 1)
        end
    end
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Delo objavljeno: %s (kakovost: %.1f)", research.topicName, quality), "success")
    end
    if _G.GameEventBus then
        pcall(_G.GameEventBus.publish, "PHILOSOPHICAL_WORK_PUBLISHED", {
            topic = research.topic, quality = quality,
        })
    end
end

-- ============================================================
-- STUDENT MENTORING
-- ============================================================
function Philosophy.mentorStudent(name)
    if not Philosophy.philosopher then return false, "Potreben filozof" end
    if not _G.state or (_G.state.gold or 0) < 200 then
        return false, "Premalo zlata za štipendijo"
    end
    _G.state.gold = _G.state.gold - 200
    local student = {
        id = "student_" .. tostring(os.time()),
        name = name or ("Študent " .. math.random(1, 99)),
        daysRemaining = 90,  -- 3 months of study
        started = os.time(),
    }
    table.insert(Philosophy.students, student)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Študent vpisan: %s", student.name), "info")
    end
    return true
end

function Philosophy.updateStudents()
    for i = #Philosophy.students, 1, -1 do
        local s = Philosophy.students[i]
        s.daysRemaining = s.daysRemaining - 1
        if s.daysRemaining <= 0 then
            -- Student graduates
            Philosophy.totalStudents = Philosophy.totalStudents + 1
            -- Bonus to knowledge
            if _G.Culture and _G.Culture.knowledgePoints then
                _G.Culture.knowledgePoints = _G.Culture.knowledgePoints + 30
            end
            if _G.NotificationCenter then
                pcall(_G.NotificationCenter.notify,
                    string.format("Študent diplomiral: %s!", s.name), "success")
            end
            table.remove(Philosophy.students, i)
        end
    end
end

-- ============================================================
-- UPDATE
-- ============================================================
function Philosophy.update(dt)
    if not _G.state then return end
    Philosophy.dayTimer = Philosophy.dayTimer + dt
    if Philosophy.dayTimer >= 30 then
        Philosophy.dayTimer = 0
        -- Process research
        for i = #Philosophy.activeResearch, 1, -1 do
            local r = Philosophy.activeResearch[i]
            r.daysRemaining = r.daysRemaining - 1
            if r.daysRemaining <= 0 then
                Philosophy.completeResearch(r)
                table.remove(Philosophy.activeResearch, i)
            end
        end
        -- Update students
        Philosophy.updateStudents()
        -- Pay upkeep
        local totalUpkeep = 0
        for _, b in ipairs(Philosophy.buildings) do
            local def = BUILDINGS[b.type]
            if def and def.upkeep then totalUpkeep = totalUpkeep + def.upkeep end
        end
        if Philosophy.philosopher then totalUpkeep = totalUpkeep + 40 end
        for _, s in ipairs(Philosophy.students) do
            totalUpkeep = totalUpkeep + 5
        end
        if totalUpkeep > 0 and _G.state then
            _G.state.gold = math.max(0, (_G.state.gold or 0) - totalUpkeep)
        end
    end
end

-- ============================================================
-- HELPERS
-- ============================================================
function Philosophy.getSchoolInfo(schoolId) return SCHOOLS[schoolId] end
function Philosophy.getTopicInfo(topicId) return TOPICS[topicId] end
function Philosophy.getBuildingInfo(buildingId) return BUILDINGS[buildingId] end

function Philosophy.getActiveBonuses()
    local bonuses = {
        happinessBonus = 0,
        knowledgeBonus = 0,
        researchBonus = 0,
        faithBonus = 0,
        prestigeBonus = 0,
    }
    if Philosophy.activeSchool then
        local def = SCHOOLS[Philosophy.activeSchool]
        if def then
            bonuses.happinessBonus = def.happinessBonus or 0
            bonuses.knowledgeBonus = def.knowledgeBonus or 0
            bonuses.researchBonus = def.researchBonus or 0
            bonuses.faithBonus = def.faithBonus or 0
            bonuses.prestigeBonus = def.prestigeBonus or 0
        end
    end
    return bonuses
end

function Philosophy.getStats()
    return {
        activeSchool = Philosophy.activeSchool,
        numBuildings = #Philosophy.buildings,
        hasPhilosopher = Philosophy.philosopher ~= nil,
        philosopherName = Philosophy.philosopher and Philosophy.philosopher.name or "—",
        philosopherSkill = Philosophy.philosopher and Philosophy.philosopher.skill or 0,
        activeResearch = #Philosophy.activeResearch,
        completedWorks = #Philosophy.completedWorks,
        numStudents = #Philosophy.students,
        totalWorks = Philosophy.totalWorks,
        totalStudents = Philosophy.totalStudents,
        researchBonus = Philosophy.getResearchBonus(),
        prestigeBonus = Philosophy.getPrestigeBonus(),
    }
end

return Philosophy
