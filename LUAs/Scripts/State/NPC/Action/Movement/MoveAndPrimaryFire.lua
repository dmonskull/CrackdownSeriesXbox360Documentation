----------------------------------------------------------------------
-- Name: MoveAndPrimaryFire State
--	Description: Move to a specified position while shooting at the target
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\Action\\Movement\\Move"

MoveAndPrimaryFire = Create (Move, 
{
	sStateName = "MoveAndPrimaryFire",
	nTargetInfoFlags = eTargetInfoFlags.nVisibilityChecks + eTargetInfoFlags.nPrimaryFireChecks,
})

function MoveAndPrimaryFire:MoveToPosition ()
	-- Go into MoveAndPrimaryFire state
	self.tHost:MoveAndPrimaryFire (self.vDestination)
end
