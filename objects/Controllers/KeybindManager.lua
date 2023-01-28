---@class KeybindManager
local KeybindManager = _G.class("KeybindManager")
local json = require("libraries.json")
local EVENT = require("objects.Enums.KeyEvents")

function KeybindManager:initialize()
    ---@type table<keyEvents, love.KeyConstant[]>
    self.keybinds = {
        [EVENT.IncreaseGameSpeed]  = {"+", "kp+"},
        [EVENT.NormalizeGameSpeed] = {"="},
        [EVENT.DecreaseGameSpeed]  = {"-", "kp-"},
        [EVENT.Screenshot]         = {"f12"},
        [EVENT.Escape]             = {"escape"},
        [EVENT.ToggleDebugView]    = {"v"},
        [EVENT.CamUp]              = {"w", "up"},
        [EVENT.CamLeft]            = {"a", "left"},
        [EVENT.CamDown]            = {"s", "down"},
        [EVENT.CamRight]           = {"d", "right"}
    }
end

--How to use:
-- 1. Add your desired keybind to the above table like this:
-- [EVENT.GenericNameHere] = {"key", "alternativekey"},

-- 2. Add your desired keybind to \objects\Enums\KeyEvents script in it's table like this:
-- GenericNameHere   = "GenericNameHere",

-- 3. Require the KeybindManager in your script.
-- local keybindManager = require("objects.Controllers.KeybindManager")

-- 4. Require the KeyEvents in your script.
-- local EVENT = require("objects.Enums.KeyEvents")

-- 5. Add this line of code in a keypressed() callback.
-- local event = keybindManager:getEventForKeypress(key)

-- 6. Utilize your keybind in if statements.
-- if event == EVENT.GenericNameHere

-- 7. Done.


--- Assigns a key to a certain Keybind.
---@param keyInput love.KeyConstant
---@param event keyEvents
function KeybindManager:mapKey(keyInput, event)
    -- check if key is already associated with this event
    if self:isKeyAssignedToEvent(keyInput, event) then return end
    table.insert(self.keybinds[event], keyInput)
end

--- Checks if a key is assigned to an event.
---@param key love.KeyConstant
---@param event keyEvents
---@return boolean
function KeybindManager:isKeyAssignedToEvent(key, event)
    if self.keybinds[event] then
        for _, comparedKey in ipairs(self.keybinds[event]) do
            if key == comparedKey then return true end
        end
    end
    return false
end

--- Returns an event that matches the input key.
---@param key love.KeyConstant
---@return keyEvents|false
function KeybindManager:getEventForKeypress(key)
    for event, _ in pairs(self.keybinds) do
        if self:isKeyAssignedToEvent(key, event) then
            return event
        end
    end
    return false
end

--- Validates if the keybinds table is in proper format.
---@private
---@return boolean valid the keybinds table is formatted
function KeybindManager:validateKeybindsTable(keybinds)
    if type(keybinds) ~= "table" then return false end
    for key, value in pairs(keybinds) do
        if EVENT[key] == nil then return false end
        if type(value) ~= "table" then return false end
        for _, scancode in ipairs(value) do
            if type(scancode) ~= "string" then return false end
        end
    end
    return true
end

--- Saves the current Keybinds to the .json file, if the file does not exists, it creates one.
function KeybindManager:saveKeybinds()
    if not love.filesystem.getInfo("keybinds.json") then
        love.filesystem.write("keybinds.json", "")
        print("Writing new Keybinds file!")
    end
    love.filesystem.write("keybinds.json", json.encode(self.keybinds))
end

--- Loads the Keybinds out of the keybind .json file, if it exists.
function KeybindManager:loadKeybinds()
    if love.filesystem.getInfo("keybinds.json") then
        local loadedKeybinds = json.decode(love.filesystem.read("keybinds.json"))
        -- Check for missing keybindings
        local incomplete = false
        for key, value in pairs(self.keybinds) do
            if not loadedKeybinds[key] then
                print("Keybinds incomplete, added missing keybindings for", key)
                incomplete = true
                loadedKeybinds[key] = value
            end
        end
        if self:validateKeybindsTable(loadedKeybinds) then
            self.keybinds = loadedKeybinds
            print("Found a valid keybind file!")
            if incomplete then
                self:saveKeybinds()
            end
        else
            print("Found keybinds, but they are not valid. Falling back to defaults.")
            self:saveKeybinds()
        end
    else
        print("No keybind file found, generating one...")
        self:saveKeybinds()
    end
end

---@type KeybindManager
local manager = KeybindManager:new()
return manager
