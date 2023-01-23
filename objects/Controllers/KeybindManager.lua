---@class KeybindManager
local KeybindManager = _G.class("KeybindManager")
local json = require "libraries.json"

function KeybindManager:initialize()
    self.keybinds =
    {
        increaseGameSpeedKey  = "+",
        normalizeGameSpeedKey = "=",
        decreaseGameSpeedKey  = "-",
        screenshotKey         = "f12",
        escapeKey             = "escape"
    }
end

--- Assigns a key to a certain Keybind.
---@param keyInput string
---@param keybindName string
function KeybindManager:mapKey(keyInput, keybindName)
    self.keybinds[keybindName] = keyInput
end

--- Returns a keybind.
---@param keybindName string
---@return string
function KeybindManager:returnKey(keybindName)
    return self.keybinds[keybindName]
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
        self.keybinds = json.decode(love.filesystem.read("keybinds.json"))
        print("Found keybind file!")
    else
        print("No keybind file found!")
    end
end

---@type KeybindManager
local manager = KeybindManager:new()
return manager
