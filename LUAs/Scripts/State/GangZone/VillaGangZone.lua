----------------------------------------------------------------------
-- Name: Villa Gang Zone
-- Description: Gang zone for the Villa area
-- Owner: BillG
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "System\\State"

VillaGangZone = Create (State, 
{
	sStateName = "VillaGangZone",
})

function VillaGangZone:OnEnter ()


	-- Call parent
	State.OnEnter (self)

	-- Check parameters
	assert (self.tVillaMission)

	-- Initialise control to muchachos
	self.tHost:SetGangInControl (tMuchachos)

	-- Set up mix of gangsters
	self.tHost:Clear ()

	self.tHost:AddPedestrian (0.5, "AIStreetSoldier5", "Config\\NPC\\StreetSoldierSpawnScript")
	self.tHost:AddPedestrian (0.5, "AIStreetSoldier2", "Config\\NPC\\StreetSoldierSpawnScript")

	self.tHost:AddDrivenVehicle (1.0, "G1_039_JapaneseCar", nil, "AIStreetSoldier5", "Config\\NPC\\GenericVehicleSpawnScript")

	
end

