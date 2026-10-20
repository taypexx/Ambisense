local sti = require("engine.sti")
local utils = game.utils
local event = game.event
local scene_component = game.scene.scene_component
local background = game.world.background

local MAP_SCENE_LAYER = 99

---@class map:scene_component
---@field name string Name of the map.
---@field file_path string File path of the lua file.
---@field loaded boolean True if the map is currently loaded, otherwise false.
---@field sti any The STI map.
---@field components table<integer,table<map_component>> All map components where key is the layer of the component and value is the table containing all map components of that layer.
---@field bgs table<integer,background> All map parallax backgrounds where key is the layer the background will be drawn at and value is the background itself. 
local map = {
    name = nil,
    file_path = nil,
    loaded = nil,
    sti = nil,
    components = nil,
    bgs = nil,

    on_load = event:new(),
    on_unload = event:new()
}
map.__index = map
map.__newindex = utils.readonly_func({"name", "sti", "bgs", "on_load", "on_unload"})

-- Inherits
setmetatable(map, scene_component)

--- Updates the map.
function map:update(dt)
    if not self.loaded then return end
    self.sti:update(dt)
end

--- Draws the map.
function map:draw()
    if not self.loaded then return end

    local camera = game.world.camera
    local x,y = camera:get_screen_pos(0,0)
    local scale = camera.scale

    self.sti:draw(x/scale, y/scale, scale, scale)
end

--- Adds a map component to the map.
--- For internal use only.
---@param component map_component Map component to add.
function map:add_component(component)
    local layer_table = self.components[component.layer]
    if layer_table then
        if utils.table_find(layer_table, component) then
            game.error(string.format("Cannot add map component to the \"%s\": Component is already present on the map.", self.name))
            return
        end
        table.insert(layer_table, component)
    else
        self.components[component.layer] = {component}
    end
end

--- Removes the map component from the map.
--- For internal use only.
---@param component map_component Map component to remove.
function map:remove_component(component)
    local layer_table = self.components[component.layer]
    local i = utils.table_find(layer_table, component)
    if not layer_table or not i then
        game.error(string.format("Cannot remove map component from the \"%s\": Component is not present on the map.", self.name))
        return
    end
    table.remove(layer_table, i)
end
--- Initializes all processes happening on the map.
---@param scene scene Scene to load this map on.
function map:load(scene)
    if not scene then game.error("Cannot load the map: scene was not provided.") return end

    local sti_map = sti(self.file_path, {"box2d"})
    if not sti_map then game.error("Cannot load the map: Failed to initialize STI.") return end

    self.sti = sti_map

    -- Iterate through the layers and modify them
    local bg_layer = 0
    for _,layer in pairs(self.sti.layers) do
        -- BG layers (image layers)
        if layer.image and string.sub(layer.name, 1, 2) == "bg" then
            layer.visible = false

            local bg = background:new(layer.image, self, bg_layer, layer.parallaxx, layer.parallaxy)
            if bg then
                table.insert(self.bgs, bg)
                bg:assign(scene)
                bg_layer = bg_layer + 1
            else
                game.log(string.format("Couldn't create a background for map \"%s\".", self.name), 1)
            end
        -- Collision layer
        elseif string.lower(layer.name) == "collision" then
            layer.visible = false
            layer.properties.collidable = true
        end
    end

    self:assign(scene)
    self.sti:box2d_init(game.world.handler.world)
    self.loaded = true
    self.on_load:fire()
end

--- Stops all processes happening on the map and unloads itself.
function map:unload()
    for _,components in pairs(self.components) do
        for i = 1, #components do
            components[1]:destroy()
        end
    end
    self.components = {}

    for _,bg in pairs(self.bgs) do
        bg:destroy()
    end

    self.sti = nil
    collectgarbage("collect")

    self.loaded = false
    self.on_unload:fire()
end

--- Creates a new map from the file at the given path.
---@param file_path string Path to the .lua tiled map.
---@return map|nil
function map:new(file_path)
    if not file_path then game.error("Cannot create a new map: file_path was not provided.") return end

    local new = setmetatable(scene_component:new(nil, MAP_SCENE_LAYER), self)
    new.name = utils.get_file_name(file_path) or file_path
    new.file_path = file_path
    new.components = {}
    new.bgs = {}

    return new
end

return map