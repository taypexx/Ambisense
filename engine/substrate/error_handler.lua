---@class error_handler
local error_handler = {}
error_handler.__index = error_handler

--- Registers and logs an error.
---@param msg string|nil A message to log.
function error_handler.error(msg)
    if not msg then msg = "An unknown error has occured." end
    
    game.log(msg, 2)
end

function error_handler.low_memory()
    game.log("Running out of memory. Attempting to free up.", 1)
    -- Clean up memory here.
end

love.lowmemory = error_handler.low_memory

return error_handler