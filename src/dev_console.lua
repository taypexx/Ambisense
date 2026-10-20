local ui_element = game.scene.ui.element
local ui_border = game.scene.ui_modifiers.ui_border

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
    self.frame = ui_element:new(scene, 9000, 0.2, 0.2, 0.6, 0.6, {0.2,0.2,0.2})
    ui_border:new(self.frame, 3, false, {0.5,0.5,0.5})

    local logs = ui_element:new(self.frame, 9001, 0.05, 0.05, 0.9, 0.8, {0,0,0})

    self:toggle()
end

return console