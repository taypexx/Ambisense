local toml = require("engine.substrate.tinytoml")
local crypto = game.crypto
local appdata = game.appdata
local utils = game.utils

local TAG = "SAVE"
local MAX_SAVE_TRIES = 5

---@class save
local save = {
    current = {},
    default = {
        lvl = 1,
        exp = 0,
        story_map = "test", -- Last map in the story mode
        inventory = {},
    }
}
save.__index = save
save.__newindex = utils.readonly_func({"default"})

--- Copies all key-value pairs of the table to the save.
---@param t table Table to copy key-value pairs from.
---@return boolean success True if save was loaded successfully, otherwise false. 
function save:apply(t)
    if type(t) ~= "table" then game.error("Couldn't copy key-value pairs from a table to save: table is wrong type or nil.") 
        return false
    end

    -- Applying the given save values
    for field,value in pairs(t) do
        local default_value = self.default[field]

        -- Check for unknown field
        if default_value ~= nil then
            -- Check for the correct value type
            if type(value) == type(default_value) then
                -- Values cleanup
                if field == "lvl" then
                    value = utils.clamp(value, 1)
                elseif field == "exp" then
                    value = utils.clamp(value, 0)
                end

                self.current[field] = value
            else
                game.log(string.format("\"%s\" field value type doesn't match. Setting to the default field value...", field), 1, TAG)
                self.current[field] = default_value
            end
        else
            game.log(string.format("Unknown field \"%s\" found in the save. Skipping...", field), 1, TAG)
        end
    end

    -- Adding skipped/missing categories/settings
    for field,default_value in pairs(self.default) do
        if self.current[field] == nil then
            game.log(string.format("Field \"%s\" is missing. Loading default value...", field), 1, TAG)
            self.current[field] = default_value
        end
    end

    return true
end

function save:load_empty()
    if not self:apply(self.default) then
        game.error("Couldn't load the empty save: Failed to apply save.", TAG)
        return false
    end

    game.log("Empty save was successfully loaded.", 0, TAG)
    return true
end

function save:load()
    local encrypted = appdata:get("save")

    -- File read check
    if not encrypted then 
        game.log("Couldn't load the save: save file not found. Loading empty...", 1, TAG)
        return self:load_empty()
    end

    -- Decrypt check
    local toml_string = crypto:decrypt(encrypted)
    if not toml_string then 
        game.log("Couldn't load the save: Failed to decrypt the file. Loading empty...", 1, TAG)
        return self:load_empty()
    end

    game.log(toml_string, 0, TAG)

    -- Parse check
    local parse_ok,result = pcall(toml.parse, toml_string, {load_from_string=true})
    if not parse_ok then
        game.log(string.format("Couldn't load the save: Parse error - %s. Loading empty...", result), 1, TAG)
        return self:load_empty()
    end

    -- Apply check
    if not self:apply(result) then
        game.log("Couldn't load the save: Failed to apply save. Loading empty...", 1, TAG)
        return self:load_empty()
    end

    game.log("Save was successfully loaded.", 0, TAG)
    return true
end

function save:save()
    local encode_ok,result = pcall(toml.encode, self.current)
    if not encode_ok then
        game.error(string.format("Failed to save progress: Couldn't encode save to TOML - %s", result), TAG)
        return false
    end

    local encrypted = crypto:encrypt(result)
    if not encrypted then
        game.error("Failed to save progress: Couldn't encrypt the save.", TAG)
        return false
    end

    local save_tries = 0
    local write_ok = false
    repeat
        save_tries = save_tries + 1
        game.log(string.format("Saving progress, attempt %i...", save_tries), 0, TAG)
        
        if save_tries > 1 then
            love.timer.sleep(1)
        end

        write_ok = appdata:set("save", encrypted)
    until write_ok or save_tries == MAX_SAVE_TRIES

    if not write_ok then
        game.error("Failed to save progress: Couldn't write to the save file.", TAG)
        return false
    end

    game.log("Progress was successfully saved.", 0, TAG)
    return true
end

return save