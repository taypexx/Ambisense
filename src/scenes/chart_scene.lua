local const = game.const
local utils = game.utils
local world_handler = game.world.handler
local scene_controller = game.scene_controller
local chart_manager = game.chart_manager
local battle_manager = game.battle_manager
local keyboard = game.input.keyboard
local settings = game.settings

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
---@field current_chart chart
---@field current_diff chart_diff
---@field update_handle event_handle
---@field accumulator number
---@field notes_queue table<integer, table<number, string>>
---@field notes table<note>
---@field long_end_flags table<integer,boolean>
---@field control_handle event_handle
---@field control_flags table<integer,boolean>
---@field map map
---@field elements table<string, ui_element>
local chart_scene = {
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

    map = nil,
    elements = {}
}
chart_scene.__index = chart_scene

-- Inherits
setmetatable(chart_scene, scene_controller)

function chart_scene:key_down(key)
    local controls = settings.current.controls

    for _,key_ in pairs(controls.left) do
        if key == key_ then
            self.control_flags[1] = true
            break
        end
    end

    for _,key_ in pairs(controls.up) do
        if key == key_ then
            self.control_flags[2] = true
            break
        end
    end

    for _,key_ in pairs(controls.right) do
        if key == key_ then
            self.control_flags[3] = true
            break
        end
    end

    for _,key_ in pairs(controls.down) do
        if key == key_ then
            self.control_flags[4] = true
            break
        end
    end
end

function chart_scene:key_up(key)
    local controls = settings.current.controls

    for _,key_ in pairs(controls.left) do
        if key == key_ then
            self.control_flags[1] = false
            break
        end
    end

    for _,key_ in pairs(controls.up) do
        if key == key_ then
            self.control_flags[2] = false
            break
        end
    end

    for _,key_ in pairs(controls.right) do
        if key == key_ then
            self.control_flags[3] = false
            break
        end
    end

    for _,key_ in pairs(controls.down) do
        if key == key_ then
            self.control_flags[4] = false
            break
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

    -- Loading battle
    battle_manager:reset_stats()

    -- Loading map
    self.map = world_handler:load_map("test", self.scene)

    -- Other
    require("src.debug_menu")(self.scene)
    self.key_down_handle = keyboard.on_key_down:sub(self.key_down, self)
    self.key_up_handle = keyboard.on_key_up:sub(self.key_up, self)

    self:play()
end

function chart_scene:unload()
    self.current_chart = nil
    self.current_diff = nil

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

    if self.map then
        self.map:unload()
        self.map = nil
    end
end

function chart_scene:init()
    self.elements = {
        info_frame = nil,
        cover_image = nil,
        info_text = nil,
        info_text2 = nil,

        combo_frame = nil,
        combo_text = nil,
        combo_count = nil,

        stats_frame = nil,
        stats_text = nil,
    }
end

function chart_scene:new()
    local new = setmetatable(scene_controller:new("chart"), self)
    new:init()

    return new
end

return chart_scene