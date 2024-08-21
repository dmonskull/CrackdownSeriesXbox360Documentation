----------------------------------------------------------------------
-- Name: Follow State
--	Description: Follow another character at a specified distance and a
-- specified angle relative to the other character's heading
-- This state does NOT target the character it is following, and it always 
-- magically knows where the character is even if it is not visible
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"

Follow = Create (TargetState, 
{
	sStateName = "Follow",
	nTargetInfoFlags = eTargetInfoFlags.nAlwaysTrack,
	nMovementPriority = eMovementPriority.nLow,
	nDistance = 5,
	nAngle = 180,
})

function Follow:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)

	self:OnResume ()
end

function Follow:OnResume ()
	-- Call parent
	TargetState.OnResume (self)

	-- Set priority
	self.tHost:SetMovementPriority (self.nMovementPriority)

	-- Go into Follow brain state
	self.tHost:Follow (self.nDistance, self.nAngle)
end

function Follow:OnPause ()
	-- Clean up the brain state
	self.tHost:ClearBrainState ()

	-- Call parent
	TargetState.OnPause (self)
end

function Follow:OnExit ()
	self:OnPause ()

	-- Call parent
	TargetState.OnExit (self)
end
