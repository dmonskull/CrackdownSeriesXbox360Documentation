----------------------------------------------------------------------
-- Name: Patrol To State
-- Description: Patrols to a position / encapsulates the patrol agent
-- Owner: Stig
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"

PatrolTo = Create (TargetState, 
{
	sStateName = "PatrolTo",
	nTargetInfoFlags = 0,
	nMovementType = eMovementType.nRun,
	nMovementPriority = eMovementPriority.nLow,
	bTargetMandatory = false,
	bSuccess = false,
})

function PatrolTo:OnEnter ()
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
function PatrolTo:OnResume ()
	-- Call parent
	TargetState.OnResume (self)

	-- Set speed
	self.tHost:SetMovementType (self.nMovementType)

	-- Set priority
	self.tHost:SetMovementPriority (self.nMovementPriority)

	-- This function is over-ridden by the derived classes
	self:PatrolToPosition ()
end

function PatrolTo:OnPause ()
	-- Clean up the brain state
	self.tHost:ClearBrainState ()

	-- Call parent
	TargetState.OnPause (self)
end

function PatrolTo:OnExit ()
	self:OnPause ()

	-- Call parent
	TargetState.OnExit (self)
end

function PatrolTo:OnEvent (tEvent)

	-- Reached destination
	if tEvent:HasID (self.nReachedDestinationID) then
	
		self.bSuccess = tEvent:RetSuccess ()
		self:Finish ()
		return true
	
	end

	-- Call parent
	return TargetState.OnEvent (self, tEvent)
end

function PatrolTo:PatrolToPosition ()
	-- Go into Move state
	self.tHost:PatrolTo (self.vDestination)
end

function PatrolTo:Success ()
	return self.bSuccess
end
