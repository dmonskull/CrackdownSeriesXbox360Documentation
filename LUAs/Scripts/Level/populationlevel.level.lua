require "State\\Gang\\Civilians"
require "State\\Gang\\Agency"
require "State\\Gang\\Muchachos"
require "State\\Gang\\Mob"
require "State\\Gang\\Corporation"
require "Config\\\zone\\ZoneInit"


local tZoneManager = cZoneManager:RetZoneManager ()
assert (tZoneManager)

local tGangZone = tZoneManager:RetNamedGangZone ("GangZone0")

tGangZone:SetGangInControl (tMuchachos)
tGangZone:SetInfluence (0.5)

tGangZone:AddPedestrian (0.2, "AIStreetSoldier5", "Config\\NPC\\SimpleWander")
tGangZone:AddPedestrian (0.2, "AIStreetSoldier5", "Config\\NPC\\SimpleWander")
tGangZone:AddPedestrian (0.2, "AIStreetSoldier5", "Config\\NPC\\SimpleWander")
tGangZone:AddPedestrian (0.2, "AIStreetSoldier5", "Config\\NPC\\SimpleWander")
tGangZone:AddPedestrian (0.2, "AIStreetSoldier5", "Config\\NPC\\SimpleWander")
--tGangZone:AddPedestrian (0.16, "AICivilian5", "Config\\NPC\\SimpleWander")
tGangZone:AddDrivenVehicle (0.25, "G1_039_JapaneseCar", nil, "AIStreetSoldier5", "Config\\NPC\\GenericVehicleSpawnScript")
tGangZone:AddDrivenVehicle (0.25, "G1_039_JapaneseCar", nil, "AIStreetSoldier5", "Config\\NPC\\GenericVehicleSpawnScript")
tGangZone:AddDrivenVehicle (0.25, "G1_039_JapaneseCar", nil, "AIStreetSoldier5", "Config\\NPC\\GenericVehicleSpawnScript")
tGangZone:AddDrivenVehicle (0.25, "G1_039_JapaneseCar", nil, "AIStreetSoldier5", "Config\\NPC\\GenericVehicleSpawnScript")

local tPopZone = tZoneManager:RetNamedPopulationZone ("PopZone0")

tPopZone:Clear ()
tPopZone:SetPedestrianDensity (1.0)
tPopZone:AddPedestrian (0.2, "AIStreetSoldier5", "Config\\NPC\\SimpleWander")
tPopZone:AddPedestrian (0.2, "AIStreetSoldier5", "Config\\NPC\\SimpleWander")
tPopZone:AddPedestrian (0.2, "AIStreetSoldier5", "Config\\NPC\\SimpleWander")
tPopZone:AddPedestrian (0.2, "AIStreetSoldier5", "Config\\NPC\\SimpleWander")
tPopZone:AddPedestrian (0.2, "AIStreetSoldier5", "Config\\NPC\\SimpleWander")
--tPopZone:AddPedestrian (0.16, "AIStreetSoldier5", "Config\\NPC\\SimpleWander")
tPopZone:SetVehicleDensity (1.0)
tPopZone:AddDrivenVehicle (0.25, "G1_039_JapaneseCar", nil, "AIStreetSoldier5", "Config\\NPC\\GenericVehicleSpawnScript")
tPopZone:AddDrivenVehicle (0.25, "G1_039_JapaneseCar", nil, "AIStreetSoldier5", "Config\\NPC\\GenericVehicleSpawnScript")
tPopZone:AddDrivenVehicle (0.25, "G1_039_JapaneseCar", nil, "AIStreetSoldier5", "Config\\NPC\\GenericVehicleSpawnScript")
tPopZone:AddDrivenVehicle (0.25, "G1_039_JapaneseCar", nil, "AIStreetSoldier5", "Config\\NPC\\GenericVehicleSpawnScript")


-- Load the global graph
NavigationManager.LoadLogicalGraph("AI\\Default\\global_graph.bin", "GlobalGraph", true)

GangHarassmentType.GangHarassmentType.atCrimeDetails =
{
	{
		sInstanceName =		"001_GangHarassment",
		nMaxGangMembers =	2,
	},
}

GangWarType.GangWarType.atCrimeDetails =
{
	{
		sInstanceName =		"001_GangWar",
	},
}

-- Get the gang manager
local MyGangManager = cGangManager.RetGangManager ()
assert (MyGangManager)

-- Create the gangs
tCivilians = MyGangManager:CreateGangInfo ("Civilians")
tAgency = MyGangManager:CreateGangInfo ("Agency")
tMuchachos = MyGangManager:CreateGangInfo ("Muchachos")
tMob = MyGangManager:CreateGangInfo ("Mob")
tCorporation = MyGangManager:CreateGangInfo ("Corporation")

tCivilians:SetState (Civilians)
tAgency:SetState (Agency)
tMuchachos:SetState (Create (Muchachos,
{
	bProjects = false,
	bHillsideHousing = false,
	bApartments = false,
	bGangHarassment = false,
	bGangWar = false,
}))
tMob:SetState (Mob)
tCorporation:SetState (Corporation)

