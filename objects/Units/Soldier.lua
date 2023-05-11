local Unit = require("objects.Units.Unit")

local Soldier = _G.class("Soldier", Unit)
function Soldier:initialize(gx, gy, type)
    Unit.initialize(self, gx, gy, type)
    _G.selectedUnit = self
end

function Soldier:moveTo(gx, gy)

end

return Soldier
