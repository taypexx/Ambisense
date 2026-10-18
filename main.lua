require("engine.core")

function love.load()
    game:load()
    require("src.run")()
end

function love.update(dt)
    game:update(dt)
end

function love.draw()
    game.graphics.handler:draw()
end

function love.quit()
    game:quit()
end