RegisterNetEvent('advanced:CreateCallout')
AddEventHandler('advanced:CreateCallout', function(type, coords, details)
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
    TriggerClientEvent('advanced:NewCallout', -1, callId, type, coords, details)
end)

RegisterNetEvent('advanced:UpdateReputation')
AddEventHandler('advanced:UpdateReputation', function(identifier, delta)
    exports.oxmysql:execute(
        "UPDATE reputation SET score = score + @delta WHERE identifier = @identifier",
        { ['@delta'] = delta, ['@identifier'] = identifier }
    )
end)