local default_tags = {
    [0] = "INFO",
    [1] = "WARNING",
    [2] = "ERROR"
}

--- Sends a log message to the console with a specific tag and level.
---@param msg string Message to log.
---@param level integer|nil Level of the log message. 0 = info, 1 = warning, 2 = error.
---@param tag string|nil Title of the log message. Preferably in caps.
return function(msg, level, tag)
    if not msg then return end
    if not level then level = 0 end
    if not tag then tag = default_tags[level] end
    
    local msg = string.format("%s | [%s] | %s", os.date(), tag, msg)
    game.appdata.client_log:write(msg)
    print(msg)
end