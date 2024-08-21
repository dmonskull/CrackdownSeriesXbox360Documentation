----------------------------------------------------------------------
-- Name: TeamIdle State
--	Description: All team members stand around idle
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\Team\\TeamState"
require "State\\NPC\\Behaviour\\StandIdle"

TeamIdle = Create (TeamState,
{
	sStateName = "TeamIdle",
})

function TeamIdle:OnEnter ()
	-- Call parent
	TeamState.OnEnter (self)
end

function TeamIdle:OnEnterTeamMember (tTeamMember)
	-- Call parent
	TeamState.OnEnterTeamMember (self, tTeamMember)

	-- Set to stand idle
	tTeamMember:SetState (StandIdle)
end
