local log = {
    default_tags = {
        [0] = "INFO",
        [1] = "WARNING",
        [2] = "ERROR"
    }
}
log.__index = log

--- Sends a log message to the console with a specific tag and level.
---@param msg string Message to log.
---@param level integer Level of the log message. 0 = info, 1 = warning, 2 = error.
---@param tag string Title of the log message. Preferably in caps.
log.__call = function(msg, level, tag)
    if not level then level = 0 end
    if not tag then tag = log.default_tags[level] end
    
    print(string.format("[%s] | %s", tag, msg))
end

return log