require 'spec.love-mocks'
require 'libraries.busted.runner'
--package.path = package.path .. ';../?.lua'
local ob = require 'objects.objects'

local addObjectAt = ob.addObjectAt

describe("addObjectAt", function()
    it("creates a table at object index, if it doesn't exist already", function()
        assert.truthy(function()
                        local object = {{{{}}}}
                        object[1][1][1][1] = nil
                        addObjectAt(1,1,1,1,"object")
                        return type(object[1][1][1][1]) == "table"
                     end)
    end)
    it("returns the added object", function()
        assert.truthy(function()
                        local object = {{{{}}}}
                        object[1][1][1][1] = nil
                        return "object" == addObjectAt(1,1,1,1,"object")
                    end)
    end)
end)