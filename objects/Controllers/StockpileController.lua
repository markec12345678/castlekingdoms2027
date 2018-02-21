
local Object = require("objects.Object")

local StockpileController = class('StockpileController')
			function StockpileController:initialize()
                self.list = {}
                self.resources = {
                    ["wood"] = {},
                    ["stone"] = {},
                    ["wheat"] = {},
                    ["iron"] = {},
                    ["flour"] = {}
                }
                self.node_list = {}
			end
			function StockpileController:store(resource) --TODO add amount
                if _G.not_full_stockpiles < 1 then
                    print("CHECKING LIST!!!!!!!!!!!!!!!!!!!!!!")
                    for k,v in ipairs(self.list) do
                        if v:store(resource) then break end
                    end
                else
                    self.resources[resource][#self.resources[resource]].id.parent:store(resource)
                end
			end
            function StockpileController:take(resource,amount)
                if next(self.resources[resource]) == nil then
                    return false
                else
                    self.resources[resource][#self.resources[resource]].id.parent:take(resource,1,self.resources[resource][#self.resources[resource]])
                end            
            end
return StockpileController