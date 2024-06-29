if Config.Framework == "esx" then
    Framework = "ESX"
    ESX = exports["es_extended"]:getSharedObject()
elseif Config.Framework == "qb" then
    Framework = "QB"
    QBCore = exports['qb-core']:GetCoreObject()
else
    print("Unsopported Framework")
    return
end

--- Contains all notifies
AllNotifies = {}

--[[
    Events
]]

RegisterNetEvent("nx_dispatch:CreateDispatchNotify", function (title, description, jobName, coords)
    local source    = source
    CreateDispatchNotify(title, description, jobName, coords, source)
end)

RegisterNetEvent("nx_dispatch:UpdateDispatchNotify", function (id)
    ---@type Notify
    local n = AllNotifies[id]
    n:updateCounter()
    n:updateReceivers()
end)

--[[]]

---Create the dispatch notification (Server)
---@param title string Dispatch Title
---@param description string Dispatch description
---@param jobName string Receiver job
---@param coords vector3 Gps coords
---@param xPlayerSource any Sender Player's source
CreateDispatchNotify = function (title, description, jobName, coords, xPlayerSource)

    if not JobIsAllowed(jobName) then
        print(("Job '%s' can't receive dispatch notification"):format(jobName))
        return
    end

    local xPlayer           = GetXPlayer(xPlayerSource)
    local xPlayerIdentifier = GetIdentifier(xPlayer)
    local id = MySQL.insert.await("INSERT nx_dispatch (title, job_name, description, sender) VALUES (?, ?, ?, ?)", {
        title, jobName, description, xPlayerIdentifier
    })

    local newNotify = Notify:new(id, title, description, jobName, 0, coords)
    newNotify:addPlayer(xPlayerSource)
    newNotify:sendDispatch()
    AllNotifies[newNotify.id] = newNotify
end
exports("CreateDispatchNotify", CreateDispatchNotify)


--- TODO: create a method for deleting old dispatches (check all database records ID with curret AllNotifies ID)
--- TODO: gps on jobs


--[[
    Testing
    !DO NOT UNCOMMENT THIS!
]]

-- print(JobIsAllowed("police"))

-- local n = Notify:new(1, "title", "description", "cardealer", 0)
-- AllNotifies[n.id] = n
-- print(json.encode(AllNotifies[1]))

-- local id = MySQL.insert.await("INSERT nx_dispatch (title, job_name, description, sender) VALUES (?, ?, ?, ?)", {
--     "title", "jobName", "description", "xPlayerIdentifier"
-- })
-- local newNotify = Notify:new(id, "title", "description", "jobName", 0)
-- print(json.encode(newNotify, {indent = true}))