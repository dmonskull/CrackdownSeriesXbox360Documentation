----------------------------------------------------------------------
-- Name: Face State
--	Description: Continually face the target
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"

Face = Create (TargetState, 
{
	sStateName = "Face",
})

function Face:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)

	self:OnResume ()
end

function Face:OnResume ()
	-- Call parent
	TargetState.OnResume (self)

	-- Go into the Face brain state
	self.tHost:Face ()
end

function Face:OnPause ()
	-- Clean up the brain state
	self.tHost:ClearBrainState ()

	-- Call parent
	TargetState.OnPause (self)
end

function Face:OnExit ()
	self:OnPause ()

	-- Call parent
	TargetState.OnExit (self)
end
