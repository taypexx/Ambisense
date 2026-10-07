---@class appdata
local appdata = {
    full_path = love.filesystem.getSaveDirectory(),
    cache_path = "cache",
    logs_path = "logs",

    client_log_path = "logs/client.log",
    client_log = nil,

    save_file_path = "save.dat",
    save_file = nil,

    settings_file_path = "settings.json",
    settings_file = nil

}
appdata.__index = appdata

--- Creates files in AppData/Roaming/LOVE and opens the log file for writing.
function appdata:init()
    if not love.filesystem.getInfo(self.cache_path) then
        love.filesystem.createDirectory(self.cache_path)
    end

    if not love.filesystem.getInfo(self.logs_path) then
        love.filesystem.createDirectory(self.logs_path)
    end

    self.client_log = love.filesystem.newFile(self.client_log_path)
    self.client_log:open("w")

    self.save_file = love.filesystem.newFile(self.save_file_path)

    self.settings_file = love.filesystem.newFile(self.settings_file_path)
end

--- Closes all file handles if they are opened.
function appdata:closeFileHandles()
    self.client_log:close()
    self.save_file:close()
    self.settings_file:close()
end

return appdata