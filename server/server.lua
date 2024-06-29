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

RegisterNetEvent("nx_dispatch:UpdateDispatchNotifyCounter", function (id)
    ---@type Notify
    local n = AllNotifies[id]
    n:updateCounter()
    n:updateReceivers()
end)

RegisterNetEvent("nx_dispatch:UpdateDispatchcNotifyState", function (id, state)
    local source    = source
    ---@type Notify
    local n         = AllNotifies[id]
    n.isNew         = state and state or false
    n:updateReceiver(source)
end)

RegisterNetEvent("nx_dispatch:UpdateDispatchNotifyPlayer", function (id)
    local source    = source
    ---@type Notify
    local n         = AllNotifies[id]
    n:removePlayer(source)
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


--- TODO: gps on jobs. Following client function for getting entity from ID
--- the server create a table with ["job"] = IDs
--- then send to whose that have the job an event
--- the client add the blip for the entity
--- each 1,5s server update all clients
--- CHECK: what happen if someone relog? or disconnect and riconnect ?
--- NETWORK_GET_ENTITY_FROM_NETWORK_ID
--- GetPlayerServerId(PlayerId()))

-- CreateThread(function ()
--     while true do

--         local allPlayers    = {}

--         for job, _ in pairs(Config.AllowedJobs) do

--             for _, playerId in pairs(GetPlayers()) do
--                 local xPlayer           = GetXPlayer(playerId)
--                 local xPlayerJobName    = GetPlayerJobName(xPlayer)

--                 if xPlayerJobName == job then
--                     table.insert(allPlayers[job], playerId)
--                 end

--             end
--         end
--         Wait(1500) -- 1 half seconds
--     end
-- end)


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