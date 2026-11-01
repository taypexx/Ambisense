---@class utils
local utils = {}
utils.__index = utils

--- Returns a new function that can be used as __newindex for a class so that the field is read-only.
---@param fields table A table containing field names (strings) that are going to be read-only.
---@return function|nil
function utils.readonly_func(fields)
    if not fields or #fields == 0 then return end

    return function (t, k, v)
        for _,field in pairs(fields) do
            if k == field and t[k] ~= nil then  -- Skip if the field wasn't assigned yet (nil).
                game.error(string.format("Attempt to modify a read-only field \"%s\".", k))
                return
            end
        end

        -- Assign new index if it's not read-only. rawset() bypasses recursion.
        rawset(t, k, v)
    end
end

--- Finds the index of the value in the given table and returns it or nil if not present.
--- Note that this won't work with dictionaries.
--- @param t table Table to look into.
--- @param value any Value to find.
--- @return any|nil
function utils.table_find(t, value)
    if not t then game.error("Table search failed: No table was provided.") return end
    if not value then game.error("Table search failed: No value was provided.") return end

    for i = 1, #t do
        if t[i] == value then
            return i
        end
    end
end

--- Creates a copy of a table.
---@param original table Original table to reference.
---@return table
function utils.table_copy(original)
    local copy = {}

    for key, value in pairs(original) do
        local copied_key = key
        local copied_value = value

        if type(key) == "table" then
            copied_key = utils.table_copy(key)
        end

        if type(value) == "table" then
            copied_value = utils.table_copy(value)
        end

        copy[copied_key] = copied_value
    end

    return copy
end

--- Same as utils.table_find but returns key instead of index.
--- @param t table Table to look into.
--- @param value any Value to find.
--- @return any|nil
function utils.table_find_k(t, value)
    if not t then game.error("Table search failed: No table was provided.") return end
    if not value then game.error("Table search failed: No value was provided.") return end

    for k,v in pairs(t) do
        if v == value then
            return k
        end
    end
end

--- Splits a string by the provided separator and returns a table containing split strings.
---@param input string String to split.
---@param sep string Separator which divides the original string.
---@return table
function utils.split(input, sep)
    if sep == nil then
        sep = "%s" -- Defaults to whitespace
    end
    local t = {}
    for str in string.gmatch(input, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

--- Clamps the given value between min and max.
---@param x number The number to clamp.
---@param min number|nil Minimum value allowed.
---@param max number|nil Maximum value allowed.
---@return number x_clamped Clamped value.
function utils.clamp(x, min, max)
    if min and x < min then
        return min
    elseif max and x > max then
        return max
    end
    return x
end

--- Applies opacity on the current drawing color.
--- @param opacity number Number from 0 to 1. 0 - fully invisible, 1 - fully visible.
function utils.apply_opacity(opacity)
    local r,g,b,a = love.graphics.getColor()
    love.graphics.setColor(r,g,b,a * opacity)
end

--- Resets the current drawing color to white.
function utils.reset_color()
    love.graphics.setColor(1,1,1,1)
end

local keys_cache = {}

--- Iterates through the dictionary and calls the function for every pair. Returns the first non-nil result from the function.
---@param dict table A dictionary to iterate (based on its keys).
---@param func function A function to be called for every pair. Key and value will be provided as arguments.
---@param reverse boolean|false Whether to iterate the dictionary in reverse.
---@return any
function utils.iterate(dict, reverse, func)
    -- Clear previous keys without deleting the table (no GC pressure)
    for i = 1, #keys_cache do keys_cache[i] = nil end
    
    -- Extract keys
    local count = 0
    for k in pairs(dict) do
        count = count + 1
        keys_cache[count] = k
    end
    
    -- Sort (Lua's table.sort is highly optimized when not creating new functions)
    if reverse then
        table.sort(keys_cache, function(a, b) return a > b end)
    else
        table.sort(keys_cache, function(a, b) return a < b end)
    end
    
    -- Use a standard numeric loop instead of an iterator function
    for i = 1, count do
        local k = keys_cache[i]
        local v = dict[k]
        local res = func(k,v)
        if res then return res end
    end
end

--- Gets the file name from the file path without extension.
---@param file_path string Path of the file.
---@return string|nil name File name without extension or nil if file_path is invalid.
function utils.get_file_name(file_path)
    local path_split = utils.split(file_path, "/")
    local file_name = path_split[#path_split]
    return utils.split(file_name, ".")[1] or file_name
end

--- Checks whether the string starts with another string.
---@param str string String to check.
---@param starts string Start of the string.
function utils.starts_with(str, starts)
    return str.sub(str, 1, #starts) == starts
end

--- Checks whether the string ends with another string.
---@param str string String to check.
---@param ends string End of the string.
function utils.ends_with(str, ends)
    return str.sub(str, -#ends) == ends
end

--- Checks whether the string is nil, empty, or consists of white spaces.
---@param str string
---@return boolean
function utils.is_empty(str)
    if not str or string.gsub(str, " ", "") == "" then
        return true
    end
    return false
end

function utils.clean_folder(path)
    for _,item in ipairs(love.filesystem.getDirectoryItems(path)) do
        local item_path = path.."/"..item

        if love.filesystem.getInfo(item_path).type == "directory" then
            utils.clean_folder(item_path)
            love.filesystem.remove(item_path)
        else
            love.filesystem.remove(item_path)
        end
    end
end

return utils