----------------------------------------------------------------------
-- Name: ChaseAndPrimaryFire State
--	Description: Run towards the target while shooting at the target
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"

ChaseAndPrimaryFire = Create (TargetState, 
{
	sStateName = "ChaseAndPrimaryFire",
	nMovementType = eMovementType.nRun,
	nMovementPriority = eMovementPriority.nLow,
	nTargetInfoFlags = eTargetInfoFlags.nVisibilityChecks + eTargetInfoFlags.nPrimaryFireChecks,
})

function ChaseAndPrimaryFire:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)

	self:OnResume ()
end

function ChaseAndPrimaryFire:OnResume ()
	-- Call parent
	TargetState.OnResume (self)

	-- Set speed
	self.tHost:SetMovementType (self.nMovementType)

	-- Set priority
	self.tHost:SetMovementPriority (self.nMovementPriority)

	-- Go into ChaseAndPrimaryFire brain state
	self.tHost:ChaseAndPrimaryFire ()
end

function ChaseAndPrimaryFire:OnPause ()
	-- Clean up the brain state
	self.tHost:ClearBrainState ()

	-- Call parent
	TargetState.OnPause (self)
end

function ChaseAndPrimaryFire:OnExit ()
	self:OnPause ()

	-- Call parent
	TargetState.OnExit (self)
end
