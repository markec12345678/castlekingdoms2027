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
    if _G.campfire.peasants >= _G.campfire.maxPeasants then
        local peasant = Peasant:new(self.gx, self.gy, true)
        peasant.state = "Leaving town"
        peasant:requestPath(_G.spawnPointX, _G.spawnPointY)
        _G.state.population = _G.state.population - 1
    else
        local peasant = Peasant:new(self.gx, self.gy)
        peasant.state = "Going to campfire"
    end
    local actionBar = require("states.ui.ActionBar")
    actionBar:updatePopulationCount()
    self.toBeDeleted = true
end

return Worker
