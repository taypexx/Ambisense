local error_handler = require("engine.substrate.error_handler")
local event = require("engine.types.event")

--[[ 
Contains all core engine structures inside. 
It is also global so that you can access it from anywhere in the code.
]]

game = {}
game.__index = game

-- Libraries
game.appdata = require("engine.substrate.appdata")
game.log = require("engine.substrate.log")
game.utils = require("engine.substrate.utils")
game.event = event
game.error = error_handler.error
game.error_handler = error_handler
game.object_handler = require("engine.substrate.object_handler")

game.graphics_handler = require("engine.graphics.graphics_handler")

game.mouse = require("engine.input.mouse")
game.keyboard = require("engine.input.keyboard")

-- Events
game.on_update = event:new()
game.on_quit = event:new()


function game:load()
    self.appdata:init()

    self.log("Engine was successfully initialized.")
end

function game:update(dt)
    self.on_update:fire(dt)


end

function game:quit()
    self.on_quit:fire()

    self.appdata:close_file_handles()
end