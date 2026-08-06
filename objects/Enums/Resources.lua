---@enum resource
local RESOURCES = {
    -- Original resources
    wood = "wood",
    stone = "stone",
    wheat = "wheat",
    iron = "iron",
    flour = "flour",
    hop = "hop",
    tar = "tar",
    ale = "ale",
    -- Stronghold 2027 v2.7.1: New resource types
    pitch = "pitch",        -- used for fire weapons
    leather = "leather",    -- used for light armor
    silk = "silk",          -- luxury trade good
    spices = "spices",      -- luxury trade good
    wine = "wine",          -- luxury beverage
    wool = "wool",          -- raw material for clothing
    coal = "coal",          -- fuel for advanced production
    gold = "gold",          -- currency (also tracked in _G.state.gold)
    food = "food",          -- aggregated food (bread, meat, etc.)
}

return RESOURCES
