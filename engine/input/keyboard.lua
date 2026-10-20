local event = game.event
local utils = game.utils

---@class keyboard
---@field key_events table<string, event>
---@field on_key_down event Fires when a keyboard button is pressed. Arguments: key:string - Key that was pressed. All key strings: https://www.love2d.org/wiki/Scancode.
---@field on_key_up event Fires when a keyboard button is released. Arguments: key:string - Key that was released. All key strings: https://www.love2d.org/wiki/Scancode.
local keyboard = {
    key_events = {
        [true] = {},
        [false] = {}
    },
    on_key_down = event:new(),
    on_key_up = event:new()
}
keyboard.__index = keyboard
keyboard.__newindex = utils.readonly_func({"key_events", "on_key_down", "on_key_up"})

--- Gets the event associated with the specific key press.
---@param key string Key of the event.
---@param down boolean If true will return the key_down event, otherwise will return key_up event. True by default.
---@return event|nil event Event that will be fired every time this key gets pressed.
function keyboard:get_key_event(key, down)
    if down == nil then down = true end
    if not self:is_valid(key) then game.error(string.format("Cannot get the key up event: \"%s\" is not a valid scancode.", key)) return end

    local key_event = self.key_events[down][key]
    if not key_event then
        key_event = event:new()
        self.key_events[down][key] = key_event
    end
    return key_event
end

--- Checks whether the key is pressed right now.
---@param key string Key that is being checked. All key strings: https://www.love2d.org/wiki/Scancode.
---@return boolean pressed True if the key is pressed, otherwise false.
function keyboard:is_pressed(key)
    return love.keyboard.isDown(key)
end

--- Checks whether the key is a valid scancode.
---@param key string Key to check.
---@return boolean valid True if the given key is a valid scancode, otherwise false. 
function keyboard:is_valid(key)
    local valid = pcall(love.keyboard.getKeyFromScancode, key)
    return valid
end

function love.keypressed(_, scancode)
    keyboard.on_key_down:fire(scancode)

    local key_event = keyboard.key_events[true][scancode]
    if key_event then
        key_event:fire()
    end
end

function love.keyreleased(_, scancode)
    keyboard.on_key_up:fire(scancode)

    local key_event = keyboard.key_events[false][scancode]
    if key_event then
        key_event:fire()
    end
end

return keyboard