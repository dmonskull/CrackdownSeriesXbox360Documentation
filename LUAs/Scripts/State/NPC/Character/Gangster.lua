----------------------------------------------------------------------
-- Name: Gangster State
--	Description: Base class to handle all combat behaviour
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "System\\State"
require "State\\NPC\\Behaviour\\StandIdle"
require "State\\NPC\\Behaviour\\Watch\\TimedWatch"
require "State\\NPC\\Behaviour\\Investigate"
require "State\\NPC\\Behaviour\\Alert\\Alert"
require "State\\NPC\\Behaviour\\Combat\\Combat"
require "State\\NPC\\Behaviour\\Retreat\\TimedRetreat"
require "State\\NPC\\Behaviour\\Search\\Search"
require "State\\NPC\\Behaviour\\Scripted\\GiveUpSearch"
require "State\\NPC\\Behaviour\\Victory\\Victory"
require "State\\NPC\\Behaviour\\Arm\\Arm"

Gangster = Create (State, 
{
	sStateName = "Gangster",
})

function Gangster:OnEnter()
	-- Call parent
	State.OnEnter (self)

	-- Save the current viewing distance
	self.nIdleViewingDistance = self.nIdleViewingDistance or self.tHost:RetViewingDistance ()
	self.nAlertViewingDistance = self.nAlertViewingDistance or self.tHost:RetViewingDistance ()

	-- Subscribe to events
	self:SubscribeNPCTriggerEvents (self.tHost)

	-- Enter Initial state
	self:PushState (self:CreateInitialState ())
end

function Gangster:CreateInitialState ()

	if self.tEnemy then
		-- If you specify an enemy as a parameter it will attack them immediately
		return self:CreateAttackState (self.tEnemy)
	else
		-- Start in the Idle state by default
		return self:CreateTransitionToIdleState ()
	end

end

function Gangster:OnActiveStateFinished ()
	
	local tState = self:RetActiveState ()

	if self:InAlertState () then

		if tState:AttackerFound () then

			-- We spotted an enemy
			self:ChangeState (self:CreateAttackState (tState.tAttacker))

		else

			-- Search for the enemy
			self:ChangeState (self:CreateSearchState (tState.tAttacker, tState.vOriginalPosition, tState.vCoverPosition, tState.vAttackDirection))

		end
		return true

	elseif self:InAttackState () then

		local tEnemy = self.tHost:RetNearestVisibleEnemy ()
		if tEnemy then

			-- Another enemy is visible - attack them instead
			self:ChangeState (self:CreateAttackState (tEnemy))

		elseif tState:TargetLost () then

			-- Target was lost - search for them
			self:ChangeState (self:CreateSearchState (tState.tTarget, tState.vLastTargetPosition, tState.vLastTargetViewPointPosition, tState.vLastTargetVelocity))

		elseif tState:TargetDied () then

			-- Target was killed - victory
			self:ChangeState (self:CreateVictoryState (tState.tTarget))

		elseif tState:TargetDeleted () then

			-- Target was deleted
			self:ChangeState (self:CreateTransitionToIdleState ())

		end
		return true

	elseif self:InSearchState () then

		if tState:TargetFound () then

			-- We found the target - attack
			self:ChangeState (self:CreateAttackState (tState.tTarget))

		elseif tState:TargetDied () then

			-- We found the corpse of the target we were looking for - victory
			self:ChangeState (self:CreateVictoryState (tState.tTarget))

		elseif tState:TargetLost () then

			-- We didn't find the target we were looking for - give up
			self:ChangeState (self:CreateGiveUpState ())

		end
		return true

	elseif self:InInvestigateState () then

		self:ChangeState (self:CreateTransitionToIdleState ())
		return true

	elseif self:InFleeState () then

		self:ChangeState (self:CreateTransitionToIdleState ())
		return true

	elseif self:InGiveUpState () then

		self:ChangeState (self:CreateTransitionToIdleState ())
		return true

	elseif self:InVictoryState () then

		self:ChangeState (self:CreateTransitionToIdleState ())
		return true

	elseif self:InWatchState () then

		self:ChangeState (self:CreateTransitionToIdleState ())
		return true		

	elseif self:InTransitionToIdleState () then

		self:ChangeState (self:CreateIdleState ())
		return true

	end

	-- Call Parent
	return State.OnActiveStateFinished (self)
end

function Gangster:OnActiveStateUnlocked ()

	if self:InAlertState () then
	
		-- An enemy could have appeared while the Alert state was locked
		local tEnemy = self.tHost:RetNearestVisibleEnemy ()
		if tEnemy then

			self:ChangeState (self:CreateAttackState (tEnemy))

		end
		return true

	end
	
	-- Call parent
	return State.OnActiveStateUnlocked (self)
end

function Gangster:OnActiveStateChanged ()
	-- Cause events to be generated when the NPC reverts to idle state
	self.tHost:SetIsIdle (self:InIdleState () or self:RetStackSize () == 0)

	-- Set the map status value - indicates what colour the NPC is shown on the map
	self.tHost:SetMapStatus (self:RetMapStatus ())

	-- Set Global Graph tracking - indicates if the NPC should be considered an ambient
	-- pedestrian and therefore managed by the population manager
	self.tHost:SetGlobalGraphTracking (self:IsGlobalGraphTracking ())	

	-- Set length of view cone
	self.tHost:SetViewingDistance (self:RetViewingDistance ())

	-- Call parent
	State.OnActiveStateChanged (self)
end

function Gangster:OnExit ()
	-- Call parent
	State.OnExit (self)
	self.tHost:SetIsIdle (true)
end

----------------------------------------------------------------------
-- Took damage from an enemy - the attacker's location is not necessarily known
----------------------------------------------------------------------

function Gangster:OnNPCAttacked (tNPC, tAttacker)

	if self:IsFleeConditionSatisfied (tAttacker) then

		self:ChangeState (self:CreateFleeState (tAttacker))

	elseif self:IsAlertConditionSatisfied (tAttacker) then
		
		self:ChangeState (self:CreateAlertState (tAttacker))

	end

end

----------------------------------------------------------------------
-- Detected an enemy - i.e. the position of an enemy is now known, either
-- because they attacked us or because we saw them
----------------------------------------------------------------------

function Gangster:OnNPCDetectedEnemy (tNPC, tEnemy)

	if self:IsFleeConditionSatisfied (tEnemy) then

		self:ChangeState (self:CreateFleeState (tEnemy))

	elseif self:IsAttackConditionSatisfied (tEnemy) then

		self:ChangeState (self:CreateAttackState (tEnemy))

	end

end

----------------------------------------------------------------------
-- Heard a suspicious sound
----------------------------------------------------------------------

function Gangster:OnNPCHeardSuspiciousSound (tNPC, vPosition)

	if self:IsInvestigateConditionSatisfied (vPosition) then

		-- Investigate the sound
		self:ChangeState (self:CreateInvestigateState (vPosition))

	end

end

----------------------------------------------------------------------
-- Heard sounds of fighting
----------------------------------------------------------------------

function Gangster:OnNPCHeardInterestingSound (tNPC, tSource)

	if self:IsWatchConditionSatisfied (tSource) then

		-- Watch the exciting things that are happening
		self:ChangeState (self:CreateWatchState (tSource))

	end

end

----------------------------------------------------------------------
-- NPC died - finish the state
----------------------------------------------------------------------

function Gangster:OnNPCDied (tNPC, tKiller)
	self.tHost:ShoutPainAudio (eVocals.nDeath, "Urgh!", tKiller)
	self:Finish ()
end

----------------------------------------------------------------------
-- Will turn to watch the source of an interesting sound if we are idle
----------------------------------------------------------------------

function Gangster:IsWatchConditionSatisfied (tEntity)

	if not self:IsActiveStateLocked () then

		if self:InPreWatchState () then
			return true
		end

	end
	return false

end

----------------------------------------------------------------------
-- Will investigate a suspicious sound if we are not in alert, attack,
-- search or flee states
----------------------------------------------------------------------

function Gangster:IsInvestigateConditionSatisfied (vPosition)

	if not self:IsActiveStateLocked () then

		if self:InPreInvestigateState () then
			return true
		end

	end
	return false

end

----------------------------------------------------------------------
-- Will become alert on being attacked if we are not in alert, attack
-- or flee states
----------------------------------------------------------------------

function Gangster:IsAlertConditionSatisfied (tEnemy)

	if not self:IsActiveStateLocked () then

		if self:InPreAlertState () then
			return true
		end

	end
	return false

end

----------------------------------------------------------------------
-- Will attack if enemy is detected if we are not in attack or
-- flee states
----------------------------------------------------------------------

function Gangster:IsAttackConditionSatisfied (tEnemy)

	if not self:IsActiveStateLocked () then

		if self:InPreAttackState () then
			return true
		end

	end
	return false

end

----------------------------------------------------------------------
-- Has enough damage been done to us for us to want to flee?
----------------------------------------------------------------------

function Gangster:IsFleeConditionSatisfied (tEnemy)

	if not self:IsActiveStateLocked () then

		if self:InPreFleeState () then

			if self.tHost:RetHealth () < 50 then
		
				-- If I am particularly cowardly then flee
				if self.tHost:RetPersonality () <= ePersonality.nCowardly then

					return true
	
				end
		
			end

		end

	end
	return false

end

----------------------------------------------------------------------
-- Return the current enemy
----------------------------------------------------------------------

function Gangster:RetEnemy ()
	if self:InAttackState () then
		local tState = self:RetActiveState ()
		return tState.tTarget
	end
	return nil
end

----------------------------------------------------------------------
-- Create State functions - over-ride these to use custom states
----------------------------------------------------------------------

function Gangster:CreateIdleState ()
	return Create (StandIdle, {})
end

function Gangster:CreateWatchState (tSource)
	return Create (TimedWatch, 
	{
		tEntity = tSource,
	})
end

function Gangster:CreateInvestigateState (vPosition)
	return Create (Investigate, 
	{
		vPosition = vPosition,
	})
end

function Gangster:CreateAlertState (tAttacker)
	return Create (Alert, 
	{
		tAttacker = tAttacker,
	})
end

function Gangster:CreateAttackState (tTarget)
	return Create (Combat, 
	{
		tTarget = tTarget,
	})
end

function Gangster:CreateSearchState (tTarget, vStartingPosition, vViewPointPosition, vDirection)
	return Create (Search, 
	{
		tTarget = tTarget,
		vStartingPosition = vStartingPosition,
		vViewPointPosition = vViewPointPosition,
		vDirection = vDirection,
	})
end

function Gangster:CreateFleeState (tEnemy)
	return Create (TimedRetreat, 
	{
		tTarget = tEnemy,
	})
end

function Gangster:CreateVictoryState (tTarget)
	return Create (Victory,
	{
		tTarget = tTarget,
	})
end

function Gangster:CreateGiveUpState ()
	return Create (GiveUpSearch, {})
end

function Gangster:CreateTransitionToIdleState ()
	-- Gangsters carry weapons when in their idle state
	return Create (Arm, {})
end

----------------------------------------------------------------------
-- Return true if we are in a particular state - over-ride these if using custom states
----------------------------------------------------------------------

function Gangster:InIdleState ()
	return self:IsInState (StandIdle)
end

function Gangster:InWatchState ()
	return self:IsInState (TimedWatch)
end

function Gangster:InInvestigateState ()
	return self:IsInState (Investigate)
end

function Gangster:InAlertState ()
	return self:IsInState (Alert)
end

function Gangster:InAttackState ()
	return self:IsInState (Combat)
end

function Gangster:InSearchState ()
	return self:IsInState (Search)
end

function Gangster:InFleeState ()
	return self:IsInState (Retreat)
end

function Gangster:InVictoryState ()
	return self:IsInState (Victory)
end

function Gangster:InGiveUpState ()
	return self:IsInState (GiveUpSearch)
end

function Gangster:InTransitionToIdleState ()
	return self:IsInState (Arm)
end

----------------------------------------------------------------------
-- Return true if we can break out of the current state to enter a new one
----------------------------------------------------------------------

function Gangster:InPreWatchState ()
	return self:InIdleState ()
end

function Gangster:InPreInvestigateState ()
	return self:InIdleState () or 
		self:InTransitionToIdleState () or
		self:InWatchState () or
		self:InGiveUpState () or 
		self:InVictoryState ()
end

function Gangster:InPreAlertState ()
	return self:InIdleState () or
		self:InTransitionToIdleState () or
		self:InWatchState () or
		self:InGiveUpState () or 
		self:InVictoryState () or
		self:InInvestigateState () or
		self:InSearchState ()
end

function Gangster:InPreAttackState ()
	return self:InIdleState () or
		self:InTransitionToIdleState () or
		self:InWatchState () or
		self:InGiveUpState () or 
		self:InVictoryState () or
		self:InInvestigateState () or
		self:InAlertState () or
		self:InSearchState ()
end

function Gangster:InPreFleeState ()
	return self:InIdleState () or
		self:InTransitionToIdleState () or
		self:InWatchState () or
		self:InGiveUpState () or 
		self:InVictoryState () or
		self:InAlertState () or
		self:InInvestigateState () or
		self:InAttackState () or
		self:InSearchState ()
end

----------------------------------------------------------------------
-- Global Graph tracking - indicates if the NPC should be considered an ambient
-- pedestrian and therefore managed by the population manager
----------------------------------------------------------------------

function Gangster:IsGlobalGraphTracking ()
	return false
end

----------------------------------------------------------------------
-- Map Status - Indicates what colour the NPC will be displayed on the map
----------------------------------------------------------------------

function Gangster:RetMapStatus ()

	if self:InAttackState () then

		return eMapStatus.nAttacking

	elseif self:InInvestigateState () or
			self:InAlertState () or
			self:InSearchState () then

		return eMapStatus.nAlerted

	elseif self:InFleeState () then

		return eMapStatus.nFleeing

	else

		return eMapStatus.nStandard

	end

end

----------------------------------------------------------------------
-- Length of view cone
----------------------------------------------------------------------

function Gangster:RetViewingDistance ()

	if self:InIdleState () or
		self:InTransitionToIdleState () or
		self:InWatchState () then

		return self.nIdleViewingDistance
	else
		return self.nAlertViewingDistance
	end

end

----------------------------------------------------------------------
-- Return true if the Gangster is available for use in ambient crimes
----------------------------------------------------------------------

function Gangster:IsAvailable ()
	return false
end
