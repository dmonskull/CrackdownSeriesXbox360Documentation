----------------------------------------------------------------------
-- Name: Idle State
--	Description: Stand idle and do nothing
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "System\\State"

Idle = Create (State, 
{
	sStateName = "Idle",
})

function Idle:OnEnter ()
	-- Call parent
	State.OnEnter (self)

	self:OnResume ()
end

function Idle:OnResume ()
	-- Call parent
	State.OnResume (self)

	-- Go into Idle brain state
	self.tHost:Idle ()
end

function Idle:OnPause ()
	-- Clean up the brain state
	self.tHost:ClearBrainState ()

	-- Call parent
	State.OnPause (self)
end

function Idle:OnExit ()
	self:OnPause ()

	-- Call parent
	State.OnExit (self)
end
