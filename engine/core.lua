local error_handler = require("engine.substrate.error_handler")
local event = require("engine.types.event")

--[[ 
Contains all core engine structures inside. 
It is also global so that you can access it from anywhere in the code.
]]

game = {}
game.__index = game

--------------------------------------------

game.appdata = require("engine.substrate.appdata")
game.log = require("engine.substrate.log")
game.error = error_handler.error
game.error_handler = error_handler
game.utils = require("engine.substrate.utils")
game.event = event

game.types = {
    object = require("engine.types.object"),
    event = require("engine.types.event")
}

game.audio_handler = require("engine.audio.audio_handler")
game.graphics_handler = require("engine.graphics.graphics_handler")

game.object_handler = require("engine.substrate.object_handler")

game.mouse = require("engine.input.mouse")
game.keyboard = require("engine.input.keyboard")

game.assets = {
    sprite = require("engine.assets.sprite"),
    sprite_sheet = require("engine.assets.sprite_sheet")
}

game.scenes = {
    scene = require("engine.graphics.scenes.scene"),
    scene_component = require("engine.graphics.scenes.scene_component")
}

game.input = {
    cursor = require("engine.input.cursor")
}

--------------------------------------------

game.on_update = event:new()
game.on_quit = event:new()


function game:load()
    self.appdata:init()
    self.graphics_handler:init()

    self.log("Engine was successfully initialized.")
end

function game:update(dt)
    self.on_update:fire(dt)


end

function game:quit()
    self.on_quit:fire()

    self.appdata:close_file_handles()
end