local utils = game.utils
local event = game.event
local map_component = game.world.map_component
local world_handler = game.world.handler

---@class world_object:map_component
---@field body love.Body Physical body of the world object.
---@field anchored boolean If true the body is not affected by any forces.
---@field on_collision_start event Fires when the object starts touching something. Arguments: object:world_object|nil - the other world object that was touched; may be nil in case the other body doesn't belong to a world object. contact:love.Contact - the contact object of the collision.
---@field on_collision_end event Fires when the object ends touching something. Arguments: object:world_object|nil - the other world object that was touched; may be nil in case the other body doesn't belong to a world object. contact:love.Contact - the contact object of the collision.
local world_object = {
    body = nil,
    anchored = nil,

    on_collision_start = event:new(),
    on_collision_end = event:new(),
}
world_object.__index = world_object
world_object.__newindex = utils.readonly_func({"body", "anchored", "on_collision_start", "on_collision_end"})

-- Inherits
setmetatable(world_object, map_component)

--- Updates the world object.
function world_object:update(dt)
    local x,y = self.body:getPosition()
    self.x = x - self.width/2
    self.y = y - self.height/2
end

--- Applies an impulse to the object by adding and then slowly substracting velocity.
---@param x number X length of the impulse relative to the object's body center.
---@param y number Y length of the impulse relative to the object's body center.
function world_object:impulse(x,y)
    if self.anchored then return end
    self.body:applyLinearImpulse(x,y)
end

--- Sets the constant velocity of the object.
---@param x number X length to be traveled in 1 second.
---@param y number Y length to be traveled in 1 second.
function world_object:set_velocity(x,y)
    if self.anchored then return end
    self.body:setLinearVelocity(x,y)
end

function world_object:reset_velocity()
    if self.anchored then return end
    self.body:setLinearVelocity(0,0)
end

--- Creates a new fixture and adds it to the body of the object.
---@param shape love.Shape Shape of the fixture.
---@param sensor boolean|nil Whether the new fixture will act as a sensor. False by default.
---@return love.Fixture fixture Newly created fixture.
function world_object:add_fixture(sensor, shape)
    sensor = sensor or false
    local fixture = love.physics.newFixture(self.body, shape, (sensor and 0) or 1)
    fixture:setSensor(sensor)

    return fixture
end

--- Creates a new world object.
---@param layer integer|nil Initial layer to draw the component on. Should be in range 100~999. Default is 100.
---@param x number|nil X coordinate in the world space. Default is 0.
---@param y number|nil Y coordinate in the world space. Default is 0.
---@param width number|nil Width in the world space. Default is 16.
---@param height number|nil Height in the world space. Default is 16.
---@param cull boolean|nil Whether to cull the object. True by default.
---@param anchored boolean|nil If true the body will not be affected by any forces. False by default.
---@param friction number|nil Friction of the body where 0 is very slippery and 1 is fully affected. Default is 0.5.
---@param allow_sleep boolean|nil If true the body will not interact with the world when idle. True by default if the body is anchored, otherwise false.
function world_object:new(layer, x, y, width, height, cull, anchored, friction, allow_sleep)
    if not world_handler.current_map then game.error("Cannot create a world object: No map loaded.") return end
    anchored = anchored or false

    local new = setmetatable(map_component:new(world_handler.current_map, layer, x, y, width, height, cull), self)
    new.anchored = anchored

    new.body = love.physics.newBody(world_handler.world, x, y, (anchored and "static") or "dynamic")
    new.body:setSleepingAllowed(anchored or allow_sleep or false)
    new.body:setFixedRotation(true)
    new.body:setLinearDamping(0)

    local main_shape = love.physics.newRectangleShape(width, height)
    local main_fixture = love.physics.newFixture(new.body, main_shape, 1)
    main_fixture:setFriction(friction or 0.5)

    world_handler:add_object(new)
    return new
end

function world_object:destroy()
    world_handler:remove_object(self)
    
    if self.body then
        self.body:destroy()
    end

    map_component.destroy(self)
end

return world_object