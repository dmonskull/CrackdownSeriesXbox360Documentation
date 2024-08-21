----------------------------------------------------------------------
-- Name: World State
-- Description: Initialises and destroys the world
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "System\\State"
require "State\\Gang\\Civilians"
require "State\\Gang\\Agency"
require "State\\Gang\\Muchachos"
require "State\\Gang\\Mob"
require "State\\Gang\\Corporation"

World = Create (State, 
{
	sStateName = "World",
})

function World:OnEnter ()
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
		-- Bill's Levels
		bHillsideHousing = true,
		bNightclub = true,
		bVilla = true, 
		bNIRace = true, 
		
		
		-- Russ's Levels
		bGarage = false,
		bLighthouse = false,
		bRadio = false,
		
		
		-- Ed's Levels 
		bSportsComplex = true,
		bApartments = true,
		bRooftops = false,
		
		
		-- Ambient Crimes - Paul G & Russ 
		bGangHarassment = true, sGangHarassmentConfigScript = "Config\\AmbientCrimes\\DefaultAI.GangHarassment.lua",
		bGangWar = true, sGangWarConfigScript = "Config\\AmbientCrimes\\DefaultAI.GangWar.lua",
		bSGFreakEscape = false, sSGFreakEscapeConfigScript = "Config\\AmbientCrimes\\DefaultAI.SGFreakEscape.lua",
		bLMAssault = false, sLMAssaultConfigScript = "Config\\AmbientCrimes\\DefaultAI.LMAssault.lua",
			
	}))
	
	tMob:SetState (Mob)
	tCorporation:SetState (Corporation)
end

function World:OnExit ()
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
