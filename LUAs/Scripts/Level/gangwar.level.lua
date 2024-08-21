require "State\\Gang\\Civilians"
require "State\\Gang\\Agency"
require "State\\Gang\\Muchachos"
require "State\\Gang\\Mob"
require "State\\Gang\\Corporation"
require "Config\\\zone\\ZoneInit"

-- Load the global graph
NavigationManager.LoadLogicalGraph("AI\\Default\\global_graph.bin", "GlobalGraph", true)

GangHarassmentType.GangHarassmentType.atCrimeDetails =
{
	{
		sInstanceName =		"001_GangHarassment",
		nMaxGangMembers =	5,
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
	bGangPatrols = false,
}))
tMob:SetState (Mob)
tCorporation:SetState (Corporation)
