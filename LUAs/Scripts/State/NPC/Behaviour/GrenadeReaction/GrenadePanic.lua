----------------------------------------------------------------------
-- Name: GrenadePanic State
--	Description: Runs around with hands in the air until the grenade explodes
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\Action\\Animation\\Panic"

GrenadePanic = Create (Panic, 
{
	sStateName = "GrenadePanic",
})

function GrenadePanic:OnEnter ()
	-- Call parent
	Panic.OnEnter (self)

	-- Check that we have a target
	assert (self.tHost:HasTarget ())

	-- Subscribe to events
	self.nGrenadeExplodedID = self:Subscribe (eEventType.AIE_GRENADE_EXPLODED, self.tHost:RetTarget ())
	self.nTimerFinishedID = self:Subscribe (eEventType.AIE_TIMER_FINISHED, self.tHost)
end

function GrenadePanic:OnEvent (tEvent)

	if tEvent:HasID (self.nGrenadeExplodedID) then

		self.nTimerID = self:AddTimer (cAIPlayer.Rand (1, 4), false)
		return true

	elseif self.nTimerID and tEvent:HasID (self.nTimerFinishedID) and tEvent:HasTimerID (self.nTimerID) then

		self:Finish ()
		return true

	end

	-- Call parent
	return Panic.OnEvent (self, tEvent)
end
