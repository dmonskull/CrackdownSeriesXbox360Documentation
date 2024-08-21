----------------------------------------------------------------------
-- Name: HillsideHousingPopZone State
--	Description: Population zone for the hillside housing area
-- Population density increases significantly after Juan Martinez is dead
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "System\\State"

NightclubPopZone = Create (State, 
{
	sStateName = "NightclubPopZone",
})

function NightclubPopZone:OnEnter ()
AILib.Emit ("NightclubPopZone.lua OnEnter function running!!")
	-- Call parent
	State.OnEnter (self)

	-- Check parameters
	assert (self.tNightclubMission)

	-- Set up the mix of pedestrians
	self.tHost:Clear ()
	self.tHost:AddPedestrian (0.5, "AICivilian3", "Config\\NPC\\AmbientPedSpawnScript")
	self.tHost:AddPedestrian (0.5, "AICivilian4", "Config\\NPC\\AmbientPedSpawnScript")
	self.tHost:AddDrivenVehicle (1, "CIV_004_Cabriolet", nil, "AICivilian3", "Config\\NPC\\GenericVehicleSpawnScript")

	-- Initialise population density - starts off low because of the gang's presence
	self.tHost:SetPedestrianDensity (0.5)
	self.tHost:SetVehicleDensity (1)

	-- Subscribe events
	self.nNightclubEventID = self:Subscribe (eEventType.AIE_CUSTOM, self.tNightclubMission)
end

--function NightclubPopZone:OnEvent (tEvent)


--	if tEvent:HasID (self.nNightclubEventID) and tEvent:HasCustomEventID ("StateFinished") then

--		self.tHost:SetPedestrianDensity (1)
--		return true

--	end
--
	-- Call parent
--	return State.OnEvent (self, tEvent)
--end
