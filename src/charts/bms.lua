local const = game.const
local utils = game.utils

---@class bms
local bms = {}
bms.__index = bms

--- Parses the given BMS data into a table.
---@param path string Path to the BMS file.
---@return bms_data|nil bms_data Parsed BMS data or nil if parsing failed.
function bms:parse(path)
    local header = {}
    local main = {}
    local header_section = nil
    if not love.filesystem.getInfo(path) then return end
    
    for line in love.filesystem.lines(path) do
        if not utils.is_empty(line) then
            if utils.starts_with(line, "*---------------------- HEADER FIELD") then
                header_section = true
            elseif utils.starts_with(line, "*---------------------- MAIN DATA FIELD") then
                header_section = false
            elseif utils.starts_with(line, "#") then
                -- Parsing header
                if header_section == true then
                    local key, value = line:match("#(%S+)%s+(.*)")
                    key = key:lower()

                    if not utils.starts_with(key, "wav") then
                        local num = tonumber(value)
                        if num then
                            header[key] = num
                        else
                            header[key] = value
                        end 
                    end
                -- Parsing main data
                elseif header_section == false then
                    local measure, line_id, data = line:match("(%d%d%d)(%d%d):(.*)")
                    measure = tonumber(measure)
                    line_id = tonumber(line_id)
                    if measure and (line_id and const.bms_lines[line_id]) and data then
                        if not main[measure] then
                            main[measure] = {}
                        end
                        if not main[measure][line_id] then
                            main[measure][line_id] = {}
                        end
                        for i = 1, #data, 2 do
                            local note = data:sub(i, i+1)
                            if note == "00" then
                                table.insert(main[measure][line_id], false)
                            else
                                table.insert(main[measure][line_id], note)
                            end
                        end
                    end
                end
            end
        end
    end

    return game.charts.bms_data:new(header, main)
end

return bms