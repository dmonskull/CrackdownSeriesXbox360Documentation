----------------------------------------------------------------------
-- Name: StandIdleArmed State
-- Description: Stands around doing nothing whilst armed. This state may 
--	eventually have anims like the standidle state but there are currently
--	no suitable anims, so the npc simply stands
-- Owner: pkg
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "System\\State"
require "State\\NPC\\Action\\Idle\\Idle"


StandIdleArmed = Create (State, 
{
	sStateName = "StandIdleArmed",
	bTimeout = false,
	nTimeoutDuration = 5.0,
	bFaceTargetPoint = false,
	vFaceTargetPoint = MakeVec3 (0, 0, 0),
	bWaitForAnimEndBeforeFinishing = true,
})


function StandIdleArmed:OnEnter ()
	-- Call parent
	State.OnEnter (self)

	-- Subscribe events
	self.nTimerFinishedID = self:Subscribe (eEventType.AIE_TIMER_FINISHED, self.tHost)

	-- If a duration has been supplied then we need to add a timer
	if self.bTimeout == true then
	
		assert (self.nTimeoutDuration > 0)
		self.nTimerDurationID = self:AddTimer (self.nTimeoutDuration, false)
		
	end

	if self.bFaceTargetPoint == true then
	
		-- Target point given - Face this point before idling
		self:PushState (Create (Turn, {
			vTargetPosition = self.vFaceTargetPoint,
		}))
	
	end
end


function StandIdleArmed:OnExit ()
	-- Call parent
	State.OnExit (self)
end


function StandIdleArmed:OnEvent (tEvent)

	if tEvent:HasID (self.nTimerFinishedID) and tEvent:HasTimerID (self.nTimerDurationID) then
	
		-- Finished idling so return to previous state
		self:PopState ()
		self:Finish ()
		return true
			
	end

	-- Call parent
	return State.OnEvent (self, tEvent)
end


function StandIdleArmed:OnActiveStateFinished ()

	if self:IsInState (Turn) then

		-- Facing correct direction, now start idling
		self:PopState ()
		self:PushState (Create (Idle, {}))
		return true

	end

	-- Call parent
	return State.OnActiveStateFinished (self)
end


