local const = {

    name = "Ambisense",
    game_version = "1.0",
    love_version = "11.5",
    icon_path = nil,

    tile_size = 32,
    gravity_constant = 1000,
    
    hit_radius = 0.1,

    note_ids = {
        ["02"] = "basic1",
        ["03"] = "basic2",
        ["04"] = "normal1",
        ["05"] = "normal2",
        ["06"] = "heavy1",
        ["07"] = "heavy2",
        ["08"] = "special",
        ["09"] = "heal",
        ["0D"] = "boss1",
        ["0E"] = "boss2",
        ["0F"] = "boss3",
        ["0G"] = "boss4",
        ["0H"] = "boss_special",
        ["0P"] = "vignette_start",
        ["0Q"] = "vignette_max",
        ["0R"] = "vignette_end",
        ["0S"] = "speed1",
        ["0T"] = "speed2",
        ["0U"] = "speed3",
        ["0V"] = "speed4",
    },
    bms_lines = {
        [16] = 1, -- Left
        [11] = 2, -- Top
        [12] = 3, -- Right
        [13] = 4, -- Bottom
        [14] = 5, -- Misc1
        [15] = 6, -- Misc2
        [18] = 7, -- Misc3
        [19] = 8, -- Misc4

        [56] = 1, -- Left (long)
        [51] = 2, -- Top (long)
        [52] = 3, -- Right (long)
        [53] = 4, -- Bottom (long)
        [54] = 5, -- Misc1 (long)
        [55] = 6, -- Misc2 (long)
        [58] = 7, -- Misc3 (long)
        [59] = 8, -- Misc4 (long)
    },

    directions = {
        [1] = "left",
        [2] = "up",
        [3] = "right",
        [4] = "down"
    }
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
    t.window.resizable = true
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