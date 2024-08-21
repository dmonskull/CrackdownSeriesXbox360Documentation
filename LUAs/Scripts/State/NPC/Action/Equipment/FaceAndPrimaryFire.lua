----------------------------------------------------------------------
-- Name: FaceAndPrimaryFire State
--	Description: Face the target and shoot continuously at it
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"

FaceAndPrimaryFire = Create (TargetState, 
{
	sStateName = "FaceAndPrimaryFire",
	nTargetInfoFlags = eTargetInfoFlags.nVisibilityChecks + eTargetInfoFlags.nPrimaryFireChecks,
})

function FaceAndPrimaryFire:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)

	self:OnResume ()
end

function FaceAndPrimaryFire:OnResume ()
	-- Call parent
	TargetState.OnResume (self)

	-- Go into FaceAndPrimaryFire state
	self.tHost:FaceAndPrimaryFire ()
end

function FaceAndPrimaryFire:OnPause ()
	-- Clean up the brain state
	self.tHost:ClearBrainState ()

	-- Call parent
	TargetState.OnPause (self)
end

function FaceAndPrimaryFire:OnExit ()
	self:OnPause ()

	-- Call parent
	TargetState.OnExit (self)
end
