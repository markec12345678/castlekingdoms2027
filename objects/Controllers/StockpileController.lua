
local Object = require("objects.Object")

local StockpileController = class('StockpileController')
			function StockpileController:initialize()
                self.list = {}
                self.resources = {
                    ["wood"] = {},
                    ["stone"] = {},
                }
                self.node_list = {}
			end
			function StockpileController:store(resource)
                if next(self.resources[resource]) == nil then
                    for k,v in ipairs(self.list) do
                        if not v:store(resource) then break end
                    end
                else
                    self.resources[resource][1].id.parent:store(resource)
                end
			end
return StockpileController