local object = require("engine.types.object")

---@class cursor
local cursor = {
    sprite = nil,
    x_hot = nil,
    y_hot = nil
}
cursor.__index = cursor
cursor.__newindex = game.utils.get_readonly_func({"sprite"})

-- Inherits
setmetatable(cursor, object)

--- Creates a new cursor.
---@param sprite sprite The cursor sprite.
---@param x integer|nil X coordinate of the cursor hot spot. 
---@param y integer|nil Y coordinate of the cursor hot spot. 
---@return cursor|nil
function cursor:new(sprite, x, y)
    if not sprite then game.error("Cannot create a cursor: sprite was not provided.") return end
    x = x or 0
    y = y or 0

    local new = setmetatable(object:new(), self)
    cursor.sprite = sprite
    cursor.x_hot = x
    cursor.y_hot = y
    
    return new
end

return cursor