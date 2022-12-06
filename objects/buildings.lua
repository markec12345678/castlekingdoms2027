local tileQuads = require("objects.object_quads")
local WoodenWall = require("objects.Structures.WoodenWall")
local WalkableWoodenWall = require("objects.Structures.WalkableWoodenWall")
local WoodenTower = require("objects.Structures.WoodenTower")
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
local Market = require("objects.Structures.Market")
local OxTether = require("objects.Structures.OxTether")
local WoodenGateEast = require("objects.Structures.WoodenGateEast")
local WoodenGateSouth = require("objects.Structures.WoodenGateSouth")

local objectFromTypeAt = _G.objectFromTypeAt
local chunkWidth = _G.chunkWidth

local buildings = {
    [SaxonHall.name] = {
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
    ["wooden_keep"] = {
        cost = {
            ["wood"] = 50
        },
    },
    ["keep"] = {
        cost = {
            ["wood"] = 50,
            ["stone"] = 100
        },
    },
    ["fortress"] = {
        cost = {
            ["stone"] = 200
        },
    },
    [Stockpile.name] = {
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
    [Granary.name] = {
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
    [Quarry.name] = {
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
    [Mine.name] = {
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
    [Orchard.name] = {
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
    [WoodenWall.name] = {
        quad = tileQuads["tile_buildings_wood_wall (1)"],
        offsetX = 0,
        offsetY = 112,
        w = 1,
        h = 1,
        cost = {
            ["wood"] = 1
        },
        build = function(self, gx, gy)
            WoodenWall:new(gx, gy)
        end,
        specialRequirements = function(self, _, _)
            return true
        end
    },
    [WalkableWoodenWall.name] = {
        quad = tileQuads["wood_wall_walkable"],
        offsetX = 0,
        offsetY = 112 - 44,
        w = 1,
        h = 1,
        cost = {
            ["wood"] = 1
        },
        build = function(self, gx, gy)
            WalkableWoodenWall:new(gx, gy)
        end,
        specialRequirements = function(self, _, _)
            return true
        end
    },
    [WoodenTower.name] = {
        quad = tileQuads["wood_tower"],
        offsetX = 16,
        offsetY = 112 - 64 + 32 - 16 + 3,
        w = 2,
        h = 2,
        cost = {
            ["wood"] = 1
        },
        build = function(self, gx, gy)
            WoodenTower:new(gx, gy)
        end,
        specialRequirements = function(self, _, _)
            return true
        end
    },
    [WoodenGateEast.name] = {
        quad = tileQuads["wooden_gate (1)"],
        offsetX = 16 * 3 - 16,
        offsetY = 140 - 48 + 7,
        w = 3,
        h = 3,
        cost = {
            ["wood"] = 4
        },
        build = function(self, gx, gy)
            for x = 0, 2 do
                for y = 0, 2 do
                    _G.DestructionController:destroyAtLocation(gx + x, gy + y)
                end
            end
            WoodenGateEast:new(gx, gy, "east")
        end,
        specialRequirements = function(self, _, _)
            return true
        end,
        overrideRequirements = function(this, self)
            self.targetGX, self.targetGY = self.gx + math.floor(self.width / 2),
                self.gy + math.floor(self.height / 2)
            local fcx, fcy, fxx, fyy = _G.getLocalCoordinatesFromGlobal(self.targetGX, self.targetGY)
            local firstTerrainHeight = (_G.state.map.heightmap[fcx][fcy][fxx][fyy] or 0) * 2
            self.firstTerrainHeight = firstTerrainHeight
            local totalTerrainDifference = 0
            for xx = 0, self.width - 1 do
                for yy = 0, self.height - 1 do
                    local ccx, ccy, xxx, yyy = _G.getLocalCoordinatesFromGlobal(xx + self.gx, yy + self.gy)
                    if _G.importantObjectAt(ccx, ccy, xxx, yyy) and not _G.objectFromClassAtGlobal(xx + self.gx, yy + self.gy, "WoodenWall") and
                        not _G.objectFromClassAtGlobal(xx + self.gx, yy + self.gy, "WalkableWoodenWall") then
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
            if not this:specialRequirements(self.gx, self.gy) then
                self.canBuild = false
                self.cannotBuildBecauseSpecial = true
            else
                self.cannotBuildBecauseSpecial = false
            end
            self.batch:clear()
            local type
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
    },
    [WoodenGateSouth.name] = {
        quad = tileQuads["wooden_gate (2)"],
        offsetX = 16 * 3 - 16,
        offsetY = 140 - 48,
        w = 3,
        h = 3,
        cost = {
            ["wood"] = 4
        },
        build = function(self, gx, gy)
            for x = 0, 2 do
                for y = 0, 2 do
                    _G.DestructionController:destroyAtLocation(gx + x, gy + y)
                end
            end
            WoodenGateSouth:new(gx, gy, "south")
        end,
        specialRequirements = function(self, _, _)
            return true
        end,
        overrideRequirements = function(this, self)
            self.targetGX, self.targetGY = self.gx + math.floor(self.width / 2),
                self.gy + math.floor(self.height / 2)
            local fcx, fcy, fxx, fyy = _G.getLocalCoordinatesFromGlobal(self.targetGX, self.targetGY)
            local firstTerrainHeight = (_G.state.map.heightmap[fcx][fcy][fxx][fyy] or 0) * 2
            self.firstTerrainHeight = firstTerrainHeight
            local totalTerrainDifference = 0
            for xx = 0, self.width - 1 do
                for yy = 0, self.height - 1 do
                    local ccx, ccy, xxx, yyy = _G.getLocalCoordinatesFromGlobal(xx + self.gx, yy + self.gy)
                    if _G.importantObjectAt(ccx, ccy, xxx, yyy) and not _G.objectFromClassAtGlobal(xx + self.gx, yy + self.gy, "WoodenWall") and
                        not _G.objectFromClassAtGlobal(xx + self.gx, yy + self.gy, "WalkableWoodenWall") then
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
            if not this:specialRequirements(self.gx, self.gy) then
                self.canBuild = false
                self.cannotBuildBecauseSpecial = true
            else
                self.cannotBuildBecauseSpecial = false
            end
            self.batch:clear()
            local type
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
    },
    [WheatFarm.name] = {
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
    [WoodcutterHut.name] = {
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
    [Windmill.name] = {
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
    [Bakery.name] = {
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
    [House.name] = {
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
    [Market.name] = {
        quad = tileQuads["market"],
        offsetX = 69 - 5,
        offsetY = 194 - 105 + 6,
        w = 5,
        h = 5,
        cost = {
            ["wood"] = 15
        },
        build = function(self, gx, gy)
            Market:new(gx, gy)
        end,
        specialRequirements = function(self, _, _)
            return true
        end
    },
    [OxTether.name] = {
        quad = tileQuads["stone_oax_base (1)"],
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

function buildings.getCost(building)
    return buildings[building].cost
end

return buildings
