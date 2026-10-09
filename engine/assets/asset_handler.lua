---@class asset_handler
---@field fonts table<string, font> Table of fonts. Key is the name of the font, value is the font object.
---@field sprites table<string, table<string, sprite|sprite_sheet>> Table of sprites|sprite sheets. Key is the name of the folder, value is the table where key is the sprite|sprite sheet name and value is the sprite|sprite sheet object.
local asset_handler = {
    fonts = {},
    sprites = {},
}
asset_handler.__index = asset_handler

--- Gets the love font object 
---@param font_name string Name of the font.
---@param size integer|nil Size of the font.
---@return love.font|nil
function asset_handler:get_font(font_name, size)
    local font = self.fonts[font_name]
    if not font then game.error(string.format("Cannot get the font: Font %s is not loaded.", font_name)) return end

    size = size or 12
    local love_font = font.fonts[size]
    if not love_font then game.error(string.format("Cannot get the font: Font %s does not have size %d.", font_name, size)) return end

    return love_font
end

--- Loads every asset into the memory.
function asset_handler:init()
    -- Loading fonts
    for _,file_name in pairs(love.filesystem.getDirectoryItems("assets/fonts")) do
        local file_path = "assets/fonts/"..file_name
        local info = love.filesystem.getInfo(file_path)
        if info and not info.isDirectory then
            local font = game.assets.font:new(file_name)
            if font then
                self.fonts[font.name] = font
            else
                game.log("Cannot load font: Failed to create the font object.", 1)
            end
        else
            game.log(string.format("Cannot load font: file_path %s is invalid.", file_path), 1)
        end
    end

    -- Loading sprites
    for _,folder_name in pairs(love.filesystem.getDirectoryItems("assets/sprites")) do
        local file_path = "assets/sprites/"..folder_name
        local info = love.filesystem.getInfo(file_path)
        if info and info.type == "directory" then
            for _,file_name in pairs(love.filesystem.getDirectoryItems(file_path)) do
                local sub_file_path = file_path.."/"..file_name
                local sub_info = love.filesystem.getInfo(sub_file_path)
                if sub_info and sub_info.type == "file" then
                    local sprite = game.assets.sprite:new_from_file(sub_file_path)
                    if sprite then
                        if not self.sprites[folder_name] then
                            self.sprites[folder_name] = {}
                        end
                        self.sprites[folder_name][sprite.name] = sprite
                    else
                        game.log("Cannot load sprite: Failed to create the sprite object.", 1)
                    end
                else
                    game.log(string.format("Cannot load sprite: file_path %s is invalid.", sub_file_path), 1)
                end
            end
        else
            game.log(string.format("Cannot load sprite: file_path %s is invalid.", file_path), 1)
        end
    end
end

return asset_handler