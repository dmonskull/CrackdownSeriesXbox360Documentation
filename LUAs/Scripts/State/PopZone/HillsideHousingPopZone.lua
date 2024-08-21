----------------------------------------------------------------------
-- Name: HillsideHousingPopZone State
--	Description: Population zone for the hillside housing area
-- Population density increases significantly after Juan Martinez is dead
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "System\\State"

HillsideHousingPopZone = Create (State, 
{
	sStateName = "HillsideHousingPopZone",
})

function HillsideHousingPopZone:OnEnter ()
	-- Call parent
	State.OnEnter (self)

	-- Check parameters
	assert (self.tHillsideHousingMission)

	-- Set up the mix of pedestrians
	self.tHost:Clear ()

	self.tHost:AddPedestrian (0.5, "AICivilian3", "Config\\NPC\\AmbientPedSpawnScript")
	self.tHost:AddPedestrian (0.5, "AICivilian4", "Config\\NPC\\AmbientPedSpawnScript")
	self.tHost:AddDrivenVehicle (1, "CIV_004_Cabriolet", nil, "AICivilian3", "Config\\NPC\\GenericVehicleSpawnScript")
	
	-- Initialise population density - starts off low because of the gang's presence
	self.tHost:SetPedestrianDensity (1.0)
	self.tHost:SetVehicleDensity (1.0)

	-- Subscribe events
	self.nHillsideHousingEventID = self:Subscribe (eEventType.AIE_CUSTOM, self.tHillsideHousingMission)
end

function HillsideHousingPopZone:OnEvent (tEvent)

	-- The Hillside Housing mission has been completed - Increase the pedestrian population
	if tEvent:HasID (self.nHillsideHousingEventID) and tEvent:HasCustomEventID ("MissionComplete") then

		self.tHost:SetPedestrianDensity (1)
		return true

	end

	-- Call parent
	return State.OnEvent (self, tEvent)
end
