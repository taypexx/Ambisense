local object = game.types.object

---@class scene
---@field scene_id integer Unique ID of the scene.
---@field name string Unique name of the scene.
---@field components table<integer,table<scene_component>> A dictionary with keys set as layers and values set as tables containing scene components.
local scene = {
    scene_id = nil,
    name = nil,
    components = nil
}
scene.__index = scene
scene.__newindex = game.utils.get_readonly_func({"scene_id", "name"})

-- Inherits
setmetatable(scene, object)

--- Adds a scene component to the scene.
--- For internal use only.
---@param component scene_component Scene component to add.
function scene:add_component(component)
    local layer_table = self.components[component.layer]
    if layer_table then
        if game.utils.table_find(layer_table, component) then 
            game.error(string.format("Cannot add scene component to the %s (scene_id: %i): Component is already present on the scene.", self.name, self.scene_id))
            return
        end
        table.insert(layer_table, component)
    else
        self.components[component.layer] = {component}
    end
end

--- Removes the scene component from the scene.
--- For internal use only.
---@param component scene_component Scene component to remove.
function scene:remove_component(component)
    local layer_table = self.components[component.layer]
    local i = game.utils.table_find(layer_table, component)
    if not (layer_table and i) then 
        game.error(string.format("Cannot remove scene component from the %s (scene_id: %i): Component is not present on the scene.", self.name, self.scene_id))
        return
    end
    table.remove(layer_table, i)
end

--- Creates a new scene.
---@param name string|nil Name of the scene.
---@return scene|nil
function scene:new(name)
    if game.graphics_handler.scenesByName[name] then
        game.error("Cannot create new scene: Scene with the same name already exists!")
        return
    end

    local new = setmetatable(object:new(), self)
    new.name = name or "scene"
    new.components = {}
    
    game.graphics_handler:register_scene(new)
    return new
end

return scene