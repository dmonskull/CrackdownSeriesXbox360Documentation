require "Config\\\zone\\ZoneInit"

function SetupM12Zones ()
	local MyGangManager = cGangManager.RetGangManager ()
	assert (MyGangManager)

	tCivilians = MyGangManager:CreateGangInfo ("Civilians")
	tAgency = MyGangManager:CreateGangInfo ("Agency")
	tMuchachos = MyGangManager:CreateGangInfo ("Muchachos")
	tMob = MyGangManager:CreateGangInfo ("Mob")
	tCorporation = MyGangManager:CreateGangInfo ("Corporation")

	assert (GangScripts)
	assert (GangZoneScripts)
	assert (PopulationZoneScripts)

	for key, value in pairs (GangScripts) do
		local fnInit = assert (RunScript (value))
	
		fnInit (MyGangManager:RetGangInfoByName (key))
	end

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

SetupM12Zones ()

-- load logical graph (<filename>, <spatial graph name>, <global>)
NavigationManager.LoadLogicalGraph("AI\\GameplayTest\\global_graph.bin", "GlobalGraph", true)
