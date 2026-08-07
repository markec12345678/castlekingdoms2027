-- objects/Combat/UnitFormationSystem.lua
-- Castle Kingdoms 2027 - Unit Formation System
-- Battle formations: line, column, wedge, scatter, box

local FormationSystem = {}

local FORMATIONS = {
    line = {
        name = "Vrsta",
        description = "Široka formacija, dobra za obrambo.",
        spacing = 1.5,
        layout = function(count)
            local positions = {}
            local width = math.ceil(math.sqrt(count))
            for i = 1, count do
                local row = math.floor((i-1) / width)
                local col = (i-1) % width - (width-1)/2
                positions[i] = { x = col * 1.5, y = row * 1.5 }
            end
            return positions
        end,
        defenseBonus = 1.2,
        attackBonus = 1.0,
        speedBonus = 1.0,
    },
    column = {
        name = "Stolpec",
        description = "Ozalka formacija, hitra za premikanje.",
        spacing = 1.0,
        layout = function(count)
            local positions = {}
            local depth = math.max(2, math.ceil(count / 4))
            for i = 1, count do
                local row = math.floor((i-1) / 4)
                local col = (i-1) % 4 - 1.5
                positions[i] = { x = col * 1.0, y = row * 1.0 }
            end
            return positions
        end,
        defenseBonus = 0.9,
        attackBonus = 1.0,
        speedBonus = 1.3,
    },
    wedge = {
        name = "Klin",
        description = "V-formacija, dobra za napad.",
        spacing = 1.2,
        layout = function(count)
            local positions = {}
            local placed = 0
            local row = 0
            while placed < count do
                local width = row + 1
                for col = 0, width - 1 do
                    if placed >= count then break end
                    local x = (col - (width-1)/2) * 1.2
                    local y = row * 1.2
                    placed = placed + 1
                    positions[placed] = { x = x, y = y }
                end
                row = row + 1
            end
            return positions
        end,
        defenseBonus = 0.8,
        attackBonus = 1.3,
        speedBonus = 1.1,
    },
    scatter = {
        name = "Razpršeno",
        description = "Razpršena formacija, dobra proti lokostrelcem.",
        spacing = 3.0,
        layout = function(count)
            local positions = {}
            for i = 1, count do
                local angle = (i / count) * math.pi * 2
                local radius = 1 + (i % 3) * 0.5
                positions[i] = { x = math.cos(angle) * radius * 2, y = math.sin(angle) * radius * 2 }
            end
            return positions
        end,
        defenseBonus = 1.5, -- Hard to hit with arrows
        attackBonus = 0.8,
        speedBonus = 1.2,
    },
    box = {
        name = "Kvadrat",
        description = "Kvadratna formacija, odlična obramba.",
        spacing = 1.0,
        layout = function(count)
            local positions = {}
            local side = math.ceil(math.sqrt(count))
            local half = (side - 1) / 2
            for i = 1, count do
                local row = math.floor((i-1) / side)
                local col = (i-1) % side
                positions[i] = { x = (col - half) * 1.0, y = (row - half) * 1.0 }
            end
            return positions
        end,
        defenseBonus = 1.4,
        attackBonus = 0.9,
        speedBonus = 0.8,
    },
    -- Castle Kingdoms 2027 v2.6.1: 2 new formations
    phalanx = {
        name = "Falanga",
        description = "Gosta kopjaška formacija. Maksimalna obramba, počasna.",
        spacing = 0.7,
        layout = function(count)
            local positions = {}
            local ranks = math.max(2, math.ceil(count / 6))
            for i = 1, count do
                local rank = math.floor((i-1) / 6)
                local file = (i-1) % 6
                positions[i] = { x = (file - 2.5) * 0.7, y = rank * 0.5 }
            end
            return positions
        end,
        defenseBonus = 1.6,
        attackBonus = 1.1,
        speedBonus = 0.6,
    },
    skirmish = {
        name = "Razpršena",
        description = "Razpršena formacija. Hitra, odlična za lokostrelce.",
        spacing = 1.8,
        layout = function(count)
            local positions = {}
            for i = 1, count do
                local angle = (i / count) * math.pi * 2
                local radius = 1.5 + (i % 3) * 0.5
                positions[i] = { x = math.cos(angle) * radius, y = math.sin(angle) * radius }
            end
            return positions
        end,
        defenseBonus = 0.8,
        attackBonus = 1.2,
        speedBonus = 1.3,
    },
}

FormationSystem.FORMATIONS = FORMATIONS

local currentFormation = "line"
local initialized = false

function FormationSystem.init()
    if initialized then return end
    initialized = true
    print("[FormationSystem] Initialized with " .. FormationSystem._getCount() .. " formations")
end

function FormationSystem._getCount()
    local c = 0
    for _ in pairs(FORMATIONS) do c = c + 1 end
    return c
end

function FormationSystem.setFormation(formationName)
    if not FORMATIONS[formationName] then
        print("[FormationSystem] Unknown formation: " .. tostring(formationName))
        return false
    end
    local old = currentFormation
    currentFormation = formationName
    if _G.GameEventBus then
        _G.GameEventBus.emit("formation_changed", {old = old, new = formationName})
    end
    if _G.VoiceOver then
        _G.VoiceOver.notify("formation_" .. formationName, FORMATIONS[formationName].name)
    end
    print("[FormationSystem] " .. old .. " -> " .. formationName .. " (" .. FORMATIONS[formationName].name .. ")")
    return true
end

function FormationSystem.getFormation()
    return currentFormation
end

function FormationSystem.getFormationInfo(name)
    return FORMATIONS[name or currentFormation]
end

function FormationSystem.getAllFormations()
    local list = {}
    for name, f in pairs(FORMATIONS) do
        table.insert(list, { name = name, displayName = f.name, description = f.description })
    end
    return list
end

-- Calculate positions for units in formation
-- @param centerX number Center X (grid)
-- @param centerY number Center Y (grid)
-- @param unitCount number Number of units
-- @return table Array of {x, y} positions
function FormationSystem.calculatePositions(centerX, centerY, unitCount)
    local formation = FORMATIONS[currentFormation]
    if not formation then return {} end

    local offsets = formation.layout(unitCount)
    local positions = {}

    for i, offset in ipairs(offsets) do
        positions[i] = {
            x = centerX + offset.x,
            y = centerY + offset.y,
        }
    end

    return positions
end

-- Apply formation bonuses to a unit
function FormationSystem.getDefenseBonus()
    local f = FORMATIONS[currentFormation]
    return f and f.defenseBonus or 1.0
end

function FormationSystem.getAttackBonus()
    local f = FORMATIONS[currentFormation]
    return f and f.attackBonus or 1.0
end

function FormationSystem.getSpeedBonus()
    local f = FORMATIONS[currentFormation]
    return f and f.speedBonus or 1.0
end

-- Cycle through formations
function FormationSystem.cycleFormation()
    -- Castle Kingdoms 2027 v2.6.1: Added phalanx and skirmish to cycle
    local order = {"line", "column", "wedge", "scatter", "box", "phalanx", "skirmish"}
    local idx = 1
    for i, f in ipairs(order) do
        if f == currentFormation then idx = i break end
    end
    local next = order[(idx % #order) + 1]
    FormationSystem.setFormation(next)
    return next
end

-- Get stats
function FormationSystem.getStats()
    local f = FORMATIONS[currentFormation]
    return {
        current = currentFormation,
        name = f and f.name or "Unknown",
        defenseBonus = f and f.defenseBonus or 1.0,
        attackBonus = f and f.attackBonus or 1.0,
        speedBonus = f and f.speedBonus or 1.0,
    }
end

return FormationSystem
