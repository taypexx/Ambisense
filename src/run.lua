-- Main function of the game (outside of engine code)

local scene = require("engine.graphics.scenes.scene")
local scene_component = require("engine.graphics.scenes.scene_component")

return function()
    
    game.log("Game started.")

    local scene = scene:new("Main")

    game.mouse.on_left_down:sub(function()
        if game.mouse.current_cursor.name == "default" then
            game.mouse:set_cursor("test")
        else
            game.mouse:set_cursor("default")
        end
    end)

    game.mouse.on_right_down:sub(function()
        game.mouse.cursor_visible = not game.mouse.cursor_visible
    end)
end