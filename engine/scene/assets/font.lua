local object = game.object
local utils = game.utils

---@class font:object
---@field name string The file name of the font.
---@field fonts table<integer,love.Font> The love font objects.
local font = {
    name = nil,
    fonts = nil
}
font.__index = font
font.__newindex = utils.readonly_func({"name", "font"})

-- Inherits
setmetatable(font, object)

--- Creates a new font from the file.
---@param file_name string Name of the font relative to the assets/fonts.
---@return font|nil
function font:new(file_name)
    if not file_name then game.error("Cannot create a new font: file_name was not provided.") return end
    local file_path = "assets/fonts/"..file_name
    if not love.filesystem.getInfo(file_path) then game.error("Cannot create a new font: file_path is incorrect.") return end

    local new = setmetatable(object:new(), self)
    new.name = utils.split(file_name, ".")[1] or file_name
    new.fonts = {}

    for _,size in ipairs({72, 64, 48, 36, 32, 28, 24, 20, 18, 16, 14, 12}) do
        local love_font = love.graphics.newFont(file_path, size)
        if love_font then
            new.fonts[size] = love_font
        else
            game.error("Cannot create a new font: Font is incorrect.")
            break
        end
    end

    return new
end

--- Destroys the font and its love font object.
function font:destroy()
    for _,love_font in pairs(self.fonts) do
        if love_font then
            love_font:release()
        end
    end
    object.destroy(self)
end

return font