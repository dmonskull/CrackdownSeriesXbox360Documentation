----------------------------------------------------------------------
-- Name: Protect State
--	Description: Stand between an object or position and the target, facing the target
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"

Protect = Create (TargetState, 
{
	sStateName = "Protect",
	nTargetInfoFlags = eTargetInfoFlags.nVisibilityChecks + eTargetInfoFlags.nPrimaryFireChecks,
	nMovementType = eMovementType.nRun,
	nMovementPriority = eMovementPriority.nLow,
	nDistance = 3,
})

function Protect:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)

	assert (self.tProtectedObject or self.vProtectedPosition)
	assert (self.nDistance)

	self:OnResume ()
end

function Protect:OnResume ()
	-- Call parent
	TargetState.OnResume (self)

	-- Set speed
	self.tHost:SetMovementType (self.nMovementType)

	-- Set priority
	self.tHost:SetMovementPriority (self.nMovementPriority)

	-- Go into Protect brain state
	if self.tProtectedObject then
		self.tHost:ProtectObject (self.nDistance, self.tProtectedObject)
	elseif self.vProtectedPosition then
		self.tHost:ProtectPosition (self.nDistance, self.vProtectedPosition)
	end
end

function Protect:OnPause ()
	-- Clean up the brain state
	self.tHost:ClearBrainState ()

	-- Call parent
	TargetState.OnPause (self)
end

function Protect:OnExit ()
	self:OnPause ()

	-- Call parent
	TargetState.OnExit (self)
end
