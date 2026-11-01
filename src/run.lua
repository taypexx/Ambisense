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

game.charts = {}
game.notes = {}

game.scene_manager = require("src.managers.scene_manager")
game.chart_manager = require("src.managers.chart_manager")
game.audio_manager = require("src.managers.audio_manager")
game.battle_manager = require("src.managers.battle_manager")

game.charts.bms = require("src.charts.bms")
game.charts.bms_data = require("src.charts.bms_data")
game.charts.note_map = require("src.charts.note_map")
game.charts.chart_diff = require("src.charts.chart_diff")
game.charts.chart = require("src.charts.chart")

game.notes.note = require("src.charts.notes.note")
game.notes.enemy = require("src.charts.notes.enemies.enemy")
game.notes.speed = require("src.charts.notes.speed.speed")

game.scene_controller = require("src.scenes.scene_controller")

return function()
    game.log("Game started.")

    -- Initialization
    game.audio_manager:init()
    game.scene_manager:init()
    game.chart_manager:load_charts()

    -- Entry point
    game.scene_manager:switch("chart", 1, 1)
end