require "State\\Gang\\Civilians"
require "State\\Gang\\Agency"
require "State\\Gang\\Muchachos"
require "State\\Gang\\Mob"
require "State\\Gang\\Corporation"

-- Load the global graph
NavigationManager.LoadLogicalGraph("AI\\Default\\global_graph.bin", "GlobalGraph", true)

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
	bGarage = true,
}))
tMob:SetState (Mob)
tCorporation:SetState (Corporation)

