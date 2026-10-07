local error_handler = {}
error_handler.__index = error_handler

function error_handler.error(msg)
    game.log(msg, 2)
end

function error_handler.low_memory()
    game.log("Running out of memory. Attempting to free up.", 1)
    -- Clean up memory here.
end

return error_handler