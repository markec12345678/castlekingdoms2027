-- saves/Missions/campaign/mission8_the_cathedral.lua
-- Castle Kingdoms 2027 - Campaign Mission 8: The Cathedral
--
-- Eighth mission of "The Lord of Fernhaven" campaign.
-- Recovery after betrayal - focus on popularity, faith, and economy.
-- Less combat, more management. Building toward the final war.
--
-- Story: After repelling Aldric's attacks and capturing the Northern Pass,
-- Sir Markus returns to Fernhaven to rebuild. The people need hope.
-- A grand cathedral will lift morale and attract more population.
-- But Draven may attack during construction...

local mission = {
    key = "mission8_the_cathedral",
    name = "The Cathedral",
    nameSlv = "Katedrala",
    description = "Build a grand cathedral to restore hope. Balance economy, faith, and defense.",
    descriptionSlv = "Zgradi veličastno katedralo za obnovo upanja. Uravnoteži ekonomijo, vero in obrambo.",

    map = "fernhaven",
    startingResources = {
        gold = 2500,
        wood = 200,
        stone = 150,
        iron = 50,
        food = 100,
    },

    objectives = {
        {
            id = 1,
            type = "build_building",
            building = "Cathedral",
            count = 1,
            description = "Build a Cathedral (500 stone, 200 gold)",
            descriptionSlv = "Zgradi katedralo (500 kamna, 200 zlata)",
            critical = true,
        },
        {
            id = 2,
            type = "reach_popularity",
            target = 80,
            description = "Achieve popularity of 80",
            descriptionSlv = "Doseži priljubljenost 80",
            critical = true,
        },
        {
            id = 3,
            type = "reach_population",
            target = 50,
            description = "Reach population of 50",
            descriptionSlv = "Doseži prebivalstvo 50",
            critical = true,
        },
        {
            id = 4,
            type = "survive_time",
            duration = 600,  -- 10 minutes
            description = "Protect the cathedral during construction (10 minutes)",
            descriptionSlv = "Zaščiti katedralo med gradnjo (10 minut)",
            critical = true,
        },
    },

    events = {
        -- Intro - returning home
        {
            name = "intro_dialogue_1",
            type = "dialogue",
            triggerTime = 1,
            dialogue = {
                character = "Brother Cedric",
                text = "Sir Markus, Fernhaven je ponovno naš. A ljudstvo je potrto po izdaji.",
            },
        },
        {
            name = "intro_dialogue_2",
            type = "dialogue",
            triggerTime = 8,
            dialogue = {
                character = "Brother Cedric",
                text = "Potrebujejo upanje. Katedrala bo dvignila moralo in pritegnila prebivalce.",
            },
        },
        {
            name = "intro_dialogue_3",
            type = "dialogue",
            triggerTime = 15,
            dialogue = {
                character = "Sir Markus",
                text = "Tako bo. A Draven nas ne bo pustil pri miru. Pripravi obrambo.",
            },
        },
        -- Tutorial - management focus
        {
            name = "tutorial_cathedral",
            type = "notification",
            triggerTime = 20,
            message = "Cathedral costs 500 stone and 200 gold. Plan your economy carefully!",
            notifType = "info",
            duration = 12,
        },
        {
            name = "tutorial_popularity",
            type = "notification",
            triggerTime = 40,
            message = "Build gardens, provide food, and keep taxes low to increase popularity.",
            notifType = "info",
            duration = 12,
        },
        {
            name = "tutorial_population",
            type = "notification",
            triggerTime = 60,
            message = "Build houses to increase population cap. Cathedral also boosts population.",
            notifType = "info",
            duration = 12,
        },
        -- Lady Elara's visit
        {
            name = "elara_visit",
            type = "dialogue",
            triggerTime = 120,
            dialogue = {
                character = "Lady Elara",
                text = "Markus, Westmarsh stoji ob vas. Moji viri so vaši, a poslušaj...",
            },
        },
        {
            name = "elara_warning",
            type = "dialogue",
            triggerTime = 130,
            dialogue = {
                character = "Lady Elara",
                text = "Draven pripravlja veliko vojsko. Njegovi vohuni so med nami. Pazite na Elaro.",
            },
        },
        -- Economic boom event
        {
            name = "economic_boom",
            type = "notification",
            triggerTime = 180,
            message = "Trade routes flourish! Sell prices increased by 20%.",
            notifType = "success",
            duration = 8,
        },
        -- Weather - clear (hopeful atmosphere)
        {
            name = "weather_clear",
            type = "set_weather",
            triggerTime = 90,
            weather = "clear",
        },
        -- Draven's scout
        {
            name = "draven_scout_warning",
            type = "notification",
            triggerTime = 240,
            message = "Draven's scouts spotted! Small raiding party incoming.",
            notifType = "warning",
            duration = 8,
        },
        -- Small raid (not full assault)
        {
            name = "small_raid",
            type = "spawn_enemy",
            triggerTime = 260,
            units = {
                {type = "Maceman", offsetX = 20, offsetY = 0, faction = 2},
                {type = "Maceman", offsetX = 22, offsetY = 0, faction = 2},
                {type = "Archer", offsetX = 24, offsetY = 2, faction = 2},
                {type = "Archer", offsetX = 26, offsetY = 2, faction = 2},
                {type = "Spearman", offsetX = 28, offsetY = -2, faction = 2},
            },
            location = {gx = 50, gy = 50},
        },
        -- Cathedral progress encouragement
        {
            name = "cathedral_progress",
            type = "notification",
            triggerTime = 360,
            message = "The cathedral rises! People are hopeful. Popularity rising.",
            notifType = "success",
            duration = 8,
        },
        -- Festival event
        {
            name = "festival",
            type = "notification",
            triggerTime = 420,
            message = "Festival celebrated! +20 popularity, people rejoice.",
            notifType = "success",
            duration = 10,
        },
        -- Draven's taunt
        {
            name = "draven_taunt",
            type = "dialogue",
            triggerTime = 480,
            dialogue = {
                character = "Lord Draven",
                text = "Tvoja katedrala ne bo rešila tvojega ljudstva, Markus. Prihajam.",
            },
        },
        -- Final small raid before completion
        {
            name = "final_raid",
            type = "spawn_enemy",
            triggerTime = 540,
            units = {
                {type = "Swordsman", offsetX = 20, offsetY = 0, faction = 2},
                {type = "Swordsman", offsetX = 22, offsetY = 0, faction = 2},
                {type = "Crossbowman", offsetX = 24, offsetY = 2, faction = 2},
                {type = "Crossbowman", offsetX = 26, offsetY = 2, faction = 2},
                {type = "Knight", offsetX = 28, offsetY = -2, faction = 2},
            },
            location = {gx = 50, gy = 50},
        },
        -- Victory dialogue
        {
            name = "victory_dialogue",
            type = "dialogue",
            triggerTime = 600,
            dialogue = {
                character = "Brother Cedric",
                text = "Katedrala je končana! Ljudstvo je močno. Sedaj lahko napademo Dravena.",
            },
        },
        -- Story setup for next mission
        {
            name = "story_setup_1",
            type = "dialogue",
            triggerTime = 608,
            dialogue = {
                character = "Captain Roric",
                text = "A čakaj... Lady Elara je izginila. Draven jo je ujel!",
            },
        },
        {
            name = "story_setup_2",
            type = "dialogue",
            triggerTime = 616,
            dialogue = {
                character = "Sir Markus",
                text = "Ne. Elara... Pripravi reševalno ekipo. Takoj!",
            },
        },
    },

    dialogues = {
        {
            character = "Sir Markus",
            text = "Za ljudstvo. Za Fernhaven. Za Elaro.",
        },
    },

    rewards = {
        gold = 1000,
        food = 100,
    },

    config = {
        timeLimit = 0,
        aiOpponents = {
            {
                faction = 2,  -- Draven (raids)
                personality = "aggressive",
                difficulty = "medium",
                spawnLocation = {gx = 85, gy = 85},
            },
        },
        startingBuildings = {},
    },

    nextMission = "mission9_lady_elaras_sacrifice",
}

return mission
