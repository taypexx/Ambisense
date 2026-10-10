local utils = game.utils

local MODES = {"static","follow"}

---@class camera
---@field x integer X coordinate of the camera center in the world space.
---@field y integer Y coordinate of the camera center in the world space.
---@field scale number Zoom of the camera where 1 - normal state (100% zoom).
---@field mode string Camera mode. "static" - stays at the same coordiates. "follow" - follows the world component. Works as static if the target is nil.
---@field target map_component|nil Target component to follow. Will not affect the camera if the mode is set to "static".
local camera = {
    x = 0,
    y = 0,
    scale = 1,
    mode = "static",
    target = nil
}
camera.__index = camera

--- Sets the camera position to the given coordinates. Camera must be in "static" mode.
---@param x integer X coordinate of the camera center in the world space.
---@param y integer Y coordinate of the camera center in the world space.
function camera:to(x,y)
    if self.mode ~= "static" then return end

    -- TODO: do smooth camera teleport with easing functions (add an option as a parameter)
    self.x = x
    self.y = y
end

--- Zooms the camera
---@param zoom number Zoom of the camera where 1 - normal state (100% zoom).
function camera:zoom(zoom)
    if not zoom then game.error("Cannot zoom camera: zoom was not provided.") return end

    -- TODO: do smooth camera zoom with easing functions (add an option as a parameter)
    self.scale = zoom
end

--- Updates the camera.
---@param dt number Time since last update in seconds.
function camera:update(dt)
    if self.mode == "follow" and self.target then
        self.x = self.target.x
        self.y = self.target.y
    end
end

--- Sets the camera mode.
---@param mode string Camera mode. "static" - stays at the same coordiates. "follow" - follows the world component. Works as static if the target is nil.
function camera:set_mode(mode)
    if not utils.table_find(MODES, mode) then game.error("Cannot set the camera mode: Unknown camera mode.") return end
    self.mode = mode
end

return camera