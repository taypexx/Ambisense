---@class battle_manager
local battle_manager = {
    combo = 0,
    score = 0,
}
battle_manager.__index = battle_manager

function battle_manager:reset_stats()
    self.combo = 0
    self.score = 0
end

return battle_manager