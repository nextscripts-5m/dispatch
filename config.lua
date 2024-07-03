Config = {}

--[[
    "esx" and "qb" are available
]]
Config.Framework = "esx"

-- "en" or "it" are now available
Config.Locales = "en"
Language = Lang[Config.Locales]

--[[
    "lib" : using ox_lib,
    "custom" : using the custom UI
]]
Config.UI = "custom"

--- Jobs that can receive dispatch notification
Config.AllowedJobs = {
    ["police"] = {

    },
}