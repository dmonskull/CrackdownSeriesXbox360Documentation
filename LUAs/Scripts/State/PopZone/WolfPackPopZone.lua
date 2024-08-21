require "System\\State"

WolfPackPopZone = Create (State, 
{
	sStateName = "WolfPackPopZone",
})

function WolfPackPopZone:OnEnter ()
	-- Call parent
	State.OnEnter (self)

	-- Check parameters
	assert (self.tWolfPackMission)

	-- Set up the mix of pedestrians
	self.tHost:Clear ()
	self.tHost:AddPedestrian (0.5, "AICivilian3", "Config\\NPC\\AmbientPedSpawnScript")
	self.tHost:AddPedestrian (0.5, "AICivilian4", "Config\\NPC\\AmbientPedSpawnScript")
	self.tHost:AddDrivenVehicle (1, "CIV_004_Cabriolet", nil, "AICivilian3", "Config\\NPC\\GenericVehicleSpawnScript")

	-- Initialise population density - starts off low because of the gang's presence
	self.tHost:SetPedestrianDensity (0.5)
	self.tHost:SetVehicleDensity (1)

	-- Subscribe events
	self.nWolfPackEventID = self:Subscribe (eEventType.AIE_CUSTOM, self.tWolfPackMission)
end

function WolfPackPopZone:OnEvent (tEvent)


end
