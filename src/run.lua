-- Main function of the game (outside of engine code)

return function()
    
    game.log("Game started.")

    game.on_update:sub_once(function()
        game.log("event fired!")
    end)

end