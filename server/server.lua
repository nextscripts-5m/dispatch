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
AllNotifies         = {}
AllOnlinePlayers    = PlayerList:new({})

--[[
    Events
]]

RegisterNetEvent("nx_dispatch:CreateDispatchNotify", function (title, description, jobName, coords)
    local source    = source
    CreateDispatchNotify(title, description, jobName, coords, source)
end)

RegisterNetEvent("nx_dispatch:IncreaseDispatchNotifyCounter", function (id)
    local source    = source
    ---@type Notify
    local n         = AllNotifies[id]
    if n:isPlayerAlreadyComing(source) then return end
    n:addPlayerComing(source)
    n:updateCounter(1)
    n:updateReceivers()
end)

RegisterNetEvent("nx_dispatch:DecreaseDispatchNotifyCounter", function (id)
    local source    = source
    ---@type Notify
    local n         = AllNotifies[id]
    if not n:isPlayerAlreadyComing(source) then return end
    n:removePlayerComing(source)
    n:updateCounter(-1)
    n:updateReceivers()
end)

RegisterNetEvent("nx_dispatch:UpdateDispatchNotifyState", function (id, state)
    local source    = source
    ---@type Notify
    local n         = AllNotifies[id]
    if state then
        n:addPlayerState(source)
    else
        n:removePlayerState(source)
    end
    n:updateReceiver(source)
end)

RegisterNetEvent("nx_dispatch:UpdateDispatchNotifyPlayer", function (id)
    local source    = source
    ---@type Notify
    local n         = AllNotifies[id]
    n:removePlayer(source)
end)

RegisterNetEvent("nx_dispatch:UpdatePlayerGps", function (jobName, toggle)
    local source    = source
    local p = AllOnlinePlayers:getPlayer(source)
    if type(p) ~= "number" then
        p:toggleGps(toggle)
        AllOnlinePlayers.players[jobName][p.id] = p
        AllOnlinePlayers:sendPlayerList(jobName)
        -- print(json.encode(AllOnlinePlayers, {indent=true}))
    end
end)

RegisterNetEvent("nx_dispatch:AddPlayer", function (jobName)
    local source    = source
    local xPlayer   = GetXPlayer(source)
    local player    = PlayerInfo:new(tonumber(source) + 0, GetPlayerName(xPlayer), GetPlayerJobName(xPlayer))
    AllOnlinePlayers:addPlayer(jobName, player)
    AllOnlinePlayers:sendPlayerList(jobName)
end)

RegisterNetEvent("nx_dispatch:RemovePlayer", function (jobName)
    local source    = source
    AllOnlinePlayers:removePlayer(jobName, tonumber(source) + 0)
    AllOnlinePlayers:sendPlayerList(jobName)
    -- print(json.encode(AllOnlinePlayers, {indent=true}))
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

    local time  = os.date("*t")
    time        = ("%s:%s"):format(time.hour, time.min)
    
    local newNotify = Notify:new(id, title, time, description, jobName, 0, coords)
    newNotify:addPlayer(xPlayerSource)
    newNotify:sendDispatch()
    AllNotifies[newNotify.id] = newNotify
end
exports("CreateDispatchNotify", CreateDispatchNotify)


CreateThread(function ()
    while true do

        for job, _ in pairs(Config.AllowedJobs) do

            for _, playerId in pairs(GetPlayers()) do
                local xPlayer           = GetXPlayer(playerId)

                if xPlayer then
                    local xPlayerJobName    = GetPlayerJobName(xPlayer)

                    if xPlayerJobName == job then
                        local player = PlayerInfo:new(tonumber(playerId) + 0, GetPlayerName(xPlayer), xPlayerJobName)
                        AllOnlinePlayers:addPlayer(job, player)
                    end
                end
            end
            AllOnlinePlayers:sendPlayerList(job)
        end
        Wait(15000) -- 15 seconds
    end
end)


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