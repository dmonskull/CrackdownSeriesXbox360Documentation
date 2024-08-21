----------------------------------------------------------------------
-- Name: Uncrouch State
--	Description: Goes out of crouch mode
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "System\\State"

Uncrouch = Create (State, 
{
	sStateName = "Uncrouch",
})

function Uncrouch:OnEnter ()
	-- Call parent
	State.OnEnter (self)

	-- HACK! Just uncrouch immediately for now
	self.tHost:UncrouchImmediately ()
	self:Finish ()
end
