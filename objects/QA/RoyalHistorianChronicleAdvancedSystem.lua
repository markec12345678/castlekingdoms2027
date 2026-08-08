-- objects/QA/RoyalHistorianChronicleAdvancedSystem.lua
-- Castle Kingdoms 2027 v3.5.1 - Royal Historian & Chronicle Advanced System
--
-- Advanced chronicle system: professional historians, multi-volume chronicles,
-- historical research, and dynasty archives. Builds on the basic Chronicle system.
--
-- Features:
-- - 6 chronicle volumes (reign, military, economic, religious, cultural, dynastic)
-- - 8 historical research topics (genealogy, battles, treaties, customs, ...)
-- - 4 archive buildings (scriptorium, chronicle hall, royal archive, museum)
-- - Royal Historian NPC (skill affects quality)
-- - Multi-volume chronicle compilation
-- - Historical accuracy tracking
-- - Dynasty genealogy
-- - Historical commentary
-- - Legacy score calculation

local Historian = {}

-- ============================================================
-- CHRONICLE VOLUMES
-- ============================================================
local VOLUMES = {
    reign = {
        name = "Kronika vladanja",
        nameEn = "Reign Chronicle",
        chapters = 10,
        writeTime = 60,
        prestigeReward = 15,
        description = "Uradni zapis vladanja monarha.",
    },
    military = {
        name = "Vojaška kronika",
        nameEn = "Military Chronicle",
        chapters = 8,
        writeTime = 45,
        prestigeReward = 12,
        description = "Zapis vojaških pohodov in bitk.",
    },
    economic = {
        name = "Gospodarska kronika",
        nameEn = "Economic Chronicle",
        chapters = 6,
        writeTime = 30,
        prestigeReward = 8,
        description = "Zapis trgovine in gospodarstva.",
    },
    religious = {
        name = "Verska kronika",
        nameEn = "Religious Chronicle",
        chapters = 7,
        writeTime = 40,
        prestigeReward = 10,
        description = "Zapis verskih dogodkov.",
    },
    cultural = {
        name = "Kulturna kronika",
        nameEn = "Cultural Chronicle",
        chapters = 5,
        writeTime = 25,
        prestigeReward = 10,
        description = "Zapis umetnosti in kulture.",
    },
    dynastic = {
        name = "Dinastična kronika",
        nameEn = "Dynastic Chronicle",
        chapters = 12,
        writeTime = 90,
        prestigeReward = 25,
        description = "Zapis rodbine in nasledstva.",
    },
}

-- ============================================================
-- HISTORICAL RESEARCH TOPICS
-- ============================================================
local RESEARCH_TOPICS = {
    genealogy = {
        name = "Genealogija",
        nameEn = "Genealogy",
        difficulty = 3,
        researchTime = 30,
        description = "Raziskovanje družinskega drevesa.",
    },
    battles = {
        name = "Bitke",
        nameEn = "Battles",
        difficulty = 4,
        researchTime = 40,
        description = "Študij zgodovinskih bitk.",
    },
    treaties = {
        name = "Pogodbe",
        nameEn = "Treaties",
        difficulty = 3,
        researchTime = 25,
        description = "Zgodovina diplomatskih sporazumov.",
    },
    customs = {
        name = "Običaji",
        nameEn = "Customs",
        difficulty = 2,
        researchTime = 20,
        description = "Tradicije in ljudski običaji.",
    },
    architecture = {
        name = "Arhitektura",
        nameEn = "Architecture",
        difficulty = 4,
        researchTime = 35,
        description = "Zgodovina gradnje in stavbarstva.",
    },
    law = {
        name = "Pravo",
        nameEn = "Law",
        difficulty = 5,
        researchTime = 45,
        description = "Zgodovina zakonodaje.",
    },
    mythology = {
        name = "Mitologija",
        nameEn = "Mythology",
        difficulty = 3,
        researchTime = 30,
        description = "Legende in miti.",
    },
    chronology = {
        name = "Kronologija",
        nameEn = "Chronology",
        difficulty = 5,
        researchTime = 50,
        description = "Datiranje zgodovinskih dogodkov.",
    },
}

-- ============================================================
-- ARCHIVE BUILDINGS
-- ============================================================
local BUILDINGS = {
    scriptorium = {
        name = "Skriptorij",
        cost = { gold = 500, wood = 100, stone = 50 },
        upkeep = 15,
        researchBonus = 5,
        description = "Soba za pisanje in prevode.",
    },
    chronicle_hall = {
        name = "Dvorana kronik",
        cost = { gold = 2000, wood = 300, stone = 500 },
        upkeep = 50,
        researchBonus = 15,
        prestigeBonus = 10,
        description = "Dvorana za hrambo kronik.",
    },
    royal_archive = {
        name = "Kraljevi arhiv",
        cost = { gold = 5000, wood = 500, stone = 1200 },
        upkeep = 100,
        researchBonus = 30,
        prestigeBonus = 20,
        description = "Veliki arhiv vseh državnih dokumentov.",
    },
    museum = {
        name = "Muzej",
        cost = { gold = 8000, wood = 600, stone = 2000 },
        upkeep = 150,
        researchBonus = 25,
        prestigeBonus = 40,
        tourismBonus = 20,
        description = "Javna razstava zgodovinskih artefaktov.",
    },
}

-- ============================================================
-- STATE
-- ============================================================
Historian.completedVolumes = {}          -- Written chronicle volumes
Historian.activeWriting = {}              -- Volumes being written
Historian.activeResearch = {}             -- Ongoing research
Historian.buildings = {}                  -- Built archives
Historian.historian = nil                 -- Royal Historian NPC
Historian.genealogy = {}                  -- Family tree data
Historian.historicalCommentary = {}       -- Commentary on events
Historian.totalVolumesWritten = 0
Historian.totalResearchCompleted = 0
Historian.legacyScore = 0
Historian.dayTimer = 0

-- ============================================================
-- INITIALIZATION
-- ============================================================
function Historian.init()
    Historian.completedVolumes = {}
    Historian.activeWriting = {}
    Historian.activeResearch = {}
    Historian.buildings = {}
    Historian.historian = nil
    Historian.genealogy = {}
    Historian.historicalCommentary = {}
    Historian.totalVolumesWritten = 0
    Historian.totalResearchCompleted = 0
    Historian.legacyScore = 0
    Historian.dayTimer = 0
    print("[Historian] Royal Historian & Chronicle Advanced System initialized (6 volumes, 8 topics, 4 buildings)")
end

-- ============================================================
-- ROYAL HISTORIAN NPC
-- ============================================================
function Historian.hireHistorian(name, skill)
    skill = skill or math.random(50, 90)
    local cost = 600 + skill * 10
    if not _G.state or (_G.state.gold or 0) < cost then
        return false, "Premalo zlata"
    end
    _G.state.gold = _G.state.gold - cost
    Historian.historian = {
        name = name or ("Zgodovinar " .. math.random(1, 99)),
        skill = skill,
        accuracy = 0.60 + (skill / 250),
        hiredDay = os.time(),
        volumesWritten = 0,
        researchCompleted = 0,
    }
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Zgodovinar najet: %s (spretnost: %d, natančnost: %.0f%%)",
                Historian.historian.name, skill, Historian.historian.accuracy * 100), "success")
    end
    return true
end

-- ============================================================
-- BUILDINGS
-- ============================================================
function Historian.canBuild(buildingId)
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

function Historian.build(buildingId)
    local ok, err = Historian.canBuild(buildingId)
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
    table.insert(Historian.buildings, {
        type = buildingId,
        builtDay = os.time(),
    })
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Zgrajeno: " .. def.name, "success")
    end
    return true
end

function Historian.getResearchBonus()
    local bonus = 0
    for _, b in ipairs(Historian.buildings) do
        local def = BUILDINGS[b.type]
        if def and def.researchBonus then bonus = bonus + def.researchBonus end
    end
    return bonus
end

function Historian.getPrestigeBonus()
    local bonus = 0
    for _, b in ipairs(Historian.buildings) do
        local def = BUILDINGS[b.type]
        if def and def.prestigeBonus then bonus = bonus + def.prestigeBonus end
    end
    return bonus
end

-- ============================================================
-- CHRONICLE WRITING
-- ============================================================
function Historian.canWriteVolume(volumeType)
    local def = VOLUMES[volumeType]
    if not def then return false, "Neznan volumen" end
    if not Historian.historian then return false, "Potreben zgodovinar" end
    if #Historian.buildings == 0 then return false, "Potrebna arhivska zgradba" end
    -- Check if already writing this volume
    for _, w in ipairs(Historian.activeWriting) do
        if w.volumeType == volumeType then
            return false, "Že se piše ta volumen"
        end
    end
    return true
end

function Historian.startWriting(volumeType)
    local ok, err = Historian.canWriteVolume(volumeType)
    if not ok then return false, err end
    local def = VOLUMES[volumeType]
    -- Calculate write time (reduced by bonuses)
    local writeTime = def.writeTime
    local bonus = Historian.getResearchBonus()
    if Historian.historian then
        bonus = bonus + math.floor(Historian.historian.skill / 5)
    end
    writeTime = math.max(5, writeTime - math.floor(bonus / 3))
    local writing = {
        id = "writing_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        volumeType = volumeType,
        volumeName = def.name,
        chapters = def.chapters,
        chaptersWritten = 0,
        daysRemaining = writeTime,
        totalDays = writeTime,
        prestigeReward = def.prestigeReward,
        started = os.time(),
    }
    table.insert(Historian.activeWriting, writing)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Pisanje kronike začeto: %s (%d dni)", def.name, writeTime), "info")
    end
    return true
end

function Historian.completeWriting(writing)
    -- Calculate accuracy
    local accuracy = 0.60
    if Historian.historian then
        accuracy = Historian.historian.accuracy
    end
    accuracy = accuracy + (Historian.getResearchBonus() / 100)
    accuracy = math.min(0.98, accuracy)
    local volume = {
        id = writing.id,
        type = writing.volumeType,
        name = writing.volumeName,
        chapters = writing.chapters,
        accuracy = accuracy,
        prestigeReward = writing.prestigeReward,
        writtenDay = os.time(),
    }
    table.insert(Historian.completedVolumes, volume)
    Historian.totalVolumesWritten = Historian.totalVolumesWritten + 1
    -- Apply prestige
    Historian.legacyScore = Historian.legacyScore + writing.prestigeReward + math.floor(accuracy * 10)
    if _G.state and _G.state.happiness then
        _G.state.happiness = math.min(100, _G.state.happiness + math.floor(writing.prestigeReward / 3))
    end
    -- Historian skill progression
    if Historian.historian then
        Historian.historian.volumesWritten = Historian.historian.volumesWritten + 1
        if math.random() < 0.25 then
            Historian.historian.skill = math.min(100, Historian.historian.skill + 1)
        end
    end
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Kronika dokončana: %s (natančnost: %.0f%%, + %d legacy)",
                writing.volumeName, accuracy * 100, writing.prestigeReward), "success")
    end
    if _G.GameEventBus then
        pcall(_G.GameEventBus.publish, "CHRONICLE_VOLUME_COMPLETED", {
            type = writing.volumeType, accuracy = accuracy,
        })
    end
end

-- ============================================================
-- HISTORICAL RESEARCH
-- ============================================================
function Historian.canResearch(topicId)
    local def = RESEARCH_TOPICS[topicId]
    if not def then return false, "Neznana tema" end
    if not Historian.historian then return false, "Potreben zgodovinar" end
    if #Historian.buildings == 0 then return false, "Potrebna arhivska zgradba" end
    return true
end

function Historian.startResearch(topicId)
    local ok, err = Historian.canResearch(topicId)
    if not ok then return false, err end
    local def = RESEARCH_TOPICS[topicId]
    local researchTime = def.researchTime
    local bonus = Historian.getResearchBonus()
    if Historian.historian then
        bonus = bonus + math.floor(Historian.historian.skill / 5)
    end
    researchTime = math.max(3, researchTime - math.floor(bonus / 4))
    local research = {
        id = "research_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        topic = topicId,
        topicName = def.name,
        difficulty = def.difficulty,
        daysRemaining = researchTime,
        totalDays = researchTime,
        started = os.time(),
    }
    table.insert(Historian.activeResearch, research)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Zgodovinska raziskava: %s (%d dni)", def.name, researchTime), "info")
    end
    return true
end

function Historian.completeResearch(research)
    Historian.totalResearchCompleted = Historian.totalResearchCompleted + 1
    -- Knowledge bonus
    if _G.Culture and _G.Culture.knowledgePoints then
        _G.Culture.knowledgePoints = _G.Culture.knowledgePoints + 25
    end
    Historian.legacyScore = Historian.legacyScore + 5
    -- Add to genealogy if applicable
    if research.topic == "genealogy" then
        Historian.addGenealogyEntry()
    end
    if Historian.historian then
        Historian.historian.researchCompleted = Historian.historian.researchCompleted + 1
        if math.random() < 0.20 then
            Historian.historian.skill = math.min(100, Historian.historian.skill + 1)
        end
    end
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Raziskava končana: %s (+%d znanja)", research.topicName, 25), "success")
    end
end

-- ============================================================
-- GENEALOGY
-- ============================================================
function Historian.addGenealogyEntry()
    local entry = {
        id = "gen_" .. tostring(os.time()),
        name = "Prednik " .. math.random(1, 99),
        generation = #Historian.genealogy + 1,
        notable = math.random() < 0.20,
        addedDay = os.time(),
    }
    table.insert(Historian.genealogy, entry)
    if entry.notable then
        Historian.legacyScore = Historian.legacyScore + 10
        if _G.NotificationCenter then
            pcall(_G.NotificationCenter.notify,
                "Pomemben prednik odkrit v genealogiji! +10 legacy", "rare")
        end
    end
end

-- ============================================================
-- HISTORICAL COMMENTARY
-- ============================================================
function Historian.addCommentary(event, comment)
    table.insert(Historian.historicalCommentary, {
        event = event,
        comment = comment or "Zgodovinski zapis.",
        writtenDay = os.time(),
    })
    -- Subscribe to events if Chronicle system exists
end

-- ============================================================
-- UPDATE
-- ============================================================
function Historian.update(dt)
    if not _G.state then return end
    Historian.dayTimer = Historian.dayTimer + dt
    if Historian.dayTimer >= 30 then
        Historian.dayTimer = 0
        -- Process writing
        for i = #Historian.activeWriting, 1, -1 do
            local w = Historian.activeWriting[i]
            w.daysRemaining = w.daysRemaining - 1
            -- Update chapters written
            local progress = 1 - (w.daysRemaining / w.totalDays)
            w.chaptersWritten = math.floor(w.chapters * progress)
            if w.daysRemaining <= 0 then
                Historian.completeWriting(w)
                table.remove(Historian.activeWriting, i)
            end
        end
        -- Process research
        for i = #Historian.activeResearch, 1, -1 do
            local r = Historian.activeResearch[i]
            r.daysRemaining = r.daysRemaining - 1
            if r.daysRemaining <= 0 then
                Historian.completeResearch(r)
                table.remove(Historian.activeResearch, i)
            end
        end
        -- Pay upkeep
        local totalUpkeep = 0
        for _, b in ipairs(Historian.buildings) do
            local def = BUILDINGS[b.type]
            if def and def.upkeep then totalUpkeep = totalUpkeep + def.upkeep end
        end
        if Historian.historian then totalUpkeep = totalUpkeep + 30 end
        if totalUpkeep > 0 and _G.state then
            _G.state.gold = math.max(0, (_G.state.gold or 0) - totalUpkeep)
        end
    end
end

-- ============================================================
-- HELPERS
-- ============================================================
function Historian.getVolumeInfo(volumeId) return VOLUMES[volumeId] end
function Historian.getResearchTopicInfo(topicId) return RESEARCH_TOPICS[topicId] end
function Historian.getBuildingInfo(buildingId) return BUILDINGS[buildingId] end

function Historian.getLegacyRank()
    local score = Historian.legacyScore
    if score >= 500 then return "Mitičen"
    elseif score >= 300 then return "Legendaren"
    elseif score >= 200 then return "Znamenit"
    elseif score >= 100 then return "Omembni"
    elseif score >= 50 then return "Spominski"
    else return "Pozabljen" end
end

function Historian.getStats()
    return {
        completedVolumes = #Historian.completedVolumes,
        activeWriting = #Historian.activeWriting,
        activeResearch = #Historian.activeResearch,
        numBuildings = #Historian.buildings,
        hasHistorian = Historian.historian ~= nil,
        historianName = Historian.historian and Historian.historian.name or "—",
        historianSkill = Historian.historian and Historian.historian.skill or 0,
        historianAccuracy = Historian.historian and Historian.historian.accuracy or 0,
        totalVolumesWritten = Historian.totalVolumesWritten,
        totalResearchCompleted = Historian.totalResearchCompleted,
        genealogySize = #Historian.genealogy,
        legacyScore = Historian.legacyScore,
        legacyRank = Historian.getLegacyRank(),
        prestigeBonus = Historian.getPrestigeBonus(),
    }
end

return Historian
