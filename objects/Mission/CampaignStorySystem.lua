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
    -- Stronghold 2027 v2.5.0: Historical Norman Conquest story beats (1066-1087)
    mission11 = {
        intro = {
            { speaker = "Pripovedovalec", portrait = "narrator", text = "Leto 1066. Kralj Edward Spoznavalec je mrtev. Harold Godwinson si je prilastil angleški prestol." },
            { speaker = "Pripovedovalec", portrait = "narrator", text = "Viljem, vojvoda Normandije, verjame, da mu je Edward obljubil krono. Z 7000 vojaki pluje čez kanal." },
            { speaker = "Viljem Osvajalec", portrait = "noble", text = "Harold je prelomil zahteva! Angleški prestol je moj po pravici. Pri Hastingsu se bomo odločili!" },
        },
        outro = {
            { speaker = "Pripovedovalec", portrait = "narrator", text = "Harold je mrtev — puščica v očesu po izročilu. Saški ščitni zid je zlomljen." },
            { speaker = "Viljem Osvajalec", portrait = "noble", text = "Anglija je moja! Zmaga pri Hastingsu bo odmevala skozi stoletja!" },
        },
    },
    mission12 = {
        intro = {
            { speaker = "Pripovedovalec", portrait = "narrator", text = "Božič 1066. Viljem pluje po Temzo do Londona. Westminster Abbey čaka na kronanje." },
            { speaker = "Viljem Osvajalec", portrait = "noble", text = "London mora biti varen pred uporniki. Tower bo simbol normanske moči!" },
        },
        outro = {
            { speaker = "Škof", portrait = "noble", text = "Vaše Veličanstvo, Anglija ima novega kralja. Viljem I., Osvajalec!" },
        },
    },
    mission13 = {
        intro = {
            { speaker = "Pripovedovalec", portrait = "narrator", text = "Zima 1069. Severna Anglija se je uprla. Danska vojska je pristala v Humberju." },
            { speaker = "Viljem Osvajalec", portrait = "noble", text = "Sever mora izvedeti, kaj pomeni prekleti normanski kralj. Pustošenje bo popolno!" },
        },
        outro = {
            { speaker = "Pripovedovalec", portrait = "narrator", text = "Yorkshire je opustošen. Tisoči stradajo. Normanski nadzor je vzpostavljen — s ceno krvi." },
        },
    },
    mission14 = {
        intro = {
            { speaker = "Pripovedovalec", portrait = "narrator", text = "Leto 1086. Viljem želi vedeti, kaj točno poseduje. Ukaze popis vse Anglije." },
            { speaker = "Viljem Osvajalec", portrait = "noble", text = "Vsak drobec zemlje, vsaka krava, vsak kmet — vse mora biti zabeleženo v Domesday Knjigi!" },
        },
        outro = {
            { speaker = "Pisar", portrait = "peasant", text = "Vaše Veličanstvo, popis je končan. Anglija je bogata dežela, resnično bogata." },
        },
    },
    mission15 = {
        intro = {
            { speaker = "Pripovedovalec", portrait = "narrator", text = "Leto 1081. Valižani napadajo obmejne vasi. Viljem vodi vojsko v gorski Wales." },
            { speaker = "Viljem Osvajalec", portrait = "noble", text = "Ti gore skrivajo gverilce. Gradili bomo obmejne gradove in jih stisnili!" },
        },
        outro = {
            { speaker = "Pripovedovalec", portrait = "narrator", text = "Wales je delno pokorjen. Obmejni gradovi bodo varovali mejo še stoletja." },
        },
    },
    mission16 = {
        intro = {
            { speaker = "Pripovedovalec", portrait = "narrator", text = "Leto 1078. Robert Curthose, Viljemov najstarejši sin, se upre očetu." },
            { speaker = "Robert Curthose", portrait = "noble", text = "Oče mi odteguje moje dediščino! Prevzel bom, kar je moje!" },
            { speaker = "Viljem Osvajalec", portrait = "noble", text = "Moj lastni sin proti meni! Kleknil bo — ali padel!" },
        },
        outro = {
            { speaker = "Pripovedovalec", portrait = "narrator", text = "Pri Gerberoyu je Viljem bil ranjen — od lastnega sina. Leta 1080 so se spravili." },
        },
    },
    mission17 = {
        intro = {
            { speaker = "Pripovedovalec", portrait = "narrator", text = "Leto 1072. Škotski kralj Malcolm III. podpira saške upornike. Viljem vodi vojsko na sever." },
            { speaker = "Viljem Osvajalec", portrait = "noble", text = "Škotska čaka. Malcolm bo kleknil pred normansko krono!" },
        },
        outro = {
            { speaker = "Malcolm III.", portrait = "noble", text = "Predajam se, kralj Viljem. Škotska je tvoja." },
        },
    },
    mission18 = {
        intro = {
            { speaker = "Pripovedovalec", portrait = "narrator", text = "Leto 1075. Danska flota 200 ladij je pristala v Yorku. Zadnja vikinška invazija Anglije!" },
            { speaker = "Viljem Osvajalec", portrait = "noble", text = "Vikingi spet na naših obalah! K orožju! Ta bo zadnjič, da plenijo Angleško!" },
        },
        outro = {
            { speaker = "Pripovedovalec", portrait = "narrator", text = "Dance so odkupili, uporniki pa zlomljeni. Zadnja vikinška doba je končana." },
        },
    },
    mission19 = {
        intro = {
            { speaker = "Pripovedovalec", portrait = "narrator", text = "Leto 1075. Grofje Ralph in Roger sta se uprla. Vstaja grofov grozi normanski oblasti." },
            { speaker = "Viljem Osvajalec", portrait = "noble", text = "Ti grofje pozabljajo, kdo jih je postavil! Zdrobili jih bomo!" },
        },
        outro = {
            { speaker = "Pripovedovalec", portrait = "narrator", text = "Ralph je pobegnil na Dansko, Roger je v ječi za vse življenje. Upor je končan." },
        },
    },
    mission20 = {
        intro = {
            { speaker = "Pripovedovalec", portrait = "narrator", text = "Leto 1087. Francoski kralj Filip I. je vdrl v Normandijo in požgal Mantes." },
            { speaker = "Viljem Osvajalec", portrait = "noble", text = "Filip si drzne napasti MOJA ozemlja? Spoznal bo ceno!" },
        },
        outro = {
            { speaker = "Pripovedovalec", portrait = "narrator", text = "Viljem je zmagal, a bil ranjen v obleganju. Njegov konc se je spotaknil pri gorečih razvalinah Mantesa." },
            { speaker = "Pripovedovalec", portrait = "narrator", text = "Umrl je v Rouenu 9. septembra 1087. Osvajalec je šel — a njegova dediščina traja." },
        },
    },
    mission21 = {
        intro = {
            { speaker = "Pripovedovalec", portrait = "narrator", text = "Epilog. Viljemova dediščina traja. Njegovi sinovi Viljem Rufus in Henrik bodo vladali Angliji." },
            { speaker = "Viljem Rufus", portrait = "noble", text = "Oče bi bil ponosen. Anglija je naša." },
            { speaker = "Henrik Beauclerc", portrait = "noble", text = "In nekoč bo tudi moja. Taka je usoda kraljev." },
        },
        outro = {
            { speaker = "Pripovedovalec", portrait = "narrator", text = "Normanska dinastija, ki jo je ustanovil Viljem, bo vladala Angliji do leta 1154." },
            { speaker = "Pripovedovalec", portrait = "narrator", text = "Njegov vpliv je oblikoval angleško pravo, jezik in kulturo za vedno." },
            { speaker = "Pripovedovalec", portrait = "narrator", text = "Od Hastingsa do Domesday Knjige — oblikovali ste zgodovino. Dobro opravljeno, moj gospod." },
        },
    },
}

local currentDialogue = nil
local currentLine = 0
local isActive = false
local onComplete = nil

function CampaignStory.init()
    print("[CampaignStory] Initialized with " .. CampaignStory._getBeatCount() .. " story beats")
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
