-- objects/QA/SaveGameCompatibility.lua
-- Castle Kingdoms 2027 - Save Game Compatibility
-- Versioned saves with migration support

local SaveCompat = {}

local SAVE_VERSION = 1
local SAVE_MAGIC = "SH2027"

-- Migration functions: version N -> version N+1
local migrations = {
    [1] = function(data)
        -- v1 -> v2 migration (placeholder for future)
        return data
    end,
}

function SaveCompat.init()
    print("[SaveCompat] Initialized (current version: " .. SAVE_VERSION .. ")")
end

-- Get current save version
function SaveCompat.getVersion()
    return SAVE_VERSION
end

-- Serialize save data with version header
function SaveCompat.serialize(data)
    if not data then return nil end

    local saveData = {
        magic = SAVE_MAGIC,
        version = SAVE_VERSION,
        timestamp = os.time(),
        gameVersion = _G.version or "1.18.0",
        data = data,
    }

    -- Simple serialization
    local function serializeValue(val, indent)
        indent = indent or ""
        local t = type(val)
        if t == "nil" then return "nil"
        elseif t == "boolean" then return tostring(val)
        elseif t == "number" then return tostring(val)
        elseif t == "string" then return '"' .. val:gsub('"', '\\"') .. '"'
        elseif t == "table" then
            local parts = {"{"}
            local isArray = true
            local count = 0
            for k, _ in pairs(val) do
                count = count + 1
                if type(k) ~= "number" then isArray = false end
            end
            if count == 0 then return "{}" end

            if isArray then
                for i = 1, count do
                    parts[#parts + 1] = serializeValue(val[i], indent .. "  ") .. ","
                end
            else
                for k, v in pairs(val) do
                    local key = type(k) == "string" and k or "[" .. tostring(k) .. "]"
                    parts[#parts + 1] = indent .. "  " .. key .. " = " .. serializeValue(v, indent .. "  ") .. ","
                end
            end
            parts[#parts + 1] = indent .. "}"
            return table.concat(parts, "\n")
        end
        return "nil"
    end

    return serializeValue(saveData)
end

-- Deserialize and migrate save data
function SaveCompat.deserialize(content)
    if not content then return nil, "No content" end

    local ok, saveData = pcall(load, content)
    if not ok or not saveData then
        return nil, "Failed to parse save data"
    end

    local dataOk, data = pcall(saveData)
    if not dataOk or type(data) ~= "table" then
        return nil, "Invalid save data format"
    end

    -- Check magic
    if data.magic ~= SAVE_MAGIC then
        return nil, "Invalid save file (wrong magic: " .. tostring(data.magic) .. ")"
    end

    -- Check version and migrate if needed
    local version = data.version or 1
    if version > SAVE_VERSION then
        return nil, "Save file is from a newer version (" .. version .. " > " .. SAVE_VERSION .. ")"
    end

    -- Run migrations
    while version < SAVE_VERSION do
        local migration = migrations[version]
        if not migration then
            return nil, "No migration path from version " .. version
        end
        data.data = migration(data.data)
        version = version + 1
    end

    return data.data, nil
end

-- Save to file
function SaveCompat.save(filename, data)
    local content = SaveCompat.serialize(data)
    if not content then return false end

    local path = "saves/" .. filename .. ".sav"
    local file = love.filesystem.newFile(path)
    if file:open("w") then
        file:write(content)
        file:close()
        print("[SaveCompat] Saved to " .. path)
        return true
    end
    return false
end

-- Load from file
function SaveCompat.load(filename)
    local path = "saves/" .. filename .. ".sav"
    local file = love.filesystem.newFile(path)
    if not file:open("r") then
        return nil, "File not found: " .. path
    end

    local content = file:read()
    file:close()

    local data, err = SaveCompat.deserialize(content)
    if err then
        print("[SaveCompat] Load error: " .. err)
        return nil, err
    end

    print("[SaveCompat] Loaded from " .. path)
    return data, nil
end

-- List all saves
function SaveCompat.listSaves()
    local saves = {}
    local files = love.filesystem.getDirectoryItems("saves")
    for _, file in ipairs(files) do
        if file:match("%.sav$") then
            local name = file:gsub("%.sav$", "")
            local info = love.filesystem.getInfo("saves/" .. file)
            table.insert(saves, {
                name = name,
                size = info and info.size or 0,
                modified = info and info.modtime or 0,
            })
        end
    end
    table.sort(saves, function(a, b) return a.modified > b.modified end)
    return saves
end

-- Delete a save
function SaveCompat.deleteSave(filename)
    local path = "saves/" .. filename .. ".sav"
    return love.filesystem.remove(path)
end

return SaveCompat
