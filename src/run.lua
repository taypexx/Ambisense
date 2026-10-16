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
local camera = game.world.camera
local mouse = game.mouse
local keyboard = game.keyboard

local main_scene = scene:new("Main")

local function init_debug_menu()
    local coords = game.ui.text_label:new(
        main_scene, game.asset_handler:get_font("pixeloid_sans", 20),
        nil, nil, nil, nil, 1000,
        0,0,
        0.1, 0.1
    )
    coords:set_parent(main_scene)

    local mouse_coords = game.ui.text_label:new(
        main_scene, game.asset_handler:get_font("pixeloid_sans", 14),
        nil, nil, nil, nil, 1001,
        0,0,
        0.1, 0.1
    )
    mouse_coords:set_parent(main_scene)

    local camera_speed = 100
    local camera_zoom = 0.1

    game.on_update:sub(function (dt)
        local cam_dx, cam_dy = 0,0
        if keyboard:is_pressed("w") then
            cam_dy = cam_dy - camera_speed
        end
        if keyboard:is_pressed("s") then
            cam_dy = cam_dy + camera_speed
        end
        if keyboard:is_pressed("a") then
            cam_dx = cam_dx - camera_speed
        end
        if keyboard:is_pressed("d") then
            cam_dx = cam_dx + camera_speed
        end
        camera:to(camera.x + cam_dx*dt, camera.y + cam_dy*dt)

        coords.text = string.format("x: %i | y: %i | scale: %.2f", camera.x, camera.y, camera.scale)

        local x,y = mouse:get_pos()
        local wx,wy = mouse:get_world_pos()
        mouse_coords.text = string.format("screen x: %i | screen y: %i | x: %i | y: %i", x, y, wx, wy)
        mouse_coords:set_position(x + mouse.current_cursor.sprite.width, y + mouse.current_cursor.sprite.height)

        if mouse.current_component then
            mouse_coords.text = mouse_coords.text.." | object_ID: "..mouse.current_component.object_id
        end
    end)

    mouse.on_wheel_move:sub(function (y)
        if y > 0 then
            camera:zoom(camera.scale + camera_zoom)
        elseif y < 0 then
            camera:zoom(camera.scale - camera_zoom)
        end
    end)
end

return function()
    
    game.log("Game started.")

    game.graphics_handler:switch_scene(main_scene)

    local music = game.asset_handler.audios.music.frozen_sky
    --music:play()

    game.world_handler:load_map("test", main_scene)

    init_debug_menu()

    mouse.on_left_down:sub(function ()
        local wx, wy = game.mouse:get_world_pos()
        local comp = game.world.map_component:new(
            main_scene, 500,
            wx, wy, 50, 50
        )
    end)

    mouse.on_right_down:sub(function()
        if game.graphics_handler.currentScene then
            game.graphics_handler:switch_scene() 
        else
             game.graphics_handler:switch_scene(main_scene)
        end
    end)
end