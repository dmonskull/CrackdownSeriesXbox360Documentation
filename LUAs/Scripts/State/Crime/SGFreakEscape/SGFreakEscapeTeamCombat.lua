----------------------------------------------------------------------
-- Name: SGFreakEscapeTeamCombat State
--	Description: Juan runs to his defensive position and stays there
-- The first bodyguard follows him and defends him
-- The remaining bodyguards try to take on the enemy
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\Team\\Behaviour\\TeamCombat"
require "State\\NPC\\Behaviour\\Combat\\Combat"
require "State\\NPC\\Behaviour\\Watch\\Watch"

namespace ("SGFreakEscape")

SGFreakEscapeTeamCombat = Create (TeamCombat,
{
	sStateName = "SGFreakEscapeTeamCombat",
})

function SGFreakEscapeTeamCombat:RetMaxMembersAssignedToEnemy ()
	-- Return the maximum number of team members that can be assigned to one enemy
	return 1
end

function SGFreakEscapeTeamCombat:RetMaxDistanceToEnemy ()
	-- Return the maximum distance a team member is allowed to be from an enemy's
	-- last known position in order to be assigned to that enemy
	return 20
end

function SGFreakEscapeTeamCombat:CreateCombatState (tTeamMember, tEnemy)
	-- This is the state team members use to fight an enemy
	return Create (Combat,
	{
		tTarget = tEnemy,
	})
end

function SGFreakEscapeTeamCombat:CreateIdleState (tTeamMember)
	-- This is the state team members use when there are no enemies
	-- available to fight that match the necessary criteria
	local tEnemy = self.tHost:RetClosestEnemyWithStatus (eEnemyStatus.nActive, tTeamMember:RetPosition ())
	assert (tEnemy)

	return Create (Watch,
	{
		tEntity = tEnemy,
	})
end
