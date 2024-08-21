require "System\\State"

ResearchCentreGangZone = Create (State, 
{
	sStateName = "ResearchCentreGangZone",
})

function ResearchCentreGangZone:OnEnter ()


	-- Call parent
	State.OnEnter (self)

	-- Check parameters
	assert (self.tResearchCentreMission)

	-- Initialise control to Corporation
	self.tHost:SetGangInControl (tCorporation)

	-- Set up mix of gangsters
	self.tHost:Clear ()

	self.tHost:AddPedestrian (0.5, "AIStreetSoldier5", "Config\\NPC\\StreetSoldierSpawnScript")
	self.tHost:AddPedestrian (0.5, "AIStreetSoldier2", "Config\\NPC\\StreetSoldierSpawnScript")

	self.tHost:AddDrivenVehicle (1.0, "G1_039_JapaneseCar", nil, "AIStreetSoldier5", "Config\\NPC\\GenericVehicleSpawnScript")

	
end