require "System\\State"

HRFacilityPopZone = Create (State, 
{
	sStateName = "HRFacility",
})

function HRFacilityPopZone:OnEnter ()
	-- Call parent
	State.OnEnter (self)

	-- Check parameters
	assert (self.tHRFacility)

	-- Set up the mix of pedestrians
	self.tHost:Clear ()
	self.tHost:AddPedestrian (0.5, "AICivilian3", "Config\\NPC\\AmbientPedSpawnScript")
	self.tHost:AddPedestrian (0.5, "AICivilian4", "Config\\NPC\\AmbientPedSpawnScript")
	self.tHost:AddDrivenVehicle (1, "CIV_004_Cabriolet", nil, "AICivilian3", "Config\\NPC\\GenericVehicleSpawnScript")

	-- Initialise population density - starts off low because of the gang's presence
	self.tHost:SetPedestrianDensity (0.5)
	self.tHost:SetVehicleDensity (1)

	-- Subscribe events
	self.nHRFacilityEventID = self:Subscribe (eEventType.AIE_CUSTOM, self.tHRFacility)
end

function HRFacilityPopZone:OnEvent (tEvent)


end