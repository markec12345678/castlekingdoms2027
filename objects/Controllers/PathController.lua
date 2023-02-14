local bitser = require("libraries.bitser")

local PathController = _G.class('PathController')
function PathController:initialize()
    self.paths = newAutotable(4)
end

function PathController:requestPath(startx, starty, endx, endy)
    _G.channel.request:push({
        sx = startx,
        sy = starty,
        ex = endx,
        ey = endy
    })
end

function PathController:update()
    local pathdata
    repeat
        pathdata = _G.channel.receive:pop()
        if pathdata then
            pathdata = bitser.loads(pathdata)
            if not pathdata.found then
                self.paths[pathdata.sx][pathdata.sy][pathdata.ex][pathdata.ey] = 1
            else
                self.paths[pathdata.sx][pathdata.sy][pathdata.ex][pathdata.ey] = pathdata.nodes
            end
        else
            break
        end
    until (not pathdata)
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
    end
    return false
end

return PathController:new()
