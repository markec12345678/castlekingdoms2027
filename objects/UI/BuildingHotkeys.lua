-- objects/UI/BuildingHotkeys.lua
-- Castle Kingdoms 2027 - Building Hotkeys
-- Quick build with number keys (Ctrl+1-9 for common buildings)

local BuildingHotkeys = {}

local HOTKEYS = {
    ["ctrl+1"] = { building = "Stockpile",   name = "Skladišče" },
    ["ctrl+2"] = { building = "Granary",     name = "Kašča" },
    ["ctrl+3"] = { building = "Woodcutter",  name = "Drvar" },
    ["ctrl+4"] = { building = "Quarry",      name = "Kamenolom" },
    ["ctrl+5"] = { building = "WheatFarm",   name = "Kmetija" },
    ["ctrl+6"] = { building = "Barracks",    name = "Barake" },
    ["ctrl+7"] = { building = "Market",      name = "Tržnica" },
    ["ctrl+8"] = { building = "Armoury",     name = "Orožarna" },
    ["ctrl+9"] = { building = "Inn",         name = "Krčma" },
}

local initialized = false

function BuildingHotkeys.init()
    if initialized then return end
    initialized = true
    print("[BuildingHotkeys] Initialized with " .. #BuildingHotkeys._getCount() .. " hotkeys")
end

function BuildingHotkeys._getCount()
    local c = 0
    for _ in pairs(HOTKEYS) do c = c + 1 end
    return c
end

function BuildingHotkeys.handleKey(key, ctrl)
    if not initialized then return false end
    if not ctrl then return false end

    local hotkey = "ctrl+" .. key
    local entry = HOTKEYS[hotkey]
    if not entry then return false end

    -- Trigger build
    if _G.BuildController and _G.BuildController.set then
        pcall(function()
            _G.BuildController:set(entry.building, function()
                if _G.ActionBar then
                    _G.ActionBar:unselectAll()
                end
            end)
        end)

        if _G.ModernUI then
            _G.ModernUI.notifyInfo("Gradnja: " .. entry.name)
        end

        if _G.VoiceOver then
            _G.VoiceOver.notify("building_selected", entry.name)
        end

        return true
    end

    return false
end

function BuildingHotkeys.getHotkeys()
    local list = {}
    for key, entry in pairs(HOTKEYS) do
        table.insert(list, {
            hotkey = key,
            building = entry.building,
            name = entry.name,
        })
    end
    table.sort(list, function(a, b) return a.hotkey < b.hotkey end)
    return list
end

function BuildingHotkeys.setHotkey(keyCombo, building, name)
    HOTKEYS[keyCombo] = { building = building, name = name or building }
    print("[BuildingHotkeys] Set: " .. keyCombo .. " -> " .. building)
end

return BuildingHotkeys
