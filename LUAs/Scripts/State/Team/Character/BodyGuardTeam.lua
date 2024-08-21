----------------------------------------------------------------------
-- Name: BodyGuardTeam State
--	Description: A type of gangster team that follows a boss and attacks 
-- anything suspicious within a specified attention radius of the boss
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\Team\\Character\\GangsterTeam"
require "State\\Team\\Behaviour\\TeamCombat"

BodyGuardTeam = Create (GangsterTeam,
{
	sStateName = "BodyGuardTeam",
	bLeaderDied = false,
	nRadius = 30,
})

----------------------------------------------------------------------
-- Heard sounds of fighting
-- Over-ride base class to just ignore the sound - BodyGuards only care about
-- suspicious sounds
----------------------------------------------------------------------

function BodyGuardTeam:OnNPCHeardInterestingSound (tNPC, tSource)
end

----------------------------------------------------------------------
-- Team member died
----------------------------------------------------------------------

function BodyGuardTeam:OnNPCDied (tNPC, tKiller)
	-- Set flag to flee when leader is dead
	if tNPC == self.tHost:RetLeader () then
		self.bLeaderDied = true
	end

	-- Call parent
	GangsterTeam.OnNPCDied (self, tNPC, tKiller)
end

----------------------------------------------------------------------
-- Flee when leader is dead
----------------------------------------------------------------------

function BodyGuardTeam:IsFleeConditionSatisfied ()
	return self.bLeaderDied
end

----------------------------------------------------------------------
-- Idle State - TODO
----------------------------------------------------------------------

function BodyGuardTeam:CreateIdleState ()
	return Create (TeamIdle, {})
end

function BodyGuardTeam:InIdleState ()
	return self:IsInState (TeamIdle)
end

----------------------------------------------------------------------
-- Investigate State - Only investigate within the attention radius
----------------------------------------------------------------------

function BodyGuardTeam:CreateInvestigateState (vPosition)
	return Create (TeamInvestigate, 
	{
		vPosition = vPosition,
		tDefendedObject = self.tHost:RetLeader (),
		nRadius = self.nRadius,
	})
end

function BodyGuardTeam:InInvestigateState ()
	return self:IsInState (TeamInvestigate)
end

----------------------------------------------------------------------
-- Alert State - Only take cover within the attention radius
----------------------------------------------------------------------

function BodyGuardTeam:CreateAlertState (tAttacker)
	return Create (TeamAlert, 
	{
		tAttacker = tAttacker,
		tDefendedObject = self.tHost:RetLeader (),
		nRadius = self.nRadius,
	})
end

function BodyGuardTeam:InAlertState ()
	return self:IsInState (TeamAlert)
end

----------------------------------------------------------------------
-- Attack State - Guards defend instead of attacking
----------------------------------------------------------------------

function BodyGuardTeam:CreateAttackState ()
	return Create (TeamCombat, 
	{
		tDefendedObject = self.tHost:RetLeader (),
		nRadius = self.nRadius,
	})
end

function BodyGuardTeam:InAttackState ()
	return self:IsInState (TeamCombat)
end

----------------------------------------------------------------------
-- Search State - Guards only search within their attention radius
----------------------------------------------------------------------

function BodyGuardTeam:CreateSearchState ()
	return Create (TeamSearch, 
	{
		tDefendedObject = self.tHost:RetLeader (),
		nRadius = self.nRadius,
	})
end

function BodyGuardTeam:InSearchState ()
	return self:IsInState (TeamSearch)
end
