---@class Blip
---@field id number
---@field entity number
---@field sprite number
---@field color number
---@field scale number
---@field jobName string
---@field blipName string
---@field coords vector3
local Blip = {}


---Blip Constructor with given coords, color and scale
---@param entity number
---@param jobName string
---@param blipName string
---@param coords vector3
---@param sprite number
---@param color number
---@param scale number
---@return Blip
function Blip:new(entity, jobName, blipName, coords, sprite, color, scale)
    local o = {
        id          = nil,
        entity      = entity,
        sprite      = sprite,
        color       = color,
        scale       = scale,
        jobName     = jobName,
        blipName    = blipName,
        coords      = coords,
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

---Create a blip for an entity or a coord if `self.entity` it's -1
function Blip:createBlip()

    ---@type number
    local blip

    if self.entity ~= -1 then
        blip            = AddBlipForEntity(self.entity)
    else
        blip            = AddBlipForCoord(self.coords.x, self.coords.y, self.coords.z)
    end

    self.id         = blip
    self:CustomizeBlip(blip)
end

---Remove a blip with given `entity` or its `self.id`
---@param entity? integer
function Blip:removeBlip(entity)
    if entity then
        RemoveBlip(GetBlipFromEntity(entity))
    else
        RemoveBlip(self.id)
    end
end

---Customize a Blip sprite, colour, scale and name
---@param blip number
function Blip:CustomizeBlip(blip)

    SetBlipSprite(blip, self.sprite)
    SetBlipColour(blip, self.color)
    SetBlipScale(blip, self.scale + 0.0)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(self.blipName)
    EndTextCommandSetBlipName(blip)
end

---Hide the blip on the legend
---@param toggle boolean
function Blip:setBlipHiddenOnLegend(toggle)
   SetBlipHiddenOnLegend(self.id, toggle)
end


_ENV.Blip = Blip


---TODO: lista di blip per gestire la rimozione di essi