-- objects/QA/GameSummaryGenerator.lua
-- Castle Kingdoms 2027 v2.9.1 - Game Summary Generator
--
-- Generates comprehensive end-of-game summaries by aggregating data
-- from all game systems. Provides detailed statistics, comparisons,
-- and grade calculations for player performance.
--
-- Summary sections:
-- - Military: combat stats, hero performance, unit breakdown
-- - Economy: resource flow, trade, production efficiency
-- - Diplomacy: relations, alliances, tributes
-- - Construction: building stats, upgrade paths
-- - Technology: research progress, tech tree completion
-- - Special: espionage, quests, tournaments, prestige
-- - Grade: overall performance letter grade (S, A, B, C, D)

local SummaryGen = {}

local initialized = false

-- Grade thresholds (based on total score 0-1000)
local GRADE_THRESHOLDS = {
    { grade = "S", minScore = 900, desc = "Legendarna izvedba", color = {1.0, 0.8, 0.0} },
    { grade = "A", minScore = 750, desc = "Odlična izvedba", color = {0.3, 0.9, 0.3} },
    { grade = "B", minScore = 550, desc = "Dobra izvedba", color = {0.3, 0.6, 0.9} },
    { grade = "C", minScore = 350, desc = "Povprečna izvedba", color = {0.9, 0.8, 0.2} },
    { grade = "D", minScore = 150, desc = "Slaba izvedba", color = {0.9, 0.5, 0.2} },
    { grade = "F", minScore = 0,   desc = "Neuspešna izvedba", color = {0.9, 0.3, 0.3} },
}

SummaryGen.GRADE_THRESHOLDS = GRADE_THRESHOLDS

function SummaryGen.init()
    if initialized then return end
    initialized = true
    print("[SummaryGen] Initialized")
end

-- Generate a full game summary
function SummaryGen.generate()
    local summary = {
        timestamp = os.time(),
        dateStr = os.date("%Y-%m-%d %H:%M:%S"),
        sections = {},
        totalScore = 0,
        grade = "F",
        gradeDesc = "Neuspešna izvedba",
        gradeColor = {0.9, 0.3, 0.3},
    }

    -- Military section
    summary.sections.military = SummaryGen._gatherMilitary()
    -- Economy section
    summary.sections.economy = SummaryGen._gatherEconomy()
    -- Diplomacy section
    summary.sections.diplomacy = SummaryGen._gatherDiplomacy()
    -- Construction section
    summary.sections.construction = SummaryGen._gatherConstruction()
    -- Technology section
    summary.sections.technology = SummaryGen._gatherTechnology()
    -- Special section
    summary.sections.special = SummaryGen._gatherSpecial()

    -- Calculate total score
    summary.totalScore = SummaryGen._calculateScore(summary.sections)
    summary.maxScore = 1000

    -- Determine grade
    for _, threshold in ipairs(GRADE_THRESHOLDS) do
        if summary.totalScore >= threshold.minScore then
            summary.grade = threshold.grade
            summary.gradeDesc = threshold.desc
            summary.gradeColor = threshold.color
            break
        end
    end

    return summary
end

-- Gather military statistics
function SummaryGen._gatherMilitary()
    local stats = { units = {}, heroes = {}, combat = {} }

    -- From Analytics
    local Analytics = _G.Analytics
    if Analytics then
        local s = Analytics.getSessionStats()
        stats.combat = {
            unitsTrained = s.unitsTrained or 0,
            unitsLost = s.unitsLost or 0,
            enemiesKilled = s.enemiesKilled or 0,
            kdRatio = s.kdRatio or 0,
            battlesWon = s.battlesWon or 0,
            battlesLost = s.battlesLost or 0,
        }
    end

    -- From HeroSystem
    local HeroSystem = _G.HeroSystem
    if HeroSystem then
        local hStats = HeroSystem.getStats()
        stats.heroes = {
            totalHeroes = hStats.totalHeroes,
            aliveHeroes = hStats.aliveHeroes,
            deadHeroes = hStats.deadHeroes,
            avgLevel = hStats.avgLevel,
        }
    end

    -- From ArmyCommand
    local ArmyCommand = _G.ArmyCommand
    if ArmyCommand then
        local aStats = ArmyCommand.getStats()
        stats.units.armyCount = aStats.armyCount
        stats.units.totalUnits = aStats.totalUnits
        stats.units.totalStrength = aStats.totalStrength
    end

    return stats
end

-- Gather economy statistics
function SummaryGen._gatherEconomy()
    local stats = { resources = {}, trade = {}, production = {} }

    local Analytics = _G.Analytics
    if Analytics then
        local s = Analytics.getSessionStats()
        stats.trade = {
            goldEarned = s.goldEarned or 0,
            goldSpent = s.goldSpent or 0,
            goldNet = s.goldNet or 0,
            netWorth = s.netWorth or 0,
            tradesCompleted = s.tradesCompleted or 0,
            tradeProfit = s.tradeProfit or 0,
        }
        stats.resources.gathered = s.resourcesGathered or {}
        stats.resources.spent = s.resourcesSpent or {}
    end

    -- From ProductionChain
    local ProductionChain = _G.ProductionChain
    if ProductionChain then
        local pStats = ProductionChain.getStats()
        stats.production.activeChains = pStats.activeChains
        stats.production.totalChains = pStats.totalChains
    end

    -- From TradeRoute
    local TradeRoute = _G.TradeRoute
    if TradeRoute then
        local tStats = TradeRoute.getStats()
        stats.trade.activeRoutes = tStats.activeRoutes
        stats.trade.totalIncome = tStats.totalIncomeGenerated
        stats.trade.totalRaids = tStats.totalRaids
    end

    return stats
end

-- Gather diplomacy statistics
function SummaryGen._gatherDiplomacy()
    local stats = { relations = {}, actions = {} }

    local Analytics = _G.Analytics
    if Analytics then
        local s = Analytics.getSessionStats()
        stats.actions = {
            alliancesFormed = s.alliancesFormed or 0,
            warsDeclared = s.warsDeclared or 0,
            tributesSent = s.tributesSent or 0,
            tributesReceived = s.tributesReceived or 0,
        }
    end

    local DiplomaticRelations = _G.DiplomaticRelations
    if DiplomaticRelations then
        local dStats = DiplomaticRelations.getStats()
        stats.relations = dStats
    end

    return stats
end

-- Gather construction statistics
function SummaryGen._gatherConstruction()
    local stats = {}

    local Analytics = _G.Analytics
    if Analytics then
        local s = Analytics.getSessionStats()
        stats = {
            buildingsBuilt = s.buildingsBuilt or 0,
            buildingsDestroyed = s.buildingsDestroyed or 0,
            buildingsRepaired = s.buildingsRepaired or 0,
        }
    end

    local BuildingManager = _G.BuildingManager
    if BuildingManager then
        local bStats = BuildingManager.getStats()
        stats.totalBuildings = bStats.total
        stats.byCategory = bStats.byCategory
        stats.damaged = bStats.damaged
        stats.healthy = bStats.healthy
    end

    return stats
end

-- Gather technology statistics
function SummaryGen._gatherTechnology()
    local stats = {}

    local Analytics = _G.Analytics
    if Analytics then
        local s = Analytics.getSessionStats()
        stats.technologiesResearched = s.technologiesResearched or 0
    end

    local TechnologyTree = _G.TechnologyTree
    if TechnologyTree then
        local tStats = TechnologyTree.getStats()
        stats.totalTechs = tStats.totalTechs
        stats.researchedTechs = tStats.researched
    end

    return stats
end

-- Gather special statistics
function SummaryGen._gatherSpecial()
    local stats = { espionage = {}, quests = {}, tournaments = {}, prestige = {} }

    local Analytics = _G.Analytics
    if Analytics then
        local s = Analytics.getSessionStats()
        stats.espionage = {
            spyMissions = s.spyMissions or 0,
            spySuccessRate = s.spySuccessRate or 0,
        }
        stats.quests = {
            accepted = s.questsAccepted or 0,
            completed = s.questsCompleted or 0,
        }
    end

    local Tournament = _G.Tournament
    if Tournament then
        local tStats = Tournament.getStats()
        stats.tournaments = tStats
    end

    local Prestige = _G.Prestige
    if Prestige then
        local pStats = Prestige.getStats()
        stats.prestige = {
            currentPrestige = pStats.currentPrestige,
            totalEarned = pStats.totalEarned,
            rank = pStats.rank,
        }
    end

    return stats
end

-- Calculate total score (0-1000)
function SummaryGen._calculateScore(sections)
    local score = 0

    -- Military (max 250)
    local mil = sections.military.combat or {}
    score = score + math.min(100, (mil.enemiesKilled or 0) * 2)
    score = score + math.min(50, (mil.battlesWon or 0) * 15)
    local kd = mil.kdRatio or 0
    score = score + math.min(50, kd * 10)
    if mil.unitsLost then
        score = score + math.max(0, 50 - mil.unitsLost)
    end

    -- Economy (max 250)
    local eco = sections.economy.trade or {}
    score = score + math.min(100, (eco.goldEarned or 0) / 100)
    score = score + math.min(50, (eco.tradesCompleted or 0) * 5)
    score = score + math.min(50, (eco.netWorth or 0) / 100)
    score = score + math.min(50, (eco.tradeProfit or 0) / 50)

    -- Diplomacy (max 150)
    local dip = sections.diplomacy.actions or {}
    score = score + math.min(50, (dip.alliancesFormed or 0) * 15)
    score = score + math.min(50, (dip.tributesSent or 0) * 10)
    score = score + math.min(50, (dip.tributesReceived or 0) * 10)

    -- Construction (max 150)
    local con = sections.construction or {}
    score = score + math.min(100, (con.buildingsBuilt or 0) * 2)
    score = score + math.min(50, (con.buildingsRepaired or 0) * 5)

    -- Technology (max 100)
    local tech = sections.technology or {}
    score = score + math.min(100, (tech.technologiesResearched or 0) * 8)

    -- Special (max 100)
    local spec = sections.special or {}
    score = score + math.min(30, (spec.espionage.spyMissions or 0) * 3)
    score = score + math.min(30, (spec.quests.completed or 0) * 10)
    local tourStats = spec.tournaments or {}
    score = score + math.min(20, (tourStats.wins or 0) * 10)
    local pres = spec.prestige or {}
    score = score + math.min(20, (pres.currentPrestige or 0) / 50)

    return math.floor(math.min(1000, score))
end

-- Get formatted text summary
function SummaryGen.getFormattedSummary(summary)
    if not summary then summary = SummaryGen.generate() end
    local lines = {}

    table.insert(lines, "═══════════════════════════════════════")
    table.insert(lines, "       POVZETEK IGRE")
    table.insert(lines, "═══════════════════════════════════════")
    table.insert(lines, "Datum: " .. summary.dateStr)
    table.insert(lines, "")
    table.insert(lines, string.format("Ocena: %s — %s", summary.grade, summary.gradeDesc))
    table.insert(lines, string.format("Skupni rezultat: %d / %d", summary.totalScore, summary.maxScore))
    table.insert(lines, "")

    -- Military
    local mil = summary.sections.military
    table.insert(lines, "─── VOJAŠKO ───")
    local mc = mil.combat or {}
    table.insert(lines, string.format("Usposobljene enote: %d | Izgubljene: %d", mc.unitsTrained or 0, mc.unitsLost or 0))
    table.insert(lines, string.format("Ubiti sovražniki: %d | K/D: %.2f", mc.enemiesKilled or 0, mc.kdRatio or 0))
    table.insert(lines, string.format("Zmage: %d | Porazi: %d", mc.battlesWon or 0, mc.battlesLost or 0))
    local h = mil.heroes or {}
    if h.totalHeroes then
        table.insert(lines, string.format("Heroji: %d (živi: %d, mrtvi: %d, povp. nivo: %.1f)",
            h.totalHeroes, h.aliveHeroes or 0, h.deadHeroes or 0, h.avgLevel or 0))
    end
    table.insert(lines, "")

    -- Economy
    local eco = summary.sections.economy
    table.insert(lines, "─── EKONOMIJA ───")
    local et = eco.trade or {}
    table.insert(lines, string.format("Zaslužek: %dg | Poraba: %dg | Neto: %dg",
        et.goldEarned or 0, et.goldSpent or 0, et.goldNet or 0))
    table.insert(lines, string.format("Neto vrednost: %dg", et.netWorth or 0))
    table.insert(lines, string.format("Trgovine: %d | Profit: %dg", et.tradesCompleted or 0, et.tradeProfit or 0))
    if et.activeRoutes then
        table.insert(lines, string.format("Trgovske poti: %d | Dohodek: %dg | Napadi: %d",
            et.activeRoutes, et.totalIncome or 0, et.totalRaids or 0))
    end
    table.insert(lines, "")

    -- Diplomacy
    local dip = summary.sections.diplomacy.actions or {}
    table.insert(lines, "─── DIPLOMACIJA ───")
    table.insert(lines, string.format("Zavezništva: %d | Vojne: %d", dip.alliancesFormed or 0, dip.warsDeclared or 0))
    table.insert(lines, string.format("Tributi poslani: %d | Prejeti: %d", dip.tributesSent or 0, dip.tributesReceived or 0))
    table.insert(lines, "")

    -- Construction
    local con = summary.sections.construction or {}
    table.insert(lines, "─── GRADNJA ───")
    table.insert(lines, string.format("Zgrajene: %d | Uničene: %d | Popravljene: %d",
        con.buildingsBuilt or 0, con.buildingsDestroyed or 0, con.buildingsRepaired or 0))
    table.insert(lines, "")

    -- Technology
    local tech = summary.sections.technology or {}
    table.insert(lines, "─── TEHNOLOGIJA ───")
    table.insert(lines, string.format("Raziskane: %d / %d", tech.technologiesResearched or 0, tech.totalTechs or 14))
    table.insert(lines, "")

    -- Special
    local spec = summary.sections.special or {}
    table.insert(lines, "─── POSEBNO ───")
    table.insert(lines, string.format("Vohunske misije: %d | Uspešnost: %.0f%%",
        spec.espionage.spyMissions or 0, spec.espionage.spySuccessRate or 0))
    table.insert(lines, string.format("Questi: %d/%d končani",
        spec.quests.completed or 0, spec.quests.accepted or 0))
    local tour = spec.tournaments or {}
    table.insert(lines, string.format("Turnirji: %d sodelovanj | %d zmag | Win rate: %.0f%%",
        tour.totalParticipations or 0, tour.wins or 0, tour.winRate or 0))
    local pres = spec.prestige or {}
    table.insert(lines, string.format("Prestige: %d točk | Rank: %s",
        pres.currentPrestige or 0, pres.rank or "Novice"))
    table.insert(lines, "")
    table.insert(lines, "═══════════════════════════════════════")

    return table.concat(lines, "\n")
end

-- Save summary to file
function SummaryGen.saveToFile(summary)
    if not summary then summary = SummaryGen.generate() end
    local text = SummaryGen.getFormattedSummary(summary)
    local filename = "game_summary_" .. os.date("%Y%m%d_%H%M%S") .. ".txt"
    local file = love.filesystem.newFile(filename)
    if file:open("w") then
        file:write(text)
        file:close()
        if _G.ModernUI then
            _G.ModernUI.notifySuccess("Povzetek shranjen: " .. filename)
        end
        return filename
    end
    return nil
end

return SummaryGen
