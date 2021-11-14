local object, object_image = ...

local tile_quads = require('objects.object_quads')
local image = love.graphics.newImage("assets/tiles/info_tiles_strip.png")
local Peasant = require('objects.Units.Peasant')
local Castle = require('objects.Structures.Castle')
local Stockpile = require('objects.Structures.Stockpile')
local Granary = require('objects.Structures.Granary')
local Quarry = require('objects.Structures.Quarry')
local Mine = require('objects.Structures.Mine')
local WoodcutterHut = require('objects.Structures.WoodcutterHut')
local Campfire = require('objects.Structures.Campfire')
local Orchard = require('objects.Structures.Orchard')
local WheatFarm = require('objects.Structures.WheatFarm')
local Windmill = require('objects.Structures.Windmill')

local building = {
    ["castle"] = {
        quad = tile_quads["small_wooden_castle (1)"],
        offset_y = 93,
        offset_x = 6 * 15 + 6,
        w = 7,
        h = 15,
        cost = {
            ["wood"] = 50
        },
        build = function(self, gx, gy)
            Castle:new(gx, gy)
            Campfire:new(gx + 2, gy + 10)
            Peasant:new(_G.spawn_point_x, _G.spawn_point_y)
            Peasant:new(_G.spawn_point_x, _G.spawn_point_y)
            Peasant:new(_G.spawn_point_x, _G.spawn_point_y)
            Peasant:new(_G.spawn_point_x, _G.spawn_point_y)
            Peasant:new(_G.spawn_point_x, _G.spawn_point_y)
            Peasant:new(_G.spawn_point_x, _G.spawn_point_y)
            Peasant:new(_G.spawn_point_x, _G.spawn_point_y)
            Peasant:new(_G.spawn_point_x, _G.spawn_point_y)
            Peasant:new(_G.spawn_point_x, _G.spawn_point_y)
            Peasant:new(_G.spawn_point_x, _G.spawn_point_y)
            Peasant:new(_G.spawn_point_x, _G.spawn_point_y)
            Peasant:new(_G.spawn_point_x, _G.spawn_point_y)
            Peasant:new(_G.spawn_point_x, _G.spawn_point_y)
            Peasant:new(_G.spawn_point_x, _G.spawn_point_y)
            Peasant:new(_G.spawn_point_x, _G.spawn_point_y)
            Peasant:new(_G.spawn_point_x, _G.spawn_point_y)
            Peasant:new(_G.spawn_point_x, _G.spawn_point_y)
            Peasant:new(_G.spawn_point_x, _G.spawn_point_y)
            Peasant:new(_G.spawn_point_x, _G.spawn_point_y)
            Peasant:new(_G.spawn_point_x, _G.spawn_point_y)
            Peasant:new(_G.spawn_point_x, _G.spawn_point_y)
        end,
        special_requirements = function(self, gx, gy)
            return true
        end
    },
    ["stockpile"] = {
        quad = tile_quads["stockpile"],
        offset_x = 64,
        offset_y = 12,
        w = 5,
        h = 5,
        cost = {
            ["stone"] = 4
        },
        build = function(self, gx, gy)
            Stockpile:new(gx, gy)
        end,
        special_requirements = function(self, gx, gy)
            if not next(_G.stockpile.list) then
                return true
            end
            local i, o, cxx, cyy
            for w = gx - 1, self.w + gx do
                for h = gy - 1, self.h + gy do
                    i = (w) % (chunk_width)
                    o = (h) % (chunk_width)
                    cxx = math.floor(w / chunk_width)
                    cyy = math.floor(h / chunk_width)
                    if objectFromTypeAt(cxx, cyy, i, o, "Stockpile") or
                        objectFromTypeAt(cxx, cyy, i, o, "Stockpile_alias") then
                        return true
                    end
                end
            end
        end
    },
    ["granary"] = {
        quad = tile_quads["granary (1)"],
        offset_x = 3 * 15 + 3,
        offset_y = 62 + 16,
        w = 4,
        h = 4,
        cost = {
            ["wood"] = 10
        },
        build = function(self, gx, gy)
            Granary:new(gx, gy)
        end,
        special_requirements = function(self, gx, gy)
            if not next(_G.foodpile.list) then
                return true
            end
            local i, o, cxx, cyy
            for w = gx - 1, self.w + gx do
                for h = gy - 1, self.h + gy do
                    i = (w) % (chunk_width)
                    o = (h) % (chunk_width)
                    cxx = math.floor(w / chunk_width)
                    cyy = math.floor(h / chunk_width)
                    if objectFromTypeAt(cxx, cyy, i, o, "Granary") or objectFromTypeAt(cxx, cyy, i, o, "Granary_alias") then
                        return true
                    end
                end
            end
        end
    },
    ["quarry"] = {
        quad = tile_quads["stone_quarry"],
        offset_x = 64 + 16,
        offset_y = 7 * 16 + 6,
        w = 6,
        h = 6,
        cost = {
            ["wood"] = 24
        },
        build = function(self, gx, gy)
            Quarry:new(gx, gy)
        end,
        special_requirements = function(self, gx, gy)
            for w = gx, self.w + gx do
                for h = gy, self.h + gy do
                    if objectFromClassAtGlobal(w, h, "Stone") then
                        return true
                    end
                end
            end
        end,
        override_requirements = function(self, ctrl)
            local MX, MY = love.mouse.getPosition()
            local type = 1
            for xx = 0, ctrl.width - 1 do
                for yy = 0, ctrl.height - 1 do
                    local x = (xx + ctrl.gx) % (chunk_width)
                    local y = (yy + ctrl.gy) % (chunk_width)
                    local cx = math.floor((xx + ctrl.gx) / chunk_width)
                    local cy = math.floor((yy + ctrl.gy) / chunk_width)
                    if not _G.objectFromClassAtGlobal(xx + ctrl.gx, yy + ctrl.gy, "Stone") then
                        ctrl.can_build = false
                    end
                end
            end
            if not self:special_requirements(ctrl.gx, ctrl.gy) then
                ctrl.can_build = false
            end
            ctrl.batch:clear()
            for xx = 0, ctrl.width - 1 do
                for yy = 0, ctrl.height - 1 do
                    local x = (xx + ctrl.gx) % (chunk_width)
                    local y = (yy + ctrl.gy) % (chunk_width)
                    local cx = math.floor((xx + ctrl.gx) / chunk_width)
                    local cy = math.floor((yy + ctrl.gy) / chunk_width)
                    if _G.objectFromClassAtGlobal(xx + ctrl.gx, yy + ctrl.gy, "Stone") then
                        if ctrl.can_build then
                            type = 2
                        else
                            type = 4
                        end
                    elseif not importantObjectAt(cx, cy, x, y) then
                        if ctrl.can_build then
                            type = 2
                        else
                            type = 3
                        end
                    else
                        type = 1
                    end
                    ctrl.batch:add(ctrl.quads[type], (xx - yy) * tile_width * 0.5, (xx + yy) * tile_height * 0.5, 0, 1,
                        1)
                end
            end
            ctrl.batch:flush()
            ctrl.previous_gx = ctrl.gx
            ctrl.previous_gy = ctrl.gy
            ctrl.previous_can_build = ctrl.can_build
            ctrl.last_building = ctrl.building
        end
    },
    ["iron_mine"] = {
        quad = tile_quads["iron_mine"],
        offset_x = 48,
        offset_y = 64 - 16 - 4,
        w = 4,
        h = 4,
        cost = {
            ["wood"] = 10,
            ["stone"] = 10
        },
        build = function(self, gx, gy)
            Mine:new(gx, gy)
        end,
        special_requirements = function(self, gx, gy)
            for w = gx, self.w + gx do
                for h = gy, self.h + gy do
                    if objectFromClassAtGlobal(w, h, "Iron") then
                        return true
                    end
                end
            end
        end,
        override_requirements = function(self, ctrl)
            local MX, MY = love.mouse.getPosition()
            local type = 1
            for xx = 0, ctrl.width - 1 do
                for yy = 0, ctrl.height - 1 do
                    local x = (xx + ctrl.gx) % (chunk_width)
                    local y = (yy + ctrl.gy) % (chunk_width)
                    local cx = math.floor((xx + ctrl.gx) / chunk_width)
                    local cy = math.floor((yy + ctrl.gy) / chunk_width)
                    if not _G.objectFromClassAtGlobal(xx + ctrl.gx, yy + ctrl.gy, "Iron") then
                        ctrl.can_build = false
                    end
                end
            end
            if not self:special_requirements(ctrl.gx, ctrl.gy) then
                ctrl.can_build = false
            end
            ctrl.batch:clear()
            for xx = 0, ctrl.width - 1 do
                for yy = 0, ctrl.height - 1 do
                    local x = (xx + ctrl.gx) % (chunk_width)
                    local y = (yy + ctrl.gy) % (chunk_width)
                    local cx = math.floor((xx + ctrl.gx) / chunk_width)
                    local cy = math.floor((yy + ctrl.gy) / chunk_width)
                    if _G.objectFromClassAtGlobal(xx + ctrl.gx, yy + ctrl.gy, "Iron") then
                        if ctrl.can_build then
                            type = 2
                        else
                            type = 4
                        end
                    elseif not importantObjectAt(cx, cy, x, y) then
                        if ctrl.can_build then
                            type = 2
                        else
                            type = 3
                        end
                    else
                        type = 1
                    end
                    ctrl.batch:add(ctrl.quads[type], (xx - yy) * tile_width * 0.5, (xx + yy) * tile_height * 0.5, 0, 1,
                        1)
                end
            end
            ctrl.batch:flush()
            ctrl.previous_gx = ctrl.gx
            ctrl.previous_gy = ctrl.gy
            ctrl.previous_can_build = ctrl.can_build
            ctrl.last_building = ctrl.building
        end
    },
    ["orchard"] = {
        quad = tile_quads["farm (3)"],
        offset_x = 32,
        offset_y = 48 + 6,
        w = 12,
        h = 12,
        cost = {
            ["wood"] = 2
        },
        build = function(self, gx, gy)
            Orchard:new(gx, gy)
        end,
        special_requirements = function(self, gx, gy)
            return true
        end
    },
    ["wheat_farm"] = {
        quad = tile_quads["farm (2)"],
        offset_x = 32,
        offset_y = 64 + 6 + 8,
        w = 12,
        h = 12,
        cost = {
            ["wood"] = 2
        },
        build = function(self, gx, gy)
            WheatFarm:new(gx, gy)
        end,
        special_requirements = function(self, gx, gy)
            return true
        end
    },
    ["woodcutter_hut"] = {
        quad = tile_quads["woodcutter_hut"],
        offset_x = 32,
        offset_y = 32,
        w = 3,
        h = 3,
        cost = {
            ["wood"] = 3
        },
        build = function(self, gx, gy)
            WoodcutterHut:new(gx, gy)
        end,
        -- add requirement for w h
        special_requirements = function(self, gx, gy)
            return true
        end
    },
    ["windmill"] = {
        quad = tile_quads["windmill_whole"],
        offset_x = 32,
        offset_y = 243 - 48,
        w = 3,
        h = 3,
        cost = {
            ["wood"] = 3
        },
        build = function(self, gx, gy)
            Windmill:new(gx, gy)
        end,
        special_requirements = function(self, gx, gy)
            return true
        end
    }
}

local BuildController = class('BuildController')
function BuildController:initialize()
    self.width = 0
    self.height = 0
    self.active = false
    self.can_afford = true
    self.start = true
    self.gx = 0
    self.gy = 0
    self.FX = 0
    self.FY = 0
    self.previous_gx = 0
    self.previous_gy = 0
    self.can_build = false
    self.previous_can_build = false
    self.building = "castle"
    self.batch = love.graphics.newSpriteBatch(image)
    self.quads = {}
    self.quads[1] = love.graphics.newQuad(0, 0, 30, 16, image:getWidth(), image:getHeight())
    self.quads[2] = love.graphics.newQuad(30, 0, 30, 16, image:getWidth(), image:getHeight())
    self.quads[3] = love.graphics.newQuad(60, 0, 30, 16, image:getWidth(), image:getHeight())
    self.quads[4] = love.graphics.newQuad(90, 0, 30, 16, image:getWidth(), image:getHeight())
end
function BuildController:set(type)
    self.building = type
    self.width, self.height = building[type].w, building[type].h
    self.batch:clear()
    local type
    for x = 0, self.width - 1 do
        for y = 0, self.height - 1 do
            type = 2
            self.batch:add(self.quads[type], (x - y) * tile_width * 0.5, (x + y) * tile_height * 0.5, 0, 1.06666, 1)
        end
    end
    self.batch:flush()
    self.active = true
end
function BuildController:update()
    if self.active then
        local MX, MY = love.mouse.getPosition()
        local type = 1
        MX = (MX - width / 2) / scale_x + view_xview - 16
        MY = (MY - height / 2) / scale_x + view_yview - 8
        local LX = math.round(ScreenToIsoX(MX, MY))
        local LY = math.round(ScreenToIsoY(MX, MY))
        self.gx, self.gy = LX, LY
        self.FX = IsoToScreenX(LX, LY) - view_xview - ((IsoToScreenX(LX, LY)) - view_xview) * (1 - scale_x)
        self.FY = IsoToScreenY(LX, LY) - view_yview - ((IsoToScreenY(LX, LY)) - view_yview) * (1 - scale_x)
        -- No point to flush the batch everytime
        if self.last_building ~= self.building or self.previous_gx ~= self.gx or self.previous_gx ~= self.gy then
            self.can_build = true
            if building[self.building].override_requirements then
                building[self.building]:override_requirements(self)
            else
                for xx = 0, self.width - 1 do
                    for yy = 0, self.height - 1 do
                        local x = (xx + self.gx) % (chunk_width)
                        local y = (yy + self.gy) % (chunk_width)
                        local cx = math.floor((xx + self.gx) / chunk_width)
                        local cy = math.floor((yy + self.gy) / chunk_width)
                        if importantObjectAt(cx, cy, x, y) then
                            self.can_build = false
                        end
                    end
                end
                if not building[self.building]:special_requirements(self.gx, self.gy) then
                    self.can_build = false
                end
                self.batch:clear()
                for xx = 0, self.width - 1 do
                    for yy = 0, self.height - 1 do
                        local x = (xx + self.gx) % (chunk_width)
                        local y = (yy + self.gy) % (chunk_width)
                        local cx = math.floor((xx + self.gx) / chunk_width)
                        local cy = math.floor((yy + self.gy) / chunk_width)
                        if not importantObjectAt(cx, cy, x, y) then
                            if self.can_build then
                                type = 2
                            else
                                type = 3
                            end
                        else
                            type = 1
                        end
                        self.batch:add(self.quads[type], (xx - yy) * tile_width * 0.5, (xx + yy) * tile_height * 0.5, 0,
                            1, 1)
                    end
                end
                self.batch:flush()
                self.previous_gx = self.gx
                self.previous_gy = self.gy
                self.previous_can_build = self.can_build
                self.last_building = self.building
            end
        end
    end
end
function BuildController:build(gx, gy)
    if self.active and self.can_build and self.gx > 0 and self.gx < 2048 and self.gy > 0 and self.gy < 2048 then
        self.can_afford = true
        if not self.start then
            for resource, amount in pairs(building[self.building].cost) do
                if _G.resources[resource] < amount then
                    self.can_afford = false
                    print("Cannot afford building! Not enough " .. resource .. "!")
                    break
                end
            end
            if self.can_afford then
                for resource, amount in pairs(building[self.building].cost) do
                    _G.stockpile:take(resource, amount)
                end
                for xx = 0, building[self.building].w do
                    for yy = 0, building[self.building].h do
                        removeObjectFromClassAtGlobal(gx + xx, gy + yy, "Shrub")
                    end
                end
                building[self.building]:build(gx, gy)
                self.active = false
                return
            end
        else
            if self.building == 'castle' then
                building[self.building]:build(gx, gy)
                self:set('stockpile')
            elseif self.building == 'stockpile' then
                building[self.building]:build(gx, gy)
                self:set('granary')
                _G.stockpile:store('stone')
                _G.stockpile:store('stone')
                _G.stockpile:store('stone')
                _G.stockpile:store('stone')
                _G.stockpile:store('stone')
                _G.stockpile:store('stone')
                _G.stockpile:store('stone')
                _G.stockpile:store('stone')
                _G.stockpile:store('stone')
                _G.stockpile:store('stone')
                _G.stockpile:store('stone')
                _G.stockpile:store('stone')
                _G.stockpile:store('stone')
                _G.stockpile:store('stone')
                _G.stockpile:store('stone')
                _G.stockpile:store('stone')
                _G.stockpile:store('stone')
                _G.stockpile:store('stone')
                _G.stockpile:store('stone')
                _G.stockpile:store('stone')
                _G.stockpile:store('wood')
                _G.stockpile:store('wood')
                _G.stockpile:store('wood')
                _G.stockpile:store('wood')
                _G.stockpile:store('wood')
                _G.stockpile:store('wood')
                _G.stockpile:store('wood')
                _G.stockpile:store('wood')
                _G.stockpile:store('wood')
                _G.stockpile:store('wood')
                _G.stockpile:store('wood')
                _G.stockpile:store('wood')
                _G.stockpile:store('wood')
                _G.stockpile:store('wood')
                _G.stockpile:store('wood')
                _G.stockpile:store('wood')
                _G.stockpile:store('wood')
                _G.stockpile:store('wood')
                _G.stockpile:store('wood')
                _G.stockpile:store('wood')
                _G.stockpile:store('wood')
                _G.stockpile:store('wood')
                _G.stockpile:store('wood')
                _G.stockpile:store('wood')
                _G.stockpile:store('wood')
                _G.stockpile:store('wood')
                _G.stockpile:store('wood')
                _G.stockpile:store('wood')
                _G.stockpile:store('wood')
                _G.stockpile:store('wood')
                _G.stockpile:store('wood')
                _G.stockpile:store('wood')
                _G.stockpile:store('wood')
                _G.stockpile:store('wood')
                _G.stockpile:store('wood')
                _G.stockpile:store('wood')
                _G.stockpile:store('wood')
                _G.stockpile:store('wood')
                _G.stockpile:store('wood')
                _G.stockpile:store('wood')
                _G.stockpile:store('wood')
                _G.stockpile:store('wood')
                _G.stockpile:store('wood')
                _G.stockpile:store('wood')
                _G.stockpile:store('wood')
                _G.stockpile:store('wood')
                _G.stockpile:store('wood')
                _G.stockpile:store('wood')
                _G.stockpile:store('wood')
                _G.stockpile:store('wood')
            elseif self.building == "granary" then
                building[self.building]:build(gx, gy)
                _G.foodpile:store('bread')
                _G.foodpile:store('bread')
                _G.foodpile:store('bread')
                _G.foodpile:store('bread')
                _G.foodpile:store('bread')
                _G.foodpile:store('bread')
                _G.foodpile:store('bread')
                _G.foodpile:store('bread')
                _G.foodpile:store('bread')
                _G.foodpile:store('bread')
                _G.foodpile:store('bread')
                _G.foodpile:store('bread')
                _G.foodpile:store('bread')
                _G.foodpile:store('bread')
                _G.foodpile:store('bread')
                _G.foodpile:store('bread')
                _G.foodpile:store('bread')
                _G.foodpile:store('bread')
                _G.foodpile:store('bread')
                _G.foodpile:store('bread')
                _G.foodpile:store('bread')
                _G.foodpile:store('bread')
                _G.foodpile:store('bread')
                _G.foodpile:store('bread')
                _G.foodpile:store('bread')
                _G.foodpile:store('bread')
                _G.foodpile:store('bread')
                self.active = false
                self.start = false
            end
        end
    end
end
function BuildController:draw()
    if self.active then
        love.graphics.setColor(1, 1, 1, 0.5)
        love.graphics.draw(self.batch, self.FX, self.FY, nil, scale_x)
        love.graphics.draw(object_image, building[self.building].quad,
            self.FX - building[self.building].offset_x * scale_x, self.FY - building[self.building].offset_y * scale_x,
            0, scale_x)
        love.graphics.setColor(1, 1, 1, 1)
    end
end

return BuildController:new()
