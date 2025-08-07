-- Advanced NPC Witness Statement Server Script

RegisterNetEvent('AdvancedMDT:CreateWitnessStatement')
AddEventHandler('AdvancedMDT:CreateWitnessStatement', function(npcNetId, crimeCoords, caseId, eventType)
    local npcId = npcNetId
    local statement = ""
    if eventType == "gunfire" then
        statement = ("NPC %s heard gunshots and saw a suspect at %s"):format(npcId, json.encode(crimeCoords))
    elseif eventType == "melee" then
        statement = ("NPC %s witnessed a fight at %s"):format(npcId, json.encode(crimeCoords))
    else
        statement = ("NPC %s witnessed a crime at %s"):format(npcId, json.encode(crimeCoords))
    end
    exports.oxmysql:execute(
        "INSERT INTO witness_statements (npc_id, case_id, statement, timestamp) VALUES (@npc_id, @case_id, @statement, @timestamp)",
        {
            ['@npc_id'] = npcId,
            ['@case_id'] = caseId,
            ['@statement'] = statement,
            ['@timestamp'] = os.time()
        }
    )
end)