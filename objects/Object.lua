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
return Object
