----------------------------------------------------------------------
-- Name: Pedestrian State
--	Description: Wanders aimlessly, runs away if attacked
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\Character\\PassiveGangster"
require "State\\NPC\\Behaviour\\Scripted\\Thank"
require "State\\NPC\\Behaviour\\Wander\\WanderEx"
require "State\\NPC\\Behaviour\\Arm\\Disarm"

Pedestrian = Create (PassiveGangster, 
{
	sStateName = "Pedestrian",
	bOnSideWalk = false,
})

function Pedestrian:OnActiveStateFinished ()

	if self:InThankState () then

		self:ChangeState (self:CreateTransitionToIdleState ())
		return true

	end

	-- Call Parent
	return PassiveGangster.OnActiveStateFinished (self)
end

----------------------------------------------------------------------
-- Bumped into someone while in the wander state
----------------------------------------------------------------------

function Pedestrian:OnEncounter (tEntity)

	if tEntity:IsAlive () then

		-- Get the gang manager
		local tGangManager = cGangManager.RetGangManager ()
		assert (tGangManager)
	
		local tGangInControl = tGangManager:RetGangInControl (self.tHost:RetPosition ())
	
		-- If their gang has control of the area then respect them
		if tGangInControl == tEntity:RetTeamSide () then
	
			-- Thank the player for defeating the gangs
			if tEntity:IsA (cPlayer) then
				self:ChangeState (self:CreateThankState (tEntity))				
			else
				self:ChangeState (self:CreateApologiseState (tEntity))				
			end
	
		-- If their gang is not in control and they are an enemy and I am very brave, attack them
		elseif self.tHost:IsEnemy (tEntity) and self.tHost:RetPersonality () >= ePersonality.nBrave then
			
			self:ChangeState (self:CreateStandoffState (tEntity))
	
		elseif tEntity:IsA (cPlayer) then
	
			self:ChangeState (self:CreateApologiseState (tEntity))				
	
		end

	end
	
end

----------------------------------------------------------------------
-- Heard sounds of fighting
----------------------------------------------------------------------

function Pedestrian:OnNPCHeardInterestingSound (tNPC, tSource)

	if self:IsFleeConditionSatisfied (nil) then

		self:ChangeState (self:CreateFleeState (tSource))

	elseif self:IsWatchConditionSatisfied (tSource) then

		self:ChangeState (self:CreateWatchState (tSource))

	end

end

----------------------------------------------------------------------
-- Will turn to watch the source of an interesting sound if we are brave enough
----------------------------------------------------------------------

function Pedestrian:IsWatchConditionSatisfied (tSource)

	-- Call parent
	if PassiveGangster.IsWatchConditionSatisfied (self, tSource) then

		-- If I am brave, watch the exciting things that are happening
		if self.tHost:RetPersonality () >= ePersonality.nBrave then
			return true
		end

	end
	return false

end

----------------------------------------------------------------------
-- Should I flee on being attacked?
----------------------------------------------------------------------

function Pedestrian:IsFleeConditionSatisfied (tEnemy)

	if not self:IsActiveStateLocked () then

		if self:InPreFleeState () then

			-- If I am not particularly brave, then flee
			if self.tHost:RetPersonality () < ePersonality.nBrave then
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
-- Idle State - Pedestrians wander around as their 'idle' activity
----------------------------------------------------------------------

function Pedestrian:CreateIdleState ()
	local tState = Create (WanderEx, 
	{
		bOnSideWalk = self.bOnSideWalk,
	})
	self.bOnSideWalk = false
	return tState
end

function Pedestrian:InIdleState ()
	return self:IsInState (WanderEx)
end

----------------------------------------------------------------------
-- Transition To Idle State - Pedestrians don't carry weapons when in their idle state
----------------------------------------------------------------------

function Pedestrian:CreateTransitionToIdleState ()
	return Create (Disarm, {})
end

function Pedestrian:InTransitionToIdleState ()
	return self:IsInState (Disarm)
end

----------------------------------------------------------------------
-- Thank State
----------------------------------------------------------------------

function Pedestrian:CreateThankState (tTarget)
	return Create (Thank, 
	{
		tTarget = tTarget,
	})
end

function Pedestrian:InThankState ()
	return self:IsInState (Thank)
end

----------------------------------------------------------------------
-- Return true if we can break out of the current state to enter a new one
-- Over-ride base class to include Thank state
----------------------------------------------------------------------

function Pedestrian:InPreAlertState ()
	return PassiveGangster.InPreAlertState (self) or self:InThankState ()
end

function Pedestrian:InPreAttackState ()
	return PassiveGangster.InPreAttackState (self) or self:InThankState ()
end

function Pedestrian:InPreFleeState ()
	return PassiveGangster.InPreFleeState (self) or self:InThankState ()
end

----------------------------------------------------------------------
-- Global Graph tracking - indicates if the NPC should be considered an ambient
-- pedestrian and therefore managed by the population manager
----------------------------------------------------------------------

function Pedestrian:IsGlobalGraphTracking ()

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

----------------------------------------------------------------------
-- Return true if the pedestrian is available for use in ambient crimes
----------------------------------------------------------------------

function Pedestrian:IsAvailable ()
	return self:InIdleState ()
end
