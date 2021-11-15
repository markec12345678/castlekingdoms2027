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
function StockpileController:store(resource) -- TODO add amount
    if _G.not_full_stockpiles[resource] < 1 then
        for k, v in ipairs(self.list) do
            if v:store(resource) then
                break
            end
        end
    else
        self.resources[resource][#self.resources[resource]].id.parent:store(resource)
    end
end
function StockpileController:take(resource, amount)
    amount = amount or 1
    -- TODO: won't work with multiple amount - will return true even if 1 out of 3 resources are present
    for _ = 1, amount do
        if next(self.resources[resource]) == nil then
            return false
        else
            self.resources[resource][#self.resources[resource]].id.parent:take(resource,
                self.resources[resource][#self.resources[resource]])
        end
    end
    return true
end
return StockpileController:new()
