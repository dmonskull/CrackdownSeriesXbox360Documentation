----------------------------------------------------------------------
-- Name: Template State
-- Description: Demonstrates a typical state which you can cut and paste
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "System\\State"

Template = Create (State, 
{
	sStateName = "Template",
})

function Template:OnEnter ()
	-- Call parent
	State.OnEnter (self)
end

function Template:OnExit ()
	-- Call parent
	State.OnExit (self)
end

function Template:OnEvent (tEvent)
	-- Call parent
	return State.OnEvent (self, tEvent)
end

function Template:OnActiveStateFinished ()
	-- Call parent
	return State.OnActiveStateFinished (self)
end
