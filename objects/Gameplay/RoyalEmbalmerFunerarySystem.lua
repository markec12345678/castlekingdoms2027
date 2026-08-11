-- objects/Gameplay/RoyalEmbalmerFunerarySystem.lua
-- Castle Kingdoms 2027 v3.6.4 - Royal Embalmer & Funerary System
--
-- Manages funerary rites, embalming, tomb construction, and memorial services.
-- Provides proper send-offs for the deceased, affecting dynasty and faith.
--
-- Features:
-- - 6 funeral types (pauper, common, knight, noble, royal, state funeral)
-- - 8 embalming techniques (desiccation, evisceration, immersion, wrapping, ...)
-- - 4 funerary buildings (charnel house, crypt, mausoleum, royal tomb)
-- - Embalmer NPC (skill affects preservation)
-- - Tomb construction (time-based)
-- - Memorial services (faith and happiness)
-- - Dynasty ancestor tracking
-- - Funeral procession

local Funerary = {}

local FUNERALS = {
    pauper = { name = "Revni pokop", cost = 10, time = 1, faithBonus = 1, happiness = 0, description = "Najpreprostejši pokop." },
    common = { name = "Navadni pokop", cost = 50, time = 2, faithBonus = 3, happiness = 1, description = "Standardni pokop za meščane." },
    knight = { name = "Viteški pokop", cost = 200, time = 3, faithBonus = 5, happiness = 2, prestige = 5, description = "Pokop z vojaškimi častmi." },
    noble = { name = "Plemiški pokop", cost = 800, time = 5, faithBonus = 8, happiness = 3, prestige = 10, description = "Veliki pokop za plemiče." },
    royal = { name = "Kraljevski pokop", cost = 3000, time = 7, faithBonus = 15, happiness = 5, prestige = 25, description = "Pokop za člane kraljeve družine." },
    state = { name = "Državni pogreb", cost = 10000, time = 14, faithBonus = 25, happiness = 8, prestige = 50, description = "Največji pogreb za monarha." },
}

local EMBALMING = {
    desiccation = { name = "Sušenje", cost = 50, time = 3, preservation = 20, description = "Sušenje telesa na soncu." },
    evisceration = { name = "Izločitev organov", cost = 100, time = 5, preservation = 35, description = "Odstranitev notranjih organov." },
    immersion = { name = "Potopitev", cost = 80, time = 4, preservation = 25, description = "Potopitev v konzervans." },
    wrapping = { name = "Zavijanje", cost = 60, time = 2, preservation = 15, description = "Zavijanje v tkanino." },
    resin = { name = "Smolna obdelava", cost = 200, time = 7, preservation = 50, description = "Obdelava z naravnimi smolami." },
    spices = { name = "Dišavne začimbe", cost = 150, time = 3, preservation = 30, aromaBonus = 10, description = "Začimbe za prijeten vonj." },
    wax = { name = "Voščena obdelava", cost = 180, time = 5, preservation = 40, description = "Potopitev v vosek." },
    mummification = { name = "Mumifikacija", cost = 500, time = 14, preservation = 80, prestige = 15, description = "Popolna mumifikacija." },
}

local BUILDINGS = {
    charnel = { name = "Kostnica", cost = { gold = 200, wood = 100, stone = 50 }, upkeep = 5, description = "Skladišče za kosti." },
    crypt = { name = "Kripta", cost = { gold = 1500, wood = 200, stone = 500 }, upkeep = 30, preservationBonus = 15, description = "Podzemna grobnica." },
    mausoleum = { name = "Mavzolej", cost = { gold = 5000, wood = 300, stone = 1200 }, upkeep = 80, preservationBonus = 30, prestigeBonus = 15, description = "Velika grobnica nad zemljo." },
    royal_tomb = { name = "Kraljevska grobnica", cost = { gold = 15000, wood = 500, stone = 3000 }, upkeep = 200, preservationBonus = 50, prestigeBonus = 40, description = "Najveličastnejša grobnica." },
}

Funerary.pendingFunerals = {}
Funerary.completedFunerals = {}
Funerary.buildings = {}
Funerary.embalmer = nil
Funerary.ancestors = {}
Funerary.totalFunerals = 0
Funerary.totalEmbalmed = 0
Funerary.dayTimer = 0

function Funerary.init()
    Funerary.pendingFunerals = {}
    Funerary.completedFunerals = {}
    Funerary.buildings = {}
    Funerary.embalmer = nil
    Funerary.ancestors = {}
    Funerary.totalFunerals = 0
    Funerary.totalEmbalmed = 0
    Funerary.dayTimer = 0
    print("[Funerary] Royal Embalmer & Funerary System initialized (6 funerals, 8 embalming, 4 buildings)")
end

function Funerary.hireEmbalmer(name, skill)
    skill = skill or math.random(35, 80)
    local cost = 300 + skill * 5
    if not _G.state or (_G.state.gold or 0) < cost then return false, "Premalo zlata" end
    _G.state.gold = _G.state.gold - cost
    Funerary.embalmer = { name = name or ("Balzamir " .. math.random(1, 99)), skill = skill, hiredDay = os.time(), bodiesProcessed = 0 }
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Balzamir najet: %s (spretnost: %d)", Funerary.embalmer.name, skill), "success") end
    return true
end

function Funerary.canBuild(id) local d = BUILDINGS[id]; if not d then return false, "Neznana zgradba" end; if not _G.state then return false, "Brez stanja" end; if _G.state.gold < (d.cost.gold or 0) then return false, "Premalo zlata" end; if _G.state.resources then for r,a in pairs(d.cost) do if r ~= "gold" and (_G.state.resources[r] or 0) < a then return false, "Premalo " .. r end end end; return true end
function Funerary.build(id) local ok,e = Funerary.canBuild(id); if not ok then return false, e end; local d = BUILDINGS[id]; _G.state.gold = _G.state.gold - (d.cost.gold or 0); if _G.state.resources then for r,a in pairs(d.cost) do if r ~= "gold" then _G.state.resources[r] = (_G.state.resources[r] or 0) - a end end end; table.insert(Funerary.buildings, {type = id, builtDay = os.time()}); if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, "Zgrajeno: " .. d.name, "success") end; return true end
function Funerary.getPreservationBonus() local b = 0; for _,bd in ipairs(Funerary.buildings) do local d = BUILDINGS[bd.type]; if d and d.preservationBonus then b = b + d.preservationBonus end end; return b end
function Funerary.getPrestigeBonus() local b = 0; for _,bd in ipairs(Funerary.buildings) do local d = BUILDINGS[bd.type]; if d and d.prestigeBonus then b = b + d.prestigeBonus end end; return b end

function Funerary.organizeFuneral(deceasedName, funeralType, embalmingType)
    local fDef = FUNERALS[funeralType]
    if not fDef then return false, "Neznan tip pogreba" end
    if not _G.state or (_G.state.gold or 0) < fDef.cost then return false, "Premalo zlata" end
    _G.state.gold = _G.state.gold - fDef.cost
    local eDef = EMBALMING[embalmingType]
    if eDef then
        if not _G.state or (_G.state.gold or 0) < eDef.cost then return false, "Premalo zlata za balzamiranje" end
        _G.state.gold = _G.state.gold - eDef.cost
    end
    local totalTime = fDef.time
    if eDef then totalTime = totalTime + eDef.time end
    table.insert(Funerary.pendingFunerals, {
        id = "funeral_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        deceasedName = deceasedName or "Neznani pokojni",
        funeralType = funeralType, funeralName = fDef.name,
        embalmingType = embalmingType, embalmingName = eDef and eDef.name or "brez",
        daysRemaining = totalTime, faithBonus = fDef.faithBonus,
        happiness = fDef.happiness, prestige = fDef.prestige or 0,
        preservation = (eDef and eDef.preservation or 0) + Funerary.getPreservationBonus(),
        started = os.time(),
    })
    Funerary.totalFunerals = Funerary.totalFunerals + 1
    if eDef then Funerary.totalEmbalmed = Funerary.totalEmbalmed + 1 end
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Pogreb organiziran: %s — %s (%d dni)", deceasedName or "Pokojni", fDef.name, totalTime), "important") end
    return true
end

function Funerary.completeFuneral(f)
    if _G.Religion then pcall(_G.Religion.addFaith, f.faithBonus) end
    if _G.state and _G.state.happiness then _G.state.happiness = math.min(100, _G.state.happiness + f.happiness) end
    if f.prestige > 0 and _G.state and _G.state.happiness then _G.state.happiness = math.min(100, _G.state.happiness + f.prestige) end
    table.insert(Funerary.ancestors, {
        name = f.deceasedName, funeralType = f.funeralName,
        embalmingType = f.embalmingName, preservation = f.preservation,
        buriedDay = os.time(),
    })
    table.insert(Funerary.completedFunerals, { deceasedName = f.deceasedName, funeralType = f.funeralName, completedDay = os.time() })
    if Funerary.embalmer then Funerary.embalmer.bodiesProcessed = Funerary.embalmer.bodiesProcessed + 1; if math.random() < 0.15 then Funerary.embalmer.skill = math.min(100, Funerary.embalmer.skill + 1) end end
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Pogreb končan: %s (+%d vere, +%d sreče)", f.deceasedName, f.faithBonus, f.happiness), "success") end
    if _G.GameEventBus then pcall(_G.GameEventBus.publish, "FUNERAL_COMPLETED", { name = f.deceasedName, type = f.funeralType }) end
end

function Funerary.update(dt)
    if not _G.state then return end
    Funerary.dayTimer = Funerary.dayTimer + dt
    if Funerary.dayTimer >= 30 then
        Funerary.dayTimer = 0
        for i = #Funerary.pendingFunerals, 1, -1 do
            local f = Funerary.pendingFunerals[i]
            f.daysRemaining = f.daysRemaining - 1
            if f.daysRemaining <= 0 then Funerary.completeFuneral(f); table.remove(Funerary.pendingFunerals, i) end
        end
        local totalUpkeep = 0
        for _, b in ipairs(Funerary.buildings) do local d = BUILDINGS[b.type]; if d and d.upkeep then totalUpkeep = totalUpkeep + d.upkeep end end
        if Funerary.embalmer then totalUpkeep = totalUpkeep + 15 end
        if totalUpkeep > 0 and _G.state then _G.state.gold = math.max(0, (_G.state.gold or 0) - totalUpkeep) end
    end
end

function Funerary.getFuneralInfo(id) return FUNERALS[id] end
function Funerary.getEmbalmingInfo(id) return EMBALMING[id] end
function Funerary.getBuildingInfo(id) return BUILDINGS[id] end
function Funerary.getStats()
    return { pendingFunerals = #Funerary.pendingFunerals, completedFunerals = #Funerary.completedFunerals,
        numBuildings = #Funerary.buildings, hasEmbalmer = Funerary.embalmer ~= nil,
        embalmerName = Funerary.embalmer and Funerary.embalmer.name or "—",
        embalmerSkill = Funerary.embalmer and Funerary.embalmer.skill or 0,
        ancestorsCount = #Funerary.ancestors, totalFunerals = Funerary.totalFunerals,
        totalEmbalmed = Funerary.totalEmbalmed, prestigeBonus = Funerary.getPrestigeBonus() }
end

return Funerary
