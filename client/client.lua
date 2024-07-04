MyDispatchList = DispatchList:new({})

PlayerLoaded = function ()
    TriggerServerEvent("nx_dispatch:AddPlayer", GetJobFramework())
end

PlayerLogout = function ()
    TriggerServerEvent("nx_dispatch:RemovePlayer", GetJobFramework())
end

if Config.Framework == "esx" then
    Framework = "ESX"
    ESX = exports["es_extended"]:getSharedObject()

    RegisterNetEvent("esx:playerLoaded", function (xPlayer, isNew, skin)
        ESX.PlayerData = xPlayer
        PlayerLoaded()
    end)

    RegisterNetEvent("esx:onPlayerLogout", PlayerLogout)

    RegisterNetEvent("esx:setJob", function (newJob, lastJob)
        ESX.PlayerData.job = newJob
        if newJob.name ~= lastJob.name then
            Blip:removeBlip(PlayerPedId())
            TriggerServerEvent("nx_dispatch:RemovePlayer", lastJob.name)
        end
    end)

elseif Config.Framework == "qb" then
    Framework = "QB"
    QBCore = exports['qb-core']:GetCoreObject()

    RegisterNetEvent("QBCore:Client:OnPlayerLoaded", PlayerLoaded)
    RegisterNetEvent("QBCore:Client:OnPlayerUnload", PlayerLogout)

    RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
        local newJob = val.job.name
        local lastJob = PlayerData.job.name
        print(newJob, lastJob)
        if newJob ~= lastJob then
            Blip:removeBlip(PlayerPedId())
            TriggerServerEvent("nx_dispatch:RemovePlayer", lastJob.name)
        end
        PlayerData = val
        -- print(QBCore.Debug(PlayerData))
    end)
else
    print("Unsopported Framework")
    return
end

---Create the dispatch notification (Client)
---@param title string Dispatch Title
---@param description string Dispatch description
---@param jobName string Receiver job
---@param coords vector3 Gps Coords
CreateDispatchNotify = function (title, description, jobName, coords)
    TriggerServerEvent("nx_dispatch:CreateDispatchNotify", title, description, jobName, coords)
end
exports("CreateDispatchNotify", CreateDispatchNotify)


--[[
    Events
]]

---@param dispatchNotification Notify
RegisterNetEvent("nx_dispatch:SendDispatchNotification", function (dispatchNotification)
    ShowNotification(Language["new-dispatch"])
    MyDispatchList:addNotification(dispatchNotification)
    SendNUIMessage({
        update = true,
        notification = dispatchNotification
    })
end)

---@param dispatchNotification Notify
RegisterNetEvent("nx_dispatch:updateDispatch", function (dispatchNotification)
    MyDispatchList.notifications[dispatchNotification.id] = dispatchNotification
end)


---Get the list of online players with my job
---@param players PlayerList
RegisterNetEvent("nx_dispatch:sendPlayerList", function (players)
    local myID  = GetPlayerServerId(PlayerId())
    for id, player in pairs(players) do
        ---@type PlayerInfo
        player = player

        if player.isGpsActive then
            local playerId = GetPlayerFromServerId(player.id)
            local entity    = GetPlayerPed(playerId)

            if GetBlipFromEntity(entity) == 0 then
                local name      = (myID == player.id) and Language["me"] or player.name
                local blip      = Blip:new(entity, player.jobName, name)
                blip:createBlip()
            end
        end
    end
end)

--[[
    NUI Callbacks
]]

RegisterNUICallback("closeUI", function (data, cb)
    -- print(data.message)
    SetNuiFocus(false, false)
end)

RegisterNUICallback("updateState", function (data, cb)
    TriggerServerEvent("nx_dispatch:UpdateDispatchcNotifyState", data.id, data.state)
end)

RegisterNUICallback("setGps", function (data, cb)
    SetNewWaypoint(data.x, data.y)
    TriggerServerEvent("nx_dispatch:UpdateDispatchNotifyCounter", data.id)
end)

RegisterNUICallback("removeDispatch", function (data, cb)
    MyDispatchList:removeNotification(data.id)
    TriggerServerEvent("nx_dispatch:UpdateDispatchNotifyPlayer", data.id)
end)

--[[
    Commands
]]

RegisterCommand("openDispatch", function (source, args, raw)

    if Config.UI == "lib" then
        local contextID = RegisterContext(MyDispatchList.notifications)
        lib.showContext(contextID)
    end

    if Config.UI == "custom" then
        SendNUIMessage({
            show = true,
            dispatches = MyDispatchList,
        })
        SetNuiFocus(true, true)
    end
end)
RegisterKeyMapping('openDispatch', 'Open Dispatch List', 'keyboard', Config.OpenDispatch)

RegisterCommand("+gpson", function (source, args, raw)
    TriggerServerEvent("nx_dispatch:UpdatePlayerGps", GetJobFramework(), true)
end)

RegisterCommand("+gpsoff", function ()
    TriggerServerEvent("nx_dispatch:UpdatePlayerGps", GetJobFramework(), false)
    Blip:removeBlip(PlayerPedId())
end)

--[[
    Test
    !DO NOT UNCOMMENT THIS!
]]

-- RegisterCommand("cc", function (source, args, raw)
--     CreateDispatchNotify("Title 1", "Description", "police", GetEntityCoords(PlayerPedId()))
-- end)