--[[ 
Contains all core engine structures inside. 
It is also global so that you can access it from anywhere in the code.
]]

game = {}
game.__index = game

--------------------------------------------

local error_handler = require("engine.substrate.error_handler")

game.appdata = require("engine.substrate.appdata")
game.log = require("engine.substrate.log")
game.error = error_handler.error
game.error_handler = error_handler
game.utils = require("engine.substrate.utils")

game.types = {}
game.types.object = require("engine.types.object")
game.types.event_handle = require("engine.types.event_handle")
game.types.event = require("engine.types.event")

game.tween = require("engine.substrate.tweening.tween")
game.tween_task = require("engine.substrate.tweening.tween_task")

game.object_handler = require("engine.substrate.object_handler")
game.audio_handler = require("engine.audio.audio_handler")
game.graphics_handler = require("engine.graphics.graphics_handler")
game.asset_handler = require("engine.assets.asset_handler")

game.mouse = require("engine.input.mouse")
game.keyboard = require("engine.input.keyboard")

game.scenes = {}
game.scenes.scene = require("engine.graphics.scenes.scene")
game.scenes.scene_component = require("engine.graphics.scenes.scene_component")

game.assets = {}
game.assets.sprite = require("engine.assets.sprite")
game.assets.sprite_sheet = require("engine.assets.sprite_sheet")
game.assets.font = require("engine.assets.font")
game.assets.audio = require("engine.assets.audio")
game.assets.map = require("engine.assets.map")

game.input = {}
game.input.cursor = require("engine.input.cursor")

game.ui = {}
game.ui.ui_element = require("engine.graphics.ui.ui_element")
game.ui.text_label = require("engine.graphics.ui.text_label")

game.world = {}
game.world.map_component = require("engine.world.map_component")
game.world.camera = require("engine.world.camera")
game.world_handler = require("engine.world.world_handler")

--------------------------------------------

game.on_update = game.types.event:new()
game.on_quit = game.types.event:new()


function game:load()
    self.appdata:init()
    self.asset_handler:init()
    self.graphics_handler:init()
    self.world_handler:init()

    self.log("Engine was successfully initialized.")
end

function game:update(dt)
    self.audio_handler:update()
    self.world_handler:update(dt)
    self.world.camera:update(dt)
    self.tween:update()

    self.on_update:fire(dt)
end

function game:quit()
    self.on_quit:fire()

    self.appdata:close_file_handles()
end