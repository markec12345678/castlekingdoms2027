function newAutotable(dim)
    local MT = {};
    for i=1, dim do
        MT[i] = {__index = function(t, k)
            if i < dim then
                t[k] = setmetatable({}, MT[i+1])
                return t[k];
            end
        end}
    end

    return setmetatable({}, MT[1]);
end

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
    LocalX = math.round(ScreenToIsoX(mx-16+view_xview, my-8+view_yview)); LocalY = math.round(ScreenToIsoY(mx-16+view_xview, my-8+view_yview)); 
    CenterX = math.round(ScreenToIsoX(width/2-16+view_xview, height/2-8+view_yview)); CenterY = math.round(ScreenToIsoY(width/2-16+view_xview,height/2-8+view_yview));
    ---------------------------------------
    xchunk = math.floor(CenterX/(chunk_width));
    ychunk = math.floor(CenterY/(chunk_width));
    current_chunk_x = xchunk;
    current_chunk_y = ychunk;
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
                "\n LocalX: " .. LocalX ..
                "\n LocalY: " .. LocalY ..
                "\n viewx: " .. view_xview ..
                "\n viewy: " .. view_yview ..
                "\n Center chunk: [" .. xchunk .. "][".. ychunk .."]" ..
                "\n Current FPS: "..tostring(love.timer.getFPS( ))
                , 0, 0);

         -- LIMIT THE FPS TO 60
            local cur_time = love.timer.getTime();
            if next_time <= cur_time then
                next_time = cur_time;
                return;
            end
            love.timer.sleep(next_time - cur_time);
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