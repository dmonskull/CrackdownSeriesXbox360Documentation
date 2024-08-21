----------------------------------------------------------------------
-- Name: Flee State
--	Description: Run away from target - cower if nowhere to run
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"

Flee = Create (TargetState, 
{
	sStateName = "Flee",
	nMovementType = eMovementType.nSprint,
	nMovementPriority = eMovementPriority.nHigh,
	bUseRadius = false,
	vCentrePosition = nil,
	nRadius = 10,
})

function Flee:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)

	self:OnResume ()
end

function Flee:OnResume ()
	-- Call parent
	TargetState.OnResume (self)

	-- Use current position as default centre position
	self.vCentrePosition = self.vCentrePosition or self.tHost:RetCentre ()

	local tFleeAnimationParams = self.tHost:RetFleeAnimationParams ()
	local tCowerAnimationParams = self.tHost:RetCowerAnimationParams ()

	-- Set fleeing animation parameters
	tFleeAnimationParams:SetAnimID (eUpperBodyAnimationID.nPanic)
	tFleeAnimationParams:SetLoop (true)

	-- Set cowering animation parameters
	tCowerAnimationParams:SetAnimID (eFullBodyAnimationID.nCower)
	tCowerAnimationParams:SetLoop (true)

	-- Set speed
	self.tHost:SetMovementType (self.nMovementType)

	-- Set priority
	self.tHost:SetMovementPriority (self.nMovementPriority)

	-- Go into flee brain state
	self.tHost:Flee (self.bUseRadius, self.vCentrePosition, self.nRadius)
end

function Flee:OnPause ()
	-- Clean up the brain state
	self.tHost:ClearBrainState ()

	-- Call parent
	TargetState.OnPause (self)
end

function Flee:OnExit ()
	self:OnPause ()

	-- Call parent
	TargetState.OnExit (self)
end
