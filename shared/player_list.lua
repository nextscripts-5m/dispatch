---@class PlayerList
---@field players table
local PlayerList = {}

---Player List constructor. It contains online players for `jobName` job
---@param players table `jobName` : {`id`: `PlayerInfo`} dict
---@return PlayerList
function PlayerList:new(players)
    local o = {
        players = players
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

---Add a player to a `jobName` key
---@param jobName string
---@param player PlayerInfo
function PlayerList:addPlayer(jobName, player)
    -- self.players[jobName][player.id] = player
    if not self.players[jobName] then
        self.players[jobName]               = {}
    end

    if not self.players[jobName][player.id] then
        self.players[jobName][player.id]    = player
    end
end

---Remove the player with the given id from `jobName`
---@param jobName string
---@param id any
function PlayerList:removePlayer(jobName, id)
    self.players[jobName][id] = nil
end

---Get the online player with the given `playerID` id. It must be already registered from the server in the `players` table.
---@param playerID any
---@return PlayerInfo | number player Return a `PlayerInfo` objects, -1 if it's not found.
function PlayerList:getPlayer(playerID)
    for job, v in pairs(self.players) do
        for id, player in pairs(v) do
            if id == playerID then
                ---@type PlayerInfo
                player = player
                return player
            end
        end
    end
    return -1
end

---Send `players` to all online players with given `jobName`
---@param jobName any
function PlayerList:sendPlayerList(jobName)
    local players = self.players[jobName]

    for id, player in pairs(players) do
        TriggerClientEvent("nx_dispatch:sendPlayerList", id, players)
    end
end

_ENV.PlayerList = PlayerList