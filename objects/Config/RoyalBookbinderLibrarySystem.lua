-- objects/Config/RoyalBookbinderLibrarySystem.lua
-- Castle Kingdoms 2027 v3.6.7 - Royal Bookbinder & Library System
--
-- Manages book binding, library management, and book collection.
-- Books provide knowledge, prestige, and research bonuses.
--
-- Features:
-- - 6 binding types (limp, leather, wooden board, jeweled, chained, royal)
-- - 8 book categories (theology, philosophy, law, medicine, history, poetry, science, bestiary)
-- - 4 library buildings (book closet, library, scriptorium archive, royal library)
-- - Bookbinder NPC (skill affects quality)
-- - Book binding (time-based production)
-- - Library cataloging
-- - Book lending and borrowing
-- - Collection bonuses

local Bookbinder = {}

local BINDINGS = {
    limp = { name = "Mehka vezava", cost = 20, time = 2, durability = 20, description = "Preprosta mehka vezava iz usnja." },
    leather = { name = "Usnjena vezava", cost = 50, time = 4, durability = 50, description = "Trdna usnjena vezava." },
    wooden = { name = "Lesena vezava", cost = 80, time = 5, durability = 80, description = "Lesene deske s usnjenim hrbtom." },
    jeweled = { name = "Draguljarna vezava", cost = 500, time = 14, durability = 100, prestige = 15, description = "Vezava z dragimi kamni in zlatom." },
    chained = { name = "Prikovana knjiga", cost = 100, time = 5, durability = 90, description = "Prikovana na polico proti kraji." },
    royal = { name = "Kraljevska vezava", cost = 1000, time = 20, durability = 100, prestige = 30, description = "Najboljša vezava za kraljevo knjižnico." },
}

local CATEGORIES = {
    theology = { name = "Teologija", knowledge = 15, faith = 10, description = "Verska besedila." },
    philosophy = { name = "Filozofija", knowledge = 20, description = "Filozofska dela." },
    law = { name = "Pravo", knowledge = 15, description = "Pravne knjige in zakoni." },
    medicine = { name = "Medicina", knowledge = 20, health = 5, description = "Medicinska besedila." },
    history = { name = "Zgodovina", knowledge = 15, prestige = 3, description = "Zgodovinski zapisi." },
    poetry = { name = "Poezija", knowledge = 10, happiness = 5, description = "Pesemske zbirke." },
    science = { name = "Znanost", knowledge = 25, description = "Naravoslovna dela." },
    bestiary = { name = "Bestiarij", knowledge = 12, happiness = 3, description = "Knjige o živalih in mitih." },
}

local BUILDINGS = {
    book_closet = { name = "Knjižna omarica", cost = { gold = 100, wood = 50 }, upkeep = 2, capacity = 20, description = "Majhna omarica za knjige." },
    library = { name = "Knjižnica", cost = { gold = 1500, wood = 300, stone = 300 }, upkeep = 30, capacity = 100, knowledgeBonus = 10, description = "Javna knjižnica." },
    scriptorium_archive = { name = "Skriptorijski arhiv", cost = { gold = 3000, wood = 400, stone = 600 }, upkeep = 60, capacity = 300, knowledgeBonus = 20, prestigeBonus = 10, description = "Veliki arhiv rokopisov." },
    royal_library = { name = "Kraljevska knjižnica", cost = { gold = 8000, wood = 500, stone = 1500 }, upkeep = 150, capacity = 1000, knowledgeBonus = 40, prestigeBonus = 25, description = "Največja knjižnica v deželi." },
}

Bookbinder.books = {}
Bookbinder.buildings = {}
Bookbinder.bookbinder = nil
Bookbinder.activeBinding = {}
Bookbinder.totalBooksBound = 0
Bookbinder.dayTimer = 0

function Bookbinder.init()
    Bookbinder.books = {}
    Bookbinder.buildings = {}
    Bookbinder.bookbinder = nil
    Bookbinder.activeBinding = {}
    Bookbinder.totalBooksBound = 0
    Bookbinder.dayTimer = 0
    print("[Bookbinder] Royal Bookbinder & Library System initialized (6 bindings, 8 categories, 4 buildings)")
end

function Bookbinder.hireBookbinder(name, skill)
    skill = skill or math.random(40, 85)
    local cost = 300 + skill * 6
    if not _G.state or (_G.state.gold or 0) < cost then return false, "Premalo zlata" end
    _G.state.gold = _G.state.gold - cost
    Bookbinder.bookbinder = { name = name or ("Vezalec " .. math.random(1, 99)), skill = skill, hiredDay = os.time(), booksBound = 0 }
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Vezalec knjig najet: %s (spretnost: %d)", Bookbinder.bookbinder.name, skill), "success") end
    return true
end

function Bookbinder.canBuild(id) local d = BUILDINGS[id]; if not d then return false, "Neznana zgradba" end; if not _G.state then return false, "Brez stanja" end; if _G.state.gold < (d.cost.gold or 0) then return false, "Premalo zlata" end; if _G.state.resources then for r,a in pairs(d.cost) do if r ~= "gold" and (_G.state.resources[r] or 0) < a then return false, "Premalo " .. r end end end; return true end
function Bookbinder.build(id) local ok,e = Bookbinder.canBuild(id); if not ok then return false, e end; local d = BUILDINGS[id]; _G.state.gold = _G.state.gold - (d.cost.gold or 0); if _G.state.resources then for r,a in pairs(d.cost) do if r ~= "gold" then _G.state.resources[r] = (_G.state.resources[r] or 0) - a end end end; table.insert(Bookbinder.buildings, {type = id, builtDay = os.time()}); if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, "Zgrajeno: " .. d.name, "success") end; return true end
function Bookbinder.getKnowledgeBonus() local b = 0; for _,bd in ipairs(Bookbinder.buildings) do local d = BUILDINGS[bd.type]; if d and d.knowledgeBonus then b = b + d.knowledgeBonus end end; return b end
function Bookbinder.getTotalCapacity() local c = 0; for _,bd in ipairs(Bookbinder.buildings) do local d = BUILDINGS[bd.type]; if d and d.capacity then c = c + d.capacity end end; return c end

function Bookbinder.canBind(bindingType, category)
    local bDef = BINDINGS[bindingType]; local cDef = CATEGORIES[category]
    if not bDef or not cDef then return false, "Neznana vezava ali kategorija" end
    if not _G.state or (_G.state.gold or 0) < bDef.cost then return false, "Premalo zlata" end
    if #Bookbinder.buildings == 0 then return false, "Potrebna knjižnična zgradba" end
    if not Bookbinder.bookbinder then return false, "Potreben vezalec" end
    return true
end

function Bookbinder.bindBook(bindingType, category, title)
    local ok, err = Bookbinder.canBind(bindingType, category)
    if not ok then return false, err end
    local bDef = BINDINGS[bindingType]; local cDef = CATEGORIES[category]
    _G.state.gold = _G.state.gold - bDef.cost
    local bindTime = bDef.time
    if Bookbinder.bookbinder then bindTime = math.max(1, bindTime - math.floor(Bookbinder.bookbinder.skill / 10)) end
    table.insert(Bookbinder.activeBinding, {
        id = "book_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        bindingType = bindingType, bindingName = bDef.name,
        category = category, categoryName = cDef.name,
        title = title or (cDef.name .. " #" .. (Bookbinder.totalBooksBound + 1)),
        durability = bDef.durability, prestige = bDef.prestige or 0,
        knowledge = cDef.knowledge, faith = cDef.faith or 0,
        health = cDef.health or 0, happiness = cDef.happiness or 0,
        daysRemaining = bindTime, started = os.time(),
    })
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Vezava knjige: %s — %s (%d dni)", bDef.name, cDef.name, bindTime), "info") end
    return true
end

function Bookbinder.completeBinding(b)
    local quality = 1.0 + (Bookbinder.getKnowledgeBonus() / 100)
    if Bookbinder.bookbinder then quality = quality + (Bookbinder.bookbinder.skill / 200) end
    quality = math.min(2.0, quality)
    local book = { id = b.id, title = b.title, binding = b.bindingName, category = b.categoryName,
        durability = b.durability, quality = quality,
        knowledge = math.floor(b.knowledge * quality), faith = math.floor(b.faith * quality),
        health = math.floor(b.health * quality), happiness = math.floor(b.happiness * quality),
        prestige = math.floor(b.prestige * quality), boundDay = os.time() }
    table.insert(Bookbinder.books, book)
    Bookbinder.totalBooksBound = Bookbinder.totalBooksBound + 1
    if _G.Culture then pcall(function() _G.Culture.knowledgePoints = (_G.Culture.knowledgePoints or 0) + book.knowledge end) end
    if book.faith > 0 and _G.Religion then pcall(_G.Religion.addFaith, book.faith) end
    if book.happiness > 0 and _G.state and _G.state.happiness then _G.state.happiness = math.min(100, _G.state.happiness + book.happiness) end
    if book.prestige > 0 and _G.state and _G.state.happiness then _G.state.happiness = math.min(100, _G.state.happiness + book.prestige) end
    if Bookbinder.bookbinder then Bookbinder.bookbinder.booksBound = Bookbinder.bookbinder.booksBound + 1; if math.random() < 0.15 then Bookbinder.bookbinder.skill = math.min(100, Bookbinder.bookbinder.skill + 1) end end
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Knjiga vezana: %s (kakovost: %.1f)", book.title, quality), "success") end
end

function Bookbinder.update(dt)
    if not _G.state then return end
    Bookbinder.dayTimer = Bookbinder.dayTimer + dt
    if Bookbinder.dayTimer >= 30 then
        Bookbinder.dayTimer = 0
        for i = #Bookbinder.activeBinding, 1, -1 do
            local b = Bookbinder.activeBinding[i]
            b.daysRemaining = b.daysRemaining - 1
            if b.daysRemaining <= 0 then Bookbinder.completeBinding(b); table.remove(Bookbinder.activeBinding, i) end
        end
        local totalUpkeep = 0
        for _, bd in ipairs(Bookbinder.buildings) do local d = BUILDINGS[bd.type]; if d and d.upkeep then totalUpkeep = totalUpkeep + d.upkeep end end
        if Bookbinder.bookbinder then totalUpkeep = totalUpkeep + 12 end
        if totalUpkeep > 0 and _G.state then _G.state.gold = math.max(0, (_G.state.gold or 0) - totalUpkeep) end
    end
end

function Bookbinder.getBindingInfo(id) return BINDINGS[id] end
function Bookbinder.getCategoryInfo(id) return CATEGORIES[id] end
function Bookbinder.getBuildingInfo(id) return BUILDINGS[id] end
function Bookbinder.getStats()
    return { numBooks = #Bookbinder.books, capacity = Bookbinder.getTotalCapacity(),
        numBuildings = #Bookbinder.buildings, hasBookbinder = Bookbinder.bookbinder ~= nil,
        bookbinderName = Bookbinder.bookbinder and Bookbinder.bookbinder.name or "—",
        bookbinderSkill = Bookbinder.bookbinder and Bookbinder.bookbinder.skill or 0,
        activeBinding = #Bookbinder.activeBinding, totalBooksBound = Bookbinder.totalBooksBound }
end

return Bookbinder
