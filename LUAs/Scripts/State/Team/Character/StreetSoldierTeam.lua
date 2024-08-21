----------------------------------------------------------------------
-- Name: StreetSoldierTeam State
--	Description: A type of gangster team that wander aimlessly until they are
-- attacked, at which point they attack the attacker
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\Team\\Character\\PassiveGangsterTeam"
require "State\\Team\\Behaviour\\TeamWander"

StreetSoldierTeam = Create (PassiveGangsterTeam,
{
	sStateName = "StreetSoldierTeam",
})

----------------------------------------------------------------------
-- Bumped into someone while in the wander state
----------------------------------------------------------------------

function StreetSoldierTeam:OnEncounter (tTeamMember, tEntity)

	-- Is it someone I don't like?
	if not self.tHost:IsFriend (tEntity) and tEntity:IsAlive () then

		-- Get the team leader
		local tLeader = self.tHost:RetLeader ()
		assert (tLeader)

		-- Get the gang manager
		local tGangManager = cGangManager.RetGangManager ()
		assert (tGangManager)

		local tGangInControl = tGangManager:RetGangInControl (tTeamMember:RetPosition ())

		-- Push everyone around if my gang is in control
		if tGangInControl == self.tHost:RetTeamSide () then
			self:ChangeState (self:CreateStandoffState (tTeamMember, tEntity))

		-- Be very polite if their gang is in control
		elseif tGangInControl == tEntity:RetTeamSide () then
			self:ChangeState (self:CreateApologiseState (tTeamMember, tEntity))		

		-- If neither is in control, only attack if team leader is brave
		elseif tLeader:RetPersonality () >= ePersonality.nBrave then
			self:ChangeState (self:CreateStandoffState (tTeamMember, tEntity))

		end

	end

end

----------------------------------------------------------------------
-- Idle State - StreetSoldiers use Wander as their 'idle' activity
----------------------------------------------------------------------

function StreetSoldierTeam:CreateIdleState ()
	return Create (TeamWander, {})
end

function StreetSoldierTeam:InIdleState ()
	return self:IsInState (TeamWander)
end

----------------------------------------------------------------------
-- Global Graph tracking - indicates if the NPC should be considered an ambient
-- pedestrian and therefore managed by the population manager
----------------------------------------------------------------------

function StreetSoldierTeam:IsGlobalGraphTracking ()

	if self:InIdleState () or
		self:InWatchState () or
		self:InApologiseState () or
		self:InStandoffState () or
		self:InTransitionToIdleState () then

		return true
	else
		return false
	end

end
