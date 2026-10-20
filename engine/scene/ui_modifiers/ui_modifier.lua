local object = game.object

---@class ui_modifier:object
---@field ui_element ui_element UI element that this modifier is attached to.
local ui_modifier = {
    ui_element = nil,
}
ui_modifier.__index = ui_modifier

-- Inherits
setmetatable(ui_modifier, object)

--- Draw function of the UI modifier.
function ui_modifier:draw() end

--- Creates a new UI modifier.
---@param ui_element ui_element UI element to add this modifier to.
---@return ui_modifier|nil
function ui_modifier:new(ui_element)
    if not ui_element then game.error("Cannot create a new UI modifier: ui_element was not provided.") return end

    local new = setmetatable(object:new(), ui_modifier)
    new.ui_element = ui_element

    ui_element:attach_modifier(new)
    return new
end

--- Destroys the UI modifier.
function ui_modifier:destroy()
    if self.ui_element then
        self.ui_element:detach_modifier(self)
    end
    object.destroy(self)
end

return ui_modifier