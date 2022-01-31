function ScreenToIsoX(globalX, globalY)
    return (((globalX - IsoX) / (tile_width / 2)) + ((globalY - IsoY) / (tile_height / 2))) / 2;
end

function ScreenToIsoY(globalX, globalY)
    return (((globalY - IsoY) / (tile_height / 2)) - ((globalX - IsoX) / (tile_width / 2))) / 2;
end

function IsoToScreenX(xx, yy)
    return IsoX + ((xx - yy) * tile_width / 2);
end

function IsoToScreenY(xx, yy)
    return IsoY + ((xx + yy) * tile_height / 2);
end

function ogIsoToScreenX(xx, yy)
    return ((xx - yy) * tile_width / 2);
end

function ogIsoToScreenY(xx, yy)
    return ((xx + yy) * tile_height / 2);
end

function _G.getLocalCoordinatesFromGlobal(gx, gy)
    local cx = math.floor(gx / _G.chunk_width)
    local cy = math.floor(gy / _G.chunk_width)
    local x = (gx) % (_G.chunk_width)
    local y = (gy) % (_G.chunk_width)
    return cx, cy, x, y
end

function _G.math.round(x, deci)
    -- deci = 10 ^ (deci or 0)
    -- return math.floor(n * deci + .5) / deci
    return x >= 0 and math.floor(x + 0.5) or math.ceil(x - 0.5)
end

local function update()
    next_time = next_time + _G.min_dt;
    ---------------------------------------
    mx, my = love.mouse.getPosition();
    mx = (mx - 16 - _G.ScreenWidth / 2) / scale_x + view_xview
    my = (my - 8 - _G.ScreenHeight / 2) / scale_x + view_yview
    LocalX = math.round(ScreenToIsoX(mx, my))
    LocalY = math.round(ScreenToIsoY(mx, my))
    CenterX = math.round(ScreenToIsoX(view_xview, view_yview))
    CenterY = math.round(ScreenToIsoY(view_xview, view_yview))

    -- Used for culling animations
    local TX, TY = 0, 0
    TX = (TX - _G.ScreenWidth / 2) / _G.scale_x + _G.view_xview - 16
    TY = (TY - _G.ScreenHeight / 2) / _G.scale_x + _G.view_yview - 8
    _G.TopLeftX = TX
    _G.TopLeftY = TY

    local BX, BY = love.graphics.getWidth(), love.graphics.getHeight() + 100
    BX = (BX - _G.ScreenWidth / 2) / _G.scale_x + _G.view_xview - 16
    BY = (BY - _G.ScreenHeight / 2) / _G.scale_x + _G.view_yview - 8
    _G.BottomRightX = BX
    _G.BottomRightY = BY

    ---------------------------------------
    _G.xchunk = math.floor(CenterX / (chunk_width));
    _G.ychunk = math.floor(CenterY / (chunk_width));
    -- TODO: Make into a function
    local MX, MY = 0, 0
    MX = (MX - _G.ScreenWidth / 2) / scale_x + view_xview - 16
    MY = (MY - _G.ScreenHeight / 2) / scale_x + view_yview - 8
    local LocalX = math.round(ScreenToIsoX(MX, MY))
    local LocalY = math.round(ScreenToIsoY(MX, MY))
    top_left_chunk_x = math.floor(LocalX / chunk_width)
    top_left_chunk_y = math.floor(LocalY / chunk_width)
    MX, MY = love.graphics.getWidth(), love.graphics.getHeight()
    MX = (MX - _G.ScreenWidth / 2) / scale_x + view_xview - 16
    MY = (MY - _G.ScreenHeight / 2) / scale_x + view_yview - 8
    LocalX = math.round(ScreenToIsoX(MX, MY))
    LocalY = math.round(ScreenToIsoY(MX, MY))
    bottom_right_chunk_x = math.ceil(LocalX / chunk_width)
    bottom_right_chunk_y = math.ceil(LocalY / chunk_width)
    -- Right up to here ^
    current_chunk_x = _G.xchunk;
    current_chunk_y = _G.ychunk;
    local final_scroll_speed = scroll_speed + ((1 - scale_x) * 20)
    if final_scroll_speed < 5 then
        final_scroll_speed = 5
    end
    if love.keyboard.isDown("up") then
        view_yview = view_yview - final_scroll_speed;
    end
    if love.keyboard.isDown("down") then
        view_yview = view_yview + final_scroll_speed;
    end
    if love.keyboard.isDown("left") then
        view_xview = view_xview - final_scroll_speed;
    end
    if love.keyboard.isDown("right") then
        view_xview = view_xview + final_scroll_speed;
    end
    if love.keyboard.isDown("escape") then
        love.event.quit();
    end
end

function manhattan_distance(x1, y1, x2, y2)
    local dx = math.abs(x1 - x2)
    local dy = math.abs(y1 - y2)
    return (dx + dy)
end

local function scale(y)
    if y > 0 and scale_x < 4 then
        scale_x = scale_x + 0.1;
        scale_y = scale_y + 0.1;
    elseif y < 0 and scale_y > 0.3 then
        scale_x = scale_x - 0.1;
        scale_y = scale_y - 0.1;
    end
end

local function draw()
    local gx, gy = LocalX, LocalY
    local prev_i = (gx - 1) % (chunk_width)
    local prev_o = (gy + 1) % (chunk_width)
    local prev_cx = math.floor((gx - 1) / chunk_width)
    local prev_cy = math.floor((gy + 1) / chunk_width)

    local prev_shadow, prev_height, prev_height_2, prev_tileheight = 0, 0, 0, 0
    if _G.terrain[prev_cx] and _G.terrain[prev_cx][prev_cy] then
        prev_height = _G.heightmap[prev_cx][prev_cy][prev_i][prev_o] or 0
        prev_height_2 = 75 * prev_height / (40 + prev_height)
        prev_shadow = _G.shadowmap[prev_cx][prev_cy][prev_i][prev_o] or 0
        prev_tileheight = _G.buildingheightmap[prev_cx][prev_cy][prev_i][prev_o] or 0
    end
    love.graphics.print("\n GlobalX: " .. LocalX .. "\n GlobalY: " .. LocalY .. "\n LocalX: " ..
                            ((LocalX) % chunk_width) .. "\n LocalY: " .. ((LocalY) % chunk_width) .. "\n Scale: " ..
                            scale_x .. "\n Shadow stuff:" .. prev_height .. " - " .. prev_height_2 .. " : " ..
                            prev_shadow .. " - " .. prev_tileheight .. "\n Garbage (kB): " .. collectgarbage('count') ..
                            "\n Center chunk: [" .. xchunk .. "][" .. ychunk .. "][" ..
                            (status[xchunk][ychunk] or "N\\A") .. "]" .. "\n Current FPS: " ..
                            tostring(love.timer.getFPS()) .. "\n Max FPS: " .. tostring(previous_frame_time) ..
                            "\n Wood: " .. tostring(_G.resources['wood']) .. "\n Stone: " ..
                            tostring(_G.resources['stone']) .. "\n Iron: " .. tostring(_G.resources['iron']), 0, 0)
    love.graphics.print(
        "[Q] - Apple orchard\n[W] - Stockpile\n[E] - Granary\n[T] - Quarry\n[Y] - Iron mine\n[I] - Wheat farm\n[Move keys] - Move map\n[Mouse scroll] - Zoom in/out\n[Escape] - Exit",
        0, _G.ScreenHeight - 130)
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

local tableOfFunctions = {
    update = update,
    scale = scale,
    draw = draw,
    getBuildingSelection = getBuildingSelection
}
return tableOfFunctions
