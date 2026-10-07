local appdata = {}
appdata.__index = appdata

function appdata.init()
    print(love.filesystem.getAppdataDirectory())
end

return appdata