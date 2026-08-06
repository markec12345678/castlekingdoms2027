-- objects/QA/MissionTestSuite.lua
-- Stronghold 2027 - Mission Test Suite
--
-- Automated tests for all 10 campaign missions.

local MissionTestSuite = {}

local MISSIONS = {
    "campaign.mission1_return_to_fernhaven",
    "campaign.mission2_first_defenders",
    "campaign.mission3_alliance_with_westmarsh",
    "campaign.mission4_the_iron_hills",
    "campaign.mission5_the_bandit_king",
    "campaign.mission6_betrayal_at_eastvale",
    "campaign.mission7_the_northern_pass",
    "campaign.mission8_the_cathedral",
    "campaign.mission9_lady_elaras_sacrifice",
    "campaign.mission10_the_throne_of_valdemar",
}

function MissionTestSuite.testMission(missionKey)
    local result = {
        mission = missionKey,
        passed = false,
        errors = {},
        warnings = {},
        checks = {},
    }

    local ok, missionData = pcall(require, "saves.Missions." .. missionKey)
    if not ok then
        table.insert(result.errors, "Failed to load: " .. tostring(missionData))
        return result
    end
    table.insert(result.checks, "Mission loads")

    if not missionData then
        table.insert(result.errors, "Mission data is nil")
        return result
    end

    local requiredFields = {"name", "description", "objectives"}
    for _, field in ipairs(requiredFields) do
        if missionData[field] == nil then
            table.insert(result.errors, "Missing field: " .. field)
        else
            table.insert(result.checks, "Has " .. field)
        end
    end

    if missionData.objectives then
        if type(missionData.objectives) ~= "table" then
            table.insert(result.errors, "Objectives must be a table")
        elseif #missionData.objectives == 0 then
            table.insert(result.warnings, "No objectives defined")
        else
            table.insert(result.checks, #missionData.objectives .. " objectives")
        end
    end

    if missionData.winCondition then
        table.insert(result.checks, "Has win condition")
    else
        table.insert(result.warnings, "No winCondition")
    end

    if missionData.loseCondition then
        table.insert(result.checks, "Has lose condition")
    else
        table.insert(result.warnings, "No loseCondition")
    end

    if missionData.startingResources then
        table.insert(result.checks, "Has starting resources")
    end

    result.passed = #result.errors == 0
    return result
end

function MissionTestSuite.runAll()
    local results = {
        total = #MISSIONS,
        passed = 0,
        failed = 0,
        missions = {},
    }

    for _, missionKey in ipairs(MISSIONS) do
        local result = MissionTestSuite.testMission(missionKey)
        table.insert(results.missions, result)
        if result.passed then
            results.passed = results.passed + 1
        else
            results.failed = results.failed + 1
        end
    end

    return results
end

function MissionTestSuite.printResults(results)
    print("\n" .. string.rep("=", 60))
    print("MISSION TEST SUITE RESULTS")
    print(string.rep("=", 60))
    print(string.format("Total: %d  |  Passed: %d  |  Failed: %d",
        results.total, results.passed, results.failed))
    print(string.rep("-", 60))

    for _, result in ipairs(results.missions) do
        local status = result.passed and "PASS" or "FAIL"
        print(string.format("\n[%s] %s", status, result.mission))
        for _, check in ipairs(result.checks) do
            print("  OK: " .. check)
        end
        for _, warning in ipairs(result.warnings) do
            print("  WARN: " .. warning)
        end
        for _, error in ipairs(result.errors) do
            print("  ERR: " .. error)
        end
    end

    print(string.rep("=", 60))
    return results
end

return MissionTestSuite
