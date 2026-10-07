--[[ 
Contains all core engine structures inside. 
It is also global so that you can access it from anywhere in the code.
]]

game = {

    log = require("engine.substrate.log"),
    utils = require("engine.substrate.utils"),

    error_handler = require("engine.substrate.error_handler"),
    object_handler = require("engine.substrate.object_handler"),
    appdata = require("engine.substrate.appdata"),

    graphics_handler = require("engine.graphics.graphics_handler"),
}
game.__index = game


function game:onLoad()
    game.appdata:init()

    game.log("Game launched.")

    local scene = require("engine.graphics.scenes.scene")
    scene:new("CoolScene")
    scene:new()
end

function game:onUpdate(dt)
    
end

function game:onQuit()
    

    game.appdata:closeFileHandles()
end

love.load = game.onLoad
love.update = game.onUpdate
love.quit = game.onQuit

love.draw = game.graphics_handler.onDraw
love.lowmemory = game.error_handler.low_memory