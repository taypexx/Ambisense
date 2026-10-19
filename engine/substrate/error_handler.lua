---@class error_handler
local error_handler = {}
error_handler.__index = error_handler

--- Registers and logs an error.
---@param msg string|nil A message to log.
---@param tag string|nil Title of the log message. Preferably in caps.
function error_handler.error(msg, tag)
    if not msg then msg = "An unknown error has occurred." end
    
    game.log(msg, 2, tag)
end

function error_handler.low_memory()
    game.log("Running out of memory. Attempting to free up.", 1)
    -- Clean up memory here.
end

love.lowmemory = error_handler.low_memory

return error_handler