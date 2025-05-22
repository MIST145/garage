local stopmove = false
local ESX = exports['es_extended']:getSharedObject()

Citizen.CreateThread(function()
    while true do
       Citizen.Wait(0)
       if stopmove then
            FreezeEntityPosition(GetPlayerPed(-1), true)
       else
            FreezeEntityPosition(GetPlayerPed(-1), false)
       end
   end
end)

OpenGarageMenu = function()
    local currentGarage = cachedData["currentGarage"]
    if not currentGarage then return end

    HandleCamera(currentGarage, true)

    ESX.TriggerServerCallback("garage:fetchPlayerVehicles", function(fetchedVehicles)
        local options = {}

        for key, vehicleData in ipairs(fetchedVehicles) do
            local vehicleProps = vehicleData["props"]
            local vehicleName = GetLabelText(GetDisplayNameFromVehicleModel(vehicleProps["model"]))

            table.insert(options, {
                title = vehicleName,
                description = 'Matricula: ' .. vehicleData["plate"] .. ' | Clica para retirar',
                icon = 'car',
                metadata = {
                    {label = 'Matrícula', value = vehicleData["plate"]},
                    {label = 'Modelo', value = vehicleName}
                },
                args = {
                    vehicle = vehicleData
                },
                onSelect = function(args)
                    if args.vehicle then
                        lib.hideContext()
                        stopmove = false
                        SpawnVehicle(args.vehicle["props"])
                    end
                end
            })
        end

        if #options == 0 then
            table.insert(options, {
                title = 'Sem veículos',
                description = 'Não tens veículos guardados nesta garagem',
                icon = 'exclamation-triangle',
                disabled = true
            })
        elseif #options > 0 then
            SpawnLocalVehicle(options[1].args.vehicle["props"], currentGarage)
        end

        stopmove = true

        lib.registerContext({
            id = 'garage_main_menu',
            title = 'Garagem - ' .. currentGarage,
            menu = 'garage_menu_back',
            options = options,
            onExit = function()
                HandleCamera(currentGarage, false)
                stopmove = false
            end
        })

        lib.showContext('garage_main_menu')
    end, currentGarage)
end

OpenVehicleMenu = function()
    ESX.TriggerServerCallback("garage:fetchPlayerVehicles", function(fetchedVehicles)
        local options = {}
        local gameVehicles = ESX.Game.GetVehicles()
        local pedCoords = GetEntityCoords(PlayerPedId())

        for key, vehicleData in ipairs(fetchedVehicles) do
            local vehicleProps = vehicleData["props"]

            for _, vehicle in ipairs(gameVehicles) do
                if DoesEntityExist(vehicle) then
                    local dstCheck = math.floor(#(pedCoords - GetEntityCoords(vehicle)))

                    if Config.Trim(GetVehicleNumberPlateText(vehicle)) == Config.Trim(vehicleProps["plate"]) then
                        local vehicleName = GetLabelText(GetDisplayNameFromVehicleModel(vehicleProps["model"]))
                        
                        table.insert(options, {
                            title = vehicleName,
                            description = 'Matrícula: ' .. vehicleData["plate"] .. ' | Distância: ' .. dstCheck .. ' metros',
                            icon = 'car',
                            metadata = {
                                {label = 'Matrícula', value = vehicleData["plate"]},
                                {label = 'Distância', value = dstCheck .. ' metros'}
                            },
                            args = {
                                vehicleData = vehicleData,
                                vehicleEntity = vehicle
                            },
                            onSelect = function(args)
                                if args.vehicleEntity then
                                    ChooseVehicleAction(args.vehicleEntity, function(actionChosen)
                                        VehicleAction(args.vehicleEntity, actionChosen)
                                    end)
                                end
                            end
                        })
                    end
                end
            end
        end

        if #options == 0 then
            table.insert(options, {
                title = 'Sem veículos',
                description = 'Não tens veículos nas ruas',
                icon = 'exclamation-triangle',
                disabled = true
            })
        end

        lib.registerContext({
            id = 'vehicle_main_menu',
            title = 'Veículos Possuídos',
            options = options
        })

        lib.showContext('vehicle_main_menu')
    end)
end

ChooseVehicleAction = function(vehicleEntity, callback)
    if not cachedData["blips"] then cachedData["blips"] = {} end

    local options = {
        {
            title = (GetIsVehicleEngineRunning(vehicleEntity) and "Desligar" or "Ligar") .. " motor",
            description = 'Controla o estado do motor do veículo',
            icon = GetIsVehicleEngineRunning(vehicleEntity) and 'power-off' or 'play',
            args = { action = "change_engine_state" },
            onSelect = function(args)
                callback(args.action)
            end
        },
        {
            title = (DoesBlipExist(cachedData["blips"][vehicleEntity]) and "Desativar" or "Ativar") .. " GPS",
            description = 'Controla o rastreador GPS do veículo',
            icon = DoesBlipExist(cachedData["blips"][vehicleEntity]) and 'map-pin-off' or 'map-pin',
            args = { action = "change_gps_state" },
            onSelect = function(args)
                callback(args.action)
            end
        },
        {
            title = "Controlar portas",
            description = 'Abre/fecha as portas do veículo',
            icon = 'door-open',
            args = { action = "change_door_state" },
            onSelect = function(args)
                callback(args.action)
            end
        }
    }

    lib.registerContext({
        id = 'vehicle_action_menu',
        title = 'Ações - ' .. GetVehicleNumberPlateText(vehicleEntity),
        menu = 'vehicle_main_menu',
        options = options
    })

    lib.showContext('vehicle_action_menu')
end

VehicleAction = function(vehicleEntity, action)
    local dstCheck = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(vehicleEntity))

    while not NetworkHasControlOfEntity(vehicleEntity) do
        Citizen.Wait(0)
        NetworkRequestControlOfEntity(vehicleEntity)
    end

    if action == "change_lock_state" then
        if dstCheck >= Config.RangeCheck then 
            return lib.notify({
                title = 'Erro',
                description = 'Estás muito longe do veículo',
                type = 'error',
                position = Config.NotificationPosition,
                duration = Config.NotificationDuration
            })
        end

        PlayAnimation(PlayerPedId(), "anim@mp_player_intmenu@key_fob@", "fob_click", {
            ["speed"] = 8.0,
            ["speedMultiplier"] = 8.0,
            ["duration"] = 1820,
            ["flag"] = 49,
            ["playbackRate"] = false
        })

        for index = 1, 4 do
            if (index % 2 == 0) then
                SetVehicleLights(vehicleEntity, 2)
            else
                SetVehicleLights(vehicleEntity, 0)
            end
            Citizen.Wait(300)
        end

        StartVehicleHorn(vehicleEntity, 50, 1, false)
        
        local vehicleLockState = GetVehicleDoorLockStatus(vehicleEntity)

        if vehicleLockState == 1 then
            SetVehicleDoorsLocked(vehicleEntity, 2)
            PlayVehicleDoorCloseSound(vehicleEntity, 1)
        elseif vehicleLockState == 2 then
            SetVehicleDoorsLocked(vehicleEntity, 1)
            PlayVehicleDoorOpenSound(vehicleEntity, 0)

            local oldCoords = GetEntityCoords(PlayerPedId())
            local oldHeading = GetEntityHeading(PlayerPedId())

            if not IsPedInVehicle(PlayerPedId(), vehicleEntity) and not DoesEntityExist(GetPedInVehicleSeat(vehicleEntity, -1)) then
                SetPedIntoVehicle(PlayerPedId(), vehicleEntity, -1)
                TaskLeaveVehicle(PlayerPedId(), vehicleEntity, 16)
                SetEntityCoords(PlayerPedId(), oldCoords - vector3(0.0, 0.0, 0.99))
                SetEntityHeading(PlayerPedId(), oldHeading)
            end
        end

        local vehicleName = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(vehicleEntity)))
        lib.notify({
            title = 'Veículo ' .. (vehicleLockState == 1 and "Trancado" or "Destrancado"),
            description = vehicleName .. ' com matrícula ' .. GetVehicleNumberPlateText(vehicleEntity),
            type = 'success',
            position = Config.NotificationPosition,
            duration = Config.NotificationDuration
        })

    elseif action == "change_door_state" then
        if dstCheck >= Config.RangeCheck then 
            return lib.notify({
                title = 'Erro',
                description = 'Estás muito longe do veículo',
                type = 'error',
                position = Config.NotificationPosition,
                duration = Config.NotificationDuration
            })
        end

        ChooseDoor(vehicleEntity, function(doorChosen)
            if doorChosen then
                if GetVehicleDoorAngleRatio(vehicleEntity, doorChosen) == 0 then
                    SetVehicleDoorOpen(vehicleEntity, doorChosen, false, false)
                else
                    SetVehicleDoorShut(vehicleEntity, doorChosen, false, false)
                end
            end
        end)

    elseif action == "change_engine_state" then
        if dstCheck >= Config.RangeCheck then 
            return lib.notify({
                title = 'Erro',
                description = 'Estás muito longe do veículo',
                type = 'error',
                position = Config.NotificationPosition,
                duration = Config.NotificationDuration
            })
        end

        if GetIsVehicleEngineRunning(vehicleEntity) then
            SetVehicleEngineOn(vehicleEntity, false, false)
            cachedData["engineState"] = true

            CreateThread(function()
                while cachedData["engineState"] do
                    Wait(5)
                    SetVehicleUndriveable(vehicleEntity, true)
                end
                SetVehicleUndriveable(vehicleEntity, false)
            end)

            lib.notify({
                title = 'Motor Desligado',
                description = 'O motor do veículo foi desligado',
                type = 'success',
                position = Config.NotificationPosition,
                duration = Config.NotificationDuration
            })
        else
            cachedData["engineState"] = false
            SetVehicleEngineOn(vehicleEntity, true, true)

            lib.notify({
                title = 'Motor Ligado',
                description = 'O motor do veículo foi ligado',
                type = 'success',
                position = Config.NotificationPosition,
                duration = Config.NotificationDuration
            })
        end

    elseif action == "change_gps_state" then
        if DoesBlipExist(cachedData["blips"][vehicleEntity]) then
            RemoveBlip(cachedData["blips"][vehicleEntity])
            cachedData["blips"][vehicleEntity] = nil

            lib.notify({
                title = 'GPS Desativado',
                description = 'O rastreador GPS foi desativado',
                type = 'inform',
                position = Config.NotificationPosition,
                duration = Config.NotificationDuration
            })
        else
            cachedData["blips"][vehicleEntity] = AddBlipForEntity(vehicleEntity)
    
            SetBlipSprite(cachedData["blips"][vehicleEntity], GetVehicleClass(vehicleEntity) == 8 and 226 or 225)
            SetBlipScale(cachedData["blips"][vehicleEntity], 1.05)
            SetBlipColour(cachedData["blips"][vehicleEntity], 30)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Veículo Pessoal - " .. GetVehicleNumberPlateText(vehicleEntity))
            EndTextCommandSetBlipName(cachedData["blips"][vehicleEntity])

            lib.notify({
                title = 'GPS Ativado',
                description = 'O rastreador GPS foi ativado',
                type = 'success',
                position = Config.NotificationPosition,
                duration = Config.NotificationDuration
            })
        end
    end
end

ChooseDoor = function(vehicleEntity, callback)
    local options = {
        {
            title = "Porta dianteira esquerda",
            icon = 'door-open',
            args = { door = 0 },
            onSelect = function(args) callback(args.door) end
        },
        {
            title = "Porta dianteira direita", 
            icon = 'door-open',
            args = { door = 1 },
            onSelect = function(args) callback(args.door) end
        },
        {
            title = "Porta traseira esquerda",
            icon = 'door-open', 
            args = { door = 2 },
            onSelect = function(args) callback(args.door) end
        },
        {
            title = "Porta traseira direita",
            icon = 'door-open',
            args = { door = 3 },
            onSelect = function(args) callback(args.door) end
        },
        {
            title = "Capot",
            icon = 'car-front',
            args = { door = 4 },
            onSelect = function(args) callback(args.door) end
        },
        {
            title = "Porta-bagagens",
            icon = 'car-rear',
            args = { door = 5 },
            onSelect = function(args) callback(args.door) end
        }
    }

    lib.registerContext({
        id = 'door_selection_menu',
        title = 'Escolher Porta',
        menu = 'vehicle_action_menu',
        options = options
    })

    lib.showContext('door_selection_menu')
end

SpawnLocalVehicle = function(vehicleProps)
    local spawnpoint = Config.Garages[cachedData["currentGarage"]]["positions"]["vehicle"]

    WaitForModel(vehicleProps["model"])

    if DoesEntityExist(cachedData["vehicle"]) then
        DeleteEntity(cachedData["vehicle"])
    end
    
    if not ESX.Game.IsSpawnPointClear(spawnpoint["position"], 3.0) then 
        lib.notify({
            title = 'Erro',
            description = 'Remove o veículo que está no local de spawn',
            type = 'error',
            position = Config.NotificationPosition,
            duration = Config.NotificationDuration
        })
        return
    end
    
    if not IsModelValid(vehicleProps["model"]) then
        return
    end

    ESX.Game.SpawnLocalVehicle(vehicleProps["model"], spawnpoint["position"], spawnpoint["heading"], function(yourVehicle)
        cachedData["vehicle"] = yourVehicle
        SetVehicleProperties(yourVehicle, vehicleProps)
        SetModelAsNoLongerNeeded(vehicleProps["model"])
    end)
end

SpawnVehicle = function(vehicleProps)
    local spawnpoint = Config.Garages[cachedData["currentGarage"]]["positions"]["vehicle"]

    WaitForModel(vehicleProps["model"])

    if DoesEntityExist(cachedData["vehicle"]) then
        DeleteEntity(cachedData["vehicle"])
    end
    
    if not ESX.Game.IsSpawnPointClear(spawnpoint["position"], 3.0) then 
        lib.notify({
            title = 'Erro', 
            description = 'Remove o veículo que está no local de spawn',
            type = 'error',
            position = Config.NotificationPosition,
            duration = Config.NotificationDuration
        })
        return
    end
    
    local gameVehicles = ESX.Game.GetVehicles()

    for i = 1, #gameVehicles do
        local vehicle = gameVehicles[i]
        if DoesEntityExist(vehicle) then
            if Config.Trim(GetVehicleNumberPlateText(vehicle)) == Config.Trim(vehicleProps["plate"]) then
                lib.notify({
                    title = 'Erro',
                    description = 'Este veículo já está nas ruas',
                    type = 'error',
                    position = Config.NotificationPosition,
                    duration = Config.NotificationDuration
                })
                return HandleCamera(cachedData["currentGarage"])
            end
        end
    end

    ESX.Game.SpawnVehicle(vehicleProps["model"], spawnpoint["position"], spawnpoint["heading"], function(yourVehicle)
        SetVehicleProperties(yourVehicle, vehicleProps)
        NetworkFadeInEntity(yourVehicle, true, true)
        SetModelAsNoLongerNeeded(vehicleProps["model"])
        SetEntityAsMissionEntity(yourVehicle, true, true)
        
        lib.notify({
            title = 'Sucesso',
            description = 'Veículo retirado da garagem',
            type = 'success',
            position = Config.NotificationPosition,
            duration = Config.NotificationDuration
        })

        HandleCamera(cachedData["currentGarage"])
    end)
    
    TriggerServerEvent("garage:takecar", vehicleProps["plate"], false)
end

PutInVehicle = function()
    local vehicle = GetVehiclePedIsUsing(PlayerPedId())

    if DoesEntityExist(vehicle) then
        local vehicleProps = GetVehicleProperties(vehicle)

        ESX.TriggerServerCallback("garage:validateVehicle", function(valid)
            if valid then
                TaskLeaveVehicle(PlayerPedId(), vehicle, 0)
    
                while IsPedInVehicle(PlayerPedId(), vehicle, true) do
                    Citizen.Wait(0)
                end
    
                Citizen.Wait(500)
                NetworkFadeOutEntity(vehicle, true, true)
                Citizen.Wait(100)
                ESX.Game.DeleteVehicle(vehicle)

                lib.notify({
                    title = 'Sucesso',
                    description = 'Veículo guardado na garagem',
                    type = 'success', 
                    position = Config.NotificationPosition,
                    duration = Config.NotificationDuration
                })
            else
                lib.notify({
                    title = 'Erro',
                    description = 'Este veículo não te pertence',
                    type = 'error',
                    position = Config.NotificationPosition,
                    duration = Config.NotificationDuration
                })
            end
        end, vehicleProps, cachedData["currentGarage"])
    end
end

SetVehicleProperties = function(vehicle, vehicleProps)
    ESX.Game.SetVehicleProperties(vehicle, vehicleProps)

    SetVehicleEngineHealth(vehicle, vehicleProps["engineHealth"] and vehicleProps["engineHealth"] + 0.0 or 1000.0)
    SetVehicleBodyHealth(vehicle, vehicleProps["bodyHealth"] and vehicleProps["bodyHealth"] + 0.0 or 1000.0)
    SetVehicleFuelLevel(vehicle, vehicleProps["fuelLevel"] and vehicleProps["fuelLevel"] + 0.0 or 100.0)
    
    -- Fuel system compatibility
    if GetResourceState("np-fuel") == "started" then
        exports["np-fuel"]:SetFuel(vehicle, vehicleProps["fuelLevel"] and vehicleProps["fuelLevel"] + 0.0 or 100)
    elseif GetResourceState("LegacyFuel") == "started" then
        exports["LegacyFuel"]:SetFuel(vehicle, vehicleProps["fuelLevel"] and vehicleProps["fuelLevel"] + 0.0 or 100)
    end

    if vehicleProps["windows"] then
        for windowId = 1, 13, 1 do
            if vehicleProps["windows"][windowId] == false then
                SmashVehicleWindow(vehicle, windowId)
            end
        end
    end

    if vehicleProps["tyres"] then
        for tyreId = 1, 7, 1 do
            if vehicleProps["tyres"][tyreId] ~= false then
                SetVehicleTyreBurst(vehicle, tyreId, true, 1000)
            end
        end
    end

    if vehicleProps["doors"] then
        for doorId = 0, 5, 1 do
            if vehicleProps["doors"][doorId] ~= false then
                SetVehicleDoorBroken(vehicle, doorId - 1, true)
            end
        end
    end
end

GetVehicleProperties = function(vehicle)
    if DoesEntityExist(vehicle) then
        local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)

        vehicleProps["tyres"] = {}
        vehicleProps["windows"] = {}
        vehicleProps["doors"] = {}

        for id = 1, 7 do
            local tyreId = IsVehicleTyreBurst(vehicle, id, false)
        
            if tyreId then
                vehicleProps["tyres"][#vehicleProps["tyres"] + 1] = tyreId
        
                if tyreId == false then
                    tyreId = IsVehicleTyreBurst(vehicle, id, true)
                    vehicleProps["tyres"][#vehicleProps["tyres"]] = tyreId
                end
            else
                vehicleProps["tyres"][#vehicleProps["tyres"] + 1] = false
            end
        end

        for id = 1, 13 do
            local windowId = IsVehicleWindowIntact(vehicle, id)

            if windowId ~= nil then
                vehicleProps["windows"][#vehicleProps["windows"] + 1] = windowId
            else
                vehicleProps["windows"][#vehicleProps["windows"] + 1] = true
            end
        end
        
        for id = 0, 5 do
            local doorId = IsVehicleDoorDamaged(vehicle, id)
        
            if doorId then
                vehicleProps["doors"][#vehicleProps["doors"] + 1] = doorId
            else
                vehicleProps["doors"][#vehicleProps["doors"] + 1] = false
            end
        end

        vehicleProps["engineHealth"] = GetVehicleEngineHealth(vehicle)
        vehicleProps["bodyHealth"] = GetVehicleBodyHealth(vehicle)
        
        -- Fuel system compatibility
        if GetResourceState("np-fuel") == "started" then
            vehicleProps["fuelLevel"] = exports["np-fuel"]:GetFuel(vehicle)
        elseif GetResourceState("LegacyFuel") == "started" then
            vehicleProps["fuelLevel"] = exports["LegacyFuel"]:GetFuel(vehicle)
        else
            vehicleProps["fuelLevel"] = GetVehicleFuelLevel(vehicle)
        end

        return vehicleProps
    end
end

HandleAction = function(action)
    if action == "menu" then
        OpenGarageMenu()
    elseif action == "vehicle" then
        PutInVehicle()
    end
end

HandleCamera = function(garage, toggle)
    local Camerapos = Config.Garages[garage]["camera"]

    if not Camerapos then return end

    if not toggle then
        if cachedData["cam"] then
            DestroyCam(cachedData["cam"])
        end
        
        if DoesEntityExist(cachedData["vehicle"]) then
            DeleteEntity(cachedData["vehicle"])
        end

        RenderScriptCams(0, 1, 750, 1, 0)
        return
    end

    if cachedData["cam"] then
        DestroyCam(cachedData["cam"])
    end

    cachedData["cam"] = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)

    SetCamCoord(cachedData["cam"], Camerapos["x"], Camerapos["y"], Camerapos["z"])
    SetCamRot(cachedData["cam"], Camerapos["rotationX"], Camerapos["rotationY"], Camerapos["rotationZ"])
    SetCamActive(cachedData["cam"], true)

    RenderScriptCams(1, 1, 750, 1, 1)
    Citizen.Wait(500)
end

DrawScriptMarker = function(markerData)
    DrawMarker(markerData["type"] or 1, 
        markerData["pos"] or vector3(0.0, 0.0, 0.0), 
        0.0, 0.0, 0.0, 
        (markerData["type"] == 6 and -90.0 or markerData["rotate"] and -180.0) or 0.0, 0.0, 0.0, 
        markerData["sizeX"] or 1.0, 
        markerData["sizeY"] or 1.0, 
        markerData["sizeZ"] or 1.0, 
        markerData["r"] or 1.0, 
        markerData["g"] or 1.0, 
        markerData["b"] or 1.0, 
        100, false, true, 2, false, false, false, false)
end

PlayAnimation = function(ped, dict, anim, settings)
    if dict then
        CreateThread(function()
            RequestAnimDict(dict)

            while not HasAnimDictLoaded(dict) do
                Wait(100)
            end

            if settings == nil then
                TaskPlayAnim(ped, dict, anim, 1.0, -1.0, 1.0, 0, 0, 0, 0, 0)
            else 
                local speed = 1.0
                local speedMultiplier = -1.0
                local duration = 1.0
                local flag = 0
                local playbackRate = 0

                if settings["speed"] then
                    speed = settings["speed"]
                end

                if settings["speedMultiplier"] then
                    speedMultiplier = settings["speedMultiplier"]
                end

                if settings["duration"] then
                    duration = settings["duration"]
                end

                if settings["flag"] then
                    flag = settings["flag"]
                end

                if settings["playbackRate"] then
                    playbackRate = settings["playbackRate"]
                end

                TaskPlayAnim(ped, dict, anim, speed, speedMultiplier, duration, flag, playbackRate, 0, 0, 0)
            end
      
            RemoveAnimDict(dict)
        end)
    else
        TaskStartScenarioInPlace(ped, anim, 0, true)
    end
end

WaitForModel = function(model)
    local DrawScreenText = function(text, red, green, blue, alpha)
        SetTextFont(4)
        SetTextScale(0.0, 0.5)
        SetTextColour(red, green, blue, alpha)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(1, 0, 0, 0, 255)
        SetTextDropShadow()
        SetTextOutline()
        SetTextCentre(true)
    
        BeginTextCommandDisplayText("STRING")
        AddTextComponentSubstringPlayerName(text)
        EndTextCommandDisplayText(0.5, 0.5)
    end

    if not IsModelValid(model) then
        return lib.notify({
            title = 'Erro',
            description = 'Este modelo de veículo não existe',
            type = 'error',
            position = Config.NotificationPosition,
            duration = Config.NotificationDuration
        })
    end

    if not HasModelLoaded(model) then
        RequestModel(model)
    end
    
    while not HasModelLoaded(model) do
        Wait(0)
        DrawScreenText("Carregando veículo " .. GetLabelText(GetDisplayNameFromVehicleModel(model)) .. "...", 255, 255, 255, 150)
    end
end
