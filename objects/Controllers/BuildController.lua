
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
                local MX, MY = love.mouse.getPosition();  
                MX = (MX - 16 - width/2)/scale_x +view_xview
                MY = (MY - 8 - height/2)/scale_x +view_yview
                local LX = math.round(ScreenToIsoX(MX, MY))
                local LY = math.round(ScreenToIsoY(MX, MY))
                if self.active then     
                    love.graphics.draw(self.batch,
                                    IsoToScreenX(LX,LY) - view_xview - ((IsoToScreenX(LX,LY))-view_xview)*(1-scale_x), 
                                    IsoToScreenY(LX,LY) - view_yview - ((IsoToScreenY(LX,LY))-view_yview)*(1-scale_x),
                                    nil,
                                    scale_x
                                    )
                end
            end

return BuildController