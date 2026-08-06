local _, _, _, _ = ...
local StoneGate = require("objects.Structures.StoneGate")
local StoneGateSouth = _G.class("StoneGateSouth", StoneGate)
StoneGateSouth.static.WIDTH = 5
StoneGateSouth.static.LENGTH = 5
StoneGateSouth.static.HEIGHT = 17
StoneGateSouth.static.DESTRUCTIBLE = true
function StoneGateSouth:initialize(gx, gy)
    StoneGate.initialize(self, gx, gy, "south")
end

return StoneGateSouth
