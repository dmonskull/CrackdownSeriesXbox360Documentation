----------------------------------------------------------------------
-- Name: Run State
-- Description: Runs away from the grenade
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\Action\\Animation\\Flee"

GrenadeRun = Create (Flee, 
{
	sStateName = "GrenadeRun",
	nMovementType = eMovementType.nSprint,
	bTargetMandatory = false,
})

function GrenadeRun:OnEnter ()
	-- Call parent
	Flee.OnEnter (self)

	-- Target is not mandatory as the state continues after the grande explodes
	-- but we expect to be given a target when we enter the state
	assert (self.tHost:HasTarget ())

	-- Subscribe to events
	self.nGrenadeExplodedID = self:Subscribe (eEventType.AIE_GRENADE_EXPLODED, self.tTargetInfo:RetTarget ())
	self.nTimerFinishedID = self:Subscribe (eEventType.AIE_TIMER_FINISHED, self.tHost)
end

function GrenadeRun:OnEvent (tEvent)

	if tEvent:HasID (self.nGrenadeExplodedID) then

		self.nTimerID = self:AddTimer (cAIPlayer.Rand (1, 4), false)
		return true

	elseif self.nTimerID and tEvent:HasID (self.nTimerFinishedID) and tEvent:HasTimerID (self.nTimerID) then

		self:Finish ()
		return true

	end

	-- Call parent
	return Flee.OnEvent (self, tEvent)
end
