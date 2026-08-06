-- saves/Missions/campaign/mission5_the_bandit_king.lua
-- Stronghold 2027 - Campaign Mission 5: The Bandit King
--
-- Fifth mission of "The Lord of Fernhaven" campaign.
-- Culmination of the first half - major battle with siege weapons.
--
-- Objectives:
-- 1. Build Engineers Guild (for siege weapons)
-- 2. Recruit 10 Knights
-- 3. Recruit 15 Archers
-- 4. Defeat the Bandit King Ragnor (destroy his keep)
--
-- Story: Bandit King Ragnor has gathered a massive army. Defeating him
-- will yield his treasure (500 gold) and the respect of the region.
-- But his fortress is well-defended - you'll need siege weapons.

local mission = {
    key = "mission5_the_bandit_king",
    name = "The Bandit King",
    nameSlv = "Banditski kralj",
    description = "Defeat Bandit King Ragnor and his army. Use siege weapons to breach his fortress.",
    descriptionSlv = "Premagaj banditskega kralja Ragnorja in njegovo vojsko. Uporabi oblegovalne naprave za preboj trdnjave.",

    map = "fernhaven",
    startingResources = {
        gold = 1500,
        wood = 120,
        stone = 80,
        iron = 30,
        food = 60,
    },

    objectives = {
        {
            id = 1,
            type = "build_building",
            building = "EngineersGuild",
            count = 1,
            description = "Build an Engineers Guild for siege weapons",
            descriptionSlv = "Zgradi ceh inženirjev za oblegovalne naprave",
            critical = true,
        },
        {
            id = 2,
            type = "recruit_units",
            unit = "Knight",
            count = 10,
            description = "Recruit 10 Knights",
            descriptionSlv = "Rekrutiraj 10 vitezov",
            critical = true,
        },
        {
            id = 3,
            type = "recruit_units",
            unit = "Archer",
            count = 15,
            description = "Recruit 15 Archers",
            descriptionSlv = "Rekrutiraj 15 lokostrelcev",
            critical = true,
        },
        {
            id = 4,
            type = "destroy_buildings",
            count = 1,
            description = "Destroy Ragnor's Keep (Bandit King's fortress)",
            descriptionSlv = "Uniči Ragnorjevo trdnjavo (grad banditskega kralja)",
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
                text = "Sir Markus, Ragnor je zbral veliko vojsko. Njegova trdnjava je dobro utrjena.",
            },
        },
        {
            name = "intro_dialogue_2",
            type = "dialogue",
            triggerTime = 8,
            dialogue = {
                character = "Brother Cedric",
                text = "Potrebujemo oblegovalne naprave. Ceh inženirjev bo ključen.",
            },
        },
        {
            name = "intro_dialogue_3",
            type = "dialogue",
            triggerTime = 15,
            dialogue = {
                character = "Sir Markus",
                text = "Zbral bom vojsko vitezov in lokostrelcev. Ragnor bo premagan!",
            },
        },
        -- Tutorial
        {
            name = "tutorial_engineers",
            type = "notification",
            triggerTime = 20,
            message = "Build Engineers Guild to recruit siege engineers for catapults.",
            notifType = "info",
            duration = 10,
        },
        {
            name = "tutorial_army",
            type = "notification",
            triggerTime = 40,
            message = "Recruit a strong army: 10 Knights for melee, 15 Archers for ranged support.",
            notifType = "info",
            duration = 10,
        },
        -- Ragnor's taunt
        {
            name = "ragnor_taunt_1",
            type = "dialogue",
            triggerTime = 120,
            dialogue = {
                character = "Bandit King Ragnor",
                text = "Mislis, da me lahko premagas? Moja trdnjava je neprimljiva!",
            },
        },
        -- Weather - storm for dramatic effect
        {
            name = "weather_storm",
            type = "set_weather",
            triggerTime = 150,
            weather = "storm",
        },
        -- Ragnor sends raiding party
        {
            name = "raiding_party_warning",
            type = "notification",
            triggerTime = 180,
            message = "Ragnor sends a raiding party! Defend your keep!",
            notifType = "warning",
            duration = 8,
        },
        -- Enemy attack wave 1
        {
            name = "enemy_attack_wave_1",
            type = "spawn_enemy",
            triggerTime = 200,
            units = {
                {type = "Maceman", offsetX = 15, offsetY = 15, faction = 2},
                {type = "Maceman", offsetX = 17, offsetY = 15, faction = 2},
                {type = "Maceman", offsetX = 19, offsetY = 15, faction = 2},
                {type = "Archer", offsetX = 22, offsetY = 17, faction = 2},
                {type = "Archer", offsetX = 24, offsetY = 17, faction = 2},
                {type = "Spearman", offsetX = 16, offsetY = 18, faction = 2},
                {type = "Spearman", offsetX = 18, offsetY = 18, faction = 2},
            },
            location = {gx = 50, gy = 50},
        },
        -- Ragnor's second taunt
        {
            name = "ragnor_taunt_2",
            type = "dialogue",
            triggerTime = 300,
            dialogue = {
                character = "Bandit King Ragnor",
                text = "Moji vojaki te bodo zdrobili! Predaj se, dokler lahko!",
            },
        },
        -- Enemy attack wave 2 (bigger)
        {
            name = "enemy_attack_wave_2",
            type = "spawn_enemy",
            triggerTime = 360,
            units = {
                {type = "Swordsman", offsetX = 12, offsetY = 12, faction = 2},
                {type = "Swordsman", offsetX = 14, offsetY = 12, faction = 2},
                {type = "Swordsman", offsetX = 16, offsetY = 12, faction = 2},
                {type = "Maceman", offsetX = 18, offsetY = 14, faction = 2},
                {type = "Maceman", offsetX = 20, offsetY = 14, faction = 2},
                {type = "Archer", offsetX = 22, offsetY = 16, faction = 2},
                {type = "Archer", offsetX = 24, offsetY = 16, faction = 2},
                {type = "Archer", offsetX = 26, offsetY = 16, faction = 2},
                {type = "Crossbowman", offsetX = 28, offsetY = 18, faction = 2},
                {type = "Crossbowman", offsetX = 30, offsetY = 18, faction = 2},
            },
            location = {gx = 50, gy = 50},
        },
        -- Hint for siege
        {
            name = "siege_hint",
            type = "notification",
            triggerTime = 420,
            message = "Use siege weapons (catapults) to breach Ragnor's fortress walls!",
            notifType = "info",
            duration = 10,
        },
        -- Victory dialogue
        {
            name = "victory_dialogue",
            type = "dialogue",
            triggerTime = 0,  -- conditional
            dialogue = {
                character = "Captain Roric",
                text = "Ragnor je premagan! Njegov zaklad je naš. Regija nas spoštuje!",
            },
        },
        -- Reward notification
        {
            name = "reward_notification",
            type = "notification",
            triggerTime = 0,  -- conditional
            message = "Bandit King defeated! +500 gold, +50 iron, region respect earned!",
            notifType = "success",
            duration = 15,
        },
    },

    dialogues = {
        {
            character = "Sir Markus",
            text = "Ragnor, tvoja vladavina terorja je končana!",
        },
    },

    rewards = {
        gold = 500,
        iron = 50,
    },

    config = {
        timeLimit = 0,
        aiOpponents = {
            {
                faction = 2,  -- Ragnor's faction
                personality = "aggressive",
                difficulty = "hard",  -- harder difficulty for boss fight
                spawnLocation = {gx = 80, gy = 80},  -- far corner
                isBoss = true,
            },
        },
        startingBuildings = {},
    },

    nextMission = "mission6_betrayal_at_eastvale",
}

return mission
