---Create the dispatch notification (Client)
---@param title string Dispatch Title
---@param description string Dispatch description
---@param jobName string Receiver job
CreateDispatchNotify = function (title, description, jobName)
    TriggerServerEvent("nx_dispatch:CreateDispatchNotify", title, description, jobName)
end
exports("CreateDispatchNotify", CreateDispatchNotify)


--- TODO: register event for creating UI