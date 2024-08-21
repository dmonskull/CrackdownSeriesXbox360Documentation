require "State\\Gang\\Civilians"
require "State\\Gang\\Agency"
require "State\\Gang\\Muchachos"
require "State\\Gang\\Mob"
require "State\\Gang\\Corporation"

-- Load the global graph
NavigationManager.LoadLogicalGraph("AI\\Default\\global_graph.bin", "GlobalGraph", true)

-- Load all patrol routes (for seed point generation) SVP 24/08/2005
--require "Config\\PatrolRouteNames.lua"
--for i in pairs(ePatrolRouteNames) do
--	local route = NavigationManager.LoadPatrolRoute(ePatrolRouteNames[i])
--	assert(route)
--end

-- Get the gang manager
local MyGangManager = cGangManager.RetGangManager ()
assert (MyGangManager)

-- Create the gangs
tCivilians = MyGangManager:CreateGangInfo ("Civilians")
tAgency = MyGangManager:CreateGangInfo ("Agency")
tMuchachos = MyGangManager:CreateGangInfo ("Muchachos")
tMob = MyGangManager:CreateGangInfo ("Mob")
tCorporation = MyGangManager:CreateGangInfo ("Corporation")

-- Set up the gangs
tCivilians:SetState (Civilians)
tAgency:SetState (Agency)
tMuchachos:SetState (Create (Muchachos,
{
	-- Bill's Levels
	bHillsideHousing = false,
	bNightclub = false,
	bVilla = false, 
	bNIRace = false, 
	
	
	-- Russ's Levels
	bGarage = false,
	bLighthouse = false,
	bRadio = false,
	
	
	-- Ed's Levels 
	bSportsComplex = false,
	bApartments = false,
	bRooftops = false,	
	
	-- Ambient Crimes - Paul G & Russ 
	bGangHarassment = false, sGangHarassmentConfigScript = "Config\\AmbientCrimes\\DefaultAI.GangHarassment.lua",
	bGangWar = false, sGangWarConfigScript = "Config\\AmbientCrimes\\DefaultAI.GangWar.lua",
	bSGFreakEscape = false, sSGFreakEscapeConfigScript = "Config\\AmbientCrimes\\DefaultAI.SGFreakEscape.lua",
    bLMAssault = false, sLMAssaultConfigScript = "Config\\AmbientCrimes\\DefaultAI.LMAssault.lua",
    	
}))

tMob:SetState (Create (Mob,
{
	bRefinery = true,
}))

tCorporation:SetState (Corporation)

-- Master Tutorial Mission
-- Uncomment this if you want to see how the tutorial mission is supposed to look
--require "State\\Crime\\MasterTutorial\\MasterTutorial"
--self.tMasterTutorialCrime = MissionManager.NewMission ("MasterTutorialCrime", tMuchachos, "MasterTutorialCrimeSpawnPoint")
--self.tMasterTutorialCrime:SetState (MasterTutorial)
