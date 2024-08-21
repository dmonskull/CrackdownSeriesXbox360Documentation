----------------------------------------------------------------------
-- Name: StandIdle State
--	Description: Stands around doing nothing, occasionally plays a 'bored' animation
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "System\\State"
require "State\\NPC\\Action\\Idle\\Idle"
require "State\\NPC\\Action\\Animation\\FullBodyAnimate"

StandIdle = Create (State, 
{
	sStateName = "StandIdle",
	bTimeout = false,
	nTimeoutDuration = 0,
	bFaceTargetPoint = false,
	vFaceTargetPoint = MakeVec3 (0, 0, 0),
	bWaitForAnimEndBeforeFinishing = true,
	anAnimList =
	{
		eFullBodyAnimationID.nIdle1,
		eFullBodyAnimationID.nIdle2,
		eFullBodyAnimationID.nIdle3,
		eFullBodyAnimationID.nIdle4,
	},
	nMinDelayBetweenAnims = 3,
	nMaxDelayBetweenAnims = 8,
})


function StandIdle:OnEnter ()
	-- Call parent
	State.OnEnter (self)

	-- Check arguments
	assert (table.getn (self.anAnimList) > 0)
	assert (self.nMinDelayBetweenAnims <= self.nMaxDelayBetweenAnims)

	-- Start the timer
	self:ResetTimer ()

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
	
	else

		self:PushState (Create (Idle, {}))

	end

	-- We use this bool when we need the bWaitForAnimEndBeforeFinishing behaviour
	self.bFinishStateAfterCurrentAnimation = false
	
end


function StandIdle:OnExit ()
	-- Call parent
	State.OnExit (self)
end


function StandIdle:OnEvent (tEvent)

	if tEvent:HasID (self.nTimerFinishedID) and tEvent:HasTimerID (self.nTimerID) then

		-- Play a random 'bored' animation
		self:PlayIdleAnimation ()
		return true

	elseif self.bTimeout and tEvent:HasID (self.nTimerFinishedID) and tEvent:HasTimerID (self.nTimerDurationID) then
	
		-- Finished idling so return to previous state
		if self.bWaitForAnimEndBeforeFinishing == false then

			-- Revert immediately
			self:PopState ()
			self:Finish ()
			return true
			
		else

			-- Revert after the current animation has finished
			self.bFinishStateAfterCurrentAnimation = true
			return true
		
		end

	end

	-- Call parent
	return State.OnEvent (self, tEvent)
end


function StandIdle:OnActiveStateFinished ()

	if self:IsInState (Turn) then

		-- Facing correct direction, now put away weapon ( if we have one )
		self:ChangeState (Create (StoreItem, {}))
		return true

	elseif self:IsInState (FullBodyAnimate) then

		-- Current idle anim has finished
		if self.bWaitForAnimEndBeforeFinishing == true and self.bFinishStateAfterCurrentAnimation == true then
			
			-- If we're wanting to finished this state after the current anim finishes
			-- then now is the time to do it
			self:Finish ()
			return true
			
		else

			-- Otherwise, reset the timer again to trigger another idle anim
			self:ResetTimer ()
			self:PopState ()
			return true
			
		end

	end

	-- Call parent
	return State.OnActiveStateFinished (self)
end


function StandIdle:ResetTimer ()
	-- Start non-looping timer
	-- When this is finished, an animation will be played
	self.nTimerID = self:AddTimer (cAIPlayer.FRand (self.nMinDelayBetweenAnims, self.nMaxDelayBetweenAnims), false)
end


-- Play a random idle animation without repeating the same one twice in a row
function StandIdle:PlayIdleAnimation ()

	local nIdleAnimIndex
	local nNumIdleAnims = table.getn (self.anAnimList)
	
	if nNumIdleAnims ~= 1 then
	
		-- Randomly choose an anim but not the same as last time
		repeat
			nIdleAnimIndex = cAIPlayer.Rand (1, nNumIdleAnims)
		until nIdleAnimIndex ~= self.nLastIdleAnimIndex

		-- Remember the last anim played	
		self.nLastIdleAnimIndex = nIdleAnimIndex
		
	else
	
		-- If we only have one anim then I guess we'd better always choose it!
		nIdleAnimIndex = 1
		
	end
	
	-- Play the anim
	self:PushState (Create (FullBodyAnimate,
	{
		nAnimationID = self.anAnimList[nIdleAnimIndex],
		nBlendInTime = 0.5,
		nBlendOutTime = 0.5,
	}))

end
