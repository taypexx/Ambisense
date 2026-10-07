local object = require("engine.types.object")
local sprite = require("engine.assets.sprite")

---@class sprite_sheet
local sprite_sheet = {
    image = nil,
    width = nil,
    height = nil,
    quads = nil,
    quad_width = nil,
    quad_height = nil
}
sprite_sheet.__index = sprite_sheet
sprite.__newindex = game.utils.get_readonly_func({"image", "width", "height", "quads", "quad_width", "quad_height"})

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

return sprite_sheet