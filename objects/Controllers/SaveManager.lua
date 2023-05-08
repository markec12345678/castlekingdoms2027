local bitser = require("libraries.bitser")
local loveframes = require("libraries.loveframes")

local SaveManager = _G.class("SaveManager")
function SaveManager:initialize()
    self.savefiles = {}
    self.userInterface = {}
    self.lastNameIndex = 1
    self.defaultMap = {}
    self.fromPauseMenu = false
end

function SaveManager:getSaveFiles()
    local files = love.filesystem.getDirectoryItems(_G.SAVEGAME_DIR)
    for _, file in ipairs(files) do
        if string.find(file, "_metadata.bin") then
            self.savefiles[#self.savefiles + 1] = bitser.loadLoveFile(_G.SAVEGAME_DIR .. "/" .. file, false)
            if self.savefiles[#self.savefiles].isMap then
                self.defaultMap = self.savefiles[#self.savefiles]
            end
        end
    end
    print(string.format("Found %d save files", #self.savefiles))
    self:sortByDate()
end

function SaveManager:sortByDate()
    table.sort(self.savefiles, function(save1, save2)
        local date1 = save1.dateModified:gsub("-", ""):gsub(":", ""):gsub(" ", "")
        local date2 = save2.dateModified:gsub("-", ""):gsub(":", ""):gsub(" ", "")
        return date1 > date2
    end)
end

function SaveManager:getNextFreeName()
    if #self.savefiles == 0 then
        return "savefile 1"
    end
    for i = self.lastNameIndex, 1000 do
        local potentialName = string.format("savefile %d", i)
        local found = false
        for _, v in ipairs(self.savefiles) do
            if potentialName == v.name then
                found = true
            end
        end
        if not found then
            self.lastNameIndex = i
            return potentialName
        end
    end
end

function SaveManager:delete(name)
    local idxToRemove
    for index, save in ipairs(self.savefiles) do
        if save.name == name then
            love.filesystem.remove(string.format("%s/%s.bin", _G.SAVEGAME_DIR, name))
            love.filesystem.remove(string.format("%s/%s_metadata.bin", _G.SAVEGAME_DIR, name))
            idxToRemove = index
            break
        end
    end
    table.remove(self.savefiles, idxToRemove)
    self:updateInterface()
end

function SaveManager:save()
    local state, metastate = _G.state:save()
    self.savefiles[#self.savefiles + 1] = metastate
    local savename = string.format("%s/%s.bin", _G.SAVEGAME_DIR, string.lower(metastate.name))
    local savenameMeta = string.format("%s/%s_metadata.bin", _G.SAVEGAME_DIR, string.lower(metastate.name))
    bitser.dumpLoveFile(savename, state)
    bitser.dumpLoveFile(savenameMeta, metastate, true)
    self:sortByDate()
end

function SaveManager:load(name)
    local filename = string.format("%s/%s.bin", _G.SAVEGAME_DIR, name)
    _G.state.newGame = false
    for _, save in ipairs(self.savefiles) do
        if save.name == name then
            if save.isMap then
                _G.state.newGame = true
            end
            if self.fromPauseMenu then
                loveframes.TogglePause()
                if _G.state then _G.state:destroy() end
                loveframes.SetState()
                collectgarbage()
            end
            _G.state:load(filename, save.compressed)
            return
        end
    end
end

function SaveManager:registerListItem(item, i)
    self.userInterface[i] = item
end

function SaveManager:updateInterface(fromPauseMenu)
    self.fromPauseMenu = fromPauseMenu
    for i = 1, 8 do
        if self.userInterface[i] then
            self.userInterface[i]:hide()
        end
    end
    for index, savegame in ipairs(self.savefiles) do
        if index > 8 then
            -- TODO: add pagination
            return
        end
        if savegame.isMap then
            return
        end
        self.userInterface[index]:setValues(savegame.name, savegame.mapName, savegame.dateModified, savegame.version)
        self.userInterface[index]:show()
    end
end

return SaveManager:new()
