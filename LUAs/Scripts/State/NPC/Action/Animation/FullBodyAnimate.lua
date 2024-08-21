----------------------------------------------------------------------
-- Name: FullBodyAnimate State
--	Description: Play a full-body character animation
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "System\\State"

FullBodyAnimate = Create (State, 
{
	sStateName = "FullBodyAnimate",
	bLooping = false,					-- Loop animation continuously
	bBlockInterrupts = false,		-- Prevent the animation from being interrupted by dying or damage
	bHoldAnimEnd = false,			-- Stay in the final frame of the animation after it ends
	bBlendOut = true,				-- Blend out (nBlendOutTime is ignored if this is false)
	nPlayBackRate = 1.0,			-- Playback rate
	nBlendInTime = 0.1,				-- Time in seconds to blend with the previous animation
	nBlendOutTime = 0.1,			-- Time in seconds to blend with the next animation
})

function FullBodyAnimate:OnEnter ()
	-- Call parent
	State.OnEnter (self)

	-- Check parameters
	assert (self.nAnimationID)

	-- Subscribe to animation finished event
	self.nAnimationFinishedID = self:Subscribe (eEventType.AIE_ANIMATION_FINISHED, self.tHost)
	
	self:OnResume ()
end

function FullBodyAnimate:OnResume ()
	-- Call parent
	State.OnResume (self)

	-- Set the parameters for the brain state
	local tParams = self.tHost:RetFullBodyAnimateParams ()

	tParams:SetAnimID (self.nAnimationID)
	tParams:SetLoop (self.bLooping)
	tParams:SetBlockInterrupts (self.bBlockInterrupts)
	tParams:SetHoldAnimEnd (self.bHoldAnimEnd)
	tParams:SetBlendOut (self.bBlendOut)
	tParams:SetPlayBackRate (self.nPlayBackRate)
	tParams:SetBlendInTime (self.nBlendInTime)
	tParams:SetBlendOutTime (self.nBlendOutTime)

	-- Go into the animation brain state
	self.tHost:FullBodyAnimate ()
end

function FullBodyAnimate:OnPause ()
	-- Clean up the brain state
	self.tHost:ClearBrainState ()

	-- Call parent
	State.OnPause (self)
end

function FullBodyAnimate:OnExit ()
	self:OnPause ()

	-- Call parent
	State.OnExit (self)
end

function FullBodyAnimate:OnEvent (tEvent)

	if tEvent:HasID (self.nAnimationFinishedID) then
		
		self:Finish ()
		return true
		
	end
	
	-- Call parent
	return State.OnEvent (self, tEvent)
end
