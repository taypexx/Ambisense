local object = game.types.object

---@class sprite_sheet
---@field image love.image Main image of the sprite sheet.
---@field width integer Width of the main image in pixels.
---@field height integer Height of the main image in pixels.
---@field quads table<love.Quad> A table containing all quads of the main image used to render different sprites of the sheet.
---@field quad_width integer Width of one quad in pixels.
---@field quad_height integer Height of one quad in pixels.
local sprite_sheet = {
    image = nil,
    width = nil,
    height = nil,
    quads = nil,
    quad_width = nil,
    quad_height = nil
}
sprite_sheet.__index = sprite_sheet
sprite_sheet.__newindex = game.utils.get_readonly_func({"image", "width", "height", "quads", "quad_width", "quad_height"})

-- Inherits
setmetatable(sprite_sheet, object)

--- Creates a new sprite sheet.
---@param file_path string Path of the sprite sheet relative to the assets.
---@param width integer Width of one quad in pixels.
---@param height integer Height of one quad in pixels.
---@return sprite_sheet|nil
function sprite_sheet:new(file_path, width, height)
    if not file_path then game.error("Cannot create a new sprite sheet: file_path was not provided.") return end
    if not love.filesystem.getInfo(file_path) then game.error("Cannot create a new sprite sheet: file_path is incorrect.") return end

    local quads = {}
    local image = love.graphics.newImage(file_path)
    local image_width, image_height = image:getDimensions()

    -- Y first so that it reads rows first
    for y = 0, image_height, height do
        for x = 0, image_width, width do
            table.insert(quads, love.graphics.newQuad(x, y, width, height))
        end
    end

    local new = setmetatable(object:new(), self)
    new.image = image
    new.width = image_width
    new.height = image_height
    new.quads = quads
    new.quad_width = width
    new.quad_height = height

    return new
end

--- Destroys the sprite sheet. Also destroys its image and quads.
function sprite_sheet:destroy()
    if self.image then
        self.image:release()
    end
    if self.quads then
        for _,quad in pairs(self.quads) do
            quad:release()
        end
    end
    object.destroy(self)
end

return sprite_sheet