local function hasPermission(src, allowedJobs)
    local job = nil
    if Framework == 'QBCore' then
        local Player = QBCore.Functions.GetPlayer(src)
        job = Player and Player.PlayerData.job.name or nil
    elseif Framework == 'ESX' then
        local xPlayer = ESX.GetPlayerFromId(src)
        job = xPlayer and xPlayer.job.name or nil
    end
    for _, allowed in ipairs(allowedJobs) do
        if job == allowed then return true end
    end
    return false
end

local function standardResponse(success, data, errorMsg)
    if success then
        return { success = true, data = data }
    else
        return { success = false, error = errorMsg or "Unknown error" }
    end
end

RegisterNUICallback("mdt:getCases", function(data, cb)
    exports.oxmysql:execute("SELECT * FROM cases", {}, function(result)
        cb(standardResponse(true, result or {}))
    end)
end)

RegisterNUICallback("mdt:getEvidence", function(data, cb)
    local src = source
    if hasPermission(src, Config.PoliceJobs) or hasPermission(src, Config.AdminJobs) then
        exports.oxmysql:execute("SELECT * FROM evidence WHERE case_id IS NOT NULL", {}, function(result)
            cb(standardResponse(true, result or {}))
        end)
    else
        cb(standardResponse(false, nil, "Unauthorized"))
    end
end)

RegisterNUICallback("mdt:getWitnesses", function(data, cb)
    local src = source
    if hasPermission(src, Config.JudgeJobs) or hasPermission(src, Config.AdminJobs) then
        exports.oxmysql:execute("SELECT * FROM witness_statements WHERE case_id IS NOT NULL", {}, function(result)
            cb(standardResponse(true, result or {}))
        end)
    else
        cb(standardResponse(false, nil, "Unauthorized"))
    end
end)

RegisterNUICallback("mdt:getScenarios", function(data, cb)
    exports.oxmysql:execute("SELECT * FROM scenarios WHERE case_id IS NOT NULL", {}, function(result)
        cb(standardResponse(true, result or {}))
    end)
end)