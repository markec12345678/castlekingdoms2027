-- objects/QA/RoyalSurveyorLandMeasurementSystem.lua
-- Castle Kingdoms 2027 v3.7.2 - Royal Surveyor & Land Measurement System
--
-- Manages land surveying, property boundaries, and cadastral records.
-- Provides accurate land measurement for taxation, disputes, and development.
--
-- Features:
-- - 6 survey types (boundary, topographic, cadastral, construction, agricultural, mining)
-- - 8 measurement tools (chain, rod, astrolabe, theodolite, level, compass, rope, pole)
-- - 4 surveyor buildings (survey office, observatory, cartography room, royal survey institute)
-- - Surveyor NPC (skill affects accuracy)
-- - Land parcel registration
-- - Boundary dispute resolution
-- - Measurement accuracy system

local Surveyor = {}

local SURVEYS = {
    boundary = { name = "Mejna survey", time = 5, accuracy = 0.70, cost = 100, description = "Določitev meja posesti." },
    topographic = { name = "Topografska survey", time = 14, accuracy = 0.60, cost = 300, description = "Zemljišče z višinami." },
    cadastral = { name = "Katastrska survey", time = 10, accuracy = 0.75, cost = 200, description = "Uradni register parcel." },
    construction = { name = "Gradbena survey", time = 7, accuracy = 0.85, cost = 250, description = "Priprava za gradnjo." },
    agricultural = { name = "Kmetijska survey", time = 5, accuracy = 0.70, cost = 150, description = "Ocena kmetijske zemlje." },
    mining = { name = "Rudarska survey", time = 14, accuracy = 0.65, cost = 500, description = "Raziskovanje rudnih nahajališč." },
}

local TOOLS = {
    chain = { name = "Veriga", cost = 20, accuracyBonus = 5, description = "Gunterjeva veriga za meritve." },
    rod = { name = "Palica", cost = 10, accuracyBonus = 3, description = "Preprosta merilna palica." },
    astrolabe = { name = "Astrolab", cost = 200, accuracyBonus = 15, description = "Za astronomske meritve." },
    theodolite = { name = "Teodolit", cost = 500, accuracyBonus = 25, prestige = 5, description = "Napredna merilna naprava." },
    level = { name = "Libela", cost = 50, accuracyBonus = 8, description = "Za vodoravne meritve." },
    compass = { name = "Kompas", cost = 80, accuracyBonus = 10, description = "Za določanje smeri." },
    rope = { name = "Vrv", cost = 5, accuracyBonus = 2, description = "Preprosta merilna vrv." },
    pole = { name = "Kol", cost = 3, accuracyBonus = 2, description = "Označevalni kol." },
}

local BUILDINGS = {
    survey_office = { name = "Geodetska pisarna", cost = { gold = 300, wood = 100 }, upkeep = 10, accuracyBonus = 5, description = "Pisarna za geodete." },
    observatory = { name = "Observatorij", cost = { gold = 2000, wood = 200, stone = 500 }, upkeep = 40, accuracyBonus = 20, prestigeBonus = 10, description = "Za astronomske meritve." },
    cartography_room = { name = "Kartografska soba", cost = { gold = 1000, wood = 200, stone = 300 }, upkeep = 25, accuracyBonus = 15, description = "Za izdelavo zemljevidov." },
    royal_survey_institute = { name = "Kraljevski geodetski inštitut", cost = { gold = 5000, wood = 400, stone = 1000 }, upkeep = 100, accuracyBonus = 35, prestigeBonus = 20, description = "Najvišja geodetska ustanova." },
}

Surveyor.parcels = {}
Surveyor.tools = {}
Surveyor.buildings = {}
Surveyor.surveyor = nil
Surveyor.activeSurveys = {}
Surveyor.totalSurveys = 0
Surveyor.dayTimer = 0

function Surveyor.init()
    Surveyor.parcels = {}
    Surveyor.tools = {}
    Surveyor.buildings = {}
    Surveyor.surveyor = nil
    Surveyor.activeSurveys = {}
    Surveyor.totalSurveys = 0
    Surveyor.dayTimer = 0
    print("[Surveyor] Royal Surveyor & Land Measurement System initialized (6 surveys, 8 tools, 4 buildings)")
end

function Surveyor.hireSurveyor(name, skill)
    skill = skill or math.random(40, 85)
    local cost = 400 + skill * 8
    if not _G.state or (_G.state.gold or 0) < cost then return false, "Premalo zlata" end
    _G.state.gold = _G.state.gold - cost
    Surveyor.surveyor = { name = name or ("Geodet " .. math.random(1, 99)), skill = skill, hiredDay = os.time(), surveysCompleted = 0 }
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Geodet najet: %s (spretnost: %d)", Surveyor.surveyor.name, skill), "success") end
    return true
end

function Surveyor.canBuild(id) local d = BUILDINGS[id]; if not d then return false, "Neznana zgradba" end; if not _G.state then return false, "Brez stanja" end; if _G.state.gold < (d.cost.gold or 0) then return false, "Premalo zlata" end; if _G.state.resources then for r,a in pairs(d.cost) do if r ~= "gold" and (_G.state.resources[r] or 0) < a then return false, "Premalo " .. r end end end; return true end
function Surveyor.build(id) local ok,e = Surveyor.canBuild(id); if not ok then return false, e end; local d = BUILDINGS[id]; _G.state.gold = _G.state.gold - (d.cost.gold or 0); if _G.state.resources then for r,a in pairs(d.cost) do if r ~= "gold" then _G.state.resources[r] = (_G.state.resources[r] or 0) - a end end end; table.insert(Surveyor.buildings, {type = id, builtDay = os.time()}); if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, "Zgrajeno: " .. d.name, "success") end; return true end
function Surveyor.getAccuracyBonus() local b = 0; for _,bd in ipairs(Surveyor.buildings) do local d = BUILDINGS[bd.type]; if d and d.accuracyBonus then b = b + d.accuracyBonus end end; return b end

function Surveyor.purchaseTool(toolType)
    local def = TOOLS[toolType]
    if not def then return false, "Neznan instrument" end
    if not _G.state or (_G.state.gold or 0) < def.cost then return false, "Premalo zlata" end
    _G.state.gold = _G.state.gold - def.cost
    Surveyor.tools[toolType] = (Surveyor.tools[toolType] or 0) + 1
    return true
end

function Surveyor.getToolAccuracyBonus()
    local b = 0
    for t, qty in pairs(Surveyor.tools) do
        local def = TOOLS[t]
        if def and qty > 0 then b = b + def.accuracyBonus end
    end
    return b
end

function Surveyor.canSurvey(surveyType, parcelName)
    local def = SURVEYS[surveyType]
    if not def then return false, "Nezna survey" end
    if not _G.state or (_G.state.gold or 0) < def.cost then return false, "Premalo zlata" end
    if #Surveyor.buildings == 0 then return false, "Potrebna geodetska zgradba" end
    if not Surveyor.surveyor then return false, "Potreben geodet" end
    return true
end

function Surveyor.startSurvey(surveyType, parcelName)
    local ok, err = Surveyor.canSurvey(surveyType, parcelName)
    if not ok then return false, err end
    local def = SURVEYS[surveyType]
    _G.state.gold = _G.state.gold - def.cost
    local accuracy = def.accuracy + (Surveyor.getAccuracyBonus() / 100) + (Surveyor.getToolAccuracyBonus() / 100)
    if Surveyor.surveyor then accuracy = accuracy + (Surveyor.surveyor.skill / 200) end
    accuracy = math.min(0.99, accuracy)
    local surveyTime = def.time
    if Surveyor.surveyor then surveyTime = math.max(1, surveyTime - math.floor(Surveyor.surveyor.skill / 10)) end
    table.insert(Surveyor.activeSurveys, {
        id = "survey_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        surveyType = surveyType, surveyName = def.name,
        parcelName = parcelName or ("Parcela " .. math.random(1, 999)),
        accuracy = accuracy, daysRemaining = surveyTime, started = os.time(),
    })
    Surveyor.totalSurveys = Surveyor.totalSurveys + 1
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Survey začeta: %s — %s (%d dni, %.0f%% natančnosti)", def.name, parcelName or "?", surveyTime, accuracy * 100), "info") end
    return true
end

function Surveyor.completeSurvey(s)
    local parcel = { id = s.id, name = s.parcelName, surveyType = s.surveyName, accuracy = s.accuracy, surveyedDay = os.time() }
    table.insert(Surveyor.parcels, parcel)
    if _G.state and _G.state.happiness then _G.state.happiness = math.min(100, _G.state.happiness + 2) end
    if Surveyor.surveyor then Surveyor.surveyor.surveysCompleted = Surveyor.surveyor.surveysCompleted + 1; if math.random() < 0.15 then Surveyor.surveyor.skill = math.min(100, Surveyor.surveyor.skill + 1) end end
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Survey končana: %s (natančnost: %.0f%%)", s.parcelName, s.accuracy * 100), "success") end
end

function Surveyor.update(dt)
    if not _G.state then return end
    Surveyor.dayTimer = Surveyor.dayTimer + dt
    if Surveyor.dayTimer >= 30 then
        Surveyor.dayTimer = 0
        for i = #Surveyor.activeSurveys, 1, -1 do
            local s = Surveyor.activeSurveys[i]
            s.daysRemaining = s.daysRemaining - 1
            if s.daysRemaining <= 0 then Surveyor.completeSurvey(s); table.remove(Surveyor.activeSurveys, i) end
        end
        local totalUpkeep = 0
        for _, bd in ipairs(Surveyor.buildings) do local d = BUILDINGS[bd.type]; if d and d.upkeep then totalUpkeep = totalUpkeep + d.upkeep end end
        if Surveyor.surveyor then totalUpkeep = totalUpkeep + 15 end
        if totalUpkeep > 0 and _G.state then _G.state.gold = math.max(0, (_G.state.gold or 0) - totalUpkeep) end
    end
end

function Surveyor.getSurveyInfo(id) return SURVEYS[id] end
function Surveyor.getToolInfo(id) return TOOLS[id] end
function Surveyor.getBuildingInfo(id) return BUILDINGS[id] end
function Surveyor.getStats()
    return { numParcels = #Surveyor.parcels, numTools = #Surveyor.tools,
        numBuildings = #Surveyor.buildings, hasSurveyor = Surveyor.surveyor ~= nil,
        surveyorName = Surveyor.surveyor and Surveyor.surveyor.name or "—",
        surveyorSkill = Surveyor.surveyor and Surveyor.surveyor.skill or 0,
        activeSurveys = #Surveyor.activeSurveys, totalSurveys = Surveyor.totalSurveys }
end

return Surveyor
