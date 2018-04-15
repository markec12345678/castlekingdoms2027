require 'busted.runner' ()

local tr = require('terrain')
local terrain_batch = tr.batch

--=======================================================================--
describe("update_terrain", function()
    it("creates a sprite batch at chunk_x, chunk_y if it doesn't exist already", function()
        terrain_batch[1][1] = nil
        update_terrain(1,1)
        assert.is_true(terrain_batch[1][1]~=nil)       
    end)
end)
--=======================================================================--
