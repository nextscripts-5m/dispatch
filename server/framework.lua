GetXPlayer = function (source)
    local source = tonumber(source)
    if Framework == "ESX" then
        return ESX.GetPlayerFromId(source)

    elseif Framework == "QB" then
        return QBCore.Functions.GetPlayer(source)
    end
end

ShowNotification = function (source, message, xPlayer)
    if Framework == "ESX" then
        xPlayer.showNotification(message)
    elseif Framework == "QB" then
        TriggerClientEvent('QBCore:Notify', source, message)
    end
end

GetIdentifier = function(xPlayer)
    if Framework == "ESX" then
       return xPlayer.getIdentifier()
    elseif Framework == "QB" then
        return xPlayer.PlayerData.license
    end
end

GetPlayerName = function (xPlayer)
    if Framework == "ESX" then
        return xPlayer.getName()
     elseif Framework == "QB" then
         return xPlayer.PlayerData.name
     end
end

GetPlayerJobName = function (xPlayer)
    if Framework == "ESX" then
        return xPlayer.getJob().name
    elseif Framework == "QB" then
        return xPlayer.PlayerData.job.name
    end
end

RegisterCallback = function(name, callback)
    if Framework == "ESX" then
        ESX.RegisterServerCallback(name, callback)
    elseif Framework == "QB" then
        QBCore.Functions.CreateCallback(name, callback)
    end
end