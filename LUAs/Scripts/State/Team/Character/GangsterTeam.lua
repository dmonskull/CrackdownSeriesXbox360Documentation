----------------------------------------------------------------------
-- Name: GangsterTeam State
--	Description: Generic Team state to handle group attack behaviour, etc.
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\Team\\TeamState"
require "State\\Team\\Behaviour\\TeamIdle"
require "State\\Team\\Behaviour\\TeamWatch"
require "State\\Team\\Behaviour\\TeamInvestigate"
require "State\\Team\\Behaviour\\TeamAlert"
require "State\\Team\\Behaviour\\TeamCombat"
require "State\\Team\\Behaviour\\TeamSearch"
require "State\\Team\\Behaviour\\TeamFlee"
require "State\\Team\\Behaviour\\TeamVictory"
require "State\\Team\\Behaviour\\TeamGiveUp"
require "State\\Team\\Behaviour\\TeamArm"

GangsterTeam = Create (TeamState,
{
	sStateName = "GangsterTeam",
})

function GangsterTeam:OnEnter ()
	-- Call parent
	TeamState.OnEnter (self)

	-- Enter Initial state
	self:PushState (self:CreateInitialState ())
end

function GangsterTeam:CreateInitialState ()

	-- If enemies have already been added to the list then attack immediately
	if self.tHost:RetNumberOfEnemiesWithStatus (eEnemyStatus.nActive) > 0 then

		-- Attack
		return self:CreateAttackState ()

	elseif self.tHost:RetNumberOfEnemiesWithStatus (eEnemyStatus.nLost) > 0 then

		-- Search
		return self:CreateSearchState ()

	else

		-- Start in the Idle state by default
		return self:CreateTransitionToIdleState ()

	end

end

function GangsterTeam:OnEvent (tEvent)

	if tEvent:HasID (self.nTeamMemberRemovedID) then

		-- If there are no remaining team members then reset to the idle state
		if self.tHost:RetNumberOfMembers () == 0 then
			self:ChangeState (self:CreateIdleState ())
		end
	
		-- Call parent
		return TeamState.OnEvent (self, tEvent)

	end

	-- Call parent
	return TeamState.OnEvent (self, tEvent)
end

function GangsterTeam:OnActiveStateFinished ()

	if self:InAlertState () then
	
		if self.tHost:RetNumberOfEnemiesWithStatus (eEnemyStatus.nActive) > 0 then

			-- Found enemy - attack
			self:ChangeState (self:CreateAttackState ())

		elseif self.tHost:RetNumberOfEnemiesWithStatus (eEnemyStatus.nLost) > 0 then

			-- Could not see enemy - search for him
			self:ChangeState (self:CreateSearchState ())

		else

			-- Alert has finished but there are no enemies - they must have been deleted
			self:ChangeState (self:CreateTransitionToIdleState ())

		end
		return true

	elseif self:InAttackState () then

		if self.tHost:RetNumberOfEnemiesWithStatus (eEnemyStatus.nLost) > 0 then

			-- Attack has finished but there are still enemies not accounted for - search for them
			self:ChangeState (self:CreateSearchState ())

		elseif self.tHost:RetNumberOfEnemiesWithStatus (eEnemyStatus.nDead) > 0 then

			-- Attack has finished and all enemies are dead - victory
			self:ChangeState (self:CreateVictoryState ())

		else

			-- Attack has finished but there are no enemies - they must have been deleted
			self:ChangeState (self:CreateTransitionToIdleState ())

		end
		return true

	elseif self:InSearchState () then

		if self.tHost:RetNumberOfEnemiesWithStatus (eEnemyStatus.nActive) > 0 then

			-- Search has found an enemy - attack
			self:ChangeState (self:CreateAttackState ())

		elseif self.tHost:RetNumberOfEnemiesWithStatus (eEnemyStatus.nDead) > 0 then

			-- Search has finished and all enemies are dead - victory
			self:ChangeState (self:CreateVictoryState ())

		else

			-- Search has finished but there are still enemies not accounted for - give up
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

	-- Call parent
	return TeamState.OnActiveStateFinished (self)
end

function GangsterTeam:OnActiveStateUnlocked ()

	if self:InAlertState () then
	
		-- An enemy could have appeared while the Alert state was locked
		if self.tHost:RetNumberOfEnemiesWithStatus (eEnemyStatus.nActive) > 0 then

			self:ChangeState (self:CreateAttackState ())

		end
		return true

	end
	
	-- Call parent
	return TeamState.OnActiveStateUnlocked (self)
end

function GangsterTeam:OnEnterTeamMember (tTeamMember)
	-- Call parent
	TeamState.OnEnterTeamMember (self, tTeamMember)

	-- Save the NPC's viewing distance
	self.tTeamMembers[tTeamMember].nIdleViewingDistance = self.nIdleViewingDistance or tTeamMember:RetViewingDistance ()
	self.tTeamMembers[tTeamMember].nAlertViewingDistance = self.nAlertViewingDistance or tTeamMember:RetViewingDistance ()

	-- Subscribe to events
	self:SubscribeNPCTriggerEvents (tTeamMember)
end

function GangsterTeam:OnExitTeamMember (tTeamMember)
	-- Unsubscribe to all our events for that team member
	self:UnsubscribeNPCTriggerEvents (tTeamMember)

	-- Call parent
	TeamState.OnExitTeamMember (self, tTeamMember)
end

function GangsterTeam:OnActiveStateChanged ()

	-- Reset the enemies list when we go into the idle state
	if self:InIdleState () then
		self.tHost:ClearEnemyList ()
	end

	-- Cause events to be generated when the team reverts to idle state
	self.tHost:SetIsIdle (self:InIdleState () or self:RetStackSize () == 0)

	-- Loop through team members
	for tTeamMember in pairs (self.tTeamMembers) do

		-- Set the map status value - indicates what colour the NPC is shown on the map
		tTeamMember:SetMapStatus (self:RetMapStatus ())

		-- Set Global Graph tracking - indicates if the NPC should be considered an ambient
		-- pedestrian and therefore managed by the population manager
		tTeamMember:SetGlobalGraphTracking (self:IsGlobalGraphTracking ())

		-- Set length of view cone
		tTeamMember:SetViewingDistance (self:RetViewingDistance (tTeamMember))

	end

	-- Call parent
	TeamState.OnActiveStateChanged (self)
end

function GangsterTeam:OnExit ()
	-- Call parent
	TeamState.OnExit (self)
	self.tHost:SetIsIdle (true)
end

----------------------------------------------------------------------
-- Team member died
----------------------------------------------------------------------

function GangsterTeam:OnNPCDied (tNPC, tKiller)
	tNPC:ShoutPainAudio (eVocals.nDeath, "Urgh!", tKiller)
	tNPC:ClearState ()
	self.tHost:RemoveEntity (tNPC)
end

----------------------------------------------------------------------
-- Took damage from an enemy - the attacker's location is not necessarily known
----------------------------------------------------------------------

function GangsterTeam:OnNPCAttacked (tNPC, tAttacker)

	-- If it is a new enemy add it to the list
	if not self.tHost:IsInEnemyList (tAttacker) then
		-- Set the enemy status to lost, because we don't necessarily know where they are
		self.tHost:AddEnemy (tAttacker, eEnemyStatus.nLost)
	end

	if self:IsFleeConditionSatisfied (tAttacker) then

		self:ChangeState (self:CreateFleeState ())

	elseif self:IsAlertConditionSatisfied (tAttacker) then
		
		self:ChangeState (self:CreateAlertState (tAttacker))

	end

end

----------------------------------------------------------------------
-- Detected an enemy - i.e. the position of an enemy is now known, either
-- because they attacked us or because we saw them
----------------------------------------------------------------------

function GangsterTeam:OnNPCDetectedEnemy (tNPC, tEnemy)

	-- Add it to the enemy list and set the enemy status to active
	self.tHost:AddEnemy (tEnemy, eEnemyStatus.nActive)

	if self:IsFleeConditionSatisfied (tEnemy) then

		self:ChangeState (self:CreateFleeState ())

	elseif self:IsAttackConditionSatisfied (tEnemy) then

		self:ChangeState (self:CreateAttackState ())

	end

end

----------------------------------------------------------------------
-- Heard a suspicious sound
----------------------------------------------------------------------

function GangsterTeam:OnNPCHeardSuspiciousSound (tNPC, vPosition)

	if self:IsInvestigateConditionSatisfied (vPosition) then

		-- Investigate the sound
		self:ChangeState (self:CreateInvestigateState (vPosition))

	end

end

----------------------------------------------------------------------
-- Heard sounds of fighting
----------------------------------------------------------------------

function GangsterTeam:OnNPCHeardInterestingSound (tNPC, tSource)

	if self:IsWatchConditionSatisfied (tSource) then
	
		-- Watch the exciting things that are happening
		self:ChangeState (self:CreateWatchState (tSource))
	
	end

end

----------------------------------------------------------------------
-- Will turn to watch the source of an interesting sound if we are idle
----------------------------------------------------------------------

function GangsterTeam:IsWatchConditionSatisfied (tEntity)

	if not self:IsActiveStateLocked () then

		if self:InPreWatchState () then

			if not self.tHost:IsEntityMemberOfTeam (tEntity) then
				return true
			end

		end

	end
	return false

end

----------------------------------------------------------------------
-- Will investigate a suspicious sound if we are not in alert, attack,
-- search or flee states
----------------------------------------------------------------------

function GangsterTeam:IsInvestigateConditionSatisfied (vPosition)

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

function GangsterTeam:IsAlertConditionSatisfied (tEnemy)

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

function GangsterTeam:IsAttackConditionSatisfied (tEnemy)

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

function GangsterTeam:IsFleeConditionSatisfied (tEnemy)
	return false
end

----------------------------------------------------------------------
-- Create State functions - over-ride these to use custom states
----------------------------------------------------------------------

function GangsterTeam:CreateIdleState ()
	return Create (TeamIdle, {})
end

function GangsterTeam:CreateWatchState (tSource)
	return Create (TeamWatch, 
	{
		tEntity = tSource,
	})
end

function GangsterTeam:CreateInvestigateState (vPosition)
	return Create (TeamInvestigate, 
	{
		vPosition = vPosition,
	})
end

function GangsterTeam:CreateAlertState (tAttacker)
	return Create (TeamAlert, 
	{
		tAttacker = tAttacker,
	})
end

function GangsterTeam:CreateAttackState ()
	return Create (TeamCombat, {})
end

function GangsterTeam:CreateSearchState ()
	return Create (TeamSearch, {})
end

function GangsterTeam:CreateFleeState ()
	return Create (TeamFlee, {})
end

function GangsterTeam:CreateVictoryState ()
	return Create (TeamVictory, {})
end

function GangsterTeam:CreateGiveUpState ()
	return Create (TeamGiveUp, {})
end

function GangsterTeam:CreateTransitionToIdleState ()
	return Create (TeamArm, {})
end

----------------------------------------------------------------------
-- Return true if we are in a particular state - over-ride these if using custom states
----------------------------------------------------------------------

function GangsterTeam:InIdleState ()
	return self:IsInState (TeamIdle)
end

function GangsterTeam:InWatchState ()
	return self:IsInState (TeamWatch)
end

function GangsterTeam:InInvestigateState ()
	return self:IsInState (TeamInvestigate)
end

function GangsterTeam:InAlertState ()
	return self:IsInState (TeamAlert)
end

function GangsterTeam:InAttackState ()
	return self:IsInState (TeamCombat)
end

function GangsterTeam:InSearchState ()
	return self:IsInState (TeamSearch)
end

function GangsterTeam:InFleeState ()
	return self:IsInState (TeamFlee)
end

function GangsterTeam:InVictoryState ()
	return self:IsInState (TeamVictory)
end

function GangsterTeam:InGiveUpState ()
	return self:IsInState (TeamGiveUp)
end

function GangsterTeam:InTransitionToIdleState ()
	return self:IsInState (TeamArm)
end

----------------------------------------------------------------------
-- Return true if we can break out of the current state to enter a new one
----------------------------------------------------------------------

function GangsterTeam:InPreWatchState ()
	return self:InIdleState ()
end

function GangsterTeam:InPreInvestigateState ()
	return self:InIdleState () or 
		self:InTransitionToIdleState () or
		self:InWatchState () or
		self:InGiveUpState () or 
		self:InVictoryState ()
end

function GangsterTeam:InPreAlertState ()
	return self:InIdleState () or
		self:InTransitionToIdleState () or
		self:InWatchState () or
		self:InGiveUpState () or 
		self:InVictoryState () or
		self:InInvestigateState () or
		self:InSearchState ()
end

function GangsterTeam:InPreAttackState ()
	return self:InIdleState () or
		self:InTransitionToIdleState () or
		self:InWatchState () or
		self:InGiveUpState () or 
		self:InVictoryState () or
		self:InInvestigateState () or
		self:InAlertState () or
		self:InSearchState ()
end

function GangsterTeam:InPreFleeState ()
	return self:InIdleState () or
		self:InTransitionToIdleState () or
		self:InWatchState () or
		self:InGiveUpState () or 
		self:InVictoryState () or
		self:InInvestigateState () or
		self:InAlertState () or
		self:InAttackState () or
		self:InSearchState ()
end

----------------------------------------------------------------------
-- Global Graph tracking - indicates if the NPC should be considered an ambient
-- pedestrian and therefore managed by the population manager
----------------------------------------------------------------------

function GangsterTeam:IsGlobalGraphTracking ()
	return false
end

----------------------------------------------------------------------
-- Map Status - Indicates what colour the NPCs will be displayed on the map
----------------------------------------------------------------------

function GangsterTeam:RetMapStatus ()

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

function GangsterTeam:RetViewingDistance (tTeamMember)

	if self:InIdleState () or
		self:InTransitionToIdleState () or
		self:InWatchState () then

		return self.tTeamMembers[tTeamMember].nIdleViewingDistance
	else
		return self.tTeamMembers[tTeamMember].nAlertViewingDistance
	end

end
