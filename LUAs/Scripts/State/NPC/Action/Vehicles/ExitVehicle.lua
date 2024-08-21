----------------------------------------------------------------------
-- Name: ExitVehicle State
--	Description: Exits the vehicle we are currently in
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"

ExitVehicle = Create (TargetState, 
{
	sStateName = "ExitVehicle",
	nTargetInfoFlags = 0,
	bTargetMandatory = false,
	bSuccess = false,
})

function ExitVehicle:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)

	-- Subscribe to drop finished event
	self.nExitVehicleFinishedID = self:Subscribe (eEventType.AIE_EXIT_VEHICLE_FINISHED, self.tHost)

	self:OnResume ()
end

function ExitVehicle:OnResume ()
	-- Call parent
	TargetState.OnResume (self)

	if self.tHost:RetVehicle () then
		-- Go into the drop brain state
		self.tHost:ExitVehicle ()
	else
		-- Finish and set success to true, since at least we are not in a vehicle
		self.bSuccess = true
		self:Finish ()
	end
end

function ExitVehicle:OnPause ()
	-- Clean up the brain state
	self.tHost:ClearBrainState ()

	-- Call parent
	TargetState.OnPause (self)
end

function ExitVehicle:OnExit ()
	self:OnPause ()

	-- Call parent
	TargetState.OnExit (self)
end

function ExitVehicle:OnEvent (tEvent)

	if tEvent:HasID (self.nExitVehicleFinishedID) then
		
		self.bSuccess = tEvent:RetSuccess ()
		self:Finish ()
		return true
		
	end
	
	-- Call parent
	return TargetState.OnEvent (self, tEvent)
end

function ExitVehicle:Success ()
	return self.bSuccess
end
