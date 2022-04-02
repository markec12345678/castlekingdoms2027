local FoodController = _G.class('FoodController')
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
    if _G.state.not_full_foods[food] < 1 then
        for _, v in ipairs(self.list) do
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
                if next(food_pile) == nil then
                    break
                else
                    taken_food = taken_food + 1
                    food_pile[#food_pile].id.parent:take(food_type, food_pile[#food_pile])
                end
            end
        end
    else
        for _ = 1, (amount or 1) do
            if next(self.food[food]) == nil then
                break
            else
                self.food[food][#self.food[food]].id.parent:take(food, self.food[food][#self.food[food]])
            end
        end
    end
end
function FoodController:serialize()
    local data = {}
    data.node_list = self.node_list
    local food = {}
    for foodtype, foodlist in pairs(self.food) do
        food[foodtype] = {}
        for i, foodpile in ipairs(foodlist) do
            food[foodtype][i] = {}
            for sk, sv in pairs(foodpile) do
                if sk == "id" then
                    food[foodtype][i][sk] = _G.state:serializeObject(sv)
                else
                    food[foodtype][i][sk] = sv
                end
            end
        end
    end
    local granary_list = {}
    for _, v in ipairs(self.list) do
        granary_list[#granary_list + 1] = _G.state:serializeObject(v)
    end
    data.granary_list = granary_list
    data.raw_food = food
    return data
end
function FoodController:deserialize(data)
    self.node_list = data.node_list
    for foodtype, foodlist in pairs(data.raw_food) do
        self.food[foodtype] = {}
        for i, foodpile in ipairs(foodlist) do
            self.food[foodtype][i] = {}
            for sk, sv in pairs(foodpile) do
                if sk == "id" then
                    self.food[foodtype][i][sk] = _G.state:dereferenceObject(sv)
                else
                    self.food[foodtype][i][sk] = sv
                end
            end
        end
    end
    for _, v in ipairs(data.granary_list) do
        self.list[#self.list + 1] = _G.state:dereferenceObject(v)
    end
end
return FoodController:new()
