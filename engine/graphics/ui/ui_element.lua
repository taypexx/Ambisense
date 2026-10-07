local scene_component = game.scenes.scene_component

---@class ui_element
local ui_element = {
    -- figure out position and size calculations
    -- also figure out parenting (will be used for ui only)
}
ui_element.__index = ui_element
ui_element.__newindex = game.utils.get_readonly_func({""})

-- Inherits
setmetatable(ui_element, scene_component)

--- Creates a new UI element.
---@param scene scene Scene to add this element to.
---@param layer integer|nil Initial layer to draw the component on. Should be 1000 or higher. Default is 1000.
---@return ui_element|nil
function ui_element:new(scene, layer)
    if not scene then game.error("Cannot create a new UI element: scene was not provided.") return end

    local new = setmetatable(scene_component:new(scene,layer or 1000), self)
    return new
end

--- Destroys the UI element.
function ui_element:destroy()
    scene_component.destroy(self)
end

return ui_element