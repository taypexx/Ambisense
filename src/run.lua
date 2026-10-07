-- Main function of the game (outside of engine code)

local scene = require("engine.graphics.scenes.scene")
local scene_component = require("engine.graphics.scenes.scene_component")

return function()
    
    game.log("Game started.")

    local scene = scene:new("Main")

    game.mouse.on_left_down:sub(function()
        local component = scene_component:new(scene)
    end)

    game.mouse.on_right_down:sub(function()
        scene.components[#scene.components]:destroy()
    end)
end