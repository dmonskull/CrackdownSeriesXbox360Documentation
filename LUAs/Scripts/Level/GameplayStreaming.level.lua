require "Config\\\zone\\ZoneInit"

function SetupM12Zones ()
	local MyGangManager = cGangManager.RetGangManager ()
	assert (MyGangManager)

	tCivilians = MyGangManager:CreateGangInfo (-1, "Civilians")
	tAgency = MyGangManager:CreateGangInfo (0, "Agency")
	tMuchachos = MyGangManager:CreateGangInfo (1, "Muchachos")
	tMob = MyGangManager:CreateGangInfo (2, "Mob")
	tCorporation = MyGangManager:CreateGangInfo (3, "Corporation")

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

SetupM12Zones ()

-- load logical graph (<filename>, <spatial graph name>, <global>)
NavigationManager.LoadLogicalGraph("AI\\Default\\global_graph.bin", "GlobalGraph", true)
