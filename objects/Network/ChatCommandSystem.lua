-- objects/Network/ChatCommandSystem.lua
-- Castle Kingdoms 2027 v2.9.3 - Chat Command System
--
-- Allows players to execute commands via chat input (like console but via chat).
-- Works in both single-player (debug) and multiplayer (admin commands).
--
-- Command categories:
-- - Economy: add gold, resources, set tax
-- - Military: spawn units, heroes, siege weapons
-- - Time: set speed, pause, skip time
-- - World: change weather, season, time of day
-- - Debug: show stats, FPS, memory, toggle overlays
-- - Fun: fireworks, confetti, dance party
--
-- Usage: type /command [args] in chat (Enter to open chat)

local ChatCmd = {}

local commands = {}
local commandHistory = {}
local maxHistory = 50
local initialized = false

function ChatCmd.init()
    if initialized then return end
    initialized = true
    ChatCmd._registerCommands()
    print("[ChatCmd] Initialized with " .. #commands .. " commands")
end

-- Register a command
function ChatCmd.register(name, description, category, handler, adminOnly)
    table.insert(commands, {
        name = name,
        description = description,
        category = category or "misc",
        handler = handler,
        adminOnly = adminOnly or false,
    })
end

function ChatCmd._registerCommands()
    -- === ECONOMY ===
    ChatCmd.register("gold", "Dodaj zlato: /gold <amount>", "economy", function(args)
        local amount = tonumber(args[1]) or 1000
        if _G.state then
            _G.state.gold = (_G.state.gold or 0) + amount
            return "Dodano " .. amount .. " zlata (skupaj: " .. (_G.state.gold or 0) .. ")"
        end
        return "State ni na voljo"
    end)

    ChatCmd.register("resource", "Dodaj surovino: /resource <type> <amount>", "economy", function(args)
        local resType = args[1] or "wood"
        local amount = tonumber(args[2]) or 100
        if _G.state and _G.state.resources then
            _G.state.resources[resType] = (_G.state.resources[resType] or 0) + amount
            return "Dodano " .. amount .. " " .. resType
        end
        return "State ni na voljo"
    end)

    ChatCmd.register("tax", "Nastavi davek: /tax <level 0-10>", "economy", function(args)
        local level = tonumber(args[1]) or 4
        if _G.TaxController and _G.TaxController.setTaxLevel then
            _G.TaxController.setTaxLevel(level)
            return "Davek nastavljen na nivo " .. level
        end
        return "TaxController ni na voljo"
    end)

    -- === MILITARY ===
    ChatCmd.register("spawn", "Ustvari enoto: /spawn <type> [count]", "military", function(args)
        local unitType = args[1] or "Knight"
        local count = tonumber(args[2]) or 1
        local CombatIntegration = _G.CombatIntegration
        if CombatIntegration and CombatIntegration.spawnUnit and _G.state and _G.state.keepX then
            for i = 1, count do
                local gx = _G.state.keepX + math.random(-5, 5)
                local gy = _G.state.keepY + math.random(-5, 5)
                pcall(function() CombatIntegration.spawnUnit(unitType, gx, gy, 1) end)
            end
            return "Ustvarjeno " .. count .. " " .. unitType
        end
        return "Cannot spawn — CombatIntegration ali keepX ni na voljo"
    end)

    ChatCmd.register("hero", "Rekrutiraj heroja: /hero <type>", "military", function(args)
        local heroType = args[1] or "knight_commander"
        local HeroSystem = _G.HeroSystem
        if HeroSystem and HeroSystem.recruit then
            local heroId, err = HeroSystem.recruit(heroType)
            if heroId then
                return "Hero rekrutiran: " .. heroType .. " (ID: " .. heroId .. ")"
            end
            return "Napaka: " .. tostring(err)
        end
        return "HeroSystem ni na voljo"
    end)

    ChatCmd.register("siege", "Ustvari oblegovalno orožje: /siege <type>", "military", function(args)
        local siegeType = args[1] or "catapult"
        local SiegeWeapons = _G.SiegeWeapons
        if SiegeWeapons and SiegeWeapons.create and _G.state and _G.state.keepX then
            pcall(function() SiegeWeapons.create(siegeType, _G.state.keepX + 5, _G.state.keepY + 5, 1) end)
            return "Ustvarjeno: " .. siegeType
        end
        return "SiegeWeapons ni na voljo"
    end)

    -- === TIME ===
    ChatCmd.register("speed", "Nastavi hitrost: /speed <0-10>", "time", function(args)
        local speed = tonumber(args[1]) or 1
        if _G.TimeManager then
            _G.TimeManager.setSpeed(speed)
            return "Hitrost: " .. speed .. "x"
        end
        if _G.state then _G.speedModifier = speed end
        return "Hitrost: " .. speed .. "x"
    end)

    ChatCmd.register("pause", "Pavza", "time", function()
        if _G.TimeManager then
            _G.TimeManager.togglePause()
            return "Pavza preklopljena"
        end
        return "TimeManager ni na voljo"
    end)

    -- === WORLD ===
    ChatCmd.register("weather", "Spremeni vreme: /weather <type>", "world", function(args)
        local weather = args[1] or "clear"
        if _G.WeatherSystem and _G.WeatherSystem.setWeather then
            _G.WeatherSystem.setWeather(weather)
            return "Vreme: " .. weather
        end
        return "WeatherSystem ni na voljo"
    end)

    ChatCmd.register("season", "Spremeni sezono: /season <spring|summer|autumn|winter>", "world", function(args)
        local season = args[1] or "summer"
        if _G.SeasonalSystem and _G.SeasonalSystem.setSeason then
            _G.SeasonalSystem.setSeason(season)
            return "Sezona: " .. season
        end
        return "SeasonalSystem ni na voljo"
    end)

    ChatCmd.register("timeofday", "Nastavi čas dneva: /timeofday <dawn|day|dusk|night>", "world", function(args)
        local tod = args[1] or "day"
        if _G.LightingSystem and _G.LightingSystem.setTimePeriod then
            _G.LightingSystem.setTimePeriod(tod)
            return "Čas dneva: " .. tod
        end
        return "LightingSystem ni na voljo"
    end)

    ChatCmd.register("festival", "Zaženi festival: /festival <type>", "world", function(args)
        local ftype = args[1] or "tournament"
        if _G.FestivalSystem and _G.FestivalSystem.start then
            local ok = _G.FestivalSystem.start(ftype)
            if ok then return "Festival: " .. ftype end
            return "Napaka pri festivalu"
        end
        return "FestivalSystem ni na voljo"
    end)

    -- === DEBUG ===
    ChatCmd.register("stats", "Prikaži statistiko", "debug", function()
        local Analytics = _G.Analytics
        if Analytics then
            local s = Analytics.getSessionStats()
            return string.format("Čas: %s | APM: %d | Zmage: %d | Ubij: %d | Zgradi: %d",
                Analytics._formatTime and Analytics._formatTime(s.playtime) or "?",
                s.apm or 0, s.battlesWon or 0, s.enemiesKilled or 0, s.buildingsBuilt or 0)
        end
        return "Analytics ni na voljo"
    end)

    ChatCmd.register("fps", "Prikaži FPS", "debug", function()
        local fps = love.timer.getFPS()
        local mem = collectgarbage("count")
        return string.format("FPS: %d | Memory: %.1f MB", fps, mem / 1024)
    end)

    ChatCmd.register("summary", "Prikaži povzetek igre", "debug", function()
        local SummaryGen = _G.SummaryGen
        if SummaryGen then
            local summary = SummaryGen.generate()
            return string.format("Ocena: %s | Rezultat: %d/1000 | %s",
                summary.grade, summary.totalScore, summary.gradeDesc)
        end
        return "SummaryGen ni na voljo"
    end)

    ChatCmd.register("prestige", "Prikaži prestige", "debug", function()
        local Prestige = _G.Prestige
        if Prestige then
            local s = Prestige.getStats()
            return string.format("Prestige: %d | Rank: %s | Skupno: %d",
                s.currentPrestige, s.rank, s.totalEarned)
        end
        return "Prestige ni na voljo"
    end)

    ChatCmd.register("repair", "Popravi vse zgradbe", "debug", function()
        local BuildingManager = _G.BuildingManager
        if BuildingManager and BuildingManager.repairAll then
            local ok = BuildingManager.repairAll()
            if ok then return "Vse zgradbe popravljene" end
            return "Ni poškodovanih zgradb ali premalo zlata"
        end
        return "BuildingManager ni na voljo"
    end)

    ChatCmd.register("tech", "Raziski tehnologijo: /tech <id>", "debug", function(args)
        local techId = args[1]
        local TechnologyTree = _G.TechnologyTree
        if TechnologyTree and TechnologyTree.startResearch then
            if techId then
                local ok = TechnologyTree.startResearch(techId)
                if ok then return "Raziskovanje: " .. techId end
                return "Napaka pri raziskovanju"
            end
            -- List available techs
            local stats = TechnologyTree.getStats()
            return string.format("Tehnologije: %d/%d raziskanih", stats.researched, stats.totalTechs)
        end
        return "TechnologyTree ni na voljo"
    end)

    ChatCmd.register("quest", "Sprejmi quest: /quest <accept|list>", "debug", function(args)
        local action = args[1] or "list"
        local QuestSystem = _G.QuestSystem
        if not QuestSystem then return "QuestSystem ni na voljo" end
        if action == "list" then
            local available = QuestSystem.getAvailable()
            local active = QuestSystem.getActive()
            return string.format("Questi: %d razpoložljivih, %d aktivnih", #available, #active)
        elseif action == "accept" then
            local available = QuestSystem.getAvailable()
            if #available > 0 then
                QuestSystem.accept(available[1].id)
                return "Quest sprejet: " .. available[1].name
            end
            return "Ni razpoložljivih questov"
        end
        return "Uporaba: /quest <accept|list>"
    end)

    ChatCmd.register("help", "Prikaži vse ukaze", "misc", function()
        local lines = {"Razpoložljivi ukazi:"}
        local byCategory = {}
        for _, cmd in ipairs(commands) do
            if not byCategory[cmd.category] then byCategory[cmd.category] = {} end
            table.insert(byCategory[cmd.category], cmd.name)
        end
        for cat, cmdList in pairs(byCategory) do
            table.insert(lines, "  [" .. cat .. "] /" .. table.concat(cmdList, " /"))
        end
        return table.concat(lines, "\n")
    end)

    -- === FUN ===
    ChatCmd.register("fireworks", "Najdi ognjemet!", "fun", function()
        if _G.VisualPolish and _G.state and _G.state.keepX then
            for i = 1, 20 do
                local gx = _G.state.keepX + math.random(-20, 20)
                local gy = _G.state.keepY + math.random(-20, 20)
                local sx = _G.IsoToScreenX(gx, gy) - (_G.state.viewXview or 0)
                local sy = _G.IsoToScreenY(gx, gy) - (_G.state.viewYview or 0)
                pcall(function() _G.VisualPolish.spawnEffect(sx, sy, "magic", 30) end)
                pcall(function() _G.VisualPolish.spawnEffect(sx, sy, "spark", 20) end)
            end
            if _G.GameFeel then pcall(function() _G.GameFeel.shake(5, 0.5) end) end
            return "Ognjemet!"
        end
        return "VisualPolish ni na voljo"
    end)

    ChatCmd.register("cinematic", "Zaženi cinematic kamero", "fun", function()
        if _G.CameraEnhanced and _G.CameraEnhanced.startCinematic then
            _G.CameraEnhanced.startCinematic(10)
            return "Cinematic način začet (10s)"
        end
        return "CameraEnhanced ni na voljo"
    end)

    ChatCmd.register("storm", "Prikliči nevihto z strelo", "fun", function()
        if _G.WeatherWarfare and _G.state and _G.state.keepX then
            _G.WeatherWarfare.use("summon_storm")
            -- Also fire lightning at random enemy
            _G.WeatherWarfare.use("lightning_strike", _G.state.keepX + 20, _G.state.keepY + 20)
            return "Nevihta priklicana!"
        end
        return "WeatherWarfare ni na voljo"
    end)
end

-- Process a chat message for commands
function ChatCmd.processMessage(message)
    if not initialized then return nil end
    if not message or message:sub(1, 1) ~= "/" then return nil end

    -- Parse command and args
    local parts = {}
    for part in message:gmatch("%S+") do
        table.insert(parts, part)
    end

    local cmdName = parts[1]:sub(2)  -- remove leading /
    local args = {}
    for i = 2, #parts do
        table.insert(args, parts[i])
    end

    -- Find command
    for _, cmd in ipairs(commands) do
        if cmd.name == cmdName then
            local ok, result = pcall(cmd.handler, args)
            if ok then
                -- Record in history
                table.insert(commandHistory, {
                    command = cmdName,
                    args = args,
                    result = result,
                    timestamp = os.time(),
                })
                while #commandHistory > maxHistory do
                    table.remove(commandHistory, 1)
                end
                return result or "Ukaz izveden"
            else
                return "Napaka: " .. tostring(result)
            end
        end
    end

    return "Neznan ukaz: /" .. cmdName .. " (poskusi /help)"
end

-- Get all commands
function ChatCmd.getCommands()
    return commands
end

-- Get commands by category
function ChatCmd.getCommandsByCategory(category)
    local result = {}
    for _, cmd in ipairs(commands) do
        if cmd.category == category then
            table.insert(result, cmd)
        end
    end
    return result
end

-- Get command history
function ChatCmd.getHistory(limit)
    local result = {}
    limit = limit or 10
    for i = math.max(1, #commandHistory - limit + 1), #commandHistory do
        table.insert(result, commandHistory[i])
    end
    return result
end

-- Get stats
function ChatCmd.getStats()
    local byCategory = {}
    for _, cmd in ipairs(commands) do
        byCategory[cmd.category] = (byCategory[cmd.category] or 0) + 1
    end
    return {
        totalCommands = #commands,
        historyCount = #commandHistory,
        byCategory = byCategory,
    }
end

return ChatCmd
