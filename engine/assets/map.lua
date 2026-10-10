local sti = require("sti")
local object = game.types.object
local utils = game.utils

---@class map:object
---@field name string Name of the map.
---@field sti any The STI map.
local map = {
    name = nil,
    sti = nil
}
map.__index = map

-- Inherits
setmetatable(map, object)

--- Updates the map.
function map:update(dt)
    self.sti:update(dt)
end

--- Draws the map.
function map:draw()
    self.sti:draw()
end

--- Initializes all processes happening on the map.
function map:load()
    -- Not sure abt this: self.sti:box2d_init(game.world_handler.world)
end

--- Stops all processes happening on the map.
function map:unload()
    
end

--- Creates a new map from the file at the given path.
---@param file_path string Path to the .lua tiled map.
---@return map|nil
function map:new(file_path)
    if not file_path then game.error("Cannot create a new map: file_path was not provided.") return end

    local sti_map = sti(file_path)
    if not sti_map then game.error("Cannot create a new map: Failed to initialize STI.") return end

    local new = setmetatable(object:new(), self)
    new.name = utils.get_file_name(file_path) or file_path
    new.sti = sti_map

    return new
end

--- Destroys the map.
function map:destroy()
    object.destroy(self)
end

return map