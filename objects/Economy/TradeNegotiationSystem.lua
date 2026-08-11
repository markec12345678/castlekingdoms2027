-- objects/Economy/TradeNegotiationSystem.lua
-- Castle Kingdoms 2027 v3.0.4 - Trade Negotiation System
--
-- Complex trade negotiation with AI factions. Goes beyond simple
-- trade routes with back-and-forth offers, counter-offers, and
-- relationship-based pricing.
--
-- Features:
-- - 4 negotiation types (trade, barter, loan, gift)
-- - AI counter-offer system (AI evaluates and responds)
-- - Relationship-based pricing (allies get discounts)
-- - Negotiation history per faction
-- - Bulk trade discounts
-- - Trade embargoes (block trade with hostile factions)
-- - Trade agreements (recurring automated trades)
-- - Market manipulation (flood/drain markets)

local TradeNeg = {}

-- Negotiation types
local NEGOTIATION_TYPES = {
    trade = { name = "Trgovina",  nameEn = "Trade",  desc = "Kupi/prodaj surovine za zlato" },
    barter = { name = "Barter",   nameEn = "Barter", desc = "Zamenjaj surovine brez zlata" },
    loan = { name = "Posojilo",  nameEn = "Loan",   desc = "Posodi/zapoši zlato z obrestmi" },
    gift = { name = "Darilo",    nameEn = "Gift",   desc = "Daruje surovine za odnose" },
}

TradeNeg.NEGOTIATION_TYPES = NEGOTIATION_TYPES

-- AI personality modifiers for negotiation
local PERSONALITY_MODIFIERS = {
    aggressive = { priceMarkup = 1.3, acceptThreshold = 0.7, counterChance = 0.8 },
    balanced = { priceMarkup = 1.1, acceptThreshold = 0.6, counterChance = 0.5 },
    defensive = { priceMarkup = 1.2, acceptThreshold = 0.8, counterChance = 0.6 },
    economic = { priceMarkup = 1.0, acceptThreshold = 0.5, counterChance = 0.7 },
    siege_master = { priceMarkup = 1.2, acceptThreshold = 0.7, counterChance = 0.5 },
    fortress_keeper = { priceMarkup = 1.15, acceptThreshold = 0.75, counterChance = 0.4 },
    raider = { priceMarkup = 1.4, acceptThreshold = 0.6, counterChance = 0.9 },
    diplomat = { priceMarkup = 0.9, acceptThreshold = 0.5, counterChance = 0.3 },
}

TradeNeg.PERSONALITY_MODIFIERS = PERSONALITY_MODIFIERS

-- Active negotiations
local activeNegotiation = nil
local negotiationHistory = {}
local maxHistory = 50
local tradeAgreements = {}  -- recurring trades
local embargoes = {}  -- blocked factions
local initialized = false

function TradeNeg.init()
    if initialized then return end
    initialized = true
    print("[TradeNeg] Initialized with " .. TradeNeg._getTypeCount() .. " negotiation types")
end

function TradeNeg._getTypeCount()
    local count = 0
    for _ in pairs(NEGOTIATION_TYPES) do count = count + 1 end
    return count
end

-- Start a negotiation
function TradeNeg.start(targetFaction, negType, offer, request)
    if activeNegotiation then
        if _G.ModernUI then _G.ModernUI.notifyError("Pogajanje že v teku") end
        return false
    end

    -- Check embargo
    if embargoes[targetFaction] then
        if _G.ModernUI then _G.ModernUI.notifyError("Trgovinski embargo na to frakcijo") end
        return false
    end

    local negConfig = NEGOTIATION_TYPES[negType or "trade"]
    if not negConfig then return false end

    -- Get AI personality
    local personality = "balanced"
    if _G.AIStrategyController and _G.AIStrategyController.getFactionPersonality then
        personality = _G.AIStrategyController.getFactionPersonality(targetFaction) or "balanced"
    end
    local modifiers = PERSONALITY_MODIFIERS[personality] or PERSONALITY_MODIFIERS.balanced

    -- Get relationship modifier
    local relationScore = 0
    if _G.DiplomaticRelations and _G.DiplomaticRelations.getRelation then
        relationScore = _G.DiplomaticRelations.getRelation(1, targetFaction) or 0
    end
    -- Better relations = better prices (up to -20%)
    local relationDiscount = 1.0 - (relationScore / 100) * 0.2
    relationDiscount = math.max(0.8, math.min(1.2, relationDiscount))

    -- Calculate AI's expected value
    local offerValue = TradeNeg._evaluateOffer(offer)
    local requestValue = TradeNeg._evaluateRequest(request)
    local aiExpectedValue = offerValue * modifiers.priceMarkup * relationDiscount

    activeNegotiation = {
        targetFaction = targetFaction,
        type = negType,
        offer = offer,
        request = request,
        round = 1,
        maxRounds = 3,
        aiPersonality = personality,
        aiModifiers = modifiers,
        relationScore = relationScore,
        relationDiscount = relationDiscount,
        offerValue = offerValue,
        requestValue = requestValue,
        aiExpectedValue = aiExpectedValue,
        state = "pending",  -- pending, accepted, rejected, counter
        startTime = os.time(),
    }

    -- AI evaluates the offer
    TradeNeg._aiEvaluate()

    return true
end

-- Evaluate offer value (what player gives)
function TradeNeg._evaluateOffer(offer)
    local value = 0
    if not offer then return 0 end
    for resource, amount in pairs(offer) do
        local unitValue = TradeNeg._getResourceValue(resource)
        value = value + unitValue * amount
    end
    return value
end

-- Evaluate request value (what player wants)
function TradeNeg._evaluateRequest(request)
    local value = 0
    if not request then return 0 end
    for resource, amount in pairs(request) do
        local unitValue = TradeNeg._getResourceValue(resource)
        value = value + unitValue * amount
    end
    return value
end

-- Get resource base value
function TradeNeg._getResourceValue(resource)
    local values = {
        gold = 1, wood = 4, stone = 14, iron = 45, food = 8,
        wheat = 32, flour = 32, ale = 20, hop = 15, tar = 30,
        pitch = 25, leather = 40, silk = 120, spices = 80,
        wine = 60, wool = 20, coal = 35,
    }
    return values[resource] or 10
end

-- AI evaluates and responds
function TradeNeg._aiEvaluate()
    if not activeNegotiation then return end

    local neg = activeNegotiation
    local ratio = neg.aiExpectedValue / math.max(1, neg.requestValue)

    -- Accept if ratio is favorable enough
    if ratio >= neg.aiModifiers.acceptThreshold then
        neg.state = "accepted"
        TradeNeg._execute()
        return
    end

    -- Counter-offer chance
    if neg.round < neg.maxRounds and math.random() < neg.aiModifiers.counterChance then
        neg.state = "counter"
        -- AI proposes counter-offer (asks for 10-30% more)
        local increaseFactor = 1.1 + math.random() * 0.2
        neg.counterOffer = {}
        for resource, amount in pairs(neg.request) do
            neg.counterOffer[resource] = math.floor(amount * increaseFactor)
        end
        if _G.ModernUI then
            local parts = {}
            for res, amt in pairs(neg.counterOffer) do
                table.insert(parts, amt .. " " .. res)
            end
            _G.ModernUI.notifyInfo("AI protiponudba: " .. table.concat(parts, ", "))
        end
    else
        neg.state = "rejected"
        if _G.ModernUI then
            _G.ModernUI.notifyError("Pogajanje zavrnjeno")
        end
        -- Slight relation penalty for failed negotiation
        if _G.DiplomaticRelations then
            pcall(function() _G.DiplomaticRelations.modifyRelation(1, neg.targetFaction, "trade_completed", -1) end)
        end
        TradeNeg._recordHistory(false)
        activeNegotiation = nil
    end
end

-- Accept counter-offer
function TradeNeg.acceptCounter()
    if not activeNegotiation or activeNegotiation.state ~= "counter" then return false end
    activeNegotiation.request = activeNegotiation.counterOffer
    activeNegotiation.requestValue = TradeNeg._evaluateRequest(activeNegotiation.request)
    activeNegotiation.round = activeNegotiation.round + 1
    activeNegotiation.state = "pending"
    TradeNeg._aiEvaluate()
    return true
end

-- Reject counter-offer
function TradeNeg.rejectCounter()
    if not activeNegotiation then return false end
    activeNegotiation.state = "rejected"
    TradeNeg._recordHistory(false)
    activeNegotiation = nil
    if _G.ModernUI then
        _G.ModernUI.notifyInfo("Protiponudba zavrnjena")
    end
    return true
end

-- Execute the trade
function TradeNeg._execute()
    if not activeNegotiation then return end
    local neg = activeNegotiation

    -- Transfer resources
    if _G.state and _G.state.resources then
        -- Player gives offer
        for resource, amount in pairs(neg.offer) do
            if resource == "gold" then
                _G.state.gold = (_G.state.gold or 0) - amount
            else
                _G.state.resources[resource] = (_G.state.resources[resource] or 0) - amount
            end
        end
        -- Player receives request
        for resource, amount in pairs(neg.request) do
            if resource == "gold" then
                _G.state.gold = (_G.state.gold or 0) + amount
            else
                _G.state.resources[resource] = (_G.state.resources[resource] or 0) + amount
            end
        end
    end

    -- Improve relations
    if _G.DiplomaticRelations then
        pcall(function() _G.DiplomaticRelations.modifyRelation(1, neg.targetFaction, "trade_completed") end)
    end

    -- Record in market (affects supply/demand)
    if _G.DynamicMarket then
        for resource, amount in pairs(neg.offer) do
            pcall(function() _G.DynamicMarket.recordTransaction(resource, amount, "sell") end)
        end
        for resource, amount in pairs(neg.request) do
            pcall(function() _G.DynamicMarket.recordTransaction(resource, amount, "buy") end)
        end
    end

    if _G.ModernUI then
        _G.ModernUI.notifySuccess("Pogajanje uspešno! Trgovina izvedena.")
    end
    if _G.GameEventBus then
        pcall(function() _G.GameEventBus.emit("trade_negotiation_success", neg) end)
    end

    TradeNeg._recordHistory(true)
    activeNegotiation = nil
end

-- Record history
function TradeNeg._recordHistory(success)
    if not activeNegotiation then return end
    table.insert(negotiationHistory, {
        targetFaction = activeNegotiation.targetFaction,
        type = activeNegotiation.type,
        success = success,
        rounds = activeNegotiation.round,
        offerValue = activeNegotiation.offerValue,
        requestValue = activeNegotiation.requestValue,
        timestamp = os.time(),
    })
    while #negotiationHistory > maxHistory do
        table.remove(negotiationHistory, 1)
    end
end

-- Set trade embargo
function TradeNeg.setEmbargo(faction, enabled)
    embargoes[faction] = enabled or nil
    if _G.ModernUI then
        _G.ModernUI.notifyInfo("Embargo na frakcijo " .. faction .. ": " .. (enabled and "ON" or "OFF"))
    end
    return true
end

-- Create trade agreement (recurring)
function TradeNeg.createAgreement(faction, offer, request, interval)
    local agreement = {
        id = #tradeAgreements + 1,
        faction = faction,
        offer = offer,
        request = request,
        interval = interval or 120,  -- every 2 minutes
        timer = 0,
        active = true,
        createdAt = os.time(),
    }
    table.insert(tradeAgreements, agreement)
    if _G.ModernUI then
        _G.ModernUI.notifySuccess("Trgovinski sporazum sklenjen z frakcijo " .. faction)
    end
    return agreement.id
end

-- Cancel trade agreement
function TradeNeg.cancelAgreement(agreementId)
    for i, agg in ipairs(tradeAgreements) do
        if agg.id == agreementId then
            agg.active = false
            table.remove(tradeAgreements, i)
            if _G.ModernUI then
                _G.ModernUI.notifyInfo("Trgovinski sporazum preklican")
            end
            return true
        end
    end
    return false
end

-- Update agreements
function TradeNeg.update(dt)
    if not initialized then return end

    -- Update trade agreements
    for i = #tradeAgreements, 1, -1 do
        local agg = tradeAgreements[i]
        if agg.active then
            agg.timer = agg.timer + dt
            if agg.timer >= agg.interval then
                agg.timer = 0
                -- Execute recurring trade
                if _G.state and _G.state.resources then
                    local canExecute = true
                    for res, amount in pairs(agg.offer) do
                        local available = res == "gold" and (_G.state.gold or 0) or (_G.state.resources[res] or 0)
                        if available < amount then canExecute = false break end
                    end
                    if canExecute then
                        for res, amount in pairs(agg.offer) do
                            if res == "gold" then _G.state.gold = _G.state.gold - amount
                            else _G.state.resources[res] = _G.state.resources[res] - amount end
                        end
                        for res, amount in pairs(agg.request) do
                            if res == "gold" then _G.state.gold = (_G.state.gold or 0) + amount
                            else _G.state.resources[res] = (_G.state.resources[res] or 0) + amount end
                        end
                        if _G.ModernUI then
                            _G.ModernUI.notifyInfo("Trgovinski sporazum izveden (frakcija " .. agg.faction .. ")")
                        end
                    end
                end
            end
        else
            table.remove(tradeAgreements, i)
        end
    end
end

-- Get active negotiation
function TradeNeg.getActive()
    if not activeNegotiation then return nil end
    return {
        targetFaction = activeNegotiation.targetFaction,
        type = activeNegotiation.type,
        typeName = NEGOTIATION_TYPES[activeNegotiation.type].name,
        round = activeNegotiation.round,
        maxRounds = activeNegotiation.maxRounds,
        state = activeNegotiation.state,
        offer = activeNegotiation.offer,
        request = activeNegotiation.request,
        counterOffer = activeNegotiation.counterOffer,
        aiPersonality = activeNegotiation.aiPersonality,
    }
end

-- Get history
function TradeNeg.getHistory(limit)
    local result = {}
    limit = limit or 10
    for i = math.max(1, #negotiationHistory - limit + 1), #negotiationHistory do
        table.insert(result, negotiationHistory[i])
    end
    return result
end

-- Get agreements
function TradeNeg.getAgreements()
    return tradeAgreements
end

-- Get embargoes
function TradeNeg.getEmbargoes()
    return embargoes
end

-- Get stats
function TradeNeg.getStats()
    local successCount = 0
    for _, h in ipairs(negotiationHistory) do
        if h.success then successCount = successCount + 1 end
    end
    return {
        totalNegotiations = #negotiationHistory,
        successful = successCount,
        failed = #negotiationHistory - successCount,
        successRate = #negotiationHistory > 0 and math.floor(successCount / #negotiationHistory * 100) or 0,
        activeAgreements = #tradeAgreements,
        activeEmbargoes = 0,
        hasActiveNegotiation = activeNegotiation ~= nil,
    }
end

return TradeNeg
