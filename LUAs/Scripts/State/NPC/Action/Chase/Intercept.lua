----------------------------------------------------------------------
-- Name: Intercept State
--	Description: Move in front of the target while facing the target
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"

Intercept = Create (TargetState, 
{
	sStateName = "Intercept",
	nMovementType = eMovementType.nRun,
	nMovementPriority = eMovementPriority.nLow,
})

function Intercept:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)

	-- Subscribe to reached destination event
	self.nReachedDestinationID = self:Subscribe(eEventType.AIE_REACHED_DESTINATION, self.tHost)

	self:OnResume ()
end

-- Over-ride this to set the correct 'move' brainstate
function Intercept:OnResume ()
	-- Call parent
	TargetState.OnResume (self)

	-- Set speed
	self.tHost:SetMovementType (self.nMovementType)

	-- Set priority
	self.tHost:SetMovementPriority (self.nMovementPriority)

	-- Intercept brainstate
	self.tHost:Intercept ()
end

function Intercept:OnPause ()
	-- Clean up the brain state
	self.tHost:ClearBrainState ()

	-- Call parent
	TargetState.OnPause (self)
end

function Intercept:OnExit ()
	self:OnPause ()

	-- Call parent
	TargetState.OnExit (self)
end

function Intercept:OnEvent (tEvent)

	-- Reached destination
	if tEvent:HasID (self.nReachedDestinationID) then
	
		self:Finish ()
		return true
	
	end

	-- Call parent
	return TargetState.OnEvent (self, tEvent)
end
