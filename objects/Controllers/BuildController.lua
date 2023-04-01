local _, objectAtlas = ...
local image = love.graphics.newImage("assets/tiles/info_tiles_strip.png")
local ActionBar = require("states.ui.ActionBar")
local WallController = require("objects.Controllers.WallController")
local console = require("libraries.console")
local tileWidth, tileHeight = _G.tileWidth, _G.tileHeight
local IsoToScreenX, IsoToScreenY = _G.IsoToScreenX, _G.IsoToScreenY
local warningTooltip = require("states.ui.warning_tooltip")

local building = require("objects.buildings")

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
    self.gx = 0
    self.gy = 0
    self.FX = 0
    self.FY = 0
    self.previousGx = 0
    self.previousGy = 0
    self.elevationOffsetY = 0
    self.canBuild = false
    self.previousCanBuild = false
    self.building = "SaxonHall"
    self.batch = love.graphics.newSpriteBatch(image)
    self.quads = {}
    self.cannotBuildBecauseSpecial = false
    self.quads[1] = love.graphics.newQuad(0, 0, 30, 16, image:getWidth(), image:getHeight())
    self.quads[2] = love.graphics.newQuad(30, 0, 30, 16, image:getWidth(), image:getHeight())
    self.quads[3] = love.graphics.newQuad(60, 0, 30, 16, image:getWidth(), image:getHeight())
    self.quads[4] = love.graphics.newQuad(90, 0, 30, 16, image:getWidth(), image:getHeight())
    self.isMultispriteBuilding = false
    self.multispriteSwitchTimer = 0
    self.currentSprite = 1
    self.freeBuildings = false
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
    data.gx = self.gx
    data.gy = self.gy
    data.FX = self.FX
    data.FY = self.FY
    data.previousGx = self.previousGx
    data.previousGy = self.previousGy
    data.elevationOffsetY = self.elevationOffsetY
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

function BuildController:set(type, callback)
    if _G.DestructionController.active then
        _G.DestructionController:toggle()
    end

    if not building[type] then
        error("want to build an unknown building: " .. tostring(type))
    end
    if type == "WalkableWoodenWall" then
        WallController:setWalkableWall()
    elseif type == "WoodenWall" then
        WallController:setWoodenWall()
    end
    self.onBuildCallback = callback
    self.building = type
    if buildingheightmap[type].quads ~= nil and building[type].quad == nil then
        self.multispriteSwitchTimer = 0
        self.isMultispriteBuilding = 1
        self.currentSprite = 1
    else
        self.isMultispriteBuilding = false
    end
    self.width, self.height = building[type].w, building[type].h
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

function BuildController:upgradeKeep(level)
    if level == 2 and self:isBuildingAffordable("WoodenKeep") then
        self:purchaseBuilding("WoodenKeep")
        _G.DestructionController:destroyAtLocation(_G.state.keepX + 2, _G.state.keepY + 7, true, true)
        _G.DestructionController:destroyAtLocation(_G.state.keepX + 4, _G.state.keepY + 7, true, true)
        _G.DestructionController:destroyAtLocation(_G.state.keepX, _G.state.keepY, true)
        local WoodenKeep = require("objects.Structures.WoodenKeep")
        WoodenKeep:new(_G.state.keepX, _G.state.keepY)
        return true
    elseif level == 3 and self:isBuildingAffordable("Keep") then
        self:purchaseBuilding("Keep")
        _G.DestructionController:destroyAtLocation(_G.state.keepX + 2, _G.state.keepY + 7, true, true)
        _G.DestructionController:destroyAtLocation(_G.state.keepX + 4, _G.state.keepY + 7, true, true)
        _G.DestructionController:destroyAtLocation(_G.state.keepX, _G.state.keepY, true)
        local Keep = require("objects.Structures.Keep")
        Keep:new(_G.state.keepX, _G.state.keepY)
        return true
    elseif level == 4 and self:isBuildingAffordable("Fortress") then
        self:purchaseBuilding("Fortress")
        _G.DestructionController:destroyAtLocation(_G.state.keepX + 2, _G.state.keepY + 7, true, true)
        _G.DestructionController:destroyAtLocation(_G.state.keepX + 4, _G.state.keepY + 7, true, true)
        _G.DestructionController:destroyAtLocation(_G.state.keepX, _G.state.keepY, true)
        -- the new keep is bigger, so destroy neighbour objects
        -- this is a temporary solution
        _G.DestructionController:destroyAtLocation(_G.state.keepX - 1, _G.state.keepY, true)
        _G.DestructionController:destroyAtLocation(_G.state.keepX - 1, _G.state.keepY - 1, true)
        _G.DestructionController:destroyAtLocation(_G.state.keepX, _G.state.keepY - 1, true)
        _G.DestructionController:destroyAtLocation(_G.state.keepX, _G.state.keepY - 2, true)
        local Fortress = require("objects.Structures.Fortress")
        Fortress:new(_G.state.keepX - 1, _G.state.keepY - 2)
        return true
    end
end

function BuildController:update()
    if self.active and _G.loaded then
        if self.start and ActionBar.currentGroup ~= nil then
            ActionBar:showGroup(nil)
        end
        if self.isMultispriteBuilding then
            self.multispriteSwitchTimer = self.multispriteSwitchTimer + _G.dt
            if self.multispriteSwitchTimer >= 1 then
                if self.currentSprite == #building[self.building].sprites then
                    self.currentSprite = 1
                else
                    self.currentSprite = self.currentSprite + 1
                end
                self.multispriteSwitchTimer = 0
            end
        end
        local MX, MY = love.mouse.getPosition()
        local LX, LY = _G.getTerrainTileOnMouse(MX, MY)
        LX, LY = LX - math.floor(self.width / 2), LY - math.floor(self.height / 2)
        self.gx, self.gy = LX, LY
        local cx, cy, x, y = _G.getLocalCoordinatesFromGlobal(self.gx, self.gy)
        local type
        self.elevationOffsetY = (_G.state.map.heightmap[cx][cy][x][y] or 0) * 2
        self.FX = IsoToScreenX(LX, LY) - _G.state.viewXview - ((IsoToScreenX(LX, LY)) - _G.state.viewXview) *
            (1 - _G.state.scaleX)
        self.FY = IsoToScreenY(LX, LY) - _G.state.viewYview - ((IsoToScreenY(LX, LY)) - _G.state.viewYview) *
            (1 - _G.state.scaleX)
        -- No point to flush the batch everytime
        if self.lastBuilding ~= self.building or self.previousGx ~= self.gx or self.previousGy ~= self.gy or not self.firstTerrainHeight then
            self.canBuild = true
            self.targetGX, self.targetGY = self.gx + math.floor(self.width / 2),
                self.gy + math.floor(self.height / 2)
            local fcx, fcy, fxx, fyy = _G.getLocalCoordinatesFromGlobal(self.targetGX, self.targetGY)
            local firstTerrainHeight = (_G.state.map.heightmap[fcx][fcy][fxx][fyy] or 0) * 2
            self.firstTerrainHeight = firstTerrainHeight
            if building[self.building].overrideRequirements then
                building[self.building]:overrideRequirements(self)
            else
                local totalTerrainDifference = 0
                for xx = 0, self.width - 1 do
                    for yy = 0, self.height - 1 do
                        local ccx, ccy, xxx, yyy = _G.getLocalCoordinatesFromGlobal(xx + self.gx, yy + self.gy)
                        if _G.importantObjectAt(ccx, ccy, xxx, yyy) then
                            warningTooltip:ShowTooltip("There is an obstacle in the way!")
                            self.canBuild = false
                            break
                        end
                        local terrainDiff = math.abs(firstTerrainHeight - (_G.state.map.heightmap[ccx][ccy][xxx][yyy] or 0) * 2)
                        if terrainDiff >= 28 then
                            -- height difference is too drastic
                            warningTooltip:ShowTooltip("Cannot build on cliffs!")
                            self.canBuild = false
                            break
                        elseif firstTerrainHeight ~= (_G.state.map.heightmap[ccx][ccy][xxx][yyy] or 0) * 2 then
                            totalTerrainDifference = totalTerrainDifference + terrainDiff
                        end
                        if _G.state.map:isWaterAt(self.gx + xx, self.gy + yy) then
                            warningTooltip:ShowTooltip("Cannot build on top of water!")
                            self.canBuild = false
                            break
                        end
                        if _G.getTerrainBiomeAt(self.gx + xx, self.gy + yy) == _G.terrainBiome.seaWalkable then
                            self.canBuild = false
                            warningTooltip:ShowTooltip("Cannot build on top of water!")
                            break
                        end
                    end
                end
                self.totalTerrainDifference = totalTerrainDifference
                if self.totalTerrainDifference >= math.min(3 * self.width * self.height, 220) then
                    warningTooltip:ShowTooltip("Cannot build on too much uneven terrain!")
                    self.canBuild = false
                end
                if not building[self.building]:specialRequirements(self.gx, self.gy) then
                    self.canBuild = false
                    self.cannotBuildBecauseSpecial = true
                else
                    self.cannotBuildBecauseSpecial = false
                end
                if not self.start and not self:isBuildingAffordable(self.building) then
                    self.canBuild = false
                    warningTooltip:ShowTooltip("Not enough resources!")
                end
                self.batch:clear()
                for xx = 0, self.width - 1 do
                    for yy = 0, self.height - 1 do
                        local ccx, ccy, xxx, yyy = _G.getLocalCoordinatesFromGlobal(xx + self.gx, yy + self.gy)
                        if _G.state.map:getWalkable(xx + self.gx, yy + self.gy) == 1 then
                            if self.canBuild then
                                type = 2
                            else
                                type = 3
                            end
                        else
                            if self.canBuild then
                                type = 3
                            else
                                type = 1
                            end
                        end
                        local elevationOffsetY = (_G.state.map.heightmap[ccx][ccy][xxx][yyy] or 0) * 2
                        self.batch:add(self.quads[type], (xx - yy) * tileWidth * 0.5,
                            (xx + yy) * tileHeight * 0.5 - elevationOffsetY, 0, 1, 1)
                    end
                end
                if self.canBuild then
                    warningTooltip:HideTooltip()
                end
                self.batch:flush()
                self.previousGx = self.gx
                self.previousGy = self.gy
                self.previousCanBuild = self.canBuild
                self.lastBuilding = self.building
            end
            if (self.gx < 0 or self.gy < 0
                or self.gx + self.width > _G.chunkWidth * _G.chunksWide
                or self.gy + self.height > _G.chunkHeight * _G.chunksHigh) then
                self.canBuild = false
                warningTooltip:ShowTooltip("Cannot build outside of map bounds!")
            end
        end
    end
end

-- resource nodes are nodes to which the workers can pathfind
-- in order to drop off their resources
function BuildController:removeResourceNodes()
    local w, h = building[self.building].w, building[self.building].h
    for x = 0, w - 1 do
        for y = 0, h - 1 do
            removeWhileIterating(_G.stockpile.nodeList, function(t, i, j)
                local node = t[i]
                return not (node.gx == self.gx + x and node.gy == self.gy + y)
            end)
            removeWhileIterating(_G.foodpile.nodeList, function(t, i, j)
                local node = t[i]
                return not (node.gx == self.gx + x and node.gy == self.gy + y)
            end)
        end
    end
end

function BuildController:mousepressed(x, y)
    if not _G.paused and self.active and self.canBuild and self.firstTerrainHeight then
        for xx = 0, self.width - 1 do
            for yy = 0, self.height - 1 do
                _G.terrainSetHeight(xx + self.gx, yy + self.gy, self.firstTerrainHeight / 2)
            end
        end
        self.firstTerrainHeight = nil
        if self.building == "WoodenWall" or self.building == "WalkableWoodenWall" then
            return WallController:build()
        end
        local built = self:build(self.gx, self.gy)
        if built then
            _G.playInterfaceSfx({_G.fx["building_place"], _G.fx["building_place_v2"]})
            self:removeResourceNodes()
        end
        return built
    end
end

function BuildController:getWoodCost(buildingKey, amountOfBuildings)
    return building[buildingKey].cost["wood"] * amountOfBuildings
end

function BuildController:getBuildingCost(key)
    return building[key].cost;
end

function BuildController:toggleFreeBuildings()
    self.freeBuildings = not self.freeBuildings
    if self.freeBuildings then print("Buildings are now free.") else print("Buildings now require resources.") end
end

function BuildController:isBuildingAffordable(buildingKey, amountOfBuildings)
    if self.freeBuildings then return true end
    amountOfBuildings = amountOfBuildings or 1
    for resource, amount in pairs(building[buildingKey].cost) do
        if _G.state.resources[resource] < amount * amountOfBuildings then
            if self.building == "WoodcutterHut" and _G.state.firstWoodCutterHut then
                break
            end
            return false
        end
    end
    return true
end

function BuildController:purchaseBuilding(buildingKey)
    if self.freeBuildings then return true end
    for resource, amount in pairs(building[buildingKey].cost) do
        if resource == "gold" then
            _G.state.gold = _G.state.gold - amount
            ActionBar:updateGoldCount()
        else
            _G.stockpile:take(resource, amount)
        end
    end
end

function BuildController:build(gx, gy)
    if self.active and self.gx > 0 and self.gx < 2048 and self.gy > 0 and self.gy < 2048 then
        if self.canBuild then
            self.canAfford = true
            if not self.start then
                self.canAfford = self:isBuildingAffordable(self.building)
                if self.canAfford then
                    self:purchaseBuilding(self.building)
                    for xx = 0, building[self.building].w - 1 do
                        for yy = 0, building[self.building].h - 1 do
                            _G.removeObjectFromClassAtGlobal(gx + xx, gy + yy, "Shrub")
                        end
                    end
                    if self.isMultispriteBuilding then
                        building[self.building]:build(gx, gy, self.currentSprite)
                    else
                        building[self.building]:build(gx, gy)
                    end
                    if self.onBuildCallback then
                        self.onBuildCallback()
                        self.onBuildCallback = nil
                    end
                    local builtBuilding = _G.objectFromClassAtGlobal(gx, gy, self.building)
                    _G.BuildingManager:add(builtBuilding)
                    if self.onBuildCallback then
                        self.onBuildCallback()
                        self.onBuildCallback = nil
                    end
                    return true
                end
            else
                local buildingWidth = building[self.building].w - 1
                local buildingHeight = building[self.building].h - 1
                for xx = 0, building[self.building].w - 1 do
                    for yy = 0, building[self.building].h - 1 do
                        _G.removeObjectFromClassAtGlobal(gx + xx, gy + yy, "Shrub")
                    end
                end
                if self.building == "SaxonHall" then
                    building[self.building]:build(gx, gy)
                    local builtBuilding = _G.objectFromClassAtGlobal(gx, gy, self.building)
                    _G.BuildingManager:add(builtBuilding)
                    _G.campfireFloatPop:immigrantCallback()()
                    _G.campfireFloatPop:immigrantCallback()()
                    _G.campfireFloatPop:immigrantCallback()()
                    _G.campfireFloatPop:immigrantCallback()()
                    _G.campfireFloatPop:immigrantCallback()()
                    self:set("Stockpile")
                    return true
                elseif self.building == "Stockpile" then
                    building[self.building]:build(gx, gy)
                    local builtBuilding = _G.objectFromClassAtGlobal(gx, gy, self.building)
                    _G.BuildingManager:add(builtBuilding)
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
                    building[self.building]:build(gx, gy)
                    local builtBuilding = _G.objectFromClassAtGlobal(gx, gy, self.building)
                    _G.BuildingManager:add(builtBuilding)
                    -- Starting food
                    for _ = 1, 26 do
                        _G.foodpile:store("bread")
                    end
                    self.active = false
                    self.start = false
                    ActionBar:showGroup("main")
                    _G.state.firstBuildings = false
                    return true
                end
            end
        else
            if self.cannotBuildBecauseSpecial and building[self.building].onFailedSpecialRequirement then
                building[self.building]:onFailedSpecialRequirement()
            else
                local sfxi = math.random(1, 2)
                if sfxi == 1 then
                    _G.playSpeech("cannot_place_1")
                else
                    _G.playSpeech("cannot_place_2")
                end
            end
        end
    end
end

function BuildController:draw()
    if self.active then
        if (self.building == "WoodenWall" or self.building == "WalkableWoodenWall") and WallController.clicked then
            WallController:draw()
        else
            love.graphics.setColor(1, 1, 1, 0.5)
            love.graphics.draw(self.batch, self.FX, self.FY, nil, _G.state.scaleX)
            local quad = building[self.building].quad
            local offsetX, offsetY
            if self.isMultispriteBuilding then
                quad = building[self.building].sprites[self.currentSprite].quad
                offsetX = building[self.building].sprites[self.currentSprite].offsetX
                offsetY = building[self.building].sprites[self.currentSprite].offsetY
            else
                offsetX = building[self.building].offsetX
                offsetY = building[self.building].offsetY
            end
            if self.canBuild then
                love.graphics.draw(objectAtlas, quad,
                    self.FX - (offsetX) * _G.state.scaleX, self.FY - self.elevationOffsetY *
                    _G.state.scaleX - (offsetY) * _G.state.scaleX, 0, _G.state.scaleX)
            end
            love.graphics.setColor(1, 1, 1, 1)
        end
    end
end

local instance = BuildController:new()
console.addCommand("freeBuildings", function() instance:toggleFreeBuildings() end, "Toggle whether buildings cost resources.")
return instance
