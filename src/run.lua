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

        elem.on_mouse_enter:sub_once(function ()
            game.log("Mouse enter "..elem.object_id)
        end)
        elem.on_mouse_leave:sub_once(function ()
            game.log("Mouse leave "..elem.object_id)
        end)
        elem.on_mouse_down:sub(function ()
            game.log("Mouse down "..elem.object_id)
        end)
        elem.on_mouse_up:sub(function ()
            game.log("Mouse up "..elem.object_id)
        end)

        layer = layer + 1
    end)
end