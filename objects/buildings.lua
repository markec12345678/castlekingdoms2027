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
local Chapel = require("objects.Structures.Chapel")
local Church = require("objects.Structures.Church")
local Apothecary = require("objects.Structures.Apothecary")
local Cathedral = require("objects.Structures.Cathedral")
local WheatFarm = require("objects.Structures.WheatFarm")
local DairyFarm = require("objects.Structures.DairyFarm")
local HopsFarm = require("objects.Structures.HopsFarm")
local Windmill = require("objects.Structures.Windmill")
local Bakery = require("objects.Structures.Bakery")
local House = require("objects.Structures.House")
local Market = require("objects.Structures.Market")
local OxTether = require("objects.Structures.OxTether")
local WoodenGateEast = require("objects.Structures.WoodenGateEast")
local WoodenGateSouth = require("objects.Structures.WoodenGateSouth")
local Inn = require("objects.Structures.Inn")
local Barracks = require("objects.Structures.Barracks")
local StoneBarracks = require("objects.Structures.StoneBarracks")
local ArcheryTarget = require("objects.Structures.ArcheryTarget")
local MeleeTarget = require("objects.Structures.MeleeTarget")
local WoodPole = require("objects.Structures.WoodPole")
local Armorer = require("objects.Structures.Armorer")
local Brewery = require("objects.Structures.Brewery")
local Armoury = require("objects.Structures.Armoury")
local FletcherWorkshop = require("objects.Structures.Fletcher")
local PoleturnerWorkshop = require("objects.Structures.Poleturner")
local BlacksmithWorkshop = require("objects.Structures.Blacksmith")
local WoodenKeep = require("objects.Structures.WoodenKeep")
local Keep = require("objects.Structures.Keep")
local Fortress = require("objects.Structures.Fortress")
local Maypole = require("objects.Structures.Maypole")
local SmallPond = require("objects.Structures.SmallPond")
local LargePond = require("objects.Structures.LargePond")
local SmallGarden = require("objects.Structures.SmallGarden")
local MediumGarden = require("objects.Structures.MediumGarden")
local LargeGarden = require("objects.Structures.LargeGarden")
local EngineersGuild = require("objects.Structures.EngineersGuild")
local TunnelersGuild = require("objects.Structures.TunnelersGuild")
local PerimeterTower = require("objects.Structures.PerimeterTower")
local DefenseTower = require("objects.Structures.DefenseTower")
local SquareTower = require("objects.Structures.SquareTower")
local RoundTower = require("objects.Structures.RoundTower")
local StoneGateEast = require("objects.Structures.StoneGateEast")
local StoneGateSouth = require("objects.Structures.StoneGateSouth")
local StoneGateEastBig = require("objects.Structures.StoneGateEastBig")
local StoneGateSouthBig = require("objects.Structures.StoneGateSouthBig")

local warningTooltip = require("states.ui.warning_tooltip")

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
    [WoodenKeep.name] = {
        cost = {
            ["wood"] = 50
        },
    },
    [Keep.name] = {
        cost = {
            ["wood"] = 50,
            ["stone"] = 100
        },
    },
    [Fortress.name] = {
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
            ["stone"] = 5
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
            warningTooltip:ShowTooltip("Needs to placed adjacent to a stockpile!")
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
            warningTooltip:ShowTooltip("Needs to placed adjacent to a granary!")
        end
    },
    [Quarry.name] = {
        quad = tileQuads["stone_quarry"],
        offsetX = 64 + 16,
        offsetY = 7 * 16 + 6,
        w = 6,
        h = 6,
        cost = {
            ["wood"] = 20
        },
        build = function(self, gx, gy)
            local stoneObjects = {}
            for xx = 0, 4 do
                for yy = 0, 4 do
                    if _G.objectFromClassAtGlobal(gx + xx, gy + yy, "Stone") then
                        local xyTable = {x = xx, y = yy}
                        table.insert(stoneObjects, xyTable)
                    end
                end
            end
            Quarry:new(gx, gy, stoneObjects)
        end,
        specialRequirements = function(self, gx, gy)
            local totalTiles = 0
            local tilesWithStone = 0
            for w = gx, self.w + gx do
                for h = gy, self.h + gy do
                    totalTiles = totalTiles + 1
                    if _G.objectFromClassAtGlobal(w, h, "Stone") then
                        tilesWithStone = tilesWithStone + 1
                    end
                end
            end
            -- if 80% of the tiles are stone, allow construction
            if tilesWithStone / totalTiles >= 0.8 then
                return true
            end
            warningTooltip:ShowTooltip("Needs to placed on top of stone!")
        end,
        overrideRequirements = function(this, self)
            local Terrain = require("terrain.terrain")
            self.targetGX, self.targetGY = self.gx + math.floor(self.width / 2),
                self.gy + math.floor(self.height / 2)
            local fcx, fcy, fxx, fyy = _G.getLocalCoordinatesFromGlobal(self.targetGX, self.targetGY)
            local firstTerrainHeight = (_G.state.map.heightmap[fcx][fcy][fxx][fyy] or 0) * 2
            self.firstTerrainHeight = firstTerrainHeight
            local totalTerrainDifference = 0
            for xx = 0, self.width - 1 do
                for yy = 0, self.height - 1 do
                    if _G.objectFromSubclassAtGlobal(xx + self.gx, yy + self.gy, "Unit") then
                        self.canBuild = false
                        warningTooltip:ShowTooltip("There are units in the way!")
                        break
                    elseif _G.objectFromSubclassAtGlobal(xx + self.gx, yy + self.gy, "Structure") then
                        self.canBuild = false
                        warningTooltip:ShowTooltip("There are structures in the way!")
                        break
                    end
                    local ccx, ccy, xxx, yyy = _G.getLocalCoordinatesFromGlobal(xx + self.gx, yy + self.gy)
                    if firstTerrainHeight ~= (_G.state.map.heightmap[ccx][ccy][xxx][yyy] or 0) * 2 then
                        totalTerrainDifference = totalTerrainDifference +
                            math.abs(
                                firstTerrainHeight - (_G.state.map.heightmap[ccx][ccy][xxx][yyy] or 0) * 2)
                    end
                    if _G.state.map:isWaterAt(self.gx + xx, self.gy + yy) then
                        self.canBuild = false
                        warningTooltip:ShowTooltip("Cannot build on top of water!")
                        break
                    end
                    if Terrain:getTerrainBiomeAt(self.gx + xx, self.gy + yy) == _G.terrainBiome.seaWalkable then
                        self.canBuild = false
                        warningTooltip:ShowTooltip("Cannot build on top of water!")
                        break
                    end
                end
            end
            self.totalTerrainDifference = totalTerrainDifference
            if self.totalTerrainDifference >= math.min(3 * self.width * self.height, 220) then
                self.canBuild = false
                warningTooltip:ShowTooltip("Terrain is too uneven!")
            end
            if not this:specialRequirements(self.gx, self.gy) then
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
            if self.canBuild then
                warningTooltip:HideTooltip()
            end
            self.batch:flush()
            self.previousGx = self.gx
            self.previousGy = self.gy
            self.previousCanBuild = self.canBuild
            self.lastBuilding = self.building
        end
    },
    [Mine.name] = {
        quad = tileQuads["iron_mine"],
        offsetX = 48,
        offsetY = 64 - 16 - 4,
        w = 4,
        h = 4,
        cost = {
            ["wood"] = 20
        },
        build = function(self, gx, gy)
            local ironObjects = {}
            for xx = 0, 3 do
                for yy = 0, 3 do
                    if _G.objectFromClassAtGlobal(gx + xx, gy + yy, "Iron") then
                        local xyTable = {x = xx, y = yy}
                        table.insert(ironObjects, xyTable)
                    end
                end
            end
            Mine:new(gx, gy, ironObjects)
        end,
        specialRequirements = function(self, gx, gy)
            for w = gx, self.w + gx do
                for h = gy, self.h + gy do
                    if _G.objectFromClassAtGlobal(w, h, "Iron") then
                        return true
                    end
                end
            end
            warningTooltip:ShowTooltip("Needs to placed on top of iron ore!")
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
                    if _G.objectFromSubclassAtGlobal(xx + self.gx, yy + self.gy, "Unit") then
                        self.canBuild = false
                        warningTooltip:ShowTooltip("There are units in the way!")
                        break
                    elseif _G.objectFromSubclassAtGlobal(xx + self.gx, yy + self.gy, "Structure") then
                        self.canBuild = false
                        warningTooltip:ShowTooltip("There are structures in the way!")
                        break
                    end
                    local ccx, ccy, xxx, yyy = _G.getLocalCoordinatesFromGlobal(xx + self.gx, yy + self.gy)
                    if firstTerrainHeight ~= (_G.state.map.heightmap[ccx][ccy][xxx][yyy] or 0) * 2 then
                        totalTerrainDifference = totalTerrainDifference +
                            math.abs(
                                firstTerrainHeight - (_G.state.map.heightmap[ccx][ccy][xxx][yyy] or 0) * 2)
                    end
                    if _G.state.map:isWaterAt(self.gx + xx, self.gy + yy) then
                        self.canBuild = false
                        warningTooltip:ShowTooltip("Cannot build on top of water!")
                        break
                    end
                    local Terrain = require("terrain.terrain")
                    if Terrain:getTerrainBiomeAt(self.gx + xx, self.gy + yy) == _G.terrainBiome.seaWalkable then
                        self.canBuild = false
                        warningTooltip:ShowTooltip("Cannot build on top of water!")
                        break
                    end
                end
            end
            self.totalTerrainDifference = totalTerrainDifference
            if self.totalTerrainDifference >= math.min(3 * self.width * self.height, 220) then
                self.canBuild = false
                warningTooltip:ShowTooltip("Terrain is too uneven!")
            end
            if not this:specialRequirements(self.gx, self.gy) then
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
            if self.canBuild then
                warningTooltip:HideTooltip()
            end
            self.batch:flush()
            self.previousGx = self.gx
            self.previousGy = self.gy
            self.previousCanBuild = self.canBuild
            self.lastBuilding = self.building
        end
    },
    [Chapel.name] = {
        quad = tileQuads["church_small"],
        offsetX = 70 + 10,
        offsetY = 95 - 10,
        w = 6,
        h = 6,
        cost = {
            ["stone"] = 10,
            ["gold"] = 100,
        },
        build = function(self, gx, gy)
            Chapel:new(gx, gy)
        end,
        specialRequirements = function(self, _, _)
            return true
        end
    },
    [Church.name] = {
        quad = tileQuads["church_medium"],
        offsetX = 128,
        offsetY = 148,
        w = 9,
        h = 9,
        cost = {
            ["stone"] = 30,
            ["gold"] = 100,
        },
        build = function(self, gx, gy)
            Church:new(gx, gy)
        end,
        specialRequirements = function(self, _, _)
            return true
        end
    },
    [Cathedral.name] = {
        quad = tileQuads["church_large"],
        offsetX = 190,
        offsetY = 193,
        w = 13,
        h = 13,
        cost = {
            ["stone"] = 50,
            ["gold"] = 100,
        },
        build = function(self, gx, gy)
            Cathedral:new(gx, gy)
        end,
        specialRequirements = function(self, _, _)
            return true
        end
    },
    [Apothecary.name] = {
        quad = tileQuads["apothecary"],
        offsetX = 78,
        offsetY = 88,
        w = 6,
        h = 6,
        cost = {
            ["wood"] = 5
        },
        build = function(self, gx, gy)
            Apothecary:new(gx, gy)
        end,
        specialRequirements = function(self, _, _)
            return true
        end
    },
    [Orchard.name] = {
        quad = tileQuads["farm (3)"],
        offsetX = 32,
        offsetY = 48 + 6,
        w = 12,
        h = 12,
        cost = {
            ["wood"] = 5
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
            ["wood"] = 5
        },
        build = function(self, gx, gy)
            WoodenTower:new(gx, gy)
        end,
        specialRequirements = function(self, _, _)
            return true
        end
    },
    [PerimeterTower.name] = {
        quad = tileQuads["small_tower (1)"],
        offsetX = 48,
        offsetY = 174,
        w = 4,
        h = 4,
        cost = {
            ["stone"] = 10
        },
        build = function(self, gx, gy)
            PerimeterTower:new(gx, gy)
        end,
        specialRequirements = function(self, _, _)
            return true
        end
    },
    [DefenseTower.name] = {
        quad = tileQuads["medium_tower (1)"],
        offsetX = 64,
        offsetY = 193,
        w = 5,
        h = 5,
        cost = {
            ["stone"] = 15
        },
        build = function(self, gx, gy)
            DefenseTower:new(gx, gy)
        end,
        specialRequirements = function(self, _, _)
            return true
        end
    },
    [SquareTower.name] = {
        quad = tileQuads["large_tower (1)"],
        offsetX = 80,
        offsetY = 213,
        w = 6,
        h = 6,
        cost = {
            ["stone"] = 35
        },
        build = function(self, gx, gy)
            SquareTower:new(gx, gy)
        end,
        specialRequirements = function(self, _, _)
            return true
        end
    },
    [RoundTower.name] = {
        quad = tileQuads["round_tower (1)"],
        offsetX = 80,
        offsetY = 209,
        w = 6,
        h = 6,
        cost = {
            ["stone"] = 40
        },
        build = function(self, gx, gy)
            RoundTower:new(gx, gy)
        end,
        specialRequirements = function(self, _, _)
            return true
        end
    },
    [Armoury.name] = {
        quad = tileQuads["armory (2)"],
        offsetX = 48,
        offsetY = 84,
        w = 4,
        h = 4,
        cost = {
            ["wood"] = 10
        },
        build = function(self, gx, gy)
            if _G.state.firstArmoury then
                _G.state.firstArmoury = false
            end
            Armoury:new(gx, gy)
        end,
        specialRequirements = function(self, gx, gy)
            if _G.BuildingManager:count("Armoury") == 0 then
                _G.state.firstArmoury = true
            end
            if _G.state.firstArmoury then
                return true
            end
            local i, o, cxx, cyy
            for w = gx - 1, self.w + gx do
                for h = gy - 1, self.h + gy do
                    i = (w) % (chunkWidth)
                    o = (h) % (chunkWidth)
                    cxx = math.floor(w / chunkWidth)
                    cyy = math.floor(h / chunkWidth)
                    if objectFromTypeAt(cxx, cyy, i, o, "Armoury") or
                        objectFromTypeAt(cxx, cyy, i, o, "ArmouryAlias") then
                        return true
                    end
                end
            end
            warningTooltip:ShowTooltip("Needs to placed adjacent to an armory!")
        end
    },
    [WoodenGateEast.name] = {
        quad = tileQuads["wooden_gate (1)"],
        offsetX = 16 * 3 - 16,
        offsetY = 140 - 48 + 7,
        w = 3,
        h = 3,
        cost = {
            ["wood"] = 10
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
                    if _G.importantObjectAt(ccx, ccy, xxx, yyy) and
                        not _G.objectFromClassAtGlobal(xx + self.gx, yy + self.gy, "WoodenWall") and
                        not _G.objectFromClassAtGlobal(xx + self.gx, yy + self.gy, "WalkableWoodenWall") then
                        self.canBuild = false
                        warningTooltip:ShowTooltip("There are obstacles in the way!")
                        break
                    end
                    if firstTerrainHeight ~= (_G.state.map.heightmap[ccx][ccy][xxx][yyy] or 0) * 2 then
                        totalTerrainDifference = totalTerrainDifference +
                            math.abs(
                                firstTerrainHeight - (_G.state.map.heightmap[ccx][ccy][xxx][yyy] or 0) * 2)
                    end
                    if _G.state.map:isWaterAt(self.gx + xx, self.gy + yy) then
                        self.canBuild = false
                        warningTooltip:ShowTooltip("Cannot build on top of water!")
                        break
                    end
                    local Terrain = require("terrain.terrain")
                    if Terrain:getTerrainBiomeAt(self.gx + xx, self.gy + yy) == _G.terrainBiome.seaWalkable then
                        self.canBuild = false
                        warningTooltip:ShowTooltip("Cannot build on top of water!")
                        break
                    end
                end
            end
            self.totalTerrainDifference = totalTerrainDifference
            if self.totalTerrainDifference >= math.min(3 * self.width * self.height, 220) then
                self.canBuild = false
                warningTooltip:ShowTooltip("Terrain is too uneven!")
            end
            if not this:specialRequirements(self.gx, self.gy) then
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
            if self.canBuild then
                warningTooltip:HideTooltip()
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
            ["wood"] = 10
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
                    if _G.importantObjectAt(ccx, ccy, xxx, yyy) and
                        not _G.objectFromClassAtGlobal(xx + self.gx, yy + self.gy, "WoodenWall") and
                        not _G.objectFromClassAtGlobal(xx + self.gx, yy + self.gy, "WalkableWoodenWall") then
                        self.canBuild = false
                        warningTooltip:ShowTooltip("There are obstacles in the way!")
                        break
                    end
                    if firstTerrainHeight ~= (_G.state.map.heightmap[ccx][ccy][xxx][yyy] or 0) * 2 then
                        totalTerrainDifference = totalTerrainDifference +
                            math.abs(
                                firstTerrainHeight - (_G.state.map.heightmap[ccx][ccy][xxx][yyy] or 0) * 2)
                    end
                    if _G.state.map:isWaterAt(self.gx + xx, self.gy + yy) then
                        self.canBuild = false
                        warningTooltip:ShowTooltip("Cannot build on top of water!")
                        break
                    end
                    local Terrain = require("terrain.terrain")
                    if Terrain:getTerrainBiomeAt(self.gx + xx, self.gy + yy) == _G.terrainBiome.seaWalkable then
                        self.canBuild = false
                        warningTooltip:ShowTooltip("Cannot build on top of water!")
                        break
                    end
                end
            end
            self.totalTerrainDifference = totalTerrainDifference
            if self.totalTerrainDifference >= math.min(3 * self.width * self.height, 220) then
                self.canBuild = false
                warningTooltip:ShowTooltip("Terrain is too uneven!")
            end
            if not this:specialRequirements(self.gx, self.gy) then
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
            if self.canBuild then
                warningTooltip:HideTooltip()
            end
            self.batch:flush()
            self.previousGx = self.gx
            self.previousGy = self.gy
            self.previousCanBuild = self.canBuild
            self.lastBuilding = self.building
        end
    },
    [StoneGateEast.name] = {
        quad = tileQuads["small_stone_gate (1)"],
        offsetX = 66,
        offsetY = 153,
        w = 5,
        h = 5,
        cost = {
            ["stone"] = 10
        },
        build = function(self, gx, gy)
            for x = 0, 2 do
                for y = 0, 2 do
                    _G.DestructionController:destroyAtLocation(gx + x, gy + y)
                end
            end
            StoneGateEast:new(gx, gy, "east")
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
                    if _G.importantObjectAt(ccx, ccy, xxx, yyy) and
                        not _G.objectFromClassAtGlobal(xx + self.gx, yy + self.gy, "WoodenWall") and
                        not _G.objectFromClassAtGlobal(xx + self.gx, yy + self.gy, "WalkableWoodenWall") then
                        self.canBuild = false
                        warningTooltip:ShowTooltip("There are obstacles in the way!")
                        break
                    end
                    if firstTerrainHeight ~= (_G.state.map.heightmap[ccx][ccy][xxx][yyy] or 0) * 2 then
                        totalTerrainDifference = totalTerrainDifference +
                            math.abs(
                                firstTerrainHeight - (_G.state.map.heightmap[ccx][ccy][xxx][yyy] or 0) * 2)
                    end
                    if _G.state.map:isWaterAt(self.gx + xx, self.gy + yy) then
                        self.canBuild = false
                        warningTooltip:ShowTooltip("Cannot build on top of water!")
                        break
                    end
                    local Terrain = require("terrain.terrain")
                    if Terrain:getTerrainBiomeAt(self.gx + xx, self.gy + yy) == _G.terrainBiome.seaWalkable then
                        self.canBuild = false
                        warningTooltip:ShowTooltip("Cannot build on top of water!")
                        break
                    end
                end
            end
            self.totalTerrainDifference = totalTerrainDifference
            if self.totalTerrainDifference >= math.min(3 * self.width * self.height, 220) then
                self.canBuild = false
                warningTooltip:ShowTooltip("Terrain is too uneven!")
            end
            if not this:specialRequirements(self.gx, self.gy) then
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
            if self.canBuild then
                warningTooltip:HideTooltip()
            end
            self.batch:flush()
            self.previousGx = self.gx
            self.previousGy = self.gy
            self.previousCanBuild = self.canBuild
            self.lastBuilding = self.building
        end
    },
    [StoneGateSouth.name] = {
        quad = tileQuads["small_stone_gate (2)"],
        offsetX = 66,
        offsetY = 153,
        w = 5,
        h = 5,
        cost = {
            ["stone"] = 10
        },
        build = function(self, gx, gy)
            for x = 0, 2 do
                for y = 0, 2 do
                    _G.DestructionController:destroyAtLocation(gx + x, gy + y)
                end
            end
            StoneGateSouth:new(gx, gy, "south")
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
                    if _G.importantObjectAt(ccx, ccy, xxx, yyy) and
                        not _G.objectFromClassAtGlobal(xx + self.gx, yy + self.gy, "WoodenWall") and
                        not _G.objectFromClassAtGlobal(xx + self.gx, yy + self.gy, "WalkableWoodenWall") then
                        self.canBuild = false
                        warningTooltip:ShowTooltip("There are obstacles in the way!")
                        break
                    end
                    if firstTerrainHeight ~= (_G.state.map.heightmap[ccx][ccy][xxx][yyy] or 0) * 2 then
                        totalTerrainDifference = totalTerrainDifference +
                            math.abs(
                                firstTerrainHeight - (_G.state.map.heightmap[ccx][ccy][xxx][yyy] or 0) * 2)
                    end
                    if _G.state.map:isWaterAt(self.gx + xx, self.gy + yy) then
                        self.canBuild = false
                        warningTooltip:ShowTooltip("Cannot build on top of water!")
                        break
                    end
                    local Terrain = require("terrain.terrain")
                    if Terrain:getTerrainBiomeAt(self.gx + xx, self.gy + yy) == _G.terrainBiome.seaWalkable then
                        self.canBuild = false
                        warningTooltip:ShowTooltip("Cannot build on top of water!")
                        break
                    end
                end
            end
            self.totalTerrainDifference = totalTerrainDifference
            if self.totalTerrainDifference >= math.min(3 * self.width * self.height, 220) then
                self.canBuild = false
                warningTooltip:ShowTooltip("Terrain is too uneven!")
            end
            if not this:specialRequirements(self.gx, self.gy) then
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
            if self.canBuild then
                warningTooltip:HideTooltip()
            end
            self.batch:flush()
            self.previousGx = self.gx
            self.previousGy = self.gy
            self.previousCanBuild = self.canBuild
            self.lastBuilding = self.building
        end
    },
    [StoneGateEastBig.name] = {
        quad = tileQuads["large_stone_gate (1)"],
        offsetX = 96,
        offsetY = 163,
        w = 7,
        h = 7,
        cost = {
            ["stone"] = 30
        },
        build = function(self, gx, gy)
            for x = 0, 2 do
                for y = 0, 2 do
                    _G.DestructionController:destroyAtLocation(gx + x, gy + y)
                end
            end
            StoneGateEastBig:new(gx, gy, "east")
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
                    if _G.importantObjectAt(ccx, ccy, xxx, yyy) and
                        not _G.objectFromClassAtGlobal(xx + self.gx, yy + self.gy, "WoodenWall") and
                        not _G.objectFromClassAtGlobal(xx + self.gx, yy + self.gy, "WalkableWoodenWall") then
                        self.canBuild = false
                        warningTooltip:ShowTooltip("There are obstacles in the way!")
                        break
                    end
                    if firstTerrainHeight ~= (_G.state.map.heightmap[ccx][ccy][xxx][yyy] or 0) * 2 then
                        totalTerrainDifference = totalTerrainDifference +
                            math.abs(
                                firstTerrainHeight - (_G.state.map.heightmap[ccx][ccy][xxx][yyy] or 0) * 2)
                    end
                    if _G.state.map:isWaterAt(self.gx + xx, self.gy + yy) then
                        self.canBuild = false
                        warningTooltip:ShowTooltip("Cannot build on top of water!")
                        break
                    end
                    local Terrain = require("terrain.terrain")
                    if Terrain:getTerrainBiomeAt(self.gx + xx, self.gy + yy) == _G.terrainBiome.seaWalkable then
                        self.canBuild = false
                        warningTooltip:ShowTooltip("Cannot build on top of water!")
                        break
                    end
                end
            end
            self.totalTerrainDifference = totalTerrainDifference
            if self.totalTerrainDifference >= math.min(3 * self.width * self.height, 220) then
                self.canBuild = false
                warningTooltip:ShowTooltip("Terrain is too uneven!")
            end
            if not this:specialRequirements(self.gx, self.gy) then
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
            if self.canBuild then
                warningTooltip:HideTooltip()
            end
            self.batch:flush()
            self.previousGx = self.gx
            self.previousGy = self.gy
            self.previousCanBuild = self.canBuild
            self.lastBuilding = self.building
        end
    },
    [StoneGateSouthBig.name] = {
        quad = tileQuads["large_stone_gate (2)"],
        offsetX = 96,
        offsetY = 163,
        w = 7,
        h = 7,
        cost = {
            ["stone"] = 30
        },
        build = function(self, gx, gy)
            for x = 0, 2 do
                for y = 0, 2 do
                    _G.DestructionController:destroyAtLocation(gx + x, gy + y)
                end
            end
            StoneGateSouthBig:new(gx, gy, "south")
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
                    if _G.importantObjectAt(ccx, ccy, xxx, yyy) and
                        not _G.objectFromClassAtGlobal(xx + self.gx, yy + self.gy, "WoodenWall") and
                        not _G.objectFromClassAtGlobal(xx + self.gx, yy + self.gy, "WalkableWoodenWall") then
                        self.canBuild = false
                        warningTooltip:ShowTooltip("There are obstacles in the way!")
                        break
                    end
                    if firstTerrainHeight ~= (_G.state.map.heightmap[ccx][ccy][xxx][yyy] or 0) * 2 then
                        totalTerrainDifference = totalTerrainDifference +
                            math.abs(
                                firstTerrainHeight - (_G.state.map.heightmap[ccx][ccy][xxx][yyy] or 0) * 2)
                    end
                    if _G.state.map:isWaterAt(self.gx + xx, self.gy + yy) then
                        self.canBuild = false
                        warningTooltip:ShowTooltip("Cannot build on top of water!")
                        break
                    end
                    local Terrain = require("terrain.terrain")
                    if Terrain:getTerrainBiomeAt(self.gx + xx, self.gy + yy) == _G.terrainBiome.seaWalkable then
                        self.canBuild = false
                        warningTooltip:ShowTooltip("Cannot build on top of water!")
                        break
                    end
                end
            end
            self.totalTerrainDifference = totalTerrainDifference
            if self.totalTerrainDifference >= math.min(3 * self.width * self.height, 220) then
                self.canBuild = false
                warningTooltip:ShowTooltip("Terrain is too uneven!")
            end
            if not this:specialRequirements(self.gx, self.gy) then
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
            if self.canBuild then
                warningTooltip:HideTooltip()
            end
            self.batch:flush()
            self.previousGx = self.gx
            self.previousGy = self.gy
            self.previousCanBuild = self.canBuild
            self.lastBuilding = self.building
        end
    },
    [WheatFarm.name] = {
        quad = tileQuads["farm (1)"],
        offsetX = 32,
        offsetY = 40 + 6 + 8,
        w = 12,
        h = 12,
        cost = {
            ["wood"] = 15
        },
        build = function(self, gx, gy)
            WheatFarm:new(gx, gy)
        end,
        specialRequirements = function(self, _, _)
            return true
        end
    },
    [HopsFarm.name] = {
        quad = tileQuads["farm (2)"],
        offsetX = 32,
        offsetY = 64 + 6 + 8,
        w = 12,
        h = 12,
        cost = {
            ["wood"] = 15
        },
        build = function(self, gx, gy)
            HopsFarm:new(gx, gy)
        end,
        specialRequirements = function(self, _, _)
            return true
        end
    },
    [DairyFarm.name] = {
        quad = tileQuads["farm (4)"],
        offsetX = 32,
        offsetY = 48 + 6,
        w = 10,
        h = 10,
        cost = {
            ["wood"] = 10
        },
        build = function(self, gx, gy)
            DairyFarm:new(gx, gy)
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
            ["wood"] = 10
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
            ["wood"] = 10
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
            ["wood"] = 5
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
    [Inn.name] = {
        quad = tileQuads["inn"],
        offsetX = 64,
        offsetY = 90,
        w = 5,
        h = 5,
        cost = {
            ["wood"] = 15,
            ["gold"] = 100
        },
        build = function(self, gx, gy)
            Inn:new(gx, gy)
        end,
        specialRequirements = function(self, _, _)
            return true
        end
    },
    [Barracks.name] = {
        quad = tileQuads["barracks (1)"],
        offsetX = 64,
        offsetY = 69,
        w = 10,
        h = 10,
        cost = {
            ["wood"] = 15
        },
        build = function(self, gx, gy)
            local barracks = Barracks:new(gx, gy)
            local archery = ArcheryTarget:new(gx + 7, gy + 7)
            local melee = MeleeTarget:new(gx + 2, gy + 7)
            local pole = WoodPole:new(gx + 7, gy + 2)
            archery.parent = barracks
            melee.parent = barracks
            pole.parent = barracks
        end,
        specialRequirements = function(self, _, _)
            return true
        end
    },
    [StoneBarracks.name] = {
        quad = tileQuads["barracks (2)"],
        offsetX = 64,
        offsetY = 80,
        w = 10,
        h = 10,
        cost = {
            ["stone"] = 15
        },
        build = function(self, gx, gy)
            local stonebarracks = StoneBarracks:new(gx, gy)
            local archery = ArcheryTarget:new(gx + 7, gy + 7)
            local melee = MeleeTarget:new(gx + 2, gy + 7)
            local pole = WoodPole:new(gx + 7, gy + 2)
            archery.parent = stonebarracks
            melee.parent = stonebarracks
            pole.parent = stonebarracks
        end,
        specialRequirements = function(self, _, _)
            return true
        end
    },
    [EngineersGuild.name] = {
        quad = tileQuads["siege_building (1)"],
        offsetX = 64,
        offsetY = 59,
        w = 5,
        h = 10,
        cost = {
            ["wood"] = 10,
            ["gold"] = 100
        },
        build = function(self, gx, gy)
            EngineersGuild:new(gx, gy)
        end,
        specialRequirements = function(self, _, _)
            return true
        end
    },
    [TunnelersGuild.name] = {
        quad = tileQuads["siege_building (2)"],
        offsetX = 64,
        offsetY = 59,
        w = 5,
        h = 10,
        cost = {
            ["wood"] = 10,
            ["gold"] = 100
        },
        build = function(self, gx, gy)
            TunnelersGuild:new(gx, gy)
        end,
        specialRequirements = function(self, _, _)
            return true
        end
    },
    [Armorer.name] = {
        quad = tileQuads["armourer_workshop (18)"],
        offsetX = 48,
        offsetY = 52,
        w = 4,
        h = 4,
        cost = {
            ["wood"] = 20,
            ["gold"] = 100
        },
        build = function(self, gx, gy)
            Armorer:new(gx, gy)
        end,
        specialRequirements = function(self, _, _)
            if _G.BuildingManager:count("Armoury") >= 1 then
                return true
            else
                warningTooltip:ShowTooltip("You need an armoury to build this!")
            end
        end
    },
    [FletcherWorkshop.name] = {
        quad = tileQuads["fletcher_workshop (18)"],
        offsetX = 49 - 1,
        offsetY = 53 - 5,
        w = 4,
        h = 4,
        cost = {
            ["wood"] = 10,
            ["gold"] = 100
        },
        build = function(self, gx, gy)
            FletcherWorkshop:new(gx, gy)
        end,
        specialRequirements = function(self, _, _)
            if _G.BuildingManager:count("Armoury") >= 1 then
                return true
            else
                warningTooltip:ShowTooltip("You need an armoury to build this!")
            end
        end
    },
    [PoleturnerWorkshop.name] = {
        quad = tileQuads["poleturner_workshop (18)"],
        offsetX = 48,
        offsetY = 44,
        w = 4,
        h = 4,
        cost = {
            ["wood"] = 10,
            ["gold"] = 100
        },
        build = function(self, gx, gy)
            PoleturnerWorkshop:new(gx, gy)
        end,
        specialRequirements = function(self, _, _)
            if _G.BuildingManager:count("Armoury") >= 1 then
                return true
            else
                warningTooltip:ShowTooltip("You need an armoury to build this!")
            end
        end
    },
    [BlacksmithWorkshop.name] = {
        quad = tileQuads["blacksmith_workshop (9)"],
        offsetX = 48,
        offsetY = 64,
        w = 4,
        h = 4,
        cost = {
            ["wood"] = 20,
            ["gold"] = 200
        },
        build = function(self, gx, gy)
            BlacksmithWorkshop:new(gx, gy)
        end,
        specialRequirements = function(self, _, _)
            if _G.BuildingManager:count("Armoury") >= 1 then
                return true
            else
                warningTooltip:ShowTooltip("You need an armoury to build this!")
            end
        end
    },
    [Brewery.name] = {
        quad = tileQuads["beer_workshop (18)"],
        offsetX = 48,
        offsetY = 131 - 64,
        w = 4,
        h = 4,
        cost = {
            ["wood"] = 10
        },
        build = function(self, gx, gy)
            Brewery:new(gx, gy)
        end,
        specialRequirements = function(self, _, _)
            return true
        end
    },
    [OxTether.name] = {
        quad = tileQuads["stone_oax_base (1)"],
        offsetY = 26,
        offsetX = 16,
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
                    if _G.importantObjectAt(ccx, ccy, xxx, yyy) then
                        self.canBuild = false
                        warningTooltip:ShowTooltip("There are obstacles in the way!")
                        break
                    end
                    if firstTerrainHeight ~= (_G.state.map.heightmap[ccx][ccy][xxx][yyy] or 0) * 2 then
                        totalTerrainDifference = totalTerrainDifference +
                            math.abs(
                                firstTerrainHeight - (_G.state.map.heightmap[ccx][ccy][xxx][yyy] or 0) * 2)
                    end
                    if _G.state.map:isWaterAt(self.gx + xx, self.gy + yy) then
                        self.canBuild = false
                        warningTooltip:ShowTooltip("Cannot build on top of water!")
                        break
                    end
                    local Terrain = require("terrain.terrain")
                    if Terrain:getTerrainBiomeAt(self.gx + xx, self.gy + yy) == _G.terrainBiome.seaWalkable then
                        self.canBuild = false
                        warningTooltip:ShowTooltip("Cannot build on top of water!")
                        break
                    end
                end
            end
            self.totalTerrainDifference = totalTerrainDifference
            if self.totalTerrainDifference >= math.min(3 * self.width * self.height, 220) then
                self.canBuild = false
                warningTooltip:ShowTooltip("Terrain is too uneven!")
            end
            if not this:specialRequirements(self.gx, self.gy) then
                self.canBuild = false
                self.cannotBuildBecauseSpecial = true
                warningTooltip:ShowTooltip("Needs to be placed close to an existing quarry!")
            else
                self.cannotBuildBecauseSpecial = false
            end
            if not self.start and not self:isBuildingAffordable(self.building) then
                self.canBuild = false
                warningTooltip:ShowTooltip("Not enough resources!")
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
            if self.canBuild then
                warningTooltip:HideTooltip()
            end
            self.batch:flush()
            self.previousGx = self.gx
            self.previousGy = self.gy
            self.previousCanBuild = self.canBuild
            self.lastBuilding = self.building
        end
    },
    ["Maypole"] = {
        quad = tileQuads["anim_maypole_full (1)"],
        w = 3,
        h = 3,
        offsetX = 32,
        offsetY = 50,
        cost = {
            ["wood"] = 2,
            ["gold"] = 30
        },
        build = function(self, gx, gy)
            Maypole:new(gx, gy)
        end,
        specialRequirements = function(self, _, _)
            return true
        end
    },
    ["SmallPond"] = {
        sprites = {
            {
                quad = tileQuads["tile_buildings_ponds (1)"],
                offsetX = 62,
                offsetY = 9
            },
            {
                quad = tileQuads["tile_buildings_ponds (2)"],
                offsetX = 62,
                offsetY = 9
            }
        },
        w = 5,
        h = 5,
        cost = {
            ["gold"] = 30
        },
        build = function(self, gx, gy, currentSprite)
            SmallPond:new(gx, gy, currentSprite)
        end,
        specialRequirements = function(self, _, _)
            return true
        end
    },
    ["LargePond"] = {
        sprites = {
            {
                quad = tileQuads["tile_buildings_ponds (3)"],
                offsetX = 78,
                offsetY = 0
            },
            {
                quad = tileQuads["tile_buildings_ponds (4)"],
                offsetX = 78,
                offsetY = 0
            }
        },
        w = 6,
        h = 6,
        cost = {
            ["gold"] = 30
        },
        build = function(self, gx, gy, currentSprite)
            LargePond:new(gx, gy, currentSprite)
        end,
        specialRequirements = function(self, _, _)
            return true
        end
    },
    ["SmallGarden"] = {
        sprites = {
            {
                quad = tileQuads["tile_buildings_gardens (1)"],
                offsetX = 16,
                offsetY = 20
            },
            {
                quad = tileQuads["tile_buildings_gardens (2)"],
                offsetX = 16,
                offsetY = 4
            },
            {
                quad = tileQuads["tile_buildings_gardens (3)"],
                offsetX = 16,
                offsetY = 2
            },
            {
                quad = tileQuads["tile_buildings_gardens (4)"],
                offsetX = 16,
                offsetY = 2
            },
            {
                quad = tileQuads["tile_buildings_gardens (5)"],
                offsetX = 16,
                offsetY = 2
            },
            {
                quad = tileQuads["tile_buildings_gardens (6)"],
                offsetX = 16,
                offsetY = 2
            }
        },
        w = 2,
        h = 2,
        cost = {
            ["gold"] = 30
        },
        build = function(self, gx, gy, currentSprite)
            SmallGarden:new(gx, gy, currentSprite)
        end,
        specialRequirements = function(self, _, _)
            return true
        end
    },
    ["MediumGarden"] = {
        sprites = {
            {
                quad = tileQuads["tile_buildings_gardens (7)"],
                offsetX = 32,
                offsetY = 20
            },
            {
                quad = tileQuads["tile_buildings_gardens (8)"],
                offsetX = 32,
                offsetY = 12
            },
            {
                quad = tileQuads["tile_buildings_gardens (9)"],
                offsetX = 32,
                offsetY = 4
            }
        },
        w = 3,
        h = 3,
        cost = {
            ["gold"] = 30
        },
        build = function(self, gx, gy, currentSprite)
            MediumGarden:new(gx, gy, currentSprite)
        end,
        specialRequirements = function(self, _, _)
            return true
        end
    },
    ["LargeGarden"] = {
        sprites = {
            {
                quad = tileQuads["tile_buildings_gardens (10)"],
                offsetX = 48,
                offsetY = 18
            },
            {
                quad = tileQuads["tile_buildings_gardens (11)"],
                offsetX = 48,
                offsetY = 4
            },
            {
                quad = tileQuads["tile_buildings_gardens (12)"],
                offsetX = 48,
                offsetY = 8
            }
        },
        w = 4,
        h = 4,
        cost = {
            ["gold"] = 30
        },
        build = function(self, gx, gy, currentSprite)
            LargeGarden:new(gx, gy, currentSprite)
        end,
        specialRequirements = function(self, _, _)
            return true
        end
    }
}

function buildings.getCost(building)
    return buildings[building].cost
end

return buildings
