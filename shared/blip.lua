---@class Blip
---@field entity number
---@field jobName string
---@field blipName string
local Blip = {}

---Blip Constructor
---@param entity number
---@param jobName string
---@param blipName string
---@return Blip
function Blip:new(entity, jobName, blipName)
    local o = {
        entity      = entity,
        jobName     = jobName,
        blipName    = blipName,
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

function Blip:createBlip()
    local blip      = AddBlipForEntity(self.entity)
    local config    = Config.AllowedJobs[self.jobName].Blip
    --- TODO: add some default values if these are not provided
    SetBlipColour(blip, config.color)
    SetBlipScale(blip, config.scale)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(self.blipName)
    EndTextCommandSetBlipName(blip)
end

function Blip:removeBlip(entity)
    RemoveBlip(GetBlipFromEntity(entity))
end


_ENV.Blip = Blip