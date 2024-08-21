----------------------------------------------------------------------
-- Name: Turn and full body animate state
-- Description: Turns and then performs a full body animation. Inludes optional
--	pre and post idle delays where the npc will simply stand still
-- Owner: pkg
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "System\\State"
require "State\\NPC\\Action\\Animation\\FullBodyAnimate"
require "State\\NPC\\Action\\Idle\\Idle"


TurnAndFullBodyAnimate = Create (State, 
{
	sStateName = "TurnAndFullBodyAnimate",
	vFaceTargetPoint = MakeVec3 (0, 0, 0),
	nAnimationID = eFullBodyAnimationID.nUpYours,
	nBlendInTime = 0.5,
	nBlendOutTime = 0.5,
	nPreIdleTime = 0.0,
	nPostIdleTime = 0.0,
})


function TurnAndFullBodyAnimate:OnEnter ()
	-- Call parent
	State.OnEnter (self)

	-- Face the target point
	self:PushState (Create (Turn, {
		vTargetPosition = self.vFaceTargetPoint,
	}))

	-- Subscribe events
	self.nTimerFinishedID = self:Subscribe (eEventType.AIE_TIMER_FINISHED, self.tHost)
end


function TurnAndFullBodyAnimate:OnActiveStateFinished ()

	if self:IsInState (Turn) then

		-- Now facing correct direction
		self:PopState ()

		if self.nPreIdleTime > 0 then
		
			-- Idle before the main animation
			self:PushState (Create (Idle, {}))
			
			-- Start a timer to tell us when to start the animation
			self.nPreIdleTimerID = self:AddTimer (self.nPreIdleTime, false)
			
		else
		
			-- No pre-idle required, go straight into the animation
			self:PushState (Create (FullBodyAnimate,
			{
				nAnimationID = self.nAnimationID,
				nBlendInTime = self.nBlendInTime,
				nBlendOutTime = self.nBlendOutTime,
			}))
			
		end
			
		return true

	elseif self:IsInState (FullBodyAnimate) then

		-- Finished animation
		self:PopState ()

		if self.nPostIdleTime > 0 then
		
			-- Idle before exiting
			self:PushState (Create (Idle, {}))
			
			-- Start a timer to tell us when to exit
			self.nPostIdleTimerID = self:AddTimer (self.nPostIdleTime, false)

		else
		
			-- No post-idle required, finish the state immediately
			self:Finish ()
		
		end

		return true

	end

	-- Call parent
	return State.OnActiveStateFinished (self)
end


function TurnAndFullBodyAnimate:OnEvent (tEvent)

	if tEvent:HasID (self.nTimerFinishedID) then
	
		if self.nPreIdleTime and tEvent:HasTimerID (self.nPreIdleTimerID) then
		
			-- Finished pre-idle so now animate
			self:PopState ()
			self:PushState (Create (FullBodyAnimate,
			{
				nAnimationID = self.nAnimationID,
				nBlendInTime = self.nBlendInTime,
				nBlendOutTime = self.nBlendOutTime,
			}))
			return true
			
		elseif self.nPostIdleTime and tEvent:HasTimerID (self.nPostIdleTimerID) then
		
			-- Finished post-idle so now exit this state
			self:PopState ()
			self:Finish ()
			return true
			
		end
			
	end

	-- Call parent
	return State.OnEvent (self, tEvent)
end
