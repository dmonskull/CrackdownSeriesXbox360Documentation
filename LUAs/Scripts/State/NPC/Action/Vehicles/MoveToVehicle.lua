----------------------------------------------------------------------
-- Name: MoveToVehicle State
--	Description: Continually move towards the current target
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"

MoveToVehicle = Create (TargetState, 
{
	sStateName = "MoveToVehicle",
	nMovementType = eMovementType.nRun,
	nMovementPriority = eMovementPriority.nLow,
	nSelectedDoor = 1,
	bSuccess = false,
})

function MoveToVehicle:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)

	-- Subscribe to reached destination event
	self.nReachedDestinationID = self:Subscribe(eEventType.AIE_REACHED_DESTINATION, self.tHost)

	self:OnResume ()
end

function MoveToVehicle:OnResume ()
	-- Call parent
	TargetState.OnResume (self)

	-- Set speed
	self.tHost:SetMovementType (self.nMovementType)

	-- Set priority
	self.tHost:SetMovementPriority (self.nMovementPriority)

	-- Go into MoveToVehicle brain state
	local tTarget = self.tTargetInfo:RetTarget ()
	self.tHost:MoveToVehicle (tTarget, self.nSelectedDoor - 1)
end

function MoveToVehicle:OnPause ()
	-- Clean up the brain state
	self.tHost:ClearBrainState ()

	-- Call parent
	TargetState.OnPause (self)
end

function MoveToVehicle:OnExit ()
	self:OnPause ()

	-- Call parent
	TargetState.OnExit (self)
end

function MoveToVehicle:OnEvent (tEvent)
	-- Reached destination
	if tEvent:HasID (self.nReachedDestinationID) then
	
		self.bSuccess = tEvent:RetSuccess ()
		self:Finish ()
		return true
	
	end

	-- Call parent
	return TargetState.OnEvent (self, tEvent)
end

function MoveToVehicle:Success ()
	return self.bSuccess
end
