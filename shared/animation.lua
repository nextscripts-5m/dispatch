---@class Animation
---@field ped integer
---@field dict string
---@field anim string
---@field duration number
---@field flag number
---@field stop boolean
local Animation = {}

---Animation constructor
---@param ped number
---@param dict string
---@param anim string
---@param duration number
---@param flag number
---@return Animation
function Animation:new(ped, dict, anim, duration, flag)
    local o = {
        ped         = ped,
        dict        = dict,
        anim        = anim,
        duration    = duration,
        flag        = flag,
        stop        = false
    }
    setmetatable(o, self)
    self.__index = self
    CreateThread(function ()
        lib.requestAnimDict(dict)
    end)
    return o
end

---Starts the animation
function Animation:startAnimation()
    self.stop = false
    TaskPlayAnim(self.ped, self.dict, self.anim, 3.0, 3.0, self.duration, self.flag, 0, false, false, false)
end

---Stops the animation
function Animation:stopAnimation()
    self.stop    = true
    ClearPedSecondaryTask(self.ped)
end

---Attach a prop to an `self.ped` entity
---@param prop string
---@param boneIndex number
---@param offset vector3
---@param rotation vector3
function Animation:AttachPropToEntity(prop, boneIndex, offset, rotation)
    CreateThread(function ()

        lib.requestModel(prop)
        local obj   = CreateObject(prop, 0, 0, 0, true, true, false)
        local index = GetPedBoneIndex(self.ped, boneIndex)

        AttachEntityToEntity(obj, self.ped, index, offset.x, offset.y, offset.z, rotation.x, rotation.y, rotation.z, true, false, false, false, 2, true)
        SetModelAsNoLongerNeeded(prop)

        while true do
            if self.stop then
                DetachEntity(obj, true, false)
                DeleteEntity(obj)
                break
            end
            Wait(500)
        end
    end)
end

_ENV.Animation = Animation