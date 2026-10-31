-- Main function of the game (outside of engine code)

--[[

    Current structute idea:

    Scenes:
    Loading screen
    Title screen scene
    Prologue
    Chart selection/home scene + map
    Lore/novel scene + maps (different scenes)
    Chart gameplay scene + maps (different scenes)

    
    Gameplay:
    enemies come from left, top, right and bottom
    When they are coming from bottom, the animation is shielding
    Enemies can be hold notes (they will have different texture and attack for longer)
]]

game.scene_manager = require("src.managers.scene_manager")
game.chart_manager = require("src.managers.chart_manager")

game.enemies = {}
game.enemies.enemy = require("src.charts.enemies.enemy")
game.enemies.basic1_enemy = require("src.charts.enemies.basic1_enemy")

game.charts = {}
game.charts.chart = require("src.charts.chart")
game.charts.chart_diff = require("src.charts.chart_diff")
game.charts.enemy_map = require("src.charts.enemy_map")

game.scene_controller = require("src.scenes.scene_controller")

return function()
    game.log("Game started.")

    -- Initialization
    game.scene_manager:init()
    game.chart_manager:load_charts()

    -- Entry point
    game.scene_manager:switch("chart", "Vicious Heroism")
end