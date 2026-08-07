-- saves/Missions/campaign/mission6_betrayal_at_eastvale.lua
-- Castle Kingdoms 2027 - Campaign Mission 6: Betrayal at Eastvale
--
-- Sixth mission of "The Lord of Fernhaven" campaign.
-- Opening of the second act - political drama and betrayal.
--
-- Story: Lord Aldric, supposedly an ally, has made a pact with Lord Draven.
-- His army attacks unprepared. Defend your castle!
--
-- Objectives:
-- 1. Build defensive walls (5 Wooden Walls)
-- 2. Build 2 Square Towers
-- 3. Survive 3 attack waves (8 minutes)
-- 4. Keep your keep alive
--
-- This mission tests rapid defensive building under pressure.

local mission = {
    key = "mission6_betrayal_at_eastvale",
    name = "Betrayal at Eastvale",
    nameSlv = "Izdaja pri Eastvalu",
    description = "Lord Aldric has betrayed you! Build defenses and survive the surprise attack.",
    descriptionSlv = "Lord Aldric te je izdal! Zgradi obrambo in preživi nepričakovan napad.",

    map = "fernhaven",
    startingResources = {
        gold = 1200,
        wood = 100,
        stone = 80,
        iron = 20,
        food = 50,
    },

    objectives = {
        {
            id = 1,
            type = "build_building",
            building = "WoodenWall",
            count = 5,
            description = "Build 5 Wooden Walls for defense",
            descriptionSlv = "Zgradi 5 lesenih zidov za obrambo",
            critical = true,
        },
        {
            id = 2,
            type = "build_building",
            building = "SquareTower",
            count = 2,
            description = "Build 2 Square Towers",
            descriptionSlv = "Zgradi 2 kvadratna stolpa",
            critical = true,
        },
        {
            id = 3,
            type = "survive_time",
            duration = 480,  -- 8 minutes
            description = "Survive 3 attack waves (8 minutes)",
            descriptionSlv = "Preživi 3 valove napadov (8 minut)",
            critical = true,
        },
        {
            id = 4,
            type = "protect_building",
            building = "Keep",  -- or WoodenKeep, SaxonHall
            duration = 480,
            description = "Protect your keep at all costs",
            descriptionSlv = "Zaščiti svojo trdnjavo za vsako ceno",
            critical = true,
        },
    },

    events = {
        -- Intro - the betrayal revelation
        {
            name = "intro_dialogue_1",
            type = "dialogue",
            triggerTime = 1,
            dialogue = {
                character = "Captain Roric",
                text = "Sir Markus! Lord Aldric je sklenil pakt z Lordom Dravenom. Njegova vojska je na poti!",
            },
        },
        {
            name = "intro_dialogue_2",
            type = "dialogue",
            triggerTime = 8,
            dialogue = {
                character = "Sir Markus",
                text = "Izdaja! Pripravi obrambo, Roric. Ne moremo se umakniti.",
            },
        },
        {
            name = "intro_dialogue_3",
            type = "dialogue",
            triggerTime = 15,
            dialogue = {
                character = "Brother Cedric",
                text = "Zidove in stolpe moramo zgraditi hitro. Čas je proti nam.",
            },
        },
        -- Tutorial - rapid defense
        {
            name = "tutorial_defense",
            type = "notification",
            triggerTime = 20,
            message = "Build walls and towers quickly! Enemy attacks in 2 minutes.",
            notifType = "warning",
            duration = 10,
        },
        -- Aldric's taunt
        {
            name = "aldric_taunt_1",
            type = "dialogue",
            triggerTime = 90,
            dialogue = {
                character = "Lord Aldric",
                text = "Markus, ti neumen! Misliš, da lahko premagaš Dravena? Pridruži se mi ali umri!",
            },
        },
        -- Weather - ominous
        {
            name = "weather_fog",
            type = "set_weather",
            triggerTime = 100,
            weather = "fog",
        },
        -- Wave 1 warning
        {
            name = "wave_1_warning",
            type = "notification",
            triggerTime = 110,
            message = "Wave 1 incoming! 8 enemy units approaching from the east!",
            notifType = "warning",
            duration = 8,
        },
        -- Wave 1 attack (2 minutes)
        {
            name = "wave_1_attack",
            type = "spawn_enemy",
            triggerTime = 120,
            units = {
                {type = "Spearman", offsetX = 25, offsetY = 0, faction = 3},
                {type = "Spearman", offsetX = 27, offsetY = 0, faction = 3},
                {type = "Spearman", offsetX = 29, offsetY = 0, faction = 3},
                {type = "Maceman", offsetX = 26, offsetY = 2, faction = 3},
                {type = "Maceman", offsetX = 28, offsetY = 2, faction = 3},
                {type = "Archer", offsetX = 30, offsetY = -2, faction = 3},
                {type = "Archer", offsetX = 32, offsetY = -2, faction = 3},
                {type = "Archer", offsetX = 34, offsetY = -2, faction = 3},
            },
            location = {gx = 50, gy = 50},
        },
        -- Brief respite
        {
            name = "respite_1",
            type = "notification",
            triggerTime = 200,
            message = "Wave 1 repelled! Reinforce defenses, Wave 2 incoming in 2 minutes.",
            notifType = "success",
            duration = 8,
        },
        -- Aldric's second taunt
        {
            name = "aldric_taunt_2",
            type = "dialogue",
            triggerTime = 250,
            dialogue = {
                character = "Lord Aldric",
                text = "Imaš srečo, a to ne bo trajalo. Moji zavezniki prihajajo!",
            },
        },
        -- Weather change - rain
        {
            name = "weather_rain",
            type = "set_weather",
            triggerTime = 280,
            weather = "heavy_rain",
        },
        -- Wave 2 warning
        {
            name = "wave_2_warning",
            type = "notification",
            triggerTime = 290,
            message = "Wave 2 incoming! 12 enemy units, including Swordsmen!",
            notifType = "warning",
            duration = 8,
        },
        -- Wave 2 attack (5 minutes)
        {
            name = "wave_2_attack",
            type = "spawn_enemy",
            triggerTime = 300,
            units = {
                {type = "Swordsman", offsetX = 22, offsetY = 0, faction = 3},
                {type = "Swordsman", offsetX = 24, offsetY = 0, faction = 3},
                {type = "Swordsman", offsetX = 26, offsetY = 0, faction = 3},
                {type = "Maceman", offsetX = 23, offsetY = 3, faction = 3},
                {type = "Maceman", offsetX = 25, offsetY = 3, faction = 3},
                {type = "Maceman", offsetX = 27, offsetY = 3, faction = 3},
                {type = "Spearman", offsetX = 28, offsetY = -3, faction = 3},
                {type = "Spearman", offsetX = 30, offsetY = -3, faction = 3},
                {type = "Archer", offsetX = 32, offsetY = -2, faction = 3},
                {type = "Archer", offsetX = 34, offsetY = -2, faction = 3},
                {type = "Crossbowman", offsetX = 36, offsetY = -2, faction = 3},
                {type = "Crossbowman", offsetX = 38, offsetY = -2, faction = 3},
            },
            location = {gx = 50, gy = 50},
        },
        -- Respite 2
        {
            name = "respite_2",
            type = "notification",
            triggerTime = 380,
            message = "Wave 2 repelled! Final wave incoming. Hold the line!",
            notifType = "success",
            duration = 8,
        },
        -- Aldric's final taunt
        {
            name = "aldric_taunt_3",
            type = "dialogue",
            triggerTime = 420,
            dialogue = {
                character = "Lord Aldric",
                text = "Draven posilja svoje elite. Tokrat ne boš pobegnil, Markus!",
            },
        },
        -- Wave 3 warning - the big one
        {
            name = "wave_3_warning",
            type = "notification",
            triggerTime = 430,
            message = "WAVE 3 INCOMING! 15 elite units including Knights! Final assault!",
            notifType = "warning",
            duration = 10,
        },
        -- Wave 3 attack (7.5 minutes) - the big one
        {
            name = "wave_3_attack",
            type = "spawn_enemy",
            triggerTime = 450,
            units = {
                {type = "Knight", offsetX = 20, offsetY = 0, faction = 3},
                {type = "Knight", offsetX = 22, offsetY = 0, faction = 3},
                {type = "Knight", offsetX = 24, offsetY = 0, faction = 3},
                {type = "Swordsman", offsetX = 21, offsetY = 3, faction = 3},
                {type = "Swordsman", offsetX = 23, offsetY = 3, faction = 3},
                {type = "Swordsman", offsetX = 25, offsetY = 3, faction = 3},
                {type = "Swordsman", offsetX = 27, offsetY = 3, faction = 3},
                {type = "Maceman", offsetX = 26, offsetY = -3, faction = 3},
                {type = "Maceman", offsetX = 28, offsetY = -3, faction = 3},
                {type = "Maceman", offsetX = 30, offsetY = -3, faction = 3},
                {type = "Crossbowman", offsetX = 32, offsetY = -2, faction = 3},
                {type = "Crossbowman", offsetX = 34, offsetY = -2, faction = 3},
                {type = "Crossbowman", offsetX = 36, offsetY = -2, faction = 3},
                {type = "Archer", offsetX = 38, offsetY = -2, faction = 3},
                {type = "Archer", offsetX = 40, offsetY = -2, faction = 3},
            },
            location = {gx = 50, gy = 50},
        },
        -- Victory dialogue
        {
            name = "victory_dialogue",
            type = "dialogue",
            triggerTime = 480,
            dialogue = {
                character = "Captain Roric",
                text = "Zadržali smo jih! Aldric je umaknil svoje sile. A vojna šele začenja se.",
            },
        },
        -- Story setup for next mission
        {
            name = "next_mission_setup",
            type = "dialogue",
            triggerTime = 485,
            dialogue = {
                character = "Brother Cedric",
                text = "Aldric je begal v Northern Pass. Če ga zavzamemo, odpremo pot do prestolnice.",
            },
        },
    },

    dialogues = {
        {
            character = "Sir Markus",
            text = "Izdaja ne bo ostala nekaznovana, Aldric.",
        },
    },

    rewards = {
        gold = 600,
        stone = 30,
    },

    config = {
        timeLimit = 0,
        aiOpponents = {
            {
                faction = 3,  -- Lord Aldric's faction
                personality = "aggressive",
                difficulty = "medium",
                spawnLocation = {gx = 85, gy = 50},  -- east (Eastvale)
            },
        },
        startingBuildings = {},
    },

    nextMission = "mission7_the_northern_pass",
}

return mission
