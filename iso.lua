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
    if love.keyboard.isDown("up")  then
        view_yview = view_yview-5;  
    end
    if love.keyboard.isDown("down")  then
        view_yview = view_yview+5;  
    end
    if love.keyboard.isDown("left")  then
        view_xview = view_xview -5;  
    end
    if love.keyboard.isDown("right")  then
        view_xview = view_xview +5;  
    end
    if love.keyboard.isDown("escape")  then
        love.event.quit();
    end
end

local function scale(y)
    if y > 0 and scale_x < 1 then 
        scale_x = scale_x + 0.1;
        scale_y = scale_y + 0.1;
    elseif y < 0 and scale_y > 0.3 then
        scale_x = scale_x - 0.1;
        scale_y = scale_y - 0.1;
    end
end

local tableOfFunctions = {update = update, scale = scale}
return tableOfFunctions