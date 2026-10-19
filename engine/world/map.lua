local sti = require("sti")
local utils = game.utils
local scene_component = game.graphics.scene_component
local background = game.world.background

local MAP_SCENE_LAYER = 99

---@class map:scene_component
---@field name string Name of the map.
---@field sti any The STI map.
---@field bgs table<integer,background> All map parallax backgrounds where key is the layer the background will be drawn at and value is the background itself. 
local map = {
    name = nil,
    sti = nil,
    bgs = nil
}
map.__index = map
map.__newindex = utils.readonly_func({"name", "sti", "bgs"})

-- Inherits
setmetatable(map, scene_component)

--- Updates the map.
function map:update(dt)
    self.sti:update(dt)
end

--- Draws the map.
function map:draw()
    local camera = game.world.camera
    local x,y = camera:get_screen_pos(0,0)
    local scale = camera.scale

    self.sti:draw(x/scale, y/scale, scale, scale)
end

--- Initializes all processes happening on the map.
---@param scene scene Scene to load this map on.
function map:load(scene)
    if not scene then game.error("Cannot load the map: scene was not provided.") return end

    self:assign(scene)
    for _,bg in pairs(self.bgs) do
        bg:assign(scene)
    end
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

    local new = setmetatable(scene_component:new(nil, MAP_SCENE_LAYER), self)
    new.name = utils.get_file_name(file_path) or file_path
    new.sti = sti_map
    new.bgs = {}

    -- Create backgrounds
    local bg_layer = 0
    for _,layer in pairs(new.sti.layers) do
        if layer.image and string.sub(layer.name, 1, 2) == "bg" then
            layer.visible = false

            local bg = background:new(layer.image, new, bg_layer, layer.parallaxx, layer.parallaxy)
            if bg then
                table.insert(new.bgs, bg)
                bg_layer = bg_layer + 1
            end
        end
    end

    return new
end

--- Destroys the map.
function map:destroy()
    if self.bgs then
        for _,bg in pairs(self.bgs) do
            bg:destroy()
        end
    end
    scene_component.destroy(self)
end

return map