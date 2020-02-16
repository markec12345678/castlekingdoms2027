
function ScreenToIsoX(globalX, globalY) 
    return (((globalX - IsoX) / (tile_width/2)) + ((globalY - IsoY) / (tile_height/2))) / 2;
end

function ScreenToIsoY(globalX, globalY) 
    return (((globalY - IsoY) / (tile_height/2)) - ((globalX - IsoX) / (tile_width/2))) / 2;
end


function IsoToScreenX(xx, yy) 
    return IsoX + ((xx - yy) * tile_width/2); end

function IsoToScreenY(xx, yy) 
    return IsoY + ((xx + yy) * tile_height/2); end  

function ogIsoToScreenX(xx, yy) 
    return  ((xx - yy) * tile_width/2); end

function ogIsoToScreenY(xx, yy) 
    return  ((xx + yy) * tile_height/2); end  

function math.round(n, deci) deci = 10^(deci or 0) return math.floor(n*deci+.5)/deci end

local function update()    
    next_time = next_time + min_dt;
    ---------------------------------------
    mx, my = love.mouse.getPosition();  
                mx = (mx - 16 - width/2)/scale_x +view_xview
                my = (my - 8 - height/2)/scale_x +view_yview
    LocalX = math.round(ScreenToIsoX(mx, my))
    LocalY = math.round(ScreenToIsoY(mx, my))
    CenterX = math.round(ScreenToIsoX(view_xview, view_yview)); 
    CenterY = math.round(ScreenToIsoY(view_xview, view_yview));
    ---------------------------------------
    _G.xchunk = math.floor(CenterX/(chunk_width));
    _G.ychunk = math.floor(CenterY/(chunk_width));
    -- TODO: Make into a function
    local MX, MY = 0, 0  
	MX = (MX - width/2)/scale_x +view_xview - 16
	MY = (MY - height/2)/scale_x +view_yview - 8
	local LocalX = math.round(ScreenToIsoX(MX, MY))
	local LocalY = math.round(ScreenToIsoY(MX, MY))
    top_left_chunk_x = math.floor(LocalX/chunk_width)
    top_left_chunk_y = math.floor(LocalY/chunk_width)
    MX, MY = love.graphics.getWidth(), love.graphics.getHeight() 
	MX = (MX - width/2)/scale_x +view_xview - 16
	MY = (MY - height/2)/scale_x +view_yview - 8
	LocalX = math.round(ScreenToIsoX(MX, MY))
	LocalY = math.round(ScreenToIsoY(MX, MY))
    bottom_right_chunk_x = math.floor(LocalX/chunk_width)
    bottom_right_chunk_y = math.floor(LocalY/chunk_width)
    -- Right up to here ^
    current_chunk_x = _G.xchunk;
    current_chunk_y = _G.ychunk;
    if love.keyboard.isDown("up")  then
        view_yview = view_yview - scroll_speed;  
    end
    if love.keyboard.isDown("down")  then
        view_yview = view_yview + scroll_speed;  
    end
    if love.keyboard.isDown("left")  then
        view_xview = view_xview - scroll_speed;  
    end
    if love.keyboard.isDown("right")  then
        view_xview = view_xview + scroll_speed;  
    end
    if love.keyboard.isDown("escape")  then
        love.event.quit();
    end
end

function manhattan_distance(x1,y1,x2,y2)
    local dx = math.abs(x1 - x2)
    local dy = math.abs(y1 - y2)
    return (dx + dy) 
end

local function scale(y)
    if y > 0 and scale_x < 2 then 
        scale_x = scale_x + 0.1;
        scale_y = scale_y + 0.1;
    elseif y < 0 and scale_y > 0.3 then
        scale_x = scale_x - 0.1;
        scale_y = scale_y - 0.1;
    end
end

local function draw()
        love.graphics.print(
                "\n GlobalX: " .. LocalX ..
                "\n GlobalY: " .. LocalY ..
                "\n LocalX: " .. ((LocalX)%chunk_width) ..
                "\n LocalY: " .. ((LocalY)%chunk_width) ..
                "\n Scale: " .. scale_x ..
                "\n Garbage (kB): " .. collectgarbage('count') ..
                "\n Center chunk: [" .. xchunk .. "][".. ychunk .."][" .. (status[xchunk][ychunk] or "N\\A") .."]"..
                "\n Top left chunk: [" .. top_left_chunk_x .. "][".. top_left_chunk_y .."][" .. (status[top_left_chunk_x][top_left_chunk_y] or "N\\A") .."]"..
                "\n Bottom right chunk: [" .. bottom_right_chunk_x .. "][".. bottom_right_chunk_y .."][" .. (status[bottom_right_chunk_x][bottom_right_chunk_y] or "N\\A") .."]"..
                "\n Current FPS: "..tostring(love.timer.getFPS())
                , 0, 0)
        limitfps()
end

local function getBuildingSelection()
    if building_selection == 374 or building_selection == 375 then
        return "Small wooden castle"
    elseif building_selection == 331 then
        return "Granary"
    elseif building_selection >= 398 and building_selection <= 401 then
        return "Wooden wall"
    end
end

local tableOfFunctions = {update = update, scale = scale, draw = draw, getBuildingSelection = getBuildingSelection}
return tableOfFunctions