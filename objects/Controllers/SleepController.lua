local Structure = require("objects.Structure")

local SleepController = _G.class("Sleep Controller")

---Initializes the Sleep Controller by assigning variables. Sets it to not active by default.
function SleepController:initialize()
    self.active = false
    self.prevGX = 0
    self.prevGY = 0
    self.sleepingCursorImg = love.image.newImageData("assets/ui/sleepButton.png")
    self.sleepingCursor = love.mouse.newCursor(self.sleepingCursorImg, 1, 1)
    self.cursorImg = love.image.newImageData("assets/ui/cursor.png")
    self.cursor = love.mouse.newCursor(self.cursorImg, 2, 2)
end

---Toggles between active and sleeping.
---@return boolean self.active whether sleep mode is active or not.
function SleepController:toggle()
    self.active = not self.active
    if (self.active) then
        love.mouse.setCursor(self.sleepingCursor)
        _G.BuildController:disable()
    else
        love.mouse.setCursor(self.cursor)
    end
    return self.active
end

---Checks if the player is currently trying to delete something, then tries to delete the object.
function SleepController:update()
    if _G.SleepController.active and love.mouse.isDown(1) then
        local mx, my = love.mouse.getPosition()
        local gx, gy = _G.getTerrainTileOnMouse(mx, my)
        if self.prevGX ~= gx and self.prevGY ~= gy then
            _G.SleepController:sleepAtLocation(gx, gy)
            self.prevGX, self.prevGY = gx, gy
        end
    else
        self.prevGX, self.prevGY = 0, 0
    end
end

---Disables the Sleep Controller.
function SleepController:disable()
    self.active = false
    love.mouse.setCursor(self.cursor)
end

---Halts production to a building at a given location.
---@param gx number X coordinate of the structure.
---@param gy number Y coordinate of the structure.
function SleepController:sleepAtLocation(gx, gy)
    local structure = _G.objectFromSubclassAtGlobal(gx, gy, Structure)
    if structure then
        -- search for main object(filters aliases)
        while structure.parent ~= nil and structure.parent ~= "Structure" do
            structure = structure.parent
        end
        -- activates sleep
        if structure.leave then
            structure.sleeping = not structure.sleeping
            if structure.sleeping then
                structure:leave(structure.sleeping)
            end
        end
    end
end

return SleepController
