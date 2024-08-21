----------------------------------------------------------------------
-- Name: EmptyWorld State
-- Description: Sets up a world with no missions or crimes (but with gangs)
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "System\\State"

EmptyWorld = Create (State, 
{
	sStateName = "EmptyWorld",
})

function EmptyWorld:OnEnter ()
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
end

function EmptyWorld:OnExit ()
	-- Call parent
	State.OnExit (self)

	-- Delete all the gangs
	local tGangManager = cGangManager.RetGangManager ()
	assert (tGangManager)
	tGangManager:DeleteAllGangs ()
end
