----------------------------------------------------------------------
-- Name: SGFreakEscapeTeam State
--	Description: Combat behaviour for the gang war crime
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\Team\\Character\\GangsterTeam"
require "State\\Crime\\SGFreakEscape\\SGFreakEscapeTeamCombat"

namespace ("SGFreakEscape")

SGFreakEscapeTeam = Create (GangsterTeam, 
{
	sStateName = "SGFreakEscapeTeam",
})

----------------------------------------------------------------------
-- Attack State - Use specialised combat state 
----------------------------------------------------------------------

function SGFreakEscapeTeam:CreateAttackState ()
	return Create (SGFreakEscapeTeamCombat, {})
end

function SGFreakEscapeTeam:InAttackState ()
	return self:IsInState (SGFreakEscapeTeamCombat)
end
