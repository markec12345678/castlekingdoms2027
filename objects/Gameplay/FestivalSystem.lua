-- objects/Gameplay/FestivalSystem.lua
-- Stronghold 2027 - Festivals boost morale

local FestivalSystem = {}

local FESTIVAL_TYPES = {
    tournament = { name="Turnir", desc="Viteshki turnir povechuje moralo.", dur=120, popBoost=10, cost={gold=200} },
    feast = { name="Gostija", desc="Velika gostija povechuje popularnost.", dur=90, popBoost=15, cost={gold=150, food=50} },
    maypole = { name="Plesi", desc="Tradicionalni plesi povechujejo srecho.", dur=60, popBoost=8, cost={gold=50, wood=20} },
    fair = { name="Sejem", desc="Trgovski sejem povechuje prihodke.", dur=150, popBoost=5, cost={gold=100} },
    religious = { name="Verski praznik", desc="Verski praznik povechuje popularnost.", dur=120, popBoost=12, cost={gold=100, food=30} },
    -- Stronghold 2027 v2.5.6: 3 new festivals
    harvest = { name="Praznik letine", desc="Praznik letine povečuje pridelke in moralo.", dur=100, popBoost=10, cost={gold=80, food=40}, productionBoost={food=1.5} },
    joust = { name="Tournamentska igra", desc="Velika viteška turnirska igra povečuje popularnost.", dur=180, popBoost=20, cost={gold=300, wood=50} },
    coronation = { name="Kronanje", desc="Kraljevo kronanje povečuje popularnost vseh subjektov.", dur=300, popBoost=35, cost={gold=500, stone=100, food=100} },
}

FestivalSystem.FESTIVAL_TYPES = FESTIVAL_TYPES
local activeFestivals = {}
local initialized = false

function FestivalSystem.init()
    if initialized then return end
    initialized = true
    print("[FestivalSystem] Initialized")
end

function FestivalSystem.start(ftype)
    if not initialized then FestivalSystem.init() end
    local def = FESTIVAL_TYPES[ftype]
    if not def then return false end
    
    if _G.state then
        for res, amt in pairs(def.cost) do
            if res == "gold" then
                if (_G.state.gold or 0) < amt then return false end
            elseif _G.state.resources then
                if (_G.state.resources[res] or 0) < amt then return false end
            end
        end
        for res, amt in pairs(def.cost) do
            if res == "gold" then _G.state.gold = _G.state.gold - amt
            elseif _G.state.resources then _G.state.resources[res] = _G.state.resources[res] - amt end
        end
        if def.popBoost then _G.state.popularity = (_G.state.popularity or 0) + def.popBoost end
    end
    
    table.insert(activeFestivals, { type=ftype, def=def, timeRemaining=def.dur })
    if _G.GameEventBus then _G.GameEventBus.emit("festival_started", {type=ftype, name=def.name}) end
    if _G.VoiceOver then _G.VoiceOver.notify("festival_started", def.name) end
    print("[FestivalSystem] Started: " .. def.name)
    return true
end

function FestivalSystem.update(dt)
    if not initialized then return end
    for i = #activeFestivals, 1, -1 do
        local f = activeFestivals[i]
        f.timeRemaining = f.timeRemaining - dt
        if f.timeRemaining <= 0 then
            if _G.GameEventBus then _G.GameEventBus.emit("festival_ended", {type=f.type}) end
            if _G.VoiceOver then _G.VoiceOver.notify("festival_ended", f.def.name) end
            print("[FestivalSystem] Ended: " .. f.def.name)
            table.remove(activeFestivals, i)
        end
    end
end

function FestivalSystem.getActiveFestivals() return activeFestivals end

function FestivalSystem.getStats()
    return { activeCount = #activeFestivals, festivals = activeFestivals }
end

return FestivalSystem
