----------------------------------------------------------------------
-- Name: DriveTrafficVehicle State
--	Description: Drive randomly around the roads
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "System\\State"

DriveTrafficVehicle = Create (State, 
{
	sStateName = "DriveTrafficVehicle",
})

function DriveTrafficVehicle:OnEnter ()
	-- Call parent
	State.OnEnter (self)

	-- Make sure we are in a vehicle
	self.tVehicle = self.tHost:RetVehicle ()
	assert (self.tVehicle)

	-- Subscribe to drop finished event
	self.nEjectedFromVehicleID = self:Subscribe (eEventType.AIE_EJECTED_FROM_VEHICLE, self.tHost)

	self:OnResume ()
end

function DriveTrafficVehicle:OnResume ()
	-- Call parent
	State.OnResume (self)

	-- Go into Idle brain state
	self.tHost:DriveTrafficVehicle ()
end

function DriveTrafficVehicle:OnPause ()
	-- Clean up the brain state
	self.tHost:ClearBrainState ()

	-- Call parent
	State.OnPause (self)
end

function DriveTrafficVehicle:OnExit ()
	self:OnPause ()

	-- Call parent
	State.OnExit (self)
end

function DriveTrafficVehicle:OnEvent (tEvent)
	
	if tEvent:HasID (self.nEjectedFromVehicleID) then

		-- Ejected from the vehicle!  Finish the state
		self:Finish ()
		return true

	end

	-- Call parent
	return State.OnEvent (self, tEvent)
end
