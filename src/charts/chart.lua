local utils = game.utils
local appdata = game.appdata
local object = game.object
local chart_diff = game.charts.chart_diff
local bms = game.charts.bms

---@class chart:object
---@field uid integer Unique identifier of the chart.
---@field path string Path of the chart relative to assets/charts.
---@field name string Name of the chart.
---@field artist string Author of the chart's music.
---@field cover sprite Cover image of the chart.
---@field demo audio Preview audio of the chart.
---@field music audio Music of the chart to be played in game.
---@field difficulties table<integer,chart_diff> Dictionary of all chart difficulties where key is the difficulty index and value is the chart_diff.
local chart = {
    uid = nil,
    path = nil,
    name = nil,
    artist = nil,
    cover = nil,
    demo = nil,
    music = nil,
    difficulties = nil,
}
chart.__index = chart
chart.__newindex = utils.readonly_func({"name", "artist", "difficulties", "demo", "music"})

-- Inherits
setmetatable(chart, object)

local function get_audio(path, name)
    for _,ext in ipairs({"ogg", "wav", "mp3"}) do
        local audio_path = string.format("%s/%s.%s", path, name, ext)
        if love.filesystem.getInfo(audio_path) then
            return game.audio.audio:new(audio_path, false, nil, false, game.audio_manager.groups.music)
        end
    end
end
 
local function get_sprite(path, name)
    for _,ext in ipairs({"png", "jpg", "jpeg"}) do
        local cover_path = string.format("%s/%s.%s", path, name, ext)
        if love.filesystem.getInfo(cover_path) then
            return game.scene.assets.sprite:new_from_file(cover_path)
        end
    end
end

local function extract_zip(path, destination)
    -- Load ZIP from the game's filesystem.
    local zip_data, err = love.filesystem.newFileData(path)
    if not zip_data then game.error("Cannot extract zip: "..err) return false end

    -- Mount ZIP into a virtual directory.
    local mount_point = "__zip_temp"

    local success = love.filesystem.mount(zip_data, mount_point)
    if not success then return false, game.error("Cannot extract zip: Failed to mount ZIP archive")end

    -- Recursively copy files.
    local function copyDirectory(source, target)
        love.filesystem.createDirectory(target)

        for _, item in ipairs(love.filesystem.getDirectoryItems(source)) do
            local src = source.."/"..item
            local dst = target.."/"..item

            local info = love.filesystem.getInfo(src)

            if info.type == "directory" then
                copyDirectory(src, dst)
            elseif info.type == "file" then
                local data, readErr = love.filesystem.read(src)
                if not data then error(readErr) end

                local written, writeErr = love.filesystem.write(dst, data)
                if not written then error(writeErr) end
            end
        end
    end

    -- Extract everything.
    local ok, copyErr = pcall(copyDirectory, mount_point, destination)
    if not ok then game.error(copyErr) return false end

    return true
end

--- Creates a new chart.
---@param path string Path of the chart relative to assets/charts.
---@return chart|nil chart Newly created chart.
function chart:new(uid, path)
    if not uid then game.error("Cannot create a chart: uid was not provided.") return end
    if not path then game.error("Cannot create a chart: path was not provided.") return end

    if utils.ends_with(path, ".zip") then
        local file_name = utils.get_file_name(path)
        local dest_path = string.format("%s/%s", appdata.cache_path, file_name)

        local extract_success = extract_zip(path, dest_path)
        if not extract_success then 
            game.error(string.format("Couldn't load the chart \"%s\".", path))
            return
        end

        path = dest_path
    end

    -- Main BMS
    local main_bms_path = string.format("%s/1.bms", path)
    if not love.filesystem.getInfo(main_bms_path) then 
        game.error(string.format("Failed to load chart: %s. Main BMS file (1.bms) not found.", path))
        return
    end

    local main_bms_data = bms:parse(main_bms_path)
    if not main_bms_data then
        game.error(string.format("Failed to load chart: %s. Failed to parse main BMS file (1.bms).", path))
        return
    end

    -- Cover
    local cover = get_sprite(path, "cover")
    if not cover then
        game.error(string.format("Failed to load chart: %s. Cover file (cover.png) not found.", path))
        return
    end

    -- Music
    local music = get_audio(path, "music")
    if not music then
        game.error(string.format("Failed to load chart: %s. Music file (music.ogg/wav/mp3) not found.", path))
        return
    end

    -- Demo
    local demo = get_audio(path, "demo")
    if not demo then
        game.log(string.format("Demo file (demo.ogg/wav/mp3) not found for chart: %s.", path), 1)
    end

    local new = setmetatable(object:new(), self)
    new.uid = uid
    new.path = path
    new.name = main_bms_data.header.title or ("Chart_"..uid)
    new.artist = main_bms_data.header.artist or ("Unknown Artist")
    new.cover = cover
    new.demo = demo
    new.music = music
    new.difficulties = {[1] = chart_diff:new(new, main_bms_data)}

    for diff_i = 2, 5 do
        local bms_data = bms:parse(string.format("%s/%i.bms", path, diff_i))
        if bms_data then
            new.difficulties[diff_i] = chart_diff:new(new, bms_data)
        end
    end

    return new
end

function chart:destroy()
    if self.cover then
        self.cover:destroy()
    end
    if self.demo then
        self.demo:destroy()
    end
    if self.music then
        self.music:destroy()
    end
    for _, diff in pairs(self.difficulties) do
        if diff then
            diff:destroy()
        end
    end
    object.destroy(self)
end

return chart