local bitser = require("libraries.bitser")

local SaveManager = _G.class("SaveManager")
function SaveManager:initialize()
    self.savefiles = {}
end
function SaveManager:getSaveFiles()
    local files = love.filesystem.getDirectoryItems(_G.SAVEGAME_DIR)
    for _, file in ipairs(files) do
        if string.find(file, "_metadata.bin") then
            self.savefiles[#self.savefiles + 1] = bitser.loadLoveFile(_G.SAVEGAME_DIR .. "/" .. file)
        end
    end
    print(string.format("Found %d save files", #self.savefiles))
end
function SaveManager:save()
    print("Saving game..")
    local state, metastate = _G.state:save()
    local savename = string.format("%s/%s.bin", _G.SAVEGAME_DIR, string.lower(metastate.name))
    local savenameMeta = string.format("%s/%s_metadata.bin", _G.SAVEGAME_DIR, string.lower(metastate.name))
    bitser.dumpLoveFile(savename, state)
    bitser.dumpLoveFile(savenameMeta, metastate)
end
return SaveManager:new()
