---@class Notify
---@field id number
---@field title string
---@field description string
---@field jobName string
---@field peopleCounter number
---@field playersIDCounter table
---@field gps vector4
---@field players table
---@field isNew boolean
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
        id                  = id,
        title               = title,
        description         = description,
        jobName             = jobName,
        peopleCounter       = peopleCounter,
        playersIDCounter    = {},
        gps                 = gps,
        players             = {},
        isNew               = true
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

---Check if a player is already coming for that notification
---@param id any
---@return boolean
function Notify:isPlayerAlreadyComing(id)
    for k, v in pairs(self.playersIDCounter) do
        if v == id then
            return true
        end
    end
    return false
end

---Add a player to players coming for dispatch
---@param id any
function Notify:addPlayerComing(id)
    self.playersIDCounter[id] = id
end

---Remove a player from player coming for dispatch
---@param id any
function Notify:removePlayerComing(id)
    self.playersIDCounter[id] = nil
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

---Update player with given `id`
---@param id any
function Notify:updateReceiver(id)
    TriggerClientEvent("nx_dispatch:updateDispatch", id, self)
end

---Update dispatch received by all `self.players`
function Notify:updateReceivers()
    for k, v in pairs(self.players) do
        self:updateReceiver(k)
    end
end

---Add a player to this dispatch notification
---@param id any
function Notify:addPlayer(id)
    self.players[id] = id
end

---Remove a player from this dispatch notification
---@param id any
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