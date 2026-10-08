---@class utils
local utils = {}
utils.__index = {}

--- Returns a new function that can be used as __newindex for a class so that the field is read-only.
---@param fields table A table containing field names (strings) that are going to be read-only.
---@return function|nil
function utils.get_readonly_func(fields)
    if not fields then game.error("Cannot create a read-only function: fields is not a table.") return end
    if #fields == 0 then game.error("Cannot create a read-only function: fields table is empty.") return end

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

--- Finds a key/index of a value in the given table and returns it or nil if not present.
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
---@param min number Minimum value allowed.
---@param max number Maximum value allowed.
---@return number x_clamped Clamped value.
function utils.clamp(x, min, max)
    if x < min then
        return min
    elseif x > max then
        return max
    end
    return x
end

--- Applies transparency on the current drawing color.
--- @param transparency number Number from 0 to 1. 0 - fully visible, 1 - fully transparent.
function utils.apply_transparency(transparency)
    local r,g,b,a = love.graphics.getColor()
    love.graphics.setColor(r,g,b,a * transparency)
end

--- Resets the current drawing color to white.
function utils.reset_color()
    love.graphics.setColor(1,1,1,1)
end

local reverse_keys_cache = {}

--- Iterates through the dictionary and calls the function for every pair. Returns the first non-nil result from the function.
---@param dict table A dictionary to reverse (based on its keys).
---@param func function A function to be called for every pair. Key and value will be provided as arguments.
---@return any
function utils.reverse_iterate(dict, func)
    -- Clear previous keys without deleting the table (no GC pressure)
    for i = 1, #reverse_keys_cache do reverse_keys_cache[i] = nil end
    
    -- Extract keys
    local count = 0
    for k in pairs(dict) do
        count = count + 1
        reverse_keys_cache[count] = k
    end
    
    -- Sort (Lua's table.sort is highly optimized when not creating new functions)
    table.sort(reverse_keys_cache, function(a, b) return a > b end)
    
    -- Use a standard numeric loop instead of an iterator function
    for i = 1, count do
        local k = reverse_keys_cache[i]
        local v = dict[k]
        local res = func(k,v)
        if res then return res end
    end
end

return utils