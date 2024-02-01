local bitser = require("libraries.bitser")
local lume = require("lume")

local PathController = _G.class('PathController')
function PathController:initialize()
    self.paths = newAutotable(4)
    self.onPathFoundCallbacks = {}
    self.rememberedPaths = {}
end

function PathController:requestPath(startx, starty, endx, endy)
    _G.channel.request:push({
        sx = startx,
        sy = starty,
        ex = endx,
        ey = endy
    })
end

function PathController:requestPathToMultipleGoals(startx, starty, endNodes)
    _G.channel.request:push({
        sx = startx,
        sy = starty,
        endNodes = endNodes
    })
end

-- Do not use unless you know what you're doing
function PathController:requestPathToMultipleGoalsWithWalkableTargetArea(centerx, centery, endNodes, walkableNodes,
                                                                         onPathFoundCallback)
    if not next(endNodes) then error("trying to pathfind to nothing") end
    local uuid = lume.uuid()
    _G.channel.request:push({
        sx = centerx,
        sy = centery,
        endNodes = endNodes,
        walkableNodes = walkableNodes,
        uuid = uuid
    })
    self.onPathFoundCallbacks[uuid] = onPathFoundCallback
end

local framesPassed = 0

function PathController:update()
    local pathdata
    framesPassed = framesPassed + 1
    if framesPassed > 200 then
        if #self.rememberedPaths > 1 then
            local pathToForget = table.remove(self.rememberedPaths)
            self.paths[pathToForget[1]][pathToForget[2]][pathToForget[3]][pathToForget[4]] = nil
        end
        framesPassed = 0
    end
    repeat
        pathdata = _G.channel.receive:pop()
        if pathdata then
            pathdata = bitser.loads(pathdata)
            if not pathdata.found then
                if pathdata.uuid then
                    self.onPathFoundCallbacks[pathdata.uuid](false)
                    self.onPathFoundCallbacks[pathdata.uuid] = nil
                else
                    self.paths[pathdata.sx][pathdata.sy][pathdata.ex][pathdata.ey] = 1
                end
            else
                if pathdata.uuid then
                    self.onPathFoundCallbacks[pathdata.uuid](pathdata.nodes)
                    self.onPathFoundCallbacks[pathdata.uuid] = nil
                else
                    self.paths[pathdata.sx][pathdata.sy][pathdata.ex][pathdata.ey] = pathdata.nodes
                end
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
            self.rememberedPaths[#self.rememberedPaths + 1] = { startx, starty, endx, endy }
            -- self.paths[startx][starty][endx][endy] = nil temporarily disabled
            return returnval
        end
    end
    return false
end

return PathController:new()
