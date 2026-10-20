local const = {

    name = "Ambisense",
    game_version = "1.0",
    love_version = "11.5",
    icon_path = nil,

    tile_size = 32,
    gravity_constant = 1000,
}

-- https://www.love2d.org/wiki/Config_Files
const.set_conf = function (t)
    t.identity = const.name
    t.appendidentity = false
    t.version = const.love_version
    t.console = true
    t.externalstorage = true

    t.audio.mic = false
    t.audio.mixwithsystem = true

    t.window.title = const.name
    t.window.icon = const.icon_path
    t.window.width = 1280
    t.window.height = 720
    t.window.minwidth = 64
    t.window.minheight = 64
    t.window.borderless = false
    t.window.resizable = false
    t.window.fullscreen = false
    t.window.fullscreentype = "desktop"
    t.window.vsync = 0
    t.window.msaa = 0
    t.window.highdpi = false
    t.window.usedpiscale = false
    t.window.x = nil
    t.window.y = nil

    t.modules.audio = true
    t.modules.data = true
    t.modules.event = true
    t.modules.font = true
    t.modules.graphics = true
    t.modules.image = true
    t.modules.joystick = true
    t.modules.keyboard = true
    t.modules.math = true
    t.modules.mouse = true
    t.modules.physics = true
    t.modules.sound = true
    t.modules.system = true
    t.modules.thread = true
    t.modules.timer = true
    t.modules.touch = true
    t.modules.video = true
    t.modules.window = true
end

return const