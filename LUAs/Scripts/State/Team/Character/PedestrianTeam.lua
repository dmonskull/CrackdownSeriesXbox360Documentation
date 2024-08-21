----------------------------------------------------------------------
-- Name: StreetSoldierTeam State
--	Description: A type of gangster team that wander aimlessly until they are
-- attacked, at which point they attack the attacker
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\Team\\Character\\PassiveGangsterTeam"
require "State\\Team\\Behaviour\\TeamThank"
require "State\\Team\\Behaviour\\TeamWander"
require "State\\Team\\Behaviour\\TeamDisarm"

PedestrianTeam = Create (PassiveGangsterTeam,
{
	sStateName = "PedestrianTeam",
})

function PedestrianTeam:OnActiveStateFinished ()

	if self:InThankState () then

		self:ChangeState (self:CreateTransitionToIdleState ())
		return true

	end

	-- Call Parent
	return PassiveGangsterTeam.OnActiveStateFinished (self)
end

----------------------------------------------------------------------
-- Bumped into someone while in the wander state
----------------------------------------------------------------------

function PedestrianTeam:OnEncounter (tTeamMember, tEntity)

	if tEntity:IsAlive () and not self.tHost:IsEntityMemberOfTeam (tEntity) then

		-- Get the team leader
		local tLeader = self.tHost:RetLeader ()
		assert (tLeader)

		-- Get the gang manager
		local tGangManager = cGangManager.RetGangManager ()
		assert (tGangManager)
	
		local tGangInControl = tGangManager:RetGangInControl (tTeamMember:RetPosition ())
	
		-- If their gang has control of the area then respect them
		if tGangInControl == tEntity:RetTeamSide () then
	
			-- Thank the player for defeating the gangs
			if tEntity:IsA (cPlayer) then
				self:ChangeState (self:CreateThankState (tTeamMember, tEntity))			
			else
				self:ChangeState (self:CreateApologiseState (tTeamMember, tEntity))
			end
	
		-- If their gang is not in control and they are an enemy and I am very brave, attack them
		elseif self.tHost:IsEnemy (tEntity) and tLeader:RetPersonality () >= ePersonality.nBrave then
			
			self:ChangeState (self:CreateStandoffState (tTeamMember, tEntity))
	
		elseif tEntity:IsA (cPlayer) then
	
			self:ChangeState (self:CreateApologiseState (tTeamMember, tEntity))
	
		end

	end

end

----------------------------------------------------------------------
-- Heard sounds of fighting
----------------------------------------------------------------------

function PedestrianTeam:OnNPCHeardInterestingSound (tNPC, tSource)

	if self:IsFleeConditionSatisfied (nil) then

		self:ChangeState (self:CreateFleeState (tSource))

	elseif self:IsWatchConditionSatisfied (tSource) then

		self:ChangeState (self:CreateWatchState (tSource))

	end

end

----------------------------------------------------------------------
-- Will turn to watch the source of an interesting sound if we are brave enough
----------------------------------------------------------------------

function PedestrianTeam:IsWatchConditionSatisfied (tSource)

	-- Call parent
	if PassiveGangsterTeam.IsWatchConditionSatisfied (self, tSource) then

		-- If the team leader is brave, all watch the exciting things that are happening
		local tLeader = self.tHost:RetLeader ()
		if tLeader and tLeader:RetPersonality () >= ePersonality.nBrave then
			return true
		end

	end
	return false

end

----------------------------------------------------------------------
-- Should I flee on being attacked?
----------------------------------------------------------------------

function PedestrianTeam:IsFleeConditionSatisfied (tEnemy)

	if not self:IsActiveStateLocked () then

		if self:InPreFleeState () then

			-- If the team leader is not particularly brave, then all flee
			local tLeader = self.tHost:RetLeader ()
			if tLeader and tLeader:RetPersonality () < ePersonality.nBrave then
				return true
			end

			-- If the gang that attacked me owns this area, always flee
			if tEnemy and
				tEnemy:RetTeamSide () and
				tEnemy:RetTeamSide ():RetInfluence (self.tHost:RetPosition ()) > 0 then
				return true
			end

		end
		
	end
	return false

end

----------------------------------------------------------------------
-- Idle State - PedestrianTeams use Wander as their 'idle' activity
----------------------------------------------------------------------

function PedestrianTeam:CreateIdleState ()
	return Create (TeamWander, {})
end

function PedestrianTeam:InIdleState ()
	return self:IsInState (TeamWander)
end

----------------------------------------------------------------------
-- Transition To Idle State - Pedestrians don't carry weapons when in their idle state
----------------------------------------------------------------------

function PedestrianTeam:CreateTransitionToIdleState ()
	return Create (TeamDisarm, {})
end

function PedestrianTeam:InTransitionToIdleState ()
	return self:IsInState (TeamDisarm)
end

----------------------------------------------------------------------
-- Thank State
----------------------------------------------------------------------

function PedestrianTeam:CreateThankState (tTeamMember, tTarget)
	return Create (TeamThank, 
	{
		tTarget = tTarget,
	})
end

function PedestrianTeam:InThankState ()
	return self:IsInState (TeamThank)
end

----------------------------------------------------------------------
-- Return true if we can break out of the current state to enter a new one
-- Over-ride base class to include Thank state
----------------------------------------------------------------------

function PedestrianTeam:InPreAlertState ()
	return PassiveGangster.InPreAlertState (self) or self:InThankState ()
end

function PedestrianTeam:InPreAttackState ()
	return PassiveGangster.InPreAttackState (self) or self:InThankState ()
end

function PedestrianTeam:InPreFleeState ()
	return PassiveGangster.InPreFleeState (self) or self:InThankState ()
end

----------------------------------------------------------------------
-- Global Graph tracking - indicates if the NPC should be considered an ambient
-- pedestrian and therefore managed by the population manager
----------------------------------------------------------------------

function PedestrianTeam:IsGlobalGraphTracking ()

	if self:InIdleState () or
		self:InWatchState () or
		self:InApologiseState () or
		self:InStandoffState () or
		self:InThankState () or
		self:InTransitionToIdleState () then

		return true
	else
		return false
	end

end
