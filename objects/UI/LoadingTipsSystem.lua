-- objects/UI/LoadingTipsSystem.lua
-- Stronghold 2027 - Loading Tips System
-- Shows tips during loading screens

local LoadingTips = {}

local TIPS = {
    -- Economy tips
    { category = "Ekonomija", text = "Les je najpomembnejša surovina v začetku. Zgradite vsaj 3 drvarjeve koče." },
    { category = "Ekonomija", text = "Kašča je nujna za shranjevanje hrane. Brez nje prebivalci stradajo." },
    { category = "Ekonomija", text = "Tržnica omogoča nakup in prodajo surovin. Izkoristite nihanje cen!" },
    { category = "Ekonomija", text = "Zlata je nikoli preveč. Davki so glavni vir dohodka." },
    { category = "Ekonomija", text = "Pšenična kmetija proizvaja žito, ki ga mlin spremeni v moko." },
    { category = "Ekonomija", text = "Pekarna porabi moko in proizvaja kruh — osnovno hrano za prebivalce." },
    { category = "Ekonomija", text = "Hmelj vzgajajte v hmeljskih kmetijah, pivovarna ga spremeni v ale." },
    { category = "Ekonomija", text = "Krčma povečuje popularnost z ale, a pazite na porabo hrane." },

    -- Military tips
    { category = "Vojaštvo", text = "Lokostrelci so učinkoviti na daljavo, a šibki v bližinskem boju." },
    { category = "Vojaštvo", text = "Kopjaši so ceni vendar učinkoviti proti konjenici." },
    { category = "Vojaštvo", text = "Vitezi so najmočnejša enota, a stanejo veliko zlata in železa." },
    { category = "Vojaštvo", text = "Strelci samostrelov prebijajo oklep, a so počasni pri ponovnem polnjenju." },
    { category = "Vojaštvo", text = "Vedno imeejte mešanico enot — lokostrelci za podporo, pehota za obrambo." },
    { category = "Vojaštvo", text = "Zidovi in stolpi so ključni za obrambo pred napadi." },
    { category = "Vojaštvo", text = "Oblegovalna orožja (katapult, trebuchet) so nujna za uničevanje zidov." },

    -- Building tips
    { category = "Zgradbe", text = "Nadgradite grad za odklepanje novih zgradb in enot." },
    { category = "Zgradbe", text = "Hiše povečujejo maksimalno populacijo. Vsaka hiša sprejme 4 prebivalce." },
    { category = "Zgradbe", text = "Kovačnica proizvaja meče, lokar fižole, kopja pa paličar." },
    { category = "Zgradbe", text = "Orožarna shranjuje orožje za usposabljanje vojakov." },
    { category = "Zgradbe", text = "Kapela, cerkev in katedrala povečujejo versko zadovoljstvo." },
    { category = "Zgradbe", text = "Vrtovi in ribniki povečujejo popularnost prebivalcev." },

    -- Strategy tips
    { category = "Strategija", text = "Popularnost nad 50 pomeni, da prebivalci ne odhajajo. Pod 50 začnejo bežati." },
    { category = "Strategija", text = "Davki nad 0 zmanjšujejo popularnost. Visoki davki = nemiri." },
    { category = "Strategija", text = "Hrana nad 0 povečuje popularnost. Brez hrane prebivalci stradajo." },
    { category = "Strategija", text = "Ale povečuje popularnost za 8. Religija za 5-25." },
    { category = "Strategija", text = "Strah (negativne zgradbe) zmanjšuje popularnost, a povečuje učinkovitost vojakov." },
    { category = "Strategija", text = "Vreme vpliva na kmetije! Dež povečuje pridelek za 50%." },
    { category = "Strategija", text = "Megla zmanjšuje vidljivost za 50%. Izkoristite za presenečenja!" },
    { category = "Strategija", text = "Festivali (turnir, gostija) začasno povečajo popularnost." },

    -- Multiplayer tips
    { category = "Multiplayer", text = "Zavezništvo omogoča skupno obrambo in delitev videnega." },
    { category = "Multiplayer", text = "Trgovina med igralci je cenejša kot nakup na tržnici." },
    { category = "Multiplayer", text = "Napoved vojne omogoča napadanje. Brez vojne ne morete napasti." },
    { category = "Multiplayer", text = "Premirje traja 5 minut. Izkoristite čas za obrambo." },
    { category = "Multiplayer", text = "Darila (tribute) izboljšujejo odnose z drugimi igralci." },

    -- Tips for beginners
    { category = "Začetnik", text = "Pritisnite F1 za pomoč in seznam tipk." },
    { category = "Začetnik", text = "Pritisnite Ctrl+T za vadbo v slovenščini (10 korakov)." },
    { category = "Začetnik", text = "Pritisnite Ctrl+O za nastavitve (jezik, grafika, zvok, dostopnost)." },
    { category = "Začetnik", text = "Pritisnite F12 za urejevalnik map. Ustvarite svojo mapo!" },
    { category = "Začetnik", text = "Pritisnite F9 za diplomacijo in trgovanje v multiplayer-ju." },
    { category = "Začetnik", text = "Pritisnite Enter za klepet v multiplayer-ju." },
    { category = "Začetnik", text = "Pritisnite Tilde (~) za debug konzolo z 12 ukazi." },

    -- HD tips
    { category = "Grafika", text = "F7 preklopi HD pipeline (normal mapping, SSAO, tone mapping)." },
    { category = "Grafika", text = "F6 spremeni čas dneva (zora, dan, mrak, noč)." },
    { category = "Grafika", text = "F5 spremeni vreme (jasno, dež, megla, sneg, nevihta)." },
    { category = "Grafika", text = "Ponoči bakle in zgradbe svetijo. Gradite ob vodnih virih." },
}

local shownTips = {}
local currentTip = nil
local tipTimer = 0
local tipInterval = 5.0  -- Show new tip every 5 seconds
local initialized = false

function LoadingTips.init()
    if initialized then return end
    initialized = true
    print("[LoadingTips] Initialized with " .. #TIPS .. " tips")
end

function LoadingTips.getRandomTip()
    -- Try to find unshown tip
    local available = {}
    for i, tip in ipairs(TIPS) do
        if not shownTips[i] then
            table.insert(available, i)
        end
    end

    -- Reset if all shown
    if #available == 0 then
        shownTips = {}
        for i = 1, #TIPS do
            table.insert(available, i)
        end
    end

    local idx = available[math.random(#available)]
    shownTips[idx] = true
    return TIPS[idx]
end

function LoadingTips.getCurrentTip()
    return currentTip
end

function LoadingTips.update(dt)
    if not initialized then return end

    tipTimer = tipTimer + dt
    if tipTimer >= tipInterval or not currentTip then
        tipTimer = 0
        currentTip = LoadingTips.getRandomTip()
    end
end

function LoadingTips.draw(x, y, maxWidth)
    if not currentTip then return end

    love.graphics.setColor(0.8, 0.8, 0.9, 0.9)
    love.graphics.printf("[" .. currentTip.category .. "] " .. currentTip.text,
        x or 50, y or 50, maxWidth or 800)
    love.graphics.setColor(1, 1, 1, 1)
end

function LoadingTips.getTipCount()
    return #TIPS
end

function LoadingTips.getTipsByCategory(category)
    local result = {}
    for _, tip in ipairs(TIPS) do
        if tip.category == category then
            table.insert(result, tip)
        end
    end
    return result
end

function LoadingTips.getCategories()
    local cats = {}
    for _, tip in ipairs(TIPS) do
        if not cats[tip.category] then
            cats[tip.category] = true
            table.insert(cats, tip.category)
        end
    end
    return cats
end

return LoadingTips
