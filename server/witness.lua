RegisterNetEvent('AdvancedMDT:DetectWitnesses')
AddEventHandler('AdvancedMDT:DetectWitnesses', function(crimeCoords, caseId)
    local witnesses = FindNearbyNPCs(crimeCoords, 30.0)
    for _, npc in ipairs(witnesses) do
        local statement = GenerateWitnessStatement(npc, crimeCoords)
        exports.oxmysql:execute(
            "INSERT INTO witness_statements (npc_id, case_id, statement, timestamp) VALUES (@npc_id, @case_id, @statement, @timestamp)",
            {
                ['@npc_id'] = npc.id,
                ['@case_id'] = caseId,
                ['@statement'] = statement,
                ['@timestamp'] = os.time()
            }
        )
    end
end)

function GenerateWitnessStatement(npc, coords)
    return ("NPC %d saw something suspicious at %s"):format(npc.id, json.encode(coords))
end