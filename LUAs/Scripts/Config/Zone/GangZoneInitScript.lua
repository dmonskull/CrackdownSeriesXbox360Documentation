-- DEPRECATED - NJR 19/7/2005


-- Gang Zone intialisation script example

return function (GangZone)
	GangZone:Clear ()

	-- Set the gang that will initially be in control of this gang zone
	GangZone:SetGangInControl (tMuchachos)

	-- The influence of the gang in the zone. I.e. The ratio of gang members to ambient population.
	-- E.g. an influence factor of 0.5 indicates that 75% of the population are gang affiliated and 25% are ambient.
	GangZone:SetInfluence (0.5)

	GangZone:AddPedestrian (0.4, "AIStreetSoldier5", "Config\\NPC\\StreetSoldierSpawnScript")
	GangZone:AddPedestrian (0.4, "AIStreetSoldier5", "Config\\NPC\\StreetSoldierSpawnScript")
	GangZone:AddPedestrian (0.2, "AIStreetSoldier5", "Config\\NPC\\StreetSoldierSpawnScript")

	GangZone:AddDrivenVehicle (0.5, "G1_039_JapaneseCar", nil, "AIStreetSoldier5", "Config\\NPC\\GenericVehicleSpawnScript")
	GangZone:AddDrivenVehicle (0.5, "G1_039_JapaneseCar", nil, "AIStreetSoldier5", "Config\\NPC\\GenericVehicleSpawnScript")
end
