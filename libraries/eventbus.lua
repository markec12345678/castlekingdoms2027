local bus = {}

local handlers = {}

--- Subscribe to an event.
--
-- Register an event handler.
-- This function is idempotent, so calling it multiple times won't create more than one handler.
---@param event event the event name
---@param handler function the event handler
bus.on = function(event, handler)
    if type(event) ~= "number" then error('Invalid event name, did you call the function with : instead of . ?') end
    if type(handler) ~= 'function' then error('Invalid event handler') end
    if not handlers[event] then handlers[event] = {} end
    handlers[event][handler] = handler
end

--- Unsubscribe from an event.
--
-- Remove a registered event handler.
---@param event event the event name
---@param handler function the event handler to unsubscribe
---@return boolean whether the handler was successfully removed
bus.off = function(event, handler)
    if type(event) ~= "number" then error('Invalid event name, did you call the function with : instead of . ?') end
    local h = handlers[event]
    if not h then return false end
    if h[handler] then
        h[handler] = nil
        return true
    end

    return false
end

--- Generate event.
--
-- Invokes all event handlers in the order they were registered.
-- Passes all arguments to the handler.
--
---@param event event the event name
---@param ... any the remaining parameters are passed on to the handler
bus.emit = function(event, ...)
    if type(event) ~= "number" then error('Invalid event name, did you call the function with : instead of . ?') end
    local eventHandlers = handlers[event]
    if not eventHandlers then return end
    for _, handler in pairs(eventHandlers) do
        handler(...)
    end
end

return bus
