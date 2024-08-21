----------------------------------------------------------------------
-- Name: Wander State
--	Description: Walk around aimlessly along the sidewalk
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "System\\State"

Wander = Create (State, 
{
	sStateName = "Wander",
	nMovementType = eMovementType.nWalk,
	nMovementPriority = eMovementPriority.nLow,
	bOnSideWalk = false,
})

function Wander:OnEnter ()
	-- Call parent
	State.OnEnter (self)

	-- Subscribe to reached destination event
	self.nReachedDestinationID = self:Subscribe (eEventType.AIE_REACHED_DESTINATION, self.tHost)

	self:OnResume ()
end

function Wander:OnResume()
	-- Call parent
	State.OnResume (self)

	-- Set speed
	self.tHost:SetMovementType (self.nMovementType)

	-- Set priority
	self.tHost:SetMovementPriority (self.nMovementPriority)

	-- Use Wander brain state
	self.tHost:Wander (self.bOnSideWalk)
end

function Wander:OnPause ()
	-- Clean up the brain state
	self.tHost:ClearBrainState ()

	-- Call parent
	State.OnPause (self)
end

function Wander:OnExit ()
	self:OnPause ()

	-- Call parent
	State.OnExit (self)
end

function Wander:OnEvent (tEvent)

	if tEvent:HasID (self.nReachedDestinationID) then

		-- If the wander agent fails to reach the next global graph vertex, bail out
		if not tEvent:RetSuccess () then
			self:Finish ()
		end
		return true

	end

	-- Call parent
	return State.OnEvent (self, tEvent)
end
