local utils = game.utils

---@class asset_handler
---@field fonts table<string, font> Table of fonts. Key is the name of the font, value is the font object.
---@field sprites table<string, table<string, sprite|sprite_sheet>> Table of sprites|sprite sheets. Key is the name of the folder, value is the table where key is the sprite|sprite sheet name and value is the sprite|sprite sheet object.
---@field audios table<string, table<string, audio>> Table of audios. Key is the name of the folder, value is the table where key is the audio name and value is the audio object.
local asset_handler = {
    fonts = {},
    sprites = {},
    audios = {},
    maps = {}
}
asset_handler.__index = asset_handler

--- Loads every asset into the memory.
function asset_handler:init()
    -- Loading fonts
    for _,file_name in pairs(love.filesystem.getDirectoryItems("assets/fonts")) do
        local file_path = "assets/fonts/"..file_name
        local info = love.filesystem.getInfo(file_path)
        if info and not info.isDirectory then
            local font = game.scene.assets.font:new(file_name)
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
                    local sprite = game.scene.assets.sprite:new_from_file(sub_file_path)
                    if sprite then
                        if not self.sprites[folder_name] then
                            self.sprites[folder_name] = {}
                        end
                        self.sprites[folder_name][sprite.name] = sprite
                    else
                        game.log("Cannot load sprite: Failed to create the sprite object.", 1)
                    end
                end
            end
        else
            game.log(string.format("Cannot load sprite: file_path %s is invalid.", file_path), 1)
        end
    end

    -- Loading audio
    for _,folder_name in pairs(love.filesystem.getDirectoryItems("assets/audio")) do
        local file_path = "assets/audio/"..folder_name
        local info = love.filesystem.getInfo(file_path)
        if info and info.type == "directory" then
            for _,file_name in pairs(love.filesystem.getDirectoryItems(file_path)) do
                local sub_file_path = file_path.."/"..file_name
                local sub_info = love.filesystem.getInfo(sub_file_path)
                if sub_info and sub_info.type == "file" then
                    local audio = game.audio.audio:new(sub_file_path, folder_name ~= "music")
                    if audio then
                        if not self.audios[folder_name] then
                            self.audios[folder_name] = {}
                        end
                        self.audios[folder_name][audio.name] = audio
                    else
                        game.log("Cannot load audio: Failed to create the audio object.", 1)
                    end
                end
            end
        else
            game.log(string.format("Cannot load audio: file_path %s is invalid.", file_path), 1)
        end
    end

    -- Loading maps
    for _,folder_name in pairs(love.filesystem.getDirectoryItems("assets/maps")) do
        local file_path = "assets/maps/"..folder_name
        local info = love.filesystem.getInfo(file_path)
        if info and info.type == "directory" then
            for _,file_name in pairs(love.filesystem.getDirectoryItems(file_path)) do
                local sub_file_path = file_path.."/"..file_name
                local sub_info = love.filesystem.getInfo(sub_file_path)
                if utils.ends_with(file_name, ".lua") and sub_info and sub_info.type == "file" then
                    local map = game.world.map:new(sub_file_path)
                    if map then
                        self.maps[map.name] = map
                    else
                        game.log("Cannot load map: Failed to create the map object.", 1)
                    end
                end
            end
        else
            game.log(string.format("Cannot load map: file_path %s is invalid.", file_path), 1)
        end
    end
end

return asset_handler