---Contains client dispatches
MyDispatchList          = DispatchList:new({})
DispatchBlipList        = BlipList:new({})
local configuration     = false
local myGPS             = false
TabletAnimation   = Animation:new(
    PlayerPedId(),
    "amb@code_human_in_bus_passenger_idles@female@tablet@base",
    "base",
    -1,
    49
)

PlayerLoaded = function ()
    TriggerServerEvent("nx_dispatch:AddPlayer", GetJobFramework())
end

PlayerLogout = function ()
    TriggerServerEvent("nx_dispatch:RemovePlayer", GetJobFramework())
    myGPS   = false
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
            TriggerServerEvent("nx_dispatch:UpdatePlayerGps", lastJob.name, false)
            Blip:removeBlip(PlayerPedId())
            TriggerServerEvent("nx_dispatch:RemovePlayer", lastJob.name)
            DispatchBlipList:removeAllDispatchBlips()
            MyDispatchList = DispatchList:new({})
            myGPS = false
        end
    end)

elseif Config.Framework == "qb" then
    Framework = "QB"
    QBCore = exports['qb-core']:GetCoreObject()

    RegisterNetEvent("QBCore:Client:OnPlayerLoaded", PlayerLoaded)
    RegisterNetEvent("QBCore:Client:OnPlayerUnload", PlayerLogout)

    local lastJob = QBCore.Functions.GetPlayerData().job.name

    RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
        local newJob = val.job.name
        if newJob ~= lastJob then
            TriggerServerEvent("nx_dispatch:UpdatePlayerGps", lastJob, false)
            Blip:removeBlip(PlayerPedId())
            TriggerServerEvent("nx_dispatch:RemovePlayer", lastJob)
            DispatchBlipList:removeAllDispatchBlips()
            MyDispatchList = DispatchList:new({})
        end
        lastJob = newJob
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

RegisterNetEvent("onClientResourceStart", function (resource)
    if resource == GetCurrentResourceName() then
        TabletAnimation:stopAnimation()
    end
end)

---@param dispatchNotification Notify
RegisterNetEvent("nx_dispatch:SendDispatchNotification", function (dispatchNotification)
    ShowNotification(Language["new-dispatch"])

    MyDispatchList:addNotification(dispatchNotification)
    SendNUIMessage({
        update = true,
        notification = dispatchNotification
    })

    local config    = Config.AllowedJobs[dispatchNotification.jobName].DispatchBlip
    local waveBlip  = Blip:new(-1, dispatchNotification.jobName, "Wave", dispatchNotification.gps, 161, config.color, 1)
    waveBlip:createBlip()
    waveBlip:setBlipHiddenOnLegend(true)

    local blip      = Blip:new(-1, dispatchNotification.jobName, dispatchNotification.title, dispatchNotification.gps, config.sprite, config.color, config.scale)
    blip:createBlip()

    DispatchBlipList:addDispatchBlip(waveBlip, dispatchNotification.id)
    DispatchBlipList:addDispatchBlip(blip, dispatchNotification.id)

end)

---@param dispatchNotification Notify
RegisterNetEvent("nx_dispatch:updateDispatch", function (dispatchNotification)
    local myID                      = GetPlayerServerId(PlayerId())
    dispatchNotification            = Notify:fromTable(dispatchNotification)
    dispatchNotification.isComing   = dispatchNotification:isPlayerAlreadyComing(myID)
    dispatchNotification.isNew      = (not dispatchNotification:hasPlayerChecked(myID))
    MyDispatchList.notifications[dispatchNotification.id] = dispatchNotification
    -- print(json.encode(MyDispatchList.notifications, {indent=true}))
end)


---Get the list of online players with my job
---@param players PlayerList
RegisterNetEvent("nx_dispatch:sendPlayerList", function (players)
    local myID  = GetPlayerServerId(PlayerId())
    for id, player in pairs(players) do
        ---@type PlayerInfo
        player          = player
        local playerId  = GetPlayerFromServerId(player.id)
        local entity    = GetPlayerPed(playerId)

        if player.isGpsActive then
            if GetBlipFromEntity(entity) == 0 then
                local name      = (myID == player.id) and Language["me"] or player.name
                local config    = Config.AllowedJobs[player.jobName].PlayerBlip
                local blip      = Blip:new(entity, player.jobName, name, vector3(0, 0, 0), config.sprite, config.color, config.scale)
                blip:createBlip()
            end
        else
            Blip:removeBlip(entity)
        end
    end
end)

--[[
    NUI Callbacks
]]

RegisterNUICallback("closeUI", function (data, cb)
    -- print(data.message)
    SetNuiFocus(false, false)
    TabletAnimation:stopAnimation()
end)

RegisterNUICallback("updateState", function (data, cb)
    TriggerServerEvent("nx_dispatch:UpdateDispatchNotifyState", data.id, data.state)
end)

RegisterNUICallback("setGps", function (data, cb)
    SetNewWaypoint(data.x, data.y)
    TriggerServerEvent("nx_dispatch:IncreaseDispatchNotifyCounter", data.id)
end)

RegisterNUICallback("leftDispatch", function (data, cb)
    DeleteWaypoint()
    TriggerServerEvent("nx_dispatch:DecreaseDispatchNotifyCounter", data.id)
end)

RegisterNUICallback("removeDispatch", function (data, cb)
    DeleteWaypoint()
    MyDispatchList:removeNotification(data.id)
    DispatchBlipList:removeDispatchBlip(data.id)
    TriggerServerEvent("nx_dispatch:UpdateDispatchNotifyPlayer", data.id)
end)

RegisterNUICallback("updatePlayerGps", function (data, cb)
    TriggerServerEvent("nx_dispatch:UpdatePlayerGps", GetJobFramework(), data.toggle)
    myGPS = data.toggle
end)

--[[
    Commands
]]


RegisterCommand("openDispatch", function (source, args, raw)

    if not Config.AllowedJobs[GetJobFramework()] then return end

    if Config.UI == "lib" then
        local contextID = RegisterContext(MyDispatchList.notifications)
        lib.showContext(contextID)
    end

    if Config.UI == "custom" then

        if not configuration then
            configuration = true
            SendNUIMessage({
                Language = {
                    RESOURCE_NAME               = GetCurrentResourceName(),
                    APP_BAR_TITLE               = Config.DispatchTitle,
                    LABEL_GO                    = Language["go"],
                    LABEL_LEAVE                 = Language["leave"],
                    LABEL_DELETE                = Language["delete-tooltip"],
                    LABEL_TOOLTIP_CHECK_READ    = Language["already-seen"],
                    LABEL_TOOLTIP_CHECK_UNREAD  = Language["not-seen"],
                    LABEL_ACTIVATE_GPS          = Language["activate"],
                    LABEL_DEACTIVATE_GPS        = Language["deactivate"],
                    THEME_COLOR                 = Config.Theme,
                }
            })
        end

        SendNUIMessage({
            show        = true,
            dispatches  = MyDispatchList:toList(),
            myGPS       = myGPS
        })

        SetNuiFocus(true, true)
        SetNuiFocusKeepInput(Config.MoveWhileOpen)
    end

    if GetPedInVehicleSeat(GetVehiclePedIsIn(PlayerPedId(), false), -1) == PlayerPedId() then return end
    TabletAnimation:AttachPropToEntity(`prop_cs_tablet`, 60309, vector3(0.03, 0.002, -0.0), vector3(10.0, 160.0, 0.0))
    TabletAnimation:startAnimation()
end)
RegisterKeyMapping('openDispatch', 'Open Dispatch List', 'keyboard', Config.OpenDispatch)

RegisterCommand("+gpson", function (source, args, raw)
    if not Config.AllowedJobs[GetJobFramework()] then return end
    print(GetJobFramework())
    TriggerServerEvent("nx_dispatch:UpdatePlayerGps", GetJobFramework(), true)
    myGPS = true
end)

RegisterCommand("+gpsoff", function ()
    if not Config.AllowedJobs[GetJobFramework()] then return end
    TriggerServerEvent("nx_dispatch:UpdatePlayerGps", GetJobFramework(), false)
    Blip:removeBlip(PlayerPedId())
    myGPS = false
end)

--[[
    Threads
]]

local delay = 100

CreateThread(function ()
    if Config.SendDispatchOnFire then
        while true do
            if IsPedShooting(PlayerPedId()) then
                if GetJobFramework() ~= "police" then
                    print("creating")
                    CreateDispatchNotify("Shooting", "Gunshots have been detected in this area!", "police", GetEntityCoords(PlayerPedId()))
                    Wait(30 * 1000)
                end
            end
            Wait(delay)
        end
    end
end)

--[[
    Test
    !DO NOT UNCOMMENT THIS!
]]

-- RegisterCommand("cc", function (source, args, raw)
--     CreateDispatchNotify("Robbery", "A robbery is in progress at number 667", "police", GetEntityCoords(PlayerPedId()))
-- end)

-- RegisterCommand("nn", function (source, args, raw)
--     ShowNotification(Language["new-dispatch"])
-- end)