local CompactArray = {}
CompactArray.__index = CompactArray
-- Create a new Compact Array
function CompactArray:new(cx, cy)
    return setmetatable({ data = {}, freeList = {}, cx = cx, cy = cy }, CompactArray)
end

-- Allocate a vertId for an object
function CompactArray:allocate(object)
    if type(object) == "number" then error("vertex compactor received a number instead of object") end
    if not object then error("vertex compactor called with nil object") end
    local pos
    if #self.freeList > 0 then
        pos = table.remove(self.freeList)
        self.data[pos] = object
    else
        pos = #self.data + 1
        self.data[pos] = object
    end
    _G.state.objectMesh[self.cx][self.cy]:setVertex(pos)
    return pos
end

-- Free a vertId
function CompactArray:free(vertId)
    if self.data[vertId] and self.data[vertId] ~= -1 then
        self.data[vertId] = -1
        _G.state.objectMesh[self.cx][self.cy]:setVertex(vertId)
        table.insert(self.freeList, vertId)
    end
    if #self.freeList >= 500 then
        self:compact()
    end
end

local function onChanged(object, old, new)
    object:onVertChange(old, new)
end

-- Compact the array to remove gaps
function CompactArray:compact()
    local x = 1          -- beginning of the list
    local y = #self.data -- last item in the list
    local a = self.data
    while x < y do
        if a[x] == -1 then
            -- move y backwards, looking for the first non-empty element
            while y > x and a[y] == -1 do
                y = y - 1
            end
            -- swap a[x] and a[y]
            if a[x] ~= a[y] then
                a[x], a[y] = a[y], a[x]
                onChanged(a[x], y, x)
            end
        end
        x = x + 1
    end
    -- remove trailing -1 elements to trigger the GC
    for i = #self.data, 1, -1 do
        if self.data[i] == -1 then
            self.data[i] = nil
        else
            break
        end
    end
    self.freeList = {}
end

return CompactArray
