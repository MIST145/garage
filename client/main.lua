Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57, 
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177, 
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70, 
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

ESX = exports['es_extended']:getSharedObject()
cachedData = {}

-- Initialize ESX and setup
CreateThread(function()
	if Config.Impound then
		Wait(1000)
		refreshBlips()
	end

	if Config.VehicleMenu then
		while true do
			Wait(5)
			if IsControlJustPressed(0, Config.VehicleMenuButton) then
				lib.hideContext()
				OpenVehicleMenu()
			end
		end
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(playerData)
	ESX.PlayerData = playerData
end)

CreateThread(function()
	local CanDraw = function(action)
		if action == "vehicle" then
			if IsPedInAnyVehicle(PlayerPedId()) then
				local vehicle = GetVehiclePedIsIn(PlayerPedId())
				if GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() then
					return true
				else
					return false
				end
			else
				return false
			end
		end
		return true
	end

	local GetDisplayText = function(action, garage)
		if not Config.Labels[action] then Config.Labels[action] = action end
		return string.format(Config.Labels[action], action == "vehicle" and GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(GetVehiclePedIsUsing(PlayerPedId())))) or garage)
	end

	-- Create garage blips
	for garage, garageData in pairs(Config.Garages) do
		local garageBlip = AddBlipForCoord(garageData["positions"]["menu"]["position"])
		SetBlipSprite(garageBlip, 357)
		SetBlipDisplay(garageBlip, 4)
		SetBlipScale(garageBlip, 0.6)
		SetBlipColour(garageBlip, 67)
		SetBlipAsShortRange(garageBlip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("Garagem: " .. garage)
		EndTextCommandSetBlipName(garageBlip)
	end

	-- Main garage interaction loop
	while true do
		local sleepThread = 500
		local ped = PlayerPedId()
		local pedCoords = GetEntityCoords(ped)

		for garage, garageData in pairs(Config.Garages) do
			for action, actionData in pairs(garageData["positions"]) do
				local dstCheck = #(pedCoords - actionData["position"])

				if dstCheck <= 10.0 then
					sleepThread = 5
					local draw = CanDraw(action)

					if draw then
						local markerSize = action == "vehicle" and 5.0 or 1.5

						if dstCheck <= markerSize - 0.1 then
							local usable, displayText = not DoesCamExist(cachedData["cam"]), GetDisplayText(action, garage)

							if usable then
								lib.showTextUI(displayText, {
									position = Config.NotificationPosition or 'top'
								})
							else
								lib.showTextUI("Escolhe o veículo.", {
									position = Config.NotificationPosition or 'top'
								})
							end

							if usable and IsControlJustPressed(0, 38) then
								cachedData["currentGarage"] = garage
								HandleAction(action)
							end
						else
							lib.hideTextUI()
						end
    					
						DrawScriptMarker({
							["type"] = 6,
							["pos"] = actionData["position"] - vector3(0.0, 0.0, 0.985),
							["sizeX"] = markerSize,
							["sizeY"] = markerSize,
							["sizeZ"] = markerSize,
							["rotate"] = -180.0,
							["r"] = 0,
							["g"] = 150,
							["b"] = 150
						})
					end
				else
					lib.hideTextUI()
				end
			end
		end

		Wait(sleepThread)
	end
end)

if Config.Impound then
	-- Open Main Menu
	function OpenMenuGarage(PointType)
		lib.registerContext({
			id = 'garage_main_menu',
			title = 'Impound',
			options = {
				{
					title = 'Carros apreendidos',
					description = 'Custo: €' .. Config.ImpoundPrice,
					icon = 'car',
					onSelect = function()
						ReturnOwnedCarsMenu()
					end
				}
			}
		})
		lib.showContext('garage_main_menu')
	end

	-- Pound Owned Cars Menu
	function ReturnOwnedCarsMenu()
		ESX.TriggerServerCallback('garage:getOutOwnedCars', function(ownedCars)
			local options = {}
			
			for _, v in pairs(ownedCars) do
				local vehicleName = GetLabelText(GetDisplayNameFromVehicleModel(v.model))
				if Config.UseVehicleNamesLua == true then
					vehicleName = GetLabelText(GetDisplayNameFromVehicleModel(v.model))
				else
					vehicleName = GetDisplayNameFromVehicleModel(v.model)
				end
				
				table.insert(options, {
					title = vehicleName,
					description = 'Matrícula: ' .. v.plate .. ' | Clica para recuperar',
					icon = 'car',
					metadata = {
						{label = 'Matrícula', value = v.plate},
						{label = 'Custo', value = '€' .. Config.ImpoundPrice}
					},
					onSelect = function()
						ESX.TriggerServerCallback('garage:checkMoneyCars', function(hasEnoughMoney)
							if hasEnoughMoney then
								TriggerServerEvent('garage:payCar')
								SpawnPoundedVehicle(v, v.plate)
								lib.hideContext()
							else
								lib.notify({
									title = 'Erro',
									description = 'Não tens dinheiro suficiente no banco',
									type = 'error',
									position = Config.NotificationPosition,
									duration = Config.NotificationDuration
								})
							end
						end)
					end
				})
			end

			if #options == 0 then
				table.insert(options, {
					title = 'Sem veículos',
					description = 'Não tens veículos apreendidos',
					icon = 'exclamation-triangle',
					disabled = true
				})
			end
			
			lib.registerContext({
				id = 'impound_cars_menu',
				title = 'Carros Apreendidos',
				menu = 'garage_main_menu',
				options = options
			})
			lib.showContext('impound_cars_menu')
		end)
	end

	-- Entered Marker
	AddEventHandler('garage:hasEnteredMarker', function(zone)
		if zone == 'car_pound_point' then
			CurrentAction = 'car_pound_point'
			CurrentActionMsg = 'Pressiona [E] para acessar os apreendidos'
			CurrentActionData = {}
		end
	end)

	-- Exited Marker
	AddEventHandler('garage:hasExitedMarker', function()
		lib.hideContext()
		CurrentAction = nil
	end)

	-- Impound Draw Markers
	CreateThread(function()
		while true do
			Wait(1)
			
			local playerPed = PlayerPedId()
			local coords = GetEntityCoords(playerPed)

			-- Car Pounds
			for k, v in pairs(Config.CarPounds) do
				if (#(coords - vector3(v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z)) < Config.DrawDistance) then
					DrawMarker(Config.MarkerType, v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.PoundMarker.x, Config.PoundMarker.y, Config.PoundMarker.z, Config.PoundMarker.r, Config.PoundMarker.g, Config.PoundMarker.b, 100, false, true, 2, false, false, false, false)
				end
			end
		end
	end)

	-- Activate Menu when in Markers
	CreateThread(function()
		while true do
			Wait(5)
			
			local playerPed = PlayerPedId()
			local coords = GetEntityCoords(playerPed)
			local isInMarker = false

			-- Car Pounds
			for k, v in pairs(Config.CarPounds) do
				if (#(coords - vector3(v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z)) < Config.PoundMarker.x) then
					isInMarker = true
					this_Garage = v
					currentZone = 'car_pound_point'
				end
			end

			if isInMarker and not hasAlreadyEnteredMarker then
				hasAlreadyEnteredMarker = true
				LastZone = currentZone
				TriggerEvent('garage:hasEnteredMarker', currentZone)
			end
			
			if not isInMarker and hasAlreadyEnteredMarker then
				hasAlreadyEnteredMarker = false
				TriggerEvent('garage:hasExitedMarker', LastZone)
			end	
		end
	end)

	-- Key Controls
	CreateThread(function()
		while true do
			Wait(0)
			
			if CurrentAction ~= nil then
				lib.showTextUI(CurrentActionMsg, {
					position = Config.NotificationPosition or 'top'
				})
				
				if IsControlJustReleased(0, Keys['E']) then
					if CurrentAction == 'car_pound_point' then
						OpenMenuGarage('car_pound_point')
					end
					CurrentAction = nil
					lib.hideTextUI()
				end
			else
				Wait(500)
			end
		end
	end)

	function refreshBlips()
		local blipList = {}
		local count = 0

		-- Car Pounds
		for k, v in pairs(Config.CarPounds) do
			count = count + 1
			table.insert(blipList, {
				coords = { v.PoundPoint.x, v.PoundPoint.y },
				text = Config.ImpoundName,
				sprite = Config.BlipImpound.Sprite,
				color = Config.BlipImpound.Color,
				scale = Config.BlipImpound.Scale
			})
		end

		for i = 1, #blipList, 1 do
			CreateBlip(blipList[i].coords, blipList[i].text, blipList[i].sprite, blipList[i].color, blipList[i].scale)
		end
	end

	function CreateBlip(coords, text, sprite, color, scale)
		local blip = AddBlipForCoord(table.unpack(coords))
		SetBlipSprite(blip, sprite)
		SetBlipScale(blip, scale)
		SetBlipColour(blip, color)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName('STRING')
		AddTextComponentSubstringPlayerName(text)
		EndTextCommandSetBlipName(blip)
	end

	-- Spawn Pound Cars
	function SpawnPoundedVehicle(vehicle, plate)
		ESX.Game.SpawnVehicle(vehicle.model, {
			x = this_Garage.SpawnPoint.x,
			y = this_Garage.SpawnPoint.y,
			z = this_Garage.SpawnPoint.z + 1
		}, this_Garage.SpawnPoint.h, function(callback_vehicle)
			ESX.Game.SetVehicleProperties(callback_vehicle, vehicle)
			SetVehRadioStation(callback_vehicle, "OFF")
			lib.notify({
				title = 'Sucesso',
				description = 'Veículo recuperado com sucesso',
				type = 'success',
				position = Config.NotificationPosition,
				duration = Config.NotificationDuration
			})
		end)
	end
end
