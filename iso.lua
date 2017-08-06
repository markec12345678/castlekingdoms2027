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
