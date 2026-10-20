local const = game.const
local utils = game.utils
local camera = game.world.camera
local scene_handler = game.scene.handler

---@class world_handler
---@field current_map map Current loaded map.
---@field world love.World The only world of the engine.
---@field objects table<world_object> All existing world objects. Objects can be indexed not only by their index, but also by their fixture/body. 
---@field gravity number Gravity factor where 1 is normal gravity.
local world_handler = {
    current_map = nil,
    world = nil,
    gravity = 1,
    objects = setmetatable({}, {__index = function(t,k)
        for i,object in pairs(t) do
            if object and (k == i or (object.body and (k == object.body or utils.table_find(object.body:getFixtures(), k) ~= nil))) then
                return object
            end
        end
    end}),
}
world_handler.__index = world_handler
world_handler.__newindex = utils.readonly_func({"world"})

--- Updates world, its objects and the current map (if there is any at the moment).
---@param dt number Time since last update in seconds.
function world_handler:update(dt)
    if self.world then
        self.world:update(dt)
    end

    for _,object in pairs(self.objects) do
        object:update(dt)
    end
    
    if self.current_map then
        self.current_map:update(dt)
    end
    camera:update(dt)
end

--- Sets the current gravity and applies it to the world.
---@param gravity number Gravity factor where 1 is normal gravity.
function world_handler:set_gravity(gravity)
    self.gravity = gravity
    if self.world then
        self.world:setGravity(0, self.gravity * const.gravity_constant)
    end
end

--- Handles the start of the collision between world objects (if any of the colliding fixtures belong to the world object).
---@param begin boolean True if the collision started, false if the collision ended.
---@param fixture1 love.Fixture First fixture that might belong to the world object.
---@param fixture2 love.Fixture Second fixture that might belong to the world object.
---@param contact love.Contact Contact object of this collision.
function world_handler:collide(begin, fixture1, fixture2, contact)
    local object1, object2 = self.objects[fixture1], self.objects[fixture2]
    local event_name = "on_collision_"..((begin and "start") or "end")
    if object1 then
        object1[event_name]:fire(object2, contact)
    end
    if object2 then
        object2[event_name]:fire(object1, contact)
    end
end

--- Adds a object to the world.
--- For internal use only.
---@param object world_object World object to add.
function world_handler:add_object(object)
    if utils.table_find(self.objects, object) then game.error("Cannot add object to the world: object is already present.") return end
    table.insert(self.objects, object)
end

--- Removes the object from the world.
--- For internal use only.
---@param object world_object Map component to remove.
function world_handler:remove_object(object)
    local i = utils.table_find(self.objects, object)
    if not i then game.error("Cannot remove object from the world: object is not present.") return end
    table.remove(self.objects, i)
end

--- Loads the map and unloads the previous one.
---@param map_name string Name of the map to load.
---@param scene scene Scene to load the map on.
---@return map|nil map The loaded map.
function world_handler:load_map(map_name, scene)
    if not map_name then game.error("Cannot load the map: map_name was not provided.") return end
    if not scene then game.error("Cannot load the map: scene was not provided.") return end
    if not scene.active then game.error("Cannot load the map: scene is not active.") return end

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

    -- Unload the loaded map once the scene changes
    scene.on_unload:sub_once(function ()
        if map == self.current_map then
            self.current_map = nil
            map:unload()
        end
    end)

    return map
end

--- Initializes the world.
function world_handler:init()
    love.physics.setMeter(const.tile_size)
    self.world = love.physics.newWorld(0, self.gravity * const.gravity_constant, true)
    self.world:setCallbacks(function(...) self:collide(true,...) end, function(...) self:collide(false,...) end)

    -- Fix the map rendering when zooming out
    camera.on_zoom:sub(function (zoom)
        if not self.current_map then return end

        local sw,sh = love.graphics.getDimensions()
        self.current_map.sti:resize(sw / zoom, sh / zoom)
    end)
end

return world_handler