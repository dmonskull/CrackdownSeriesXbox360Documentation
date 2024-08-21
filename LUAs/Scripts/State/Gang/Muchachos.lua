----------------------------------------------------------------------
-- Name: Muchachos Gang State
--	Description: Create missions and set up variables for the Muchachos
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "System\\State"
require "State\\Mission\\Projects\\Projects"
require "State\\Mission\\HillsideHousing\\HillsideHousing"
require "State\\Mission\\Nightclub\\Nightclub"
require "State\\Mission\\Villa\\Villa"
require "State\\Mission\\Apartments\\Apartments"
require "State\\Mission\\SportsComplex\\SportsComplex"
require "State\\Mission\\Rooftops\\Rooftops"
require "State\\Mission\\Garage\\Garage"
require "State\\Mission\\Docks\\Docks"                     -- Russ, Move to Mob
require "State\\Mission\\GangPatrols\\GangPatrols"
require "State\\Crime\\GangHarassment\\GangHarassmentType"
require "State\\Crime\\GangWar\\GangWarType"
require "State\\Crime\\SGFreakEscape\\SGFreakEscapeType"   -- russ move to corp
require "State\\Crime\\LMAssault\\LMAssaultType"
require "State\\Mission\\NIRace\\NIRace"

Muchachos = Create (State, 
{
	sStateName = "Muchachos",
	
	-- Unknown Missions -- No owner
	bGangPatrols = false,  	-- Suspect this was made for press demo 
	
	--Ed's 
	bApartments = false,
	bSportsComplex = false,
	bRooftops = false,	-- Added for X05 probably redundant now, should be cleaned. 
		
	-- Russ's 
	bGarage = false,
    bDocks = false,   -- Russ, move to mob
	
	-- Bill's 
	bNightclub = false,
	bVilla = false,
	bHillsideHousing = false,
	bNIRace = false, 
	
		
	-- Ambient crimes -- Paul G & Russ
	bGangHarassment = false, sGangHarassmentConfigScript = "",
	bGangWar = false, sGangHarassmentConfigScript = "",
	bSGFreakEscape = false, sSGFreakEscapeConfigScript = "",   -- russ move to corp
    bLMAssault = false, sLMAssaultConfigScript = "", 
})

function Muchachos:OnEnter ()
	-- Call parent
		State.OnEnter (self)

	-- Set up relationships - Muchachos hate the Agency and the Mob
	self.tHost:SetGangRelationship (tCivilians, eRelationship.nNeutral)
	self.tHost:SetGangRelationship (tAgency, eRelationship.nEnemy)
	self.tHost:SetGangRelationship (tMuchachos, eRelationship.nFriend)
	self.tHost:SetGangRelationship (tMob, eRelationship.nEnemy)
	self.tHost:SetGangRelationship (tCorporation, eRelationship.nNeutral)

	-- Set up the variables initially
	self.tHost:SetRecruitment (1)
	self.tHost:SetEquipmentAvailability (1)

	--* No Owner *--
	-- The GangPatrols mission
	if self.bGangPatrols then
		self.tGangPatrolsMission = self:NewMission ("GangPatrolsMission", self.tHost, "SP_PJ_Rodrigo")
		self.tGangPatrolsMission:SetState(GangPatrols.GangPatrols)
	end
	
	
	--* Ambient Crimes - Paul G & Russ F *-------
    	
    	-- Create LMAssault ambient crime type -- Russ
	if self.bLMAssault then
		Emit ("Loading LMAssault ambient crime")
		self.tLMAssaultType = self:NewAmbientCrimeType ("LMAssault")
		self.tLMAssaultType:SetState (LMAssaultType.LMAssaultType)
		LMAssaultType.LMAssaultType:RunConfigScript (self.sLMAssaultConfigScript) 
	end

	-- Create the GangHarassment ambient crime type
	if self.bGangHarassment then
		Emit ("Loading GangHarassment ambient crime")
		self.tGangHarassmentType = self:NewAmbientCrimeType ("GangHarassment")
		self.tGangHarassmentType:SetState (GangHarassmentType.GangHarassmentType)
		GangHarassmentType.GangHarassmentType:RunConfigScript (self.sGangHarassmentConfigScript)
	end

	-- Create GangWar ambient crime type
	if self.bGangWar then
		Emit ("Loading GangWar ambient crime")
		self.tGangWarType = self:NewAmbientCrimeType ("GangWar")
		self.tGangWarType:SetState (GangWarType.GangWarType)
		GangWarType.GangWarType:RunConfigScript (self.sGangWarConfigScript)
	end

	-- Create SGFreakEscape ambient crime type   -- Russ  (Move to Corp when setup)
	if self.bSGFreakEscape then
		Emit ("Loading SGFreakEscape ambient crime")
		self.tSGFreakEscapeType = self:NewAmbientCrimeType ("SGFreakEscape")
		self.tSGFreakEscapeType:SetState (SGFreakEscapeType.SGFreakEscapeType)
		SGFreakEscapeType.SGFreakEscapeType:RunConfigScript (self.sSGFreakEscapeConfigScript) 
	end
	
	--* Ed's missions *--

	-- The apartments mission
	if self.bApartments then
		self.tApartmentsMission = self:NewMission ("ApartmentsMission", self.tHost, "SP_AP_Vio_Podium00")
		self.tApartmentsMission:SetState(Apartments.Apartments)
	end
	
	-- The sports complex mission
	if self.bSportsComplex then
		self.tSportsComplexMission = self:NewMission ("SportsComplexMission", self.tHost, "SP_SC_Rod_Bar00")
		self.tSportsComplexMission:SetState(SportsComplex.SportsComplex)
	end

	-- The additional rooftops guards mission
	if self.bRooftops then
		self.tRooftopsMission = self:NewMission ("RooftopsMission", self.tHost, "SP_ADD_Rooftop00")
		self.tRooftopsMission:SetState(Rooftops.Rooftops)
	end

	--* Russ's missions *--	
	
	-- The garage mission - Northy - TO BE CLEANED by Russ
	if self.bGarage then
		self.tGarageMission = self:NewMission ("GarageMission", self.tHost, "GA_SP_Garage")
		self.tGarageMission:SetState(Garage.Garage)
	end
    
    -- The Docks mission -- Russ to be moved to mob
	if self.bDocks then
		self.tDocksMission = self:NewMission ("DocksMission", self.tHost, "SP_Docks_Mission_Ship_SpawnPoint")
        self.tDocksMission:SetRadius (500)
		self.tDocksMission:SetState(Docks.Docks)
	end
		
	--* Bill's missions *--	

	-- The Villa mission
	if self.bVilla then
		self.tVillaMission = self:NewMission ("VillaMission", self.tHost, "SP_Vi_BalcGrd01")
		self.tVillaMission:SetState(Villa.Villa)
		--self.nVillaEventID = self:Subscribe (eEventType.AIE_CUSTOM, self.tVillaMission) -- NOT NEEDED YET 
	end
	
	-- The Nightclub mission
	if self.bNightclub then
		self.tNightclubMission = self:NewMission ("NightclubMission", self.tHost, "SP_MainGateGrds")
		self.tNightclubMission:SetState(Nightclub.Nightclub)
		--self.nNightclubEventID = self:Subscribe (eEventType.AIE_CUSTOM, self.tNightclubMission) -- NOT NEEDED YET
	end

	-- The Hillside Housing mission
	if self.bHillsideHousing then
		self.tHillsideHousingMission = self:NewMission ("HillsideHousingMission", self.tHost, "SP_HH_JuanMartinez")
		self.tHillsideHousingMission:SetState (HillsideHousing.HillsideHousing)
		self.nHillsideHousingEventID = self:Subscribe (eEventType.AIE_CUSTOM, self.tHillsideHousingMission)
	end
	
	-- The North Island Race mission
	if 	self.bNIRace then
		self.tRaceMission = self:NewRaceMission ("NIRaceMission", self.tHost, "RaceStartPosition")
		self.tRaceMission:SetState (NIRace.NIRace)
	--	self.nRaceEventID = self:Subscribe (eEventType.AIE_CUSTOM, self.tRaceMission)
	end
	
end

function Muchachos:OnEvent (tEvent)

	if self.bHillsideHousing and 
		tEvent:HasID (self.nHillsideHousingEventID) and 
		tEvent:HasCustomEventID ("MissionComplete") then

		-- Juan Martinez has been assassinated - reduce equipment availability and recruitment
		self.tHost:SetEquipmentAvailability (0)
		self.tHost:SetRecruitment (0)
		return true

	end

	-- Call parent
	State.OnEvent (self, tEvent)
end
