local _, objectAtlas = ...

local tileQuads = require("objects.object_quads")
local image = love.graphics.newImage("assets/tiles/info_tiles_strip.png")
local ActionBar = require("states.ui.ActionBar")
local SaxonHall = require("objects.Structures.SaxonHall")
local Stockpile = require("objects.Structures.Stockpile")
local Granary = require("objects.Structures.Granary")
local Quarry = require("objects.Structures.Quarry")
local Mine = require("objects.Structures.Mine")
local WoodcutterHut = require("objects.Structures.WoodcutterHut")
local Campfire = require("objects.Structures.Campfire")
local Orchard = require("objects.Structures.Orchard")
local WheatFarm = require("objects.Structures.WheatFarm")
local Windmill = require("objects.Structures.Windmill")
local Bakery = require("objects.Structures.Bakery")
local House = require("objects.Structures.House")
local OxTether = require("objects.Structures.OxTether")

local objectFromTypeAt = _G.objectFromTypeAt
local chunkWidth = _G.chunkWidth
local tileWidth, tileHeight = _G.tileWidth, _G.tileHeight
local IsoToScreenX, IsoToScreenY = _G.IsoToScreenX, _G.IsoToScreenY

local building = {
    ["saxon_hall"] = {
        quad = tileQuads["small_wooden_castle (1)"],
        offsetY = 93,
        offsetX = 6 * 15 + 6,
        w = 7,
        h = 15,
        cost = {
            ["wood"] = 50
        },
        build = function(self, gx, gy)
            SaxonHall:new(gx, gy)
            Campfire:new(gx + 2, gy + 10)
        end,
        specialRequirements = function(self, _, _)
            return true
        end
    },
    ["stockpile"] = {
        quad = tileQuads["stockpile"],
        offsetX = 64,
        offsetY = 12,
        w = 5,
        h = 5,
        cost = {
            ["stone"] = 4
        },
        build = function(self, gx, gy)
            Stockpile:new(gx, gy)
        end,
        specialRequirements = function(self, gx, gy)
            if not next(_G.stockpile.list) then
                return true
            end
            local i, o, cxx, cyy
            for w = gx - 1, self.w + gx do
                for h = gy - 1, self.h + gy do
                    i = (w) % (chunkWidth)
                    o = (h) % (chunkWidth)
                    cxx = math.floor(w / chunkWidth)
                    cyy = math.floor(h / chunkWidth)
                    if objectFromTypeAt(cxx, cyy, i, o, "Stockpile") or
                        objectFromTypeAt(cxx, cyy, i, o, "StockpileAlias") then
                        return true
                    end
                end
            end
        end,
        onFailedSpecialRequirement = function()
            _G.playSpeech("adjacent_stockpile")
        end
    },
    ["granary"] = {
        quad = tileQuads["granary (1)"],
        offsetX = 3 * 15 + 3,
        offsetY = 62 + 16,
        w = 4,
        h = 4,
        cost = {
            ["wood"] = 10
        },
        build = function(self, gx, gy)
            Granary:new(gx, gy)
        end,
        specialRequirements = function(self, gx, gy)
            if not next(_G.foodpile.list) then
                return true
            end
            local i, o, cxx, cyy
            for w = gx - 1, self.w + gx do
                for h = gy - 1, self.h + gy do
                    i = (w) % (chunkWidth)
                    o = (h) % (chunkWidth)
                    cxx = math.floor(w / chunkWidth)
                    cyy = math.floor(h / chunkWidth)
                    if objectFromTypeAt(cxx, cyy, i, o, "Granary") or objectFromTypeAt(cxx, cyy, i, o, "GranaryAlias") then
                        return true
                    end
                end
            end
        end
    },
    ["quarry"] = {
        quad = tileQuads["stone_quarry"],
        offsetX = 64 + 16,
        offsetY = 7 * 16 + 6,
        w = 6,
        h = 6,
        cost = {
            ["wood"] = 24
        },
        build = function(self, gx, gy)
            Quarry:new(gx, gy)
        end,
        specialRequirements = function(self, gx, gy)
            for w = gx, self.w + gx do
                for h = gy, self.h + gy do
                    if _G.objectFromClassAtGlobal(w, h, "Stone") then
                        return true
                    end
                end
            end
        end,
        overrideRequirements = function(self, ctrl)
            local type
            for xx = 0, ctrl.width - 1 do
                for yy = 0, ctrl.height - 1 do
                    if not _G.objectFromClassAtGlobal(xx + ctrl.gx, yy + ctrl.gy, "Stone") then
                        ctrl.canBuild = false
                    end
                end
            end
            if not self:specialRequirements(ctrl.gx, ctrl.gy) then
                ctrl.canBuild = false
            end
            ctrl.batch:clear()
            for xx = 0, ctrl.width - 1 do
                for yy = 0, ctrl.height - 1 do
                    local cx, cy, x, y = _G.getLocalCoordinatesFromGlobal(xx + ctrl.gx, yy + ctrl.gy)
                    if _G.objectFromClassAtGlobal(xx + ctrl.gx, yy + ctrl.gy, "Stone") then
                        if ctrl.canBuild then
                            type = 2
                        else
                            type = 4
                        end
                    elseif not _G.importantObjectAt(cx, cy, x, y) then
                        if ctrl.canBuild then
                            type = 2
                        else
                            type = 3
                        end
                    else
                        type = 1
                    end
                    local elevationOffsetY = (_G.state.map.heightmap[cx][cy][x][y] or 0) * 2
                    ctrl.batch:add(ctrl.quads[type], (xx - yy) * tileWidth * 0.5,
                        (xx + yy) * tileHeight * 0.5 - elevationOffsetY, 0, 1, 1)
                end
            end
            ctrl.batch:flush()
            ctrl.previousGx = ctrl.gx
            ctrl.previousGy = ctrl.gy
            ctrl.previousCanBuild = ctrl.canBuild
            ctrl.lastBuilding = ctrl.building
        end
    },
    ["iron_mine"] = {
        quad = tileQuads["iron_mine"],
        offsetX = 48,
        offsetY = 64 - 16 - 4,
        w = 4,
        h = 4,
        cost = {
            ["wood"] = 10,
            ["stone"] = 10
        },
        build = function(self, gx, gy)
            Mine:new(gx, gy)
        end,
        specialRequirements = function(self, gx, gy)
            for w = gx, self.w + gx do
                for h = gy, self.h + gy do
                    if _G.objectFromClassAtGlobal(w, h, "Iron") then
                        return true
                    end
                end
            end
        end,
        overrideRequirements = function(self, ctrl)
            local type
            for xx = 0, ctrl.width - 1 do
                for yy = 0, ctrl.height - 1 do
                    if not _G.objectFromClassAtGlobal(xx + ctrl.gx, yy + ctrl.gy, "Iron") then
                        ctrl.canBuild = false
                    end
                end
            end
            if not self:specialRequirements(ctrl.gx, ctrl.gy) then
                ctrl.canBuild = false
            end
            ctrl.batch:clear()
            for xx = 0, ctrl.width - 1 do
                for yy = 0, ctrl.height - 1 do
                    local cx, cy, x, y = _G.getLocalCoordinatesFromGlobal(xx + ctrl.gx, yy + ctrl.gy)
                    if _G.objectFromClassAtGlobal(xx + ctrl.gx, yy + ctrl.gy, "Iron") then
                        if ctrl.canBuild then
                            type = 2
                        else
                            type = 4
                        end
                    elseif not _G.importantObjectAt(cx, cy, x, y) then
                        if ctrl.canBuild then
                            type = 2
                        else
                            type = 3
                        end
                    else
                        type = 1
                    end
                    local elevationOffsetY = (_G.state.map.heightmap[cx][cy][x][y] or 0) * 2
                    ctrl.batch:add(ctrl.quads[type], (xx - yy) * tileWidth * 0.5,
                        (xx + yy) * tileHeight * 0.5 - elevationOffsetY, 0, 1, 1)
                end
            end
            ctrl.batch:flush()
            ctrl.previousGx = ctrl.gx
            ctrl.previousGy = ctrl.gy
            ctrl.previousCanBuild = ctrl.canBuild
            ctrl.lastBuilding = ctrl.building
        end
    },
    ["orchard"] = {
        quad = tileQuads["farm (3)"],
        offsetX = 32,
        offsetY = 48 + 6,
        w = 12,
        h = 12,
        cost = {
            ["wood"] = 3
        },
        build = function(self, gx, gy)
            Orchard:new(gx, gy)
        end,
        specialRequirements = function(self, _, _)
            return true
        end
    },
    ["wheat_farm"] = {
        quad = tileQuads["farm (2)"],
        offsetX = 32,
        offsetY = 64 + 6 + 8,
        w = 12,
        h = 12,
        cost = {
            ["wood"] = 4
        },
        build = function(self, gx, gy)
            WheatFarm:new(gx, gy)
        end,
        specialRequirements = function(self, _, _)
            return true
        end
    },
    ["woodcutter_hut"] = {
        quad = tileQuads["woodcutter_hut"],
        offsetX = 32,
        offsetY = 32,
        w = 3,
        h = 3,
        cost = {
            ["wood"] = 3
        },
        build = function(self, gx, gy)
            WoodcutterHut:new(gx, gy)
        end,
        -- add requirement for w h
        specialRequirements = function(self, _, _)
            return true
        end
    },
    ["windmill"] = {
        quad = tileQuads["windmill_whole"],
        offsetX = 32,
        offsetY = 243 - 48,
        w = 3,
        h = 3,
        cost = {
            ["wood"] = 8
        },
        build = function(self, gx, gy)
            Windmill:new(gx, gy)
        end,
        specialRequirements = function(self, _, _)
            return true
        end
    },
    ["bakery"] = {
        quad = tileQuads["bakery_workshop (18)"],
        offsetX = 48,
        offsetY = 131 - 64,
        w = 4,
        h = 4,
        cost = {
            ["wood"] = 10,
            ["stone"] = 2
        },
        build = function(self, gx, gy)
            Bakery:new(gx, gy)
        end,
        specialRequirements = function(self, _, _)
            return true
        end
    },
    ["house"] = {
        quad = tileQuads["housing (1)"],
        offsetX = 48,
        offsetY = 135 - 32 - 64,
        w = 4,
        h = 4,
        cost = {
            ["wood"] = 3
        },
        build = function(self, gx, gy)
            House:new(gx, gy)
        end,
        specialRequirements = function(self, _, _)
            return true
        end
    },
    ["ox_tether"] = {
        quad = tileQuads["stone_ox_base (1)"],
        offsetY = 26,
        offsetX = 15,
        w = 2,
        h = 2,
        cost = {
            ["wood"] = 5
        },
        build = function(self, gx, gy)
            OxTether:new(gx, gy)
        end,
        specialRequirements = function(self, gx, gy)
            for x = gx - 25, gx + 25 do
                for y = gy - 25, gy + 25 do
                    if _G.objectFromClassAtGlobal(x, y, "Quarry") then
                        return true
                    end
                end
            end
            return false
        end,
        overrideRequirements = function(self, ctrl)
            local type
            ctrl.batch:clear()
            if not self:specialRequirements(ctrl.gx, ctrl.gy) then
                ctrl.canBuild = false
            end
            for xx = 0, ctrl.width - 1 do
                for yy = 0, ctrl.height - 1 do
                    local cx, cy, x, y = _G.getLocalCoordinatesFromGlobal(xx + ctrl.gx, yy + ctrl.gy)
                    if _G.objectFromClassAtGlobal(xx + ctrl.gx, yy + ctrl.gy, "Stone") then
                        if ctrl.canBuild then
                            type = 2
                        else
                            type = 4
                        end
                    elseif not _G.importantObjectAt(cx, cy, x, y) then
                        if ctrl.canBuild then
                            type = 2
                        else
                            type = 3
                        end
                    else
                        type = 1
                    end
                    local elevationOffsetY = (_G.state.map.heightmap[cx][cy][x][y] or 0) * 2
                    ctrl.batch:add(ctrl.quads[type], (xx - yy) * tileWidth * 0.5,
                        (xx + yy) * tileHeight * 0.5 - elevationOffsetY, 0, 1, 1)
                end
            end
            ctrl.batch:flush()
            ctrl.previousGx = ctrl.gx
            ctrl.previousGy = ctrl.gy
            ctrl.previousCanBuild = ctrl.canBuild
            ctrl.lastBuilding = ctrl.building
        end
    }
}

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
    self.building = "saxon_hall"
    self.batch = love.graphics.newSpriteBatch(image)
    self.quads = {}
    self.cannotBuildBecauseSpecial = false
    self.quads[1] = love.graphics.newQuad(0, 0, 30, 16, image:getWidth(), image:getHeight())
    self.quads[2] = love.graphics.newQuad(30, 0, 30, 16, image:getWidth(), image:getHeight())
    self.quads[3] = love.graphics.newQuad(60, 0, 30, 16, image:getWidth(), image:getHeight())
    self.quads[4] = love.graphics.newQuad(90, 0, 30, 16, image:getWidth(), image:getHeight())
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
    self.onBuildCallback = callback
    self.building = type
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

function BuildController:update()
    if self.active then
        if self.start and ActionBar.currentGroup ~= nil then
            ActionBar:showGroup(nil)
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
        if self.lastBuilding ~= self.building or self.previousGx ~= self.gx or self.previousGx ~= self.gy then
            self.canBuild = true
            if building[self.building].overrideRequirements then
                building[self.building]:overrideRequirements(self)
            else
                self.targetGX, self.targetGY = self.gx + math.floor(self.width / 2),
                    self.gy + math.floor(self.height / 2)
                local fcx, fcy, fxx, fyy = _G.getLocalCoordinatesFromGlobal(self.targetGX, self.targetGY)
                local firstTerrainHeight = (_G.state.map.heightmap[fcx][fcy][fxx][fyy] or 0) * 2
                self.firstTerrainHeight = firstTerrainHeight
                local totalTerrainDifference = 0
                for xx = 0, self.width - 1 do
                    for yy = 0, self.height - 1 do
                        local ccx, ccy, xxx, yyy = _G.getLocalCoordinatesFromGlobal(xx + self.gx, yy + self.gy)
                        if _G.importantObjectAt(ccx, ccy, xxx, yyy) then
                            self.canBuild = false
                        end
                        if firstTerrainHeight ~= (_G.state.map.heightmap[ccx][ccy][xxx][yyy] or 0) * 2 then
                            totalTerrainDifference = totalTerrainDifference +
                                math.abs(
                                    firstTerrainHeight - (_G.state.map.heightmap[ccx][ccy][xxx][yyy] or 0) * 2)
                        end
                        if _G.state.map:isWaterAt(self.gx + xx, self.gy + yy) then
                            self.canBuild = false
                        end
                    end
                end
                self.totalTerrainDifference = totalTerrainDifference
                if self.totalTerrainDifference >= math.min(3 * self.width * self.height, 220) then
                    self.canBuild = false
                end
                if not building[self.building]:specialRequirements(self.gx, self.gy) then
                    self.canBuild = false
                    self.cannotBuildBecauseSpecial = true
                else
                    self.cannotBuildBecauseSpecial = false
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
                self.batch:flush()
                self.previousGx = self.gx
                self.previousGy = self.gy
                self.previousCanBuild = self.canBuild
                self.lastBuilding = self.building
            end
        end
    end
end

function BuildController:mousepressed(x, y)
    local gx, gy = _G.getTerrainTileOnMouse(x, y)
    gx, gy = gx - math.floor(self.width / 2), gy - math.floor(self.height / 2)
    local success = self:build(gx, gy)
    if success and self.firstTerrainHeight then
        for xx = 0, self.width - 1 do
            for yy = 0, self.height - 1 do
                _G.terrainSetHeight(xx + gx, yy + gy, self.firstTerrainHeight / 2)
            end
        end
    end
    self.firstTerrainHeight = nil
    return success
end

function BuildController:build(gx, gy)
    if self.active and self.gx > 0 and self.gx < 2048 and self.gy > 0 and self.gy < 2048 then
        if self.canBuild then
            self.canAfford = true
            if not self.start then
                for resource, amount in pairs(building[self.building].cost) do
                    if _G.state.resources[resource] < amount then
                        self.canAfford = false
                        print("Cannot afford building! Not enough " .. resource .. "!")
                        break
                    end
                end
                if self.canAfford then
                    for resource, amount in pairs(building[self.building].cost) do
                        _G.stockpile:take(resource, amount)
                    end
                    for xx = 0, building[self.building].w do
                        for yy = 0, building[self.building].h do
                            _G.removeObjectFromClassAtGlobal(gx + xx, gy + yy, "Shrub")
                        end
                    end
                    building[self.building]:build(gx, gy)
                    if self.onBuildCallback then
                        self.onBuildCallback()
                        self.onBuildCallback = nil
                    end
                    return true
                end
            else
                if self.building == "saxon_hall" then
                    building[self.building]:build(gx, gy)
                    self:set("stockpile")
                    return true
                elseif self.building == "stockpile" then
                    building[self.building]:build(gx, gy)
                    self:set("granary")
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
                elseif self.building == "granary" then
                    building[self.building]:build(gx, gy)
                    -- Starting food
                    for _ = 1, 26 do
                        _G.foodpile:store("bread")
                    end
                    self.active = false
                    self.start = false
                    ActionBar:showGroup("main")
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
        love.graphics.setColor(1, 1, 1, 0.5)
        love.graphics.draw(self.batch, self.FX, self.FY, nil, _G.state.scaleX)
        if self.canBuild then
            love.graphics.draw(objectAtlas, building[self.building].quad,
                self.FX - building[self.building].offsetX * _G.state.scaleX, self.FY - self.elevationOffsetY *
                _G.state.scaleX - building[self.building].offsetY * _G.state.scaleX, 0, _G.state.scaleX)
        end
        love.graphics.setColor(1, 1, 1, 1)
    end
end

return BuildController:new()
