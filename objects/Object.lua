local Object = class('Object')
        function Object:initialize(cx,cy,i,o,x,y,type)
            self.cx = cx
            self.cy = cy
            self.i = i
            self.o = o
            self.x = x
            self.y = y
            self.type = type
            self.qid = 0
            end
return Object