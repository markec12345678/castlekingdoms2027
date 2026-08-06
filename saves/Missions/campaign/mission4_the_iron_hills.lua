-- saves/Missions/campaign/mission4_the_iron_hills.lua
-- Stronghold 2027 - Campaign Mission 4: The Iron Hills
--
-- Fourth mission of "The Lord of Fernhaven" campaign.
-- Focus on capturing iron mine and military assault on fortified positions.
--
-- Objectives:
-- 1. Build an Iron Mine (capture the iron hills)
-- 2. Produce 20 iron ingots
-- 3. Destroy enemy camp (3 buildings)
--
-- Story: For advanced units, iron is essential. The abandoned iron mine
-- in the southern hills is guarded by Lord Draven's mercenaries.
-- Send your army to capture it, then build the mine.

local mission = {
    key = "mission4_the_iron_hills",
    name = "The Iron Hills",
    nameSlv = "Železni griči",
    description = "Capture the iron mine from Lord Draven's mercenaries and produce iron for advanced units.",
    descriptionSlv = "Zavzemi železni rudnik od plačancev Lorda Dravena in pridobivaj železo za napredne enote.",

    map = "fernhaven",
    startingResources = {
        gold = 1000,
        wood = 100,
        stone = 60,
        food = 40,
    },

    objectives = {
        {
            id = 1,
            type = "build_building",
            building = "IronMine",
            count = 1,
            description = "Build an Iron Mine in the southern hills",
            descriptionSlv = "Zgradi železni rudnik v južnih gričih",
            critical = true,
        },
        {
            id = 2,
            type = "gather_resources",
            resource = "iron",
            count = 20,
            description = "Produce 20 iron ingots",
            descriptionSlv = "Proizvedi 20 železnih ingotov",
            critical = true,
        },
        {
            id = 3,
            type = "destroy_buildings",
            count = 3,
            description = "Destroy 3 enemy buildings (mercenary camp)",
            descriptionSlv = "Uniči 3 sovražnikove zgradbe (tabor plačancev)",
            critical = true,
        },
    },

    events = {
        -- Intro
        {
            name = "intro_dialogue_1",
            type = "dialogue",
            triggerTime = 1,
            dialogue = {
                character = "Captain Roric",
                text = "Sir Markus, železo potrebujemo za viteze in mečevalce. Rudnik v južnih gričih je zapuščen.",
            },
        },
        {
            name = "intro_dialogue_2",
            type = "dialogue",
            triggerTime = 8,
            dialogue = {
                character = "Brother Cedric",
                text = "A stražijo ga Lord Dravenovi plačanci. Potrebna bo vojska.",
            },
        },
        {
            name = "intro_dialogue_3",
            type = "dialogue",
            triggerTime = 15,
            dialogue = {
                character = "Sir Markus",
                text = "Pripravi vojsko, Roric. Rudnik bo naš.",
            },
        },
        -- Tutorial
        {
            name = "tutorial_army",
            type = "notification",
            triggerTime = 20,
            message = "Recruit at least 8 military units before attacking the mercenary camp.",
            notifType = "info",
            duration = 10,
        },
        -- Mercenary camp spotted
        {
            name = "camp_spotted",
            type = "notification",
            triggerTime = 60,
            message = "Mercenary camp spotted in the southern hills! 5 enemy units guarding.",
            notifType = "warning",
            duration = 8,
        },
        -- Weather change
        {
            name = "weather_fog",
            type = "set_weather",
            triggerTime = 90,
            weather = "fog",
        },
        -- Reinforcements warning
        {
            name = "reinforcements_warning",
            type = "notification",
            triggerTime = 180,
            message = "Enemy reinforcements arriving! Strike before they strengthen!",
            notifType = "warning",
            duration = 8,
        },
        -- Enemy reinforcements
        {
            name = "enemy_reinforcements",
            type = "spawn_enemy",
            triggerTime = 200,
            units = {
                {type = "Swordsman", offsetX = 35, offsetY = 30, faction = 2},
                {type = "Swordsman", offsetX = 37, offsetY = 30, faction = 2},
                {type = "Archer", offsetX = 40, offsetY = 32, faction = 2},
            },
            location = {gx = 50, gy = 50},
        },
        -- Iron mine captured dialogue
        {
            name = "mine_captured",
            type = "notification",
            triggerTime = 0,  -- will trigger via condition
            message = "Iron mine captured! Build IronMine on the iron ore deposit.",
            notifType = "success",
            duration = 10,
        },
        -- Victory
        {
            name = "victory_dialogue",
            type = "dialogue",
            triggerTime = 0,
            dialogue = {
                character = "Captain Roric",
                text = "Rudnik je naš, Sir Markus! Sedaj lahko kujemo orožje za našo vojsko.",
            },
        },
    },

    dialogues = {
        {
            character = "Captain Roric",
            text = "Železo je ključno za močno vojsko.",
        },
    },

    rewards = {
        gold = 400,
        iron = 20,
    },

    config = {
        timeLimit = 0,
        aiOpponents = {
            {
                faction = 2,
                personality = "aggressive",
                difficulty = "medium",
                spawnLocation = {gx = 75, gy = 75},  -- southern hills
            },
        },
        startingBuildings = {},
    },

    nextMission = "mission5_the_bandit_king",
}

return mission
