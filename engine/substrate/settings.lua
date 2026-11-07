local toml = require("engine.substrate.tinytoml")
local appdata = game.appdata
local utils = game.utils
local keyboard = game.input.keyboard

local TAG = "SETTINGS"
local MAX_SAVE_TRIES = 5
local WINDOW_TYPES = {"windowed", "borderless", "fullscreen"}
local MSAA_SAMPLES = {2, 4, 8}

---@class settings
local settings = {
    current = {},
    default = {
        offset = 0,

        -- Volumes are within the range 0 ~ 100.
        audio = {
            music_volume = 50,
            sfx_volume = 50,
            voice_volume = 50,
            hitsounds_volume = 50,
            directional_hitsounds = true
        },

        -- Some video settings are exclusive to specific OS'es.
        video = {
            window_width = 1280, -- Ignored with fullscreen
            window_height = 720, -- Ignored with fullscreen
            window_type = "windowed", -- Allowed values in WINDOW_TYPES
            vsync = false, -- Always true on IOS
            msaa = false,
            msaa_samples = 0, -- Allowed values in MSAA_SAMPLES
        },

        -- Desktop only. Controls exactly match their scancodes. More info: https://www.love2d.org/wiki/Scancode.
        controls = {
            proceed = {"return"}, -- Any action that requires confirmation
            back = {"escape", "backspace"}, -- Any action that requires confirmation, also used for opening the pause menu
            up = {"up", "w"},
            left = {"left", "a"},
            down = {"down", "s"},
            right = {"right", "d"},
        },
    }
}
settings.__index = settings
settings.__newindex = utils.readonly_func({"default"})

--- Copies all key-value pairs of the table to the settings. Also removes unused settings on different os'es.
---@param t table Table to copy key-value pairs from.
---@return boolean success True if settings were applied successfully, otherwise false. 
function settings:apply(t)
    if type(t) ~= "table" then game.error("Couldn't copy key-value pairs from a table to settings: table is wrong type or nil.") 
        return false
    end
 
    -- Applying the given settings
    for cat,values in pairs(t) do
        local default_values = self.default[cat]

        -- Check for unknown category
        if default_values ~= nil then
            local values_type = type(values)
            -- Check for the correct value type
            if values_type == type(default_values) then
                -- Fields/values cleanup
                if values_type == "table" then
                    for setting_name,value in pairs(values) do
                        -- Remove unknown fields from the provided category values
                        local default_value = default_values[setting_name]
                        if default_value ~= nil then
                            -- Check for the correct value type of the setting
                            if type(value) == type(default_value) then
                                -- Setting specific clamping
                                if cat == "audio" and string.sub(setting_name, -6, -1) == "volume" then
                                    -- Volume
                                    value = utils.clamp(value, 0, 100)
                                elseif cat == "video" then
                                    -- Window type
                                    if setting_name == "window_type" then
                                        local mobile_window_type = WINDOW_TYPES[3]
                                        -- If current OS is mobile and the window type is not supported on mobile 
                                        if game.current_os == "Android" or game.current_os == "iOS" and value ~= mobile_window_type then
                                            game.log(string.format("\"%s\" window type not supported on %s. Setting to \"%s\"...", value, game.current_os, mobile_window_type), 1, TAG)
                                            value = mobile_window_type
                                        -- If window type is not recognized
                                        elseif not utils.table_find(WINDOW_TYPES, value) then
                                            local lower_window_type = string.lower(value)
                                            if utils.table_find(WINDOW_TYPES, lower_window_type) then
                                                value = lower_window_type
                                            else
                                                local default_window_type = WINDOW_TYPES[1]
                                                game.log(string.format("Unknown window_type \"%s\". Setting to \"%s\"...", value, default_window_type), 1, TAG)
                                                value = default_window_type
                                            end
                                        end
                                    -- V-sync
                                    elseif setting_name == "vsync" and game.current_os == "iOS" then
                                        game.log("V-sync cannot be turned off on iOS. Setting to true...", 1, TAG)
                                        value = true
                                    -- MSAA samples
                                    elseif setting_name == "msaa_samples" and values.msaa and not utils.table_find(MSAA_SAMPLES, value) then
                                        local default_msaa_samples = MSAA_SAMPLES[1]
                                        game.log(string.format("Invalid MSAA samples count: %s. Setting to %s...", value, default_msaa_samples), 1, TAG)
                                        value = default_msaa_samples
                                    end
                                elseif cat == "controls" then
                                    -- Check for every control in the table
                                    for scancode_i,scancode in pairs(value) do
                                        local scancode_exist = keyboard:is_valid(scancode)
                                        if not scancode_exist then
                                            game.log(string.format("Unknown control \"%s\" detected for the \"%s\" action. Removing it from controls...", scancode, setting_name), 1, TAG)
                                            table.remove(value, scancode_i)
                                        end
                                    end

                                    -- Set default controls if no controls present
                                    if #value == 0 then
                                        game.log(string.format("Action \"%s\" doesn't have controls. Setting to default...", setting_name), 1, TAG)
                                        value = default_value
                                    end
                                end

                                -- Applying changed value
                                values[setting_name] = value
                            else
                                game.log(string.format("\"%s\" setting value type in \"%s\" category is incorrect. Setting the default value...", setting_name, cat), 1, TAG)
                                values[setting_name] = default_value
                            end
                        else
                            game.log(string.format("\"%s\" setting does not exist in \"%s\" category. Skipping...", setting_name, cat), 1, TAG)
                            values[setting_name] = nil
                        end
                    end
                end

                self.current[cat] = values
            else
                game.log(string.format("\"%s\" category value type doesn't match. Setting to the default category values...", cat), 1, TAG)
                self.current[cat] = default_values
            end
        else
            game.log(string.format("Unknown category \"%s\" found in the settings. Skipping...", cat), 1, TAG)
        end
    end

    -- Adding skipped/missing categories/settings
    for cat,default_values in pairs(self.default) do
        if self.current[cat] ~= nil then
            if type(default_values) == "table" then
                for setting_name,default_value in pairs(default_values) do
                    if self.current[cat][setting_name] == nil then
                        game.log(string.format("Setting \"%s\" in the \"%s\" category is missing. Setting to the default value...", setting_name, cat), 1, TAG)
                        self.current[cat][setting_name] = default_value
                    end
                end
            end
        else
            game.log(string.format("Category \"%s\" is missing. Loading default values for this category...", cat), 1, TAG)
            self.current[cat] = default_values
        end
    end

    -- Applying
    local video = self.current.video
    love.window.setMode(video.window_width, video.window_height, {
        fullscreen = video.window_type == "fullscreen",
        borderless = video.window_type == "borderless",
        vsync = video.vsync and 1 or 0,
        msaa = video.msaa_samples
    })

    return true
end

--- Loads default settings.
---@return boolean success True if loaded successfully, otherwise false.
function settings:load_default()
    if not self:apply(self.default) then
        game.error("Couldn't load the default settings: Failed to apply settings. Now we are screwed.", TAG)
        return false
    end

    game.log("Default settings were successfully loaded.", 0, TAG)
    return true
end

--- Loads the settings from the file in appdata.
---@return boolean success True if loaded successfully, otherwise false.
function settings:load()
    local toml_string = appdata:get("settings")

    -- File read check
    if not toml_string then 
        game.log("Couldn't load the settings: settings file not found. Loading default...", 1, TAG)
        return self:load_default()
    end

    game.log(toml_string, 0, TAG)

    -- Parse check
    local parse_ok,result = pcall(toml.parse, toml_string, {load_from_string=true})
    if not parse_ok then
        game.log(string.format("Couldn't load the settings: Parse error - %s. Loading default...", result), 1, TAG)
        return self:load_default()
    end

    -- Apply check
    if not self:apply(result) then
        game.log("Couldn't load the settings: Failed to apply settings. Loading default...", 1, TAG)
        return self:load_default()
    end

    game.log("Settings were successfully loaded.", 0, TAG)
    return true
end

--- Saves the settings to the file in appdata.
---@return boolean success True if saved successfully, otherwise false.
function settings:save()
    local encode_ok,result = pcall(toml.encode, self.current)
    if not encode_ok then
        game.error(string.format("Failed to save settings: Couldn't encode settings to TOML - %s", result), TAG)
        return false
    end

    local save_tries = 0
    local write_ok = false
    repeat
        save_tries = save_tries + 1
        game.log(string.format("Saving settings, attempt %i...", save_tries), 0, TAG)
        
        if save_tries > 1 then
            love.timer.sleep(1)
        end

        write_ok = appdata:set("settings", result)
    until write_ok or save_tries == MAX_SAVE_TRIES

    if not write_ok then
        game.error("Failed to save settings: Couldn't write to the settings file.", TAG)
        return false
    end

    game.log("Settings were successfully saved.", 0, TAG)
    return true
end

return settings