--[[------------------------------------------------
	-- Love Frames - A GUI library for LOVE --
	-- Copyright (c) 2012-2014 Kenny Shields --
--]]
------------------------------------------------
local path = ...

local loveframes = {}

-- special require for loveframes specific modules
loveframes.require = function(name)
    local ret = require(name)
    if type(ret) == "function" then
        return ret(loveframes)
    end
    return ret
end

-- loveframes specific modules
loveframes.require(path .. ".libraries.utils")
loveframes.require(path .. ".libraries.templates")
loveframes.require(path .. ".libraries.objects")
loveframes.require(path .. ".libraries.skins")

-- generic libraries
loveframes.class = require(path .. ".third-party.middleclass")
loveframes.utf8 = require(path .. ".third-party.utf8")

-- library info
loveframes.author = "Kenny Shields"
loveframes.version = "11.3"
loveframes.stage = "Alpha"

-- library configurations
loveframes.config = {}
loveframes.config["DIRECTORY"] = nil
loveframes.config["DEFAULTSKIN"] = "Default"
loveframes.config["ACTIVESKIN"] = "Default"
loveframes.config["INDEXSKINIMAGES"] = true
loveframes.config["DEBUG"] = false
loveframes.config["ENABLE_SYSTEM_CURSORS"] = false

-- misc library vars
loveframes.state = "none"
loveframes.drawcount = 0
loveframes.collisioncount = 0
loveframes.objectcount = 0
loveframes.hoverobject = false
loveframes.modalobject = false
loveframes.inputobject = false
loveframes.downobject = false
loveframes.resizeobject = false
loveframes.dragobject = false
loveframes.hover = false
loveframes.input_cursor_set = false
loveframes.prevcursor = nil
loveframes.slanted_big_green = love.graphics.newImageFont("assets/fonts/slanted_big_green.png", "019/2345678", -4)
loveframes.slanted_big_red = love.graphics.newImageFont("assets/fonts/slanted_big_red.png", "019/2345678", -4)
loveframes.slanted_medium_green = love.graphics.newImageFont("assets/fonts/slanted_medium_green.png", "01/23456789 ", -3)
loveframes.slanted_medium_red = love.graphics.newImageFont("assets/fonts/slanted_medium_red.png", "01/23456789 ", -3)
loveframes.slanted_small_green = love.graphics.newImageFont("assets/fonts/slanted_small_green.png", "01/23456789 ", -3)
loveframes.slanted_small_red = love.graphics.newImageFont("assets/fonts/slanted_small_red.png", "01/23456789 ", -3)
loveframes.slanted_xsmall_green = love.graphics.newImageFont("assets/fonts/slanted_xsmall_green.png", "01/23456789 ", -1)
loveframes.slanted_xsmall_red = love.graphics.newImageFont("assets/fonts/slanted_xsmall_red.png", "01/23456789 ", -1)
if love.graphics.getHeight() >= 1440 and love.graphics.getWidth() >= 2560 and love.graphics.getWidth() < 3840 then
    loveframes.basicfont = love.graphics.newFont("assets/fonts/Geologica-Regular.ttf", 18 + 2)
    loveframes.basicfontmedium = love.graphics.newFont("assets/fonts/Geologica-Regular.ttf", 20 + 2)
    loveframes.font_immortal = love.graphics.newFont("assets/fonts/IMMORTAL.ttf", 18)
    loveframes.font_immortal_large = love.graphics.newFont("assets/fonts/IMMORTAL.ttf", 24)
    loveframes.font_times_new_normal = love.graphics.newFont("assets/fonts/Geologica-Regular.ttf", 18)
    loveframes.font_times_new_medium = love.graphics.newFont("assets/fonts/Geologica-Regular.ttf", 21)
    loveframes.font_times_new_normal_large = love.graphics.newFont("assets/fonts/KellySlab-Regular.ttf", 24)
    loveframes.font_times_new_normal_large_48 = love.graphics.newFont("assets/fonts/KellySlab-Regular.ttf", 36)
    loveframes.basicfontsmall = love.graphics.newFont("assets/fonts/Geologica-Regular.ttf", 16 + 2)
    loveframes.font_vera_bold = love.graphics.newFont("assets/fonts/Geologica-Bold.ttf", 18)
    loveframes.font_vera_bold_medium = love.graphics.newFont("assets/fonts/Geologica-Bold.ttf", 22)
    loveframes.font_vera_bold_large = love.graphics.newFont("assets/fonts/Geologica-Bold.ttf", 24)
    loveframes.font_vera_italic = love.graphics.newFont("assets/fonts/VeraIt.ttf", 18)
    loveframes.font_vera_italic_large = love.graphics.newFont("assets/fonts/VeraIt.ttf", 24)
elseif love.graphics.getHeight() >= 1440 and love.graphics.getWidth() >= 3840 then
    loveframes.basicfont = love.graphics.newFont("assets/fonts/Geologica-Regular.ttf", 28 + 2)
    loveframes.basicfontmedium = love.graphics.newFont("assets/fonts/Geologica-Regular.ttf", 30 + 2)
    loveframes.font_immortal = love.graphics.newFont("assets/fonts/IMMORTAL.ttf", 28)
    loveframes.font_immortal_large = love.graphics.newFont("assets/fonts/IMMORTAL.ttf", 36)
    loveframes.font_times_new_normal = love.graphics.newFont("assets/fonts/Geologica-Regular.ttf", 28)
    loveframes.font_times_new_medium = love.graphics.newFont("assets/fonts/Geologica-Regular.ttf", 32)
    loveframes.font_times_new_normal_large = love.graphics.newFont("assets/fonts/KellySlab-Regular.ttf", 36)
    loveframes.font_times_new_normal_large_48 = love.graphics.newFont("assets/fonts/KellySlab-Regular.ttf", 48)
    loveframes.basicfontsmall = love.graphics.newFont("assets/fonts/Geologica-Regular.ttf", 26 + 2)
    loveframes.font_vera_bold = love.graphics.newFont("assets/fonts/Geologica-Bold.ttf", 28)
    loveframes.font_vera_bold_medium = love.graphics.newFont("assets/fonts/Geologica-Bold.ttf", 32)
    loveframes.font_vera_bold_large = love.graphics.newFont("assets/fonts/Geologica-Bold.ttf", 36)
    loveframes.font_vera_italic = love.graphics.newFont("assets/fonts/VeraIt.ttf", 28)
    loveframes.font_vera_italic_large = love.graphics.newFont("assets/fonts/VeraIt.ttf", 36)
elseif love.graphics.getHeight() <= 720 and love.graphics.getWidth() <= 1280 then
    loveframes.basicfont = love.graphics.newFont("assets/fonts/Geologica-Regular.ttf", 10 + 2)
    loveframes.basicfontmedium = love.graphics.newFont("assets/fonts/Geologica-Regular.ttf", 12 + 2)
    loveframes.font_immortal = love.graphics.newFont("assets/fonts/IMMORTAL.ttf", 10)
    loveframes.font_immortal_large = love.graphics.newFont("assets/fonts/IMMORTAL.ttf", 16)
    loveframes.font_times_new_normal = love.graphics.newFont("assets/fonts/Geologica-Regular.ttf", 10)
    loveframes.font_times_new_medium = love.graphics.newFont("assets/fonts/Geologica-Regular.ttf", 13)
    loveframes.font_times_new_normal_large = love.graphics.newFont("assets/fonts/KellySlab-Regular.ttf", 16)
    loveframes.font_times_new_normal_large_48 = love.graphics.newFont("assets/fonts/KellySlab-Regular.ttf", 22)
    loveframes.basicfontsmall = love.graphics.newFont("assets/fonts/Geologica-Regular.ttf", 8 + 2)
    loveframes.font_vera_bold = love.graphics.newFont("assets/fonts/Geologica-Bold.ttf", 10)
    loveframes.font_vera_bold_medium = love.graphics.newFont("assets/fonts/Geologica-Bold.ttf", 13)
    loveframes.font_vera_bold_large = love.graphics.newFont("assets/fonts/Geologica-Bold.ttf", 16)
    loveframes.font_vera_italic = love.graphics.newFont("assets/fonts/VeraIt.ttf", 10)
    loveframes.font_vera_italic_large = love.graphics.newFont("assets/fonts/VeraIt.ttf", 16)
else
    loveframes.basicfont = love.graphics.newFont("assets/fonts/Geologica-Regular.ttf", 12 + 2)
    loveframes.basicfontmedium = love.graphics.newFont("assets/fonts/Geologica-Regular.ttf", 14 + 2)
    loveframes.font_immortal = love.graphics.newFont("assets/fonts/IMMORTAL.ttf", 12)
    loveframes.font_immortal_large = love.graphics.newFont("assets/fonts/IMMORTAL.ttf", 18)
    loveframes.font_times_new_normal = love.graphics.newFont("assets/fonts/Geologica-Regular.ttf", 12)
    loveframes.font_times_new_medium = love.graphics.newFont("assets/fonts/Geologica-Regular.ttf", 15)
    loveframes.font_times_new_normal_large = love.graphics.newFont("assets/fonts/KellySlab-Regular.ttf", 18)
    loveframes.font_times_new_normal_large_48 = love.graphics.newFont("assets/fonts/KellySlab-Regular.ttf", 24)
    loveframes.basicfontsmall = love.graphics.newFont("assets/fonts/Geologica-Regular.ttf", 10 + 2)
    loveframes.font_vera_bold = love.graphics.newFont("assets/fonts/Geologica-Bold.ttf", 12)
    loveframes.font_vera_bold_medium = love.graphics.newFont("assets/fonts/Geologica-Bold.ttf", 14)
    loveframes.font_vera_bold_large = love.graphics.newFont("assets/fonts/Geologica-Bold.ttf", 18)
    loveframes.font_vera_italic = love.graphics.newFont("assets/fonts/VeraIt.ttf")
    loveframes.font_vera_italic_large = love.graphics.newFont("assets/fonts/VeraIt.ttf", 18)
end
loveframes.basicfontHeight = loveframes.basicfont:getHeight()
loveframes.basicfontsmallHeight = loveframes.basicfontsmall:getHeight()
loveframes.font_vera_boldHeight = loveframes.font_vera_bold:getHeight()
loveframes.collisions = {}
-- install directory of the library
local dir = loveframes.config["DIRECTORY"] or path

-- replace all "." with "/" in the directory setting
dir = loveframes.utf8.gsub(loveframes.utf8.gsub(dir, "\\", "/"), "(%a)%.(%a)", "%1/%2")
loveframes.config["DIRECTORY"] = dir

-- enable key repeat
love.keyboard.setKeyRepeat(true)

--[[---------------------------------------------------------
	- func: update(deltatime)
	- desc: updates all library objects
--]]
---------------------------------------------------------
function loveframes.update(dt)
    local base = loveframes.base
    local input_cursor_set = loveframes.input_cursor_set

    loveframes.collisioncount = 0
    loveframes.objectcount = 0
    loveframes.hover = false
    loveframes.hoverobject = false

    local downobject = loveframes.downobject
    if #loveframes.collisions > 0 then
        local top = loveframes.collisions[#loveframes.collisions]
        if not top.disablehover then
            if not downobject then
                loveframes.hoverobject = top
            else
                if downobject == top then
                    loveframes.hoverobject = top
                end
            end
        end
    end

    if loveframes.config["ENABLE_SYSTEM_CURSORS"] then
        local hoverobject = loveframes.hoverobject
        local arrow = love.mouse.getSystemCursor("arrow")
        local curcursor = love.mouse.getCursor()
        if hoverobject then
            local ibeam = love.mouse.getSystemCursor("ibeam")
            local mx, my = love.mouse.getPosition()
            if hoverobject.type == "textinput" and not loveframes.resizeobject then
                if curcursor ~= ibeam then
                    love.mouse.setCursor(ibeam)
                end
            elseif hoverobject.type == "frame" then
                if not hoverobject.dragging and hoverobject.canresize then
                    if loveframes.BoundingBox(hoverobject.x, mx, hoverobject.y, my, 5, 1, 5, 1) then
                        local sizenwse = love.mouse.getSystemCursor("sizenwse")
                        if curcursor ~= sizenwse then
                            love.mouse.setCursor(sizenwse)
                        end
                    elseif loveframes.BoundingBox(hoverobject.x + hoverobject.width - 5, mx,
                            hoverobject.y + hoverobject.height - 5, my, 5, 1, 5, 1) then
                        local sizenwse = love.mouse.getSystemCursor("sizenwse")
                        if curcursor ~= sizenwse then
                            love.mouse.setCursor(sizenwse)
                        end
                    elseif loveframes.BoundingBox(hoverobject.x + hoverobject.width - 5, mx, hoverobject.y, my, 5, 1, 5,
                            1) then
                        local sizenesw = love.mouse.getSystemCursor("sizenesw")
                        if curcursor ~= sizenesw then
                            love.mouse.setCursor(sizenesw)
                        end
                    elseif loveframes.BoundingBox(hoverobject.x, mx, hoverobject.y + hoverobject.height - 5, my, 5, 1,
                            5, 1) then
                        local sizenesw = love.mouse.getSystemCursor("sizenesw")
                        if curcursor ~= sizenesw then
                            love.mouse.setCursor(sizenesw)
                        end
                    elseif loveframes.BoundingBox(hoverobject.x + 5, mx, hoverobject.y, my, hoverobject.width - 10, 1,
                            2, 1) then
                        local sizens = love.mouse.getSystemCursor("sizens")
                        if curcursor ~= sizens then
                            love.mouse.setCursor(sizens)
                        end
                    elseif loveframes.BoundingBox(hoverobject.x + 5, mx, hoverobject.y + hoverobject.height - 2, my,
                            hoverobject.width - 10, 1, 2, 1) then
                        local sizens = love.mouse.getSystemCursor("sizens")
                        if curcursor ~= sizens then
                            love.mouse.setCursor(sizens)
                        end
                    elseif loveframes.BoundingBox(hoverobject.x, mx, hoverobject.y + 5, my, 2, 1,
                            hoverobject.height - 10, 1) then
                        local sizewe = love.mouse.getSystemCursor("sizewe")
                        if curcursor ~= sizewe then
                            love.mouse.setCursor(sizewe)
                        end
                    elseif loveframes.BoundingBox(hoverobject.x + hoverobject.width - 2, mx, hoverobject.y + 5, my, 2,
                            1, hoverobject.height - 10, 1) then
                        local sizewe = love.mouse.getSystemCursor("sizewe")
                        if curcursor ~= sizewe then
                            love.mouse.setCursor(sizewe)
                        end
                    else
                        if not loveframes.resizeobject then
                            local arrow = love.mouse.getSystemCursor("arrow")
                            if curcursor ~= arrow then
                                love.mouse.setCursor(arrow)
                            end
                        end
                    end
                end
            elseif hoverobject.type == "text" and hoverobject.linkcol and not loveframes.resizeobject then
                local hand = love.mouse.getSystemCursor("hand")
                if curcursor ~= hand then
                    love.mouse.setCursor(hand)
                end
            end
            if curcursor ~= arrow then
                if hoverobject.type ~= "textinput" and hoverobject.type ~= "frame" and not hoverobject.linkcol and
                    not loveframes.resizeobject then
                    love.mouse.setCursor(arrow)
                elseif hoverobject.type ~= "textinput" and curcursor == ibeam then
                    love.mouse.setCursor(arrow)
                end
            end
        else
            if curcursor ~= arrow and not loveframes.resizeobject then
                love.mouse.setCursor(arrow)
            end
        end
    end

    loveframes.collisions = {}
    base:update(dt)
end

--[[---------------------------------------------------------
	- func: draw()
	- desc: draws all library objects
--]]
---------------------------------------------------------
function loveframes.draw()
    local base = loveframes.base
    local r, g, b, a = love.graphics.getColor()
    local font = love.graphics.getFont()

    base:draw()

    loveframes.drawcount = 0

    if loveframes.config["DEBUG"] then
        loveframes.DebugDraw()
    end

    love.graphics.setColor(r, g, b, a)

    if font then
        love.graphics.setFont(font)
    end
end

--[[---------------------------------------------------------
	- func: mousepressed(x, y, button)
	- desc: called when the player presses a mouse button
--]]
---------------------------------------------------------
function loveframes.mousepressed(x, y, button)
    local base = loveframes.base
    local consumed = base:mousepressed(x, y, button)

    -- close open menus
    local bchildren = base.children
    local hoverobject = loveframes.hoverobject
    for k, v in ipairs(bchildren) do
        local otype = v.type
        local visible = v.visible
        if hoverobject then
            local htype = hoverobject.type
            if otype == "menu" and visible and htype ~= "menu" and htype ~= "menuoption" then
                v:SetVisible(false)
            end
        else
            if otype == "menu" and visible then
                v:SetVisible(false)
            end
        end
    end
    return consumed
end

--[[---------------------------------------------------------
	- func: mousereleased(x, y, button)
	- desc: called when the player releases a mouse button
--]]
---------------------------------------------------------
function loveframes.mousereleased(x, y, button)
    local base = loveframes.base
    local consumed = base:mousereleased(x, y, button)

    -- reset the hover object
    if button == 1 then
        loveframes.downobject = false
        loveframes.selectedobject = false
    end
    return consumed
end

--[[---------------------------------------------------------
	- func: wheelmoved(x, y)
	- desc: called when the player moves a mouse wheel
--]]
---------------------------------------------------------
function loveframes.wheelmoved(x, y)
    local base = loveframes.base
    base:wheelmoved(x, y)
end

--[[---------------------------------------------------------
	- func: keypressed(key, isrepeat)
	- desc: called when the player presses a key
--]]
---------------------------------------------------------
function loveframes.keypressed(key, isrepeat)
    local base = loveframes.base
    base:keypressed(key, isrepeat)
end

--[[---------------------------------------------------------
	- func: keyreleased(key)
	- desc: called when the player releases a key
--]]
---------------------------------------------------------
function loveframes.keyreleased(key)
    local base = loveframes.base
    base:keyreleased(key)
end

--[[---------------------------------------------------------
	- func: textinput(text)
	- desc: called when the user inputs text
--]]
---------------------------------------------------------
function loveframes.textinput(text)
    local base = loveframes.base
    base:textinput(text)
end

loveframes.LoadObjects(dir .. "/objects")
loveframes.LoadTemplates(dir .. "/templates")
loveframes.LoadSkins(dir .. "/skins")

-- create the base gui object
local base = loveframes.objects["base"]
loveframes.base = base:new()

return loveframes
