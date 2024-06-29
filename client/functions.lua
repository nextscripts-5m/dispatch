RegisterContext = function (dispatchNotifications)

    local elements = {}

    ---TODO: submenu for GO and DELETE
    ---TODO: add new and old notification icon

    for k, v in pairs(dispatchNotifications) do
        ---@type Notify
        local notify = v

        table.insert(elements, {
            title       = notify.title,
            description = notify.description,
            metadata = {
                {label = Language["dispatch-people"], value = notify.peopleCounter},
            },
            onSelect = function()
                SetNewWaypoint(notify.gps.x, notify.gps.y)
                TriggerServerEvent("nx_dispatch:UpdateDispatchNotify", notify.id)
            end,
        })
    end

    lib.registerContext({
        id      = "dispatch_menu",
        title   = Language["dispatch-title"],
        options = elements
    })
    return "dispatch_menu"
end