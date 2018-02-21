
local object, object_image = ...

local tile_quads = require('objects.objects_quads')
local image = love.graphics.newImage( "assets/tiles/info_tiles_strip.png" )
local Castle = require('objects.Structures.Castle')
local Stockpile = require('objects.Structures.Stockpile')
local Granary = require('objects.Structures.Granary')

local building = {
    ["castle"] = {
        quad = tile_quads[767],
        offset_y = 93,
        offset_x = 6*15+6,
        w = 7, h = 7,
        build = function(cx,cy,x,y) 
            object[cx][cy][x][y] = 
			Castle:new(cx,cy,x,y, 
			IsoX + (x - y) * tile_width  * 0.5 - 0,
			IsoY + (x + y) * tile_height * 0.5 - 0)
        end,
    },
    ["stockpile"] = {
        quad = tile_quads[735],
        offset_x = 64,
        offset_y = 12,
        w = 5, h = 5,
        build = function(cx,cy,x,y)
            object[cx][cy][x][y] = 
			Stockpile:new(cx,cy,x,y, 
			IsoX + (x - y) * tile_width  * 0.5,
			IsoY + (x + y) * tile_height * 0.5)
        end,
    },
    ["granary"] = {
        quad = tile_quads[723],
        offset_x = 3*15+3,
        offset_y = 62+16,
        w = 4, h = 4,
        build = function(cx,cy,x,y)
            object[cx][cy][x][y] = 
			Granary:new(cx,cy,x,y, 
			IsoX + (x - y) * tile_width  * 0.5,
			IsoY + (x + y) * tile_height * 0.5)
        end,
    }
}

local BuildController = class('BuildController')
			function BuildController:initialize()
                self.width = 0
                self.height = 0
                self.active = false
                self.gx = 0
                self.gy = 0
                self.FX = 0
                self.FY = 0
                self.can_build = false
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
                        if object[cx][cy][x][y] ~= nil then self.can_build = false end
                    end
                end
               
                self.batch:clear()
                for xx = 0, self.width-1 do
                    for yy = 0, self.height-1 do   
                        local x = (xx+LX) % (chunk_width)
                        local y = (yy+LY) % (chunk_width)
                        local cx = math.floor((xx+LX)/chunk_width)
                        local cy = math.floor((yy+LY)/chunk_width)
                        if object[cx][cy][x][y] == nil then 
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
            end
            function BuildController:build(cx,cy,x,y)
                if self.active and self.can_build and cx >= 0 and cy >= 0 and cx < 32 and cy < 32 then
                    building[self.building].build(cx,cy,x,y)
                    self.active = false
                end
            end
            function BuildController:draw()       
                if self.active then     
                    love.graphics.setColor( 255, 255, 255, 127 )
                    love.graphics.draw(self.batch, self.FX, self.FY, nil, scale_x)
                    love.graphics.draw(object_image,building[self.building].quad,self.FX-building[self.building].offset_x*scale_x,self.FY-building[self.building].offset_y*scale_x,0,scale_x)
                    love.graphics.setColor( 255, 255, 255, 255 )
                end
            end

return BuildController