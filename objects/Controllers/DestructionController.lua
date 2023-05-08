local Structure = require("objects.Structure")
local ActionBar = require("states.ui.ActionBar")
local ActionBar = require("states.ui.ActionBar")

local DestructionController = _G.class("Destruction Controller")

---Initializes the Destruction Controller by assigning variables. Sets it to not active by default.
function DestructionController:initialize()
    self.active = false
    self.destructionCursorImg = love.image.newImageData("assets/ui/cursor_destroy.png")
    self.destructionCursor = love.mouse.newCursor(self.destructionCursorImg, 1, 1)
    self.cursorImg = love.image.newImageData("assets/ui/cursor.png")
    self.cursor = love.mouse.newCursor(self.cursorImg, 2, 2)
    self.prevGX = 0
    self.prevGY = 0
end

---Toggles between deleting and not deleting.
---@return boolean self.active whether destruction mode is active or not.
function DestructionController:toggle()
    self.active = not self.active
    if (self.active) then
        love.mouse.setCursor(self.destructionCursor);
        _G.BuildController:disable()
        if _G.BuildController.onBuildCallback then
            _G.BuildController.onBuildCallback()
            _G.BuildController.onBuildCallback = nil
        end
    else
        love.mouse.setCursor(self.cursor)
    end
    return self.active
end

---Checks if the player is currently trying to delete something, then tries to delete the object.
function DestructionController:update()
    if _G.DestructionController.active and love.mouse.isDown(1) then
        local mx, my = love.mouse.getPosition()
        local gx, gy = _G.getTerrainTileOnMouse(mx, my)
        if self.prevGX ~= gx and self.prevGY ~= gy then
            _G.DestructionController:destroyAtLocation(gx, gy)
            self.prevGX, self.prevGY = gx, gy
        end
    else
        self.prevGX, self.prevGY = 0, 0
    end
end

---Disables the Destruction Controller.
function DestructionController:disable()
    self.active = false
    love.mouse.setCursor(self.cursor)
end

---Destroy an object at a given location.
---@param gx number X coordinate of the structure.
---@param gy number Y coordinate of the structure.
---@param force boolean ignores the static class variable DESTRUCTIBLE.
---@param targetAlias boolean doesn't destroy the parent structure, but only the alias at that specific spot.
function DestructionController:destroyAtLocation(gx, gy, force, targetAlias)
    local structure = _G.objectFromSubclassAtGlobal(gx, gy, Structure)
    if structure then
        -- Get the base Structure
        if not targetAlias then
            structure = structure.parent or structure
        end

        if (structure.health) then
            structure.health = -1
        end

        -- check if structure is destructible
        if structure.class.DESTRUCTIBLE or force then
            if targetAlias then
                local targets = _G.allObjectsFromSubclassAtGlobal(structure.gx, structure.gy, Structure)
                for _, target in ipairs(targets) do
                    if target == structure or target.parent == structure then
                        target:destroy()
                    end
                end
                _G.state.Terrain:terrainSetTileAt(structure.gx, structure.gy, _G.terrainBiome.scarceGrass, nil, true)
                local cx, cy, x, y = _G.getLocalCoordinatesFromGlobal(structure.gx, structure.gy)
                _G.state.Terrain:scheduleTerrainUpdate(cx, cy, x, y)
                _G.state.map.buildingheightmap[cx][cy][x][y] = 0
                _G.state.map.shadowmap[cx][cy][x][y] = 0
            else
                -- Set the Terrain under the Structure to scarce grass and remove shadows
                for xx = 0, structure.class.WIDTH - 1 do
                    for yy = 0, structure.class.LENGTH - 1 do
                        _G.state.Terrain:terrainSetTileAt(structure.gx + xx, structure.gy + yy, _G.terrainBiome.scarceGrass, nil, true)
                        local cx, cy, x, y = _G.getLocalCoordinatesFromGlobal(structure.gx + xx, structure.gy + yy)
                        self:revertWalkability(structure.gx, structure.gy)
                        _G.state.map.buildingheightmap[cx][cy][x][y] = 0
                        _G.state.map.shadowmap[cx][cy][x][y] = 0
                    end
                end
                -- Destroy all the Aliases of a Structure
                for x = 0, structure.class.WIDTH - 1 do
                    for y = 0, structure.class.LENGTH - 1 do
                        local targets = _G.allObjectsFromSubclassAtGlobal(structure.gx + x, structure.gy + y, Structure)
                        for _, target in ipairs(targets) do
                            if target == structure or target.parent == structure then
                                local buildings = require("objects.buildings")
                                local building = buildings[target.class.name]
                                if building then
                                    local cost = buildings[target.class.name].cost
                                    if cost then
                                        for t, q in pairs(cost) do
                                            if t == "gold" then
                                                _G.state.gold = _G.state.gold + q / 2
                                                ActionBar:updateGoldCount()
                                            else
                                                for i = 1, q / 2 do
                                                    _G.stockpile:store(t, 1)
                                                end
                                            end
                                        end
                                    end
                                end
                                target:destroy()
                                _G.BuildingManager:remove(structure)
                            end
                        end
                    end
                end

                _G.playSfx(structure, _G.fx["buildingwreck_01"])
            end
        end
    end
end

-- reverts the terrain to walkable after destruction
---@param gx number X coordinate.
---@param gy number Y coordinate.
function DestructionController:revertWalkability(gx, gy)
    if not _G.state.Terrain:tileShouldBeCliff(gx, gy, true) then
        if _G.shouldTileBeWalkable(gx, gy) and _G.state.map:getWalkable(gx, gy) == 1 then
            _G.state.map:setWalkable(gx, gy, 0)
        end
    end
end

return DestructionController
