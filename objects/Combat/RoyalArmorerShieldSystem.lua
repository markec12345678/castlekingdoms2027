local Armorer = {}
local ARMOR = {
    helmet = { name = "Čelada", metalCost = 3, leatherCost = 1, time = 8, defense = 15, cost = 100 },
    breastplate = { name = "Oklep", metalCost = 8, leatherCost = 2, time = 14, defense = 30, cost = 300 },
    shield = { name = "Ščit", metalCost = 4, woodCost = 3, time = 6, defense = 20, cost = 150 },
    gauntlets = { name = "Rokavice", metalCost = 2, leatherCost = 2, time = 5, defense = 8, cost = 80 },
    greaves = { name = "Nogavice", metalCost = 4, leatherCost = 2, time = 7, defense = 12, cost = 120 },
    full_plate = { name = "Polni oklep", metalCost = 15, leatherCost = 5, time = 30, defense = 50, cost = 1000, prestige = 10 },
}
local METALS = {
    iron = { name = "Železo", cost = 15, defenseBonus = 5 },
    steel = { name = "Jeklo", cost = 30, defenseBonus = 15 },
    bronze = { name = "Bron", cost = 25, defenseBonus = 10 },
    silver = { name = "Srebro", cost = 100, defenseBonus = 20, prestige = 5, faith = 5 },
    gold = { name = "Zlato", cost = 200, defenseBonus = 25, prestige = 15 },
    mithril = { name = "Mitril", cost = 500, defenseBonus = 40, prestige = 25 },
}
local BUILDINGS = {
    armory = { name = "Okleparna", cost = { gold = 400, wood = 100, stone = 100, iron = 50 }, upkeep = 15, qualityBonus = 5 },
    forge = { name = "Kovašnica oklepov", cost = { gold = 1500, wood = 200, stone = 300, iron = 100 }, upkeep = 40, qualityBonus = 20 },
    plate_armory = { name = "Ploščasta okleparna", cost = { gold = 3000, wood = 300, stone = 600, iron = 200 }, upkeep = 70, qualityBonus = 35, prestigeBonus = 10 },
    royal_armory = { name = "Kraljevska okleparna", cost = { gold = 7000, wood = 500, stone = 1200, iron = 400 }, upkeep = 140, qualityBonus = 50, prestigeBonus = 25 },
}
Armorer.metalStock = {}; Armorer.armorStock = {}; Armorer.buildings = {}; Armorer.armorer = nil
Armorer.activeForging = {}; Armorer.totalArmor = 0; Armorer.dayTimer = 0
function Armorer.init() Armorer.metalStock={}; Armorer.armorStock={}; Armorer.buildings={}; Armorer.armorer=nil; Armorer.activeForging={}; Armorer.totalArmor=0; Armorer.dayTimer=0; print("[Armorer] Royal Armorer & Shield System initialized (6 armor, 6 metals, 4 buildings)") end
function Armorer.hireArmorer(n,s) s=s or math.random(45,90); local c=500+s*10; if not _G.state or (_G.state.gold or 0)<c then return false,"Premalo zlata" end; _G.state.gold=_G.state.gold-c; Armorer.armorer={name=n or ("Oklepar "..math.random(1,99)),skill=s,hiredDay=os.time(),itemsMade=0}; if _G.NotificationCenter then pcall(_G.NotificationCenter.notify,string.format("Oklepar najet: %s (spretnost: %d)",Armorer.armorer.name,s),"success") end; return true end
function Armorer.canBuild(id) local d=BUILDINGS[id]; if not d then return false,"Neznana zgradba" end; if not _G.state then return false,"Brez stanja" end; if _G.state.gold<(d.cost.gold or 0) then return false,"Premalo zlata" end; if _G.state.resources then for r,a in pairs(d.cost) do if r~="gold" and (_G.state.resources[r] or 0)<a then return false,"Premalo "..r end end end; return true end
function Armorer.build(id) local ok,e=Armorer.canBuild(id); if not ok then return false,e end; local d=BUILDINGS[id]; _G.state.gold=_G.state.gold-(d.cost.gold or 0); if _G.state.resources then for r,a in pairs(d.cost) do if r~="gold" then _G.state.resources[r]=(_G.state.resources[r] or 0)-a end end end; table.insert(Armorer.buildings,{type=id,builtDay=os.time()}); if _G.NotificationCenter then pcall(_G.NotificationCenter.notify,"Zgrajeno: "..d.name,"success") end; return true end
function Armorer.getQualityBonus() local b=0; for _,bd in ipairs(Armorer.buildings) do local d=BUILDINGS[bd.type]; if d and d.qualityBonus then b=b+d.qualityBonus end end; return b end
function Armorer.purchaseMetal(t,q) local d=METALS[t]; if not d then return false,"Neznana kovina" end; q=q or 1; local c=d.cost*q; if not _G.state or (_G.state.gold or 0)<c then return false,"Premalo zlata" end; _G.state.gold=_G.state.gold-c; Armorer.metalStock[t]=(Armorer.metalStock[t] or 0)+q; return true end
function Armorer.canForge(at,mt) local aD=ARMOR[at]; local mD=METALS[mt]; if not aD or not mD then return false,"Neznan oklep ali kovina" end; if (Armorer.metalStock[mt] or 0)<aD.metalCost then return false,"Premalo kovine" end; if #Armorer.buildings==0 then return false,"Potrebna okleparna" end; if not Armorer.armorer then return false,"Potreben oklepar" end; return true end
function Armorer.forge(at,mt) local ok,e=Armorer.canForge(at,mt); if not ok then return false,e end; local aD=ARMOR[at]; local mD=METALS[mt]; Armorer.metalStock[mt]=Armorer.metalStock[mt]-aD.metalCost; local t=aD.time; if Armorer.armorer then t=math.max(1,t-math.floor(Armorer.armorer.skill/8)) end; table.insert(Armorer.activeForging,{id="armor_"..tostring(os.time()).."_"..tostring(math.random(1000,9999)),armorType=at,armorName=aD.name,metalType=mt,metalName=mD.name,defense=aD.defense,cost=aD.cost,metalQuality=mD.defenseBonus,metalPrestige=mD.prestige or 0,metalFaith=mD.faith or 0,armorPrestige=aD.prestige or 0,daysRemaining=t,started=os.time()}); if _G.NotificationCenter then pcall(_G.NotificationCenter.notify,string.format("Kovanje oklepa: %s iz %s (%d dni)",aD.name,mD.name,t),"info") end; return true end
function Armorer.completeForging(f) local q=1.0+(Armorer.getQualityBonus()/100)+(f.metalQuality/100); if Armorer.armorer then q=q+(Armorer.armorer.skill/200) end; q=math.min(2.5,q); Armorer.armorStock[f.armorType]=Armorer.armorStock[f.armorType] or {}; table.insert(Armorer.armorStock[f.armorType],{id=f.id,metal=f.metalName,quality=q,defense=math.floor(f.defense*q),value=math.floor(f.cost*q*(1+(f.metalPrestige/20))),prestige=f.metalPrestige+f.armorPrestige,faith=f.metalFaith,forgedDay=os.time()}); Armorer.totalArmor=Armorer.totalArmor+1; if Armorer.armorer then Armorer.armorer.itemsMade=Armorer.armorer.itemsMade+1; if math.random()<0.15 then Armorer.armorer.skill=math.min(100,Armorer.armorer.skill+1) end end; if _G.NotificationCenter then pcall(_G.NotificationCenter.notify,string.format("Oklep skovan: %s %s (kakovost: %.1f)",f.metalName,f.armorName,q),"success") end end
function Armorer.sellArmor(at,i) if not Armorer.armorStock[at] or not Armorer.armorStock[at][i] then return false,"Oklep ne obstaja" end; local a=table.remove(Armorer.armorStock[at],i); if _G.state then _G.state.gold=(_G.state.gold or 0)+a.value end; if _G.NotificationCenter then pcall(_G.NotificationCenter.notify,string.format("Oklep prodan: %s za %d zlata",at,a.value),"success") end; return true end
function Armorer.update(dt) if not _G.state then return end; Armorer.dayTimer=Armorer.dayTimer+dt; if Armorer.dayTimer>=30 then Armorer.dayTimer=0; for i=#Armorer.activeForging,1,-1 do local f=Armorer.activeForging[i]; f.daysRemaining=f.daysRemaining-1; if f.daysRemaining<=0 then Armorer.completeForging(f); table.remove(Armorer.activeForging,i) end end; local tu=0; for _,bd in ipairs(Armorer.buildings) do local d=BUILDINGS[bd.type]; if d and d.upkeep then tu=tu+d.upkeep end end; if Armorer.armorer then tu=tu+25 end; if tu>0 and _G.state then _G.state.gold=math.max(0,(_G.state.gold or 0)-tu) end end end
function Armorer.getStats() local ta=0; for _,a in pairs(Armorer.armorStock) do ta=ta+#a end; return {numArmor=ta,metalStock=Armorer.metalStock,numBuildings=#Armorer.buildings,hasArmorer=Armorer.armorer~=nil,armorerName=Armorer.armorer and Armorer.armorer.name or "—",armorerSkill=Armorer.armorer and Armorer.armorer.skill or 0,activeForging=#Armorer.activeForging,totalArmor=Armorer.totalArmor} end
return Armorer
