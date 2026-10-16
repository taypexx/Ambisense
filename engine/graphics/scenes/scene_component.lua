local object = game.types.object

---@class scene_component:object
---@field scene scene Scene of the component.
---@field layer integer Layer on which the component will be drawn. 0 is default. Higher values will overlap lower values.
local scene_component = {
    scene = nil,
    layer = nil,
}
scene_component.__index = scene_component
scene_component.__newindex = game.utils.get_readonly_func({"scene"})

-- Inherits
setmetatable(scene_component, object)

--- Tells whether the given position overlaps with the element.
---@param x integer X position on the screen to check.
---@param y integer Y position on the screen to check.
---@return boolean
function scene_component:does_overlap(x,y)
    x = x or 0
    y = y or 0

    local ox,oy = self:get_position()
    local width,height = self:get_size()

    return x >= ox and x <= ox + width and y >= oy and y <= oy + height
end

--- Placeholder for the draw function.
function scene_component:draw() end
--- Placeholder for the screen position function.
function scene_component:get_position() end
--- Placeholder for the screen size function.
function scene_component:get_size() end

--- Assigns the component to the scene. Cannot be called if the scene was already set.
---@param scene scene Scene to assign this component to.
function scene_component:assign(scene)
    if not scene then game.error("Cannot assign a scene component: scene was not provided.") return end
    if self.scene then game.error("Cannot assign a scene component: scene was already assigned.") return end

    self.scene = scene
    self.scene:add_component(self)
end

--- Creates a new scene component.
---@param scene scene|nil Scene to add this component to.
---@param layer integer|nil Initial layer to draw the component on. 0-999 - game objects. 1000+ - interface.
---@return scene_component|nil
function scene_component:new(scene, layer)
    local new = setmetatable(object:new(), self)
    new.scene = scene
    new.layer = layer or 0

    if scene then
        scene:add_component(new)
    end

    return new
end

--- Destroys the component. Also removes the component from the attached scene.
function scene_component:destroy()
    if self.scene then
        self.scene:remove_component(self)
    end
    object.destroy(self)
end

return scene_component