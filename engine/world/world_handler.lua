local camera = game.world.camera

---@class world_handler
---@field current_map map Current loaded map.
local world_handler = {
    current_map = nil,
    world = nil,
}
world_handler.__index = world_handler
world_handler.__newindex = game.utils.get_readonly_func({"world"})

--- Updates the current map (if there is any at the moment).
---@param dt number Time since last update in seconds.
function world_handler:update(dt)
    if not self.current_map then return end

    self.current_map:update(dt)
    camera:update(dt)
end

--- Loads the map and unloads the previous one.
---@param map_name string Name of the map to load.
---@param scene scene Scene to load the map on.
function world_handler:load_map(map_name, scene)
    if not map_name then game.error("Cannot load the map: map_name was not provided.") return end
    if not scene then game.error("Cannot load the map: scene was not provided.") return end

    local map = game.asset_handler.maps[map_name]
    if not map then game.error(string.format("Cannot load map: map %s doesn't exist.", map_name)) return end

    if self.current_map then
        self.current_map:unload()
    end

    -- Set camera to default settings.
    camera:set_mode("static")
    camera:to()
    camera:zoom(1)

    self.current_map = map
    map:load(scene)
end

--- Unloads the current map.
function world_handler:unload_map()
    if not self.current_map then return end
    self.current_map:unload()
end

--- Initializes the world.
function world_handler:init()
    self.world = love.physics.newWorld(0,0)
end

return world_handler