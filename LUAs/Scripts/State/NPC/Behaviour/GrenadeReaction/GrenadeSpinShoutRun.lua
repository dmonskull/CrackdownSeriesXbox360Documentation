----------------------------------------------------------------------
-- Name: SpinShoutRun State
-- Description: Turn to face the grenade, then shout a warning, then run off
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "System\\State"
require "State\\NPC\\Action\\Turn\\Turn"
require "State\\NPC\\Action\\Turn\\WaitAndFace"
require "State\\NPC\\Action\\Animation\\Flee"

GrenadeSpinShoutRun = Create (TargetState, 
{
	sStateName = "GrenadeSpinShoutRun",
})

function GrenadeSpinShoutRun:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)

	-- Target is not mandatory as the state continues after the grande explodes
	-- but we expect to be given a target when we enter the state
	assert (self.tHost:HasTarget ())

	self:PushState (Create (Turn, {}))

	-- Subscribe to events
	self.nGrenadeExplodedID = self:Subscribe (eEventType.AIE_GRENADE_EXPLODED, self.tTargetInfo:RetTarget ())
	self.nTimerFinishedID = self:Subscribe (eEventType.AIE_TIMER_FINISHED, self.tHost)
end

function GrenadeSpinShoutRun:OnEvent (tEvent)

	if tEvent:HasID (self.nGrenadeExplodedID) then

		self.nTimerID = self:AddTimer (cAIPlayer.Rand (1, 4), false)
		return true

	elseif self.nTimerID and tEvent:HasID (self.nTimerFinishedID) and tEvent:HasTimerID (self.nTimerID) then

		self:Finish ()
		return true

	end

	-- Call parent
	return TargetState.OnEvent (self, tEvent)
end

function GrenadeSpinShoutRun:OnActiveStateFinished ()

	if self:IsInState (Turn) then

		self.tHost:ShoutGrenadeWarningAudio (eVocals.nWarn, "Grenade!", self.tTargetInfo:RetTarget ())
		self:ChangeState (Create (WaitAndFace,
		{
			nWaitTime = cAIPlayer.FRand (1, 2),
		}))
		return true

	elseif self:IsInState (WaitAndFace) then

		self:ChangeState (Create (Flee, 
		{
			nMovementType = eMovementType.nSprint,
		}))
		return true

	end

	-- Call parent
	return TargetState.OnActiveStateFinished (self)
end
