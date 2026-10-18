local sti = require("sti")
local utils = game.utils
local scene_component = game.graphics.scene_component

local MAP_SCENE_LAYER = 99

---@class map:scene_component
---@field name string Name of the map.
---@field sti any The STI map.
---@field bgs table<integer,background> All map parallax backgrounds.
local map = {
    name = nil,
    sti = nil,
    bgs = nil
}
map.__index = map

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

    local camera = game.world.camera

    -- Makes the background layers repeat
    for _,layer in pairs(new.sti.layers) do
        if layer.image and string.sub(layer.name, 1, 2) == "bg" then
            layer.visible = false

            local image = layer.image
            image:setWrap("repeat", "repeat")

            local iw, ih = image:getDimensions()
            local sw, sh = love.graphics.getDimensions()
            local quad = love.graphics.newQuad(0, 0, sw, sh, iw, ih)

            layer.draw = function()
                local px = math.floor(camera.x * (self.parallaxx or 1))
                local py = math.floor(camera.y * (self.parallaxy or 1))
                
                quad:setViewport(
                    -px, -py,
                    sw, sh,
                    iw, ih
                )
                love.graphics.draw(image, quad, 0, 0)
            end
        end
    end

    return new
end

--- Destroys the map.
function map:destroy()
    scene_component.destroy(self)
end

return map