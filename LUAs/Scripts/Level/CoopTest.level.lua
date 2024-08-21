require "Config\\\zone\\ZoneInit"

function SetupM12Zones ()
	local MyGangManager = cGangManager.RetGangManager ()
	assert (MyGangManager)

	tCivilians = MyGangManager:CreateGangInfo ("Civilians")
	tAgency = MyGangManager:CreateGangInfo ("Agency")
	tMuchachos = MyGangManager:CreateGangInfo ("Muchachos")
	tMob = MyGangManager:CreateGangInfo ("Mob")
	tCorporation = MyGangManager:CreateGangInfo ("Corporation")
	
	assert (GangZoneScripts)
	assert (PopulationZoneScripts)

	local MyZoneManager = cZoneManager:RetZoneManager ()
	
	for key, value in pairs (GangZoneScripts) do
		local fnInit = assert (RunScript (value))
		fnInit (MyZoneManager:RetNamedGangZone (key))
	end

	for key, value in pairs (PopulationZoneScripts) do
		local fnInit = assert (RunScript (value))
		fnInit (MyZoneManager:RetNamedPopulationZone (key))
	end

end

-- load logical graph (<filename>, <spatial graph name>, <global>)
NavigationManager.LoadLogicalGraph("AI\\M12\\global_graph.bin", "GlobalGraph", true)

SetupM12Zones ()

-- Spawn a convenient victim for the GangHarassment crime
cAIPlayer.SpawnNPCAtNamedLocationWithScript ( "AICivilian4", "PedestrianStart", "Config\\NPC\\AmbientPedSpawnScript" )
