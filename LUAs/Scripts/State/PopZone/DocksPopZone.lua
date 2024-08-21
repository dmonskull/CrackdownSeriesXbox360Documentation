----------------------------------------------------------------------
-- Name: DocksPopZone State
--	Description: Population zone for the hillside housing area
-- Population density increases significantly after Juan Martinez is dead
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "System\\State"

DocksPopZone = Create (State, 
{
	sStateName = "DocksPopZone",
})

function DocksPopZone:OnEnter ()
	-- Call parent
	State.OnEnter (self)

	-- Check parameters
	assert (self.tDocksMission)

	-- Set up the mix of pedestrians
	self.tHost:Clear ()

	self.tHost:AddPedestrian (0.25, "AICivilian4", "Config\\NPC\\AmbientPedSpawnScript")
	self.tHost:AddPedestrian (0.25, "AICivilian4", "Config\\NPC\\AmbientPedSpawnScript")
	self.tHost:AddPedestrian (0.25, "AICivilian4", "Config\\NPC\\AmbientPedSpawnScript")
	self.tHost:AddPedestrian (0.25, "AICivilian4", "Config\\NPC\\AmbientPedSpawnScript")
	--self.tHost:AddPedestrian (1.0, "AIStreetSoldier1", "Config\\NPC\\AmbientPedSpawnScript")

	self.tHost:AddDrivenVehicle (0.5, "G1_039_JapaneseCar", nil, "AICivilian4", "Config\\NPC\\GenericVehicleSpawnScript")
	self.tHost:AddDrivenVehicle (0.5, "G1_039_JapaneseCar", nil, "AICivilian4", "Config\\NPC\\GenericVehicleSpawnScript")
	self.tHost:AddDrivenVehicle (0.33, "G1_039_JapaneseCar", nil, "AICivilian4", "Config\\NPC\\GenericVehicleSpawnScript")
	
	-- Initialise population density - starts off low because of the gang's presence
	self.tHost:SetPedestrianDensity (1.0)
	self.tHost:SetVehicleDensity (1)

	-- Subscribe events
	self.nDocksEventID = self:Subscribe (eEventType.AIE_CUSTOM, self.tDocksMission)
end

function DocksPopZone:OnEvent (tEvent)

	-- The Hillside Housing mission has been completed - Increase the pedestrian population
	if tEvent:HasID (self.nDocksEventID) and tEvent:HasCustomEventID ("MissionComplete") then

		self.tHost:SetPedestrianDensity (1)
		return true

	end

	-- Call parent
	return State.OnEvent (self, tEvent)
end
