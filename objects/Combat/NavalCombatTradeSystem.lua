-- objects/Combat/NavalCombatTradeSystem.lua
-- Castle Kingdoms 2027 v3.1.8 - Naval Combat & Trade System
--
-- Manages ships, naval battles, maritime trade routes, blockades, and piracy.
-- Adds a complete naval layer to the medieval strategy.
--
-- Features:
-- - 5 ship types (fishing boat, cog, galley, carrack, warship)
-- - 4 naval buildings (harbor, shipyard, drydock, naval academy)
-- - Naval combat (boarding, ramming, ranged)
-- - Trade routes (sea-based, high profit, piracy risk)
-- - Blockades (cut off enemy trade)
-- - Piracy (privateers, raiding)
-- - Naval prestige
-- - Weather effects on naval operations

local Naval = {}

-- ============================================================
-- SHIP TYPES
-- ============================================================
local SHIPS = {
    fishing_boat = {
        name = "Ribiška ladja",
        nameEn = "Fishing Boat",
        cost = { gold = 100, wood = 50 },
        upkeep = 2,
        speed = 1.0,
        hp = 50,
        attack = 5,
        defense = 5,
        cargoCapacity = 50,
        crewSize = 4,
        canTrade = true,
        canFight = false,
        description = "Majhna ribiška ladja za lokalno trgovino.",
    },
    cog = {
        name = "Koga",
        nameEn = "Cog",
        cost = { gold = 500, wood = 200, cloth = 50 },
        upkeep = 10,
        speed = 1.2,
        hp = 150,
        attack = 15,
        defense = 20,
        cargoCapacity = 300,
        crewSize = 15,
        canTrade = true,
        canFight = true,
        description = "Trgovaška ladja s palubo in jamborom.",
    },
    galley = {
        name = "Galeja",
        nameEn = "Galley",
        cost = { gold = 800, wood = 300, iron = 50 },
        upkeep = 20,
        speed = 1.8,
        hp = 120,
        attack = 35,
        defense = 15,
        cargoCapacity = 100,
        crewSize = 50,  -- rowers
        canTrade = false,
        canFight = true,
        description = "Vojna ladja z vesli, hitra in okretna.",
    },
    carrack = {
        name = "Karaka",
        nameEn = "Carrack",
        cost = { gold = 2000, wood = 500, cloth = 200, iron = 100 },
        upkeep = 40,
        speed = 1.5,
        hp = 300,
        attack = 50,
        defense = 40,
        cargoCapacity = 800,
        crewSize = 80,
        canTrade = true,
        canFight = true,
        description = "Velika oceanska ladja, trgovina in vojna.",
    },
    warship = {
        name = "Vojna ladja",
        nameEn = "Warship",
        cost = { gold = 3500, wood = 600, iron = 300, cloth = 100 },
        upkeep = 80,
        speed = 1.6,
        hp = 500,
        attack = 80,
        defense = 60,
        cargoCapacity = 200,
        crewSize = 150,
        canTrade = false,
        canFight = true,
        description = "Najmočnejša vojna ladja s topovi.",
    },
}

-- ============================================================
-- NAVAL BUILDINGS
-- ============================================================
local NAVAL_BUILDINGS = {
    harbor = {
        name = "Pristanišče",
        cost = { gold = 500, wood = 200, stone = 100 },
        upkeep = 10,
        shipCapacity = 5,
        tradeBonus = 0.10,
        description = "Osnovno pristanišče za ribiške in majhne ladje.",
    },
    shipyard = {
        name = "Ladjedelnica",
        cost = { gold = 1500, wood = 500, stone = 200 },
        upkeep = 30,
        shipCapacity = 10,
        tradeBonus = 0.20,
        canBuildShips = true,
        description = "Ladjedelnica za gradnjo večjih ladij.",
    },
    drydock = {
        name = "Suhi dok",
        cost = { gold = 3000, wood = 800, stone = 500, iron = 100 },
        upkeep = 60,
        shipCapacity = 20,
        tradeBonus = 0.30,
        canBuildShips = true,
        repairBonus = 0.50,  -- 50% faster repairs
        description = "Napreden dok za gradnjo in popravilo velikih ladij.",
    },
    naval_academy = {
        name = "Pomorska akademija",
        cost = { gold = 5000, wood = 500, stone = 800, iron = 200 },
        upkeep = 100,
        shipCapacity = 30,
        tradeBonus = 0.40,
        canBuildShips = true,
        crewQualityBonus = 0.30,  -- 30% better crew
        description = "Trenira pomorske častnike in izboljša ladje.",
    },
}

-- ============================================================
-- NAVAL COMBAT TACTICS
-- ============================================================
local NAVAL_TACTICS = {
    ram = {
        name = "Zabijanje",
        nameEn = "Ramming",
        damageMultiplier = 1.5,
        selfDamageMultiplier = 0.3,
        successChance = 0.60,
        requiresSpeed = true,
    },
    board = {
        name = "Vkrcanje",
        nameEn = "Boarding",
        damageMultiplier = 1.0,
        selfDamageMultiplier = 0.5,
        successChance = 0.70,
        captureChance = 0.40,  -- chance to capture enemy ship
    },
    ranged = {
        name = "Streljanje",
        nameEn = "Ranged",
        damageMultiplier = 0.8,
        selfDamageMultiplier = 0.1,
        successChance = 0.85,
        safeDistance = true,
    },
    bombard = {
        name = "Bombardiranje",
        nameEn = "Bombardment",
        damageMultiplier = 2.0,
        selfDamageMultiplier = 0.2,
        successChance = 0.50,
        requiresCannons = true,
    },
}

-- ============================================================
-- STATE
-- ============================================================
Naval.fleet = {}                    -- Player's ships
Naval.navalBuildings = {}           -- Built buildings
Naval.activeTradeRoutes = {}        -- Active sea trade routes
Naval.activeBlockades = {}          -- Blockades imposed on enemies
Naval.activeBattles = {}            -- Ongoing naval battles
Naval.pirateThreat = 20             -- 0-100, chance of pirate attacks
Naval.navalPrestige = 0
Naval.totalBattlesWon = 0
Naval.totalBattlesLost = 0
Naval.totalShipsSunk = 0
Naval.totalShipsCaptured = 0
Naval.tradeIncomeTotal = 0
Naval.dayTimer = 0

-- ============================================================
-- INITIALIZATION
-- ============================================================
function Naval.init()
    Naval.fleet = {}
    Naval.navalBuildings = {}
    Naval.activeTradeRoutes = {}
    Naval.activeBlockades = {}
    Naval.activeBattles = {}
    Naval.pirateThreat = 20
    Naval.navalPrestige = 0
    Naval.totalBattlesWon = 0
    Naval.totalBattlesLost = 0
    Naval.totalShipsSunk = 0
    Naval.totalShipsCaptured = 0
    Naval.tradeIncomeTotal = 0
    Naval.dayTimer = 0
    print("[Naval] Naval Combat & Trade System initialized (5 ships, 4 buildings)")
end

-- ============================================================
-- BUILDING CONSTRUCTION
-- ============================================================
function Naval.canBuild(buildingId)
    local def = NAVAL_BUILDINGS[buildingId]
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

function Naval.buildNavalBuilding(buildingId, x, y)
    local ok, err = Naval.canBuild(buildingId)
    if not ok then return false, err end
    local def = NAVAL_BUILDINGS[buildingId]
    _G.state.gold = _G.state.gold - (def.cost.gold or 0)
    if _G.state.resources then
        for res, amt in pairs(def.cost) do
            if res ~= "gold" then
                _G.state.resources[res] = (_G.state.resources[res] or 0) - amt
            end
        end
    end
    table.insert(Naval.navalBuildings, {
        type = buildingId,
        x = x or 0,
        y = y or 0,
        builtDay = os.time(),
    })
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Pomorska zgradba: " .. def.name, "success")
    end
    if _G.GameEventBus then
        pcall(_G.GameEventBus.publish, "NAVAL_BUILDING_BUILT", { type = buildingId })
    end
    return true
end

function Naval.getTotalShipCapacity()
    local cap = 0
    for _, b in ipairs(Naval.navalBuildings) do
        local def = NAVAL_BUILDINGS[b.type]
        if def then cap = cap + (def.shipCapacity or 0) end
    end
    return cap
end

-- ============================================================
-- SHIP CONSTRUCTION
-- ============================================================
function Naval.canBuildShip(shipType)
    local def = SHIPS[shipType]
    if not def then return false, "Neznana ladja" end
    -- Check capacity
    if #Naval.fleet >= Naval.getTotalShipCapacity() then
        return false, "Premalo kapacitete pristanišča"
    end
    -- Check resources
    if not _G.state then return false, "Brez stanja" end
    if _G.state.gold < (def.cost.gold or 0) then return false, "Premalo zlata" end
    if _G.state.resources then
        for res, amt in pairs(def.cost) do
            if res ~= "gold" and (_G.state.resources[res] or 0) < amt then
                return false, "Premalo " .. res
            end
        end
    end
    -- Check if can build (need shipyard+)
    local canBuild = false
    for _, b in ipairs(Naval.navalBuildings) do
        local bdef = NAVAL_BUILDINGS[b.type]
        if bdef and bdef.canBuildShips then canBuild = true; break end
    end
    if not canBuild and shipType ~= "fishing_boat" then
        return false, "Potrebna ladjedelnica"
    end
    return true
end

function Naval.buildShip(shipType, name)
    local ok, err = Naval.canBuildShip(shipType)
    if not ok then return false, err end
    local def = SHIPS[shipType]
    _G.state.gold = _G.state.gold - (def.cost.gold or 0)
    if _G.state.resources then
        for res, amt in pairs(def.cost) do
            if res ~= "gold" then
                _G.state.resources[res] = (_G.state.resources[res] or 0) - amt
            end
        end
    end
    local ship = {
        id = "ship_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        type = shipType,
        name = name or (def.name .. " " .. #Naval.fleet + 1),
        hp = def.hp,
        maxHp = def.hp,
        crew = def.crewSize,
        maxCrew = def.crewSize,
        cargo = 0,
        maxCargo = def.cargoCapacity,
        status = "harbor",  -- harbor, trading, fighting, damaged, sunk
        builtDay = os.time(),
    }
    table.insert(Naval.fleet, ship)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Ladja splovljena: " .. ship.name, "success")
    end
    if _G.GameEventBus then
        pcall(_G.GameEventBus.publish, "SHIP_BUILT", { type = shipType, name = ship.name })
    end
    return true, ship.id
end

-- ============================================================
-- TRADE ROUTES
-- ============================================================
function Naval.establishTradeRoute(destination, shipId)
    local ship = Naval.findShip(shipId)
    if not ship then return false, "Ladja ne obstaja" end
    local def = SHIPS[ship.type]
    if not def or not def.canTrade then
        return false, "Ta ladja ne more trgovati"
    end
    if ship.status ~= "harbor" then
        return false, "Ladja ni v pristanišču"
    end
    -- Calculate profit based on cargo capacity and destination
    local baseProfit = def.cargoCapacity * 2
    local tradeBonus = 1.0
    for _, b in ipairs(Naval.navalBuildings) do
        local bdef = NAVAL_BUILDINGS[b.type]
        if bdef and bdef.tradeBonus then
            tradeBonus = tradeBonus + bdef.tradeBonus
        end
    end
    -- Pirate risk
    local pirateRisk = Naval.pirateThreat / 100
    local route = {
        id = "route_" .. tostring(os.time()),
        destination = destination or "Daleč dežela",
        shipId = shipId,
        shipName = ship.name,
        expectedProfit = math.floor(baseProfit * tradeBonus),
        duration = 120,  -- 2 minutes real time
        pirateRisk = pirateRisk,
        started = os.time(),
    }
    ship.status = "trading"
    table.insert(Naval.activeTradeRoutes, route)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Trgovska pot vzpostavljena: %s (%d zlata, tveganje piratov: %d%%)",
                route.destination, route.expectedProfit, math.floor(pirateRisk * 100)), "info")
    end
    return true
end

function Naval.updateTradeRoutes(dt)
    for i = #Naval.activeTradeRoutes, 1, -1 do
        local r = Naval.activeTradeRoutes[i]
        r.duration = r.duration - dt
        if r.duration <= 0 then
            local ship = Naval.findShip(r.shipId)
            -- Check for pirate attack
            if math.random() < r.pirateRisk then
                -- Pirate attack!
                if ship then
                    local survivalChance = (ship.hp / ship.maxHp) * 0.5 + 0.30
                    if math.random() < survivalChance then
                        -- Survived with damage
                        ship.hp = math.floor(ship.hp * 0.6)
                        ship.status = "damaged"
                        if _G.NotificationCenter then
                            pcall(_G.NotificationCenter.notify,
                                "Piratski napad! " .. ship.name .. " preživela, vendar poškodovana.", "warning")
                        end
                    else
                        -- Ship sunk
                        ship.status = "sunk"
                        Naval.totalShipsSunk = Naval.totalShipsSunk + 1
                        if _G.NotificationCenter then
                            pcall(_G.NotificationCenter.notify,
                                "PIRATI POTOPILI LADJO! " .. ship.name, "danger")
                        end
                    end
                end
            else
                -- Successful trade
                if _G.state then
                    _G.state.gold = (_G.state.gold or 0) + r.expectedProfit
                    Naval.tradeIncomeTotal = Naval.tradeIncomeTotal + r.expectedProfit
                end
                if ship then
                    ship.status = "harbor"
                    ship.hp = math.min(ship.maxHp, ship.hp + 10)  -- minor repair
                end
                if _G.NotificationCenter then
                    pcall(_G.NotificationCenter.notify,
                        string.format("Trgovina uspešna: +%d zlata", r.expectedProfit), "success")
                end
            end
            table.remove(Naval.activeTradeRoutes, i)
        end
    end
end

-- ============================================================
-- NAVAL COMBAT
-- ============================================================
function Naval.initiateBattle(attackerShipId, defenderShipId, tactic)
    local attacker = Naval.findShip(attackerShipId)
    local defender = Naval.findShip(defenderShipId)
    -- Defender might be enemy ship (not in our fleet) — represented by stats
    if not attacker then return false, "Napadalec ne obstaja" end
    local attDef = SHIPS[attacker.type]
    if not attDef or not attDef.canFight then
        return false, "Ta ladja ne more napadati"
    end
    local tac = NAVAL_TACTICS[tactic] or NAVAL_TACTICS.ranged
    -- Calculate outcome
    local attackPower = attDef.attack * (attacker.hp / attacker.maxHp)
    local defensePower = 30  -- default enemy
    if defender then
        local defDef = SHIPS[defender.type]
        if defDef then defensePower = defDef.defense end
    end
    local success = math.random() < tac.successChance
    local battle = {
        id = "battle_" .. tostring(os.time()),
        attacker = attacker.name,
        defender = defender and defender.name or "Nepoznana ladja",
        tactic = tac.name,
        won = false,
        attackerDamage = 0,
        defenderDamage = 0,
        shipCaptured = false,
        duration = 30,  -- 30 sec resolution
    }
    if success then
        -- Won the battle
        battle.won = true
        battle.defenderDamage = math.floor(attackPower * tac.damageMultiplier)
        battle.attackerDamage = math.floor(defensePower * tac.selfDamageMultiplier * 0.5)
        if attacker then
            attacker.hp = math.max(0, attacker.hp - battle.attackerDamage)
        end
        -- Check capture
        if tac.captureChance and math.random() < tac.captureChance then
            battle.shipCaptured = true
            Naval.totalShipsCaptured = Naval.totalShipsCaptured + 1
            -- Add captured ship to fleet (simplified)
            local newShip = {
                id = "captured_" .. tostring(os.time()),
                type = "cog",  -- generic captured
                name = "Zajeta ladja " .. (Naval.totalShipsCaptured),
                hp = 80,
                maxHp = 150,
                crew = 10,
                maxCrew = 15,
                cargo = 0,
                maxCargo = 200,
                status = "harbor",
                builtDay = os.time(),
            }
            table.insert(Naval.fleet, newShip)
        end
        Naval.totalBattlesWon = Naval.totalBattlesWon + 1
        Naval.navalPrestige = math.min(100, Naval.navalPrestige + 5)
        if _G.NotificationCenter then
            local msg = "ZMAGA! " .. battle.attacker .. " premagala " .. battle.defender
            if battle.shipCaptured then msg = msg .. " (ladja zajeta!)" end
            pcall(_G.NotificationCenter.notify, msg, "success")
        end
    else
        -- Lost
        battle.attackerDamage = math.floor(defensePower * 1.2)
        if attacker then
            attacker.hp = math.max(0, attacker.hp - battle.attackerDamage)
            if attacker.hp <= 0 then
                attacker.status = "sunk"
                Naval.totalShipsSunk = Naval.totalShipsSunk + 1
            end
        end
        Naval.totalBattlesLost = Naval.totalBattlesLost + 1
        Naval.navalPrestige = math.max(0, Naval.navalPrestige - 3)
        if _G.NotificationCenter then
            pcall(_G.NotificationCenter.notify,
                "PORAZ! " .. battle.attacker .. " premagana v boju.", "danger")
        end
    end
    table.insert(Naval.activeBattles, battle)
    if _G.GameEventBus then
        pcall(_G.GameEventBus.publish, "NAVAL_BATTLE", {
            won = battle.won, shipCaptured = battle.shipCaptured,
        })
    end
    return true, battle.id
end

-- ============================================================
-- BLOCKADES
-- ============================================================
function Naval.imposeBlockade(targetFaction, shipIds)
    if #shipIds < 2 then return false, "Potrebni vsaj 2 ladji" end
    for _, sid in ipairs(shipIds) do
        local ship = Naval.findShip(sid)
        if not ship or ship.status ~= "harbor" then
            return false, "Ladje morajo biti v pristanišču"
        end
    end
    local blockade = {
        id = "blockade_" .. tostring(os.time()),
        target = targetFaction,
        shipIds = shipIds,
        duration = 300,  -- 5 min
        effectiveness = #shipIds * 0.15,  -- each ship blocks 15%
    }
    for _, sid in ipairs(shipIds) do
        local ship = Naval.findShip(sid)
        if ship then ship.status = "blockading" end
    end
    table.insert(Naval.activeBlockades, blockade)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Blokada vpeljana proti %s (učinkovitost: %d%%)",
                tostring(targetFaction), math.floor(blockade.effectiveness * 100)), "info")
    end
    if _G.GameEventBus then
        pcall(_G.GameEventBus.publish, "BLOCKADE_IMPOSED", {
            target = targetFaction, effectiveness = blockade.effectiveness,
        })
    end
    return true
end

function Naval.updateBlockades(dt)
    for i = #Naval.activeBlockades, 1, -1 do
        local b = Naval.activeBlockades[i]
        b.duration = b.duration - dt
        if b.duration <= 0 then
            -- Release ships
            for _, sid in ipairs(b.shipIds) do
                local ship = Naval.findShip(sid)
                if ship then ship.status = "harbor" end
            end
            table.remove(Naval.activeBlockades, i)
            if _G.NotificationCenter then
                pcall(_G.NotificationCenter.notify, "Blokada končana.", "info")
            end
        end
    end
end

-- ============================================================
-- SHIP REPAIRS
-- ============================================================
function Naval.repairShip(shipId)
    local ship = Naval.findShip(shipId)
    if not ship then return false, "Ladja ne obstaja" end
    if ship.status == "sunk" then return false, "Ladja potopljena" end
    if ship.hp >= ship.maxHp then return false, "Ladja že popolna" end
    -- Repair cost: 1 gold per HP
    local cost = ship.maxHp - ship.hp
    if not _G.state or (_G.state.gold or 0) < cost then
        return false, "Premalo zlata za popravilo"
    end
    _G.state.gold = _G.state.gold - cost
    -- Check for repair bonus
    local repairMult = 1.0
    for _, b in ipairs(Naval.navalBuildings) do
        local def = NAVAL_BUILDINGS[b.type]
        if def and def.repairBonus then
            repairMult = math.max(repairMult, 1 - def.repairBonus)
        end
    end
    ship.hp = ship.maxHp
    ship.status = "harbor"
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Ladja popravljena: " .. ship.name, "success")
    end
    return true
end

-- ============================================================
-- HELPERS
-- ============================================================
function Naval.findShip(shipId)
    for _, s in ipairs(Naval.fleet) do
        if s.id == shipId then return s end
    end
    return nil
end

function Naval.getShipInfo(shipType) return SHIPS[shipType] end
function Naval.getBuildingInfo(buildingId) return NAVAL_BUILDINGS[buildingId] end
function Naval.getTacticInfo(tacticId) return NAVAL_TACTICS[tacticId] end

function Naval.getStats()
    return {
        numShips = #Naval.fleet,
        shipCapacity = Naval.getTotalShipCapacity(),
        numBuildings = #Naval.navalBuildings,
        activeTradeRoutes = #Naval.activeTradeRoutes,
        activeBlockades = #Naval.activeBlockades,
        battlesWon = Naval.totalBattlesWon,
        battlesLost = Naval.totalBattlesLost,
        shipsSunk = Naval.totalShipsSunk,
        shipsCaptured = Naval.totalShipsCaptured,
        navalPrestige = Naval.navalPrestige,
        pirateThreat = Naval.pirateThreat,
        tradeIncomeTotal = Naval.tradeIncomeTotal,
    }
end

-- ============================================================
-- UPDATE
-- ============================================================
function Naval.update(dt)
    if not _G.state then return end
    Naval.dayTimer = Naval.dayTimer + dt
    Naval.updateTradeRoutes(dt)
    Naval.updateBlockades(dt)
    -- Daily tick
    if Naval.dayTimer >= 30 then
        Naval.dayTimer = 0
        -- Upkeep
        local totalUpkeep = 0
        for _, s in ipairs(Naval.fleet) do
            if s.status ~= "sunk" then
                local def = SHIPS[s.type]
                if def then totalUpkeep = totalUpkeep + def.upkeep end
            end
        end
        if totalUpkeep > 0 and _G.state then
            _G.state.gold = math.max(0, (_G.state.gold or 0) - totalUpkeep)
        end
        -- Random pirate threat changes
        Naval.pirateThreat = math.max(0, math.min(100,
            Naval.pirateThreat + math.random(-5, 5)))
        -- Clean up sunk ships after 60 days
        for i = #Naval.fleet, 1, -1 do
            local s = Naval.fleet[i]
            if s.status == "sunk" then
                s.cleanupTimer = (s.cleanupTimer or 60) - 1
                if s.cleanupTimer <= 0 then
                    table.remove(Naval.fleet, i)
                end
            end
        end
    end
end

return Naval
