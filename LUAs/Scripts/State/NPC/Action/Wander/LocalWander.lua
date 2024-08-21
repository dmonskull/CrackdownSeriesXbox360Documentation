----------------------------------------------------------------------
-- Name: LocalWander State
-- Description: Walk around aimlessly along the local graph
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "System\\State"

LocalWander = Create (State, 
{
	sStateName = "LocalWander",
	nMovementType = eMovementType.nWalk,
	nMovementPriority = eMovementPriority.nLow,
	bUseRadius = false,
	vCentrePosition = nil,
	nRadius = 10,
})

function LocalWander:OnEnter ()
	-- Call parent
	State.OnEnter (self)

	self:OnResume ()
end

function LocalWander:OnResume()
	-- Call parent
	State.OnResume (self)

	-- Use current position as default centre position
	self.vCentrePosition = self.vCentrePosition or self.tHost:RetCentre ()

	-- Set speed
	self.tHost:SetMovementType (self.nMovementType)

	-- Set priority
	self.tHost:SetMovementPriority (self.nMovementPriority)

	-- Use Wander brain state
	self.tHost:LocalWander (self.bUseRadius, self.vCentrePosition, self.nRadius)
end

function LocalWander:OnPause ()
	-- Clean up the brain state
	self.tHost:ClearBrainState ()

	-- Call parent
	State.OnPause (self)
end

function LocalWander:OnExit ()
	self:OnPause ()

	-- Call parent
	State.OnExit (self)
end
