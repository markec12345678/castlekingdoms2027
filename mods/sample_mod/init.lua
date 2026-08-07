-- Sample Mod - Entry Point
-- Demonstrates the Castle Kingdoms 2027 modding API.

local ModAPI = {}

function ModAPI.init()
    print("[Sample Mod] Initialized!")
    print("[Sample Mod] This mod adds custom content to demonstrate the API.")
end

-- Call init when loaded
ModAPI.init()

return ModAPI
