if Framework == 'QBCore' then

    function GetPlayerIdentifier(source)
        local Player = QBCore.Functions.GetPlayer(source)
        if Player then
            return Player.PlayerData.citizenid
        end
        return nil
    end

    function QBCore_Server_CollectEvidence(evidenceId, evidenceType, coords, caseId, identifier)
        exports.oxmysql:execute("INSERT INTO evidence (id, type, coords, case_id, collected_by, timestamp) VALUES (@id, @type, @coords, @case_id, @collected_by, @timestamp)",
            {
                ['@id'] = evidenceId,
                ['@type'] = evidenceType,
                ['@coords'] = json.encode(coords),
                ['@case_id'] = caseId,
                ['@collected_by'] = identifier,
                ['@timestamp'] = os.time()
            },
            function(rowsAffected)
                if rowsAffected > 0 then
                    TriggerClientEvent('QBCore:Notify', src, 'Evidence collected and linked to case ' .. caseId)
                else
                    TriggerClientEvent('QBCore:Notify', src, 'Evidence collection failed.')
                end
            end
        )
    end

    -- QBCore-specific functions for job checks, inventory management, notifications etc.
    -- Example for getting player data (as shown in the previous response)
    QBCore.Functions.CreateCallback('AdvancedMDT:GetPlayerData', function(source, cb)
        local Player = QBCore.Functions.GetPlayer(source)
        if Player then
            cb({
                citizenid = Player.PlayerData.citizenid,
                name = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname,
                job = Player.PlayerData.job.name
            })
        else
            cb(nil)
        end
    end)

end