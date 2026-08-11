-- objects/QA/RoyalArchiveRecordsSystem.lua
-- Castle Kingdoms 2027 v3.2.7 - Royal Archive & Records System
--
-- Manages royal documents, treaties, edicts, land grants, and historical
-- records. Provides bonuses for organized archives and access to past decisions.
--
-- Features:
-- - 6 document types (treaty, edict, land grant, marriage contract, tax record, chronicle)
-- - Archive buildings (storage with capacity)
-- - Document search and retrieval
-- - Treaty management (active, expired, broken)
-- - Land grant tracking
-- - Royal scribes (NPCs who write faster)
-- - Document preservation (degradation over time)
-- - Legal reference (bonuses from having records)

local Archive = {}

-- ============================================================
-- DOCUMENT TYPES
-- ============================================================
local DOCUMENT_TYPES = {
    treaty = {
        name = "Pogodba",
        nameEn = "Treaty",
        icon = "📜",
        degradationRate = 0.5,  -- per year
        legalWeight = 10,
        description = "Uradna mednarodna pogodba.",
    },
    edict = {
        name = "Odlok",
        nameEn = "Edict",
        icon = "📋",
        degradationRate = 0.3,
        legalWeight = 8,
        description = "Kraljevi odlok z zakonsko močjo.",
    },
    land_grant = {
        name = "Darovnica",
        nameEn = "Land Grant",
        icon = "🗺",
        degradationRate = 0.2,
        legalWeight = 12,
        description = "Daritev zemlje podaniku ali cerkvi.",
    },
    marriage_contract = {
        name = "Porokna pogodba",
        nameEn = "Marriage Contract",
        icon = "💍",
        degradationRate = 0.1,
        legalWeight = 15,
        description = "Uradna porokna pogodba med hišama.",
    },
    tax_record = {
        name = "Davčni zapis",
        nameEn = "Tax Record",
        icon = "💰",
        degradationRate = 0.8,
        legalWeight = 5,
        description = "Zapis o pobranih davkih.",
    },
    chronicle = {
        name = "Kronika",
        nameEn = "Chronicle",
        icon = "📖",
        degradationRate = 0.1,
        legalWeight = 20,
        description = "Zgodovinski zapis dogodkov.",
    },
}

-- ============================================================
-- ARCHIVE BUILDINGS
-- ============================================================
local ARCHIVE_BUILDINGS = {
    scroll_cabinet = {
        name = "Omara za zvitke",
        cost = { gold = 200, wood = 100 },
        upkeep = 5,
        capacity = 50,
        preservationBonus = 0.10,
        description = "Preprosta omara za shranjevanje dokumentov.",
    },
    archive_room = {
        name = "Arhivska soba",
        cost = { gold = 800, wood = 200, stone = 200 },
        upkeep = 20,
        capacity = 200,
        preservationBonus = 0.30,
        description = "Klimatizirana soba za ohranjanje dokumentov.",
    },
    royal_archive = {
        name = "Kraljevi arhiv",
        cost = { gold = 3000, wood = 300, stone = 800 },
        upkeep = 60,
        capacity = 1000,
        preservationBonus = 0.60,
        description = "Veliki kraljevi arhiv z vsemi zapisi.",
    },
    grand_library = {
        name = "Velika knjižnica",
        cost = { gold = 8000, wood = 500, stone = 2000 },
        upkeep = 150,
        capacity = 5000,
        preservationBonus = 0.90,
        legalBonus = 10,
        description = "Največja zbirka znanja in dokumentov.",
    },
}

-- ============================================================
-- STATE
-- ============================================================
Archive.documents = {}                  -- All stored documents
Archive.archiveBuildings = {}           -- Built archive buildings
Archive.activeTreaties = {}             -- Active treaties
Archive.landGrants = {}                 -- Land grants given
Archive.scribes = {}                    -- Royal scribes
Archive.totalDocuments = 0
Archive.documentsLost = 0              -- Lost to degradation
Archive.dayTimer = 0
Archive.yearTimer = 0

-- ============================================================
-- INITIALIZATION
-- ============================================================
function Archive.init()
    Archive.documents = {}
    Archive.archiveBuildings = {}
    Archive.activeTreaties = {}
    Archive.landGrants = {}
    Archive.scribes = {}
    Archive.totalDocuments = 0
    Archive.documentsLost = 0
    Archive.dayTimer = 0
    Archive.yearTimer = 0
    print("[Archive] Royal Archive & Records System initialized (6 doc types, 4 buildings)")
end

-- ============================================================
-- BUILDING CONSTRUCTION
-- ============================================================
function Archive.canBuild(buildingId)
    local def = ARCHIVE_BUILDINGS[buildingId]
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

function Archive.build(buildingId)
    local ok, err = Archive.canBuild(buildingId)
    if not ok then return false, err end
    local def = ARCHIVE_BUILDINGS[buildingId]
    _G.state.gold = _G.state.gold - (def.cost.gold or 0)
    if _G.state.resources then
        for res, amt in pairs(def.cost) do
            if res ~= "gold" then
                _G.state.resources[res] = (_G.state.resources[res] or 0) - amt
            end
        end
    end
    table.insert(Archive.archiveBuildings, {
        type = buildingId,
        builtDay = os.time(),
    })
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Zgrajeno: " .. def.name, "success")
    end
    return true
end

function Archive.getTotalCapacity()
    local cap = 0
    for _, b in ipairs(Archive.archiveBuildings) do
        local def = ARCHIVE_BUILDINGS[b.type]
        if def and def.capacity then cap = cap + def.capacity end
    end
    return cap
end

function Archive.getPreservationBonus()
    local bonus = 0
    for _, b in ipairs(Archive.archiveBuildings) do
        local def = ARCHIVE_BUILDINGS[b.type]
        if def and def.preservationBonus then
            bonus = math.max(bonus, def.preservationBonus)
        end
    end
    return bonus
end

function Archive.getLegalBonus()
    local bonus = 0
    for _, b in ipairs(Archive.archiveBuildings) do
        local def = ARCHIVE_BUILDINGS[b.type]
        if def and def.legalBonus then bonus = bonus + def.legalBonus end
    end
    return bonus
end

-- ============================================================
-- DOCUMENT CREATION
-- ============================================================
function Archive.createDocument(docType, title, content, metadata)
    local def = DOCUMENT_TYPES[docType]
    if not def then return false, "Neznan tip dokumenta" end
    -- Check capacity
    if #Archive.documents >= Archive.getTotalCapacity() then
        return false, "Arhiv je poln"
    end
    local doc = {
        id = "doc_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        type = docType,
        typeName = def.name,
        icon = def.icon,
        title = title or "Neimenovan dokument",
        content = content or "",
        metadata = metadata or {},
        createdDay = os.time(),
        condition = 100,  -- 100 = perfect, 0 = destroyed
        legalWeight = def.legalWeight,
    }
    table.insert(Archive.documents, doc)
    Archive.totalDocuments = Archive.totalDocuments + 1
    -- Special handling for treaties
    if docType == "treaty" then
        table.insert(Archive.activeTreaties, {
            docId = doc.id,
            title = doc.title,
            targetFaction = metadata and metadata.targetFaction or "unknown",
            terms = metadata and metadata.terms or {},
            duration = metadata and metadata.duration or 0,  -- 0 = permanent
            daysRemaining = metadata and metadata.duration or 0,
            signedDay = os.time(),
            active = true,
        })
    elseif docType == "land_grant" then
        table.insert(Archive.landGrants, {
            docId = doc.id,
            recipient = metadata and metadata.recipient or "unknown",
            territory = metadata and metadata.territory or "unknown",
            size = metadata and metadata.size or 100,
            grantedDay = os.time(),
        })
    end
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Dokument ustvarjen: %s — %s", def.name, doc.title), "info")
    end
    if _G.GameEventBus then
        pcall(_G.GameEventBus.publish, "DOCUMENT_CREATED", { type = docType, title = doc.title })
    end
    return true, doc.id
end

-- ============================================================
-- SCRIBES
-- ============================================================
function Archive.hireScribe(name, skill)
    skill = skill or math.random(40, 80)
    local cost = 200 + skill * 5
    if not _G.state or (_G.state.gold or 0) < cost then
        return false, "Premalo zlata"
    end
    _G.state.gold = _G.state.gold - cost
    local scribe = {
        id = "scribe_" .. tostring(os.time()),
        name = name or ("Pisar " .. math.random(1, 99)),
        skill = skill,
        speed = 1.0 + (skill / 100),
        hiredDay = os.time(),
    }
    table.insert(Archive.scribes, scribe)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Pisar najet: %s (spretnost: %d)", scribe.name, skill), "success")
    end
    return true
end

function Archive.getTotalScribeSpeed()
    local speed = 1.0
    for _, s in ipairs(Archive.scribes) do
        speed = speed + (s.speed - 1.0)
    end
    return speed
end

-- ============================================================
-- DOCUMENT MANAGEMENT
-- ============================================================
function Archive.searchDocuments(query)
    query = query and query:lower() or ""
    local results = {}
    for _, d in ipairs(Archive.documents) do
        if query == "" or
           (d.title and d.title:lower():find(query)) or
           (d.content and d.content:lower():find(query)) or
           (d.typeName and d.typeName:lower():find(query)) then
            table.insert(results, d)
        end
    end
    return results
end

function Archive.findDocument(docId)
    for _, d in ipairs(Archive.documents) do
        if d.id == docId then return d end
    end
    return nil
end

function Archive.destroyDocument(docId)
    for i, d in ipairs(Archive.documents) do
        if d.id == docId then
            table.remove(Archive.documents, i)
            return true
        end
    end
    return false
end

-- ============================================================
-- TREATY MANAGEMENT
-- ============================================================
function Archive.breakTreaty(docId)
    for _, t in ipairs(Archive.activeTreaties) do
        if t.docId == docId and t.active then
            t.active = false
            t.broken = true
            t.brokenDay = os.time()
            -- Diplomatic hit
            if _G.DiplomacyController and t.targetFaction then
                pcall(_G.DiplomacyController.changeRelation, t.targetFaction, -20)
            end
            if _G.NotificationCenter then
                pcall(_G.NotificationCenter.notify,
                    "Pogodba prekinjena: " .. t.title, "warning")
            end
            return true
        end
    end
    return false
end

function Archive.getActiveTreaties()
    local result = {}
    for _, t in ipairs(Archive.activeTreaties) do
        if t.active then
            table.insert(result, t)
        end
    end
    return result
end

-- ============================================================
-- DEGRADATION
-- ============================================================
function Archive.updateDegradation()
    local preservation = Archive.getPreservationBonus()
    for i = #Archive.documents, 1, -1 do
        local d = Archive.documents[i]
        local def = DOCUMENT_TYPES[d.type]
        if def then
            local rate = def.degradationRate * (1 - preservation)
            d.condition = math.max(0, d.condition - rate)
            if d.condition <= 0 then
                -- Document destroyed
                Archive.documentsLost = Archive.documentsLost + 1
                table.remove(Archive.documents, i)
                if _G.NotificationCenter and d.legalWeight >= 10 then
                    pcall(_G.NotificationCenter.notify,
                        "Dokument uničen: " .. d.title, "warning")
                end
            end
        end
    end
end

function Archive.restoreDocument(docId)
    local doc = Archive.findDocument(docId)
    if not doc then return false, "Dokument ne obstaja" end
    if doc.condition >= 100 then return false, "Dokument je že popoln" end
    local cost = math.floor((100 - doc.condition) * 2)
    if not _G.state or (_G.state.gold or 0) < cost then
        return false, "Premalo zlata za obnovo"
    end
    _G.state.gold = _G.state.gold - cost
    doc.condition = 100
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Dokument obnovljen: " .. doc.title, "success")
    end
    return true
end

-- ============================================================
-- UPDATE
-- ============================================================
function Archive.update(dt)
    if not _G.state then return end
    Archive.dayTimer = Archive.dayTimer + dt
    Archive.yearTimer = Archive.yearTimer + dt
    -- Yearly tick (every 120 sec)
    if Archive.yearTimer >= 120 then
        Archive.yearTimer = 0
        Archive.updateDegradation()
    end
    -- Daily upkeep
    if Archive.dayTimer >= 30 then
        Archive.dayTimer = 0
        local totalUpkeep = 0
        for _, b in ipairs(Archive.archiveBuildings) do
            local def = ARCHIVE_BUILDINGS[b.type]
            if def and def.upkeep then totalUpkeep = totalUpkeep + def.upkeep end
        end
        for _, s in ipairs(Archive.scribes) do
            totalUpkeep = totalUpkeep + 5  -- scribe salary
        end
        if totalUpkeep > 0 and _G.state then
            _G.state.gold = math.max(0, (_G.state.gold or 0) - totalUpkeep)
        end
        -- Update treaty durations
        for _, t in ipairs(Archive.activeTreaties) do
            if t.active and t.duration > 0 then
                t.daysRemaining = t.daysRemaining - 1
                if t.daysRemaining <= 0 then
                    t.active = false
                    t.expired = true
                end
            end
        end
    end
end

-- ============================================================
-- HELPERS
-- ============================================================
function Archive.getDocumentTypeInfo(typeId) return DOCUMENT_TYPES[typeId] end
function Archive.getBuildingInfo(buildingId) return ARCHIVE_BUILDINGS[buildingId] end

function Archive.getStats()
    return {
        totalDocuments = #Archive.documents,
        capacity = Archive.getTotalCapacity(),
        numBuildings = #Archive.archiveBuildings,
        numScribes = #Archive.scribes,
        activeTreaties = #Archive.getActiveTreaties(),
        landGrants = #Archive.landGrants,
        totalDocumentsCreated = Archive.totalDocuments,
        documentsLost = Archive.documentsLost,
        legalBonus = Archive.getLegalBonus(),
    }
end

return Archive
