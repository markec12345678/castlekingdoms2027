local Ropemaker = {}
local PRODUCTS = {
    rope = { name = "Vrv", fiberCost = 3, time = 1, cost = 10, strength = 20, description = "Osnovna vrv." },
    thick_rope = { name = "Debela vrv", fiberCost = 8, time = 3, cost = 40, strength = 50, description = "Debela vrv za sidra." },
    cord = { name = "Vrvica", fiberCost = 1, time = 1, cost = 5, strength = 10, description = "Tanko vrvico." },
    net = { name = "Mreža", fiberCost = 10, time = 5, cost = 60, strength = 30, description = "Ribja mreža." },
    tackle = { name = "Tovorna vrv", fiberCost = 15, time = 7, cost = 100, strength = 80, description = "Vrv za dvigalne naprave." },
    bowstring = { name = "Tetiva", fiberCost = 2, time = 2, cost = 20, strength = 15, militaryBonus = 5, description = "Tetiva za lok." },
}
local FIBERS = {
    hemp = { name = "Konoplja", cost = 3, strengthBonus = 10, description = "Najpogostejša vlakna." },
    flax = { name = "Len", cost = 5, strengthBonus = 15, description = "Fina in močna vlakna." },
    jute = { name = "Juta", cost = 2, strengthBonus = 5, description = "Cenejša vlakna." },
    silk = { name = "Svila", cost = 50, strengthBonus = 30, prestige = 5, description = "Luksuzna vlakna." },
    cotton = { name = "Bombaž", cost = 8, strengthBonus = 12, description = "Mehka vlakna." },
    sinew = { name = "Kitica", cost = 20, strengthBonus = 25, militaryBonus = 3, description = "Živalska vlakna za tetive." },
}
local BUILDINGS = {
    ropewalk = { name = "Vrvarna", cost = { gold = 200, wood = 100 }, upkeep = 5, qualityBonus = 5 },
    workshop = { name = "Delavnica vrvi", cost = { gold = 500, wood = 200 }, upkeep = 12, qualityBonus = 10 },
    fiber_garden = { name = "Vrt vlaken", cost = { gold = 300, wood = 50 }, upkeep = 5, fiberProduction = 5 },
    royal_ropery = { name = "Kraljevska vrvana", cost = { gold = 2500, wood = 400, stone = 500 }, upkeep = 50, qualityBonus = 30, prestigeBonus = 10 },
}
Ropemaker.fiberStock = {}; Ropemaker.productStock = {}; Ropemaker.buildings = {}; Ropemaker.ropemaker = nil
Ropemaker.activeMaking = {}; Ropemaker.totalProducts = 0; Ropemaker.dayTimer = 0
function Ropemaker.init() Ropemaker.fiberStock={}; Ropemaker.productStock={}; Ropemaker.buildings={}; Ropemaker.ropemaker=nil; Ropemaker.activeMaking={}; Ropemaker.totalProducts=0; Ropemaker.dayTimer=0; print("[Ropemaker] Royal Ropemaker & Cordage System initialized (6 products, 6 fibers, 4 buildings)") end
function Ropemaker.hireRopemaker(n,s) s=s or math.random(35,75); local c=200+s*4; if not _G.state or (_G.state.gold or 0)<c then return false,"Premalo zlata" end; _G.state.gold=_G.state.gold-c; Ropemaker.ropemaker={name=n or ("Vrvar "..math.random(1,99)),skill=s,hiredDay=os.time(),itemsMade=0}; if _G.NotificationCenter then pcall(_G.NotificationCenter.notify,string.format("Vrvar najet: %s (spretnost: %d)",Ropemaker.ropemaker.name,s),"success") end; return true end
function Ropemaker.canBuild(id) local d=BUILDINGS[id]; if not d then return false,"Neznana zgradba" end; if not _G.state then return false,"Brez stanja" end; if _G.state.gold<(d.cost.gold or 0) then return false,"Premalo zlata" end; if _G.state.resources then for r,a in pairs(d.cost) do if r~="gold" and (_G.state.resources[r] or 0)<a then return false,"Premalo "..r end end end; return true end
function Ropemaker.build(id) local ok,e=Ropemaker.canBuild(id); if not ok then return false,e end; local d=BUILDINGS[id]; _G.state.gold=_G.state.gold-(d.cost.gold or 0); if _G.state.resources then for r,a in pairs(d.cost) do if r~="gold" then _G.state.resources[r]=(_G.state.resources[r] or 0)-a end end end; table.insert(Ropemaker.buildings,{type=id,builtDay=os.time()}); if _G.NotificationCenter then pcall(_G.NotificationCenter.notify,"Zgrajeno: "..d.name,"success") end; return true end
function Ropemaker.getQualityBonus() local b=0; for _,bd in ipairs(Ropemaker.buildings) do local d=BUILDINGS[bd.type]; if d and d.qualityBonus then b=b+d.qualityBonus end end; return b end
function Ropemaker.purchaseFiber(ft,q) local d=FIBERS[ft]; if not d then return false,"Neznana vlakna" end; q=q or 1; local c=d.cost*q; if not _G.state or (_G.state.gold or 0)<c then return false,"Premalo zlata" end; _G.state.gold=_G.state.gold-c; Ropemaker.fiberStock[ft]=(Ropemaker.fiberStock[ft] or 0)+q; return true end
function Ropemaker.canMake(pt,ft) local pD=PRODUCTS[pt]; local fD=FIBERS[ft]; if not pD or not fD then return false,"Neznan produkt ali vlakna" end; if (Ropemaker.fiberStock[ft] or 0)<pD.fiberCost then return false,"Premalo vlaken" end; if #Ropemaker.buildings==0 then return false,"Potrebna vrvana" end; if not Ropemaker.ropemaker then return false,"Potreben vrvar" end; return true end
function Ropemaker.make(pt,ft) local ok,e=Ropemaker.canMake(pt,ft); if not ok then return false,e end; local pD=PRODUCTS[pt]; local fD=FIBERS[ft]; Ropemaker.fiberStock[ft]=Ropemaker.fiberStock[ft]-pD.fiberCost; local t=pD.time; if Ropemaker.ropemaker then t=math.max(1,t-math.floor(Ropemaker.ropemaker.skill/20)) end; table.insert(Ropemaker.activeMaking,{id="rope_"..tostring(os.time()).."_"..tostring(math.random(1000,9999)),productType=pt,productName=pD.name,fiberType=ft,fiberName=fD.name,fiberStrength=fD.strengthBonus,fiberPrestige=fD.prestige or 0,strength=pD.strength,cost=pD.cost,militaryBonus=pD.militaryBonus or 0,daysRemaining=t,started=os.time()}); if _G.NotificationCenter then pcall(_G.NotificationCenter.notify,string.format("Izdelava: %s iz %s (%d dni)",pD.name,fD.name,t),"info") end; return true end
function Ropemaker.completeMaking(m) local q=1.0+(Ropemaker.getQualityBonus()/100)+(m.fiberStrength/100); if Ropemaker.ropemaker then q=q+(Ropemaker.ropemaker.skill/200) end; q=math.min(2.0,q); Ropemaker.productStock[m.productType]=(Ropemaker.productStock[m.productType] or 0)+1; Ropemaker.totalProducts=Ropemaker.totalProducts+1; if Ropemaker.ropemaker then Ropemaker.ropemaker.itemsMade=Ropemaker.ropemaker.itemsMade+1; if math.random()<0.15 then Ropemaker.ropemaker.skill=math.min(100,Ropemaker.ropemaker.skill+1) end end; if _G.NotificationCenter then pcall(_G.NotificationCenter.notify,string.format("Vrv izdelana: %s (kakovost: %.1f)",m.productName,q),"success") end end
function Ropemaker.update(dt) if not _G.state then return end; Ropemaker.dayTimer=Ropemaker.dayTimer+dt; if Ropemaker.dayTimer>=30 then Ropemaker.dayTimer=0; for i=#Ropemaker.activeMaking,1,-1 do local m=Ropemaker.activeMaking[i]; m.daysRemaining=m.daysRemaining-1; if m.daysRemaining<=0 then Ropemaker.completeMaking(m); table.remove(Ropemaker.activeMaking,i) end end; local tu=0; for _,bd in ipairs(Ropemaker.buildings) do local d=BUILDINGS[bd.type]; if d and d.upkeep then tu=tu+d.upkeep end end; if Ropemaker.ropemaker then tu=tu+6 end; if tu>0 and _G.state then _G.state.gold=math.max(0,(_G.state.gold or 0)-tu) end end end
function Ropemaker.getStats() return {fiberStock=Ropemaker.fiberStock,productStock=Ropemaker.productStock,numBuildings=#Ropemaker.buildings,hasRopemaker=Ropemaker.ropemaker~=nil,ropemakerName=Ropemaker.ropemaker and Ropemaker.ropemaker.name or "—",ropemakerSkill=Ropemaker.ropemaker and Ropemaker.ropemaker.skill or 0,activeMaking=#Ropemaker.activeMaking,totalProducts=Ropemaker.totalProducts} end
return Ropemaker
