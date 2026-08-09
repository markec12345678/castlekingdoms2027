# HANDOFF DOKUMENT — Castle Kingdoms 2027

## TRENUTNO STANJE
- Različica: **v3.11.381**
- Skupaj Royal sistemov: **469**
- Skupaj Lua datotek: **1118**
- Sintaktična preverba: **1115/1118 pass** (3 znani false positives: moonscript.lua, test.lua, grid.lua)
- GitHub: sinhroniziran (vsi tagi pushani)
- Lokalni repo: `/home/z/my-project/s2027`
- .love datoteke: `/home/z/my-project/download/`

## NASLEDNJI PAKET (v3.11.382–v3.11.386) — RUDARSKA ORODJA

Ustvari 5 novih sistemov v `/home/z/my-project/s2027/objects/Economy/`:

1. **RoyalPickaxeMakerSystem.lua** → `local PickaxeMaker` (kiji/krampi)
2. **RoyalShovelMakerSystem.lua** → `local ShovelMaker` (lopate)
3. **RoyalAugerMakerSystem.lua** → `local AugerMaker` (svedri za vrtanje)
4. **RoyalMiningChiselMakerSystem.lua** → `local MiningChiselMaker` (dleta za rudarjenje)
5. **RoyalProspectingPanMakerSystem.lua** → `local ProspectingPanMaker` (porabniki za iskanje zlata)

## PATTERN ZA VSAK SISTEM

Vsak sistem mora imeti:
- 6 produktov (železni → bronasti → srebrni → pozlačeni → draguljasti → kraljevski suvereni)
- 4 zgradbe (delavnica, hiša, mojstrski atelje, suverena palača)
- Funkcije: `init`, `hireMaker`, `canBuild`, `build`, `getQualityBonus`, `canMake`, `make`, `completeMaking`, `update`, `getStats`
- `_G.NotificationCenter.notify` in `_G.GameEventBus.publish` s pcall
- Vrača lokalno tabelo
- Slovenian product/building names

## REGISTRACIJA V states/game.lua

3 točke za vsak sistem (najdi zadnji `S.AngelusBellMaker` in dodaj za njim):

```lua
-- require block (po S.AngelusBellMaker = require(...))
S.PickaxeMaker = require("objects.Economy.RoyalPickaxeMakerSystem")
S.ShovelMaker = require("objects.Economy.RoyalShovelMakerSystem")
S.AugerMaker = require("objects.Economy.RoyalAugerMakerSystem")
S.MiningChiselMaker = require("objects.Economy.RoyalMiningChiselMakerSystem")
S.ProspectingPanMaker = require("objects.Economy.RoyalProspectingPanMakerSystem")

-- init block (po S.AngelusBellMaker.init(); ...)
S.PickaxeMaker.init(); _G.PickaxeMaker = S.PickaxeMaker
S.ShovelMaker.init(); _G.ShovelMaker = S.ShovelMaker
S.AugerMaker.init(); _G.AugerMaker = S.AugerMaker
S.MiningChiselMaker.init(); _G.MiningChiselMaker = S.MiningChiselMaker
S.ProspectingPanMaker.init(); _G.ProspectingPanMaker = S.ProspectingPanMaker

-- update block (po S.AngelusBellMaker.update(dt))
S.PickaxeMaker.update(dt)
S.ShovelMaker.update(dt)
S.AugerMaker.update(dt)
S.MiningChiselMaker.update(dt)
S.ProspectingPanMaker.update(dt)
```

## WORKFLOW

1. Preveri duplikate: `ls objects/Economy/ | grep -iE "pickaxe|shovel|auger|chisel"` (mora biti prazno)
2. Ustvari 5 .lua datotek (glej template spodaj)
3. Registriraj v states/game.lua (3 točke)
4. Poženi: `python3 /home/z/my-project/scripts/lua_syntax_check.py` (pričakuj 1120/1123 pass)
5. Posodobi CHANGELOG.md (dodaj vnose za v3.11.382 do v3.11.386 na vrh)
6. Posodobi README.md badge-je:
   - version-3.11.381 → version-3.11.386
   - syntax-1115%2F1118 → syntax-1120%2F1123
   - Royal%20systems-469 → Royal%20systems-474
   - Lua%20files-1118 → Lua%20files-1123
7. Git: commit, tag (v3.11.382 do v3.11.386), push
8. Build .love: `zip -r -q /home/z/my-project/download/castlekingdoms2027-v3.11.386.love . -x ".git/*" "tool-results/*" "*.love" ".gitignore" "scripts/lua_syntax_check.py"`

## TEMPLATE ZA SISTEM (primer PickaxeMaker)

```lua
local PickaxeMaker = {}
local PRODUCTS = {
    iron_pickaxe = { name = "Železno kramp", ironCost = 2, woodCost = 2, leatherCost = 1, time = 5, cost = 130, prestige = 2, happiness = 1, description = "Železno kramp za rudarjenje." },
    bronze_pickaxe = { name = "Bronast kramp", bronzeCost = 2, ironCost = 1, woodCost = 2, leatherCost = 1, time = 7, cost = 320, prestige = 4, happiness = 2, description = "Bronast kramp za trdovratno kamnino." },
    silver_pickaxe = { name = "Srebrni kramp", silverCost = 2, bronzeCost = 1, ironCost = 1, woodCost = 2, leatherCost = 1, time = 11, cost = 780, prestige = 9, happiness = 3, description = "Srebrni kramp za plemiče." },
    gilded_pickaxe = { name = "Pozlačeni kramp", goldCost = 1, silverCost = 2, bronzeCost = 1, woodCost = 2, leatherCost = 1, time = 15, cost = 1700, prestige = 18, happiness = 4, description = "Pozlačeni kramp za dvorne rudnike." },
    jewel_set_pickaxe = { name = "Draguljasti kramp", goldCost = 2, silverCost = 2, jewelCost = 1, bronzeCost = 1, woodCost = 2, leatherCost = 1, time = 19, cost = 3700, prestige = 33, happiness = 6, description = "Draguljasti kramp za kraljeve rudnike." },
    royal_sovereign_pickaxe = { name = "Kraljevski suvereni kramp", goldCost = 3, silverCost = 3, jewelCost = 2, pearlCost = 2, bronzeCost = 1, woodCost = 3, leatherCost = 1, time = 26, cost = 8000, prestige = 65, happiness = 12, description = "Suvereni kramp z biseri za krono." },
}
local BUILDINGS = {
    pickaxe_workshop = { name = "Rudarska delavnica", cost = { gold = 300, wood = 160, stone = 120, iron = 6 }, upkeep = 6, qualityBonus = 5 },
    mining_house = { name = "Rudarska hiša", cost = { gold = 1100, wood = 320, stone = 240, silver = 6, iron = 6 }, upkeep = 24, qualityBonus = 18 },
    master_pickaxe_atelier = { name = "Mojstrski rudarski atelje", cost = { gold = 2900, wood = 380, stone = 480, silver = 32, gold = 6 }, upkeep = 68, qualityBonus = 30 },
    sovereign_mining_palace = { name = "Suverena rudarska palača", cost = { gold = 12500, wood = 600, stone = 800, gold = 80, jewel = 18 }, upkeep = 245, qualityBonus = 55, prestigeBonus = 50 },
}
PickaxeMaker.ironStock = 12; PickaxeMaker.bronzeStock = 10; PickaxeMaker.woodStock = 14; PickaxeMaker.leatherStock = 10; PickaxeMaker.silverStock = 8; PickaxeMaker.goldStock = 6; PickaxeMaker.jewelStock = 4; PickaxeMaker.pearlStock = 4
PickaxeMaker.productStock = {}; PickaxeMaker.buildings = {}; PickaxeMaker.maker = nil; PickaxeMaker.activeMaking = {}; PickaxeMaker.totalProducts = 0; PickaxeMaker.dayTimer = 0
function PickaxeMaker.init() PickaxeMaker.ironStock=12; PickaxeMaker.bronzeStock=10; PickaxeMaker.woodStock=14; PickaxeMaker.leatherStock=10; PickaxeMaker.silverStock=8; PickaxeMaker.goldStock=6; PickaxeMaker.jewelStock=4; PickaxeMaker.pearlStock=4; PickaxeMaker.productStock={}; PickaxeMaker.buildings={}; PickaxeMaker.maker=nil; PickaxeMaker.activeMaking={}; PickaxeMaker.totalProducts=0; PickaxeMaker.dayTimer=0; print("[PickaxeMaker] Royal Pickaxe Maker System initialized (6 products, 4 buildings)") end
function PickaxeMaker.hireMaker(n,s) s=s or math.random(55,90); local c=580+s*12; if not _G.state or (_G.state.gold or 0)<c then return false,"Premalo zlata" end; _G.state.gold=_G.state.gold-c; PickaxeMaker.maker={name=n or ("Krampar "..math.random(1,99)),skill=s,hiredDay=os.time(),itemsMade=0}; if _G.NotificationCenter then pcall(_G.NotificationCenter.notify,string.format("Krampar najet: %s (spretnost: %d)",PickaxeMaker.maker.name,s),"success") end; return true end
function PickaxeMaker.canBuild(id) local d=BUILDINGS[id]; if not d then return false,"Neznana zgradba" end; if not _G.state then return false,"Brez stanja" end; if _G.state.gold<(d.cost.gold or 0) then return false,"Premalo zlata" end; if _G.state.resources then for r,a in pairs(d.cost) do if r~="gold" and (_G.state.resources[r] or 0)<a then return false,"Premalo "..r end end end; return true end
function PickaxeMaker.build(id) local ok,e=PickaxeMaker.canBuild(id); if not ok then return false,e end; local d=BUILDINGS[id]; _G.state.gold=_G.state.gold-(d.cost.gold or 0); if _G.state.resources then for r,a in pairs(d.cost) do if r~="gold" then _G.state.resources[r]=(_G.state.resources[r] or 0)-a end end end; table.insert(PickaxeMaker.buildings,{type=id,builtDay=os.time()}); if _G.NotificationCenter then pcall(_G.NotificationCenter.notify,"Zgrajeno: "..d.name,"success") end; return true end
function PickaxeMaker.getQualityBonus() local b=0; for _,bd in ipairs(PickaxeMaker.buildings) do local d=BUILDINGS[bd.type]; if d and d.qualityBonus then b=b+d.qualityBonus end end; return b end
function PickaxeMaker.canMake(pt) local d=PRODUCTS[pt]; if not d then return false,"Neznan produkt" end; if d.ironCost and PickaxeMaker.ironStock<(d.ironCost or 0) then return false,"Premalo železa" end; if d.bronzeCost and PickaxeMaker.bronzeStock<(d.bronzeCost or 0) then return false,"Premalo brona" end; if d.woodCost and PickaxeMaker.woodStock<(d.woodCost or 0) then return false,"Premalo lesa" end; if d.leatherCost and PickaxeMaker.leatherStock<(d.leatherCost or 0) then return false,"Premalo usnja" end; if d.silverCost and PickaxeMaker.silverStock<(d.silverCost or 0) then return false,"Premalo srebra" end; if d.goldCost and PickaxeMaker.goldStock<(d.goldCost or 0) then return false,"Premalo zlata" end; if d.jewelCost and PickaxeMaker.jewelStock<(d.jewelCost or 0) then return false,"Premalo draguljev" end; if d.pearlCost and PickaxeMaker.pearlStock<(d.pearlCost or 0) then return false,"Premalo biserov" end; if #PickaxeMaker.buildings==0 then return false,"Potrebna rudarska delavnica" end; if not PickaxeMaker.maker then return false,"Potreben krampar" end; return true end
function PickaxeMaker.make(pt,qty) qty=qty or 1; local ok,e=PickaxeMaker.canMake(pt); if not ok then return false,e end; local d=PRODUCTS[pt]; if d.ironCost then PickaxeMaker.ironStock=PickaxeMaker.ironStock-d.ironCost*qty end; if d.bronzeCost then PickaxeMaker.bronzeStock=PickaxeMaker.bronzeStock-d.bronzeCost*qty end; if d.woodCost then PickaxeMaker.woodStock=PickaxeMaker.woodStock-d.woodCost*qty end; if d.leatherCost then PickaxeMaker.leatherStock=PickaxeMaker.leatherStock-d.leatherCost*qty end; if d.silverCost then PickaxeMaker.silverStock=PickaxeMaker.silverStock-d.silverCost*qty end; if d.goldCost then PickaxeMaker.goldStock=PickaxeMaker.goldStock-d.goldCost*qty end; if d.jewelCost then PickaxeMaker.jewelStock=PickaxeMaker.jewelStock-d.jewelCost*qty end; if d.pearlCost then PickaxeMaker.pearlStock=PickaxeMaker.pearlStock-d.pearlCost*qty end; local t=d.time; if PickaxeMaker.maker then t=math.max(1,t-math.floor(PickaxeMaker.maker.skill/13)) end; table.insert(PickaxeMaker.activeMaking,{id="pickaxe_"..tostring(os.time()).."_"..tostring(math.random(1000,9999)),productType=pt,productName=d.name,cost=d.cost*qty,quantity=qty,food=0,prestige=d.prestige or 0,happiness=d.happiness or 0,daysRemaining=t,started=os.time()}); if _G.NotificationCenter then pcall(_G.NotificationCenter.notify,string.format("Izdelava: %d %s (%d dni)",qty,d.name,t),"info") end; return true end
function PickaxeMaker.completeMaking(m) local q=1.0+(PickaxeMaker.getQualityBonus()/100); if PickaxeMaker.maker then q=q+(PickaxeMaker.maker.skill/140) end; q=math.min(2.5,q); PickaxeMaker.productStock[m.productType]=(PickaxeMaker.productStock[m.productType] or 0)+m.quantity; PickaxeMaker.totalProducts=PickaxeMaker.totalProducts+m.quantity; if m.prestige>0 and _G.state and _G.state.happiness then _G.state.happiness=math.min(100,_G.state.happiness+m.prestige) end; if m.happiness>0 and _G.state and _G.state.happiness then _G.state.happiness=math.min(100,_G.state.happiness+m.happiness) end; if PickaxeMaker.maker then PickaxeMaker.maker.itemsMade=PickaxeMaker.maker.itemsMade+m.quantity; if math.random()<0.25 then PickaxeMaker.maker.skill=math.min(100,PickaxeMaker.maker.skill+1) end end; if _G.NotificationCenter then pcall(_G.NotificationCenter.notify,string.format("Kramp izdelan: %d %s (kakovost: %.1f)",m.quantity,m.productName,q),"success") end; if _G.GameEventBus then pcall(_G.GameEventBus.publish,"pickaxe.completed",{productName=m.productName,prestige=m.prestige,happiness=m.happiness}) end end
function PickaxeMaker.update(dt) if not _G.state then return end; PickaxeMaker.dayTimer=PickaxeMaker.dayTimer+dt; if PickaxeMaker.dayTimer>=30 then PickaxeMaker.dayTimer=0; for i=#PickaxeMaker.activeMaking,1,-1 do local m=PickaxeMaker.activeMaking[i]; m.daysRemaining=m.daysRemaining-1; if m.daysRemaining<=0 then PickaxeMaker.completeMaking(m); table.remove(PickaxeMaker.activeMaking,i) end end; local tu=0; for _,bd in ipairs(PickaxeMaker.buildings) do local d=BUILDINGS[bd.type]; if d and d.upkeep then tu=tu+d.upkeep end end; if PickaxeMaker.maker then tu=tu+15 end; if tu>0 and _G.state then _G.state.gold=math.max(0,(_G.state.gold or 0)-tu) end end end
function PickaxeMaker.getStats() return {ironStock=PickaxeMaker.ironStock,bronzeStock=PickaxeMaker.bronzeStock,woodStock=PickaxeMaker.woodStock,leatherStock=PickaxeMaker.leatherStock,silverStock=PickaxeMaker.silverStock,goldStock=PickaxeMaker.goldStock,jewelStock=PickaxeMaker.jewelStock,pearlStock=PickaxeMaker.pearlStock,productStock=PickaxeMaker.productStock,numBuildings=#PickaxeMaker.buildings,hasMaker=PickaxeMaker.maker~=nil,makerName=PickaxeMaker.maker and PickaxeMaker.maker.name or "—",makerSkill=PickaxeMaker.maker and PickaxeMaker.maker.skill or 0,activeMaking=#PickaxeMaker.activeMaking,totalProducts=PickaxeMaker.totalProducts} end
return PickaxeMaker
```

Za preostale 4 sisteme (ShovelMaker, AugerMaker, MiningChiselMaker, ProspectingPanMaker) uporabi enak vzorec, samo spremeni:
- Imena produktov (npr. "železna lopata", "železni sveder", "železno dleto", "železni porabnik")
- Imena zgradb (lopatarska, vrtalna, dletarska, prospekcijska)
- Maker ime (Lopatar, Svedrar, Dletar, Prospektor)
- Event bus publish (shovel.completed, auger.completed, chisel.completed, pan.completed)

## SPOROČILO ZA NOVO SEJO

Ko začneš novo sejo, pošlji to sporočilo:

```
Nadaljuj z razvojem Castle Kingdoms 2027. Preberi /home/z/my-project/s2027/NEXT_BATCH_HANDOFF.md za popolna navodila. Trenutna različica je v3.11.381. Naslednji paket je v3.11.382–v3.11.386 (rudarska orodja: PickaxeMaker, ShovelMaker, AugerMaker, MiningChiselMaker, ProspectingPanMaker). Sledi navodilom v handoff dokumentu. Po končanem paketu ročno posodobi NEXT_BATCH_HANDOFF.md z naslednjim paketom (v3.11.387–v3.11.391 — predlagano: lekarniška posoda: MortarPestleMaker, ApothecaryVialMaker, SalveJarMaker, SurgicalLancetMaker, PhysicPotionMaker).
```

## NASLEDNJI PAKETI (po vrsti)

- v3.11.387–v3.11.391: lekarniška posoda (MortarPestleMaker, ApothecaryVialMaker, SalveJarMaker, SurgicalLancetMaker, PhysicPotionMaker)
- v3.11.392–v3.11.396: vrtnarska oprema (PruningShearsMaker, TopiaryFrameMaker, GardenTrowelMaker, HedgeHookMaker, WateringCanMaker)
- v3.11.397–v3.11.401: jermenska oprema (SaddleMaker, BridleMaker, StirrupMaker, HorseHarnessMaker, SaddlebagMaker)
- v3.11.402–v3.11.406: slikarska oprema (EaselMaker, PaintbrushMaker, PaletteMaker, PigmentGrinderMaker, CanvasStretcherMaker)
