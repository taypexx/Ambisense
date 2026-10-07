local path = arg[1]
local const = dofile(path.."/src/const.lua")

local variables = {
    GameName = const.name,
    GamePackageName = string.format("com.taypexx.%s",const.name),
    GameVersionCode = string.gsub(const.game_version, "%.", ""),
    GameVersionSemantic = const.game_version,
}

local templateFile = io.open(path.."/build/manifest/AndroidManifest.template.xml", "r")
if not templateFile then return end

local manifest = templateFile:read("*a")
templateFile:close()

for k,v in pairs(variables) do
    manifest = string.gsub(manifest, string.format("${%s}", k), v)
end

local newFile = io.open(path.."/build/manifest/AndroidManifest.xml", "w")
if not newFile then return end

newFile:write(manifest)
newFile:close()