----------------------------------------------------------------------
-- Name: UpperBodyAnimateAndFace State
--	Description: Play an upper-body character animation while using the feet to
-- rotate and keep facing the target
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"

UpperBodyAnimateAndFace = Create (TargetState, 
{
	sStateName = "UpperBodyAnimateAndFace",
	bLooping = false,					-- Loop animation continuously
	bBlockInterrupts = false,		-- Prevent the animation from being interrupted by dying or damage
	bHoldAnimEnd = false,			-- Stay in the final frame of the animation after it ends
	bBlendOut = true,				-- Blend out (nBlendOutTime is ignored if this is false)
	nPlayBackRate = 1.0,			-- Playback rate
	nBlendInTime = 0.1,				-- Time in seconds to blend with the previous animation
	nBlendOutTime = 0.1,			-- Time in seconds to blend with the next animation
})

function UpperBodyAnimateAndFace:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)

	-- Check parameters
	assert (self.nAnimationID)

	-- Subscribe to animation finished event
	self.nAnimationFinishedID = self:Subscribe (eEventType.AIE_ANIMATION_FINISHED, self.tHost)
	
	self:OnResume ()
end

function UpperBodyAnimateAndFace:OnResume ()
	-- Call parent
	TargetState.OnResume (self)

	-- Set the parameters for the brain state
	local tParams = self.tHost:RetUpperBodyAnimateAndFaceParams ()

	tParams:SetAnimID (self.nAnimationID)
	tParams:SetLoop (self.bLooping)
	tParams:SetBlockInterrupts (self.bBlockInterrupts)
	tParams:SetHoldAnimEnd (self.bHoldAnimEnd)
	tParams:SetBlendOut (self.bBlendOut)
	tParams:SetPlayBackRate (self.nPlayBackRate)
	tParams:SetBlendInTime (self.nBlendInTime)
	tParams:SetBlendOutTime (self.nBlendOutTime)

	-- Go into the animation brain state
	self.tHost:UpperBodyAnimateAndFace ()
end

function UpperBodyAnimateAndFace:OnPause ()
	-- Clean up the brain state
	self.tHost:ClearBrainState ()

	-- Call parent
	TargetState.OnPause (self)
end

function UpperBodyAnimateAndFace:OnExit ()
	self:OnPause ()

	-- Call parent
	TargetState.OnExit (self)
end

function UpperBodyAnimateAndFace:OnEvent (tEvent)

	if tEvent:HasID (self.nAnimationFinishedID) then
		
		self:Finish ()
		return true
		
	end
	
	-- Call parent
	return TargetState.OnEvent (self, tEvent)
end
