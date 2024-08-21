----------------------------------------------------------------------
-- Name: ShoutRun State
--	Description: Shouts a warning, then runs off
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"
require "State\\NPC\\Action\\Turn\\WaitAndFace"
require "State\\NPC\\Action\\Animation\\Flee"

GrenadeShoutRun = Create (TargetState, 
{
	sStateName = "GrenadeShoutRun",
	bTargetMandatory = false,
})

function GrenadeShoutRun:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)

	-- Target is not mandatory as the state continues after the grande explodes
	-- but we expect to be given a target when we enter the state
	assert (self.tHost:HasTarget ())

	self.tHost:ShoutGrenadeWarningAudio (eVocals.nWarn, "Grenade!", self.tTargetInfo:RetTarget ())

	self:PushState (Create (WaitAndFace,
	{
		nWaitTime = cAIPlayer.FRand (1, 2),
	}))

	-- Subscribe to events
	self.nGrenadeExplodedID = self:Subscribe (eEventType.AIE_GRENADE_EXPLODED, self.tTargetInfo:RetTarget ())
	self.nTimerFinishedID = self:Subscribe (eEventType.AIE_TIMER_FINISHED, self.tHost)
end

function GrenadeShoutRun:OnEvent (tEvent)

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

function GrenadeShoutRun:OnActiveStateFinished ()

	if self:IsInState (WaitAndFace) then

		self:ChangeState (Create (Flee, 
		{
			nMovementType = eMovementType.nSprint,
		}))
		return true

	end

	-- Call parent
	return TargetState.OnActiveStateFinished (self)
end
