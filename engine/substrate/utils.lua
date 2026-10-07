---@class utils
local utils = {}
utils.__index = {}

--- Returns a new function that can be used as __newindex for a class so that the field is read-only.
---@param fields table A table containing field names (strings) that are going to be read-only.
---@return function
function utils.get_readonly_func(fields)
    return function (t, k, v)
        for _,field in ipairs(fields) do
            if k == field and t[k] ~= nil then  -- Skip if the field wasn't assigned yet (nil).
                game.error_handler:error(string.format("Attempt to modify a read-only field \"%s\".", k))
                return
            end
        end

        -- Assign new index if it's not read-only. rawset() bypasses recursion.
        rawset(t, k, v)
    end
end

return utils