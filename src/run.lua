-- Main function of the game (outside of engine code)

local scene = game.scenes.scene
local mouse = game.mouse

return function()
    
    game.log("Game started.")

    local main_scene = scene:new("Main")
    game.graphics_handler:switch_scene(main_scene)

    local layer = 1000

    mouse.on_right_down:sub(function()
        local elem = game.ui.text_label:new(
            main_scene, game.asset_handler:get_font("pixeloid_sans", 28),
            nil, nil, nil, nil, layer,
            love.mouse.getX()/love.graphics.getWidth(),
            love.mouse.getY()/love.graphics.getHeight(),
            0.1, 0.1
        )
        elem:set_parent(main_scene)

        layer = layer + 1
    end)
end