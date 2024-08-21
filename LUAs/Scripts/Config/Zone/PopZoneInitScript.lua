-- DEPRECATED - NJR 19/7/2005



--Population zone initialisation script example

return function (PopZone)

	-- Removes all previously added population (if any) from the population zone.
	PopZone:Clear ()

	-- Set the pedestrian density of this zone: 0.0 -> no pedestrians; 1.0 -> max pedestrians
	PopZone:SetPedestrianDensity (1.0)

	-- Adds an AI Player prototype to be spawned in the population zone. The function has the following format:
	--
	--		AddPedestrianWithScript (<spawn probability (0.0 to 1.0)>, <prototype name>, <initialisation script>)
	--
	-- Don't worry too much about the initialisation script. These will ultimately be used to configure spawned NPCs with
	-- specific AI behaviours and skill setups but just use the AmbientPedSpawnScript for now (default ped behaviour.)
	--
	-- E.g. The following two lines implies a 75% chance of spawning an "AI Civilian" and a 25% chance of spawning an "AI Civilian 2"
	PopZone:AddPedestrian (0.3, "AIStreetSoldier5", "Config\\NPC\\AmbientPedSpawnScript")
	PopZone:AddPedestrian (0.2, "AIStreetSoldier5", "Config\\NPC\\AmbientPedSpawnScript")
	PopZone:AddPedestrian (0.2, "AIStreetSoldier5", "Config\\NPC\\AmbientPedSpawnScript")
	PopZone:AddPedestrian (0.2, "AIStreetSoldier5", "Config\\NPC\\StreetSoldierSpawnScript")


	-- Removes all previously added vehicles (if any) from the population zone.
	-- Set the vehicle density of this zone: 0.0 -> no vehicles; 1.0 -> max vehicles
	PopZone:SetVehicleDensity (1.0)

	-- Adds a vehicle prototype to be spawned in the population zone. The function has the following format:
	--
	--		AddVehicleWithScript (<spawn probability (0.0 to 1.0)>, <prototype name>, <vehicle script>, <driver prototype name>, <driver script>)
	--
	-- Don't worry too much about the initialisation script. These will ultimately be used to configure spawned vehicles
	-- and drivers with specific AI behaviours and skill setups but just use the GenericVehicleSpawnScript for now
	-- (default vehicle and driver behaviour.)

	PopZone:AddDrivenVehicle (0.3, "G1_039_JapaneseCar", nil, "AIStreetSoldier5", "Config\\NPC\\GenericVehicleSpawnScript")
	PopZone:AddDrivenVehicle (0.3, "G1_039_JapaneseCar", nil, "AIStreetSoldier5", "Config\\NPC\\GenericVehicleSpawnScript")
	PopZone:AddDrivenVehicle (0.3, "G1_039_JapaneseCar", nil, "AIStreetSoldier5", "Config\\NPC\\GenericVehicleSpawnScript")
	PopZone:AddDrivenVehicle (0.05, "G1_039_JapaneseCar", nil, "AIStreetSoldier5", "Config\\NPC\\GenericVehicleSpawnScript")
	PopZone:AddDrivenVehicle (0.05, "G1_039_JapaneseCar", nil, "AIStreetSoldier5", "Config\\NPC\\GenericVehicleSpawnScript")

end
