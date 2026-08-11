-- objects/Config/HeraldryCoatOfArmsSystem.lua
-- Castle Kingdoms 2027 v3.2.2 - Heraldry & Coat of Arms System
--
-- Manages heraldic designs, coats of arms, family crests, and heraldic
-- recognition. Used for identification, diplomacy, and prestige.
--
-- Features:
-- - 8 heraldic colors (with traditional meanings)
-- - 12 heraldic charges (symbols: lion, eagle, cross, fleur-de-lis, ...)
-- - 6 shield divisions (per pale, per fess, quarterly, per bend, chevron, pile)
-- - Coat of arms designer (create custom heraldry)
-- - Heraldic recognition (identify houses by their arms)
-- - Heraldic registry (track all known coats of arms)
-- - Heraldic disputes (similar arms cause conflicts)
-- - Heraldic tournaments (display arms at jousts)
-- - Heraldry prestige (rare combinations boost prestige)

local Heraldry = {}

-- ============================================================
-- HERALDIC COLORS (TINCTURES)
-- ============================================================
local TINCTURES = {
    -- Metals
    or_gold = {
        name = "Zlato",
        nameEn = "Or (Gold)",
        color = { 0.85, 0.7, 0.1 },
        type = "metal",
        meaning = "Plemenitost, velikodušnost",
    },
    argent = {
        name = "Srebro",
        nameEn = "Argent (Silver)",
        color = { 0.92, 0.92, 0.95 },
        type = "metal",
        meaning = "Mir, iskrenost",
    },
    -- Colors
    gules = {
        name = "Rdeča",
        nameEn = "Gules (Red)",
        color = { 0.75, 0.10, 0.10 },
        type = "color",
        meaning = "Vojaška hrabrost, pogum",
    },
    azure = {
        name = "Modra",
        nameEn = "Azure (Blue)",
        color = { 0.15, 0.30, 0.75 },
        type = "color",
        meaning = "Zvestoba, resnicoljubnost",
    },
    sable = {
        name = "Črna",
        nameEn = "Sable (Black)",
        color = { 0.10, 0.10, 0.10 },
        type = "color",
        meaning = "Žalost, konstantnost",
    },
    vert = {
        name = "Zelena",
        nameEn = "Vert (Green)",
        color = { 0.15, 0.55, 0.20 },
        type = "color",
        meaning = "Up, zvestoba v ljubezni",
    },
    purpure = {
        name = "Škrlatna",
        nameEn = "Purpure (Purple)",
        color = { 0.55, 0.15, 0.55 },
        type = "color",
        meaning = "Kraljevska dolžnost, viteštvo",
    },
    tenne = {
        name = "Oranžna",
        nameEn = "Tenné (Orange)",
        color = { 0.80, 0.45, 0.10 },
        type = "color",
        meaning = "Ambicija, vztrajnost",
    },
}

-- ============================================================
-- HERALDIC CHARGES (SYMBOLS)
-- ============================================================
local CHARGES = {
    lion_rampant = {
        name = "Lev stoječ",
        nameEn = "Lion Rampant",
        rarity = 2,
        prestigeBonus = 15,
        meaning = "Hrabrost, kraljevska moč",
    },
    eagle_displayed = {
        name = "Orel razprt",
        nameEn = "Eagle Displayed",
        rarity = 3,
        prestigeBonus = 20,
        meaning = "Videnje, moč, cesarstvo",
    },
    cross = {
        name = "Križ",
        nameEn = "Cross",
        rarity = 1,
        prestigeBonus = 8,
        meaning = "Vera, krščanstvo",
    },
    fleur_de_lis = {
        name = "Lilija",
        nameEn = "Fleur-de-lis",
        rarity = 2,
        prestigeBonus = 12,
        meaning = "Čistost, francoska kraljevska hiša",
    },
    dragon = {
        name = "Zmaj",
        nameEn = "Dragon",
        rarity = 5,
        prestigeBonus = 30,
        meaning = "Sila, strašljivost, valyrijci",
    },
    crown = {
        name = "Krona",
        nameEn = "Crown",
        rarity = 4,
        prestigeBonus = 25,
        meaning = "Kraljevska oblast",
    },
    sword = {
        name = "Meč",
        nameEn = "Sword",
        rarity = 2,
        prestigeBonus = 10,
        meaning = "Vojaška moč, pravica",
    },
    tower = {
        name = "Stolp",
        nameEn = "Tower",
        rarity = 2,
        prestigeBonus = 10,
        meaning = "Trdnost, varnost",
    },
    star = {
        name = "Zvezda",
        nameEn = "Star",
        rarity = 3,
        prestigeBonus = 15,
        meaning = "Vodstvo, božansko navdihnjenje",
    },
    boar = {
        name = "Merjavec",
        nameEn = "Boar",
        rarity = 3,
        prestigeBonus = 12,
        meaning = "Hrabrost, divjost",
    },
    wolf = {
        name = "Volk",
        nameEn = "Wolf",
        rarity = 3,
        prestigeBonus = 14,
        meaning = "Vztrajnost, taktika",
    },
    unicorn = {
        name = "Enorog",
        nameEn = "Unicorn",
        rarity = 5,
        prestigeBonus = 35,
        meaning = "Čistost, redkost, mističnost",
    },
}

-- ============================================================
-- SHIELD DIVISIONS
-- ============================================================
local DIVISIONS = {
    solid = {
        name = "Polno",
        nameEn = "Solid",
        complexity = 1,
        description = "Eno barvo čez cel ščit.",
    },
    per_pale = {
        name = "Navpično deljeno",
        nameEn = "Per Pale",
        complexity = 2,
        description = "Ščit razdeljen navpično na dve polji.",
    },
    per_fess = {
        name = "Vodoravno deljeno",
        nameEn = "Per Fess",
        complexity = 2,
        description = "Ščit razdeljen vodoravno na dve polji.",
    },
    quarterly = {
        name = "Četrtinsko",
        nameEn = "Quarterly",
        complexity = 4,
        description = "Ščit razdeljen na 4 četrtine.",
    },
    per_bend = {
        name = "Poševno deljeno",
        nameEn = "Per Bend",
        complexity = 2,
        description = "Ščit razdeljen poševno.",
    },
    chevron = {
        name = "Strešica",
        nameEn = "Chevron",
        complexity = 3,
        description = "V-oblika na ščitu.",
    },
}

-- ============================================================
-- STATE
-- ============================================================
Heraldry.playerArms = nil              -- Player's coat of arms
Heraldry.registry = {}                 -- All registered arms
Heraldry.disputes = {}                 -- Active heraldic disputes
Heraldry.totalDesigned = 0
Heraldry.heraldicPrestige = 0

-- ============================================================
-- INITIALIZATION
-- ============================================================
function Heraldry.init()
    Heraldry.playerArms = nil
    Heraldry.registry = {}
    Heraldry.disputes = {}
    Heraldry.totalDesigned = 0
    Heraldry.heraldicPrestige = 0
    -- Register default arms for major houses
    Heraldry.registerArms("norman", {
        division = "solid",
        primaryTincture = "gules",
        secondaryTincture = "or_gold",
        charge = "lion_rampant",
        owner = "Normanska hiša",
    })
    Heraldry.registerArms("plantagenet", {
        division = "quarterly",
        primaryTincture = "or_gold",
        secondaryTincture = "azure",
        charge = "fleur_de_lis",
        owner = "Plantageneti",
    })
    Heraldry.registerArms("habsburg", {
        division = "solid",
        primaryTincture = "or_gold",
        secondaryTincture = "gules",
        charge = "eagle_displayed",
        owner = "Habsburžani",
    })
    print("[Heraldry] Heraldry & Coat of Arms System initialized (8 tinctures, 12 charges)")
end

-- ============================================================
-- COAT OF ARMS DESIGN
-- ============================================================
function Heraldry.designArms(division, primaryTincture, secondaryTincture, charge)
    -- Validate
    if not DIVISIONS[division] then return false, "Neznana delitev" end
    if not TINCTURES[primaryTincture] then return false, "Neznana primarna barva" end
    if not TINCTURES[secondaryTincture] then return false, "Neznana sekundarna barva" end
    if charge and not CHARGES[charge] then return false, "Neznan simbol" end
    -- Rule of tincture: metal cannot be on metal, color cannot be on color
    local pType = TINCTURES[primaryTincture].type
    local sType = TINCTURES[secondaryTincture].type
    if division ~= "solid" and pType == sType then
        return false, "Heraldično pravilo: kovina na barvi ali barva na kovini!"
    end
    local arms = {
        id = "arms_" .. tostring(os.time()),
        division = division,
        primaryTincture = primaryTincture,
        secondaryTincture = secondaryTincture,
        charge = charge,
        designedDay = os.time(),
    }
    Heraldry.playerArms = arms
    Heraldry.totalDesigned = Heraldry.totalDesigned + 1
    -- Calculate prestige
    local prestige = Heraldry.calculatePrestige(arms)
    Heraldry.heraldicPrestige = prestige
    -- Register
    Heraldry.registerArms("player", arms)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Grb oblikovan! Prestiž: +%d", prestige), "success")
    end
    if _G.GameEventBus then
        pcall(_G.GameEventBus.publish, "ARMS_DESIGNED", { prestige = prestige })
    end
    return true, arms.id
end

function Heraldry.calculatePrestige(arms)
    local prestige = 0
    -- Division complexity
    local div = DIVISIONS[division or arms.division]
    if div then prestige = prestige + div.complexity * 2 end
    -- Charge rarity
    if arms.charge then
        local charge = CHARGES[arms.charge]
        if charge then prestige = prestige + charge.prestigeBonus end
    end
    -- Rare tinctures
    if arms.primaryTincture == "purpure" then prestige = prestige + 5 end
    if arms.primaryTincture == "tenne" then prestige = prestige + 8 end
    return prestige
end

-- ============================================================
-- REGISTRY
-- ============================================================
function Heraldry.registerArms(houseId, arms)
    Heraldry.registry[houseId] = {
        id = houseId,
        division = arms.division,
        primaryTincture = arms.primaryTincture,
        secondaryTincture = arms.secondaryTincture,
        charge = arms.charge,
        owner = arms.owner or houseId,
        registeredDay = os.time(),
    }
end

function Heraldry.getArms(houseId)
    return Heraldry.registry[houseId]
end

function Heraldry.recognizeHouse(arms)
    -- Find a house with matching arms
    for houseId, registered in pairs(Heraldry.registry) do
        if registered.division == arms.division and
           registered.primaryTincture == arms.primaryTincture and
           registered.charge == arms.charge then
            return houseId, registered.owner
        end
    end
    return nil, "Neznan grb"
end

-- ============================================================
-- HERALDIC DISPUTES
-- ============================================================
function Heraldry.checkForDisputes()
    if not Heraldry.playerArms then return end
    for houseId, registered in pairs(Heraldry.registry) do
        if houseId ~= "player" then
            -- Similar arms = dispute
            local similarity = Heraldry.calculateSimilarity(Heraldry.playerArms, registered)
            if similarity > 0.7 then
                Heraldry.createDispute(houseId, similarity)
            end
        end
    end
end

function Heraldry.calculateSimilarity(arms1, arms2)
    local score = 0
    if arms1.division == arms2.division then score = score + 0.3 end
    if arms1.primaryTincture == arms2.primaryTincture then score = score + 0.3 end
    if arms1.charge == arms2.charge then score = score + 0.4 end
    return score
end

function Heraldry.createDispute(targetHouse, similarity)
    -- Check if dispute already exists
    for _, d in ipairs(Heraldry.disputes) do
        if d.targetHouse == targetHouse then return end
    end
    table.insert(Heraldry.disputes, {
        targetHouse = targetHouse,
        similarity = similarity,
        startedDay = os.time(),
        resolved = false,
    })
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Heraldični spor z %s! Podobnost: %d%%",
                targetHouse, math.floor(similarity * 100)), "warning")
    end
    if _G.GameEventBus then
        pcall(_G.GameEventBus.publish, "HERALDIC_DISPUTE", { target = targetHouse })
    end
end

function Heraldry.resolveDispute(houseId, method)
    -- method: "yield" (change our arms) or "contend" (insist on ours)
    for i, d in ipairs(Heraldry.disputes) do
        if d.targetHouse == houseId and not d.resolved then
            d.resolved = true
            if method == "yield" then
                -- Change our arms
                Heraldry.heraldicPrestige = math.max(0, Heraldry.heraldicPrestige - 5)
                if _G.NotificationCenter then
                    pcall(_G.NotificationCenter.notify,
                        "Heraldični spor rešen: spremenil si grb.", "info")
                end
            else
                -- Contend — diplomatic hit
                if _G.DiplomacyController then
                    pcall(_G.DiplomacyController.changeRelation, houseId, -15)
                end
                if _G.NotificationCenter then
                    pcall(_G.NotificationCenter.notify,
                        "Heraldični spor: vztrajaš pri svojem grbu!", "warning")
                end
            end
            table.remove(Heraldry.disputes, i)
            return true
        end
    end
    return false
end

-- ============================================================
-- HERALDIC TOURNAMENTS
-- ============================================================
function Heraldry.displayAtTournament()
    if not Heraldry.playerArms then return false, "Ni grba za prikaz" end
    local prestige = Heraldry.heraldicPrestige
    -- Bonus to tournament performance
    local bonus = prestige / 10
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Grb razvit na turnirju! Bonus: +%.1f", bonus), "info")
    end
    return true, bonus
end

-- ============================================================
-- HELPERS
-- ============================================================
function Heraldry.getTinctureInfo(id) return TINCTURES[id] end
function Heraldry.getChargeInfo(id) return CHARGES[id] end
function Heraldry.getDivisionInfo(id) return DIVISIONS[id] end

function Heraldry.getStats()
    return {
        hasArms = Heraldry.playerArms ~= nil,
        totalDesigned = Heraldry.totalDesigned,
        heraldicPrestige = Heraldry.heraldicPrestige,
        numRegistered = #Heraldry.registry,
        activeDisputes = #Heraldry.disputes,
    }
end

function Heraldry.describeArms(arms)
    arms = arms or Heraldry.playerArms
    if not arms then return "Brez grba" end
    local div = DIVISIONS[arms.division]
    local primary = TINCTURES[arms.primaryTincture]
    local charge = arms.charge and CHARGES[arms.charge]
    local desc = div and div.name or arms.division
    desc = desc .. ", " .. (primary and primary.name or arms.primaryTincture)
    if arms.secondaryTincture then
        local sec = TINCTURES[arms.secondaryTincture]
        desc = desc .. " in " .. (sec and sec.name or arms.secondaryTincture)
    end
    if charge then
        desc = desc .. ", s simbolom: " .. charge.name
    end
    return desc
end

return Heraldry
