-- Custom Building Definition: Gold Mine
-- A building that produces gold over time.

return {
    name = "GoldMine",
    displayName = "Gold Mine",
    description = "A mine that extracts gold from the earth. Produces 5 gold every 10 seconds.",
    cost = {
        wood = 50,
        stone = 30,
        gold = 0,
    },
    buildTime = 30,
    size = { w = 2, h = 2 },
    category = "industry",
    workers = 3,
    tier = 2,
    production = {
        input = {},
        output = { gold = 5 },
        rate = 10.0,  -- 10 second cycle
    },
}
