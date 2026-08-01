-- saves/Missions/campaign/mission7_the_northern_pass.lua
-- Stronghold 2027 - Campaign Mission 7: The Northern Pass
--
-- Seventh mission of "The Lord of Fernhaven" campaign.
-- Siege warfare - use catapults to breach mountain fortress.
--
-- Story: Lord Aldric has fled to the Northern Pass, a strategic chokepoint.
-- To open the road to the capital, you must breach his fortress walls
-- using siege weapons. Catapults are essential.
--
-- Objectives:
-- 1. Build Engineers Guild
-- 2. Recruit 3 Engineers (siege unit)
-- 3. Build 2 Catapults
-- 4. Destroy Aldric's Keep (breach the fortress)
-- 5. Don't lose all your catapults (protect siege weapons)
--
-- This mission introduces siege warfare mechanics.

local mission = {
    key = "mission7_the_northern_pass",
    name = "The Northern Pass",
    nameSlv = "Severni prelaz",
    description = "Breach Lord Aldric's mountain fortress using catapults. Open the road to the capital!",
    descriptionSlv = "Prebij trdnjavo Lorda Aldrica v gorah s katapulti. Odpri pot do prestolnice!",

    map = "fernhaven",
    startingResources = {
        gold = 2000,
        wood = 150,
        stone = 100,
        iron = 40,
        food = 80,
    },

    objectives = {
        {
            id = 1,
            type = "build_building",
            building = "EngineersGuild",
            count = 1,
            description = "Build an Engineers Guild",
            descriptionSlv = "Zgradi ceh inženirjev",
            critical = true,
        },
        {
            id = 2,
            type = "recruit_units",
            unit = "Engineer",
            count = 3,
            description = "Recruit 3 Siege Engineers",
            descriptionSlv = "Rekrutiraj 3 oblegovalne inženirje",
            critical = true,
        },
        {
            id = 3,
            type = "build_building",
            building = "Catapult",  -- siege weapon as building
            count = 2,
            description = "Build 2 Catapults",
            descriptionSlv = "Zgradi 2 katapulte",
            critical = true,
        },
        {
            id = 4,
            type = "destroy_buildings",
            count = 1,
            description = "Destroy Lord Aldric's Keep (breach the fortress)",
            descriptionSlv = "Uniči trdnjavo Lorda Aldrica (preboj trdnjave)",
            critical = true,
        },
        {
            id = 5,
            type = "protect_building",
            building = "Catapult",
            duration = 600,  -- 10 minutes
            description = "Protect your catapults (don't lose them all)",
            descriptionSlv = "Zaščiti svoje katapulturne (ne izgubi vseh)",
            critical = false,  -- bonus objective
        },
    },

    events = {
        -- Intro - the strategic situation
        {
            name = "intro_dialogue_1",
            type = "dialogue",
            triggerTime = 1,
            dialogue = {
                character = "Captain Roric",
                text = "Sir Markus, Northern Pass je strateško ključen. Aldric se je utrdil tam.",
            },
        },
        {
            name = "intro_dialogue_2",
            type = "dialogue",
            triggerTime = 8,
            dialogue = {
                character = "Brother Cedric",
                text = "Ozki prelaz otežuje napad. Njegovi zidovi so visoki. Potrebni so katapulti.",
            },
        },
        {
            name = "intro_dialogue_3",
            type = "dialogue",
            triggerTime = 15,
            dialogue = {
                character = "Sir Markus",
                text = "Torej moramo zgraditi oblegovalne naprave. Pripravi inženirje, Roric.",
            },
        },
        -- Tutorial - siege warfare
        {
            name = "tutorial_siege_1",
            type = "notification",
            triggerTime = 20,
            message = "Build Engineers Guild to recruit siege engineers for catapults.",
            notifType = "info",
            duration = 10,
        },
        {
            name = "tutorial_siege_2",
            type = "notification",
            triggerTime = 40,
            message = "Catapults deal massive damage to buildings. Use them to breach walls!",
            notifType = "info",
            duration = 10,
        },
        {
            name = "tutorial_siege_3",
            type = "notification",
            triggerTime = 60,
            message = "Protect your catapults! They're slow and vulnerable to melee units.",
            notifType = "warning",
            duration = 10,
        },
        -- Aldric's defense taunt
        {
            name = "aldric_taunt_1",
            type = "dialogue",
            triggerTime = 120,
            dialogue = {
                character = "Lord Aldric",
                text = "Misliš, da lahko prebijes moje zidove? Moji lokostrelci te bodo ustavili!",
            },
        },
        -- Weather - snow in the mountains
        {
            name = "weather_snow",
            type = "set_weather",
            triggerTime = 90,
            weather = "snow",
        },
        -- Aldric sends defenders
        {
            name = "defenders_warning",
            type = "notification",
            triggerTime = 180,
            message = "Aldric sends archers to destroy your catapults! Protect them!",
            notifType = "warning",
            duration = 10,
        },
        -- Enemy sortie 1 - archers targeting catapults
        {
            name = "enemy_sortie_1",
            type = "spawn_enemy",
            triggerTime = 200,
            units = {
                {type = "Archer", offsetX = 30, offsetY = 0, faction = 3},
                {type = "Archer", offsetX = 32, offsetY = 0, faction = 3},
                {type = "Archer", offsetX = 34, offsetY = 2, faction = 3},
                {type = "Archer", offsetX = 36, offsetY = 2, faction = 3},
                {type = "Crossbowman", offsetX = 38, offsetY = -2, faction = 3},
                {type = "Crossbowman", offsetX = 40, offsetY = -2, faction = 3},
            },
            location = {gx = 50, gy = 50},
        },
        -- Aldric's second taunt
        {
            name = "aldric_taunt_2",
            type = "dialogue",
            triggerTime = 280,
            dialogue = {
                character = "Lord Aldric",
                text = "Moji zidovi držijo! Tvoji katapulti so igrača!",
            },
        },
        -- Time pressure - Aldric calls for reinforcements
        {
            name = "reinforcements_warning",
            type = "notification",
            triggerTime = 360,
            message = "Aldric called for Draven's reinforcements! Destroy his keep before they arrive!",
            notifType = "warning",
            duration = 10,
        },
        -- Enemy sortie 2 - bigger, includes knights
        {
            name = "enemy_sortie_2",
            type = "spawn_enemy",
            triggerTime = 400,
            units = {
                {type = "Knight", offsetX = 25, offsetY = 0, faction = 3},
                {type = "Knight", offsetX = 27, offsetY = 0, faction = 3},
                {type = "Swordsman", offsetX = 29, offsetY = 3, faction = 3},
                {type = "Swordsman", offsetX = 31, offsetY = 3, faction = 3},
                {type = "Maceman", offsetX = 33, offsetY = -3, faction = 3},
                {type = "Maceman", offsetX = 35, offsetY = -3, faction = 3},
                {type = "Archer", offsetX = 37, offsetY = 2, faction = 3},
                {type = "Archer", offsetX = 39, offsetY = 2, faction = 3},
            },
            location = {gx = 50, gy = 50},
        },
        -- Draven's reinforcements arrive (fail state hint)
        {
            name = "draven_reinforcements",
            type = "notification",
            triggerTime = 540,
            message = "Draven's reinforcements arriving! Destroy Aldric's keep NOW!",
            notifType = "warning",
            duration = 15,
        },
        -- Final wave if player hasn't won yet
        {
            name = "final_wave",
            type = "spawn_enemy",
            triggerTime = 580,
            units = {
                {type = "Knight", offsetX = 20, offsetY = 0, faction = 2},  -- Draven's forces
                {type = "Knight", offsetX = 22, offsetY = 0, faction = 2},
                {type = "Knight", offsetX = 24, offsetY = 0, faction = 2},
                {type = "Swordsman", offsetX = 21, offsetY = 4, faction = 2},
                {type = "Swordsman", offsetX = 23, offsetY = 4, faction = 2},
                {type = "Swordsman", offsetX = 25, offsetY = 4, faction = 2},
                {type = "Crossbowman", offsetX = 27, offsetY = -3, faction = 2},
                {type = "Crossbowman", offsetX = 29, offsetY = -3, faction = 2},
                {type = "Archer", offsetX = 31, offsetY = -3, faction = 2},
                {type = "Archer", offsetX = 33, offsetY = -3, faction = 2},
            },
            location = {gx = 50, gy = 50},
        },
        -- Victory dialogue
        {
            name = "victory_dialogue",
            type = "dialogue",
            triggerTime = 0,  -- conditional on winning
            dialogue = {
                character = "Captain Roric",
                text = "Aldric je premagan! Northern Pass je naš. Pot do prestolnice je odprta!",
            },
        },
        -- Story setup
        {
            name = "story_setup",
            type = "dialogue",
            triggerTime = 0,
            dialogue = {
                character = "Brother Cedric",
                text = "Aldric je begal, a Draven je še vedno močan. Pred napadom na prestolnico, moramo okrepiti ljudstvo.",
            },
        },
        -- Reward notification
        {
            name = "reward_notification",
            type = "notification",
            triggerTime = 0,
            message = "Northern Pass captured! +800 gold, +50 iron, region control earned!",
            notifType = "success",
            duration = 15,
        },
    },

    dialogues = {
        {
            character = "Sir Markus",
            text = "Aldric, tvoja trdnjava pade danes!",
        },
    },

    rewards = {
        gold = 800,
        iron = 50,
    },

    config = {
        timeLimit = 0,
        aiOpponents = {
            {
                faction = 3,  -- Lord Aldric (defensive)
                personality = "defensive",
                difficulty = "hard",
                spawnLocation = {gx = 80, gy = 30},  -- northern pass
            },
            {
                faction = 2,  -- Lord Draven (reinforcements)
                personality = "aggressive",
                difficulty = "hard",
                spawnLocation = {gx = 90, gy = 50},  -- far east
                spawnDelay = 540,  -- arrives at 9 minutes
            },
        },
        startingBuildings = {},
    },

    nextMission = "mission8_the_cathedral",
}

return mission
