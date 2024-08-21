----------------------------------------------------------------------
-- Name: WanderEx State
--	Description: Extended Wander state - sets animation profile according
-- to whether or not the guy is holding a gun
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\Action\\Wander\\MoveAndWander"

WanderEx = Create (MoveAndWander, 
{
	sStateName = "WanderEx",
})

function WanderEx:OnEnter ()
	-- Call parent
	MoveAndWander.OnEnter (self)
end

function WanderEx:OnExit ()
	-- Call parent
	MoveAndWander.OnExit (self)
end
