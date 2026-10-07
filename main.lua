--[[ 
Contains all core engine structures inside. 
It is also global so that you can access it from anywhere in the code.
]]

game = {

    log = require("engine/substrate/log"),
    error_handler = require("engine/substrate/error_handler"),
    garbage_collector = require("engine/substrate/garbage_collector"),
    appdata = require("engine/substrate/appdata"),

    graphics = require("engine/graphics/graphics_main"),

}
game.__index = game

function game.onLoad()
    game.log("Launching the game...")

    game.garbage_collector.init()
    game.appdata.init()
    
    game.log("Game launched.")
end

function game.onUpdate(dt)
    
end

function game.onQuit()
    
end

love.load = game.onLoad
love.update = game.onUpdate
love.quit = game.onQuit

love.draw = game.graphics.onDraw

love.errorhandler = game.error_handler.error
love.lowmemory = game.error_handler.low_memory