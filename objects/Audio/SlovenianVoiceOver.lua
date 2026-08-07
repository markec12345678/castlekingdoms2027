-- objects/Audio/SlovenianVoiceOver.lua
-- Castle Kingdoms 2027 - Slovenian Voice Over System
--
-- Provides Slovenian voice-over notifications for game events:
-- - Combat alerts (attack incoming, enemy spotted)
-- - Economy notifications (low resources, building complete)
-- - Mission events (objective complete, mission failed)
-- - Diplomacy (alliance formed, war declared)
--
-- Uses text-to-speech fallback if audio files are missing.
-- All notifications also appear as on-screen text (ModernUI).
--
-- Usage:
--   local VoiceOver = require("objects.Audio.SlovenianVoiceOver")
--   VoiceOver.init()
--   VoiceOver.notify("attack_incoming")
--   VoiceOver.notify("building_complete", "Barracks")

local VoiceOver = {}

local initialized = false
local enabled = true

-- Slovenian voice-over messages
-- Each message has: text (Slovenian), priority (1=high, 2=medium, 3=low), cooldown
local MESSAGES = {
    -- Combat
    attack_incoming     = { text = "Napad prihaja!",                priority = 1, cooldown = 10 },
    enemy_spotted       = { text = "Nasprotnik opažen!",            priority = 2, cooldown = 5 },
    under_attack        = { text = "Pod napadom!",                  priority = 1, cooldown = 8 },
    enemy_retreating    = { text = "Nasprotnik se umika.",          priority = 2, cooldown = 10 },
    battle_won          = { text = "Bitka dobljena!",               priority = 1, cooldown = 0 },
    battle_lost         = { text = "Bitka izgubljena.",             priority = 1, cooldown = 0 },
    lord_in_danger      = { text = "Gospodar v nevarnosti!",        priority = 1, cooldown = 5 },
    keep_under_attack   = { text = "Grad napaden!",                 priority = 1, cooldown = 8 },

    -- Economy
    low_gold            = { text = "Nizko zlato.",                  priority = 3, cooldown = 30 },
    low_food            = { text = "Nizke zaloge hrane.",           priority = 3, cooldown = 30 },
    low_wood            = { text = "Nizko les.",                    priority = 3, cooldown = 30 },
    low_stone           = { text = "Nizko kamen.",                  priority = 3, cooldown = 30 },
    building_complete   = { text = "Gradnja končana: %s",           priority = 2, cooldown = 0 },
    unit_trained        = { text = "Enota usposobljena: %s",        priority = 2, cooldown = 0 },
    population_full     = { text = "Populacija polna.",             priority = 3, cooldown = 30 },
    not_enough_workers  = { text = "Ni dovolj delavcev.",           priority = 3, cooldown = 15 },

    -- Mission
    objective_complete  = { text = "Cilj dosežen!",                 priority = 1, cooldown = 0 },
    mission_complete    = { text = "Misija končana!",               priority = 1, cooldown = 0 },
    mission_failed      = { text = "Misija spodletela.",            priority = 1, cooldown = 0 },
    new_objective       = { text = "Nov cilj: %s",                  priority = 2, cooldown = 0 },

    -- Diplomacy
    alliance_formed     = { text = "Zavezništvo sklenjeno z igralcem %d.",  priority = 2, cooldown = 0 },
    war_declared        = { text = "Vojna napovedana igralcu %d.",          priority = 1, cooldown = 0 },
    peace_proposed      = { text = "Predlagan mir.",                priority = 2, cooldown = 0 },
    tribute_received    = { text = "Prejeto darilo od igralca %d.", priority = 2, cooldown = 0 },

    -- Multiplayer
    player_joined       = { text = "Igralec %s se je pridružil.",   priority = 2, cooldown = 0 },
    player_left         = { text = "Igralec %s je odšel.",          priority = 2, cooldown = 0 },
    chat_received       = { text = "Sporočilo od %s.",              priority = 3, cooldown = 5 },

    -- General
    game_saved          = { text = "Igra shranjena.",               priority = 3, cooldown = 0 },
    game_loaded         = { text = "Igra naložena.",                priority = 3, cooldown = 0 },
    achievement_unlocked = { text = "Dosežek odklenjen: %s",        priority = 2, cooldown = 0 },
    hd_pipeline_on      = { text = "HD način vklopljen.",           priority = 3, cooldown = 0 },
    hd_pipeline_off     = { text = "HD način izklopljen.",          priority = 3, cooldown = 0 },
    -- Castle Kingdoms 2027 v2.5.8: New voice-over messages
    unit_veteran        = { text = "Enota napredovala: %s",         priority = 2, cooldown = 5 },
    unit_legendary      = { text = "Legendarna enota! %s",          priority = 1, cooldown = 0 },
    siege_weapon_ready  = { text = "Oblegovalno orožje pripravljeno!", priority = 2, cooldown = 10 },
    festival_started    = { text = "Praznik se je začel: %s",       priority = 2, cooldown = 0 },
    festival_ended      = { text = "Praznik se je končal.",         priority = 3, cooldown = 0 },
    economic_event      = { text = "Ekonomski dogodek: %s",         priority = 2, cooldown = 5 },
    season_changed      = { text = "Letni čas se je spremenil: %s", priority = 3, cooldown = 0 },
    trade_completed     = { text = "Trgovina zaključena.",          priority = 3, cooldown = 5 },
    tribute_sent        = { text = "Darilo poslano.",               priority = 3, cooldown = 5 },
    coop_mission_start  = { text = "Kooperativna kampanja se začenja!", priority = 1, cooldown = 0 },
    skirmish_start      = { text = "Skirmish misija se začenja!",   priority = 1, cooldown = 0 },
}

VoiceOver.MESSAGES = MESSAGES

-- Track last play time for cooldown
local lastPlayTime = {}

-- Initialize
function VoiceOver.init()
    if initialized then return end
    initialized = true
    print("[SlovenianVoiceOver] Initialized with " .. #VoiceOver._getMessageCount() .. " messages")
end

function VoiceOver._getMessageCount()
    local count = 0
    for _ in pairs(MESSAGES) do count = count + 1 end
    return count
end

-- Enable/disable voice over
function VoiceOver.setEnabled(state)
    enabled = state
    print("[SlovenianVoiceOver] " .. (enabled and "Enabled" or "Disabled"))
end

function VoiceOver.isEnabled()
    return enabled
end

-- Play a voice-over notification
-- @param messageId string Message key from MESSAGES
-- @param ... Format arguments (for %s, %d placeholders)
function VoiceOver.notify(messageId, ...)
    if not initialized or not enabled then return end

    local msg = MESSAGES[messageId]
    if not msg then
        print("[SlovenianVoiceOver] Unknown message: " .. tostring(messageId))
        return
    end

    -- Check cooldown
    local now = love.timer.getTime()
    if msg.cooldown > 0 then
        local lastTime = lastPlayTime[messageId] or 0
        if now - lastTime < msg.cooldown then
            return  -- Still on cooldown
        end
    end
    lastPlayTime[messageId] = now

    -- Format message
    local text = msg.text
    local args = { ... }
    if #args > 0 then
        local ok, formatted = pcall(string.format, text, ...)
        if ok then
            text = formatted
        end
    end

    -- Show on-screen notification
    if _G.ModernUI then
        if msg.priority == 1 then
            _G.ModernUI.notifyError(text)
        elseif msg.priority == 2 then
            _G.ModernUI.notifyInfo(text)
        else
            _G.ModernUI.notifySuccess(text)
        end
    end

    -- Try to play speech audio (if available)
    VoiceOver._playSpeech(messageId)

    -- Log to console
    print("[VoiceOver] " .. text)
end

-- Play speech audio file (if it exists)
function VoiceOver._playSpeech(messageId)
    -- Try to find speech audio in Slovenian folder
    local folder = "sounds/speech/slv/"
    local filePath = folder .. messageId .. ".ogg"

    if love.filesystem.getInfo(filePath) then
        local ok, source = pcall(love.audio.newSource, filePath, "static")
        if ok and source then
            source:setVolume(_G.OPTIONS and (_G.OPTIONS.SPEECH_VOLUME or 1) * (_G.OPTIONS.MASTER_VOLUME or 1) or 1)
            source:play()
        end
    end
    -- If no audio file, the text notification serves as fallback
end

-- Convenience methods for common notifications
function VoiceOver.attackIncoming()
    VoiceOver.notify("attack_incoming")
end

function VoiceOver.underAttack()
    VoiceOver.notify("under_attack")
end

function VoiceOver.battleWon()
    VoiceOver.notify("battle_won")
end

function VoiceOver.battleLost()
    VoiceOver.notify("battle_lost")
end

function VoiceOver.buildingComplete(buildingName)
    VoiceOver.notify("building_complete", buildingName or "zgradba")
end

function VoiceOver.unitTrained(unitName)
    VoiceOver.notify("unit_trained", unitName or "enota")
end

function VoiceOver.objectiveComplete()
    VoiceOver.notify("objective_complete")
end

function VoiceOver.missionComplete()
    VoiceOver.notify("mission_complete")
end

function VoiceOver.missionFailed()
    VoiceOver.notify("mission_failed")
end

function VoiceOver.allianceFormed(playerId)
    VoiceOver.notify("alliance_formed", playerId or 0)
end

function VoiceOver.warDeclared(playerId)
    VoiceOver.notify("war_declared", playerId or 0)
end

function VoiceOver.gameSaved()
    VoiceOver.notify("game_saved")
end

function VoiceOver.gameLoaded()
    VoiceOver.notify("game_loaded")
end

function VoiceOver.achievementUnlocked(name)
    VoiceOver.notify("achievement_unlocked", name or "dosežek")
end

-- Get all available messages (for UI)
function VoiceOver.getMessages()
    return MESSAGES
end

-- Get debug info
function VoiceOver.getInfo()
    return {
        enabled = enabled,
        messageCount = #VoiceOver._getMessageCount(),
    }
end

return VoiceOver
