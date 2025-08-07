RegisterNetEvent('AdvancedMDT:CreateCallout')
AddEventHandler('AdvancedMDT:CreateCallout', function(type, coords, details)
    local callId = ('call_%d'):format(os.time())
    exports.oxmysql:execute(
        "INSERT INTO calls (id, type, coords, details, timestamp) VALUES (@id, @type, @coords, @details, @timestamp)",
        {
            ['@id'] = callId,
            ['@type'] = type,
            ['@coords'] = json.encode(coords),
            ['@details'] = details,
            ['@timestamp'] = os.time()
        }
    )
    TriggerClientEvent('AdvancedMDT:NewCallout', -1, callId, type, coords, details)
end)

RegisterNetEvent('AdvancedMDT:UpdateReputation')
AddEventHandler('AdvancedMDT:UpdateReputation', function(identifier, delta)
    exports.oxmysql:execute(
        "UPDATE reputation SET score = score + @delta WHERE identifier = @identifier",
        { ['@delta'] = delta, ['@identifier'] = identifier }
    )
end)