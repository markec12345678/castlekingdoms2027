-- objects/Economy/RoyalTreasuryTaxationSystem.lua
-- Castle Kingdoms 2027 v3.2.0 - Royal Treasury & Taxation System
--
-- Comprehensive tax system: manage revenue streams, set tax rates, deal with
-- tax evasion, and fund the kingdom through various levies.
--
-- Features:
-- - 6 tax types (income, property, trade, salt, hearth, church tithe)
-- - 5 tax brackets (exempt, low, medium, high, oppressive)
-- - Tax collector buildings (efficiency boost)
-- - Tax evasion & enforcement
-- - Royal treasury (separate from working gold)
-- - Loans & debt system (borrow from merchants)
-- - Inflation simulation
-- - Tax holidays (temporary relief)
-- - Corruption mechanics

local Treasury = {}

-- ============================================================
-- TAX TYPES
-- ============================================================
local TAX_TYPES = {
    income = {
        name = "Dohodnina",
        nameEn = "Income Tax",
        baseRate = 0.10,        -- 10% default
        maxRate = 0.30,
        minRate = 0.0,
        happinessImpact = -2,  -- per 10% rate
        peasantImpact = 1.0,
        nobleImpact = 0.5,
        description = "Davki na dohodek prebivalstva.",
    },
    property = {
        name = "Posestnina",
        nameEn = "Property Tax",
        baseRate = 0.05,
        maxRate = 0.20,
        minRate = 0.0,
        happinessImpact = -1,
        peasantImpact = 0.5,
        nobleImpact = 1.5,  -- hits nobles more
        description = "Davki na lastnino in zemljo.",
    },
    trade = {
        name = "Trgovski davek",
        nameEn = "Trade Tax",
        baseRate = 0.08,
        maxRate = 0.25,
        minRate = 0.0,
        happinessImpact = -1,
        peasantImpact = 0.0,
        nobleImpact = 0.5,
        merchantImpact = 2.0,
        description = "Carine in trgovski davki.",
    },
    salt = {
        name = "Solni davek",
        nameEn = "Salt Tax",
        baseRate = 0.15,
        maxRate = 0.50,
        minRate = 0.0,
        happinessImpact = -3,
        peasantImpact = 1.5,  -- regressive
        nobleImpact = 0.3,
        description = "Gabela na sol — zelo regresiven.",
    },
    hearth = {
        name = "Ognjiščarina",
        nameEn = "Hearth Tax",
        baseRate = 0.05,
        maxRate = 0.15,
        minRate = 0.0,
        happinessImpact = -2,
        peasantImpact = 1.2,
        nobleImpact = 0.5,
        description = "Davek na vsako ognjišče (hišo).",
    },
    tithe = {
        name = "Cerkvena desetina",
        nameEn = "Church Tithe",
        baseRate = 0.10,
        maxRate = 0.10,
        minRate = 0.0,
        happinessImpact = -1,
        peasantImpact = 1.0,
        nobleImpact = 1.0,
        faithImpact = 2,
        description = "10% cerkvi — teološko obvezna.",
    },
}

-- ============================================================
-- TAX BRACKETS
-- ============================================================
local TAX_BRACKETS = {
    exempt = {
        name = "Oproščeno",
        multiplier = 0.0,
        happinessBonus = 10,
    },
    low = {
        name = "Nizko",
        multiplier = 0.5,
        happinessBonus = 3,
    },
    medium = {
        name = "Srednje",
        multiplier = 1.0,
        happinessBonus = 0,
    },
    high = {
        name = "Visoko",
        multiplier = 1.5,
        happinessBonus = -5,
    },
    oppressive = {
        name = "Tiransko",
        multiplier = 2.0,
        happinessBonus = -15,
        rebellionRisk = 0.02,  -- 2% per day
    },
}

-- ============================================================
-- STATE
-- ============================================================
Treasury.taxRates = {}              -- Per tax type, current rate
Treasury.currentBracket = "medium"
Treasury.treasury = 0               -- Royal treasury (separate from working gold)
Treasury.treasuryMax = 50000
Treasury.taxCollectors = 0          -- Number of collector buildings
Treasury.collectorEfficiency = 1.0
Treasury.activeLoans = {}           -- Outstanding loans
Treasury.totalDebt = 0
Treasury.inflation = 0              -- 0-100, higher = worse
Treasury.corruptionLevel = 5        -- 0-100, % of taxes lost
Treasury.taxHolidays = {}           -- Active holidays
Treasury.totalCollected = 0
Treasury.totalSpentOnInterest = 0
Treasury.dayTimer = 0

-- ============================================================
-- INITIALIZATION
-- ============================================================
function Treasury.init()
    Treasury.taxRates = {}
    for taxId, def in pairs(TAX_TYPES) do
        Treasury.taxRates[taxId] = def.baseRate
    end
    Treasury.currentBracket = "medium"
    Treasury.treasury = 1000
    Treasury.treasuryMax = 50000
    Treasury.taxCollectors = 0
    Treasury.collectorEfficiency = 1.0
    Treasury.activeLoans = {}
    Treasury.totalDebt = 0
    Treasury.inflation = 0
    Treasury.corruptionLevel = 5
    Treasury.taxHolidays = {}
    Treasury.totalCollected = 0
    Treasury.totalSpentOnInterest = 0
    Treasury.dayTimer = 0
    print("[Treasury] Royal Treasury & Taxation System initialized (6 taxes, 5 brackets)")
end

-- ============================================================
-- TAX RATE MANAGEMENT
-- ============================================================
function Treasury.setTaxRate(taxId, rate)
    local def = TAX_TYPES[taxId]
    if not def then return false, "Neznan davek" end
    rate = math.max(def.minRate, math.min(def.maxRate, rate))
    Treasury.taxRates[taxId] = rate
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("%s nastavljen na %.0f%%", def.name, rate * 100), "info")
    end
    return true
end

function Treasury.setTaxBracket(bracketId)
    local bracket = TAX_BRACKETS[bracketId]
    if not bracket then return false, "Neznana stopnja" end
    Treasury.currentBracket = bracketId
    -- Apply happiness effect
    if _G.state and _G.state.happiness then
        _G.state.happiness = math.max(0, math.min(100,
            _G.state.happiness + bracket.happinessBonus))
    end
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            "Davčna stopnja: " .. bracket.name, "info")
    end
    return true
end

function Treasury.getEffectiveTaxRate(taxId)
    local base = Treasury.taxRates[taxId] or 0
    local bracket = TAX_BRACKETS[Treasury.currentBracket]
    if not bracket then return base end
    return base * bracket.multiplier
end

-- ============================================================
-- TAX COLLECTION
-- ============================================================
function Treasury.canBuildCollector()
    if not _G.state then return false end
    return (_G.state.gold or 0) >= 600 and
           (_G.state.resources and _G.state.resources.stone or 0) >= 50
end

function Treasury.buildCollector()
    if not Treasury.canBuildCollector() then return false, "Premalo surovin" end
    _G.state.gold = _G.state.gold - 600
    _G.state.resources.stone = (_G.state.resources.stone or 0) - 50
    Treasury.taxCollectors = Treasury.taxCollectors + 1
    Treasury.collectorEfficiency = 1.0 + (Treasury.taxCollectors * 0.10)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Davčni urad zgrajen!", "success")
    end
    return true
end

function Treasury.collectTaxes()
    if not _G.state then return 0 end
    local total = 0
    local pop = _G.state.population or 100
    -- Each tax type generates income based on population and rate
    for taxId, _ in pairs(TAX_TYPES) do
        local rate = Treasury.getEffectiveTaxRate(taxId)
        if rate > 0 then
            -- Check for tax holiday
            local isHoliday = false
            for _, h in ipairs(Treasury.taxHolidays) do
                if h.taxId == taxId then isHoliday = true; break end
            end
            if not isHoliday then
                local baseIncome = pop * rate * 10  -- 10 gold per pop per 100% rate
                -- Apply collector efficiency
                baseIncome = baseIncome * Treasury.collectorEfficiency
                -- Reduce by corruption
                local lost = baseIncome * (Treasury.corruptionLevel / 100)
                baseIncome = baseIncome - lost
                total = total + baseIncome
            end
        end
    end
    -- Apply inflation reduction
    local inflationMult = 1 - (Treasury.inflation / 200)
    total = total * inflationMult
    -- Add to treasury (not directly to gold)
    Treasury.treasury = math.min(Treasury.treasuryMax, Treasury.treasury + total)
    Treasury.totalCollected = Treasury.totalCollected + total
    return total
end

function Treasury.withdrawFromTreasury(amount)
    if Treasury.treasury < amount then
        return false, "Premalo v zakladnici"
    end
    Treasury.treasury = Treasury.treasury - amount
    if _G.state then
        _G.state.gold = (_G.state.gold or 0) + amount
    end
    return true
end

function Treasury.depositToTreasury(amount)
    if not _G.state or (_G.state.gold or 0) < amount then
        return false, "Premalo zlata"
    end
    if Treasury.treasury + amount > Treasury.treasuryMax then
        return false, "Zakladnica polna"
    end
    _G.state.gold = _G.state.gold - amount
    Treasury.treasury = Treasury.treasury + amount
    return true
end

-- ============================================================
-- LOANS & DEBT
-- ============================================================
function Treasury.takeLoan(amount, interestRate, termDays)
    interestRate = interestRate or 0.10  -- 10% default
    termDays = termDays or 90
    local loan = {
        id = "loan_" .. tostring(os.time()),
        principal = amount,
        interestRate = interestRate,
        remaining = amount * (1 + interestRate),
        daysRemaining = termDays,
        totalDays = termDays,
    }
    table.insert(Treasury.activeLoans, loan)
    Treasury.totalDebt = Treasury.totalDebt + loan.remaining
    -- Add gold to state
    if _G.state then
        _G.state.gold = (_G.state.gold or 0) + amount
    end
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Posojila vzeto: %d zlata (obresti: %.0f%%)", amount, interestRate * 100), "info")
    end
    return true
end

function Treasury.repayLoan(loanId, amount)
    for _, loan in ipairs(Treasury.activeLoans) do
        if loan.id == loanId then
            amount = amount or loan.remaining
            if not _G.state or (_G.state.gold or 0) < amount then
                return false, "Premalo zlata"
            end
            _G.state.gold = _G.state.gold - amount
            loan.remaining = loan.remaining - amount
            Treasury.totalDebt = Treasury.totalDebt - amount
            if loan.remaining <= 0 then
                -- Loan paid off
                for i, l in ipairs(Treasury.activeLoans) do
                    if l.id == loanId then
                        table.remove(Treasury.activeLoans, i)
                        break
                    end
                end
                if _G.NotificationCenter then
                    pcall(_G.NotificationCenter.notify, "Posojilo odplačano!", "success")
                end
            end
            return true
        end
    end
    return false, "Posojilo ne obstaja"
end

function Treasury.updateLoans()
    for i = #Treasury.activeLoans, 1, -1 do
        local loan = Treasury.activeLoans[i]
        loan.daysRemaining = loan.daysRemaining - 1
        if loan.daysRemaining <= 0 then
            -- Loan due — auto-repay from gold (or default)
            if _G.state and (_G.state.gold or 0) >= loan.remaining then
                _G.state.gold = _G.state.gold - loan.remaining
                Treasury.totalDebt = Treasury.totalDebt - loan.remaining
                if _G.NotificationCenter then
                    pcall(_G.NotificationCenter.notify, "Posojilo samodejno odplačano.", "info")
                end
            else
                -- Default — happiness hit, reputation loss
                if _G.state and _G.state.happiness then
                    _G.state.happiness = math.max(0, _G.state.happiness - 15)
                end
                Treasury.corruptionLevel = math.min(100, Treasury.corruptionLevel + 10)
                if _G.NotificationCenter then
                    pcall(_G.NotificationCenter.notify,
                        "NEPLAČEVANJE POSOJILA! Trgovci nezadovoljni.", "danger")
                end
            end
            table.remove(Treasury.activeLoans, i)
        end
    end
end

-- ============================================================
-- TAX HOLIDAYS
-- ============================================================
function Treasury.declareHoliday(taxId, duration)
    duration = duration or 30
    table.insert(Treasury.taxHolidays, {
        taxId = taxId,
        daysRemaining = duration,
    })
    if _G.state and _G.state.happiness then
        _G.state.happiness = math.min(100, _G.state.happiness + 5)
    end
    if _G.NotificationCenter then
        local def = TAX_TYPES[taxId]
        pcall(_G.NotificationCenter.notify,
            "Davčni praznik: " .. (def and def.name or taxId) .. " oproščen " .. duration .. " dni", "success")
    end
    return true
end

function Treasury.updateHolidays()
    for i = #Treasury.taxHolidays, 1, -1 do
        local h = Treasury.taxHolidays[i]
        h.daysRemaining = h.daysRemaining - 1
        if h.daysRemaining <= 0 then
            table.remove(Treasury.taxHolidays, i)
        end
    end
end

-- ============================================================
-- CORRUPTION & INFLATION
-- ============================================================
function Treasury.updateCorruption()
    -- Corruption grows if tax collectors are few and taxes are high
    local totalTaxRate = 0
    for _, rate in pairs(Treasury.taxRates) do
        totalTaxRate = totalTaxRate + rate
    end
    local targetCorruption = (totalTaxRate * 50) - (Treasury.taxCollectors * 5)
    targetCorruption = math.max(0, math.min(100, targetCorruption))
    -- Drift towards target
    Treasury.corruptionLevel = Treasury.corruptionLevel +
        (targetCorruption - Treasury.corruptionLevel) * 0.05
end

function Treasury.updateInflation()
    -- Inflation grows when treasury is full (too much money in circulation)
    local treasuryFill = Treasury.treasury / Treasury.treasuryMax
    if treasuryFill > 0.7 then
        Treasury.inflation = math.min(50, Treasury.inflation + 0.1)
    elseif treasuryFill < 0.3 then
        Treasury.inflation = math.max(0, Treasury.inflation - 0.05)
    end
end

-- ============================================================
-- UPDATE
-- ============================================================
function Treasury.update(dt)
    if not _G.state then return end
    Treasury.dayTimer = Treasury.dayTimer + dt
    if Treasury.dayTimer >= 30 then
        Treasury.dayTimer = 0
        Treasury.collectTaxes()
        Treasury.updateLoans()
        Treasury.updateHolidays()
        Treasury.updateCorruption()
        Treasury.updateInflation()
        -- Check rebellion risk from oppressive taxes
        local bracket = TAX_BRACKETS[Treasury.currentBracket]
        if bracket and bracket.rebellionRisk and math.random() < bracket.rebellionRisk then
            if _G.Rebellion then
                pcall(_G.Rebellion.triggerRebellion, "peasant_revolt")
            end
        end
    end
end

-- ============================================================
-- HELPERS
-- ============================================================
function Treasury.getTaxTypeInfo(taxId) return TAX_TYPES[taxId] end
function Treasury.getBracketInfo(bracketId) return TAX_BRACKETS[bracketId] end

function Treasury.getStats()
    return {
        treasury = Treasury.treasury,
        treasuryMax = Treasury.treasuryMax,
        currentBracket = Treasury.currentBracket,
        taxCollectors = Treasury.taxCollectors,
        collectorEfficiency = Treasury.collectorEfficiency,
        activeLoans = #Treasury.activeLoans,
        totalDebt = Treasury.totalDebt,
        inflation = Treasury.inflation,
        corruptionLevel = Treasury.corruptionLevel,
        activeHolidays = #Treasury.taxHolidays,
        totalCollected = Treasury.totalCollected,
        taxRates = Treasury.taxRates,
    }
end

return Treasury
