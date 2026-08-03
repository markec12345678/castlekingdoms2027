-- objects/AI/AIPersonalityDialogue.lua
-- Stronghold 2027 - AI Personality Dialogue
-- AI opponents send taunts, greetings, and threats based on personality

local AIDialogue = {}

local DIALOGUES = {
    aggressive = {
        greeting = {
            "Pripravi se na vojno! Tvoje kraljestvo bo padlo!",
            "Vidim tvoje majhno gospostvo. Kmalu bo moje!",
            "Napadel te bom, ko boš najmanj pričakoval!",
            "Tvoje zidove bom porušil do temeljev!",
        },
        attacking = {
            "Napadam! Tvoje enote so šibke!",
            "Zrušil te bom kot hišo kart!",
            "Moj vojska prihaja! Beži, če lahko!",
            "Tvoja obramba je smešna!",
        },
        losing = {
            "To... to ni mogoče! Kako si zmagal?",
            "Bil sem nevihten! A ne premagan!",
            "Naslednjič ne boš tako srečen!",
            "Kletva! Moje enote so bile šibke!",
        },
        winning = {
            "Tvoje mesto gori! Končno!",
            "Pridi, predaj se in ti prizanesem!",
            "Tvoja obramba je padla! Zmaga je moja!",
            "Ali vidiš? Moč je na moji strani!",
        },
        low_resources = {
            "Potrebujem več zlata za vojsko!",
            "Malo surovin... a vojna ne čaka!",
        },
        alliance_rejected = {
            "Zavezništvo? S tabo? Nikoli!",
            "Ne potrebujem tvoje pomoči!",
            "Bolje sam kot s tabo!",
        },
    },
    balanced = {
        greeting = {
            "Pozdravljen, sosed. Upam, da bomo v miru.",
            "Spoštujem tvojo moč. Pustiva me v miru?",
            "Tvoje kraljestvo je impresivno. Bodi previden.",
            "Dobrodošel. Upam, da ne bosta sovražnika.",
        },
        attacking = {
            "Opravičujem se, a moram te napasti.",
            "Nič osebnega. Samo poslovno.",
            "Strategija zahteva ta napad.",
            "Čas je, da pokažem svojo moč.",
        },
        losing = {
            "Dobro si se boril. Priznavam poraz.",
            "Bil si boljši. Spoštujem to.",
            "Premagan. A naučil se bom.",
            "Zmaga je tvoja. Dobro izigrana.",
        },
        winning = {
            "Nisem hotel tega, a moram zmago vzeti.",
            "Škoda, da ni šlo drugače.",
            "Ponudil ti bom pogoje za predajo.",
            "Tvoja obramba je bila dobra. A ne dovolj.",
        },
        low_resources = {
            "Ekonomija je ključna. Mora graditi.",
            "Potrebujem več surovin za rast.",
        },
        alliance_rejected = {
            "Morda drugič. Zdaj ne morem.",
            "Ne morem zaupati. Še ne.",
        },
        alliance_accepted = {
            "Odlično! Skupaj bomo močnejši.",
            "Zavezništvo sklenjeno. Na tvojo zvestobo računam.",
        },
    },
    defensive = {
        greeting = {
            "Moji zidovi so visoki. Ne poskusi ničesar.",
            "Obramba je moč. Napad ne bo uspel.",
            "Pripravljen sem na vsak napad.",
            "Moja trdnjava je nepremagljiva!",
        },
        attacking = {
            "Nisem napadalec, a ti si me izzval!",
            "Zadnjič opozorjen! Napadam!",
            "Bolje bi bilo, da bi ostal doma.",
            "Napaden sem bil. Zdaj odgovarjam!",
        },
        losing = {
            "Moji zidovi... so padli? Neverjetno.",
            "Obramba je bila prešibka. Presenetljivo.",
            "Nisem pričakoval tako močnega napada.",
            "Premagan v lastni trdnjavi. Škoda.",
        },
        winning = {
            "Kot sem rekel — moji zidovi so nepremagljivi!",
            "Napad je bil napaka. Vidiš zdaj?",
            "Obramba zmaga! Vedno je tako.",
            "Tvoje enote so se zaleteli v zid.",
        },
        low_resources = {
            "Mora okrepiti obrambo. Premalo kamna!",
            "Zidovi potrebujejo popravilo. Kje je kamen?",
        },
        alliance_rejected = {
            "Ne potrebujem zaveznikov. Moji zidovi zadostujejo.",
            "Zavezništvo pomeni šibkost. Ne hvala.",
        },
    },
    economic = {
        greeting = {
            "Trgova sem! Kupi kaj od mene?",
            "Zlato je moč. In jaz ga imam veliko.",
            "Spoštujem dobro ekonomijo. Imaš jo?",
            "Pustiva me v miru in trgujeva!",
        },
        attacking = {
            "Ne maraš trgovine? Potem napadam!",
            "Ekonomija mi omogoča to vojsko. Občuti jo!",
            "Kupi si mir... ali pa ne. Napadam!",
            "Moje bogastvo tije v vojsko!",
        },
        losing = {
            "Moje zlato... moja vojska... vse izgubljeno!",
            "Nisem računal na tako izgubo.",
            "Ekonomija ni vse, kakor kaže.",
            "Premagan. A še imam zlata... nekje.",
        },
        winning = {
            "Vidiš? Zlato zmaga nad vsem!",
            "Moja ekonomija ti je bila premočna!",
            "Kupi si lekcijo. Nauči se!",
            "Bogat sem. Ti pa ne več!",
        },
        low_resources = {
            "Trg je zaprl! Potrebujem nove poti!",
            "Inflacija raste. Zlatu se izmika!",
        },
        alliance_rejected = {
            "Zavezništvo? Brez trgovine? Ne!",
            "Ne morem si privoščiti ne-trgujočega zaveznika.",
        },
        alliance_accepted = {
            "Odlično! Trgovina bo cvetela!",
            "Skupaj bomo bogati! Zavezništvo sklenjeno!",
        },
    },
}

local initialized = false
local lastDialogueTime = {}
local dialogueCooldown = 30  -- 30 seconds between dialogues per AI
local activeDialogues = {}  -- {playerId = {text, timer}}

function AIDialogue.init()
    if initialized then return end
    initialized = true
    print("[AIDialogue] Initialized for 4 AI personalities")
end

-- Get a random dialogue for a personality and situation
function AIDialogue.getDialogue(personality, situation)
    local p = DIALOGUES[personality]
    if not p then return nil end
    local s = p[situation]
    if not s or #s == 0 then return nil end
    return s[math.random(#s)]
end

-- Trigger AI dialogue
function AIDialogue.trigger(aiPlayerId, personality, situation)
    if not initialized then return end

    -- Check cooldown
    local now = love.timer.getTime()
    if lastDialogueTime[aiPlayerId] and (now - lastDialogueTime[aiPlayerId]) < dialogueCooldown then
        return
    end
    lastDialogueTime[aiPlayerId] = now

    local text = AIDialogue.getDialogue(personality, situation)
    if not text then return end

    -- Show dialogue
    activeDialogues[aiPlayerId] = {
        text = text,
        timer = 5.0,  -- Show for 5 seconds
        personality = personality,
    }

    -- Show notification
    if _G.ModernUI then
        local prefix = ""
        if personality == "aggressive" then prefix = "[Agresiven AI] "
        elseif personality == "balanced" then prefix = "[Uravnovešen AI] "
        elseif personality == "defensive" then prefix = "[Obramben AI] "
        elseif personality == "economic" then prefix = "[Ekonomski AI] " end
        _G.ModernUI.notifyInfo(prefix .. text)
    end

    -- Voice-over
    if _G.VoiceOver then
        _G.VoiceOver.notify("ai_dialogue", text)
    end

    -- Emit event
    if _G.GameEventBus then
        _G.GameEventBus.emit("ai_dialogue", {
            playerId = aiPlayerId,
            personality = personality,
            situation = situation,
            text = text,
        })
    end

    print(string.format("[AIDialogue] AI %d (%s): %s", aiPlayerId, personality, text))
end

-- Update active dialogues
function AIDialogue.update(dt)
    if not initialized then return end

    for id, dialogue in pairs(activeDialogues) do
        dialogue.timer = dialogue.timer - dt
        if dialogue.timer <= 0 then
            activeDialogues[id] = nil
        end
    end
end

-- Draw active AI dialogues
function AIDialogue.draw()
    if not initialized then return end

    local y = 80
    for id, dialogue in pairs(activeDialogues) do
        local alpha = math.min(1, dialogue.timer / 1.0)  -- Fade out in last second

        -- Background
        love.graphics.setColor(0, 0, 0, 0.7 * alpha)
        love.graphics.rectangle("fill", 10, y, love.graphics.getWidth() - 20, 30)

        -- Border
        local color = {0.8, 0.3, 0.3}
        if dialogue.personality == "balanced" then color = {0.3, 0.6, 0.8}
        elseif dialogue.personality == "defensive" then color = {0.3, 0.8, 0.3}
        elseif dialogue.personality == "economic" then color = {0.8, 0.7, 0.2} end

        love.graphics.setColor(color[1], color[2], color[3], alpha)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", 10, y, love.graphics.getWidth() - 20, 30)

        -- Text
        love.graphics.setColor(1, 1, 1, alpha)
        love.graphics.printf(dialogue.text, 15, y + 7, love.graphics.getWidth() - 30, "left")

        y = y + 40
    end

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setLineWidth(1)
end

-- Get active dialogue count
function AIDialogue.getActiveCount()
    local count = 0
    for _ in pairs(activeDialogues) do count = count + 1 end
    return count
end

-- Set cooldown
function AIDialogue.setCooldown(seconds)
    dialogueCooldown = math.max(5, seconds)
end

return AIDialogue
