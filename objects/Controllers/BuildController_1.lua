local _, objectAtlas = ...
local image = love.graphics.newImage("assets/tiles/info_tiles_strip.png")
local ActionBar = require("states.ui.ActionBar")
local WallController = require("objects.Controllers.WallController")
local buildings = require("objects.buildings")
local warningTooltip = require("states.ui.warning_tooltip")

-- I have not idea what this function is doing if someone knows please document
local function removeWhileIterating(t, fnKeep)
    local j, n = 1, #t
    for i = 1, n do
        if (fnKeep(t, i, j)) then
            if (i ~= j) then
                t[j] = t[i]
                t[i] = nil
            end
            j = j + 1
        else
            t[i] = nil
        end
    end
    return t
end

local BuildController = _G.class("BuildController")
function BuildController:initialize()
    self.width = 0
    self.height = 0
    self.active = true
    self.canAfford = true
    self.start = true
    self.globalX = 0
    self.globalY = 0
    self.drawX = 0
    self.drawY = 0
    self.previousGlobalX = 0
    self.previousGlobalY = 0
    self.elevationOffset = 0
    self.checkBuildRequirements = false
    self.previousCanBuild = false
    self.building = "SaxonHall"
    self.batch = love.graphics.newSpriteBatch(image)
    self.currentSprite = 1
    self.isMultispriteBuilding = false
    self.multispriteSwitchTimer = 0
    self.cannotBuildBecauseSpecial = false
    self.quads = {}
    self.quads[1] = love.graphics.newQuad(0, 0, 30, 16, image:getWidth(), image:getHeight())
    self.quads[2] = love.graphics.newQuad(30, 0, 30, 16, image:getWidth(), image:getHeight())
    self.quads[3] = love.graphics.newQuad(60, 0, 30, 16, image:getWidth(), image:getHeight())
    self.quads[4] = love.graphics.newQuad(90, 0, 30, 16, image:getWidth(), image:getHeight())
end

function BuildController:disable()
    self.active = false
    warningTooltip:HideTooltip()
end

function BuildController:serialize()
    local data = {}
    data.width = self.width
    data.height = self.height
    data.active = self.active
    data.canAfford = self.canAfford
    data.start = self.start
    data.globalX = self.globalX
    data.globalY = self.globalY
    data.drawX = self.drawX
    data.drawY = self.drawY
    data.previousGlobalX = self.previousGlobalX
    data.previousGlobalY = self.previousGlobalY
    data.elevationOffset = self.elevationOffset
    data.canBuild = self.canBuild
    data.previousCanBuild = self.previousCanBuild
    data.building = self.building
    data.cannotBuildBecauseSpecial = self.cannotBuildBecauseSpecial
    return data
end

function BuildController:deserialize(data)
    for k, v in pairs(data) do
        self[k] = v
    end
    if self.start then
        ActionBar:showGroup(nil)
    end
end

-- Set the selected building type or if it is a wall delegate it to the wall controller
function BuildController:set(type, callback)
    -- If Desctruction Mode is actived deactivate it
    if _G.DestructionController.active then
        _G.DestructionController:deactivate()
    end    
    -- Delegate building walls to the wall controller
    if type == "WalkableWoodenWall" then
        WallController:setWalkableWall()
    elseif type == "WoodenWall" then
        WallController:setWoodenWall()
    end
    -- Check if the building that was input is an known building type
    if not buildings[type] then
        error("Wanting to build an unknown building: " .. tostring(type))
    end
    self.onBuildCallback = callback
    self.building = type
    -- Check if current building is a multisprite building
    if buildingheightmap[type].quads ~= nil and buildings[type].quad == nil then
        self.multispriteSwitchTimer = 0
        self.isMultispriteBuilding = 1
        self.currentSprite = 1
    else
        self.isMultispriteBuilding = false
    end
    -- Setup building outline
    self.width, self.height = buildings[type].w, buildings[type].h
    self.batch:clear()
    for x = 0, self.width - 1 do
        for y = 0, self.height - 1 do
            type = 2
            self.batch:add(self.quads[type], (x - y) * tileWidth * 0.5, (x + y) * tileHeight * 0.5, 0, 1.06666, 1)
        end
    end
    self.batch:flush()
    self.active = true
end

function BuildController:update()
    -- If the building controller is not active do not run this function
    if not self.active then
        return
    end
    -- Show initial action group when a new game is started
    if self.start and ActionBar.currentGroup ~= nil then
        ActionBar:showGroup(nil)
    end
    -- Remove previous tooltip
    warningTooltip:HideTooltip()
    -- If the bulding is a multisprite building update the timer and if enough time has passed switch to the next sprite
    if self.isMultispriteBuilding then
        self.multispriteSwitchTimer = self.multispriteSwitchTimer + _G.dt
        if self.multispriteSwitchTimer >= 1 then
            if self.currentSprite == #buildings[self.building].sprites then
                self.currentSprite = 1
            else
                self.currentSprite = self.currentSprite + 1
            end
            self.multispriteSwitchTimer = 0
        end
    end
    -- Get required coordinate data
    local globalX, globalY, chunkX, chunkY, x, y = self:getCoordinatesFromCursorPosition()
    self.globalX = globalX
    self.globalY = globalY
    -- Calculate elevation offset
    self.elevationOffset = (_G.state.map.heightmap[chunkX][chunkY][x][y] or 0) * 2
    -- Calculate position to draw ghost building at
    self.drawX = _G.IsoToScreenX(self.globalX, self.globalY) - _G.state.viewXview - ((IsoToScreenX(self.globalX, self.globalY)) - _G.state.viewXview) * (1 - _G.state.scaleX)
    self.drawY = _G.IsoToScreenY(self.globalX, self.globalY) - _G.state.viewYview - ((IsoToScreenY(self.globalX, self.globalY)) - _G.state.viewYview) * (1 - _G.state.scaleX)
    -- Update building outline
    if self:shouldRedrawOutline() then
        self.checkBuildRequirements = true
        -- Calculate target coordinates for outline
        self.targetGlobalX, self.targetGlobalY = self.globalX + math.floor(self.width / 2), self.globalY + math.floor(self.height / 2)
        local targetChunkX, targetChunkY, targetX, targetY = _G.getLocalCoordinatesFromGlobal(self.targetGlobalX, self.targetGlobalY)
        -- Set refrence terrain height to detect if building is hovering over uneven terrain
        self.refrenceTerrainHeight = (_G.state.map.heightmap[targetChunkX][targetChunkY][targetX][targetY] or 0) * 2
        -- If the building implements its own requirements ignore the default requirements
        if buildings[self.building].overrideRequirements then
            buildings[self.building]:overrideRequirements(self)
            return
        end
        -- Building does not override default requirements so use default ones
        -- Calculate the terrain height difference of each of the buildings tiles
        self.totalTerrainHeightDifference = 0
        for xx = 0, self.width - 1 do
            for yy = 0, self.height - 1 do
                local tileChunkX, tileChunkY, tileX, tileY = _G.getLocalCoordinatesFromGlobal(self.globalX + xx, self.globalY)
                -- Check if there is an object like another bulding or a tree at the tiles location
                if _G.importantObjectAt(tileChunkX, tileChunkY, tileX, tileY) then
                    warningTooltip:ShowTooltip("There is an obstacle in the way!")
                    self.checkBuildRequirements = false
                end
                -- Check if there is water on the tile
                if _G.state.map:isWaterAt(self.globalX + xx, self.globalY + yy) then
                    warningTooltip:ShowTooltip("Cannot build on top of water!")
                    self.checkBuildRequirements = false
                end
                -- Calculate the height difference between the current tile and the refrence tile
                if self.refrenceTerrainHeight ~= (_G.state.map.heightmap[tileChunkX][tileChunkY][tileX][tileY] or 0) * 2 then
                    self.totalTerrainHeightDifference = self.totalTerrainHeightDifference + 
                        math.abs(self.refrenceTerrainHeight - (_G.state.map.heightmap[tileChunkX][tileChunkY][tileX][tileY] or 0) * 2)
                end
            end
        end
        -- Check if the height difference between the tiles is to great
        if self.totalTerrainHeightDifference >= math.min(3 * self.width * self.height, 220) then
            warningTooltip:ShowTooltip("Cannot build on cliffs!")
            self.checkBuildRequirements = false
        end
        -- Check if the building special requirements are multispriteSwitchTimer
        if not buildings[self.building]:specialRequirements(self.globalX, self.globalY) then
            self.checkBuildRequirements = false
            self.cannotBuildBecauseSpecial = true
        else
            self.cannotBuildBecauseSpecial = false
        end
        -- Generate outline sprite batch
        self.batch:clear()
        for xx = 0, self.width - 1 do
            for yy = 0, self.height - 1 do
                local tileChunkX, tileChunkY, tileX, tileY = _G.getLocalCoordinatesFromGlobal(self.globalX + xx, self.globalY)
                -- Set type of outline tile
                local type = self:getOutlineTileType(x, y)
                -- Adjust the outline tile for the elevation
                local elevationOffsetY = (_G.state.map.heightmap[tileChunkX][tileChunkY][tileX][tileY] or 0) * 2
                -- Add it to the batch
                self.batch:add(self.quads[type], (xx - yy) * _G.tileWidth * 0.5, (xx + yy) * _G.tileHeight * 0.5 - elevationOffsetY, 0, 1, 1)
            end
        end
        self.batch:flush()
        -- Set refrence values for next update
        self.previousglobalX = self.globalX
        self.previousglobalY = self.globalY
        self.previousCanBuild = self.checkBuildRequirements
        self.lastBuilding = self.building
    end
end

--- @return Will return the building instance if the building can be constructed otherwise returns nil
function BuildController:mousepressed(x, y)
    -- Construct the building if the building controller is active and all requirements are met
    if not self.active or not self.checkBuildRequirements or not self.refrenceTerrainHeight then
        return nil
    end
    -- Flatten the terrain
    for xx = 0, self.width - 1 do
        for yy = 0, self.height - 1 do
            _G.terrainSetHeight(self.globalX + xx, self.globalY + yy, self.refrenceTerrainHeight / 2)
        end
    end
    -- Reset refrence height
    self.refrenceTerrainHeight = nil
    -- Delegate wall construction to the wall controller
    if self.building == "WoodenWall" or self.building == "WalkableWoodenWall" then 
        return WallController:build()
    end
    -- Construct the building
    local built = self:build(self.globalX, self.globalY)
    -- Remove resource nodes if necesarry
    if built then
        self:removeResourceNodes()
    end
    return built
end

--- @param globalX Required
--- @param globalY Required
function BuildController:build(globalX, globalY)
    -- Check if the building can be placed here
    if not self:canBuild() then
        return
    end
    self.canAfford = self:isBuildingAffordable(self.building)
    if not self.start then
        -- Standard building mode
        -- If the player can afford the building purchase it and place it
        if self.canAfford then
            self:purchaseBuilding(self.building)
            for xx = 0, buildings[self.building].w - 1 do
                for yy = 0, buildings[self.building].h - 1 do
                    _G.removeObjectFromClassAtGlobal(globalX + xx, globalY + yy, "Shrub")
                end
            end
            if self.isMultispriteBuilding then
                buildings[self.building]:build(globalX, globalY, self.currentSprite)
            else
                buildings[self.building]:build(globalX, globalY, nil)
            end
            if self.onBuildCallback then
                self.onBuildCallback()
                self.onBuildCallback = nil
            end
            return true
        end
    else
        -- Build mode for placing the initial buildings
        for xx = 0, buildings[self.building].w - 1 do
            for yy = 0, buildings[self.building].h - 1 do
                _G.removeObjectFromClassAtGlobal(globalX + xx, globalY + yy, "Shrub")
            end
        end
        if self.building == "SaxonHall" then
            buildings[self.building]:build(globalX, globalY, nil)
            self:set("Stockpile")
            return true
        elseif self.building == "Stockpile" then
            buildings[self.building]:build(globalX, globalY, nil)
            self:set("Granary")
            _G.playSpeech("place_granary")
            -- Starting resources
            for _ = 1, 10 do
                _G.stockpile:store("wheat")
            end
            for _ = 1, 6 do
                _G.stockpile:store("flour")
            end
            for _ = 1, 19 do
                _G.stockpile:store("stone")
            end
            for _ = 1, 49 do
                _G.stockpile:store("wood")
            end
            return true
        elseif self.building == "Granary" then
            buildings[self.building]:build(globalX, globalY, nil)
            -- Starting food
            for _ = 1, 26 do
                _G.foodpile:store("bread")
            end
            self.active = false
            self.start = false
            ActionBar:showGroup("main")
            _G.campfireFloatPop:immigrantCallback()()
            _G.campfireFloatPop:immigrantCallback()()
            _G.campfireFloatPop:immigrantCallback()()
            _G.campfireFloatPop:immigrantCallback()()
            _G.campfireFloatPop:immigrantCallback()()
            return true
        end
    end
end

--- @return Returns true if the building can be placed otherwise returns false
function BuildController:canBuild()
    if not self.active then
        print("not active")
        return false
    end
    if self.globalX < 0 and self.globalX > 2048 and self.globalY < 0 and self.globalY > 2048 then
        print("out of bounds")
        return false
    end
    if not self.canBuild then
        print("cannot build")
        return false
    end
    return true
end

--- @param buildingKey Required: The type of building to be checked
--- @param amountOfBuildings Optional: Amount of buildings to be checked defualt is one
--- @return Returns true if the player can afford the building(s) otherwise returns false
function BuildController:isBuildingAffordable(buildingKey, amountOfBuildings)
    amountOfBuildings = amountOfBuildings or 1
    for resource, amount in pairs(buildings[buildingKey].cost) do
        if resource == "gold" then
            return _G.state.gold >= amount
        end

        if _G.state.resources[resource] < amount * amountOfBuildings then
            if self.building == "WoodcuttersHut" and _G.state.firstWoodCutterHut then
                _G.state.firstWoodCutterHut = false
                break
            end
            return false
        end
    end
    return true
end

--- @param buildingKey Required: The type of buidlign to be purchaseBuilding
function BuildController:purchaseBuilding(buildingKey)
    for resource, amount in pairs(buildings[buildingKey].cost) do
        if resource == "gold" then
            _G.state.gold = _G.state.gold - amount
            ActionBar:updateGoldCount()
        else
            _G.stockpile:take(resource, amount)
        end
    end
end

-- Helper function to remove resource nodes from the building arrayRemove
-- A resource node is use by workers to pathfind to a resource dropoff point
function BuildController:removeResourceNodes()
    -- local width, height = buildings[self.building].w, buildings[self.buidling].h
    for x = 0, self.width - 1 do
        for y = 0, self.height - 1 do
            removeWhileIterating(_G.stockpile.nodeList, function(t, i, j)
                local node = t[i]
                return not (node.globalX == self.globalX + x and node.globalY == self.globalY + y)
            end)
            removeWhileIterating(_G.foodpile.nodeList, function(t, i, j)
                local node = t[i]
                return not (node.globalX == self.globalX + x and node.globalY == self.globalY + y)
            end)
        end
    end
end

--- @return Returns the Global, Chunk and World x and y positions (globalX, globalY, chunkX, chunkY, x, y)
function BuildController:getCoordinatesFromCursorPosition()
    -- Get current mouse Position
    local mouseX, mouseY = love.mouse.getPosition()
    -- Get the coordinates of the terrain tile the cursor is hovering over
    local terrainX, terrainY = _G.getTerrainTileOnMouse(mouseX, mouseY)
    local globalX, globalY = terrainX - math.floor(self.width / 2), terrainY - math.floor(self.height / 2)
    -- Get the world and chunk coordinates
    local chunkX, chunkY, x, y = _G.getLocalCoordinatesFromGlobal(globalX, globalY)
    return globalX, globalY, chunkX, chunkY, x, y
end

--- @return Returns true if the tile outline should be redrawn otherwise returns false
function BuildController:shouldRedrawOutline()
    if self.building ~= self.lastBuilding then
        return true
    elseif self.previousGlobalX ~= self.globalX then
        return true
    elseif self.previousGlobalY ~= self.globalY then
        return true
    elseif not self.refrenceTerrainHeight then
        return true
    else
        return false
    end
end

--- @param x Required
--- @param y Required
--- @return Returns the type (colour) of outline tile at the give coordinates
function BuildController:getOutlineTileType(x, y)
    if _G.state.map:getWalkable(x, y) == 1 then
        if self.checkBuildRequirements then
            return 2
        else
            return 3
        end
    else
        if self.checkBuildRequirements then
            return 3
        else
            return 1
        end
    end
end

--- @return Returns true if the keep can be upgraded otherwise returns false
function BuildController:upgradeKeep(level)
    if level == 2 and self:isBuildingAffordable("wooden_keep") then
        self:purchaseBuilding("wooden_keep")
        _G.DestructionController:destroyAtLocation(_G.state.keepX + 2, _G.state.keepY + 7, true, true)
        _G.DestructionController:destroyAtLocation(_G.state.keepX + 4, _G.state.keepY + 7, true, true)
        _G.DestructionController:destroyAtLocation(_G.state.keepX, _G.state.keepY, true)
        require("objects.Structures.WoodenKeep"):new(_G.state.keepX, _G.state.keepY)
        return true
    elseif level == 3 and self:isBuildingAffordable("keep") then
        self:purchaseBuilding("keep")
        _G.DestructionController:destroyAtLocation(_G.state.keepX + 2, _G.state.keepY + 7, true, true)
        _G.DestructionController:destroyAtLocation(_G.state.keepX + 4, _G.state.keepY + 7, true, true)
        _G.DestructionController:destroyAtLocation(_G.state.keepX, _G.state.keepY, true)
        require("objects.Structures.Keep"):new(_G.state.keepX, _G.state.keepY)
        return true
    elseif level == 4 and self:isBuildingAffordable("fortress") then
        self:purchaseBuilding("fortress")
        _G.DestructionController:destroyAtLocation(_G.state.keepX + 2, _G.state.keepY + 7, true, true)
        _G.DestructionController:destroyAtLocation(_G.state.keepX + 4, _G.state.keepY + 7, true, true)
        _G.DestructionController:destroyAtLocation(_G.state.keepX, _G.state.keepY, true)
        -- the new keep is bigger, so destroy neighbour objects
        -- this is a temporary solution
        _G.DestructionController:destroyAtLocation(_G.state.keepX - 1, _G.state.keepY, true)
        _G.DestructionController:destroyAtLocation(_G.state.keepX - 1, _G.state.keepY - 1, true)
        _G.DestructionController:destroyAtLocation(_G.state.keepX, _G.state.keepY - 1, true)
        _G.DestructionController:destroyAtLocation(_G.state.keepX, _G.state.keepY - 2, true)
        require("objects.Structures.Fortress"):new(_G.state.keepX - 1, _G.state.keepY - 2)
        return true
    end
    return false
end

function BuildController:draw()
    if self.active then
        if (self.building == "WoodenWall" or self.building == "WalkableWoodenWall") and WallController.clicked then
            WallController:draw()
        else
            love.graphics.setColor(1, 1, 1, 0.5)
            love.graphics.draw(self.batch, self.drawX, self.drawY, nil, _G.state.scaleX)
            local quad = buildings[self.building].quad
            local offsetX, offsetY
            if self.isMultispriteBuilding then
                quad = buildings[self.building].sprites[self.currentSprite].quad
                offsetX = buildings[self.building].sprites[self.currentSprite].offsetX
                offsetY = buildings[self.building].sprites[self.currentSprite].offsetY
            else
                offsetX = buildings[self.building].offsetX
                offsetY = buildings[self.building].offsetY
            end
            if self.canBuild then
                love.graphics.draw(objectAtlas, quad,
                    self.drawX - offsetX * _G.state.scaleX, self.drawY - self.elevationOffset *
                    _G.state.scaleX - offsetY * _G.state.scaleX, 0, _G.state.scaleX)
            end
            love.graphics.setColor(1, 1, 1, 1)
        end
    end
end

return BuildController:new()