RegisterContext = function (dispatchNotifications)

    local elements = {}

    --- TODO: the counter updates only once for player. DO NOT spam GO

    for k, v in pairs(dispatchNotifications) do
        ---@type Notify
        local notify = v

        lib.registerContext({
            id      = ("notify_%s"):format(notify.id),
            title   = notify.title,
            menu    = "dispatch_menu",
            options = {
                {
                    title       = Language["go"],
                    icon        = "fa-solid fa-location-dot",
                    metadata    = {
                        {label = Language["dispatch-people"], value = notify.peopleCounter},
                    },
                    onSelect    = function()
                        SetNewWaypoint(notify.gps.x, notify.gps.y)
                        TriggerServerEvent("nx_dispatch:UpdateDispatchNotifyCounter", notify.id)
                    end
                },
                {
                    title   = Language["delete"],
                    icon    = "fa-solid fa-trash-can",
                    onSelect = function ()
                        MyDispatchList:removeNotification(notify.id)
                        TriggerServerEvent("nx_dispatch:UpdateDispatchNotifyPlayer", notify.id)
                    end
                },
                {
                    title   = notify.isNew and Language["already-seen"] or Language["not-seen"],
                    icon    = "fa-solid fa-map-pin",
                    onSelect = function ()
                        TriggerServerEvent("nx_dispatch:UpdateDispatchcNotifyState", notify.id, not notify.isNew)
                    end
                }
            }
        })

        table.insert(elements, {
            title       = notify.title,
            description = notify.description,
            menu        = ("notify_%s"):format(notify.id),
            icon        = notify.isNew and "fa-regular fa-circle" or "fa-regular fa-circle-check"
        })
    end

    lib.registerContext({
        id      = "dispatch_menu",
        title   = Language["dispatch-title"],
        options = elements
    })
    return "dispatch_menu"
end