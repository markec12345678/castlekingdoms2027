-- objects/Steam/SteamWorkshopIntegration.lua
-- Castle Kingdoms 2027 - Steam Workshop Integration
-- Upload and download mods through Steam Workshop

local Workshop = {}

local initialized = false
local downloadedMods = {}
local uploadQueue = {}

-- Workshop item states
local ITEM_STATE = {
    UNKNOWN = 0,
    SUBSCRIBED = 1,
    LEGACY = 2,
    INSTALLED = 3,
    UPDATE_REQUIRED = 4,
    DOWNLOADING = 5,
    DOWNLOAD_PENDING = 6,
}

Workshop.ITEM_STATE = ITEM_STATE

function Workshop.init()
    if initialized then return end
    initialized = true
    print("[Workshop] Initialized (Steam Workshop integration stub)")
end

-- Subscribe to a workshop item (download a mod)
function Workshop.subscribe(itemID)
    if not initialized then Workshop.init() end

    print("[Workshop] Subscribing to item: " .. tostring(itemID))

    -- In production: steamworks.subscribeItem(itemID)
    -- Stub: mark as subscribed
    downloadedMods[itemID] = {
        id = itemID,
        state = ITEM_STATE.DOWNLOAD_PENDING,
        title = "Unknown Mod",
        downloadProgress = 0,
    }

    return true
end

-- Unsubscribe from a workshop item
function Workshop.unsubscribe(itemID)
    print("[Workshop] Unsubscribing from item: " .. tostring(itemID))
    downloadedMods[itemID] = nil
    return true
end

-- Upload a mod to Steam Workshop
function Workshop.upload(modPath, title, description, tags)
    if not initialized then Workshop.init() end

    local item = {
        path = modPath,
        title = title or "Untitled Mod",
        description = description or "",
        tags = tags or {},
        state = "uploading",
        progress = 0,
    }

    table.insert(uploadQueue, item)

    print("[Workshop] Uploading: " .. item.title .. " from " .. modPath)

    -- In production: steamworks.createItem or steamworks.updateItem
    -- Stub: simulate upload
    return true
end

-- Update an existing workshop item
function Workshop.update(itemID, modPath, changelog)
    print("[Workshop] Updating item " .. tostring(itemID) .. ": " .. (changelog or "No changelog"))
    -- In production: steamworks.updateItem(itemID, {path = modPath, changelog = changelog})
    return true
end

-- Get subscribed items
function Workshop.getSubscribed()
    local list = {}
    for id, item in pairs(downloadedMods) do
        table.insert(list, item)
    end
    return list
end

-- Get upload queue
function Workshop.getUploadQueue()
    return uploadQueue
end

-- Check if a mod is installed
function Workshop.isInstalled(itemID)
    local item = downloadedMods[itemID]
    return item and item.state == ITEM_STATE.INSTALLED
end

-- Browse workshop (stub — would open Steam overlay)
function Workshop.browse()
    print("[Workshop] Opening Steam Workshop in overlay")
    -- In production: steamworks.openOverlayBrowser("https://steamcommunity.com/app/APPID/workshop/")
    if _G.ModernUI then
        _G.ModernUI.notifyInfo("Odpiranje Steam Workshop...")
    end
end

-- Import a downloaded mod into the ModLoader
function Workshop.importMod(itemID)
    local item = downloadedMods[itemID]
    if not item or item.state ~= ITEM_STATE.INSTALLED then
        print("[Workshop] Item not installed: " .. tostring(itemID))
        return false
    end

    -- In production: copy from steam workshop directory to mods/
    -- Stub: notify ModLoader
    local ModLoader = require("objects.Modding.ModLoader")
    local modId = "workshop_" .. itemID

    -- Simulate loading
    pcall(function()
        ModLoader.loadMod(modId)
    end)

    print("[Workshop] Imported mod: " .. modId)
    return true
end

-- Update download progress (called internally)
function Workshop.update(dt)
    -- Simulate downloads
    for id, item in pairs(downloadedMods) do
        if item.state == ITEM_STATE.DOWNLOAD_PENDING or item.state == ITEM_STATE.DOWNLOADING then
            item.state = ITEM_STATE.DOWNLOADING
            item.downloadProgress = (item.downloadProgress or 0) + dt * 20  -- 20% per second

            if item.downloadProgress >= 100 then
                item.downloadProgress = 100
                item.state = ITEM_STATE.INSTALLED
                print("[Workshop] Download complete: " .. tostring(id))
                Workshop.importMod(id)
            end
        end
    end

    -- Simulate uploads
    for i, item in ipairs(uploadQueue) do
        if item.state == "uploading" then
            item.progress = (item.progress or 0) + dt * 15
            if item.progress >= 100 then
                item.progress = 100
                item.state = "uploaded"
                print("[Workshop] Upload complete: " .. item.title)
            end
        end
    end
end

-- Get stats
function Workshop.getStats()
    local installed = 0
    local downloading = 0
    for _, item in pairs(downloadedMods) do
        if item.state == ITEM_STATE.INSTALLED then installed = installed + 1
        elseif item.state == ITEM_STATE.DOWNLOADING then downloading = downloading + 1 end
    end
    return {
        subscribedItems = #Workshop.getSubscribed(),
        installedMods = installed,
        downloadingMods = downloading,
        uploadQueueSize = #uploadQueue,
    }
end

return Workshop
