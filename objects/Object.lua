local Object = class('Object')
function Object:initialize(gx, gy, type)
    self.i = (gx) % (chunk_width)
    self.o = (gy) % (chunk_width)
    self.cx = math.floor(gx / chunk_width)
    self.cy = math.floor(gy / chunk_width)
    self.x = IsoX + (self.i - self.o) * tile_width * 0.5
    self.y = IsoY + (self.i + self.o) * tile_height * 0.5
    self.gx = gx
    self.gy = gy
    self.type = type
    self.qid = 0
    self.to_be_deleted = false
end
function Object:is_visible_on_screen()
    if not (self.x + (self.cx - self.cy) * chunk_width * tile_width * 0.5 < TopLeftX or self.x + (self.cx - self.cy) *
        chunk_width * tile_width * 0.5 > BottomRightX or self.y + (self.cx + self.cy) * chunk_height * tile_height * 0.5 <
        TopLeftY or self.y + (self.cx + self.cy) * chunk_height * tile_height * 0.5 > BottomRightY) then
        return true
    end
    return false
end
function Object:update()
end
return Object
