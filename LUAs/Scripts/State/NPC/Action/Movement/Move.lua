----------------------------------------------------------------------
-- Name: Move State
--	Description: Move towards a position
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"

Move = Create (TargetState, 
{
	sStateName = "Move",
	nTargetInfoFlags = 0,
	nMovementType = eMovementType.nRun,
	nMovementPriority = eMovementPriority.nLow,
	bTargetMandatory = false,
	bSuccess = false,
})

function Move:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)

	-- Check parameters
	assert (self.vDestination)

	-- Subscribe to reached destination event
	self.nReachedDestinationID = self:Subscribe(eEventType.AIE_REACHED_DESTINATION, self.tHost)

	-- Go to destination
	self:OnResume ()
end

-- Over-ride this to set the correct 'move' brainstate
function Move:OnResume ()
	-- Call parent
	TargetState.OnResume (self)

	-- Set speed
	self.tHost:SetMovementType (self.nMovementType)

	-- Set priority
	self.tHost:SetMovementPriority (self.nMovementPriority)

	-- This function is over-ridden by the derived classes
	self:MoveToPosition ()
end

function Move:OnPause ()
	-- Clean up the brain state
	self.tHost:ClearBrainState ()

	-- Call parent
	TargetState.OnPause (self)
end

function Move:OnExit ()
	self:OnPause ()

	-- Call parent
	TargetState.OnExit (self)
end

function Move:OnEvent (tEvent)

	-- Reached destination
	if tEvent:HasID (self.nReachedDestinationID) then
	
		self.bSuccess = tEvent:RetSuccess ()
		self:Finish ()
		return true
	
	end

	-- Call parent
	return TargetState.OnEvent (self, tEvent)
end

function Move:MoveToPosition ()
	-- Go into Move state
	self.tHost:MoveTo (self.vDestination)
end

function Move:Success ()
	return self.bSuccess
end
