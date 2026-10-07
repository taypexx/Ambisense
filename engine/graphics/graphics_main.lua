local graphics = {}
graphics.__index = graphics

function graphics.onDraw()
    love.graphics.print("Hello, LÖVE!", 100, 100)
end

return graphics