local _, _, _, _ = ...
local StoneGate = require("objects.Structures.StoneGate")
local StoneGateEast = _G.class("StoneGateEast", StoneGate)
StoneGateEast.static.WIDTH = 5
StoneGateEast.static.LENGTH = 5
StoneGateEast.static.HEIGHT = 17
StoneGateEast.static.DESTRUCTIBLE = true
function StoneGateEast:initialize(gx, gy)
    StoneGate.initialize(self, gx, gy, "east")
end

return StoneGateEast
