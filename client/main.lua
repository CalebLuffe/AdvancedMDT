if not lib then return end

isMdtOpen = false

local hasLoadedUi = false
local config = require 'config'
local utils = require 'client.utils'
local framework = require(('client.framework.%s'):format(config.framework))
local player = nil
local isMiniDispatchOpen = false
local VEHICLES = framework.GetVehiclesByName()
local officerBlips = {}
local respondKey

require 'client.alerts'
require 'client.blips'
require 'client.camera'
require 'client.eventHandlers'

tabletAnimDict = 'amb@world_human_seat_wall_tablet@female@base'
tablet = nil

local function closeMdt(hideUi)
    if not isMdtOpen then return end

    isMdtOpen = false

    if hideUi then
        SendNUIMessage({
            action = 'setVisible',
            data = {
                visible = false,
            }
        })

        SetNuiFocus(false, false)
    end

    if IsEntityPlayingAnim(cache.ped, tabletAnimDict, 'base', 3) then
        ClearPedTasks(cache.ped)
    end

    if tablet then
        if DoesEntityExist(tablet) then
        Wait(300)
        DeleteEntity(tablet)
        end

        tablet = nil
    end
end

local function openMdt()
    local isAuthorised, callSign = lib.callback.await('mdt:openMdt', 500)

    if not isAuthorised then return end

    isMdtOpen = true

    if not IsEntityPlayingAnim(cache.ped, tabletAnimDict, 'base', 3) then
        lib.requestAnimDict(tabletAnimDict)
        TaskPlayAnim(cache.ped, tabletAnimDict, 'base', 6.0, 3.0, -1, 49, 1.0, false, false, false)
    end

    if not tablet then
        local model = lib.requestModel(`prop_cs_tablet`)

        if not model then return end

        local coords = GetEntityCoords(cache.ped)
        tablet = CreateObject(model, coords.x, coords.y, coords.z, true, true, true)
        AttachEntityToEntity(tablet, cache.ped, GetPedBoneIndex(cache.ped, 28422), 0.0, 0.0, 0.03, 0.0, 0.0, 0.0, true, true, false, true, 0, true)
    end

    if not hasLoadedUi then
        SendNUIMessage({
            action = 'setConfig',
            data = {
                config = {
                    isDispatchEnabled = config.isDispatchEnabled
                }
            }
        })

        local profileCards = lib.callback.await('mdt:getCustomProfileCards')
        local charges = lib.callback.await('mdt:getAllCharges')

        player.unit = LocalPlayer.state.mdtUnitId
        player.callSign = callSign

        SendNUIMessage({
            action = 'setInitData',
            data = {
                locale = GetConvar('ox:locale', 'en'),
                locales = lib.getLocales(),
                profileCards = profileCards,
                charges = charges
            }
        })

        hasLoadedUi = true
    end

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openMDT',
        data = {
            personalData = player,
        }
    })
end
exports('openMdt', openMdt)

lib.addKeybind({
    defaultKey = 'm',
    description = 'Open the Police MDT',
    name = 'openMdt',
    onPressed = openMdt
})

if config.isDispatchEnabled then
    local function openMiniDispatch()
        if isMdtOpen then return end

        local isAuthorised = lib.callback.await('mdt:openDispatch', 500)

        if not isAuthorised then return end

        isMiniDispatchOpen = true

        SetNuiFocus(true, true)
        SendNUIMessage({
            action = 'showMiniDispatch',
            data = {
            currentRespondKey = respondKey:getCurrentKey()
            }
        })
    end

    lib.addKeybind({
        defaultKey = 'i',
        description = 'Open the mini dispatch',
        name = 'openMiniDispatch',
        onPressed = openMiniDispatch
    })

    local function respondToCall()
        if (not isMiniDispatchOpen) then return end

        SendNUIMessage({
            action = 'respondToCall',
            data = {
            currentRespondKey = respondKey:getCurrentKey()
            }
        })
    end

    respondKey = lib.addKeybind({
        deafultKey = config.defaultRespondKey,
        description = 'Reponds to call',
        name = 'respondToCall',
        onPressed = respondToCall
    })

    lib.addKeybind({
        name = 'NextDisptachCall',
        description = 'Go to the next dispatch call',
        defaultKey = 'RIGHT',
        onPressed = function()
            SendNUIMessage({
                action = 'handleRightArrowPress'
            })
        end
    })

    lib.addKeybind({
        name = 'PreviousDisptachCall',
        description = 'Go to the previous dispatch call',
        defaultKey = 'LEFT',
        onPressed = function()
            SendNUIMessage({
                action = 'handleLeftArrowPress'
            })
        end
    })
end

RegisterNetEvent(framework.loadedEvent, function()
    player = framework.getOfficerData()
end)

RegisterNetEvent(framework.logoutEvent, function()
    hasLoadedUi = false

    if framework.isJobPolice() then closeMdt(true) end
end)

RegisterNetEvent(framework.setGroupEvent, function()
    framework.getOfficerData()

    if not framework.isJobPolice() then
        closeMdt(true)
    end
end)

RegisterNetEvent('mdt:OpenMDT', function()
    openMdt()
end)

RegisterNetEvent('mdt:client:CloseMiniDispatch', function()
    isMiniDispatchOpen = false
    SetNuiFocus(false, false)

    SendNUIMessage({
        action = "hideMiniDispatch"
    })
end)

RegisterNetEvent('mdt:client:CloseMDT', function()
    closeMdt(true)
end)

RegisterNetEvent('mdt:updateOfficerPositions', function(data)
    for i = 1, #data do
        local officer = data[i]

        if officer.citizenid ~= player.citizenid then
            local blip = officerBlips[officer.citizenid]

            if not blip then
                local name = ('police:%s'):format(officer.citizenid)

                blip = AddBlipForCoord(officer.position[2], officer.position[1], officer.position[3])
                officerBlips[officer.citizenid] = blip

                SetBlipSprite(blip, 1)
                SetBlipDisplay(blip, 3)
                SetBlipColour(blip, 42)
                ShowFriendIndicatorOnBlip(blip, true)
                AddTextEntry(name, ('%s %s (%s)'):format(officer.firstname, officer.lastname, officer.callsign))
                BeginTextCommandSetBlipName(name)
                EndTextCommandSetBlipName(blip)
                SetBlipCategory(blip, 7)
            else
                SetBlipCoords(blip, officer.position[2], officer.position[1], officer.position[3])
            end
        end
    end

    if not hasLoadedUi then return end

    SendNUIMessage({
        action = 'updateOfficerPositions',
        data = data
    })
end)

RegisterNetEvent('mdt:refreshUnits', function(data)
    SendNUIMessage({
        action = 'refreshUnits',
        data = data
    })
end)

RegisterNetEvent('mdt:createCall', function(data)
    data.call.id = data.id
    data.call.location = GetStreetNameFromHashKey(GetStreetNameAtCoord(data.call.coords[2], data.call.coords[1], 0))

    PlaySoundFrontend(-1, 'Near_Miss_Counter_Reset', 'GTAO_FM_Events_Soundset', false)

    SendNUIMessage({
        action = 'addCall',
        data = data.call
    })
end)

RegisterNetEvent('mdt:updateCallCoords', function(data)
    SendNUIMessage({
        action = 'updateCallCoords',
        data = data
    })
end)

RegisterNetEvent('mdt:updateCalls', function(data)
    for i = 1, #data.calls do
        data.calls[i].location = GetStreetNameFromHashKey(GetStreetNameAtCoord(data.calls[i].coords[2], data.calls[i].coords[1], 0))
    end

    SendNUIMessage({
        action = 'updateCalls',
        data = data
    })
end)

RegisterNetEvent('mdt:editCallUnits', function(data)
    SendNUIMessage({
        action = 'editCallUnits',
        data = data
    })
end)

RegisterNetEvent('mdt:setCallUnits', function(data)
    SendNUIMessage({
        action = 'setCallUnits',
        data = data
    })
end)

RegisterNetEvent('mdt:client:notify', function(text, type)
    framework.notify(text, type)
end)

RegisterNUICallback('hideMiniDisptach', function(_, cb)
    if isMdtOpen then return end

    SetNuiFocus(false, false)
    cb(1)
end)

RegisterNuiCallback('takePicture', function(data, cb)
    SetNuiFocus(false, false);
    closeMdt(true);
    camera = true
    CameraLoop(data);
    cb(1)
end)

RegisterNuiCallback('setWaypoint', function(data, cb)
    SetNewWaypoint(data[2], data[1])
    cb(1)
end)

RegisterNUICallback('exit', function(_, cb)
	cb(1)
    SetNuiFocus(false, false)
    closeMdt(true)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == cache.resource then
        player.unit = nil
        closeMdt()
    end
end)

AddEventHandler("onResourceStart", function(resource)
    if resource == cache.resource then
        player = framework.getOfficerData()
    end
end)

local function serverNuiCallback(event, clientCb)
    RegisterNuiCallback(event, function(data, cb)
        local response = lib.callback.await('mdt:' .. event, false, data)
        if clientCb then return clientCb(response, cb) end
        cb(response)
    end)
end

-- Dashboard
serverNuiCallback('getAnnouncements')
serverNuiCallback('createAnnouncement')
serverNuiCallback('getRecentActivity')
serverNuiCallback('getActiveOfficers')
serverNuiCallback('getWarrants')

-- Profiles
serverNuiCallback('getAllProfiles')
serverNuiCallback('getProfile')
serverNuiCallback('getProfiles')
serverNuiCallback('saveProfileNotes')
serverNuiCallback('isProfileWanted')
serverNuiCallback('updateProfileImage')

-- Incidents
serverNuiCallback('getIncidents')
serverNuiCallback('deleteIncident')
serverNuiCallback('createIncident')
serverNuiCallback('getIncident')
serverNuiCallback('addOfficer')
serverNuiCallback('removeOfficer')
serverNuiCallback('addCriminal')
serverNuiCallback('removeCriminal')
serverNuiCallback('addEvidence')
serverNuiCallback('getRecommendedWarrantExpiry')
serverNuiCallback('saveCriminal')
serverNuiCallback('removeEvidence')
serverNuiCallback('getOfficers')
serverNuiCallback('getCriminalProfiles')
serverNuiCallback('saveIncidentContents')

-- Reports
serverNuiCallback('getReports')
serverNuiCallback('getReport')
serverNuiCallback('removeReportOfficer')
serverNuiCallback('removeReportCitizen')
serverNuiCallback('saveReportContents')
serverNuiCallback('removeReportEvidence')
serverNuiCallback('createReport')
serverNuiCallback('addReportOfficer')
serverNuiCallback('addReportEvidence')
serverNuiCallback('addReportCitizen')

-- Vehicles
serverNuiCallback('getAllVehicles', function(data, cb)
    local vehicles = {}
    for i = 1, #data do
        vehicles[#vehicles+1] = {
            plate = data[i].plate,
            model = VEHICLES[data[i].vehicle].model,
        }
    end

    cb(vehicles)
end)

serverNuiCallback('getVehicle', function(data, cb)
    local vehicle = {
        plate = data.plate,
        model = VEHICLES[data.vehicle].model,
        color = utils.GetColor(json.decode(data.mods).color1) or 'Blue',
        owner = data.owner,
        notes = data.notes,
        class = utils.GetVehicleClassById(GetVehicleClassFromName(VEHICLES[data.vehicle].hash)) or 'Unknown',
        image = data.image,
        knownInformation = json.decode(data.known_information) or {},
    }

    cb(vehicle)
end)
serverNuiCallback('saveVehicleInformation')
serverNuiCallback('saveVehicleNotes')
serverNuiCallback('updateVehicleImage')
serverNuiCallback('createBOLO')
serverNuiCallback('isVehicleBOLO')
serverNuiCallback('getBOLOExpirationDate')
serverNuiCallback('deleteBOLO')
serverNuiCallback('getBolos')
serverNuiCallback('getBolo')

-- Dispatch
serverNuiCallback('respondToCall')
serverNuiCallback('detachFromCall')
serverNuiCallback('getCalls', function(data, cb)
    for _, call in pairs(data) do
        call.location = GetStreetNameFromHashKey(GetStreetNameAtCoord(call.coords[1], call.coords[2], 0))
    end

    cb(data)
end)
serverNuiCallback('getUnits')
serverNuiCallback('createUnit')
serverNuiCallback('leaveUnit')
serverNuiCallback('setCallUnits')
serverNuiCallback('setUnitOfficers')
serverNuiCallback('setUnitType')

-- Roster
serverNuiCallback('fetchRoster')
serverNuiCallback('hireOfficer')
serverNuiCallback('fireOfficer')
serverNuiCallback('setOfficerCallSign')
serverNuiCallback('setOfficerRoles')
serverNuiCallback('setOfficerRank')

-- Charges
serverNuiCallback('deleteCharge')
serverNuiCallback('createCharge')
serverNuiCallback('editCharge')

-- Framework detection (important for client-side as well)
if ESX then
    Framework = 'ESX'
elseif QBCore then
    Framework = 'QBCore'
else
    print("WARNING: No supported framework (ESX or QBCore) detected on client!")
end

-- Client-side evidence detection (conceptual)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        -- Example: Detect nearby evidence (e.g., bullet casings)
        -- Iterate through spawned evidence objects or pre-defined locations
        -- Check for proximity and allow interaction
        -- If player interacts and is authorized (e.g., police job), trigger server event to collect evidence

        -- Placeholder: Assuming a local function to check for evidence interaction
        CheckForEvidenceInteraction(playerCoords)
    end
end)

function CheckForEvidenceInteraction(playerCoords)
    -- This is where you would implement logic to detect nearby evidence items
    -- and check for player interaction (e.g., pressing a key when near evidence).
    -- If interaction happens and the player has the correct permissions,
    -- you would trigger the server event to collect and link the evidence.

    -- Example: Triggering the collection event
    -- TriggerServerEvent('advanced:Server:CollectEvidence', "shellcasing", playerCoords, "CASE_XYZ")
end

-- Client-side NPC Interaction for Witnesses (conceptual)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        -- Detect nearby NPCs who might have witnessed an event (proximity, LOS check)
        -- If an NPC is a potential witness, display a prompt for the player to interact
        -- If player interacts, trigger a UI for witness interrogation or automatically generate a statement
        -- Trigger server event to store witness statement in the database

        -- Placeholder: Assuming a local function to detect and interact with witnesses
        DetectAndInteractWithWitnesses(playerCoords)
    end
end)

function DetectAndInteractWithWitnesses(playerCoords)
    -- This function would iterate through nearby NPCs, check if they are flagged as witnesses
    -- based on recent events (e.g., stored data from server).
    -- It would then display a prompt for the player to press a key to interact.
    -- Upon interaction, it could open a UI for dialogue or directly trigger server-side
    -- witness statement generation and storage.

    -- Example: Triggering a server event for witness callout
    -- TriggerServerEvent('advanced:Server:CreateNPCWitnessCallout', "CRIME_SCENE_123", witnessCoords, "I saw a blue car speeding away.")
end

-- Handle evidence collected confirmation (or failed) from server
RegisterNetEvent('advanced:Client:EvidenceCollected')
AddEventHandler('advanced:Client:EvidenceCollected', function(evidenceId, caseId)
    if Framework == 'ESX' then
        ESX.ShowNotification('Evidence ' .. evidenceId .. ' collected and linked to case ' .. caseId)
    elseif Framework == 'QBCore' then
        -- QBCore notification already handled on the server side
    end
end)

RegisterNetEvent('advanced:Client:EvidenceCollectionFailed')
AddEventHandler('advanced:Client:EvidenceCollectionFailed', function()
    if Framework == 'ESX' then
        ESX.ShowNotification('Evidence collection failed.')
    elseif Framework == 'QBCore' then
        -- QBCore notification already handled on the server side
    end
end)