local Structure = require("objects.Structure")

local DestructionController = _G.class("Destruction Controller")
function DestructionController:initialize()
    self.active = false
    self.destructionCursorImg = love.image.newImageData("assets/ui/cursor_destroy.png")
    self.destructionCursor = love.mouse.newCursor(self.destructionCursorImg, 1, 1)
    self.cursorImg = love.image.newImageData("assets/ui/cursor.png")
    self.cursor = love.mouse.newCursor(self.cursorImg, 2, 2)
end

function DestructionController:toggle()
    self.active = not self.active
    if (self.active) then
        love.mouse.setCursor(self.destructionCursor);
        _G.BuildController.active = false
        if _G.BuildController.onBuildCallback then
            _G.BuildController.onBuildCallback()
            _G.BuildController.onBuildCallback = nil
        end
    else
        love.mouse.setCursor(self.cursor)
    end
    return self.active
end

function DestructionController:disable()
    self.active = false
    love.mouse.setCursor(self.cursor)
end

-- Handles destruction of the main Structure, its aliases and reverting the terrain biome and setting the building health to -1.
-- Everything else (e.G. refunding, destruction of sub-buildings and respawning of resources (Iron, Stone))
-- must be handled by the Strcutures destroy() function.
function DestructionController:mousereleased(button, mx, my)
    if self.active and button == 1 then
        local gx, gy = _G.getTerrainTileOnMouse(mx, my)
        local structure = _G.objectFromSubclassAtGlobal(gx, gy, Structure)
        if structure then
            -- Get the base Structure
            structure = structure.parent or structure

            if (structure.health) then
                structure.health = -1
            end

            -- check if structure is destructible
            if structure.class.DESTRUCTIBLE == true then
                -- Destroy all the Aliases of a Structure
                for x = 0, structure.class.WIDTH - 1 do
                    for y = 0, structure.class.HEIGHT - 1 do
                        local targets = _G.allObjectsFromSubclassAtGlobal(structure.gx + x, structure.gy + y, Structure)
                        for _, target in ipairs(targets) do
                            if target == structure or target.parent == structure then
                                target:destroy()
                                Structure.destroy(target)
                            end
                        end
                    end
                end

                _G.playSfx(structure, _G.fx["buildingwreck_01"])

                -- Set the Terrain under the Structure to scarce grass and remove shadows
                for xx = -1, 3 do
                    for yy = -1, 3 do
                        _G.terrainSetTileAt(structure.gx + xx, structure.gy + yy, _G.terrainBiome.scarceGrass, nil, true)
                        local cx, cy, x, y = _G.getLocalCoordinatesFromGlobal(structure.gx + xx, structure.gy + yy)
                        _G.scheduleTerrainUpdate(cx, cy, x, y)
                        _G.buildingheightmap[cx][cy][x][y] = 0
                        _G.shadowmap[cx][cy][x][y] = 0
                    end
                end
            end
        end
    end
end

return DestructionController
