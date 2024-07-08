RegisterContext = function (dispatchNotifications)

    local elements = {}

    for k, v in pairs(dispatchNotifications) do
        ---@type Notify
        local notify = v

        lib.registerContext({
            id      = ("notify_%s"):format(notify.id),
            title   = notify.title,
            menu    = "dispatch_menu",
            options = {
                notify.isComing and {
                    title       = Language["leave"],
                    icon        = "fa-solid fa-location-dot",
                    metadata    = {
                        {label = Language["dispatch-people"], value = notify.peopleCounter},
                    },
                    onSelect    = function()
                        DeleteWaypoint()
                        TriggerServerEvent("nx_dispatch:DecreaseDispatchNotifyCounter", notify.id)
                    end
                } or
                {
                    title       = Language["go"],
                    icon        = "fa-solid fa-location-dot",
                    metadata    = {
                        {label = Language["dispatch-people"], value = notify.peopleCounter},
                    },
                    onSelect    = function()
                        SetNewWaypoint(notify.gps.x, notify.gps.y)
                        TriggerServerEvent("nx_dispatch:IncreaseDispatchNotifyCounter", notify.id)
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
                        TriggerServerEvent("nx_dispatch:UpdateDispatchNotifyState", notify.id, not notify.isNew)
                    end
                }
            }
        })


        table.insert(elements, {
            title       = notify.title,
            description = notify.description,
            menu        = ("notify_%s"):format(notify.id),
            icon        = (notify.isNew and "fa-regular fa-circle" or "fa-regular fa-circle-check"),
            metadata    = {
                {label = Language["dispatch-people"], value = notify.peopleCounter},
                {label = Language["dispatch-time"], value = notify.time},
            },
        })
    end

    lib.registerContext({
        id      = "dispatch_menu",
        title   = Language["dispatch-title"],
        options = elements
    })
    return "dispatch_menu"
end