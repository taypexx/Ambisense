local utils = game.utils

local FILE_TYPES = {"save", "settings"}
local TAG = "APPDATA"

---@class appdata
local appdata = {
    full_path = love.filesystem.getSaveDirectory(),
    cache_path = "cache",
    logs_path = "logs",

    client_log_path = "logs/client.log",
    client_log = nil,

    save_file_path = "save.dat",
    save_file = nil,

    settings_file_path = "settings.toml",
    settings_file = nil

}
appdata.__index = appdata

--- Reads contents of the file.
---@param file love.File Path of the file relative to appdata folder.
---@return string|nil content File content.
local function read_from_file(file)
    if not file then game.error("Cannot read the file: file is nil.") return end
    
    -- Open the file in proper mode if it isn't "read"
    if file:getMode() ~= "r" then
        file:close()

        local open_ok,open_err = file:open("r")
        if not open_ok then 
            game.error(string.format("Cannot read the file \"%s\": %s", file:getFilename(), open_err), TAG) 
            return
        end
    end

    local content,size = file:read()
    if size == 0 then
        game.log(string.format("0 bytes was read from file \"%s\".", file:getFilename()), 1, TAG)
    end

    return content
end

--- Sets contents to the file.
---@param file love.File Path of the file relative to appdata folder.
---@param content string Content to set to the file.
---@return boolean success True if set successfully, otherwise false.
local function set_to_file(file, content)
    if not file then game.error("Cannot set to the file: file is nil.", TAG) return false end
    if type(content) ~= "string" then game.error("Cannot set to the file: content must be a string.", TAG) return false end

    -- Open the file in proper mode if it isn't "write"
    if file:getMode() ~= "w" then
        file:close()

        local open_ok,open_err = file:open("w")
        if not open_ok then 
            game.error(string.format("Cannot write to the file \"%s\": Couldn't open the file - %s", file:getFilename(), open_err), TAG) 
            return false
        end
    end

    if string.len(content) == 0 then
        game.log(string.format("Writing a 0 byte string to the \"%s\" file.", file:getFilename()), 1, TAG)
    end
    
    local write_ok,write_err = file:write(content)
    if not write_ok then
        game.error(string.format("Cannot write to the file \"%s\": %s", file:getFilename(), write_err), TAG)
    end

    return write_ok
end

--- Reads contents from a file in appdata.
---@param file_type string What file to read from. See available values in FILE_TYPES.
---@return string|nil content File content.
function appdata:get(file_type)
    if not utils.table_find(FILE_TYPES, file_type) then
        game.error(string.format("Couldn't get content of the appdata file: Unknown type \"%s\".", file_type))
        return
    end
    return read_from_file(self[file_type.."_file"])
end

--- Sets contents to the file in appdata.
---@param file_type string What file to save to. See available values in FILE_TYPES.
---@param content string Content to set to the file.
---@return boolean success True if set successfully, otherwise false.
function appdata:set(file_type, content)
    if not utils.table_find(FILE_TYPES, file_type) then
        game.error(string.format("Couldn't set content to the appdata file: Unknown type \"%s\".", file_type))
        return false
    end
    if type(content) ~= "string" then
        game.error("Couldn't set content to the appdata file: content must be a string.", TAG)
        return false
    end

    return set_to_file(self[file_type.."_file"], content)
end

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
function appdata:close_file_handles()
    self.client_log:close()
    self.save_file:close()
    self.settings_file:close()
end

return appdata