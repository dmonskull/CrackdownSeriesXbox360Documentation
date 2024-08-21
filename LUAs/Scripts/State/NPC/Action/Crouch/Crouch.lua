----------------------------------------------------------------------
-- Name: Crouch State
--	Description: Goes into crouch mode
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "System\\State"

Crouch = Create (State, 
{
	sStateName = "Crouch",
})

function Crouch:OnEnter ()
	-- Call parent
	State.OnEnter (self)

	-- HACK! Just crouch immediately for now
	self.tHost:CrouchImmediately ()
	self:Finish ()
end
