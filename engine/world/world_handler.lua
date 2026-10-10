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
end

--- Draws the current map (if there is any at the moment).
function world_handler:draw()
    if not self.current_map then return end
    self.current_map:draw()
end

--- Loads the map and unloads the previous one.
---@param map map Map to load.
function world_handler:load_map(map)
    if self.current_map then
        self.current_map:unload()
    end

    self.current_map = map
    map:load()
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