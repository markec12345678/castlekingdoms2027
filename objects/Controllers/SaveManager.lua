local bitser = require("libraries.bitser")
local loveframes = require("libraries.loveframes")
local config = require("config_file")
local Events = require("objects.Enums.Events")

local SaveManager = _G.class("SaveManager")

SaveManager.static.AUTOSAVE_INTERVAL = config.general.autosaveInterval or -1

function SaveManager:initialize()
    self.savefiles = {}
    self.userInterface = {}
    self.lastNameIndex = 1
    self.defaultMap = {}
    self.fromPauseMenu = false
    self.autosaveEventCounter = 0

    self.savefileChunkSize = {}

    -- If autosave is turned on, register event listener on in-game time changed
    if (SaveManager.static.AUTOSAVE_INTERVAL >= 1) then
        _G.bus.on(Events.OnInGameTimeChanged, function()
            self:autosave()
        end)
    end
end

function SaveManager:getMapSizeInChunks(name)
    local foundMap = self.savefileChunkSize[name]
    if foundMap then
        return foundMap.w, foundMap.h
    end
    return 8, 8
end

function SaveManager:getSaveFiles()
    local files = love.filesystem.getDirectoryItems(_G.SAVEGAME_DIR)
    for _, file in ipairs(files) do
        if string.find(file, "_metadata.bin") then
            local metadataSave = bitser.loadLoveFile(_G.SAVEGAME_DIR .. "/" .. file, false)
            self.savefiles[#self.savefiles + 1] = metadataSave
            self.savefileChunkSize[metadataSave.name] = { w = metadataSave.w or 8, h = metadataSave.h or 8 }
            if metadataSave.isMap then
                -- TODO: fix, won't work with more than one map
                -- it works now because we only have fernhaven
                self.defaultMap = metadataSave
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

function SaveManager:findIndex(name)
    for index, save in ipairs(self.savefiles) do
        if save.name == name then
            return index
        end
    end
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
    -- Find the metastate in table of saves
    local idxToRemove = self:findIndex(name)
    if (type(idxToRemove) == 'nil') then
        -- Skip if save is not found
        return
    end

    -- Delete the local files
    love.filesystem.remove(string.format("%s/%s.bin", _G.SAVEGAME_DIR, name))
    love.filesystem.remove(string.format("%s/%s_metadata.bin", _G.SAVEGAME_DIR, name))

    -- Remove metastate from table of saves
    table.remove(self.savefiles, idxToRemove)

    self:updateInterface()
end

function SaveManager:save(name)
    local state, metastate = _G.state:save()

    -- Adjust save name, if custom was supplied
    metastate.name = name or string.lower(metastate.name)

    -- Save the local files
    local savename = string.format("%s/%s.bin", _G.SAVEGAME_DIR, metastate.name)
    local savenameMeta = string.format("%s/%s_metadata.bin", _G.SAVEGAME_DIR, metastate.name)

    bitser.dumpLoveFile(savename, state)
    bitser.dumpLoveFile(savenameMeta, metastate, true)

    -- Save metastate in table of saves
    local index = self:findIndex(metastate.name)
    if (type(index) == 'nil') then
        index = #self.savefiles + 1
    end

    self.savefiles[index] = metastate

    self:sortByDate()
end

function SaveManager:copy(originalName, newName)
    -- Initialize self, if necessary
    if (type(self.savefiles) == 'nil') then
        self:initialize()
        self:getSaveFiles()
    end

    -- Find the original metastate in table of saves
    local originalIndex = self:findIndex(originalName)
    if (type(originalIndex) == 'nil') then
        -- Skip, if the original save is not found
        return
    end
    local originalMetastate = self.savefiles[originalIndex]

    -- Create new metastate
    local newMetastate = loveframes.DeepCopy(originalMetastate)
    newMetastate.name = newName
    newMetastate.dateCreated = os.date("%Y-%m-%d %X")
    newMetastate.dateModified = newMetastate.dateCreated

    -- Load the original state
    local originalSavename = string.format("%s/%s.bin", _G.SAVEGAME_DIR, originalMetastate.name)
    local originalState = bitser.loadLoveFile(originalSavename, originalMetastate.compressed or true)

    -- Save the local files
    local newSavename = string.format("%s/%s.bin", _G.SAVEGAME_DIR, newMetastate.name)
    local newSavenameMeta = string.format("%s/%s_metadata.bin", _G.SAVEGAME_DIR, newMetastate.name)

    bitser.dumpLoveFile(newSavename, originalState)
    bitser.dumpLoveFile(newSavenameMeta, newMetastate, true)

    -- Save new metastate in table of saves
    local newIndex = self:findIndex(newMetastate.name)
    if (type(newIndex) == 'nil') then
        newIndex = #self.savefiles + 1
    end

    self.savefiles[newIndex] = newMetastate

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
                loveframes.SetState()
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

function SaveManager:autosave()
    -- Skip every N events (in-game months)
    self.autosaveEventCounter = self.autosaveEventCounter + 1
    if self.autosaveEventCounter % SaveManager.static.AUTOSAVE_INTERVAL ~= 0 then
        return
    end

    -- Perform save
    self:save('autosave')
end

return SaveManager:new()
