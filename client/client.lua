MyDispatchList = DispatchList:new({})

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
end)


---@param dispatchNotification Notify
RegisterNetEvent("nx_dispatch:updateDispatch", function (dispatchNotification)
    MyDispatchList.notifications[dispatchNotification.id] = dispatchNotification
end)

--[[
    Commands
]]

RegisterCommand("openDispatch", function (source, args, raw)
    local contextID = RegisterContext(MyDispatchList.notifications)
    lib.showContext(contextID)
end)
RegisterKeyMapping('openDispatch', 'Open Dispatch List', 'keyboard', 'l')

--[[
    Test
    !DO NOT UNCOMMENT THIS!
]]

RegisterCommand("cc", function (source, args, raw)
    CreateDispatchNotify("Title 1", "Description", "police", GetEntityCoords(PlayerPedId()))
end)
