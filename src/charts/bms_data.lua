local object = game.object

---@class bms_data:object
---@field header table<string,string>
---@field main table<integer, table<integer, table<string|nil>>>
local bms_data = {
    header = nil,
    main = nil
}
bms_data.__index = bms_data

-- Inherits
setmetatable(bms_data, object)

function bms_data:new(header, main)
    local new = setmetatable(object:new(), self)
    new.header = header
    new.main = main

    return new
end

function bms_data:destroy()
    object.destroy(self)
end

return bms_data