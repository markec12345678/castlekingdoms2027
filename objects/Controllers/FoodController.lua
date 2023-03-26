local FoodController = _G.class('FoodController')
local FOOD = require("objects.Enums.Food")
local Events = require("objects.Enums.Events")

---Initializes the Food Controller by assigning variables.
function FoodController:initialize()
    self.list = {}
    self.food = {}

    for _, v in pairs(FOOD) do
        self.food[v] = {}
    end

    self.nodeList = {}
end

---Counts the amount of food consumed and returns that value.
---@return number foods returns the amount of food consumed.
function FoodController:foodsConsumed()
    local foods = 0
    for _, v in pairs(self.food) do
        if next(v) then foods = foods + 1 end
    end
    return foods
end

---Stores food inside the granary if it isn't full.
---@param food string name of the food.
function FoodController:store(food) -- TODO add amount
    if _G.state.notFullFoods[food] < 1 then
        for _, v in ipairs(self.list) do
            if v:store(food) then
                _G.bus.emit(Events.OnFoodStore, FOOD[food])
                return true
            end
        end
    else
        self.food[food][#self.food[food]].id.parent:store(food)
        _G.bus.emit(Events.OnFoodStore, FOOD[food])
        return true
    end
end

---Takes food from the foodpile.
---@param food? string Food type. If not provided, takes one at random.
---@param amount? number Amount of food taken. If not provided, takes only one food.
function FoodController:take(food, amount)
    local takenFood = 0
    if not food then
        for _ = 1, (amount or 1) do
            for foodType, foodPile in pairs(self.food) do
                if takenFood == amount then
                    return
                end
                if next(foodPile) ~= nil then
                    takenFood = takenFood + 1
                    foodPile[#foodPile].id.parent:take(foodType, foodPile[#foodPile])
                    _G.bus.emit(Events.OnFoodTake, FOOD[food])
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
    data.nodeList = self.nodeList
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
    local granaryList = {}
    for _, v in ipairs(self.list) do
        granaryList[#granaryList + 1] = _G.state:serializeObject(v)
    end
    data.granaryList = granaryList
    data.rawFood = food
    return data
end

function FoodController:deserialize(data)
    self.nodeList = data.nodeList
    for foodtype, foodlist in pairs(data.rawFood) do
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
    for _, v in ipairs(data.granaryList) do
        self.list[#self.list + 1] = _G.state:dereferenceObject(v)
    end
end

return FoodController:new()
