local ui_element = game.scene.ui.element

---@class console
---@field frame ui_element
local console = {
    frame = nil
}
console.__index = console

function console:toggle()
    self.frame.active = not self.frame.active
end

function console:create(scene)
    self.frame = ui_element:new(scene, 9999, 0.2, 0.2, 0.6, 0.6)
    self.frame.color = {0.2,0.2,0.2}
    self:toggle()
end

return console