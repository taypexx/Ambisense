-- Main function of the game (outside of engine code)

--[[

    Current structute idea:

    Scenes:
    Prologue
    Title screen scene
    Loading screen
    Chart selection/home scene + map
    Lore/novel scene + maps (different scenes)
    Chart gameplay scene + maps (different scenes)

    

]]

local scene = game.scenes.scene
local mouse = game.mouse

return function()
    
    game.log("Game started.")

    local main_scene = scene:new("Main")
    game.graphics_handler:switch_scene(main_scene)

    local layer = 1000

    local music = game.asset_handler.audios.music.frozen_sky
    music:play()

    mouse.on_right_down:sub(function()
        local elem = game.ui.text_label:new(
            main_scene, game.asset_handler:get_font("karmatic_arcade", 24),
            nil, nil, nil, nil, layer,
            love.mouse.getX()/love.graphics.getWidth(),
            love.mouse.getY()/love.graphics.getHeight(),
            0.1, 0.1
        )
        elem:set_parent(main_scene)

        layer = layer + 1
    end)

    local bass = game.asset_handler.audios.sfx.bass
    mouse.on_left_down:sub(function ()
        bass:play()
    end)

    game.world_handler:load_map("test", main_scene)
    game.world.camera:to(-300, 220) -- figure out why it needs minus here it's just stupid bruh
    game.world.camera:zoom(3)
end