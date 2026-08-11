local Mason = {}
local STONES = {
    granite = { name = "Granit", cost = 30, qualityBonus = 10, durability = 90 },
    marble = { name = "Marmor", cost = 80, qualityBonus = 25, prestige = 5 },
    limestone = { name = "Apnenec", cost = 15, qualityBonus = 5, durability = 50 },
    sandstone = { name = "Peščenjak", cost = 20, qualityBonus = 8, durability = 40 },
    slate = { name = "Skrilavec", cost = 40, qualityBonus = 15, durability = 70 },
    basalt = { name = "Bazalt", cost = 50, qualityBonus = 18, durability = 85 },
    travertine = { name = "Travertin", cost = 60, qualityBonus = 20, prestige = 3 },
    flint = { name = "Kremen", cost = 25, qualityBonus = 12, durability = 60 },
}
local PRODUCTS = {
    block = { name = "Zidanica", stoneCost = 3, time = 2, cost = 50, description = "Pravilno izklesan kamen za gradnjo." },
    column = { name = "Stebro", stoneCost = 10, time = 14, cost = 500, prestige = 15, description = "Okrasno stebro." },
    capital = { name = "Kapitel", stoneCost = 4, time = 7, cost = 200, prestige = 8, description = "Vrh stebra z okrasjem." },
    lintel = { name = "Nadpražnik", stoneCost = 5, time = 5, cost = 150, description = "Kamniti nadpražnik." },
    fountain = { name = "Vodnjak", stoneCost = 15, time = 20, cost = 800, prestige = 20, happiness = 5, description = "Kamniti vodnjak." },
    tombstone = { name = "Nagrobnik", stoneCost = 3, time = 5, cost = 100, faith = 5, description = "Nagrobni spomenik." },
}
local BUILDINGS = {
    quarry = { name = "Kamnolom", cost = { gold = 500, wood = 100, iron = 50 }, upkeep = 15, stoneProduction = 5, description = "Za pridobivanje kamna." },
    workshop = { name = "Klesarska delavnica", cost = { gold = 300, wood = 100, stone = 50 }, upkeep = 10, qualityBonus = 5, description = "Za klesanje kamna." },
    stone_yard = { name = "Kamnoseško dvorišče", cost = { gold = 1500, wood = 200, stone = 300 }, upkeep = 30, qualityBonus = 20, description = "Veliko dvorišče za obdelavo." },
    royal_quarry = { name = "Kraljevski kamnolom", cost = { gold = 4000, wood = 400, stone = 800, iron = 100 }, upkeep = 80, qualityBonus = 35, prestigeBonus = 15, description = "Največji kamnolom." },
}
Mason.stoneStock = {}; Mason.productStock = {}; Mason.buildings = {}; Mason.mason = nil
Mason.activeCutting = {}; Mason.totalProducts = 0; Mason.dayTimer = 0
function Mason.init() Mason.stoneStock = {}; Mason.productStock = {}; Mason.buildings = {}; Mason.mason = nil; Mason.activeCutting = {}; Mason.totalProducts = 0; Mason.dayTimer = 0; print("[Mason] Royal Mason & Stonecutter System initialized (8 stones, 6 products, 4 buildings)") end
function Mason.hireMason(n,s) s=s or math.random(40,85); local c=300+s*6; if not _G.state or (_G.state.gold or 0)<c then return false,"Premalo zlata" end; _G.state.gold=_G.state.gold-c; Mason.mason={name=n or ("Kamnosek "..math.random(1,99)),skill=s,hiredDay=os.time(),itemsMade=0}; if _G.NotificationCenter then pcall(_G.NotificationCenter.notify,string.format("Kamnosek najet: %s (spretnost: %d)",Mason.mason.name,s),"success") end; return true end
function Mason.canBuild(id) local d=BUILDINGS[id]; if not d then return false,"Neznana zgradba" end; if not _G.state then return false,"Brez stanja" end; if _G.state.gold<(d.cost.gold or 0) then return false,"Premalo zlata" end; if _G.state.resources then for r,a in pairs(d.cost) do if r~="gold" and (_G.state.resources[r] or 0)<a then return false,"Premalo "..r end end end; return true end
function Mason.build(id) local ok,e=Mason.canBuild(id); if not ok then return false,e end; local d=BUILDINGS[id]; _G.state.gold=_G.state.gold-(d.cost.gold or 0); if _G.state.resources then for r,a in pairs(d.cost) do if r~="gold" then _G.state.resources[r]=(_G.state.resources[r] or 0)-a end end end; table.insert(Mason.buildings,{type=id,builtDay=os.time()}); if _G.NotificationCenter then pcall(_G.NotificationCenter.notify,"Zgrajeno: "..d.name,"success") end; return true end
function Mason.getQualityBonus() local b=0; for _,bd in ipairs(Mason.buildings) do local d=BUILDINGS[bd.type]; if d and d.qualityBonus then b=b+d.qualityBonus end end; return b end
function Mason.purchaseStone(t,q) local d=STONES[t]; if not d then return false,"Neznan kamen" end; q=q or 1; local c=d.cost*q; if not _G.state or (_G.state.gold or 0)<c then return false,"Premalo zlata" end; _G.state.gold=_G.state.gold-c; Mason.stoneStock[t]=(Mason.stoneStock[t] or 0)+q; return true end
function Mason.canCut(pt,st) local pD=PRODUCTS[pt]; local sD=STONES[st]; if not pD or not sD then return false,"Neznan produkt ali kamen" end; if (Mason.stoneStock[st] or 0)<pD.stoneCost then return false,"Premalo kamna" end; if #Mason.buildings==0 then return false,"Potrebna zgradba" end; if not Mason.mason then return false,"Potreben kamnosek" end; return true end
function Mason.cut(pt,st) local ok,e=Mason.canCut(pt,st); if not ok then return false,e end; local pD=PRODUCTS[pt]; local sD=STONES[st]; Mason.stoneStock[st]=Mason.stoneStock[st]-pD.stoneCost; local t=pD.time; if Mason.mason then t=math.max(1,t-math.floor(Mason.mason.skill/8)) end; table.insert(Mason.activeCutting,{id="cut_"..tostring(os.time()).."_"..tostring(math.random(1000,9999)),productType=pt,productName=pD.name,stoneType=st,stoneName=sD.name,stoneQuality=sD.qualityBonus,stonePrestige=sD.prestige or 0,cost=pD.cost,prestige=pD.prestige or 0,happiness=pD.happiness or 0,faith=pD.faith or 0,daysRemaining=t,started=os.time()}); if _G.NotificationCenter then pcall(_G.NotificationCenter.notify,string.format("Klesanje: %s iz %s (%d dni)",pD.name,sD.name,t),"info") end; return true end
function Mason.completeCutting(c) local q=1.0+(Mason.getQualityBonus()/100)+(c.stoneQuality/100); if Mason.mason then q=q+(Mason.mason.skill/200) end; q=math.min(2.5,q); Mason.productStock[c.productType]=(Mason.productStock[c.productType] or 0)+1; Mason.totalProducts=Mason.totalProducts+1; if _G.state and _G.state.happiness then _G.state.happiness=math.min(100,_G.state.happiness+c.happiness) end; if c.faith>0 and _G.Religion then pcall(_G.Religion.addFaith,c.faith) end; if Mason.mason then Mason.mason.itemsMade=Mason.mason.itemsMade+1; if math.random()<0.15 then Mason.mason.skill=math.min(100,Mason.mason.skill+1) end end; if _G.NotificationCenter then pcall(_G.NotificationCenter.notify,string.format("Kamnoseštvo dokončano: %s (kakovost: %.1f)",c.productName,q),"success") end end
function Mason.update(dt) if not _G.state then return end; Mason.dayTimer=Mason.dayTimer+dt; if Mason.dayTimer>=30 then Mason.dayTimer=0; for i=#Mason.activeCutting,1,-1 do local c=Mason.activeCutting[i]; c.daysRemaining=c.daysRemaining-1; if c.daysRemaining<=0 then Mason.completeCutting(c); table.remove(Mason.activeCutting,i) end end; local tu=0; for _,bd in ipairs(Mason.buildings) do local d=BUILDINGS[bd.type]; if d and d.upkeep then tu=tu+d.upkeep end end; if Mason.mason then tu=tu+12 end; if tu>0 and _G.state then _G.state.gold=math.max(0,(_G.state.gold or 0)-tu) end end end
function Mason.getStats() return {numProducts=#Mason.productStock,stoneStock=Mason.stoneStock,numBuildings=#Mason.buildings,hasMason=Mason.mason~=nil,masonName=Mason.mason and Mason.mason.name or "—",masonSkill=Mason.mason and Mason.mason.skill or 0,activeCutting=#Mason.activeCutting,totalProducts=Mason.totalProducts} end
return Mason
