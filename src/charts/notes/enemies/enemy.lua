local utils = game.utils
local note = game.notes.note
local asset_handler = game.asset_handler
local tween = game.tween

---@class enemy:note
---@field sprite sprite
local enemy = {
    sprite = nil
}
enemy.__index = enemy

-- Inherits
setmetatable(enemy, note)

function enemy:hit(dt)
    note.hit(self, dt)


    tween:start(self, "y", self.y - 75, 0.1, "sine", function ()
        tween:start(self, "y", self.y + 500, 1.5, "linear")
    end)
end

function enemy:draw()
    if not self:is_drawing() then return end

    local x,y = self:get_position()
    local w,h = self:get_size()
    local sx,sy = w / self.sprite.width, h / self.sprite.height

    if self.was_hit then
        love.graphics.setColor(1,1,1,0.2)
    end

    -- TODO: draw holds properly

    love.graphics.draw(self.sprite.image, x - w/2, y - h/2, 0, sx, sy)

    utils.reset_color()
end

function enemy:new(name, duration, line, long, long_end)
    local sprite = asset_handler.sprites.notes[name] or asset_handler.sprites.notes["basic1"]
    if not sprite then game.error(string.format("Cannot create a new enemy: %s sprite not found.", name)) return end

    local new = setmetatable(note:new(name, duration, line, long, long_end, false), self)
    new.sprite = sprite

    return new
end

function enemy:destroy()
    note.destroy(self)
end

return enemy