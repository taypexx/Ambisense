local object = game.types.object

---@class cursor
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
cursor.__newindex = game.utils.get_readonly_func({"name", "sprite"})

-- Inherits
setmetatable(cursor, object)

--- Creates a new cursor.
---@param file_name string Name of the cursor sprite file. All cursors are stored in assets/sprites/cursors.
---@param x integer|nil X coordinate of the cursor hot spot. 
---@param y integer|nil Y coordinate of the cursor hot spot. 
---@return cursor|nil
function cursor:new(file_name, x, y)
    if not file_name then game.error("Cannot create a cursor: file_name was not provided.") return end
    local file_path = "assets/sprites/cursors/"..file_name
    if not love.filesystem.getInfo(file_path) then game.error("Cannot create a cursor: file path is invalid.") return end

    local sprite = game.assets.sprite:new_from_file(file_path)
    if not sprite then return end

    x = x or 0
    y = y or 0

    local new = setmetatable(object:new(), self)
    new.name = game.utils.split(file_name, ".")[1] or file_name
    new.sprite = sprite
    new.x_hot = x
    new.y_hot = y
    
    return new
end


function cursor:destroy()
    if self.sprite then
        self.sprite:destroy()
    end
    object.destroy(self)
end

return cursor