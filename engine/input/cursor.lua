local object = game.object
local utils = game.utils

---@class cursor:object
---@field name string Name of the cursor.
---@field sprite sprite Sprite of the cursor.
---@field x_hot integer X hot spot coordinate of the cursor in pixels.
---@field y_hot integer Y hot spot coordinate of the cursor in pixels.
local cursor = {
    name = nil,
    sprite = nil,
    x_hot = nil,
    y_hot = nil
}
cursor.__index = cursor
cursor.__newindex = utils.get_readonly_func({"name", "sprite"})

-- Inherits
setmetatable(cursor, object)

--- Creates a new cursor.
---@param sprite sprite Sprite of the cursor.
---@param x integer|nil X coordinate of the cursor hot spot. 
---@param y integer|nil Y coordinate of the cursor hot spot. 
---@return cursor|nil
function cursor:new(sprite, x, y)
    if not sprite then game.error("Cannot create a cursor: sprite was not provided.") return end
    x = x or 0
    y = y or 0

    local new = setmetatable(object:new(), self)
    new.name = sprite.name
    new.sprite = sprite
    new.x_hot = x
    new.y_hot = y
    
    return new
end


function cursor:destroy()
    object.destroy(self)
end

return cursor