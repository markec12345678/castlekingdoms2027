local FoodController = class('FoodController')
function FoodController:initialize()
    self.list = {}
    self.food = {
        ["apples"] = {},
        ["bread"] = {},
        ["cheese"] = {}
    }

    self.node_list = {}
end
function FoodController:store(food) -- TODO add amount
    if _G.not_full_foods[food] < 1 then
        for k, v in ipairs(self.list) do
            if v:store(food) then
                break
            end
        end
    else
        self.food[food][#self.food[food]].id.parent:store(food)
    end
end
function FoodController:take(food, amount)
    local taken_food = 0
    if not food then
        for food_type, food_pile in pairs(self.food) do
            for _ = 1, (amount or 1) do
                if taken_food == amount then
                    return
                end
                if next(self.food[food_type]) == nil then
                    break
                else
                    taken_food = taken_food + 1
                    self.food[food_type][#self.food[food_type]].id.parent:take(food_type,
                        self.food[food_type][#self.food[food_type]])
                end
            end
        end
    else
        for i = 1, (amount or 1) do
            if next(self.food[food]) == nil then
                break
            else
                self.food[food][#self.food[food]].id.parent:take(food, self.food[food][#self.food[food]])
            end
        end
    end
end
return FoodController:new()
