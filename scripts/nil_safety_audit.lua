-- scripts/nil_safety_audit.lua
-- Stronghold 2027 - Nil Safety Audit
--
-- Pregleda vse naše datoteke za potential nil crash-e:
-- - Dostop do .property brez prejšnjega nil check-a
-- - Primerjave z nil (a < 5 kjer a je lahko nil)
-- - _G.state.X brez preverbe _G.state
--
-- Run: lua scripts/nil_safety_audit.lua

local function readFile(path)
    local f = io.open(path, "r")
    if not f then return nil end
    local content = f:read("*all")
    f:close()
    return content
end

local function getLuaFiles(dir, results)
    results = results or {}
    local pipe = io.popen('find "' .. dir .. '" -name "*.lua" -type f 2>/dev/null | sort')
    for line in pipe:lines() do
        table.insert(results, line)
    end
    pipe:close()
    return results
end

-- Check for potential nil issues
local function auditFile(filepath)
    local content = readFile(filepath)
    if not content then return {} end

    local issues = {}
    local lines = {}
    for line in content:gmatch("[^\n]+") do
        table.insert(lines, line)
    end

    for i, line in ipairs(lines) do
        -- Skip comments
        if not line:match("^%s*%-%-") then
            -- Check for _G.state.X without prior nil check
            if line:match("_G%.state%.") and not line:match("if _G%.state")
               and not line:match("not _G%.state") and not line:match("or _G%.state")
               and not line:match("_G%.state and") then
                -- Check if previous line checks for _G.state
                local prevLine = lines[i - 1] or ""
                if not prevLine:match("if _G%.state") and not prevLine:match("not _G%.state")
                   and not prevLine:match("_G%.state and") then
                    -- Check if same line has check
                    if not line:match("if _G%.state") and not line:match("_G%.state and") then
                        table.insert(issues, {
                            line = i,
                            text = line:gsub("^%s+", ""),
                            type = "potential_nil_state",
                            severity = "warning",
                        })
                    end
                end
            end

            -- Check for resource comparison without nil-safe
            -- Pattern: resources.X < number or resources.X > number
            local resourceAccess = line:match("resources%.(%w+) [<>]")
            if resourceAccess and resourceAccess ~= "nil" then
                -- Check if line has nil-safe (or 0)
                if not line:match("or 0") and not line:match("local " .. resourceAccess) then
                    table.insert(issues, {
                        line = i,
                        text = line:gsub("^%s+", ""),
                        type = "resource_compare_without_nil_safe",
                        severity = "warning",
                        resource = resourceAccess,
                    })
                end
            end

            -- Check for unit.X without nil check (common crash source)
            if line:match("unit%.gx") or line:match("unit%.gy") or line:match("unit%.health") then
                if not line:match("if unit") and not line:match("unit and")
                   and not line:match("not unit") and not line:match("unit%.gx and") then
                    -- Check previous line
                    local prevLine = lines[i - 1] or ""
                    if not prevLine:match("if unit") and not prevLine:match("unit and") then
                        table.insert(issues, {
                            line = i,
                            text = line:gsub("^%s+", ""),
                            type = "potential_nil_unit",
                            severity = "info",
                        })
                    end
                end
            end

            -- Check for division by potential nil/zero
            if line:match("/ ([a-z]+)%.") and not line:match("if") then
                local divisor = line:match("/ ([a-z]+)%.")
                if divisor and (divisor == "self" or divisor == "target" or divisor == "unit") then
                    table.insert(issues, {
                        line = i,
                        text = line:gsub("^%s+", ""),
                        type = "potential_division_by_zero",
                        severity = "warning",
                    })
                end
            end
        end
    end

    return issues
end

-- Main
print("==========================================")
print("  Stronghold 2027 - Nil Safety Audit")
print("==========================================")
print("")

-- Get all our Lua files (exclude libraries, busted)
local files = getLuaFiles("objects")
local stateFiles = getLuaFiles("states")
local combatFiles = getLuaFiles("objects/Combat")
local aiFiles = getLuaFiles("objects/AI")
local economyFiles = getLuaFiles("objects/Economy")
local feedbackFiles = getLuaFiles("objects/Feedback")

-- Combine (our files only)
local allFiles = {}
for _, f in ipairs(files) do
    if not f:match("/libraries/") and not f:match("/busted/") then
        table.insert(allFiles, f)
    end
end
for _, f in ipairs(stateFiles) do
    table.insert(allFiles, f)
end

print("Auditing " .. #allFiles .. " files...")
print("")

local totalIssues = 0
local filesWithIssues = 0
local issuesByType = {}

for _, filepath in ipairs(allFiles) do
    local issues = auditFile(filepath)
    if #issues > 0 then
        filesWithIssues = filesWithIssues + 1
        totalIssues = totalIssues + #issues

        -- Count by type
        for _, issue in ipairs(issues) do
            issuesByType[issue.type] = (issuesByType[issue.type] or 0) + 1
        end

        -- Show first 5 issues per file
        print("📄 " .. filepath .. " (" .. #issues .. " issues)")
        for i = 1, math.min(5, #issues) do
            local issue = issues[i]
            print(string.format("   L%d [%s]: %s", issue.line, issue.severity, issue.text:sub(1, 80)))
        end
        if #issues > 5 then
            print(string.format("   ... and %d more", #issues - 5))
        end
        print("")
    end
end

print("==========================================")
print("  SUMMARY")
print("==========================================")
print(string.format("  Files audited:    %d", #allFiles))
print(string.format("  Files with issues: %d", filesWithIssues))
print(string.format("  Total issues:     %d", totalIssues))
print("")
print("  Issues by type:")
for issueType, count in pairs(issuesByType) do
    print(string.format("    %s: %d", issueType, count))
end
print("")
print("NOTE: These are POTENTIAL issues, not confirmed bugs.")
print("Many are false positives (e.g., already checked in earlier lines).")
print("Focus on 'warning' severity first.")
