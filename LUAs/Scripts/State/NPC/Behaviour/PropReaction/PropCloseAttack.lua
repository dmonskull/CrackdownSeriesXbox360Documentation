----------------------------------------------------------------------
-- Name: PropCloseAttack State
--	Description: Try to punch the prop
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "System\\State"
require "State\\NPC\\Action\\Animation\\UpperBodyAnimateAndFace"
require "State\\NPC\\Action\\Combat\\CloseAttack"

PropCloseAttack = Create (TargetState, 
{
	sStateName = "PropCloseAttack",
	nTargetInfoFlags = eTargetInfoFlags.nVisibilityChecks + eTargetInfoFlags.nCombatTargetingChecks,
	nTimeout = 2,
	nRadius = 3,
})

function PropCloseAttack:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)

	-- Create non-looping timer
	self.nTimerID = self:AddTimer (self.nTimeout, false)

	-- Set up proximity check
	-- Since props move so fast it generally isn't enough to wait for the prop to come
	-- within punch radius before starting to punch - it's better to start when it's still a bit
	-- further away
	self.nProximityCheckID = self:AddProximityCheck (self.tHost, self.tTargetInfo:RetTarget (), self.nRadius)

	-- Subscribe to events
	self.nTimerFinishedID = self:Subscribe (eEventType.AIE_TIMER_FINISHED, self.tHost)
	self.nTargetInProximityID = self:Subscribe (eEventType.AIE_TARGET_IN_PROXIMITY, self.tHost)
	self.nCombatTargetFoundID = self:Subscribe (eEventType.AIE_COMBAT_TARGET_FOUND, self.tTargetInfo)

	-- Face the prop with fists at the ready until it comes close enough
	self:PushState (Create (UpperBodyAnimateAndFace, 
	{
		nAnimationID = eUpperBodyAnimationID.nFistFight,
		bLooping = true,
	}))
end

function PropCloseAttack:OnEvent (tEvent)

	if tEvent:HasID (self.nCombatTargetFoundID) then

		if self:IsInState (UpperBodyAnimateAndFace) then
			self:ChangeState (Create (CloseAttack, {}))
		end
		return true

	elseif tEvent:HasID (self.nTargetInProximityID) and tEvent:HasProximityCheckID (self.nProximityCheckID) then

		if self:IsInState (UpperBodyAnimateAndFace) then
			self:ChangeState (Create (CloseAttack, {}))
		end
		return true

	elseif tEvent:HasID (self.nTimerFinishedID) and tEvent:HasTimerID (self.nTimerID) then

		-- Timed out and prop still has not hit us - forget about it
		if self:IsInState (UpperBodyAnimateAndFace) then
			self:Finish ()
		end
		return true	

	end

	-- Call parent
	return TargetState.OnEvent (self, tEvent)
end

function PropCloseAttack:OnActiveStateFinished ()

	if self:IsInState (CloseAttack) then

		-- Finished punching the prop
		self:Finish ()
		return true

	end

	-- Call parent
	return TargetState.OnActiveStateFinished (self)
end
