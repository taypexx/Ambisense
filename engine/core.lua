--[[ 
Contains all core engine structures inside. 
It is also global so that you can access it from anywhere in the code.
]]

game = {
    const = require("src.const"),
    current_os = love.system.getOS(), -- https://www.love2d.org/wiki/love.system.getOS
    audio = {},
    scene = {
        assets = {},
        ui = {},
        ui_modifiers = {}
    },
    input = {},
    world = {}
}

-- Proper indexing for the game table
setmetatable(game, {
    __index = function (t,lib)
        for _,v in pairs({"", ".types", ".tweening"}) do
            local s,m = pcall(require, string.format("engine.substrate%s.%s", v, lib))
            if s then
                return m
            end
        end
    end
})

-- Proper indexing for the internal tables inside game
for cat,libs in pairs(game) do
    if type(libs) == "table" then
        setmetatable(libs, {
            __index = function(t,lib)
                if lib == "handler" then
                    lib = string.format("%s_%s", cat, lib)
                end
                return require(string.format("engine.%s.%s", cat, lib))
            end
        })

        for subcat, libs_ in pairs(libs) do
            if type(libs_) == "table" then
                setmetatable(libs_, {
                    __index = function (t, lib_)
                        return require(string.format("engine.%s.%s.%s", cat, subcat, lib_))
                    end
                })
            end
        end
    end
end

-- Substrate
game.utils = require("engine.substrate.utils")

game.appdata = require("engine.substrate.appdata")
game.asset_handler = require("engine.substrate.asset_handler")
game.error_handler = require("engine.substrate.error_handler")
game.error = game.error_handler.error
game.log = require("engine.substrate.log")
game.crypto = require("engine.substrate.crypto")
game.save = require("engine.substrate.save")
game.settings = require("engine.substrate.settings")
game.object_handler = require("engine.substrate.object_handler")

-- Types
game.object = require("engine.substrate.types.object")
game.event = require("engine.substrate.types.event")
game.event_handle = require("engine.substrate.types.event_handle")

-- Tweens
game.tween = require("engine.substrate.tweening.tween")
game.tween_task = require("engine.substrate.tweening.tween_task")

-- Audio
game.audio.audio = require("engine.audio.audio")
game.audio.group = require("engine.audio.audio_group")
game.audio.handler = require("engine.audio.audio_handler")

-- Scenes
game.scene.scene = require("engine.scene.scene")
game.scene.scene_component = require("engine.scene.scene_component")
game.scene.handler = require("engine.scene.scene_handler")

game.scene.assets.font = require("engine.scene.assets.font")
game.scene.assets.sprite = require("engine.scene.assets.sprite")
game.scene.assets.sprite_sheet = require("engine.scene.assets.sprite_sheet")
    
game.scene.ui.element = require("engine.scene.ui.ui_element")
game.scene.ui.text_label = require("engine.scene.ui.text_label")
game.scene.ui_modifiers.ui_modifiers = require("engine.scene.ui_modifiers.ui_modifier")
game.scene.ui_modifiers.ui_border = require("engine.scene.ui_modifiers.ui_border")

-- Input
game.input.cursor = require("engine.input.cursor")
game.input.mouse = require("engine.input.mouse")
game.input.keyboard = require("engine.input.keyboard")

-- World
game.world.camera = require("engine.world.camera")
game.world.background = require("engine.world.background")
game.world.map = require("engine.world.map")
game.world.map_component = require("engine.world.map_component")
game.world.handler = require("engine.world.world_handler")
game.world.world_object = require("engine.world.world_object")

-- Events
game.on_update = game.event:new()
game.on_quit = game.event:new()

--------------------------------------------

function game:load()
    self.appdata:init()
    self.asset_handler:init()
    self.scene.handler:init()
    self.world.handler:init()

    self.settings:load()
    self.save:load()

    self.log("Engine was successfully initialized.")
end

function game:update(dt)
    -- Clamp delta time if the game froze for a long time
    dt = math.min(dt, 1 / 30)

    self.audio.handler:update()
    self.world.handler:update(dt)
    self.world.camera:update(dt)
    self.tween:update()

    self.on_update:fire(dt)
end

function game:quit()
    self.on_quit:fire()

    self.settings:save()
    self.save:save()

    self.appdata:close_file_handles()
end