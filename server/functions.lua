JobIsAllowed = function (jobName)
    return Config.AllowedJobs[jobName] and true or false
end

--[[
    Utility
]]
---Get the ID of the last record inserted in the database
---@return number
GetLastId = function ()
    local response = MySQL.query.await("SELECT @@IDENTITY as 'count' FROM nx_dispatch")
    return tonumber(response[1].count) + 0
end
---Returns last available id in sql table
---@return number
GetLastAvailableId = function ()
    return GetLastId() + 1
end