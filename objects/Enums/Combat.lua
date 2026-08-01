-- objects/Enums/Combat.lua
-- Stronghold 2027 - Combat Enums
-- Defines combat-related constants and types

---@enum combat_state
local COMBAT = {
    -- Combat states for units
    STATE_IDLE = "idle",
    STATE_AGGRO = "aggro",          -- Unit has detected an enemy
    STATE_SEEKING = "seeking",      -- Moving toward enemy
    STATE_ATTACKING = "attacking",  -- In attack range
    STATE_RETREATING = "retreating",
    STATE_DEAD = "dead",

    -- Attack types
    ATTACK_MELEE = "melee",
    ATTACK_RANGED = "ranged",
    ATTACK_SIEGE = "siege",

    -- Damage types
    DAMAGE_PHYSICAL = "physical",     -- Swords, maces, arrows
    DAMAGE_PIERCING = "piercing",     -- Spears, pikes, crossbows
    DAMAGE_BLUNT = "blunt",           -- Maces, catapult rocks
    DAMAGE_FIRE = "fire",             -- Pitch, molotovs

    -- Faction identifiers
    FACTION_PLAYER = 1,
    FACTION_ENEMY_1 = 2,
    FACTION_ENEMY_2 = 3,
    FACTION_ENEMY_3 = 4,
    FACTION_NEUTRAL = 5,  -- Animals (deer, bears)

    -- Combat resolution
    ATTACK_COOLDOWN_DEFAULT = 1.5,    -- Seconds between attacks
    ATTACK_COOLDOWN_FAST = 0.8,       -- Fast units (archers)
    ATTACK_COOLDOWN_SLOW = 3.0,       -- Slow units (siege)

    -- Range constants (in tiles)
    RANGE_MELEE = 1.5,
    RANGE_SHORT = 5,       -- Spearmen
    RANGE_MEDIUM = 8,      -- Archers
    RANGE_LONG = 12,       -- Crossbowmen
    RANGE_SIEGE = 20,      -- Catapults, trebuchets

    -- Damage values per unit type
    DAMAGE = {
        Archer = 12,
        Crossbowman = 25,
        Spearman = 15,
        Pikeman = 20,
        Maceman = 18,
        Swordsman = 22,
        Knight = 30,
        Lord = 50,
    },

    -- Health values per unit type
    HEALTH = {
        Archer = 50,
        Crossbowman = 60,
        Spearman = 70,
        Pikeman = 90,
        Maceman = 100,
        Swordsman = 120,
        Knight = 180,
        Lord = 500,
    },

    -- Armor values (damage reduction percentage 0-1)
    ARMOR = {
        Archer = 0.05,
        Crossbowman = 0.10,
        Spearman = 0.15,
        Pikeman = 0.25,
        Maceman = 0.20,
        Swordsman = 0.30,
        Knight = 0.45,
        Lord = 0.60,
    },

    -- Aggro range (when unit detects enemies)
    AGGRO_RANGE = 12,

    -- Retreat threshold (retreat when health below this percentage)
    RETREAT_HEALTH_PERCENT = 0.20,
}

return COMBAT
