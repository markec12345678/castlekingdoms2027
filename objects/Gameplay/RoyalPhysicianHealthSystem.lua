-- objects/Gameplay/RoyalPhysicianHealthSystem.lua
-- Castle Kingdoms 2027 v3.4.7 - Royal Physician & Health System
--
-- Manages court physicians, medical treatments, surgery, and disease prevention.
-- Distinct from the Apothecary system — focuses on diagnosis and surgical procedures.
--
-- Features:
-- - 6 disease types (fever, infection, gout, consumption, pox, madness)
-- - 8 treatment types (bloodletting, herbal, surgery, prayer, diet, rest, purging, cauterization)
-- - 4 medical buildings (infirmary, hospital, surgery, apothecary shop)
-- - Physician NPC (skill affects treatment success)
-- - Diagnosis system (symptom-based)
-- - Surgical procedures (risky but effective)
-- - Court health tracking
-- - Epidemic prevention
-- - Medical research

local Physician = {}

-- ============================================================
-- DISEASE TYPES
-- ============================================================
local DISEASES = {
    fever = {
        name = "Vročina",
        nameEn = "Fever",
        severity = 3,
        duration = 7,
        contagion = 0.10,
        mortality = 0.05,
        symptoms = { "high_temp", "sweating", "weakness" },
        description = "Povišana telesna temperatura.",
    },
    infection = {
        name = "Okužba",
        nameEn = "Infection",
        severity = 5,
        duration = 14,
        contagion = 0.15,
        mortality = 0.10,
        symptoms = { "swelling", "redness", "pain", "pus" },
        description = "Bakterijska okužba rane.",
    },
    gout = {
        name = "Protin",
        nameEn = "Gout",
        severity = 4,
        duration = 30,
        contagion = 0.0,
        mortality = 0.0,
        symptoms = { "joint_pain", "swelling", "stiffness" },
        description = "Boleča bolezen sklepov.",
    },
    consumption = {
        name = "Sušica",
        nameEn = "Consumption",
        severity = 8,
        duration = 90,
        contagion = 0.20,
        mortality = 0.40,
        symptoms = { "cough", "weight_loss", "fatigue", "blood_sputum" },
        description = "Smrtonosna pljučna bolezen.",
    },
    pox = {
        name = "Črne koze",
        nameEn = "Smallpox",
        severity = 9,
        duration = 21,
        contagion = 0.30,
        mortality = 0.30,
        symptoms = { "rash", "fever", "blisters", "scarring" },
        description = "Smrtonosna nalezljiva bolezen.",
    },
    madness = {
        name = "Norost",
        nameEn = "Madness",
        severity = 6,
        duration = 0,  -- chronic
        contagion = 0.0,
        mortality = 0.0,
        symptoms = { "delusions", "erratic_behavior", "hallucinations" },
        description = "Duševna motnja, težko zdravljiva.",
    },
}

-- ============================================================
-- TREATMENT TYPES
-- ============================================================
local TREATMENTS = {
    bloodletting = {
        name = "Puščanje krvi",
        nameEn = "Bloodletting",
        cost = 50,
        successBonus = 0.10,
        risk = 0.15,
        description = "Srednjeveški standard — izpustitev 'slabe krvi'.",
    },
    herbal_remedy = {
        name = "Zeliščno zdravilo",
        nameEn = "Herbal Remedy",
        cost = 100,
        successBonus = 0.25,
        risk = 0.05,
        description = "Zeliščni napoji in obkladki.",
    },
    surgery = {
        name = "Operacija",
        nameEn = "Surgery",
        cost = 500,
        successBonus = 0.50,
        risk = 0.30,
        description = "Kirurški poseg — tvegano a učinkovito.",
    },
    prayer = {
        name = "Molitev",
        nameEn = "Prayer",
        cost = 0,
        successBonus = 0.05,
        risk = 0.0,
        faithCost = 20,
        description = "Versko zdravljenje z molitvijo.",
    },
    diet = {
        name = "Dieta",
        nameEn = "Diet",
        cost = 30,
        successBonus = 0.15,
        risk = 0.0,
        duration = 14,
        description = "Sprememba prehrane za okrevanje.",
    },
    rest = {
        name = "Počitek",
        nameEn = "Rest",
        cost = 10,
        successBonus = 0.20,
        risk = 0.0,
        duration = 7,
        description = "Mirovanje in okrevanje.",
    },
    purging = {
        name = "Čiščenje",
        nameEn = "Purging",
        cost = 80,
        successBonus = 0.12,
        risk = 0.20,
        description = "Izločanje toksinov (emetics, laxatives).",
    },
    cauterization = {
        name = "Kauterizacija",
        nameEn = "Cauterization",
        cost = 200,
        successBonus = 0.40,
        risk = 0.25,
        description = "Žganje rane z vročim železom.",
    },
}

-- ============================================================
-- MEDICAL BUILDINGS
-- ============================================================
local BUILDINGS = {
    infirmary = {
        name = "Bolnišnica",
        cost = { gold = 400, wood = 200, stone = 100 },
        upkeep = 15,
        capacity = 10,
        treatmentBonus = 5,
        description = "Osnovna bolnišnica za dvor.",
    },
    hospital = {
        name = "Velika bolnišnica",
        cost = { gold = 2000, wood = 400, stone = 500 },
        upkeep = 50,
        capacity = 30,
        treatmentBonus = 15,
        contagionReduction = 0.30,
        description = "Velika bolnišnica z izolacijo.",
    },
    surgery = {
        name = "Operacijska dvorana",
        cost = { gold = 1500, wood = 200, stone = 300, iron = 100 },
        upkeep = 40,
        capacity = 5,
        treatmentBonus = 25,
        surgeryBonus = 0.20,
        description = "Sterilna dvorana za operacije.",
    },
    quarantine_ward = {
        name = "Karantena",
        cost = { gold = 800, wood = 300, stone = 200 },
        upkeep = 20,
        capacity = 20,
        contagionReduction = 0.60,
        description = "Izolacija kužnih bolnikov.",
    },
}

-- ============================================================
-- STATE
-- ============================================================
Physician.activePatients = {}            -- Patients being treated
Physician.buildings = {}                 -- Built medical buildings
Physician.physician = nil                -- Hired physician NPC
Physician.courtHealth = 80               -- Average court health (0-100)
Physician.totalTreated = 0
Physician.totalCured = 0
Physician.totalDeaths = 0
Physician.totalSurgeries = 0
Physician.dayTimer = 0

-- ============================================================
-- INITIALIZATION
-- ============================================================
function Physician.init()
    Physician.activePatients = {}
    Physician.buildings = {}
    Physician.physician = nil
    Physician.courtHealth = 80
    Physician.totalTreated = 0
    Physician.totalCured = 0
    Physician.totalDeaths = 0
    Physician.totalSurgeries = 0
    Physician.dayTimer = 0
    print("[Physician] Royal Physician & Health System initialized (6 diseases, 8 treatments, 4 buildings)")
end

-- ============================================================
-- PHYSICIAN NPC
-- ============================================================
function Physician.hirePhysician(name, skill)
    skill = skill or math.random(40, 90)
    local cost = 600 + skill * 12
    if not _G.state or (_G.state.gold or 0) < cost then
        return false, "Premalo zlata"
    end
    _G.state.gold = _G.state.gold - cost
    Physician.physician = {
        name = name or ("Zdravnik " .. math.random(1, 99)),
        skill = skill,
        hiredDay = os.time(),
        patientsTreated = 0,
        surgeriesPerformed = 0,
    }
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Zdravnik najet: %s (spretnost: %d)", Physician.physician.name, skill), "success")
    end
    return true
end

-- ============================================================
-- BUILDINGS
-- ============================================================
function Physician.canBuild(buildingId)
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

function Physician.build(buildingId)
    local ok, err = Physician.canBuild(buildingId)
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
    table.insert(Physician.buildings, {
        type = buildingId,
        builtDay = os.time(),
    })
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Zgrajeno: " .. def.name, "success")
    end
    return true
end

function Physician.getTreatmentBonus()
    local bonus = 0
    for _, b in ipairs(Physician.buildings) do
        local def = BUILDINGS[b.type]
        if def and def.treatmentBonus then bonus = bonus + def.treatmentBonus end
    end
    return bonus
end

function Physician.getSurgeryBonus()
    local bonus = 0
    for _, b in ipairs(Physician.buildings) do
        local def = BUILDINGS[b.type]
        if def and def.surgeryBonus then bonus = bonus + def.surgeryBonus end
    end
    return bonus
end

function Physician.getContagionReduction()
    local reduction = 0
    for _, b in ipairs(Physician.buildings) do
        local def = BUILDINGS[b.type]
        if def and def.contagionReduction then reduction = math.max(reduction, def.contagionReduction) end
    end
    return reduction
end

function Physician.getTotalCapacity()
    local cap = 0
    for _, b in ipairs(Physician.buildings) do
        local def = BUILDINGS[b.type]
        if def and def.capacity then cap = cap + def.capacity end
    end
    return cap
end

-- ============================================================
-- DIAGNOSIS
-- ============================================================
function Physician.diagnose(patientName)
    -- Random disease based on severity weights
    local diseaseKeys = {}
    for k, _ in pairs(DISEASES) do
        table.insert(diseaseKeys, k)
    end
    local selected = diseaseKeys[math.random(#diseaseKeys)]
    local def = DISEASES[selected]
    local patient = {
        id = "patient_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        name = patientName or ("Bolnik " .. math.random(1, 99)),
        disease = selected,
        diseaseName = def.name,
        severity = def.severity,
        daysRemaining = def.duration,
        daysInfected = 0,
        health = 100 - (def.severity * 5),
        treated = false,
        cured = false,
        died = false,
        diagnosedDay = os.time(),
    }
    table.insert(Physician.activePatients, patient)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Diagnoza: %s — %s (resnost: %d)", patient.name, def.name, def.severity), "warning")
    end
    return patient.id
end

-- ============================================================
-- TREATMENT
-- ============================================================
function Physician.canTreat(patientId, treatmentType)
    local patient = nil
    for _, p in ipairs(Physician.activePatients) do
        if p.id == patientId then patient = p; break end
    end
    if not patient then return false, "Bolnik ne obstaja" end
    if patient.cured or patient.died then return false, "Bolnik ni več na zdravljenju" end
    local def = TREATMENTS[treatmentType]
    if not def then return false, "Neznano zdravljenje" end
    if not Physician.physician then return false, "Potreben zdravnik" end
    if def.cost > 0 and (not _G.state or (_G.state.gold or 0) < def.cost) then
        return false, "Premalo zlata"
    end
    return true
end

function Physician.treat(patientId, treatmentType)
    local ok, err = Physician.canTreat(patientId, treatmentType)
    if not ok then return false, err end
    local def = TREATMENTS[treatmentType]
    -- Find patient
    local patient = nil
    for _, p in ipairs(Physician.activePatients) do
        if p.id == patientId then patient = p; break end
    end
    -- Pay cost
    if def.cost > 0 and _G.state then
        _G.state.gold = _G.state.gold - def.cost
    end
    -- Pay faith cost
    if def.faithCost and _G.Religion then
        pcall(function()
            _G.Religion.faith = math.max(0, _G.Religion.faith - def.faithCost)
        end)
    end
    -- Calculate success
    local successChance = 0.30 + def.successBonus
    successChance = successChance + (Physician.getTreatmentBonus() / 100)
    if Physician.physician then
        successChance = successChance + (Physician.physician.skill / 200)
    end
    -- Surgery bonus
    if treatmentType == "surgery" then
        successChance = successChance + Physician.getSurgeryBonus()
    end
    -- Disease severity reduces chance
    local diseaseDef = DISEASES[patient.disease]
    if diseaseDef then
        successChance = successChance - (diseaseDef.severity / 20)
    end
    successChance = math.max(0.05, math.min(0.90, successChance))
    patient.treated = true
    Physician.totalTreated = Physician.totalTreated + 1
    if Physician.physician then
        Physician.physician.patientsTreated = Physician.physician.patientsTreated + 1
    end
    -- Roll for treatment risk
    if math.random() < def.risk then
        -- Complication!
        patient.health = math.max(0, patient.health - 20)
        if _G.NotificationCenter then
            pcall(_G.NotificationCenter.notify,
                string.format("Komplikacija pri zdravljenju: %s!", patient.name), "danger")
        end
        if patient.health <= 0 then
            patient.died = true
            Physician.totalDeaths = Physician.totalDeaths + 1
            return true
        end
    end
    -- Roll for success
    if math.random() < successChance then
        -- Cured!
        patient.cured = true
        patient.health = math.min(100, patient.health + 30)
        Physician.totalCured = Physician.totalCured + 1
        if _G.NotificationCenter then
            pcall(_G.NotificationCenter.notify,
                string.format("Bolnik ozdravljen: %s!", patient.name), "success")
        end
        -- Skill progression
        if Physician.physician and math.random() < 0.20 then
            Physician.physician.skill = math.min(100, Physician.physician.skill + 1)
        end
        if treatmentType == "surgery" then
            Physician.totalSurgeries = Physician.totalSurgeries + 1
            if Physician.physician then
                Physician.physician.surgeriesPerformed = Physician.physician.surgeriesPerformed + 1
            end
        end
    else
        -- Treatment failed but patient still alive
        patient.health = math.max(0, patient.health + 5)  -- small recovery
        if _G.NotificationCenter then
            pcall(_G.NotificationCenter.notify,
                string.format("Zdravljenje neuspešno: %s", patient.name), "warning")
        end
    end
    return true
end

-- ============================================================
-- PATIENT UPDATES
-- ============================================================
function Physician.updatePatients()
    local contagionReduction = Physician.getContagionReduction()
    for i = #Physician.activePatients, 1, -1 do
        local p = Physician.activePatients[i]
        if not p.cured and not p.died then
            p.daysInfected = p.daysInfected + 1
            local def = DISEASES[p.disease]
            if def then
                -- Health decline
                p.health = math.max(0, p.health - (def.severity / 10))
                -- Duration check
                if def.duration > 0 then
                    p.daysRemaining = p.daysRemaining - 1
                    if p.daysRemaining <= 0 then
                        -- Disease runs its course
                        local survivalChance = 1 - def.mortality
                        if math.random() < survivalChance then
                            p.cured = true
                            p.health = math.min(100, p.health + 20)
                            Physician.totalCured = Physician.totalCured + 1
                        else
                            p.died = true
                            Physician.totalDeaths = Physician.totalDeaths + 1
                            if _G.NotificationCenter then
                                pcall(_G.NotificationCenter.notify,
                                    string.format("Bolnik umrl: %s (%s)", p.name, def.name), "danger")
                            end
                        end
                    end
                end
                -- Death from low health
                if p.health <= 0 and not p.died then
                    p.died = true
                    Physician.totalDeaths = Physician.totalDeaths + 1
                end
                -- Contagion
                if def.contagion > 0 and math.random() < (def.contagion * (1 - contagionReduction)) then
                    -- Spread to another court member
                    Physician.diagnose("Dvorjan " .. math.random(1, 99))
                end
            end
        end
        -- Remove resolved patients after delay
        if p.cured or p.died then
            p.cleanupTimer = (p.cleanupTimer or 30) - 1
            if p.cleanupTimer <= 0 then
                table.remove(Physician.activePatients, i)
            end
        end
    end
    -- Update court health
    if #Physician.activePatients > 0 then
        local totalHealth = 0
        for _, p in ipairs(Physician.activePatients) do
            totalHealth = totalHealth + p.health
        end
        Physician.courtHealth = math.floor(totalHealth / #Physician.activePatients)
    else
        Physician.courtHealth = math.min(100, Physician.courtHealth + 1)
    end
end

-- ============================================================
-- EPIDEMIC PREVENTION
-- ============================================================
function Physician.checkEpidemic()
    local contagiousCount = 0
    for _, p in ipairs(Physician.activePatients) do
        local def = DISEASES[p.disease]
        if def and def.contagion > 0.15 and not p.cured and not p.died then
            contagiousCount = contagiousCount + 1
        end
    end
    if contagiousCount >= 3 then
        if _G.NotificationCenter then
            pcall(_G.NotificationCenter.notify,
                "Epidemija na dvoru! Karantena priporočena.", "danger")
        end
        if _G.GameEventBus then
            pcall(_G.GameEventBus.publish, "EPIDEMIC_WARNING", { count = contagiousCount })
        end
    end
end

-- ============================================================
-- UPDATE
-- ============================================================
function Physician.update(dt)
    if not _G.state then return end
    Physician.dayTimer = Physician.dayTimer + dt
    if Physician.dayTimer >= 30 then
        Physician.dayTimer = 0
        Physician.updatePatients()
        Physician.checkEpidemic()
        -- Random new patients
        if math.random() < 0.05 and #Physician.activePatients < Physician.getTotalCapacity() then
            Physician.diagnose()
        end
        -- Pay upkeep
        local totalUpkeep = 0
        for _, b in ipairs(Physician.buildings) do
            local def = BUILDINGS[b.type]
            if def and def.upkeep then totalUpkeep = totalUpkeep + def.upkeep end
        end
        if Physician.physician then totalUpkeep = totalUpkeep + 30 end
        if totalUpkeep > 0 and _G.state then
            _G.state.gold = math.max(0, (_G.state.gold or 0) - totalUpkeep)
        end
    end
end

-- ============================================================
-- HELPERS
-- ============================================================
function Physician.getDiseaseInfo(diseaseId) return DISEASES[diseaseId] end
function Physician.getTreatmentInfo(treatmentId) return TREATMENTS[treatmentId] end
function Physician.getBuildingInfo(buildingId) return BUILDINGS[buildingId] end

function Physician.getStats()
    return {
        numPatients = #Physician.activePatients,
        capacity = Physician.getTotalCapacity(),
        numBuildings = #Physician.buildings,
        hasPhysician = Physician.physician ~= nil,
        physicianName = Physician.physician and Physician.physician.name or "—",
        physicianSkill = Physician.physician and Physician.physician.skill or 0,
        courtHealth = Physician.courtHealth,
        totalTreated = Physician.totalTreated,
        totalCured = Physician.totalCured,
        totalDeaths = Physician.totalDeaths,
        totalSurgeries = Physician.totalSurgeries,
        contagionReduction = Physician.getContagionReduction(),
    }
end

return Physician
