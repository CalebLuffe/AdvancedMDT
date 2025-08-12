-- Expanded Evidence Collection Server Script

RegisterNetEvent('advanced:CollectEvidence')
AddEventHandler('advanced:CollectEvidence', function(evidenceType, coords, caseId, description)
    local src = source
    local identifier = GetPlayerIdentifier(src)
    local evidenceId = ('%s_%d'):format(evidenceType, os.time())
    exports.oxmysql:execute(
        "INSERT INTO evidence (id, type, coords, case_id, collected_by, description, timestamp) VALUES (@id, @type, @coords, @case_id, @collected_by, @description, @timestamp)",
        {
            ['@id'] = evidenceId,
            ['@type'] = evidenceType,
            ['@coords'] = json.encode(coords),
            ['@case_id'] = caseId,
            ['@collected_by'] = identifier,
            ['@description'] = description,
            ['@timestamp'] = os.time()
        }
    )
    TriggerClientEvent('QBCore:Notify', src, 'Evidence collected: ' .. evidenceType)
end)

function GetPlayerIdentifier(source)
    if Framework == 'QBCore' then
        local Player = QBCore.Functions.GetPlayer(source)
        return Player and Player.PlayerData.citizenid or nil
    elseif Framework == 'ESX' then
        local xPlayer = ESX.GetPlayerFromId(source)
        return xPlayer and xPlayer.identifier or nil
    end
    return nil
end