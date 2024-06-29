---@class DispatchList
---@field notifications table
local DispatchList = {}

---Dispatch List Constructor
---@param notifications table `Notify` list
---@return DispatchList
function DispatchList:new(notifications)
    local o = {
        notifications = notifications
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

---Get the dispatch notification with the given `id`
---@param id number
---@return Notify
function DispatchList:getNotification(id)
    return self.notifications[id]
end

---Add a new notification
---@param notification Notify
function DispatchList:addNotification(notification)
    self.notifications[notification.id] = notification
end

---comment
---@param id number
function DispatchList:removeNotification(id)
    self.notifications[id] = nil
end


_ENV.DispatchList = DispatchList