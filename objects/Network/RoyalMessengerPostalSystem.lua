-- objects/Network/RoyalMessengerPostalSystem.lua
-- Castle Kingdoms 2027 v3.7.4 - Royal Messenger & Postal System
--
-- Manages royal messengers, mail delivery, and communication networks.
-- Provides fast communication between courts, provinces, and allies.
--
-- Features:
-- - 6 message types (royal decree, diplomatic, military, trade, personal, intelligence)
-- - 8 messenger types (courier, mounted, relay, pigeon, signal, naval, diplomatic, spy)
-- - 4 postal buildings (post station, relay house, pigeon loft, royal post office)
-- - Messenger NPC (skill affects speed and reliability)
-- - Message delivery (time-based with risk of interception)
-- - Relay network for long-distance
-- - Carrier pigeon system
-- - Intelligence gathering

local Postal = {}

local MESSAGES = {
    decree = { name = "Kraljevi odlok", priority = 3, baseSpeed = 1.0, description = "Uradni odlok monarha." },
    diplomatic = { name = "Diplomatsko sporočilo", priority = 2, baseSpeed = 1.2, description = "Diplomatska korespondenca." },
    military = { name = "Vojaško sporočilo", priority = 3, baseSpeed = 1.5, description = "Nujne vojaške ukaze." },
    trade = { name = "Trgovsko sporočilo", priority = 1, baseSpeed = 1.0, description = "Trgovska naročila." },
    personal = { name = "Osebno sporočilo", priority = 1, baseSpeed = 0.8, description = "Zasebna korespondenca." },
    intelligence = { name = "Vohunska informacija", priority = 3, baseSpeed = 1.8, secrecy = 0.20, description = "Tajne informacije." },
}

local MESSENGERS = {
    courier = { name = "Kurir", cost = 50, upkeep = 5, speed = 1.0, reliability = 0.85, description = "Tekeči kurir za kratke razdalje." },
    mounted = { name = "Jahač", cost = 150, upkeep = 12, speed = 1.8, reliability = 0.90, description = "Jahač na konju." },
    relay = { name = "Relay", cost = 200, upkeep = 15, speed = 2.5, reliability = 0.95, description = "Relay sistem s postanki." },
    pigeon = { name = "Golob", cost = 30, upkeep = 1, speed = 3.0, reliability = 0.75, capacity = 1, description = "Carrier pigeon za majhna sporočila." },
    signal = { name = "Signalni ogenj", cost = 100, upkeep = 3, speed = 5.0, reliability = 0.60, capacity = 1, description = "Signalni ogenj za nujna sporočila." },
    naval = { name = "Mornariški", cost = 300, upkeep = 20, speed = 1.5, reliability = 0.80, description = "Mornariški kurir." },
    diplomatic = { name = "Diplomatski", cost = 250, upkeep = 15, speed = 1.5, reliability = 0.95, prestige = 3, description = "Diplomatski kurir z imuniteto." },
    spy = { name = "Vohun", cost = 200, upkeep = 10, speed = 2.0, reliability = 0.85, secrecy = 0.15, description = "Tajni kurir za vohunske informacije." },
}

local BUILDINGS = {
    post_station = { name = "Poštna postaja", cost = { gold = 200, wood = 100 }, upkeep = 8, speedBonus = 0.10, description = "Postaja za menjavo konjev." },
    relay_house = { name = "Relay hiša", cost = { gold = 500, wood = 200, stone = 100 }, upkeep = 15, speedBonus = 0.20, reliabilityBonus = 10, description = "Za organizacijo relay mreže." },
    pigeon_loft = { name = "Golobnjak", cost = { gold = 150, wood = 100 }, upkeep = 3, pigeonCapacity = 20, description = "Za gojenje in vzdrževanje golobov." },
    royal_post_office = { name = "Kraljevska pošta", cost = { gold = 2000, wood = 300, stone = 400 }, upkeep = 50, speedBonus = 0.35, reliabilityBonus = 20, prestigeBonus = 10, description = "Osrednja poštna ustanova." },
}

Postal.messengers = {}
Postal.buildings = {}
Postal.postmaster = nil
Postal.activeDeliveries = {}
Postal.pigeonStock = 10
Postal.totalDelivered = 0
Postal.totalIntercepted = 0
Postal.dayTimer = 0

function Postal.init()
    Postal.messengers = {}
    Postal.buildings = {}
    Postal.postmaster = nil
    Postal.activeDeliveries = {}
    Postal.pigeonStock = 10
    Postal.totalDelivered = 0
    Postal.totalIntercepted = 0
    Postal.dayTimer = 0
    print("[Postal] Royal Messenger & Postal System initialized (6 messages, 8 messengers, 4 buildings)")
end

function Postal.hirePostmaster(name, skill)
    skill = skill or math.random(40, 85)
    local cost = 300 + skill * 6
    if not _G.state or (_G.state.gold or 0) < cost then return false, "Premalo zlata" end
    _G.state.gold = _G.state.gold - cost
    Postal.postmaster = { name = name or ("Poštmajster " .. math.random(1, 99)), skill = skill, hiredDay = os.time(), deliveriesManaged = 0 }
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Poštmajster najet: %s (spretnost: %d)", Postal.postmaster.name, skill), "success") end
    return true
end

function Postal.canBuild(id) local d = BUILDINGS[id]; if not d then return false, "Neznana zgradba" end; if not _G.state then return false, "Brez stanja" end; if _G.state.gold < (d.cost.gold or 0) then return false, "Premalo zlata" end; if _G.state.resources then for r,a in pairs(d.cost) do if r ~= "gold" and (_G.state.resources[r] or 0) < a then return false, "Premalo " .. r end end end; return true end
function Postal.build(id) local ok,e = Postal.canBuild(id); if not ok then return false, e end; local d = BUILDINGS[id]; _G.state.gold = _G.state.gold - (d.cost.gold or 0); if _G.state.resources then for r,a in pairs(d.cost) do if r ~= "gold" then _G.state.resources[r] = (_G.state.resources[r] or 0) - a end end end; table.insert(Postal.buildings, {type = id, builtDay = os.time()}); if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, "Zgrajeno: " .. d.name, "success") end; return true end
function Postal.getSpeedBonus() local b = 0; for _,bd in ipairs(Postal.buildings) do local d = BUILDINGS[bd.type]; if d and d.speedBonus then b = b + d.speedBonus end end; return b end
function Postal.getReliabilityBonus() local b = 0; for _,bd in ipairs(Postal.buildings) do local d = BUILDINGS[bd.type]; if d and d.reliabilityBonus then b = b + d.reliabilityBonus end end; return b end

function Postal.hireMessenger(messengerType, customName)
    local def = MESSENGERS[messengerType]
    if not def then return false, "Neznan kurir" end
    if not _G.state or (_G.state.gold or 0) < def.cost then return false, "Premalo zlata" end
    _G.state.gold = _G.state.gold - def.cost
    table.insert(Postal.messengers, { id = "msg_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        type = messengerType, name = customName or (def.name .. " " .. #Postal.messengers + 1),
        speed = def.speed, reliability = def.reliability, secrecy = def.secrecy or 0,
        energy = 100, status = "available", hiredDay = os.time() })
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Kurir najet: %s (%s)", customName or def.name, def.name), "success") end
    return true
end

function Postal.findAvailableMessenger(messengerType)
    for _, m in ipairs(Postal.messengers) do
        if m.status == "available" and m.energy > 20 then
            if not messengerType or m.type == messengerType then return m end
        end
    end
    return nil
end

function Postal.canSend(messageType, messengerType, destination)
    local mDef = MESSAGES[messageType]
    if not mDef then return false, "Neznano sporočilo" end
    local messenger = Postal.findAvailableMessenger(messengerType)
    if not messenger then return false, "Ni prostega kurirja" end
    if not Postal.postmaster then return false, "Potreben poštmajster" end
    return true
end

function Postal.send(messageType, messengerType, destination)
    local ok, err = Postal.canSend(messageType, messengerType, destination)
    if not ok then return false, err end
    local mDef = MESSAGES[messageType]
    local messenger = Postal.findAvailableMessenger(messengerType)
    local msgDef = MESSENGERS[messenger.type]
    local speed = mDef.baseSpeed * messenger.speed * (1 + Postal.getSpeedBonus())
    if Postal.postmaster then speed = speed * (1 + Postal.postmaster.skill / 200) end
    local deliveryTime = math.max(1, math.floor(10 / speed))
    local reliability = messenger.reliability + (Postal.getReliabilityBonus() / 100)
    if Postal.postmaster then reliability = reliability + (Postal.postmaster.skill / 300) end
    reliability = math.min(0.99, reliability)
    local interceptionChance = (mDef.secrecy or 0.05) * (1 - (messenger.secrecy or 0))
    messenger.status = "delivering"
    messenger.energy = messenger.energy - 30
    table.insert(Postal.activeDeliveries, {
        id = "delivery_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        messageType = messageType, messageName = mDef.name, messengerId = messenger.id,
        messengerName = messenger.name, destination = destination or "neznano",
        daysRemaining = deliveryTime, reliability = reliability,
        interceptionChance = interceptionChance, priority = mDef.priority, started = os.time(),
    })
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Sporočilo poslano: %s (%s → %s, %d dni)", mDef.name, messenger.name, destination or "?", deliveryTime), "info") end
    return true
end

function Postal.completeDelivery(d)
    local messenger = nil
    for _, m in ipairs(Postal.messengers) do if m.id == d.messengerId then messenger = m; break end end
    if math.random() < d.interceptionChance then
        Postal.totalIntercepted = Postal.totalIntercepted + 1
        if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Sporočilo prestreženo: %s!", d.messageName), "danger") end
        if messenger then messenger.status = "available"; messenger.energy = math.min(100, messenger.energy + 20) end
        if _G.state and _G.state.happiness then _G.state.happiness = math.max(0, _G.state.happiness - 3) end
        return
    end
    if math.random() < d.reliability then
        Postal.totalDelivered = Postal.totalDelivered + 1
        if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Sporočilo dostavljeno: %s → %s", d.messageName, d.destination), "success") end
        if d.priority >= 3 and _G.state and _G.state.happiness then _G.state.happiness = math.min(100, _G.state.happiness + 2) end
    else
        if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Sporočilo izgubljeno: %s", d.messageName), "warning") end
    end
    if messenger then messenger.status = "available"; messenger.energy = math.min(100, messenger.energy + 30) end
    if Postal.postmaster then Postal.postmaster.deliveriesManaged = Postal.postmaster.deliveriesManaged + 1; if math.random() < 0.15 then Postal.postmaster.skill = math.min(100, Postal.postmaster.skill + 1) end end
end

function Postal.update(dt)
    if not _G.state then return end
    Postal.dayTimer = Postal.dayTimer + dt
    if Postal.dayTimer >= 30 then
        Postal.dayTimer = 0
        for i = #Postal.activeDeliveries, 1, -1 do
            local d = Postal.activeDeliveries[i]
            d.daysRemaining = d.daysRemaining - 1
            if d.daysRemaining <= 0 then Postal.completeDelivery(d); table.remove(Postal.activeDeliveries, i) end
        end
        for _, m in ipairs(Postal.messengers) do
            if m.status == "available" and m.energy < 100 then m.energy = math.min(100, m.energy + 15) end
        end
        local totalUpkeep = 0
        for _, m in ipairs(Postal.messengers) do local def = MESSENGERS[m.type]; if def then totalUpkeep = totalUpkeep + def.upkeep end end
        for _, bd in ipairs(Postal.buildings) do local d = BUILDINGS[bd.type]; if d and d.upkeep then totalUpkeep = totalUpkeep + d.upkeep end end
        if Postal.postmaster then totalUpkeep = totalUpkeep + 15 end
        if totalUpkeep > 0 and _G.state then _G.state.gold = math.max(0, (_G.state.gold or 0) - totalUpkeep) end
    end
end

function Postal.getMessageInfo(id) return MESSAGES[id] end
function Postal.getMessengerInfo(id) return MESSENGERS[id] end
function Postal.getBuildingInfo(id) return BUILDINGS[id] end
function Postal.getStats()
    return { numMessengers = #Postal.messengers, numBuildings = #Postal.buildings,
        hasPostmaster = Postal.postmaster ~= nil,
        postmasterName = Postal.postmaster and Postal.postmaster.name or "—",
        postmasterSkill = Postal.postmaster and Postal.postmaster.skill or 0,
        activeDeliveries = #Postal.activeDeliveries, pigeonStock = Postal.pigeonStock,
        totalDelivered = Postal.totalDelivered, totalIntercepted = Postal.totalIntercepted }
end

return Postal
