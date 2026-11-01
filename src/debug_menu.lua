local camera = game.world.camera
local mouse = game.input.mouse
local keyboard = game.input.keyboard

local console = require("src.dev_console")

return function (init_scene)
    local coords = game.scene.ui.text_label:new(
        init_scene, game.asset_handler:get_font("pixeloid", 20),
        nil, nil, nil, nil, 9998,
        0,0,
        0.1, 0.1
    )
    coords:set_parent(init_scene)

    local mouse_coords = game.scene.ui.text_label:new(
        init_scene, game.asset_handler:get_font("pixeloid", 14),
        nil, nil, nil, nil, 9999,
        0,0,
        0.1, 0.1
    )
    mouse_coords:set_parent(init_scene)

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

        if mouse.current_component and mouse.current_component.object_id then
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

    console:create(init_scene)
    keyboard:get_key_event("`", true):sub(console.toggle, console)
end