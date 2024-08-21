----------------------------------------------------------------------
-- Name: GuardTeam State
--	Description: A type of gangster team that patrols along a set path and attacks 
-- anything suspicious within a specified attention radius
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\Team\\Character\\GangsterTeam"
require "State\\Team\\Behaviour\\TeamPatrol"
require "State\\Team\\Behaviour\\TeamCombat"

GuardTeam = Create (GangsterTeam,
{
	sStateName = "GuardTeam",
	nRadius = 30,
})

function GuardTeam:OnEnter ()
	-- Check parameters
	assert (self.tPatrolRouteNames)

	-- Call parent
	GangsterTeam.OnEnter (self)
end

function GuardTeam:OnEnterTeamMember (tTeamMember)
	-- Call parent
	GangsterTeam.OnEnterTeamMember (self, tTeamMember)

	-- Get a pointer to the team leader
	local tLeader = self.tHost:RetLeader ()
	assert (tLeader)

	-- Set Properties
	tTeamMember:SetGuardRadius (self.nRadius)
	tTeamMember:SetGuardPosition (tLeader:RetPosition ())
end

----------------------------------------------------------------------
-- Heard sounds of fighting
-- Over-ride base class to just ignore the sound - Guards only care about
-- suspicious sounds
----------------------------------------------------------------------

function GuardTeam:OnNPCHeardInterestingSound (tNPC, tSource)
end

----------------------------------------------------------------------
-- Idle State - Guards use Patrol as their 'idle' activity
----------------------------------------------------------------------

function GuardTeam:CreateIdleState ()
	return Create (TeamPatrol, 
	{
		tPatrolRouteNames = self.tPatrolRouteNames,
	})
end

function GuardTeam:InIdleState ()
	return self:IsInState (TeamPatrol)
end

----------------------------------------------------------------------
-- Investigate State - Only investigate within the attention radius
----------------------------------------------------------------------

function GuardTeam:CreateInvestigateState (vPosition)
	-- Get a pointer to the team leader
	local tLeader = self.tHost:RetLeader ()
	assert (tLeader)

	return Create (TeamInvestigate, 
	{
		vPosition = vPosition,
		vDefendedPosition = tLeader:RetGuardPosition (),
		nRadius = self.nRadius,
	})
end

function GuardTeam:InInvestigateState ()
	return self:IsInState (TeamInvestigate)
end

----------------------------------------------------------------------
-- Alert State - Only take cover within the attention radius
----------------------------------------------------------------------

function GuardTeam:CreateAlertState (tAttacker)
	-- Get a pointer to the team leader
	local tLeader = self.tHost:RetLeader ()
	assert (tLeader)

	return Create (TeamAlert, 
	{
		tAttacker = tAttacker,
		vDefendedPosition = tLeader:RetPatrolPosition (),
		nRadius = self.nRadius,
	})
end

function GuardTeam:InAlertState ()
	return self:IsInState (TeamAlert)
end

----------------------------------------------------------------------
-- Attack State - Guards defend instead of attacking
----------------------------------------------------------------------

function GuardTeam:CreateAttackState ()
	-- Get a pointer to the team leader
	local tLeader = self.tHost:RetLeader ()
	assert (tLeader)

	return Create (TeamCombat, 
	{
		vDefendedPosition = tLeader:RetPatrolPosition (),
		nRadius = self.nRadius,
	})
end

function GuardTeam:InAttackState ()
	return self:IsInState (TeamCombat)
end

----------------------------------------------------------------------
-- Search State - Guards only search within their attention radius
----------------------------------------------------------------------

function GuardTeam:CreateSearchState ()
	-- Get a pointer to the team leader
	local tLeader = self.tHost:RetLeader ()
	assert (tLeader)

	return Create (Search, 
	{
		vDefendedPosition = tLeader:RetPatrolPosition (),
		nRadius = self.nRadius,
	})
end

function GuardTeam:InSearchState ()
	return self:IsInState (Search)
end

----------------------------------------------------------------------
-- Map Status - Indicates what colour the NPCs will be displayed on the map
----------------------------------------------------------------------

function GuardTeam:RetMapStatus ()

	if self:InIdleState () then
		return eMapStatus.nPatrolling
	end

	-- Call parent
	return GangsterTeam.RetMapStatus (self)
end
