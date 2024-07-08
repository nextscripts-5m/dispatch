---@class BlipList
---@field blips table
local BlipList = {}

---BlipList Constructor
---@param blips table
---@return BlipList
function BlipList:new(blips)
    local o = {
        blips   = blips,
    }
    setmetatable(o, self)
    self.__index = self
    return o
end


---Add a dispatch blip
---@param blip Blip
---@param dispatchID number
function BlipList:addDispatchBlip(blip, dispatchID)
    if not self.blips[dispatchID] then
        self.blips[dispatchID]          = {}
    end
    if not self.blips[dispatchID][blip.id] then
        self.blips[dispatchID][blip.id] = blip
    end
end

---Remove a dispatch blip
---@param dispatchID number
function BlipList:removeDispatchBlip(dispatchID)
    for blipID, blip in pairs(self.blips[dispatchID]) do
        ---@type Blip
        blip = blip
        blip:removeBlip()
    end
    self.blips[dispatchID] = nil
end

---Remove all Dispatch Blips
function BlipList:removeAllDispatchBlips()
    for id, v in pairs(self.blips) do
        self:removeDispatchBlip(id)
    end
end


_ENV.BlipList = BlipList