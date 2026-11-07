local const = game.const
local utils = game.utils
local world_handler = game.world.handler
local scene_controller = game.scene_controller
local chart_manager = game.chart_manager
local battle_manager = game.battle_manager
local keyboard = game.input.keyboard
local settings = game.settings
local camera = game.world.camera

local NOTE_CLASSES = {
    ["basic1"] = require("src.charts.notes.enemies.basic.basic1"),
    ["basic2"] = require("src.charts.notes.enemies.basic.basic2"),
    ["normal1"] = require("src.charts.notes.enemies.normal.normal1"),
    ["normal2"] = require("src.charts.notes.enemies.normal.normal2"),
    ["heavy1"] = require("src.charts.notes.enemies.heavy.heavy1"),
    ["heavy2"] = require("src.charts.notes.enemies.heavy.heavy2"),
    ["special"] = require("src.charts.notes.enemies.special"),
    ["heal"] = require("src.charts.notes.enemies.heal"),
    ["boss1"] = require("src.charts.notes.enemies.boss.boss1"),
    ["boss2"] = require("src.charts.notes.enemies.boss.boss2"),
    ["boss3"] = require("src.charts.notes.enemies.boss.boss3"),
    ["boss4"] = require("src.charts.notes.enemies.boss.boss4"),
    ["boss_special"] = require("src.charts.notes.enemies.boss.boss_special"),
    ["vignette_start"] = require("src.charts.notes.vignette.vignette_start"),
    ["vignette_max"] = require("src.charts.notes.vignette.vignette_max"),
    ["vignette_end"] = require("src.charts.notes.vignette.vignette_end"),
    ["speed1"] = require("src.charts.notes.speed.speed1"),
    ["speed2"] = require("src.charts.notes.speed.speed2"),
    ["speed3"] = require("src.charts.notes.speed.speed3"),
    ["speed4"] = require("src.charts.notes.speed.speed4"),
}

---@class chart_scene:scene_controller
---@field ui chart_ui
---@field map map
---@field current_chart chart
---@field current_diff chart_diff
---@field update_handle event_handle
---@field accumulator number
---@field notes_queue table<integer, table<number, string>>
---@field notes table<note>
---@field long_end_flags table<integer,boolean>
---@field control_handle event_handle
---@field control_flags table<integer,boolean>
local chart_scene = {
    map = nil,

    current_chart = nil,
    current_diff = nil,
    
    update_handle = nil,
    accumulator = 0,

    notes_queue = nil,
    notes = {},
    long_end_flags = {},
    
    key_down_handle = nil,
    key_up_handle = nil,
    control_flags = {},
}
chart_scene.__index = chart_scene

-- Inherits
setmetatable(chart_scene, scene_controller)

function chart_scene:key_down(key)
    for flag,dir in ipairs(const.directions) do
        for _,key_ in pairs(settings.current.controls[dir]) do
            if key == key_ then
                self.control_flags[flag] = true
                break
            end
        end
    end
end

function chart_scene:key_up(key)
    for flag,dir in ipairs(const.directions) do
        for _,key_ in pairs(settings.current.controls[dir]) do
            if key == key_ then
                self.control_flags[flag] = false
                break
            end
        end
    end
end

function chart_scene:update(dt)
    self.accumulator = self.accumulator + dt

    -- Add new notes
    for line_id, notes in pairs(self.notes_queue) do
        for timestamp, note_id in pairs(notes) do
            if note_id then
                local note_name = const.note_ids[note_id]
                if note_name then
                    local note_class = NOTE_CLASSES[note_name]
                    if note_class then
                        if timestamp + settings.current.offset - note_class.duration <= self.accumulator then
                            local line = const.bms_lines[line_id]
                            local is_long = line_id > 50

                            -- Flip the long flag
                            if is_long then
                                if self.long_end_flags[line_id] ~= nil then
                                    self.long_end_flags[line_id] = not self.long_end_flags[line_id]
                                else
                                    self.long_end_flags[line_id] = false
                                end
                            end

                            -- Create a new note
                            local note = note_class:new(line, is_long, self.long_end_flags[line_id])
                            notes[timestamp] = nil
                            table.insert(self.notes, note)

                            game.log("Added note "..note_name)
                        end 
                    end
                end
            end
        end
    end

    -- Update/destroy existing notes
    for i,note in pairs(self.notes) do
        if note then
            if note.left > -note.duration then
                note:update(dt)

                if not note.was_hit and (
                    (note.auto_hit and note.left <= 0)
                    or
                    (self.control_flags[note.line] and math.abs(note.left) <= const.hit_radius)
                ) then
                    self.control_flags[note.line] = false
                    note:hit()
                end
            else
                table.remove(self.notes, i)
                note:destroy()
            end
        end
    end
end

function chart_scene:play()
    self.current_chart.music:play(true)

    -- Makes sure the update accumulation starts on the next update
    self.accumulator = -1
    game.on_update:sub_once(function ()
        self.accumulator = self.accumulator + 1
    end)

    self.update_handle = game.on_update:sub(self.update, self)
end

function chart_scene:load(chart_key, diff_i)
    -- Loading chart data
    local chart = chart_manager:get(chart_key)
    if not chart then
        game.error(string.format("Failed to load the chart scene: chart \"%s\" not found.", chart_key))
        return
    end

    local diff = chart.difficulties[diff_i]
    if not diff then
        game.error(string.format("Failed to load the chart scene: difficulty %i of the chart \"%s\" not found.", diff_i, chart_key))
        return
    end

    self.current_chart = chart
    self.current_diff = diff
    self.notes_queue = utils.table_copy(diff.note_map.notes)

    -- Loading map
    self.map = world_handler:load_map("test", self.scene)
    camera:to(0, -50)
    camera:zoom(1.5)

    -- Loading battle
    battle_manager:reset_stats()

    -- Loading UI
    self.ui:load()

    -- Other
    self.key_down_handle = keyboard.on_key_down:sub(self.key_down, self)
    self.key_up_handle = keyboard.on_key_up:sub(self.key_up, self)

    self:play()
end

function chart_scene:unload()
    self.current_chart = nil
    self.current_diff = nil

    if self.map then
        self.map:unload()
        self.map = nil
    end

    if self.update_handle then
        self.update_handle:destroy()
    end
    self.accumulator = 0

    self.notes_queue = nil
    self.notes = {}
    self.long_end_flags = {}

    if self.key_down_handle then
        self.key_down_handle:destroy()
    end
    if self.key_up_handle then
        self.key_up_handle:destroy()
    end
end

function chart_scene:init()
    self.ui:init()
end

function chart_scene:new()
    local new = setmetatable(scene_controller:new("chart"), self)
    return new
end

return chart_scene