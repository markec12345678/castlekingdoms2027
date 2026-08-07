-- saves/Missions/campaign/mission10_the_throne_of_valdemar.lua
-- Castle Kingdoms 2027 - Campaign Mission 10: The Throne of Valdemar
--
-- FINAL MISSION of "The Lord of Fernhaven" campaign.
-- The grand finale - assault on the capital city with 6 phases.
--
-- Story: With Lady Elara rescued and the people behind him, Sir Markus
-- marches on the capital. Lord Draven holds the throne, but his rule
-- crumbles. This is the final battle for the kingdom of Valdemar.
--
-- 6 PHASES OF COMBAT (instead of one big battle):
-- Phase 1: Capture outer village (small skirmish)
-- Phase 2: Destroy defensive towers (siege preparation)
-- Phase 3: Break first wall (catapult assault)
-- Phase 4: Enemy reinforcements arrive (defend captured position)
-- Phase 5: Final assault on the keep (climactic battle)
-- Phase 6: Concluding dialogue and victory

local mission = {
    key = "mission10_the_throne_of_valdemar",
    name = "The Throne of Valdemar",
    nameSlv = "Prestol Valdemarja",
    description = "The final battle! March on the capital and claim the throne from Lord Draven.",
    descriptionSlv = "Zadnja bitka! Kreni na prestolnico in prevzemi krono od Lorda Dravena.",

    map = "fernhaven",  -- ideally a larger map, but using existing
    startingResources = {
        gold = 5000,
        wood = 300,
        stone = 200,
        iron = 100,
        food = 200,
    },

    objectives = {
        -- Phase 1: Capture outer village
        {
            id = 1,
            type = "destroy_buildings",
            count = 3,
            description = "[Phase 1] Capture outer village (destroy 3 enemy buildings)",
            descriptionSlv = "[Faza 1] Zavzemi zunanjo vas (uniči 3 sovražnikove zgradbe)",
            critical = true,
        },
        -- Phase 2: Destroy defensive towers
        {
            id = 2,
            type = "destroy_buildings",
            count = 2,
            description = "[Phase 2] Destroy 2 defensive towers (prepare for siege)",
            descriptionSlv = "[Faza 2] Uniči 2 obrambna stolpa (priprava na oblegovalni napad)",
            critical = true,
        },
        -- Phase 3: Build catapults and breach wall
        {
            id = 3,
            type = "build_building",
            building = "Catapult",
            count = 3,
            description = "[Phase 3] Build 3 Catapults for wall breach",
            descriptionSlv = "[Faza 3] Zgradi 3 katapulte za preboj zidu",
            critical = true,
        },
        {
            id = 4,
            type = "destroy_buildings",
            count = 1,
            description = "[Phase 3] Breach the city wall (destroy wall segment)",
            descriptionSlv = "[Faza 3] Prebij mestni zid (uniči segment zidu)",
            critical = true,
        },
        -- Phase 4: Survive reinforcements
        {
            id = 5,
            type = "survive_time",
            duration = 180,  -- 3 minutes
            description = "[Phase 4] Hold position against reinforcements (3 minutes)",
            descriptionSlv = "[Faza 4] Zadrži položaj proti okrepitvam (3 minute)",
            critical = true,
        },
        -- Phase 5: Final assault on the keep
        {
            id = 6,
            type = "destroy_buildings",
            count = 1,
            description = "[Phase 5] Destroy Draven's Keep (FINAL ASSAULT)",
            descriptionSlv = "[Faza 5] Uniči Dravenovo trdnjavo (KONČNI NAPAD)",
            critical = true,
        },
        -- Bonus: military buildup
        {
            id = 7,
            type = "recruit_units",
            unit = "Knight",
            count = 15,
            description = "[Bonus] Recruit 15 Knights for final assault",
            descriptionSlv = "[Bonus] Rekrutiraj 15 vitezov za končni napad",
            critical = false,
        },
    },

    events = {
        -- === PHASE 1: INTRO AND OUTER VILLAGE ===
        {
            name = "intro_dialogue_1",
            type = "dialogue",
            triggerTime = 1,
            dialogue = {
                character = "Sir Markus",
                text = "Končno. Prestolnica Valdemar pred nami. Draven, tvoja vladavina je končana.",
            },
        },
        {
            name = "intro_dialogue_2",
            type = "dialogue",
            triggerTime = 8,
            dialogue = {
                character = "Captain Roric",
                text = "Sir Markus, zunanja vas je slabo branena. Zavzamemo jo prvo.",
            },
        },
        {
            name = "intro_dialogue_3",
            type = "dialogue",
            triggerTime = 16,
            dialogue = {
                character = "Brother Cedric",
                text = "Aldricove sile so šibke. A v notranjosti čakajo Dravenovi elitci.",
            },
        },
        {
            name = "phase_1_start",
            type = "notification",
            triggerTime = 20,
            message = "[PHASE 1] Capture the outer village! Destroy 3 enemy buildings.",
            notifType = "info",
            duration = 12,
        },
        -- Weather - clear (epic atmosphere)
        {
            name = "weather_clear",
            type = "set_weather",
            triggerTime = 25,
            weather = "clear",
        },
        -- Time of day - morning
        {
            name = "time_morning",
            type = "set_time",
            triggerTime = 30,
            timePeriod = "dawn",
        },
        -- Village defenders
        {
            name = "village_defenders",
            type = "spawn_enemy",
            triggerTime = 60,
            units = {
                {type = "Spearman", offsetX = 30, offsetY = 0, faction = 2},
                {type = "Spearman", offsetX = 32, offsetY = 0, faction = 2},
                {type = "Spearman", offsetX = 34, offsetY = 2, faction = 2},
                {type = "Archer", offsetX = 36, offsetY = -2, faction = 2},
                {type = "Archer", offsetX = 38, offsetY = -2, faction = 2},
                {type = "Maceman", offsetX = 40, offsetY = 0, faction = 2},
            },
            location = {gx = 50, gy = 50},
        },

        -- === PHASE 2: DESTROY TOWERS ===
        {
            name = "phase_2_start",
            type = "notification",
            triggerTime = 180,
            message = "[PHASE 2] Village captured! Destroy 2 defensive towers to prepare for siege.",
            notifType = "success",
            duration = 12,
        },
        {
            name = "phase_2_dialogue",
            type = "dialogue",
            triggerTime = 190,
            dialogue = {
                character = "Captain Roric",
                text = "Vas je naša! A stolpi ščitijo mestni zid. Lokostrelci na stolpih so nevarni.",
            },
        },
        -- Tower defenders
        {
            name = "tower_defenders",
            type = "spawn_enemy",
            triggerTime = 220,
            units = {
                {type = "Archer", offsetX = 35, offsetY = 5, faction = 2},
                {type = "Archer", offsetX = 37, offsetY = 5, faction = 2},
                {type = "Archer", offsetX = 39, offsetY = 5, faction = 2},
                {type = "Crossbowman", offsetX = 36, offsetY = -5, faction = 2},
                {type = "Crossbowman", offsetX = 38, offsetY = -5, faction = 2},
            },
            location = {gx = 50, gy = 50},
        },

        -- === PHASE 3: BUILD CATAPULTS AND BREACH WALL ===
        {
            name = "phase_3_start",
            type = "notification",
            triggerTime = 360,
            message = "[PHASE 3] Towers down! Build 3 Catapults and breach the city wall!",
            notifType = "success",
            duration = 12,
        },
        {
            name = "phase_3_dialogue",
            type = "dialogue",
            triggerTime = 370,
            dialogue = {
                character = "Captain Roric",
                text = "Sedaj potrebujemo oblegovalne naprave. Inženirji, pripravite katapulturne!",
            },
        },
        {
            name = "phase_3_tutorial",
            type = "notification",
            triggerTime = 380,
            message = "Build Engineers Guild, recruit Engineers, then build Catapults.",
            notifType = "info",
            duration = 10,
        },
        -- Weather change - clouds gathering
        {
            name = "weather_clouds",
            type = "set_weather",
            triggerTime = 400,
            weather = "rain",
        },
        -- Wall defenders sally out
        {
            name = "wall_sally",
            type = "spawn_enemy",
            triggerTime = 450,
            units = {
                {type = "Swordsman", offsetX = 25, offsetY = 0, faction = 2},
                {type = "Swordsman", offsetX = 27, offsetY = 0, faction = 2},
                {type = "Maceman", offsetX = 29, offsetY = 2, faction = 2},
                {type = "Maceman", offsetX = 31, offsetY = 2, faction = 2},
                {type = "Knight", offsetX = 33, offsetY = -2, faction = 2},
            },
            location = {gx = 50, gy = 50},
        },

        -- === PHASE 4: REINFORCEMENTS ARRIVE ===
        {
            name = "phase_4_start",
            type = "notification",
            triggerTime = 540,
            message = "[PHASE 4] WALL BREACHED! Draven's reinforcements arriving! Hold for 3 minutes!",
            notifType = "warning",
            duration = 15,
        },
        {
            name = "phase_4_dialogue",
            type = "dialogue",
            triggerTime = 550,
            dialogue = {
                character = "Lord Draven",
                text = "Markus! Misliš, da si zmagal? Moji zavezniki prihajajo!",
            },
        },
        -- Time of day - dusk (dramatic)
        {
            name = "time_dusk",
            type = "set_time",
            triggerTime = 560,
            timePeriod = "dusk",
        },
        -- Reinforcements wave 1
        {
            name = "reinforcements_1",
            type = "spawn_enemy",
            triggerTime = 580,
            units = {
                {type = "Knight", offsetX = 20, offsetY = 0, faction = 2},
                {type = "Knight", offsetX = 22, offsetY = 0, faction = 2},
                {type = "Knight", offsetX = 24, offsetY = 0, faction = 2},
                {type = "Swordsman", offsetX = 26, offsetY = 3, faction = 2},
                {type = "Swordsman", offsetX = 28, offsetY = 3, faction = 2},
                {type = "Maceman", offsetX = 30, offsetY = -3, faction = 2},
                {type = "Maceman", offsetX = 32, offsetY = -3, faction = 2},
                {type = "Crossbowman", offsetX = 34, offsetY = 2, faction = 2},
                {type = "Crossbowman", offsetX = 36, offsetY = 2, faction = 2},
                {type = "Archer", offsetX = 38, offsetY = -2, faction = 2},
            },
            location = {gx = 50, gy = 50},
        },
        -- Reinforcements wave 2
        {
            name = "reinforcements_2",
            type = "spawn_enemy",
            triggerTime = 660,
            units = {
                {type = "Knight", offsetX = 18, offsetY = 0, faction = 2},
                {type = "Knight", offsetX = 20, offsetY = 0, faction = 2},
                {type = "Knight", offsetX = 22, offsetY = 0, faction = 2},
                {type = "Knight", offsetX = 24, offsetY = 0, faction = 2},
                {type = "Swordsman", offsetX = 26, offsetY = 4, faction = 2},
                {type = "Swordsman", offsetX = 28, offsetY = 4, faction = 2},
                {type = "Swordsman", offsetX = 30, offsetY = 4, faction = 2},
                {type = "Maceman", offsetX = 32, offsetY = -4, faction = 2},
                {type = "Maceman", offsetX = 34, offsetY = -4, faction = 2},
                {type = "Crossbowman", offsetX = 36, offsetY = -2, faction = 2},
                {type = "Crossbowman", offsetX = 38, offsetY = -2, faction = 2},
                {type = "Archer", offsetX = 40, offsetY = 2, faction = 2},
            },
            location = {gx = 50, gy = 50},
        },

        -- === PHASE 5: FINAL ASSAULT ON THE KEEP ===
        {
            name = "phase_5_start",
            type = "notification",
            triggerTime = 720,
            message = "[PHASE 5] Reinforcements repelled! FINAL ASSAULT on Draven's Keep!",
            notifType = "warning",
            duration = 15,
        },
        {
            name = "phase_5_dialogue_1",
            type = "dialogue",
            triggerTime = 730,
            dialogue = {
                character = "Sir Markus",
                text = "Draven! Zadnjič se srečava. Pripravi se!",
            },
        },
        {
            name = "phase_5_dialogue_2",
            type = "dialogue",
            triggerTime = 738,
            dialogue = {
                character = "Lord Draven",
                text = "Markus, ne boš vzel mojega prestola! Bolje uničiti ga kot prepustiti!",
            },
        },
        -- Time of day - night (final battle)
        {
            name = "time_night",
            type = "set_time",
            triggerTime = 740,
            timePeriod = "night",
        },
        -- Weather - storm (epic finale)
        {
            name = "weather_storm",
            type = "set_weather",
            triggerTime = 745,
            weather = "storm",
        },
        -- Draven's elite guard
        {
            name = "draven_elite_guard",
            type = "spawn_enemy",
            triggerTime = 760,
            units = {
                {type = "Knight", offsetX = 15, offsetY = 0, faction = 2},
                {type = "Knight", offsetX = 17, offsetY = 0, faction = 2},
                {type = "Knight", offsetX = 19, offsetY = 0, faction = 2},
                {type = "Knight", offsetX = 21, offsetY = 0, faction = 2},
                {type = "Knight", offsetX = 23, offsetY = 0, faction = 2},
                {type = "Swordsman", offsetX = 16, offsetY = 4, faction = 2},
                {type = "Swordsman", offsetX = 18, offsetY = 4, faction = 2},
                {type = "Swordsman", offsetX = 20, offsetY = 4, faction = 2},
                {type = "Swordsman", offsetX = 22, offsetY = 4, faction = 2},
                {type = "Maceman", offsetX = 24, offsetY = -4, faction = 2},
                {type = "Maceman", offsetX = 26, offsetY = -4, faction = 2},
                {type = "Crossbowman", offsetX = 28, offsetY = -2, faction = 2},
                {type = "Crossbowman", offsetX = 30, offsetY = -2, faction = 2},
                {type = "Crossbowman", offsetX = 32, offsetY = -2, faction = 2},
                {type = "Archer", offsetX = 34, offsetY = 2, faction = 2},
            },
            location = {gx = 50, gy = 50},
        },

        -- === PHASE 6: VICTORY AND CONCLUSION ===
        {
            name = "victory_dialogue_1",
            type = "dialogue",
            triggerTime = 0,  -- conditional on winning
            dialogue = {
                character = "Lord Draven",
                text = "Ne... moje kraljestvo... Markus, ti si...",
            },
        },
        {
            name = "victory_dialogue_2",
            type = "dialogue",
            triggerTime = 0,
            dialogue = {
                character = "Sir Markus",
                text = "Končano je, Draven. Valdemar je prost.",
            },
        },
        {
            name = "victory_dialogue_3",
            type = "dialogue",
            triggerTime = 0,
            dialogue = {
                character = "Lady Elara",
                text = "Markus, storil si to. Ljudstvo je prosto.",
            },
        },
        {
            name = "victory_dialogue_4",
            type = "dialogue",
            triggerTime = 0,
            dialogue = {
                character = "Brother Cedric",
                text = "Dolga pot je končana. A nova začenja se. Dolgo živl kralj Markus!",
            },
        },
        {
            name = "victory_dialogue_5",
            type = "dialogue",
            triggerTime = 0,
            dialogue = {
                character = "Captain Roric",
                text = "Kralj Markus! Naj bo vaša vladavina modra in pravična.",
            },
        },
        {
            name = "victory_notification",
            type = "notification",
            triggerTime = 0,
            message = "=== KAMPANJA KONČANA === Sir Markus je postal kralj Valdemarja! Hvala za igranje!",
            notifType = "success",
            duration = 30,
        },
        {
            name = "credits_notification",
            type = "notification",
            triggerTime = 0,
            message = "Castle Kingdoms 2027 - The Lord of Fernhaven. Zahvale: Stone Kingdoms community, Stone Kingdoms, LÖVE",
            notifType = "info",
            duration = 20,
        },
    },

    dialogues = {
        {
            character = "Sir Markus",
            text = "Za Valdemar. Za Elaro. Za našo prihodnost.",
        },
    },

    rewards = {
        gold = 5000,
        iron = 200,
        -- Special: campaign completion achievement
        achievement = "king_of_valdemar",
    },

    config = {
        timeLimit = 0,
        aiOpponents = {
            {
                faction = 2,  -- Lord Draven (final boss)
                personality = "aggressive",
                difficulty = "brutal",  -- highest difficulty
                spawnLocation = {gx = 85, gy = 85},
                isBoss = true,
                isFinalBoss = true,
            },
        },
        startingBuildings = {},
    },

    -- No next mission - this is the finale
    nextMission = nil,

    -- Campaign completion flag
    isCampaignFinale = true,
}

return mission
