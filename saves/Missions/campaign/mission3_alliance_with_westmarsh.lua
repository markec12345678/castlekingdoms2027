-- saves/Missions/campaign/mission3_alliance_with_westmarsh.lua
-- Stronghold 2027 - Campaign Mission 3: Alliance with Westmarsh
--
-- Third mission of "The Lord of Fernhaven" campaign.
-- Introduces trade and diplomacy.
--
-- Objectives:
-- 1. Build a Market
-- 2. Accumulate 500 gold (via trade)
-- 3. Send 100 gold to Lady Elara as alliance gift
--
-- Story: Lady Elara of Westmarsh offers an alliance. She has rich resources
-- but a weak army. In exchange for your gold, she'll send food. Build a market
-- and establish trade relations.

local mission = {
    -- Metadata
    key = "mission3_alliance_with_westmarsh",
    name = "Alliance with Westmarsh",
    nameSlv = "Zavezništvo z Westmarshem",
    description = "Lady Elara offers an alliance. Build a market and send gold to seal the pact.",
    descriptionSlv = "Lady Elara ponuja zavezništvo. Zgradi trg in pošlji zlato za pečat zveze.",

    -- Mission setup
    map = "fernhaven",
    startingResources = {
        gold = 400,
        wood = 80,
        stone = 50,
        food = 20,
    },

    -- Objectives
    objectives = {
        {
            id = 1,
            type = "build_building",
            building = "Market",
            count = 1,
            description = "Build a Market",
            descriptionSlv = "Zgradi trg",
            critical = true,
        },
        {
            id = 2,
            type = "reach_gold",
            target = 500,
            description = "Accumulate 500 gold through trade",
            descriptionSlv = "Zberi 500 zlata s trgovino",
            critical = true,
        },
        {
            id = 3,
            type = "reach_gold",
            target = 600,  -- need extra 100 to send as gift
            description = "Send 100 gold to Lady Elara (have 600 total)",
            descriptionSlv = "Pošlji 100 zlata Lady Elari (imaj 600 skupno)",
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
                character = "Lady Elara",
                text = "Sir Markus, slišala sem za vašo obrambo proti banditom. Westmarsh ponuja zavezništvo.",
            },
        },
        {
            name = "intro_dialogue_2",
            type = "dialogue",
            triggerTime = 8,
            dialogue = {
                character = "Lady Elara",
                text = "Naše vire so bogati, a vojska šibka. V zameno za vaše zlato, pošiljala vam bom hrano.",
            },
        },
        {
            name = "intro_dialogue_3",
            type = "dialogue",
            triggerTime = 15,
            dialogue = {
                character = "Brother Cedric",
                text = "Modra poteza, Sir Markus. Zavezništvo z Westmarshem bo okrepilo naše položaje.",
            },
        },
        -- Tutorial
        {
            name = "tutorial_market",
            type = "notification",
            triggerTime = 20,
            message = "Build a Market to enable trade with other factions.",
            notifType = "info",
            duration = 8,
        },
        {
            name = "tutorial_caravan",
            type = "notification",
            triggerTime = 60,
            message = "Press C to open Caravan UI and send trade caravans to AI factions.",
            notifType = "info",
            duration = 10,
        },
        -- Weather event for atmosphere
        {
            name = "weather_rain",
            type = "set_weather",
            triggerTime = 90,
            weather = "rain",
        },
        -- Economic event
        {
            name = "trade_boom",
            type = "notification",
            triggerTime = 120,
            message = "Trade routes are flourishing! Sell prices increased by 20%.",
            notifType = "success",
            duration = 8,
        },
        -- Lady Elara's gift in return
        {
            name = "elara_gift",
            type = "notification",
            triggerTime = 180,
            message = "Lady Elara sends food as a gesture of goodwill! +50 food",
            notifType = "success",
            duration = 8,
        },
        -- Mid-mission hint
        {
            name = "hint_gold",
            type = "notification",
            triggerTime = 240,
            message = "Remember: Caravans give 30% better prices than local market!",
            notifType = "info",
            duration = 6,
        },
        -- Victory dialogue
        {
            name = "victory_dialogue",
            type = "dialogue",
            triggerTime = 300,
            dialogue = {
                character = "Lady Elara",
                text = "Zavezništvo je zapečateno. Skupaj bomo močni, Sir Markus.",
            },
        },
    },

    -- Story dialogues
    dialogues = {
        {
            character = "Lady Elara",
            text = "Westmarsh stoji ob vas, Sir Markus.",
        },
    },

    -- Rewards
    rewards = {
        gold = 200,
        food = 50,  -- bonus food from alliance
    },

    -- Mission configuration
    config = {
        timeLimit = 0,
        aiOpponents = {
            {
                faction = 3,  -- COMBAT.FACTION_ENEMY_2 - Lady Elara's faction (ally)
                personality = "balanced",
                difficulty = "easy",
                spawnLocation = {gx = 30, gy = 70},
                isAlly = true,  -- won't attack player
            },
        },
        startingBuildings = {},
    },

    -- Next mission
    nextMission = "mission4_the_iron_hills",
}

return mission
