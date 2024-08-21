----------------------------------------------------------------------
-- Name: EnterVehicle State
--	Description: Enters the vehicle we are currently targeting
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"

EnterVehicle = Create (TargetState, 
{
	sStateName = "EnterVehicle",
	nTargetInfoFlags = eTargetInfoFlags.nVisibilityChecks + eTargetInfoFlags.nVehicleTargetingChecks,
	bSuccess = false,
})

function EnterVehicle:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)

	-- Subscribe to drop finished event
	self.nEnterVehicleFinishedID = self:Subscribe (eEventType.AIE_ENTER_VEHICLE_FINISHED, self.tHost)

	self:OnResume ()
end

function EnterVehicle:OnResume ()
	-- Call parent
	TargetState.OnResume (self)

	-- Am I already in this vehicle?
	if self.tHost:RetVehicle () == self.tTargetInfo:RetTarget () then
		self.bSuccess = true
		self:Finish ()
	else
		-- Go into the enter vehicle brain state
		self.tHost:EnterVehicle ()
	end
end

function EnterVehicle:OnPause ()
	-- Clean up the brain state
	self.tHost:ClearBrainState ()

	-- Call parent
	TargetState.OnPause (self)
end

function EnterVehicle:OnExit ()
	self:OnPause ()

	-- Call parent
	TargetState.OnExit (self)
end

function EnterVehicle:OnEvent (tEvent)

	if tEvent:HasID (self.nEnterVehicleFinishedID) then
		
		self.bSuccess = tEvent:RetSuccess ()
		self:Finish ()
		return true
		
	end
	
	-- Call parent
	return TargetState.OnEvent (self, tEvent)
end

function EnterVehicle:Success ()
	return self.bSuccess
end
