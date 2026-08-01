-- saves/Missions/campaign/mission2_first_defenders.lua
-- Stronghold 2027 - Campaign Mission 2: First Defenders
--
-- Second mission of "The Lord of Fernhaven" campaign.
-- Introduces military recruitment and defense.
--
-- Objectives:
-- 1. Build a Barracks
-- 2. Recruit 5 Archers
-- 3. Survive the bandit attack (defend your keep)
--
-- Story: Bandits have noticed Fernhaven is being rebuilt. Captain Roric
-- warns of an incoming attack. Build a barracks and recruit archers to defend.

local mission = {
    -- Metadata
    key = "mission2_first_defenders",
    name = "First Defenders",
    nameSlv = "Prvi branilci",
    description = "Bandits approach! Build a barracks and recruit archers to defend Fernhaven.",
    descriptionSlv = "Banditi se približujejo! Zgradi vojašnico in rekrutiraj lokostrelce za obrambo Fernhavna.",

    -- Mission setup
    map = "fernhaven",
    startingResources = {
        gold = 800,
        wood = 60,
        stone = 30,
        food = 30,
    },

    -- Objectives
    objectives = {
        {
            id = 1,
            type = "build_building",
            building = "Barracks",
            count = 1,
            description = "Build a Barracks",
            descriptionSlv = "Zgradi vojašnico",
            critical = true,
        },
        {
            id = 2,
            type = "recruit_units",
            unit = "Archer",
            count = 5,
            description = "Recruit 5 Archers",
            descriptionSlv = "Rekrutiraj 5 lokostrelcev",
            critical = true,
        },
        {
            id = 3,
            type = "survive_time",
            duration = 300,  -- 5 minutes
            description = "Survive the bandit attack (5 minutes)",
            descriptionSlv = "Preživi napad banditov (5 minut)",
            critical = true,
        },
    },

    -- Scripted events
    events = {
        -- Intro
        {
            name = "intro_dialogue_1",
            type = "dialogue",
            triggerTime = 1,
            dialogue = {
                character = "Captain Roric",
                text = "Sir Markus! Banditi so opazili, da se Fernhaven obnavlja. Napadli bodo!",
            },
        },
        {
            name = "intro_dialogue_2",
            type = "dialogue",
            triggerTime = 6,
            dialogue = {
                character = "Brother Cedric",
                text = "Potrebujemo vojašnico in lokostrelce. Hitro!",
            },
        },
        -- Tutorial hint
        {
            name = "tutorial_barracks",
            type = "notification",
            triggerTime = 12,
            message = "Build a Barracks to recruit military units.",
            notifType = "info",
            duration = 8,
        },
        -- First wave attack at 3 minutes
        {
            name = "bandit_attack_wave_1",
            type = "spawn_enemy",
            triggerTime = 180,
            units = {
                {type = "Maceman", offsetX = 20, offsetY = 20, faction = 2},
                {type = "Maceman", offsetX = 22, offsetY = 20, faction = 2},
                {type = "Archer", offsetX = 25, offsetY = 22, faction = 2},
            },
            location = {gx = 50, gy = 50},  -- will be replaced with player keep location
        },
        -- Second wave at 4 minutes
        {
            name = "bandit_attack_wave_2",
            type = "spawn_enemy",
            triggerTime = 240,
            units = {
                {type = "Maceman", offsetX = 18, offsetY = 18, faction = 2},
                {type = "Maceman", offsetX = 20, offsetY = 18, faction = 2},
                {type = "Maceman", offsetX = 22, offsetY = 18, faction = 2},
                {type = "Archer", offsetX = 25, offsetY = 20, faction = 2},
                {type = "Archer", offsetX = 27, offsetY = 20, faction = 2},
            },
            location = {gx = 50, gy = 50},
        },
        -- Warning before attack
        {
            name = "attack_warning",
            type = "notification",
            triggerTime = 170,
            message = "Bandits approaching! Prepare your defenses!",
            notifType = "warning",
            duration = 8,
        },
        -- Victory dialogue at end
        {
            name = "victory_dialogue",
            type = "dialogue",
            triggerTime = 300,
            dialogue = {
                character = "Captain Roric",
                text = "Zadržali smo jih! Fernhaven je varovan. A to je le začetek.",
            },
        },
    },

    -- Story dialogues
    dialogues = {
        {
            character = "Captain Roric",
            text = "I'll train your archers, my lord. We must be ready.",
        },
    },

    -- Rewards
    rewards = {
        gold = 300,
    },

    -- Mission configuration
    config = {
        timeLimit = 0,  -- no overall limit, but survive objective has 5 min
        aiOpponents = {
            {
                faction = 2,  -- COMBAT.FACTION_ENEMY_1
                personality = "aggressive",
                difficulty = "easy",
                spawnLocation = {gx = 70, gy = 70},  -- far from player
            },
        },
        startingBuildings = {},
    },

    -- Next mission
    nextMission = "mission3_alliance_with_westmarsh",
}

return mission
