----------------------------------------------------------------------
-- Name: PreCombat State
--	Description: Taunt an enemy, probably the player
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "System\\State"

namespace ("DrugDealer")

PreCombat = Create (State,
{
	sStateName = "PreCombat",
})

function PreCombat:OnEnter ()
	-- Call parent
	State.OnEnter (self)
end
