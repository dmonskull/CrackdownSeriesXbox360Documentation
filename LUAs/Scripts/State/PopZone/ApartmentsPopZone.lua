----------------------------------------------------------------------
-- Name: ApartmentsPopZone State
--	Description: Population zone for the apartments area
-- Population density increases significantly after Violetta Sanchez is dead
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "System\\State"

ApartmentsPopZone = Create (State, 
{
	sStateName = "ApartmentsPopZone",
})

function ApartmentsPopZone:OnEnter ()
	-- Call parent
	State.OnEnter (self)

	-- Check parameters
	assert (self.tApartmentsMission)

	-- Set up the mix of pedestrians
	self.tHost:Clear ()
	self.tHost:AddPedestrian (0.5, "AICivilian3", "Config\\NPC\\AmbientPedSpawnScript")
	self.tHost:AddPedestrian (0.5, "AICivilian4", "Config\\NPC\\AmbientPedSpawnScript")
	self.tHost:AddDrivenVehicle (1, "CIV_004_Cabriolet", nil, "AICivilian3", "Config\\NPC\\GenericVehicleSpawnScript")

	-- Initialise population density - starts off low because of the gang's presence
	self.tHost:SetPedestrianDensity (0.5)
	self.tHost:SetVehicleDensity (1)

	-- Subscribe events
	self.nApartmentsEventID = self:Subscribe (eEventType.AIE_CUSTOM, self.tApartmentsMission)
end

function ApartmentsPopZone:OnEvent (tEvent)

	-- The Apartments mission has been completed - Increase the pedestrian population
	if tEvent:HasID (self.nApartmentsEventID) and tEvent:HasCustomEventID ("StateFinished") then

		self.tHost:SetPedestrianDensity (1)
		return true

	end

	-- Call parent
	return State.OnEvent (self, tEvent)
end
