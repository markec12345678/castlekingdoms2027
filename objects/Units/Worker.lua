local Unit = require("objects.Units.Unit")
local Peasant = require("objects.Units.Peasant")

local Worker = _G.class("Worker", Unit)
function Worker.initialize(target, gx, gy, type)
    Unit.initialize(target, gx, gy, type)
end

function Worker:quitJob()
    -- Delete the current Worker
    _G.freeVertexFromTile(self.cx, self.cy, self.previousVertId)
    self.animation = nil
    _G.freeVertexFromTile(self.cx, self.cy, self.vertId)
    _G.removeObjectAt(self.cx, self.cy, self.i, self.o, self)
    -- Spawn a new Peasant and skip bow animation
    local peasant = Peasant:new(self.gx, self.gy, true)
    peasant.pathState = "Waiting for path"
    if _G.campfire.peasants >= _G.campfire.maxPeasants then
        peasant.state = "Leaving town"
        peasant:requestPath(_G.spawnPointX, _G.spawnPointY)
        _G.state.population = _G.state.population - 1
    else
        peasant.state = "Going to campfire"
    end
    local actionBar = require("states.ui.ActionBar")
    actionBar:updatePopulationCount()
    self.toBeDeleted = true
end

return Worker
