
local object, object_image = ...

local tile_quads = require('objects.objects_quads')
local image = love.graphics.newImage( "assets/tiles/info_tiles_strip.png" )
local Castle = require('objects.Structures.Castle')
local Stockpile = require('objects.Structures.Stockpile')
local Granary = require('objects.Structures.Granary')
local Quarry = require('objects.Structures.Quarry')
local Mine = require('objects.Structures.Mine')

local building = {
    ["castle"] = {
        quad = tile_quads[767],
        offset_y = 93,
        offset_x = 6*15+6,
        w = 7, h = 7,
        cost = {
            ["wood"] = 50
        },
        build = function(self,cx,cy,x,y) 
           addObjectAt(cx, cy, x, y, 
			Castle:new(cx,cy,x,y, 
			IsoX + (x - y) * tile_width  * 0.5 - 0,
			IsoY + (x + y) * tile_height * 0.5 - 0))
        end,
        special_requirements = function(self,cx,cy,x,y) return true end,
    },
    ["stockpile"] = {
        quad = tile_quads[735],
        offset_x = 64,
        offset_y = 12,
        w = 5, h = 5,
        cost = {
            ["stone"] = 1
        },
        build = function(self,cx,cy,x,y)
           addObjectAt(cx, cy, x, y, 
			Stockpile:new(cx,cy,x,y, 
			IsoX + (x - y) * tile_width  * 0.5,
			IsoY + (x + y) * tile_height * 0.5))
        end,
        special_requirements = function(self,cx,cy,x,y)
            if not next(_G.stockpile.list) then return true end
            local gx = chunk_width*cx+x
            local gy = chunk_width*cy+y
            local i,o,cxx,cyy
            for w = gx-1, self.w+gx do
                for h = gy-1, self.h+gy do
                    i = (w) % (chunk_width)
                    o = (h) % (chunk_width)
                    cxx = math.floor(w/chunk_width)
                    cyy = math.floor(h/chunk_width)
                    if objectFromTypeAt(cxx, cyy ,i, o, "Stockpile") or objectFromTypeAt(cxx, cyy, i, o, "Stockpile_alias") then
                        return true
                    end
                end
            end
        end,
    },
    ["granary"] = {
        quad = tile_quads[723],
        offset_x = 3*15+3,
        offset_y = 62+16,
        w = 4, h = 4,
        cost = {
            ["wood"] = 10
        },
        build = function(self,cx,cy,x,y)
           addObjectAt(cx, cy, x, y, 
			Granary:new(cx,cy,x,y, 
			IsoX + (x - y) * tile_width  * 0.5,
			IsoY + (x + y) * tile_height * 0.5))
        end,
        special_requirements = function(self,cx,cy,x,y) return true end,
    },
    ["quarry"] = {
        quad = tile_quads[732],
        offset_x = 64+16,
        offset_y = 7*16+6,
        w = 6, h = 6,
        cost = {
            ["wood"] = 24
        },
        build = function(self,cx,cy,x,y)
           addObjectAt(cx, cy, x, y, 
			Quarry:new(cx,cy,x,y, 
			IsoX + (x - y) * tile_width  * 0.5,
			IsoY + (x + y) * tile_height * 0.5))
        end,
        special_requirements = function(self,cx,cy,x,y) return true end,
    },
    ["iron_mine"] = {
        quad = tile_quads[726],
        offset_x = 48,
        offset_y = 64-16-4,
        w = 4, h = 4,
        cost = {
            ["wood"] = 24,
            ["stone"] = 10,
        },
        build = function(self,cx,cy,x,y)
           addObjectAt(cx, cy, x, y,
			Mine:new(cx,cy,x,y, 
			IsoX + (x - y) * tile_width  * 0.5,
			IsoY + (x + y) * tile_height * 0.5))
        end,
        special_requirements = function(self,cx,cy,x,y) return true end,
    },
}

local BuildController = class('BuildController')
    function BuildController:initialize()
        self.width = 0
        self.height = 0
        self.active = false
        self.can_afford = true
        self.start = false
        self.gx = 0
        self.gy = 0
        self.FX = 0
        self.FY = 0
        self.previous_gx = 0
        self.previous_gy = 0
        self.can_build = false
        self.previous_can_build = false
        self.building = "stockpile"
        self.batch = love.graphics.newSpriteBatch(image)
        self.quads = {}
        self.quads[1] = love.graphics.newQuad(0, 0,30, 16, 90,16)
        self.quads[2] = love.graphics.newQuad(30, 0,30, 16, 90,16)
        self.quads[3] = love.graphics.newQuad(60, 0,30, 16, 90,16)
    end
    function BuildController:set(type)
        self.building = type
        self.width, self.height = building[type].w,building[type].h
        self.batch:clear()
        local type
        for x = 0, self.width-1 do
            for y = 0, self.height-1 do
                type = 2
                self.batch:add(
                        self.quads[type], 
                            (x - y) * tile_width  * 0.5,
                            (x + y) * tile_height * 0.5,
                        0,1.06666,1) 
            end
        end
        self.batch:flush()
        self.active = true
    end
    function BuildController:update()   
        if self.active then 
            local MX, MY = love.mouse.getPosition();  
            local type = 1
            MX = (MX - width/2)/scale_x +view_xview - 16
            MY = (MY - height/2)/scale_x +view_yview - 8
            local LX = math.round(ScreenToIsoX(MX, MY))
            local LY = math.round(ScreenToIsoY(MX, MY))
            self.gx, self.gy = LX,LY
            self.FX = IsoToScreenX(LX,LY) - view_xview - ((IsoToScreenX(LX,LY))-view_xview)*(1-scale_x)
            self.FY = IsoToScreenY(LX,LY) - view_yview - ((IsoToScreenY(LX,LY))-view_yview)*(1-scale_x) 
            self.can_build = true
            for xx = 0, self.width-1 do
                for yy = 0, self.height-1 do   
                    local x = (xx+LX) % (chunk_width)
                    local y = (yy+LY) % (chunk_width)
                    local cx = math.floor((xx+LX)/chunk_width)
                    local cy = math.floor((yy+LY)/chunk_width)
                    if objectAt(cx, cy, x, y) then self.can_build = false end
                end
            end
            do
                local i = (self.gx) % (chunk_width)
                local o = (self.gy) % (chunk_width)
                local cx = math.floor(self.gx/chunk_width)
                local cy = math.floor(self.gy/chunk_width)
                if not building[self.building]:special_requirements(cx,cy,i,o) then self.can_build = false end
            end
            self.batch:clear()
            for xx = 0, self.width-1 do
                for yy = 0, self.height-1 do   
                    local x = (xx+LX) % (chunk_width)
                    local y = (yy+LY) % (chunk_width)
                    local cx = math.floor((xx+LX)/chunk_width)
                    local cy = math.floor((yy+LY)/chunk_width)
                    if not objectAt(cx, cy, x, y) then 
                        if self.can_build then
                            type = 2
                        else
                            type = 3
                        end                
                    else type = 1 end
                    self.batch:add(
                            self.quads[type], 
                            (xx - yy) * tile_width  * 0.5,
                            (xx + yy) * tile_height * 0.5,
                            0,1,1) 
                    self.batch:add(
                        tile_quads[324]
                        ,(xx - yy) * tile_width  * 0.5,(xx + yy) * tile_height * 0.5,0)
                end
            end
            self.batch:flush()
            self.previous_gx = self.gx
            self.previous_gy = self.gy
            self.previous_can_build = self.can_build
        end
    end
    function BuildController:build(cx,cy,x,y)
        if self.active and self.can_build and cx >= 0 and cy >= 0 and cx < 32 and cy < 32 then
            self.can_afford = true
            if not self.start then
                for resource, amount in pairs(building[self.building].cost) do
                    if _G.resources[resource] < amount then 
                        self.can_afford = false 
                        print("Cannot afford building! Not enough "..resource.."!")
                        break                             
                    end
                end
                if self.can_afford then
                    for resource, amount in pairs(building[self.building].cost) do                            
                        _G.stockpile:take(resource,amount)
                    end                          
                    building[self.building]:build(cx,cy,x,y)
                    self.active = false
                    return
                end
            else        
                if self.building == 'castle' then               
                    building[self.building]:build(cx,cy,x,y)
                    self:set('stockpile')
                elseif self.building == 'stockpile' then                               
                    building[self.building]:build(cx,cy,x,y)
                    self.active = false
                    self.start = false
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
                end
            end
        end
    end
    function BuildController:draw()       
        if self.active then     
            love.graphics.setColor( 1, 1, 1, 0.5 )
            love.graphics.draw(self.batch, self.FX, self.FY, nil, scale_x)
            love.graphics.draw(object_image,building[self.building].quad,self.FX-building[self.building].offset_x*scale_x,self.FY-building[self.building].offset_y*scale_x,0,scale_x)
            love.graphics.setColor( 1, 1, 1, 1 )
        end
    end

return BuildController:new()