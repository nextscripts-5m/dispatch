Config = {}

--[[
    "esx" and "qb" are available
]]
Config.Framework = "esx"

-- "en" or "it" are now available
Config.Locales = "en"
Language = Lang[Config.Locales]

--- Jobs that can receive dispatch notification
Config.AllowedJobs = {
    ["police"] = {

    },
}