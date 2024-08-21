----------------------------------------------------------------------
-- Name: Panic State
--	Description: Panic sequence where the NPC runs around with arms in the air
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "System\\State"

Panic = Create (State, 
{
	sStateName = "Panic",
	nMovementType = eMovementType.nRun,
	nMovementPriority = eMovementPriority.nLow,
	bUseRadius = false,
	vCentrePosition = nil,
	nRadius = 10,
})

function Panic:OnEnter ()
	-- Call parent
	State.OnEnter (self)

	self:OnResume ()
end

function Panic:OnResume ()
	-- Call parent
	State.OnResume (self)

	-- Use current position as default centre position
	self.vCentrePosition = self.vCentrePosition or self.tHost:RetCentre ()

	-- Set the animation parameters for the brain state
	local tParams = self.tHost:RetPanicAnimationParams ()

	tParams:SetAnimID (eUpperBodyAnimationID.nPanic)
	tParams:SetLoop (true)

	-- Set speed
	self.tHost:SetMovementType (self.nMovementType)

	-- Set priority
	self.tHost:SetMovementPriority (self.nMovementPriority)

	-- Use Panic brain state
	self.tHost:Panic (self.bUseRadius, self.vCentrePosition, self.nRadius)
end

function Panic:OnPause ()
	-- Clean up the brain state
	self.tHost:ClearBrainState ()

	-- Call parent
	State.OnPause (self)
end

function Panic:OnExit ()
	self:OnPause ()

	-- Call parent
	State.OnExit (self)
end
