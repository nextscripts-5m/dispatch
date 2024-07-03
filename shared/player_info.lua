---@class PlayerInfo
---@field id number
---@field name string
---@field jobName string
---@field isGpsActive boolean
local PlayerInfo = {}

---Player Info Constructor
---@param id number
---@param name string
---@param jobName string
---@return PlayerInfo
function PlayerInfo:new(id, name, jobName)
    local o = {
        id          = id,
        name        = name,
        jobName     = jobName,
        isGpsActive = false
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

---Set `isGpsActive` with the given value
---@param toggle boolean
---@return boolean toggle `true` if its active, else `false`
function PlayerInfo:toggleGps(toggle)
    self.isGpsActive = toggle
    return toggle
end

_ENV.PlayerInfo = PlayerInfo