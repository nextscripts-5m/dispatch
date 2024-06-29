---@class Notify
---@field id number
---@field title string
---@field description string
---@field jobName string
---@field peopleCounter number
---@field gps vector4
---@field players table
local Notify = {}

---Dispatcher Notification Constructor
---@param id number
---@param title string
---@param description string
---@param jobName string
---@param peopleCounter number
---@param gps vector3
---@return Notify
function Notify:new(id, title, description, jobName, peopleCounter, gps)
    local o = {
        id              = id,
        title           = title,
        description     = description,
        jobName         = jobName,
        peopleCounter   = peopleCounter,
        gps             = gps,
        players         = {}
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

---Update the counter and returns the new counter
---This is a SERVER FUNCTION
---@return number
function Notify:updateCounter()
    local response      = MySQL.query.await("SELECT count FROM nx_dispatch WHERE id = ?", {self.id})
    local count         = tonumber(response[1].count) + 1
    self.peopleCounter  = count
    response            = MySQL.update.await("UPDATE nx_dispatch SET count = ? WHERE id = ?", {count, self.id})
    print("Affected rows: " .. (response and response or "ERROR"))
    return (response > 0) and count or -1
end

function Notify:updateReceivers()
    for k, v in pairs(self.players) do
        TriggerClientEvent("nx_dispatch:updateDispatch", k, self)
    end
end

---Add a player to this dispatch notification
---@param id number
function Notify:addPlayer(id)
    self.players[id] = id
end

---Remove a player from this dispatch notification
---@param id number
function Notify:removePlayer(id)
    self.players[id] = nil
end

--- Send the dispatch notification to all online players that have Notify.jobName job.
--- This is a SERVER FUNCTION.
function Notify:sendDispatch()
    for _, playerId in ipairs(GetPlayers()) do
        local xPlayer           = GetXPlayer(playerId)
        local xPlayerJobName    = GetPlayerJobName(xPlayer)
        if xPlayerJobName == self.jobName then
            TriggerClientEvent("nx_dispatch:SendDispatchNotification", tonumber(playerId) + 0, self)
        end
    end
end


_ENV.Notify = Notify