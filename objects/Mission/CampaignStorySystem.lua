-- objects/Mission/CampaignStorySystem.lua
-- Stronghold 2027 - Campaign Story System
-- Cutscenes, dialogue, story progression between missions

local CampaignStory = {}

local STORY_BEATS = {
    mission1 = {
        intro = {
            { speaker = "Pripovedovalec", portrait = "narrator", text = "Leto 1147. Kraljestvo Valdemar je v kaosu. Stari kralj je mrtev, njegovi sinovi pa se borijo za prestol." },
            { speaker = "Pripovedovalec", portrait = "narrator", text = "Vi ste Sir Aldric, zvest vitez pokojnega kralja. Vrnili ste se v Fernhaven, svoj rodni kraj, da bi obnovili svoje gospostvo." },
            { speaker = "Sir Aldric", portrait = "hero", text = "Fernhaven... Koliko spominov. Tukaj se je vse začelo. In tukaj se bo znova začelo." },
        },
        outro = {
            { speaker = "Sir Aldric", portrait = "hero", text = "Grad stoji. Ljudstvo se vrača. A to je šele začetek." },
            { speaker = "Pripovedovalec", portrait = "narrator", text = "Novice o Aldricovi vrnitvi so se hitro razširile. Kmalu bo moral dokazati svojo vrednost." },
        },
    },
    mission2 = {
        intro = {
            { speaker = "Pripovedovalec", portrait = "narrator", text = "Banditi iz gozdov so začeli napadati bližnje vasi. Prebivalci prosijo za zaščito." },
            { speaker = "Kmet", portrait = "peasant", text = "Gospod! Banditi so nam vzeli vse! Prosimo, pomagajte nam!" },
            { speaker = "Sir Aldric", portrait = "hero", text = "Ne bojite se. Zgradili bomo barake in usposobili vojake. Nikoli več vam ne bodo vzeli ničesar." },
        },
    },
    mission3 = {
        intro = {
            { speaker = "Pripovedovalec", portrait = "narrator", text = "Po zmagi nad banditi je Aldric pridobil sloves sposobnega vodje. Zahodna baronija Westmarsh išče zavezništvo." },
            { speaker = "Baron Westmarsha", portrait = "noble", text = "Sir Aldric, naša dežela grozi invazija z vzhoda. Če se združimo, bomo močnejši." },
            { speaker = "Sir Aldric", portrait = "hero", text = "Zavezništvo pomeni skupno obrambo. A zaupanje je treba zaslužiti. Dokazite svojo zvestobo." },
        },
    },
    mission10 = {
        intro = {
            { speaker = "Pripovedovalec", portrait = "narrator", text = "Končni spopad je pred vrati. Valdemarjev prestol je v rokah uzurpatorja, znanega le kot Temni Kralj." },
            { speaker = "Lady Elara", portrait = "heroine", text = "Aldric, to je naš zadnji boj. Če izgubimo, je vse izgubljeno." },
            { speaker = "Sir Aldric", portrait = "hero", text = "Potem ne smemo izgubiti. Za Fernhaven. Za Valdemar. Za vse tiste, ki so verjeli v nas." },
        },
        outro = {
            { speaker = "Pripovedovalec", portrait = "narrator", text = "S Temnim Kraljem poraženim je Valdemar končno svoboden. Sir Aldric, nekoč pregnani vitez, sedaj stoji na prestolu." },
            { speaker = "Sir Aldric", portrait = "hero", text = "Nisem iskal krune. A če je moram nositi, jo bom nosil s častjo." },
            { speaker = "Lady Elara", portrait = "heroine", text = "In mi bomo ob tebi. Vedno." },
            { speaker = "Pripovedovalec", portrait = "narrator", text = "Tako se začne nova doba. Doba miru. Doba upanja. Doba Stronghold 2027." },
        },
    },
}

local currentDialogue = nil
local currentLine = 0
local isActive = false
local onComplete = nil

function CampaignStory.init()
    print("[CampaignStory] Initialized with " .. #CampaignStory._getBeatCount() .. " story beats")
end

function CampaignStory._getBeatCount()
    local count = 0
    for _ in pairs(STORY_BEATS) do count = count + 1 end
    return count
end

function CampaignStory.playIntro(missionId, callback)
    local beat = STORY_BEATS[missionId]
    if not beat or not beat.intro then
        if callback then callback() end
        return
    end
    CampaignStory._play(beat.intro, callback)
end

function CampaignStory.playOutro(missionId, callback)
    local beat = STORY_BEATS[missionId]
    if not beat or not beat.outro then
        if callback then callback() end
        return
    end
    CampaignStory._play(beat.outro, callback)
end

function CampaignStory._play(dialogue, callback)
    currentDialogue = dialogue
    currentLine = 0
    isActive = true
    onComplete = callback
    CampaignStory.nextLine()
end

function CampaignStory.nextLine()
    if not isActive then return end
    currentLine = currentLine + 1
    if currentLine > #currentDialogue then
        CampaignStory._complete()
        return
    end
end

function CampaignStory._complete()
    isActive = false
    currentDialogue = nil
    currentLine = 0
    if onComplete then
        local cb = onComplete
        onComplete = nil
        cb()
    end
end

function CampaignStory.skip()
    if not isActive then return end
    CampaignStory._complete()
end

function CampaignStory.isActive()
    return isActive
end

function CampaignStory.getCurrentLine()
    if not isActive or not currentDialogue then return nil end
    return currentDialogue[currentLine]
end

function CampaignStory.update(dt)
    -- Could add typing animation here
end

function CampaignStory.draw()
    if not isActive then return end

    local line = CampaignStory.getCurrentLine()
    if not line then return end

    local w, h = love.graphics.getDimensions()
    local boxW, boxH = w - 100, 150
    local boxX, boxY = 50, h - boxH - 50

    -- Dark overlay
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 0, 0, w, h)

    -- Dialogue box
    love.graphics.setColor(0.05, 0.05, 0.08, 0.95)
    love.graphics.rectangle("fill", boxX, boxY, boxW, boxH)
    love.graphics.setColor(0.6, 0.5, 0.2, 1)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", boxX, boxY, boxW, boxH)

    -- Portrait area
    local portraitSize = 110
    love.graphics.setColor(0.15, 0.15, 0.2, 1)
    love.graphics.rectangle("fill", boxX + 10, boxY + 10, portraitSize, portraitSize)
    love.graphics.setColor(0.5, 0.4, 0.15, 1)
    love.graphics.rectangle("line", boxX + 10, boxY + 10, portraitSize, portraitSize)

    -- Portrait placeholder (colored block based on speaker)
    local portraitColors = {
        narrator = {0.3, 0.3, 0.4},
        hero = {0.4, 0.5, 0.3},
        heroine = {0.5, 0.3, 0.4},
        peasant = {0.4, 0.35, 0.2},
        noble = {0.3, 0.3, 0.5},
    }
    local pc = portraitColors[line.portrait] or {0.3, 0.3, 0.3}
    love.graphics.setColor(pc[1], pc[2], pc[3], 1)
    love.graphics.rectangle("fill", boxX + 12, boxY + 12, portraitSize - 4, portraitSize - 4)

    -- Speaker name
    love.graphics.setColor(1, 0.9, 0.5, 1)
    local font = loveframes and loveframes.font_vera_bold_medium or love.graphics.getFont()
    love.graphics.setFont(font)
    love.graphics.print(line.speaker, boxX + 140, boxY + 15)

    -- Dialogue text
    love.graphics.setColor(1, 1, 1, 1)
    local bodyFont = love.graphics.getFont()
    love.graphics.printf(line.text, boxX + 140, boxY + 45, boxW - 160)

    -- Continue hint
    love.graphics.setColor(0.6, 0.6, 0.6, 0.8 + math.sin(love.timer.getTime() * 3) * 0.2)
    love.graphics.print("Pritisnite PRESLEDEK ali kliknite za nadaljevanje", boxX + 140, boxY + boxH - 25)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setLineWidth(1)
end

function CampaignStory.keypressed(key)
    if not isActive then return false end
    if key == "space" or key == "return" or key == "kpenter" then
        CampaignStory.nextLine()
        return true
    elseif key == "escape" then
        CampaignStory.skip()
        return true
    end
    return false
end

function CampaignStory.mousepressed(x, y, button)
    if not isActive then return false end
    if button == 1 then
        CampaignStory.nextLine()
        return true
    end
    return false
end

return CampaignStory
