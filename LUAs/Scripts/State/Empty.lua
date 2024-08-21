----------------------------------------------------------------------
-- Name: Empty State
--	Description: A state that does nothing and finishes immediately
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "System\\State"

Empty = Create (State, 
{
	sStateName = "Empty",
})

function Empty:OnEnter ()
	-- Call parent
	State.OnEnter (self)
	self:Finish ()
end
