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
        for _,field in ipairs(fields) do
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

return utils