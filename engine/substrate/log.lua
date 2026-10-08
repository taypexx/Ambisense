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
    if not msg then msg = "nil" end
    level = level or 0
    tag = tag or default_tags[level]
    
    local msg = string.format("%s | [%s] | %s", os.date(), tag, msg)
    if game.appdata.client_log then
        game.appdata.client_log:write(msg.."\n")
    end
    print(msg)
end