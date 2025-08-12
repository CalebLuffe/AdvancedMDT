-- Advanced NPC Witness Detection Client Script

local function getActiveCaseId()
    return exports["advanced"]:GetActiveCaseId()
end

local function detectCrimeAndWitnesses()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    if IsPedShooting(playerPed) or IsPedInMeleeCombat(playerPed) then
        for npc in EnumeratePeds() do
            if not IsPedAPlayer(npc) and not IsPedDeadOrDying(npc, true) then
                local npcCoords = GetEntityCoords(npc)
                local dist = #(playerCoords - npcCoords)
                if dist < 25.0 and HasEntityClearLosToEntity(npc, playerPed, 17) then
                    local caseId = getActiveCaseId()
                    local eventType = IsPedShooting(playerPed) and "gunfire" or "melee"
                    TriggerServerEvent('advanced:CreateWitnessStatement', NetworkGetNetworkIdFromEntity(npc), playerCoords, caseId, eventType)
                end
            end
        end
    end
end

Citizen.CreateThread(function()
    while true do
        detectCrimeAndWitnesses()
        Citizen.Wait(2000)
    end
end)

function EnumeratePeds()
    return coroutine.wrap(function()
        local handle, ped = FindFirstPed()
        local finished = false
        repeat
            if not IsPedAPlayer(ped) then
                coroutine.yield(ped)
            end
            finished, ped = FindNextPed(handle)
        until not finished
        EndFindPed(handle)
    end)
end