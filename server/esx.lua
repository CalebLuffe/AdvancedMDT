if Framework == 'ESX' then

    function GetPlayerIdentifier(source)
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            return xPlayer.identifier
        end
        return nil
    end

    function ESX_Server_CollectEvidence(evidenceId, evidenceType, coords, caseId, identifier)
        MySQL.Async.execute("INSERT INTO evidence (id, type, coords, case_id, collected_by, timestamp) VALUES (@id, @type, @coords, @case_id, @collected_by, @timestamp)",
            {
                ['@id'] = evidenceId,
                ['@type'] = evidenceType,
                ['@coords'] = json.encode(coords),
                ['@case_id'] = caseId,
                ['@collected_by'] = identifier,
                ['@timestamp'] = os.time()
            },
            function(rowsChanged)
                if rowsChanged > 0 then
                    TriggerClientEvent('advanced:Client:EvidenceCollected', src, evidenceId, caseId)
                else
                    TriggerClientEvent('advanced:Client:EvidenceCollectionFailed', src)
                end
            end
        )
    end

    -- ESX-specific functions for job checks, inventory management, notifications etc.
    -- Example for getting player data (as shown in the previous response)
    ESX.RegisterServerCallback('advanced:GetPlayerData', function(source, cb)
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            cb({
                identifier = xPlayer.identifier,
                name = xPlayer.name,
                job = xPlayer.job.name
            })
        else
            cb(nil)
        end
    end)

end