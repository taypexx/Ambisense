local object = game.types.object

---@class sprite:object
---@field name string Name of the sprite.
---@field image love.image Sprite image.
---@field width integer Image width in pixels.
---@field height integer Image height in pixels.
local sprite = {
    name = nil,
    image = nil,
    width = nil,
    height = nil
}
sprite.__index = sprite
sprite.__newindex = game.utils.get_readonly_func({"image", "width", "height"})

-- Inherits
setmetatable(sprite, object)

--- Creates a new sprite from image.
---@param image love.Image Image object.
---@param name string Name of the sprite.
---@return sprite|nil
function sprite:new_from_image(image, name)
    if not image then game.error("Cannot create a new sprite: image was not provided.") return end
    if not name then game.error("Cannot create a new sprite: name was not provided.") return end

    local new = setmetatable(object:new(), self)
    new.name = name
    new.image = image
    new.width = image:getPixelWidth()
    new.height = image:getPixelHeight()

    return new
end

--- Creates a new sprite from file.
---@param file_path string Path of the sprite relative to the assets.
---@return sprite|nil
function sprite:new_from_file(file_path)
    if not file_path then game.error("Cannot create a new sprite: file_path was not provided.") return end
    if not love.filesystem.getInfo(file_path) then game.error("Cannot create a new sprite: file_path is incorrect.") return end

    local image = love.graphics.newImage(file_path)
    if not image then game.error("Cannot create a new sprite: Image is incorrect.") return end

    local name = game.utils.get_file_name(file_path)
    return self:new_from_image(image, name)
end

--- Destroys the sprite. Also destroys its image.
function sprite:destroy()
    if self.image then
        self.image:release()
    end
    object.destroy(self)
end

return sprite