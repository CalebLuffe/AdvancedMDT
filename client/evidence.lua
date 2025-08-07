-- Expanded Evidence Detection Client Script

local evidenceTypes = {
    {type = "shell_casing", action = function() return IsPedShooting(PlayerPedId()) end, desc = "Shell casing found"},
    {type = "blood_sample", action = function() return IsPedInjured(PlayerPedId()) end, desc = "Blood sample found"},
    {type = "fingerprint", action = function() return IsPedInMeleeCombat(PlayerPedId()) end, desc = "Fingerprint found"},
    {type = "weapon_fragment", action = function() return HasPedBeenDamagedByWeapon(PlayerPedId(), 0, 2) end, desc = "Weapon fragment found"},
    {type = "drug_residue", action = function() return IsPedUsingScenario(PlayerPedId(), "WORLD_HUMAN_DRUG_DEALER") end, desc = "Drug residue found"},
}

local function getActiveCaseId()
    return exports["advancedmdt"]:GetActiveCaseId()
end

local function detectEvidence()
    for _, ev in ipairs(evidenceTypes) do
        if ev.action() then
            local coords = GetEntityCoords(PlayerPedId())
            local caseId = getActiveCaseId()
            TriggerServerEvent('AdvancedMDT:CollectEvidence', ev.type, coords, caseId, ev.desc)
        end
    end
end

Citizen.CreateThread(function()
    while true do
        detectEvidence()
        Citizen.Wait(1000)
    end
end)

RegisterNetEvent('AdvancedMDT:DetectEvidence')
AddEventHandler('AdvancedMDT:DetectEvidence', function(evidenceType, coords, description)
    local officer = GetPlayerServerId(PlayerId())
    TriggerServerEvent('AdvancedMDT:CollectEvidence', evidenceType, coords, officer, description)
end)