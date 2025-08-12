-- Framework detection (this needs to be at the top of shared server/client scripts)
if ESX then
    Framework = 'ESX'
    ESX = nil -- Clear ESX to ensure it's not accidentally used in shared code
elseif QBCore then
    Framework = 'QBCore'
    QBCore = nil -- Clear QBCore
else
    -- Handle cases where no framework or an unknown framework is detected
    print("WARNING: No supported framework (ESX or QBCore) detected!")
end

-- Shared server-side functions (framework agnostic where possible)

function GenerateUniqueCaseId()
    -- Implement a method to generate unique case IDs (e.g., UUID, timestamp-based)
    return 'CASE_' .. os.time() .. math.random(1000, 9999)
end

function GenerateUniqueEvidenceId()
    -- Implement a method to generate unique evidence IDs
    return 'EVIDENCE_' .. os.time() .. math.random(1000, 9999)
end

-- Server-side evidence logic
RegisterServerEvent('advanced:Server:CollectEvidence')
AddEventHandler('advanced:Server:CollectEvidence', function(evidenceType, coords, caseId)
    local src = source
    local identifier = GetPlayerIdentifier(src) -- Placeholder, will be framework-specific

    local evidenceId = GenerateUniqueEvidenceId()

    -- Framework-specific database interaction handled in esx.lua/qbcore.lua
    if Framework == 'ESX' then
        ESX_Server_CollectEvidence(evidenceId, evidenceType, coords, caseId, identifier)
    elseif Framework == 'QBCore' then
        QBCore_Server_CollectEvidence(evidenceId, evidenceType, coords, caseId, identifier)
    end
end)

-- Server-side NPC Callout logic
RegisterServerEvent('advanced:Server:CreateNPCWitnessCallout')
AddEventHandler('advanced:Server:CreateNPCWitnessCallout', function(crimeSceneId, witnessCoords, witnessStatement)
    -- Store witness data in the database, linked to the crime scene ID
    MySQL.Async.execute("INSERT INTO witnesses (crime_scene_id, coords, statement) VALUES (@crime_scene_id, @coords, @statement)",
        {['@crime_scene_id'] = crimeSceneId, ['@coords'] = json.encode(witnessCoords), ['@statement'] = witnessStatement},
        function(rowsChanged)
            if rowsChanged > 0 then
                -- Trigger dispatch callout for officers
            end
        end
    )
end)

-- You would have functions here to handle case creation, evidence linking, etc.
-- These would call framework-specific functions (defined in esx.lua/qbcore.lua) for player data and database interaction.