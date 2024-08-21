----------------------------------------------------------------------
-- Name: CrouchAnimation State
-- Description: NPC crouches
-- Owner: PKG
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------


require "State\\NPC\\Action\\Animation\\FullBodyAnimate"
require "State\\NPC\\Action\\Turn\\Face"


CrouchAnimation = Create (State, 
{
	sStateName = "CrouchAnimation",
	bTimeout = false,
	nTimeoutDuration = 5.0,
	bFaceTargetPoint = false,
	vFaceTargetPoint = MakeVec3 (0, 0, 0)
})


function CrouchAnimation:OnEnter ()

	-- Call parent
	State.OnEnter (self)
	
	-- If a duration has been supplied then we need to add a timer
	if self.bTimeout == true then
		self.nTimerFinishedID = self:Subscribe (eEventType.AIE_TIMER_FINISHED, self.tHost)
		self.nDurationID = self:AddTimer (self.nTimeoutDuration, false)
	end

	if self.bFaceTargetPoint == false then
	
		-- No target point - immediately animate to crouch position
		self:PushState (Create (FullBodyAnimate,
		{
			nAnimationID = eFullBodyAnimationID.nIdle3,
		}))
		
	else
	
		-- Target point given - Face this point before crouching
		self:PushState (Create (Turn, {
			vTargetPosition = self.vFaceTargetPoint,
		}))
	
	end

end


-- This catches when the duration timer runs out
function CrouchAnimation:OnEvent (tEvent)

	if self.bTimeout and tEvent:HasID (self.nTimerFinishedID) and tEvent:HasTimerID (self.nDurationID) then

		-- Finished waiting so return to previous state
		self:PopState ()
		self:Finish ()
		return true

	end

	-- Call parent
	return State.OnEvent (self, tEvent)

end


function CrouchAnimation:OnActiveStateFinished ()

	if self:IsInState (Turn) then

		-- Facing correct direction, now animate to crouch position
		self:PopState ()
		self:PushState (Create (FullBodyAnimate,
		{
			nAnimationID = eFullBodyAnimationID.nIdle3,
		}))
		return true

	end

	-- Call parent
	return State.OnActiveStateFinished (self)
end

