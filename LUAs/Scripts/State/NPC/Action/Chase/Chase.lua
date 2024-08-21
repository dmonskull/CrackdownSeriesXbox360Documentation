----------------------------------------------------------------------
-- Name: Chase State
--	Description: Continually move towards the current target
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"

Chase = Create (TargetState, 
{
	sStateName = "Chase",
	nMovementType = eMovementType.nRun,
	nMovementPriority = eMovementPriority.nLow,
})

function Chase:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)

	self:OnResume ()
end

function Chase:OnResume ()
	-- Call parent
	TargetState.OnResume (self)

	-- Set speed
	self.tHost:SetMovementType (self.nMovementType)

	-- Set priority
	self.tHost:SetMovementPriority (self.nMovementPriority)

	-- Go into chase brain state
	self.tHost:Chase ()
end

function Chase:OnPause ()
	-- Clean up the brain state
	self.tHost:ClearBrainState ()

	-- Call parent
	TargetState.OnPause (self)
end

function Chase:OnExit ()
	self:OnPause ()

	-- Call parent
	TargetState.OnExit (self)
end
