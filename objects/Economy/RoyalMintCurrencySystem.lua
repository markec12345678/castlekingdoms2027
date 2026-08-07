-- objects/Economy/RoyalMintCurrencySystem.lua
-- Castle Kingdoms 2027 v3.2.3 - Royal Mint & Currency System
--
-- Manages coinage, minting, currency debasement, and exchange rates.
-- Players can mint their own coins, debase currency for quick cash (with
-- long-term inflation), and trade in foreign currencies.
--
-- Features:
-- - 5 coin types (copper penny, silver groat, gold florin, gold noble, ducat)
-- - Royal mint buildings (produce coins)
-- - Currency debasement (reduce purity for immediate gold)
-- - Exchange rates with foreign currencies
-- - Coin purity (affects trust and value)
-- - Forgeries and counterfeiting
-- - Inflation effects
-- - Mintmaster (NPC with skill affecting output)

local Mint = {}

-- ============================================================
-- COIN TYPES
-- ============================================================
local COINS = {
    penny = {
        name = "Bakreni denar",
        nameEn = "Copper Penny",
        material = "copper",
        value = 1,
        purity = 0.95,
        mintCost = 0.8,  -- 0.8 gold worth of copper per coin
        weight = 1.0,
        description = "Osnovna kovanica za vsakdanjo trgovino.",
    },
    groat = {
        name = "Srebrni groat",
        nameEn = "Silver Groat",
        material = "silver",
        value = 4,
        purity = 0.92,
        mintCost = 3.0,
        weight = 2.5,
        description = "Srebrna kovanica za srednje transakcije.",
    },
    florin = {
        name = "Zlati florin",
        nameEn = "Gold Florin",
        material = "gold",
        value = 50,
        purity = 0.98,
        mintCost = 45,
        weight = 3.5,
        description = "Zlata kovanica za velike transakcije.",
    },
    noble = {
        name = "Zlati plemič",
        nameEn = "Gold Noble",
        material = "gold",
        value = 80,
        purity = 0.99,
        mintCost = 75,
        weight = 7.0,
        description = "Velika zlata kovanica za mednarodno trgovino.",
    },
    ducat = {
        name = "Dukat",
        nameEn = "Ducat",
        material = "gold",
        value = 100,
        purity = 0.985,
        mintCost = 95,
        weight = 3.5,
        description = "Mednarodno priznana zlata kovanica.",
    },
}

-- ============================================================
-- FOREIGN CURRENCIES
-- ============================================================
local FOREIGN_CURRENCIES = {
    byzantine_solidus = {
        name = "Bizantinski solidus",
        nameEn = "Byzantine Solidus",
        exchangeRate = 1.2,  -- 1 solidus = 1.2 ducats
        volatility = 0.05,
    },
    venetian_ducat = {
        name = "Beneški dukat",
        nameEn = "Venetian Ducat",
        exchangeRate = 1.0,
        volatility = 0.03,
    },
    arabic_dinar = {
        name = "Arabski dinar",
        nameEn = "Arabic Dinar",
        exchangeRate = 0.95,
        volatility = 0.08,
    },
    hanseatic_mark = {
        name = "Hanzna marka",
        nameEn = "Hanseatic Mark",
        exchangeRate = 0.65,
        volatility = 0.04,
    },
}

-- ============================================================
-- STATE
-- ============================================================
Mint.coinStockpile = {}             -- Coins in treasury
Mint.coinPurity = {}                -- Current purity per coin type
Mint.mintBuildings = 0
Mint.mintmaster = nil               -- { name, skill }
Mint.currentDebasement = 0          -- Cumulative debasement level
Mint.trustLevel = 100               -- 0-100, affects exchange rates
Mint.exchangeRates = {}             -- Current rates
Mint.counterfeitingRisk = 5         -- % chance
Mint.totalMinted = 0
Mint.totalDebased = 0
Mint.dayTimer = 0

-- ============================================================
-- INITIALIZATION
-- ============================================================
function Mint.init()
    Mint.coinStockpile = {}
    Mint.coinPurity = {}
    for coinId, def in pairs(COINS) do
        Mint.coinStockpile[coinId] = 0
        Mint.coinPurity[coinId] = def.purity
    end
    Mint.mintBuildings = 0
    Mint.mintmaster = nil
    Mint.currentDebasement = 0
    Mint.trustLevel = 100
    Mint.exchangeRates = {}
    for curId, def in pairs(FOREIGN_CURRENCIES) do
        Mint.exchangeRates[curId] = def.exchangeRate
    end
    Mint.counterfeitingRisk = 5
    Mint.totalMinted = 0
    Mint.totalDebased = 0
    Mint.dayTimer = 0
    print("[Mint] Royal Mint & Currency System initialized (5 coins, 4 foreign currencies)")
end

-- ============================================================
-- MINT BUILDINGS
-- ============================================================
function Mint.canBuildMint()
    if not _G.state then return false end
    return (_G.state.gold or 0) >= 1500 and
           (_G.state.resources and _G.state.resources.stone or 0) >= 300 and
           (_G.state.resources and _G.state.resources.iron or 0) >= 100
end

function Mint.buildMint()
    if not Mint.canBuildMint() then return false, "Premalo surovin" end
    _G.state.gold = _G.state.gold - 1500
    _G.state.resources.stone = (_G.state.resources.stone or 0) - 300
    _G.state.resources.iron = (_G.state.resources.iron or 0) - 100
    Mint.mintBuildings = Mint.mintBuildings + 1
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Kovnica zgrajena!", "success")
    end
    return true
end

-- ============================================================
-- MINTMASTER
-- ============================================================
function Mint.hireMintmaster(name, skill)
    skill = skill or math.random(40, 90)
    Mint.mintmaster = {
        name = name or "Mojster " .. math.random(1, 100),
        skill = skill,
        hiredDay = os.time(),
    }
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Mintmaster najet: %s (spretnost: %d)",
                Mint.mintmaster.name, skill), "info")
    end
    return true
end

-- ============================================================
-- MINTING
-- ============================================================
function Mint.canMint(coinId, quantity)
    local def = COINS[coinId]
    if not def then return false, "Neznana kovanica" end
    if Mint.mintBuildings == 0 then return false, "Potrebna kovnica" end
    local totalCost = def.mintCost * quantity
    if not _G.state or (_G.state.gold or 0) < totalCost then
        return false, "Premalo zlata za kovino"
    end
    -- Check resources
    if _G.state.resources then
        local materialNeeded = quantity * def.weight
        if (_G.state.resources[def.material] or 0) < materialNeeded then
            return false, "Premalo " .. def.material
        end
    end
    return true
end

function Mint.mint(coinId, quantity)
    local ok, err = Mint.canMint(coinId, quantity)
    if not ok then return false, err end
    local def = COINS[coinId]
    -- Deduct costs
    local totalCost = def.mintCost * quantity
    _G.state.gold = _G.state.gold - totalCost
    if _G.state.resources then
        local materialNeeded = quantity * def.weight
        _G.state.resources[def.material] = (_G.state.resources[def.material] or 0) - materialNeeded
    end
    -- Apply mintmaster skill bonus
    local skillBonus = 1.0
    if Mint.mintmaster then
        skillBonus = 1.0 + (Mint.mintmaster.skill / 200)  -- up to +45%
    end
    local actualCoins = math.floor(quantity * skillBonus)
    Mint.coinStockpile[coinId] = (Mint.coinStockpile[coinId] or 0) + actualCoins
    Mint.totalMinted = Mint.totalMinted + actualCoins
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Kovano: %d %s", actualCoins, def.name), "success")
    end
    if _G.GameEventBus then
        pcall(_G.GameEventBus.publish, "COINS_MINTED", { coinId = coinId, quantity = actualCoins })
    end
    return true
end

-- ============================================================
-- DEBASEMENT
-- ============================================================
function Mint.debaseCurrency(coinId, percentage)
    percentage = math.max(0.01, math.min(0.30, percentage or 0.10))
    local def = COINS[coinId]
    if not def then return false, "Neznana kovanica" end
    -- Reduce purity
    local oldPurity = Mint.coinPurity[coinId] or def.purity
    local newPurity = oldPurity * (1 - percentage)
    Mint.coinPurity[coinId] = newPurity
    -- Immediate gold gain (the difference)
    local stockpile = Mint.coinStockpile[coinId] or 0
    local gain = math.floor(stockpile * def.value * percentage * 0.5)
    if _G.state then
        _G.state.gold = (_G.state.gold or 0) + gain
    end
    Mint.currentDebasement = Mint.currentDebasement + percentage
    Mint.totalDebased = Mint.totalDebased + 1
    -- Trust level drops
    Mint.trustLevel = math.max(0, Mint.trustLevel - percentage * 100)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Kovanica %s devalvirana za %.0f%%! +%d zlata (trenutek), -%d zaupanja",
                def.name, percentage * 100, gain, math.floor(percentage * 100)), "warning")
    end
    if _G.GameEventBus then
        pcall(_G.GameEventBus.publish, "CURRENCY_DEBASED", {
            coinId = coinId, percentage = percentage, gain = gain,
        })
    end
    return true, gain
end

-- ============================================================
-- EXCHANGE RATES
-- ============================================================
function Mint.updateExchangeRates()
    for curId, def in pairs(FOREIGN_CURRENCIES) do
        local rate = def.exchangeRate
        -- Apply trust modifier
        rate = rate * (Mint.trustLevel / 100)
        -- Random volatility
        rate = rate * (1 + (math.random() - 0.5) * def.volatility * 2)
        Mint.exchangeRates[curId] = math.max(0.1, rate)
    end
end

function Mint.exchange(foreignCurrencyId, amount)
    local rate = Mint.exchangeRates[foreignCurrencyId]
    if not rate then return false, "Neznana valuta" end
    local localGold = math.floor(amount * rate)
    if not _G.state or (_G.state.gold or 0) < localGold then
        return false, "Premalo zlata za menjavo"
    end
    -- 5% exchange fee
    local fee = math.floor(localGold * 0.05)
    _G.state.gold = _G.state.gold - localGold - fee
    -- Add foreign currency (conceptually)
    if not _G.state.foreignCurrency then _G.state.foreignCurrency = {} end
    _G.state.foreignCurrency[foreignCurrencyId] =
        (_G.state.foreignCurrency[foreignCurrencyId] or 0) + amount
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Menjava: %d %s za %d zlata (+%d provizija)",
                amount, foreignCurrencyId, localGold, fee), "info")
    end
    return true
end

-- ============================================================
-- COUNTERFEITING
-- ============================================================
function Mint.checkCounterfeiting()
    -- Random chance of counterfeit coins being discovered
    if math.random() < Mint.counterfeitingRisk / 100 then
        -- Counterfeits discovered in our stockpile
        local affectedCoin = nil
        for coinId, _ in pairs(COINS) do
            if (Mint.coinStockpile[coinId] or 0) > 0 then
                if not affectedCoin or math.random() < 0.3 then
                    affectedCoin = coinId
                end
            end
        end
        if affectedCoin then
            local lost = math.floor((Mint.coinStockpile[affectedCoin] or 0) * 0.10)
            Mint.coinStockpile[affectedCoin] = Mint.coinStockpile[affectedCoin] - lost
            Mint.trustLevel = math.max(0, Mint.trustLevel - 5)
            if _G.NotificationCenter then
                pcall(_G.NotificationCenter.notify,
                    string.format("ODKRITA PONAREDBA! %d %s izgubljenih, -5 zaupanja",
                        lost, COINS[affectedCoin].name), "danger")
            end
        end
    end
end

function Mint.increaseSecurity()
    -- Build anti-counterfeiting measures
    if not _G.state or (_G.state.gold or 0) < 500 then
        return false, "Premalo zlata"
    end
    _G.state.gold = _G.state.gold - 500
    Mint.counterfeitingRisk = math.max(0, Mint.counterfeitingRisk - 3)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Varnost kovnice povečana!", "success")
    end
    return true
end

-- ============================================================
-- CONVERT COINS TO GOLD
-- ============================================================
function Mint.convertCoinsToGold(coinId, quantity)
    local def = COINS[coinId]
    if not def then return false, "Neznana kovanica" end
    if (Mint.coinStockpile[coinId] or 0) < quantity then
        return false, "Premalo kovancev"
    end
    -- Apply purity modifier
    local purityMod = (Mint.coinPurity[coinId] or def.purity) / def.purity
    local goldGained = math.floor(quantity * def.value * purityMod)
    Mint.coinStockpile[coinId] = Mint.coinStockpile[coinId] - quantity
    if _G.state then
        _G.state.gold = (_G.state.gold or 0) + goldGained
    end
    return true, goldGained
end

-- ============================================================
-- UPDATE
-- ============================================================
function Mint.update(dt)
    if not _G.state then return end
    Mint.dayTimer = Mint.dayTimer + dt
    if Mint.dayTimer >= 30 then
        Mint.dayTimer = 0
        Mint.updateExchangeRates()
        Mint.checkCounterfeiting()
        -- Trust level slowly recovers
        if Mint.trustLevel < 100 then
            Mint.trustLevel = math.min(100, Mint.trustLevel + 0.5)
        end
        -- Counterfeiting risk grows over time
        Mint.counterfeitingRisk = math.min(50, Mint.counterfeitingRisk + 0.2)
    end
end

-- ============================================================
-- HELPERS
-- ============================================================
function Mint.getCoinInfo(coinId) return COINS[coinId] end
function Mint.getForeignCurrencyInfo(curId) return FOREIGN_CURRENCIES[curId] end
function Mint.getStockpile() return Mint.coinStockpile end
function Mint.getPurity(coinId) return Mint.coinPurity[coinId] or COINS[coinId].purity end

function Mint.getStats()
    return {
        mintBuildings = Mint.mintBuildings,
        mintmaster = Mint.mintmaster and Mint.mintmaster.name or "—",
        mintmasterSkill = Mint.mintmaster and Mint.mintmaster.skill or 0,
        currentDebasement = Mint.currentDebasement,
        trustLevel = Mint.trustLevel,
        counterfeitingRisk = Mint.counterfeitingRisk,
        totalMinted = Mint.totalMinted,
        totalDebased = Mint.totalDebased,
        coinStockpile = Mint.coinStockpile,
        exchangeRates = Mint.exchangeRates,
    }
end

return Mint
