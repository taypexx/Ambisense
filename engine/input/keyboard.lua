local event = game.types.event

---@class keyboard
---@field on_key_down event Fires when a keyboard button is pressed. Arguments: key:string - Key that was pressed. All key strings: https://www.love2d.org/wiki/Scancode.
---@field on_key_up event Fires when a keyboard button is released. Arguments: key:string - Key that was released. All key strings: https://www.love2d.org/wiki/Scancode.
local keyboard = {
    on_key_down = event:new(),
    on_key_up = event:new()
}
keyboard.__index = keyboard
keyboard.__newindex = game.utils.get_readonly_func({"on_key_down", "on_key_up"})

function love.keypressed(key, scancode)
    keyboard.on_key_down:fire(scancode)
end

function love.keyreleased(key, scancode)
    keyboard.on_key_up:fire(scancode)
end

return keyboard