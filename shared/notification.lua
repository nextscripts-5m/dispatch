---@class Notify
---@field id number
---@field title string
---@field time string
---@field description string
---@field jobName string
---@field peopleCounter number
---@field playersIDCounter table
---@field playersIDStates table
---@field gps vector3
---@field players table
---@field isNew boolean Client parameter. Server-side makes no sense
---@field isComing boolean Client parameter. Server-side makes no sense
local Notify = {}

---Dispatcher Notification Constructor
---@param id number
---@param title string
---@param time string
---@param description string
---@param jobName string
---@param peopleCounter number
---@param gps vector3
---@return Notify
function Notify:new(id, title, time, description, jobName, peopleCounter, gps)
    local o = {
        id                  = id,
        time                = time,
        title               = title,
        description         = description,
        jobName             = jobName,
        peopleCounter       = peopleCounter,
        playersIDCounter    = {},
        playersIDStates     = {},
        gps                 = gps,
        players             = {},
        isNew               = true,
        isComing            = false,
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

---Create a Notify Instance from a table
---@param data table
---@return Notify
function Notify:fromTable(data)
    local o = setmetatable(data, self)
    self.__index = self
    return o
end

---Check if a player is already has checked or not the state
---@param id any
---@return boolean
function Notify:hasPlayerChecked(id)
    for k, v in pairs(self.playersIDStates) do
        if v == id then
            return true
        end
    end
    return false
end

---Add a player "sign as read state" with given `id` for this dispatch
---@param id any
function Notify:addPlayerState(id)
    self.playersIDStates[id] = id
end

---Remove a player "sign as read state" with given `id` for this dispatch
---@param id any
function Notify:removePlayerState(id)
    self.playersIDStates[id] = nil
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
---@param amount number By how much increase or decrease the count
---@return number
function Notify:updateCounter(amount)
    local response      = MySQL.query.await("SELECT count FROM nx_dispatch WHERE id = ?", {self.id})
    local count         = tonumber(response[1].count) + amount
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