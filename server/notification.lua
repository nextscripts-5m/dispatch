---@class Notify
---@field id number
---@field title string
---@field description string
---@field jobName string
---@field peopleCounter number
local Notify = {}

---Dispatcher Notification Constructor
---@param id number
---@param title string
---@param description string
---@param jobName string
---@param peopleCounter number
---@return Notify
function Notify:new(id, title, description, jobName, peopleCounter)
    local o = {
        id              = id,
        title           = title,
        description     = description,
        jobName         = jobName,
        peopleCounter   = peopleCounter,
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

---Update the counter and returns the new counter
---@return number
function Notify:updateCounter()
    local response      = MySQL.query.await("SELECT count FROM nx_dispatch WHERE id = ?", {self.id})
    local count         = tonumber(response[1].count) + 1
    self.peopleCounter  = count
    response            = MySQL.update.await("UPDATE nx_dispatch SET count = ? WHERE id = ?", {count, self.id})
    print("Affected rows: " .. response and response or "ERROR")
    return (response > 0) and count or -1
end

---Send the dispatch notification to all online players that have Notify.jobName job
function Notify:sendDispatch()
    for _, playerId in ipairs(GetPlayers()) do
        local xPlayer           = GetXPlayer(playerId)
        local xPlayerJobName    = GetPlayerJobName(xPlayer)
        if xPlayerJobName == self.jobName then
            --- TODO: create event for creating UI
            TriggerClientEvent("", tonumber(playerId) + 0)
        end
    end
end


_ENV.Notify = Notify