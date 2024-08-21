----------------------------------------------------------------------
-- Name: Circle State
--	Description: Circle around the target, as in a fist-fight
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"

Circle = Create (TargetState, 
{
	sStateName = "Circle",
	nMovementType = eMovementType.nWalk,
	nMovementPriority = eMovementPriority.nLow,
	nDistance = 5,
})

function Circle:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)

	self:OnResume ()
end

function Circle:OnResume ()
	-- Call parent
	TargetState.OnResume (self)

	-- Set the animation parameters for the brain state
	local tParams = self.tHost:RetCircleAnimationParams ()

	tParams:SetAnimID (eUpperBodyAnimationID.nFistFight)
	tParams:SetLoop (true)

	-- Set speed
	self.tHost:SetMovementType (self.nMovementType)

	-- Set priority
	self.tHost:SetMovementPriority (self.nMovementPriority)

	-- Go into Circle state
	self.tHost:Circle (self.nDistance)
end

function Circle:OnPause ()
	-- Clean up the brain state
	self.tHost:ClearBrainState ()

	-- Call parent
	TargetState.OnPause (self)
end

function Circle:OnExit ()
	self:OnPause ()

	-- Call parent
	TargetState.OnExit (self)
end
