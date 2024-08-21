----------------------------------------------------------------------
-- Name: BillWorld State
-- Description: Initialises and destroys the BillLevel world
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "System\\State"
require "State\\Gang\\Civilians"
require "State\\Gang\\Agency"
require "State\\Gang\\Muchachos"
require "State\\Gang\\Mob"
require "State\\Gang\\Corporation"

BillWorld = Create (State, 
{
	sStateName = "BillWorld",
})

function BillWorld:OnEnter ()
	-- Call parent
	State.OnEnter (self)

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
		bNightclub = false,
		bVilla = false,
		bHillsideHousing = false, 
		bNIRace = false, 

	}))
	
	tMob:SetState (Mob)
	tCorporation:SetState (Create (Corporation,
	{
		bPRComplex = true, 
		bIntelComplex = true, 
	}))

end

function BillWorld:OnExit ()
	-- Call parent
	State.OnExit (self)

	-- Clear all the gang states - this deletes all the missions etc
	tCivilians:ClearState ()
	tAgency:ClearState ()
	tMuchachos:ClearState ()
	tMob:ClearState ()
	tCorporation:ClearState ()

	-- Now delete all the gangs
	local tGangManager = cGangManager.RetGangManager ()
	assert (tGangManager)
	tGangManager:DeleteAllGangs ()
end
