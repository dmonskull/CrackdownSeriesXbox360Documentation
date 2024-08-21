----------------------------------------------------------------------
-- Name: Villa PopZone State
--Description: Population zone for the Villa area
-- Owner: BillG
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "System\\State"

VillaPopZone = Create (State, 
{
	sStateName = "VillaPopZone",
})

function VillaPopZone:OnEnter ()

	-- Call parent
	State.OnEnter (self)

	-- Check parameters
--	assert (self.tVillaMission)

	-- Set up the mix of pedestrians
--	self.tHost:Clear ()
--	self.tHost:AddPedestrian (0.8, "AIStreetSoldier5", "Config\\NPC\\AmbientPedSpawnScript")
--	self.tHost:AddPedestrian (0.2, "AIStreetSoldier5", "Config\\NPC\\StreetSoldierSpawnScript")
--	self.tHost:AddDrivenVehicle (1, "G1_039_JapaneseCar", nil, "AIStreetSoldier5", "Config\\NPC\\GenericVehicleSpawnScript")

	-- Initialise population density - starts off low because of the gang's presence
--	self.tHost:SetPedestrianDensity (0.5)
--	self.tHost:SetVehicleDensity (1)

	-- Subscribe events
--	self.nVillaEventID = self:Subscribe (eEventType.AIE_CUSTOM, self.tVillaMission)
end


