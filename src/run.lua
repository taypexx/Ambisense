-- Main function of the game (outside of engine code)

local scene = game.scenes.scene
local mouse = game.mouse

return function()
    
    game.log("Game started.")

    local main_scene = scene:new("Main")
    game.graphics_handler:switch_scene(main_scene)

    local layer = 1000

    mouse.on_right_down:sub(function()
        local elem = game.ui.ui_element:new(
            main_scene, layer,
            mouse:getX() / love.graphics.getPixelWidth(), 
            mouse:getY() / love.graphics.getPixelHeight(),
            0.2,0.2
        )
        elem:set_parent(main_scene)

        

        layer = layer + 1
    end)
end