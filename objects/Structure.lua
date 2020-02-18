
local Object = require("objects.Object")
local Structure = class('Structure', Object)
function Structure:initialize(gx, gy, type)
    Object.initialize(self, gx, gy, type)
	addObjectAt(self.cx, self.cy, self.i, self.o, self)	
end
return Structure