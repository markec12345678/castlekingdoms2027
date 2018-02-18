
--TODO
local image = love.graphics.newImage( "assets/tiles/info_tiles_strip.png" )
local img = love.graphics.newImage('assets/tiles/collection148.png')
local BuildController = class('BuildController')
			function BuildController:initialize()
                self.width = 0
                self.height = 0
                self.active = false
                self.batch = love.graphics.newSpriteBatch(image)
                self.quads = {}
                self.quads[1] = love.graphics.newQuad(0, 0,30, 16, 90,16)
            end
            function BuildController:set(w,h)
                self.width, self.height = w,h
                self.batch:clear()
                for x = 0, w-1 do
                    for y = 0, h-1 do
                        self.batch:add(
								self.quads[1], 
								 (x - y) * tile_width  * 0.5,
								 (x + y) * tile_height * 0.5,
								0,1.06666,1) 
                    end
                end
                self.batch:flush()
                self.active = true
            end
            function BuildController:draw()                
                mx, my = love.mouse.getPosition();  
                mx = (mx - width/2 + view_xview)/scale_x
                my = (my - height/2 + view_yview)/scale_x
                local LX = math.round(ScreenToIsoX(mx, my)); 
                local LY = math.round(ScreenToIsoY(mx, my)); 
                if self.active then     
                    love.graphics.draw(self.batch,IsoToScreenX(LX,LY)+width/2-(IsoToScreenX(LX,LY)*(1-scale_x)) - view_xview, 
                                                  IsoToScreenY(LX,LY)+height/2-(IsoToScreenY(LX,LY)*(1-scale_x)) - view_yview,
                                                  nil,scale_x);
                end
            end

return BuildController