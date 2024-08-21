----------------------------------------------------------------------
-- Name: WoundedReaction State
--	Description: Runs away for a while after being shot in the leg
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"
require "State\\NPC\\Action\\Animation\\Flee"

WoundedReaction = Create (TargetState, 
{
	sStateName = "WoundedReaction",
	nTimeout = 5,
})

function WoundedReaction:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)

	-- Check parameters
	assert (self.nTimeout)

	-- Create non-looping timer
	self.nTimerID = self:AddTimer (self.nTimeout, false)

	-- Subscribe events
	self.nTimerFinishedID = self:Subscribe (eEventType.AIE_TIMER_FINISHED, self.tHost)
	self.nShotInLegID = self:SubscribeImmediate (eEventType.AIE_SHOT_IN_LEG, self.tHost)

	self:PushState (Create (Flee, 
	{
		nMovementType = eMovementType.nLimp,
	}))
end

function WoundedReaction:OnExit ()
	-- Call parent
	TargetState.OnExit (self)
end

function WoundedReaction:OnEvent (tEvent)

	if tEvent:HasID (self.nShotInLegID) then

		-- Use limping animation profile
		self:Unsubscribe (self.nShotInLegID)
		return true

	elseif tEvent:HasID (self.nTimerFinishedID) and tEvent:HasTimerID (self.nTimerID) then

		self:Finish ()
		return true

	end

	-- Call parent
	return TargetState.OnEvent (self, tEvent)
end
