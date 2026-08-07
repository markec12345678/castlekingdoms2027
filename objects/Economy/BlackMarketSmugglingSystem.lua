-- objects/Economy/BlackMarketSmugglingSystem.lua
-- Castle Kingdoms 2027 v3.1.4 - Black Market & Smuggling System
--
-- Underground economy: contraband goods, tax evasion, smuggling routes,
-- and enforcement. Adds risk/reward layer to legitimate trading.
--
-- Features:
-- - 8 contraband types (spices, silk, weapons, ale, jewels, relics, poisons, slaves)
-- - 4 smuggling methods (caravan, ship, night runner, bribe officials)
-- - Black market merchants (hidden NPC vendors)
-- - Tax evasion mechanics (hide income, but risk audits)
-- - Enforcement & customs officials (catch smugglers)
-- - Bribery system (pay off officials)
-- - Reputation with criminal underworld
-- - Risk vs reward (huge profits, but heavy fines if caught)

local BlackMarket = {}

-- ============================================================
-- CONTRABAND DEFINITIONS
-- ============================================================
local CONTRABAND = {
    spices = {
        name = "Začimbe",
        nameEn = "Spices",
        baseValue = 80,
        legalPrice = 30,
        blackMarketPrice = 150,
        riskLevel = 1,  -- 1-5
        weight = 1,
        description = "Vredne začimbe z vzhoda, visoko obdavčene.",
    },
    silk = {
        name = "Svila",
        nameEn = "Silk",
        baseValue = 120,
        legalPrice = 50,
        blackMarketPrice = 280,
        riskLevel = 2,
        weight = 1,
        description = "Luksuzna tkanina, prepovedana za uvoz včasih.",
    },
    weapons = {
        name = "Orožje",
        nameEn = "Weapons",
        baseValue = 100,
        legalPrice = 80,
        blackMarketPrice = 220,
        riskLevel = 4,
        weight = 3,
        description = "Vojaško orožje, strogo regulirano.",
    },
    ale = {
        name = "Žganje",
        nameEn = "Spirits",
        baseValue = 30,
        legalPrice = 15,
        blackMarketPrice = 70,
        riskLevel = 1,
        weight = 2,
        description = "Močno žganje brez dovoljenja.",
    },
    jewels = {
        name = "Nakit",
        nameEn = "Jewels",
        baseValue = 500,
        legalPrice = 200,
        blackMarketPrice = 900,
        riskLevel = 3,
        weight = 1,
        description = "Dragoceni nakit, ukraden ali tihotapljen.",
    },
    relics = {
        name = "Relikvije",
        nameEn = "Relics",
        baseValue = 1000,
        legalPrice = 0,  -- can't sell legally
        blackMarketPrice = 2500,
        riskLevel = 5,
        weight = 1,
        description = "Svete relikvije, prodaja prepovedana.",
    },
    poisons = {
        name = "Strupi",
        nameEn = "Poisons",
        baseValue = 300,
        legalPrice = 0,
        blackMarketPrice = 800,
        riskLevel = 5,
        weight = 1,
        description = "Smrtonosni strupi za atentate.",
    },
    slaves = {
        name = "Sužnji",
        nameEn = "Slaves",
        baseValue = 200,
        legalPrice = 0,
        blackMarketPrice = 450,
        riskLevel = 5,
        weight = 4,
        description = "Sužnji — visoko kazen če ujet.",
    },
}

-- ============================================================
-- SMUGGLING METHODS
-- ============================================================
local SMUGGLING_METHODS = {
    caravan = {
        name = "Tihotapska karavana",
        nameEn = "Smuggler Caravan",
        successRate = 0.85,
        speed = 1.0,
        capacity = 50,
        cost = 100,
        detectionChance = 0.15,
    },
    ship = {
        name = "Tihotapska ladja",
        nameEn = "Smuggler Ship",
        successRate = 0.90,
        speed = 1.5,
        capacity = 200,
        cost = 500,
        detectionChance = 0.10,
    },
    night_runner = {
        name = "Nočni tekač",
        nameEn = "Night Runner",
        successRate = 0.70,
        speed = 2.0,
        capacity = 10,
        cost = 50,
        detectionChance = 0.25,
    },
    bribe_officials = {
        name = "Podkupljeni uradniki",
        nameEn = "Bribed Officials",
        successRate = 0.98,
        speed = 1.0,
        capacity = 100,
        cost = 1000,  -- large bribe
        detectionChance = 0.02,
    },
}

-- ============================================================
-- STATE
-- ============================================================
BlackMarket.activeShipments = {}        -- In-transit smuggling
BlackMarket.blackMarketMerchants = {}   -- Available merchants
BlackMarket.criminalReputation = 50     -- 0-100, higher = better deals
BlackMarket.lawEnforcementLevel = 50    -- 0-100, higher = more audits
BlackMarket.taxEvasionAmount = 0        -- Hidden income
BlackMarket.totalContrabandSold = 0
BlackMarket.totalContrabandValue = 0
BlackMarket.timesCaught = 0
BlackMarket.totalFinesPaid = 0
BlackMarket.bribesPaid = 0
BlackMarket.auditTimer = 0
BlackMarket.merchantTimer = 0
BlackMarket.activeAudits = 0
BlackMarket.enforcementBuildings = 0

-- ============================================================
-- INITIALIZATION
-- ============================================================
function BlackMarket.init()
    BlackMarket.activeShipments = {}
    BlackMarket.blackMarketMerchants = {}
    BlackMarket.criminalReputation = 50
    BlackMarket.lawEnforcementLevel = 50
    BlackMarket.taxEvasionAmount = 0
    BlackMarket.totalContrabandSold = 0
    BlackMarket.totalContrabandValue = 0
    BlackMarket.timesCaught = 0
    BlackMarket.totalFinesPaid = 0
    BlackMarket.bribesPaid = 0
    BlackMarket.auditTimer = 0
    BlackMarket.merchantTimer = 0
    BlackMarket.activeAudits = 0
    BlackMarket.enforcementBuildings = 0
    print("[BlackMarket] Black Market & Smuggling System initialized (8 contraband, 4 methods)")
end

-- ============================================================
-- BLACK MARKET MERCHANTS
-- ============================================================
function BlackMarket.spawnMerchant()
    local items = {}
    for id, def in pairs(CONTRABAND) do
        table.insert(items, id)
    end
    -- Spawn 1-3 items
    local merchant = {
        id = "merchant_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        name = BlackMarket.generateMerchantName(),
        location = { x = math.random(100, 1000), y = math.random(100, 1000) },
        inventory = {},
        available = true,
        expiresAt = os.time() + 300,  -- 5 min availability
    }
    local numItems = math.random(1, 3)
    for _ = 1, numItems do
        local itemId = items[math.random(#items)]
        local qty = math.random(1, 10)
        local priceMod = 0.8 + math.random() * 0.5
        merchant.inventory[itemId] = {
            quantity = qty,
            price = math.floor(CONTRABAND[itemId].blackMarketPrice * priceMod),
        }
    end
    table.insert(BlackMarket.blackMarketMerchants, merchant)
    return merchant
end

function BlackMarket.generateMerchantName()
    local firstNames = { "Stari", "Slep", "Kriv", "Temni", "Siv", "Molk" }
    local lastNames = { "Jaka", "Boris", "Mare", "Luka", "Volk", "Gunn" }
    return firstNames[math.random(#firstNames)] .. " " .. lastNames[math.random(#lastNames)]
end

function BlackMarket.getMerchants()
    return BlackMarket.blackMarketMerchants
end

function BlackMarket.buyFromMerchant(merchantId, itemId, quantity)
    for _, m in ipairs(BlackMarket.blackMarketMerchants) do
        if m.id == merchantId and m.available then
            local item = m.inventory[itemId]
            if not item or item.quantity < quantity then
                return false, "Ni dovolj na zalogi"
            end
            local totalCost = item.price * quantity
            if not _G.state or (_G.state.gold or 0) < totalCost then
                return false, "Premalo zlata"
            end
            _G.state.gold = _G.state.gold - totalCost
            item.quantity = item.quantity - quantity
            -- Add to player's contraband inventory
            if not _G.state.contraband then _G.state.contraband = {} end
            _G.state.contraband[itemId] = (_G.state.contraband[itemId] or 0) + quantity
            -- Reputation gain
            BlackMarket.criminalReputation = math.min(100, BlackMarket.criminalReputation + 1)
            -- Risk of instant detection
            local risk = CONTRABAND[itemId].riskLevel * 0.005
            if math.random() < risk then
                BlackMarket.triggerAudit()
            end
            return true
        end
    end
    return false, "Trgovec ni na voljo"
end

function BlackMarket.sellContraband(itemId, quantity)
    if not _G.state or not _G.state.contraband then return false, "Nimaš kontrabande" end
    local available = _G.state.contraband[itemId] or 0
    if available < quantity then return false, "Premalo na zalogi" end
    local def = CONTRABAND[itemId]
    if not def then return false, "Neznan predmet" end
    -- Reputation affects price
    local repMod = 0.7 + (BlackMarket.criminalReputation / 100) * 0.6
    local price = math.floor(def.blackMarketPrice * repMod * quantity)
    _G.state.gold = (_G.state.gold or 0) + price
    _G.state.contraband[itemId] = available - quantity
    BlackMarket.totalContrabandSold = BlackMarket.totalContrabandSold + quantity
    BlackMarket.totalContrabandValue = BlackMarket.totalContrabandValue + price
    -- Risk of detection
    local risk = def.riskLevel * 0.01
    if math.random() < risk then
        BlackMarket.triggerAudit()
    end
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Prodano: %d %s za %d zlata", quantity, def.name, price), "success")
    end
    return true, price
end

-- ============================================================
-- SMUGGLING OPERATIONS
-- ============================================================
function BlackMarket.organizeShipment(methodId, itemId, quantity, destination)
    local method = SMUGGLING_METHODS[methodId]
    if not method then return false, "Neznana metoda" end
    local def = CONTRABAND[itemId]
    if not def then return false, "Neznan predmet" end
    if not _G.state or (_G.state.gold or 0) < method.cost then
        return false, "Premalo zlata za operacijo"
    end
    if quantity > method.capacity then
        return false, "Količina presega kapaciteto"
    end
    -- Pay cost
    _G.state.gold = _G.state.gold - method.cost
    local shipment = {
        id = "shipment_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        method = methodId,
        itemId = itemId,
        quantity = quantity,
        destination = destination or "main",
        successRate = method.successRate,
        detectionChance = method.detectionChance,
        arrivalIn = 60 / method.speed,  -- seconds
        totalValue = def.blackMarketPrice * quantity,
    }
    table.insert(BlackMarket.activeShipments, shipment)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Tihotapska operacija: %s (%d %s)", method.name, quantity, def.name), "info")
    end
    return true, shipment.id
end

function BlackMarket.updateShipments(dt)
    for i = #BlackMarket.activeShipments, 1, -1 do
        local s = BlackMarket.activeShipments[i]
        s.arrivalIn = s.arrivalIn - dt
        if s.arrivalIn <= 0 then
            -- Roll success
            local success = math.random() < s.successRate
            local detected = math.random() < s.detectionChance
            if success and not detected then
                -- Add contraband to inventory
                if not _G.state.contraband then _G.state.contraband = {} end
                _G.state.contraband[s.itemId] = (_G.state.contraband[s.itemId] or 0) + s.quantity
                BlackMarket.criminalReputation = math.min(100, BlackMarket.criminalReputation + 3)
                if _G.NotificationCenter then
                    pcall(_G.NotificationCenter.notify,
                        string.format("Tihotapska dostava uspela: %d %s", s.quantity, CONTRABAND[s.itemId].name),
                        "success")
                end
            elseif detected then
                BlackMarket.caught(s)
            else
                -- Lost at sea / stolen
                if _G.NotificationCenter then
                    pcall(_G.NotificationCenter.notify, "Tihotapska dostava izgubljena!", "warning")
                end
            end
            table.remove(BlackMarket.activeShipments, i)
        end
    end
end

function BlackMarket.caught(shipment)
    BlackMarket.timesCaught = BlackMarket.timesCaught + 1
    local def = CONTRABAND[shipment.itemId]
    local fine = math.floor(def.blackMarketPrice * shipment.quantity * 0.5)
    if _G.state then
        _G.state.gold = math.max(0, (_G.state.gold or 0) - fine)
    end
    BlackMarket.totalFinesPaid = BlackMarket.totalFinesPaid + fine
    BlackMarket.criminalReputation = math.max(0, BlackMarket.criminalReputation - 5)
    BlackMarket.lawEnforcementLevel = math.min(100, BlackMarket.lawEnforcementLevel + 3)
    -- Happiness penalty (public scandal)
    if _G.state and _G.state.happiness then
        _G.state.happiness = math.max(0, _G.state.happiness - 3)
    end
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("UJET! Globa: %d zlata. Izgubljeno: %d %s",
                fine, shipment.quantity, def.name), "danger")
    end
    if _G.GameEventBus then
        pcall(_G.GameEventBus.publish, "SMUGGLER_CAUGHT", {
            itemId = shipment.itemId, quantity = shipment.quantity, fine = fine,
        })
    end
end

-- ============================================================
-- TAX EVASION
-- ============================================================
function BlackMarket.hideIncome(amount)
    if not _G.state or (_G.state.gold or 0) < amount then
        return false, "Premalo zlata za skriti"
    end
    -- Move gold to hidden stash
    _G.state.gold = _G.state.gold - amount
    BlackMarket.taxEvasionAmount = BlackMarket.taxEvasionAmount + amount
    -- Risk of detection
    if math.random() < 0.02 * (BlackMarket.lawEnforcementLevel / 50) then
        BlackMarket.triggerAudit()
    end
    return true
end

function BlackMarket.withdrawHiddenIncome(amount)
    if BlackMarket.taxEvasionAmount < amount then
        return false, "Premalo skritega prihodka"
    end
    BlackMarket.taxEvasionAmount = BlackMarket.taxEvasionAmount - amount
    if _G.state then
        _G.state.gold = (_G.state.gold or 0) + amount
    end
    return true
end

-- ============================================================
-- LAW ENFORCEMENT & AUDITS
-- ============================================================
function BlackMarket.buildCustomsOffice()
    -- Increase enforcement level
    if not _G.state or (_G.state.gold or 0) < 800 then
        return false, "Premalo zlata"
    end
    _G.state.gold = _G.state.gold - 800
    BlackMarket.enforcementBuildings = BlackMarket.enforcementBuildings + 1
    BlackMarket.lawEnforcementLevel = math.min(100, BlackMarket.lawEnforcementLevel + 10)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Carinska postaja zgrajena!+", "info")
    end
    return true
end

function BlackMarket.triggerAudit()
    if BlackMarket.activeAudits >= 3 then return end
    BlackMarket.activeAudits = BlackMarket.activeAudits + 1
    -- Audit takes 60 seconds
    local audit = {
        started = os.time(),
        duration = 60,
    }
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "CARINSKI NADZOR! Preverjajo tvoje finance.", "warning")
    end
    -- Schedule audit result
    local co = coroutine.create(function()
        local waited = 0
        while waited < audit.duration do
            local dt = coroutine.yield()
            waited = waited + dt
        end
        BlackMarket.completeAudit()
    end)
    -- Store coroutine and resume mechanism
    if not BlackMarket.auditCoroutines then BlackMarket.auditCoroutines = {} end
    table.insert(BlackMarket.auditCoroutines, co)
end

function BlackMarket.completeAudit()
    BlackMarket.activeAudits = math.max(0, BlackMarket.activeAudits - 1)
    -- Find hidden income
    local found = BlackMarket.taxEvasionAmount > 0
    local hasContraband = _G.state and _G.state.contraband
    local contrabandCount = 0
    if hasContraband then
        for _, qty in pairs(_G.state.contraband) do
            contrabandCount = contrabandCount + qty
        end
    end
    if found or contrabandCount > 0 then
        -- Heavy fines
        local fine = (BlackMarket.taxEvasionAmount * 2) + (contrabandCount * 100)
        if _G.state then
            _G.state.gold = math.max(0, (_G.state.gold or 0) - fine)
        end
        BlackMarket.totalFinesPaid = BlackMarket.totalFinesPaid + fine
        BlackMarket.taxEvasionAmount = 0
        -- Confiscate contraband
        if _G.state then
            _G.state.contraband = {}
        end
        if _G.NotificationCenter then
            pcall(_G.NotificationCenter.notify,
                string.format("Nadzor uspešen zanj! Globa: %d zlata, kontrabanda zaplenjena!", fine), "danger")
        end
        -- Major happiness hit
        if _G.state and _G.state.happiness then
            _G.state.happiness = math.max(0, _G.state.happiness - 10)
        end
    else
        if _G.NotificationCenter then
            pcall(_G.NotificationCenter.notify, "Nadzor opravljen, ni nepravilnosti.", "success")
        end
    end
end

-- ============================================================
-- BRIBERY
-- ============================================================
function BlackMarket.bribeOfficial(amount)
    if not _G.state or (_G.state.gold or 0) < amount then
        return false, "Premalo zlata"
    end
    _G.state.gold = _G.state.gold - amount
    BlackMarket.bribesPaid = BlackMarket.bribesPaid + amount
    -- Reduce enforcement level
    local reduction = amount / 100
    BlackMarket.lawEnforcementLevel = math.max(0, BlackMarket.lawEnforcementLevel - reduction)
    -- Cancel active audits
    if BlackMarket.activeAudits > 0 then
        BlackMarket.activeAudits = BlackMarket.activeAudits - 1
        if _G.NotificationCenter then
            pcall(_G.NotificationCenter.notify, "Nadzor preklican z podkupnino!", "success")
        end
    end
    return true
end

-- ============================================================
-- UPDATE
-- ============================================================
function BlackMarket.update(dt)
    if not _G.state then return end
    BlackMarket.auditTimer = BlackMarket.auditTimer + dt
    BlackMarket.merchantTimer = BlackMarket.merchantTimer + dt
    -- Update shipments (real-time)
    BlackMarket.updateShipments(dt)
    -- Update audit coroutines
    if BlackMarket.auditCoroutines then
        for i = #BlackMarket.auditCoroutines, 1, -1 do
            local co = BlackMarket.auditCoroutines[i]
            local ok, err = coroutine.resume(co, dt)
            if not ok or coroutine.status(co) == "dead" then
                table.remove(BlackMarket.auditCoroutines, i)
            end
        end
    end
    -- Spawn merchants periodically (every 60 sec)
    if BlackMarket.merchantTimer >= 60 then
        BlackMarket.merchantTimer = 0
        if #BlackMarket.blackMarketMerchants < 3 then
            BlackMarket.spawnMerchant()
        end
    end
    -- Random audit (every 5 min real time)
    if BlackMarket.auditTimer >= 300 then
        BlackMarket.auditTimer = 0
        local auditChance = (BlackMarket.lawEnforcementLevel / 100) * 0.10
        if BlackMarket.taxEvasionAmount > 0 then
            auditChance = auditChance + 0.05
        end
        if math.random() < auditChance then
            BlackMarket.triggerAudit()
        end
    end
    -- Clean up expired merchants
    local now = os.time()
    for i = #BlackMarket.blackMarketMerchants, 1, -1 do
        if BlackMarket.blackMarketMerchants[i].expiresAt < now then
            table.remove(BlackMarket.blackMarketMerchants, i)
        end
    end
    -- Enforcement level slowly drifts back to 50
    if BlackMarket.lawEnforcementLevel > 50 then
        BlackMarket.lawEnforcementLevel = BlackMarket.lawEnforcementLevel - dt * 0.05
    elseif BlackMarket.lawEnforcementLevel < 50 then
        BlackMarket.lawEnforcementLevel = BlackMarket.lawEnforcementLevel + dt * 0.05
    end
end

-- ============================================================
-- HELPERS
-- ============================================================
function BlackMarket.getContrabandInfo(itemId) return CONTRABAND[itemId] end
function BlackMarket.getMethodInfo(methodId) return SMUGGLING_METHODS[methodId] end

function BlackMarket.getStats()
    return {
        activeShipments = #BlackMarket.activeShipments,
        activeMerchants = #BlackMarket.blackMarketMerchants,
        criminalReputation = BlackMarket.criminalReputation,
        lawEnforcementLevel = BlackMarket.lawEnforcementLevel,
        hiddenIncome = BlackMarket.taxEvasionAmount,
        totalContrabandSold = BlackMarket.totalContrabandSold,
        totalContrabandValue = BlackMarket.totalContrabandValue,
        timesCaught = BlackMarket.timesCaught,
        totalFinesPaid = BlackMarket.totalFinesPaid,
        bribesPaid = BlackMarket.bribesPaid,
        activeAudits = BlackMarket.activeAudits,
        enforcementBuildings = BlackMarket.enforcementBuildings,
    }
end

function BlackMarket.getContrabandInventory()
    if not _G.state or not _G.state.contraband then return {} end
    local result = {}
    for itemId, qty in pairs(_G.state.contraband) do
        if qty > 0 then
            table.insert(result, {
                itemId = itemId,
                name = CONTRABAND[itemId] and CONTRABAND[itemId].name or itemId,
                quantity = qty,
                value = CONTRABAND[itemId] and CONTRABAND[itemId].blackMarketPrice or 0,
            })
        end
    end
    return result
end

return BlackMarket
