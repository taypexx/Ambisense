---@class graphics_handler
local graphics_handler = {
    last_id = 0,
    scenes = {},
    scenesByName = {}
}
graphics_handler.__index = graphics_handler

--- Registers a new scene.
--- For internal use only.
---@param scene scene Scene to register.
function graphics_handler:registerScene(scene)
    if scene.scene_id ~= nil then return end

    self.last_id = self.last_id + 1
    scene.scene_id = self.last_id

    self.scenes[scene.scene_id] = scene
    self.scenesByName[scene.name] = scene

    game.log("Registered a new scene, ID: "..scene.scene_id)
end

function graphics_handler:onDraw()
    love.graphics.print("Hello, LÖVE!", 100, 100)
end

return graphics_handler