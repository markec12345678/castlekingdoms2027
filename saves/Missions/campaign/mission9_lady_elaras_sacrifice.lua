-- saves/Missions/campaign/mission9_lady_elaras_sacrifice.lua
-- Stronghold 2027 - Campaign Mission 9: Lady Elara's Sacrifice
--
-- Ninth mission of "The Lord of Fernhaven" campaign.
-- The most emotional mission - rescue the captive Lady Elara.
-- Multiple objectives simultaneously, time pressure, difficult choices.
--
-- Story: Draven has captured Lady Elara! He demands 2000 gold or her head.
-- But Captain Roric suggests a rescue operation. You must:
-- - Gather ransom money (in case diplomacy fails)
-- - Simultaneously prepare a strike force for rescue
-- - Make a difficult choice: pay the ransom OR attempt rescue
--
-- This mission has TWO PATHS to victory:
-- Path A (Diplomatic): Accumulate 2000 gold and pay the ransom
-- Path B (Military): Build strike force and destroy Draven's prison

local mission = {
    key = "mission9_lady_elaras_sacrifice",
    name = "Lady Elara's Sacrifice",
    nameSlv = "Žrtev Lady Elare",
    description = "Draven holds Lady Elara captive! Gather ransom or attempt a daring rescue.",
    descriptionSlv = "Draven drži Lady Elaro kot talec! Zberi odkupnino ali poskusi drzno reševanje.",

    map = "fernhaven",
    startingResources = {
        gold = 1500,
        wood = 150,
        stone = 100,
        iron = 40,
        food = 80,
    },

    objectives = {
        -- Path A: Diplomatic (gather ransom)
        {
            id = 1,
            type = "reach_gold",
            target = 2000,
            description = "[Path A] Gather 2000 gold for ransom",
            descriptionSlv = "[Pot A] Zberi 2000 zlata za odkupnino",
            critical = false,  -- alternative path
        },
        -- Path B: Military (build strike force)
        {
            id = 2,
            type = "recruit_units",
            unit = "Knight",
            count = 8,
            description = "[Path B] Recruit 8 Knights for rescue force",
            descriptionSlv = "[Pot B] Rekrutiraj 8 vitezov za reševalno ekipo",
            critical = false,  -- alternative path
        },
        {
            id = 3,
            type = "recruit_units",
            unit = "Archer",
            count = 10,
            description = "[Path B] Recruit 10 Archers for support",
            descriptionSlv = "[Pot B] Rekrutiraj 10 lokostrelcev za podporo",
            critical = false,
        },
        -- Either path requires this
        {
            id = 4,
            type = "destroy_buildings",
            count = 1,
            description = "[Path B] Destroy Draven's Prison (rescue Elara)",
            descriptionSlv = "[Pot B] Uniči Dravenov zapor (reši Elaro)",
            critical = false,
        },
        -- Survival - Draven attacks periodically
        {
            id = 5,
            type = "survive_time",
            duration = 480,  -- 8 minutes
            description = "Survive Draven's pressure (8 minutes)",
            descriptionSlv = "Preživi Dravenov pritisk (8 minut)",
            critical = true,
        },
    },

    events = {
        -- Intro - the kidnapping revealed
        {
            name = "intro_dialogue_1",
            type = "dialogue",
            triggerTime = 1,
            dialogue = {
                character = "Captain Roric",
                text = "Sir Markus! Lady Elara je izginila. Dravenovi vohuni so jo ujeli!",
            },
        },
        {
            name = "intro_dialogue_2",
            type = "dialogue",
            triggerTime = 8,
            dialogue = {
                character = "Lord Draven",
                text = "Markus! Imam tvojo ljubico. 2000 zlata ali njena glava.",
            },
        },
        {
            name = "intro_dialogue_3",
            type = "dialogue",
            triggerTime = 16,
            dialogue = {
                character = "Sir Markus",
                text = "Draven, ti zver. Če ji kaj storis...",
            },
        },
        {
            name = "intro_dialogue_4",
            type = "dialogue",
            triggerTime = 24,
            dialogue = {
                character = "Captain Roric",
                text = "Imamo dve možnosti. Plačamo odkupnino ali izvedemo reševanje.",
            },
        },
        {
            name = "intro_dialogue_5",
            type = "dialogue",
            triggerTime = 32,
            dialogue = {
                character = "Brother Cedric",
                text = "Plačilo krepí Dravena. Reševanje je tvegano, a častno.",
            },
        },
        -- Tutorial - two paths
        {
            name = "tutorial_paths",
            type = "notification",
            triggerTime = 40,
            message = "TWO PATHS: Gather 2000 gold (diplomacy) OR build strike force (military rescue)!",
            notifType = "info",
            duration = 12,
        },
        {
            name = "tutorial_path_a",
            type = "notification",
            triggerTime = 60,
            message = "[Path A] Trade with caravans (C key) for faster gold accumulation.",
            notifType = "info",
            duration = 10,
        },
        {
            name = "tutorial_path_b",
            type = "notification",
            triggerTime = 80,
            message = "[Path B] Build Engineers Guild and Stone Barracks for elite units.",
            notifType = "info",
            duration = 10,
        },
        -- Weather - ominous
        {
            name = "weather_fog",
            type = "set_weather",
            triggerTime = 100,
            weather = "fog",
        },
        -- Draven's taunts
        {
            name = "draven_taunt_1",
            type = "dialogue",
            triggerTime = 120,
            dialogue = {
                character = "Lord Draven",
                text = "Čas teče, Markus. Vsak ura pomeni trpljenje za Elaro.",
            },
        },
        -- Draven sends pressure attack 1
        {
            name = "pressure_attack_1_warning",
            type = "notification",
            triggerTime = 150,
            message = "Draven sends a raid! He wants to weaken you before ransom.",
            notifType = "warning",
            duration = 8,
        },
        {
            name = "pressure_attack_1",
            type = "spawn_enemy",
            triggerTime = 170,
            units = {
                {type = "Maceman", offsetX = 22, offsetY = 0, faction = 2},
                {type = "Maceman", offsetX = 24, offsetY = 0, faction = 2},
                {type = "Spearman", offsetX = 26, offsetY = 2, faction = 2},
                {type = "Archer", offsetX = 28, offsetY = -2, faction = 2},
                {type = "Archer", offsetX = 30, offsetY = -2, faction = 2},
            },
            location = {gx = 50, gy = 50},
        },
        -- Elara's voice (hope)
        {
            name = "elara_voice",
            type = "dialogue",
            triggerTime = 220,
            dialogue = {
                character = "Lady Elara",
                text = "Markus... ne plačaj. Draven te bo izdal. Reši me z vojsko...",
            },
        },
        -- Draven's second taunt
        {
            name = "draven_taunt_2",
            type = "dialogue",
            triggerTime = 280,
            dialogue = {
                character = "Lord Draven",
                text = "Ali že obupujes? Morda naj jo končam...",
            },
        },
        -- Weather change - rain
        {
            name = "weather_rain",
            type = "set_weather",
            triggerTime = 300,
            weather = "rain",
        },
        -- Pressure attack 2 - bigger
        {
            name = "pressure_attack_2_warning",
            type = "notification",
            triggerTime = 320,
            message = "Draven's forces approaching! Larger assault incoming!",
            notifType = "warning",
            duration = 8,
        },
        {
            name = "pressure_attack_2",
            type = "spawn_enemy",
            triggerTime = 340,
            units = {
                {type = "Swordsman", offsetX = 20, offsetY = 0, faction = 2},
                {type = "Swordsman", offsetX = 22, offsetY = 0, faction = 2},
                {type = "Knight", offsetX = 24, offsetY = 0, faction = 2},
                {type = "Maceman", offsetX = 26, offsetY = 2, faction = 2},
                {type = "Maceman", offsetX = 28, offsetY = 2, faction = 2},
                {type = "Crossbowman", offsetX = 30, offsetY = -2, faction = 2},
                {type = "Crossbowman", offsetX = 32, offsetY = -2, faction = 2},
            },
            location = {gx = 50, gy = 50},
        },
        -- Choice reminder
        {
            name = "choice_reminder",
            type = "notification",
            triggerTime = 400,
            message = "DECISION TIME: Pay 2000 gold ransom OR attack Draven's Prison!",
            notifType = "warning",
            duration = 12,
        },
        -- Final pressure attack
        {
            name = "pressure_attack_3_warning",
            type = "notification",
            triggerTime = 440,
            message = "FINAL ASSAULT! Draven wants to break you before Elara is saved!",
            notifType = "warning",
            duration = 10,
        },
        {
            name = "pressure_attack_3",
            type = "spawn_enemy",
            triggerTime = 450,
            units = {
                {type = "Knight", offsetX = 18, offsetY = 0, faction = 2},
                {type = "Knight", offsetX = 20, offsetY = 0, faction = 2},
                {type = "Knight", offsetX = 22, offsetY = 0, faction = 2},
                {type = "Swordsman", offsetX = 24, offsetY = 3, faction = 2},
                {type = "Swordsman", offsetX = 26, offsetY = 3, faction = 2},
                {type = "Swordsman", offsetX = 28, offsetY = 3, faction = 2},
                {type = "Maceman", offsetX = 25, offsetY = -3, faction = 2},
                {type = "Maceman", offsetX = 27, offsetY = -3, faction = 2},
                {type = "Crossbowman", offsetX = 30, offsetY = -2, faction = 2},
                {type = "Crossbowman", offsetX = 32, offsetY = -2, faction = 2},
            },
            location = {gx = 50, gy = 50},
        },
        -- Victory dialogues (depend on path taken)
        {
            name = "victory_dialogue_military",
            type = "dialogue",
            triggerTime = 0,  -- conditional
            dialogue = {
                character = "Lady Elara",
                text = "Markus! Rešil si me. Draven te bo plačal za to.",
            },
        },
        {
            name = "victory_dialogue_diplomatic",
            type = "dialogue",
            triggerTime = 0,  -- conditional
            dialogue = {
                character = "Lady Elara",
                text = "Si plačal zame, Markus. A Draven bo še obžaloval.",
            },
        },
        -- Story setup for finale
        {
            name = "story_setup",
            type = "dialogue",
            triggerTime = 0,
            dialogue = {
                character = "Captain Roric",
                text = "Elara je varna. Sedaj je čas za zadnji obračun. Na prestolnico!",
            },
        },
        {
            name = "story_setup_2",
            type = "dialogue",
            triggerTime = 0,
            dialogue = {
                character = "Sir Markus",
                text = "Draven, tvoja vladavina tiranije se konča danes.",
            },
        },
    },

    dialogues = {
        {
            character = "Sir Markus",
            text = "Za Elaro. Za Fernhaven. Za končno pravico.",
        },
    },

    rewards = {
        gold = 500,
        iron = 30,
    },

    config = {
        timeLimit = 0,
        aiOpponents = {
            {
                faction = 2,  -- Draven
                personality = "aggressive",
                difficulty = "hard",
                spawnLocation = {gx = 85, gy = 85},
            },
        },
        startingBuildings = {},
    },

    nextMission = "mission10_the_throne_of_valdemar",
}

return mission
