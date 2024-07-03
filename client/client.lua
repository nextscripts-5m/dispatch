MyDispatchList = DispatchList:new({})

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

--[[
    NUI Callbacks
]]

RegisterNUICallback("closeUI", function (data, cb)
    print(data.message)
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
RegisterKeyMapping('openDispatch', 'Open Dispatch List', 'keyboard', 'l')


--[[
    Test
    !DO NOT UNCOMMENT THIS!
]]

RegisterCommand("cc", function (source, args, raw)
    CreateDispatchNotify("Title 1", "Description", "police", GetEntityCoords(PlayerPedId()))
end)