

local bitser = require("libraries.bitser")

local PathController = class('PathController')
			function PathController:initialize()                
                self.paths = newAutotable(4) 
			end
			function PathController:requestPath(startx, starty, endx, endy)
                _G.channel.request:push({sx = startx, sy = starty, ex = endx, ey = endy})
			end
            function PathController:update() 
                local table    
                repeat
                    table = _G.channel.receive:pop()
                    if table then 
                        table = bitser.loads(table)
                        if not table.found then
                            self.paths[table.sx][table.sy][table.ex][table.ey] = 1
                        else
                            self.paths[table.sx][table.sy][table.ex][table.ey] = table.nodes
                        end
                    else break end
                until (not table)
            end
            function PathController:getPath(startx, starty, endx, endy)
                if self.paths[startx][starty][endx][endy] then
                    if self.paths[startx][starty][endx][endy] == 1 then
                        return 2
                    elseif type(self.paths[startx][starty][endx][endy]) == 'table' then
                        local returnval = self.paths[startx][starty][endx][endy]
                        self.paths[startx][starty][endx][endy] = nil 
                        return returnval
                    end
                else return false  end
            end
return PathController