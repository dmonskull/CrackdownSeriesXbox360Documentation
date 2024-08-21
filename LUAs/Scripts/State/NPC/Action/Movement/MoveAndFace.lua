----------------------------------------------------------------------
-- Name: MoveAndFace State
--	Description: Move to a specified position while facing the target
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\Action\\Movement\\Move"

MoveAndFace = Create (Move, 
{
	sStateName = "MoveAndFace",
	nTargetInfoFlags = eTargetInfoFlags.nVisibilityChecks,
})

function MoveAndFace:MoveToPosition ()
	-- Go into MoveAndFace state
	self.tHost:MoveAndFace (self.vDestination)
end
