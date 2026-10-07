-- Main function of the game (outside of engine code)

return function()
    
    game.log("Game started.")

    game.mouse.on_wheel_move:sub(function(y)
        game.log(string.format("Mouse scroll: %i", y))
    end)
end