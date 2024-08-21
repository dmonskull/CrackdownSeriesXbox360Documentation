----------------------------------------------------------------------
-- Name: TeamCombat State
-- Description: Base state for all team combat states
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\Team\\TeamState"
require "State\\NPC\\Behaviour\\Combat\\Combat"
require "State\\NPC\\Behaviour\\Listen\\Listen"

TeamCombat = Create (TeamState,
{
	sStateName = "TeamCombat",
})

function TeamCombat:OnEnter ()
	-- Call parent
	TeamState.OnEnter (self)

	-- Subscribe events
	self.nTeamEnemyDiedID = self:Subscribe (eEventType.AIE_TEAM_ENEMY_DIED, self.tHost)
	self.nTeamEnemyDisappearedID = self:Subscribe (eEventType.AIE_TEAM_ENEMY_DISAPPEARED, self.tHost)
	self.nTeamEnemyStatusChangedID = self:Subscribe (eEventType.AIE_TEAM_ENEMY_STATUS_CHANGED, self.tHost)
	self.nTeamEnemyAddedID = self:Subscribe (eEventType.AIE_TEAM_ENEMY_ADDED, self.tHost)
	self.nTeamEnemyRemovedID = self:Subscribe (eEventType.AIE_TEAM_ENEMY_REMOVED, self.tHost)

	self.tHost:UnassignAllEnemies ()
	self:AssignTargets ()
end

function TeamCombat:OnExit ()
	-- Call parent
	TeamState.OnExit (self)
	self.tHost:UnassignAllEnemies ()
end

function TeamCombat:OnEvent (tEvent)

	if tEvent:HasID (self.nTeamEnemyDiedID) then

		-- Set the enemy's status to dead
		local tEnemyInfo = self.tHost:FindEnemyInfo (tEvent:RetEnemy ())
		tEnemyInfo:SetStatus (eEnemyStatus.nDead)
		return true

	elseif tEvent:HasID (self.nTeamEnemyDisappearedID) then

		-- Set the enemy's status to lost if no one is assigned to it
		if self.tHost:RetNumberOfMembersAssignedToEnemy (tEvent:RetEnemy ()) == 0 then
			local tEnemyInfo = self.tHost:FindEnemyInfo (tEvent:RetEnemy ())
			tEnemyInfo:SetStatus (eEnemyStatus.nLost)
		end
		return true

	elseif tEvent:HasID (self.nTeamEnemyStatusChangedID) then

		self:AssignTargets ()
		return true

	elseif tEvent:HasID (self.nTeamEnemyAddedID) then

		self:AssignTargets ()
		return true

	elseif tEvent:HasID (self.nTeamEnemyRemovedID) then

		self:AssignTargets ()
		return true

	elseif tEvent:HasID (self.nTeamMemberAddedID) then

		self:AssignTargets ()
		return TeamState.OnEvent (self, tEvent)

	elseif tEvent:HasID (self.nTeamMemberRemovedID) then

		self:AssignTargets ()
		return TeamState.OnEvent (self, tEvent)

	end

	for tTeamMember, tTeamMemberEvents in pairs (self.tTeamMembers) do
		
		if tEvent:HasID (tTeamMemberEvents.nCustomEventID) and tEvent:HasCustomEventID ("StateFinished") then

			self:OnMemberStateFinished (tTeamMember, tEvent.tState)
			self:AssignTargets ()
			return true

		elseif tEvent:HasID (tTeamMemberEvents.nDamagedID) then

			-- If someone is damaged while they are not assigned to an enemy
			-- assign them to that enemy
			local tEnemy = tEvent:RetInstigator ()
			if tEnemy then

				local tEnemyInfo = self.tHost:FindEnemyInfo (tEnemy)
				local tTeamMemberInfo = self.tHost:FindMemberInfo (tTeamMember)
	
				if not tTeamMemberInfo:RetAssignedEnemy () then
					
					-- Make sure it's a valid enemy
					if tEnemyInfo and tEnemyInfo:RetStatus () == eEnemyStatus.nActive then
	
						tTeamMemberInfo:SetAssignedEnemy (tEnemy)
						tTeamMember:SetState (self:CreateCombatState (tTeamMember, tEnemy))
	
					end
	
				end

			end
			return true

		end
		
	end

	-- Call parent
	return TeamState.OnEvent (self, tEvent)
end

function TeamCombat:OnMemberStateFinished (tTeamMember, tState)

	if tState:IsA (Combat) then

		local tMemberInfo = self.tHost:FindMemberInfo (tTeamMember)
		local tEnemyInfo = self.tHost:FindEnemyInfo (tState.tTarget)

		-- Clear the team member's assigned enemy
		tMemberInfo:SetAssignedEnemy (nil)

		if tEnemyInfo then

			if tState:TargetLost () then
	
				-- If the target is not assigned to anyone else on the team set its status to lost
				if self.tHost:RetNumberOfMembersAssignedToEnemy (tState.tTarget) == 0 then
					tEnemyInfo:SetStatus (eEnemyStatus.nLost)
				end
	
			elseif tState:TargetDied () then
	
				tEnemyInfo:SetStatus (eEnemyStatus.nDead)
			
			elseif tState:TargetDeleted () then
	
				tEnemyInfo:SetStatus (eEnemyStatus.nLost)
	
			end

		end

	end

end

function TeamCombat:AssignTargets ()

	-- Get the number of enemies
	if self.tHost:RetNumberOfEnemiesWithStatus (eEnemyStatus.nActive) > 0 then
	
		-- Loop through team members
		for i=1, self.tHost:RetNumberOfMembers () do

			local tTeamMember = self.tHost:RetMember (i-1)
			local tTeamMemberInfo = self.tHost:RetMemberInfo (i-1)

			-- If the team member has not been assigned an enemy
			if not tTeamMemberInfo:RetAssignedEnemy () then

				-- Find the best enemy
				local tEnemy = self.tHost:RetBestEnemy (
					eEnemyStatus.nActive, 
					self:RetMaxMembersAssignedToEnemy () - 1, 
					self:RetMaxDistanceToEnemy (), 
					tTeamMember:RetPosition ())

				if tEnemy then
	
					tTeamMemberInfo:SetAssignedEnemy (tEnemy)
					tTeamMember:SetState (self:CreateCombatState (tTeamMember, tEnemy))

				-- If there is not good enemy then just go into an 'idle' state
				elseif not tTeamMember:RetState () then

					tTeamMember:SetState (self:CreateIdleState (tTeamMember))					

				end

			end

		end

	else
		-- There are no active enemies left, so finish the state
		self:Finish ()
	end

end

function TeamCombat:RetMaxMembersAssignedToEnemy ()
	-- Return the maximum number of team members that can be assigned to one enemy
	return self.tHost:RetNumberOfMembers ()
end

function TeamCombat:RetMaxDistanceToEnemy ()
	-- Return the maximum distance a team member is allowed to be from an enemy's
	-- last known position in order to be assigned to that enemy
	return nMAX_REAL
end

function TeamCombat:OnEnterTeamMember (tTeamMember)
	-- Call parent
	TeamState.OnEnterTeamMember (self, tTeamMember)

	-- Subscribe to events for the team member
	self.tTeamMembers[tTeamMember].nCustomEventID = self:Subscribe (eEventType.AIE_CUSTOM, tTeamMember)
	self.tTeamMembers[tTeamMember].nDamagedID = self:Subscribe (eEventType.AIE_DAMAGE_TAKEN, tTeamMember)
end

function TeamCombat:OnExitTeamMember (tTeamMember)
	-- Unsubscribe events for the team member
	self:Unsubscribe (self.tTeamMembers[tTeamMember].nCustomEventID)
	self:Unsubscribe (self.tTeamMembers[tTeamMember].nDamagedID)

	-- Call parent
	TeamState.OnExitTeamMember (self, tTeamMember)
end

function TeamCombat:IsLocked ()
	-- Team state is locked if any of the individual states are locked
	for tTeamMember in pairs (self.tTeamMembers) do
		if tTeamMember.tCurrentState and 
			tTeamMember.tCurrentState:IsLocked () then
			return true
		end
	end
	return false
end

function TeamCombat:CreateCombatState (tTeamMember, tEnemy)
	-- This is the state team members use to fight an enemy
	return Create (Combat,
	{
		tTarget = tEnemy,
		tDefendedObject = self.tDefendedObject,
		vDefendedPosition = self.vDefendedPosition,
		nRadius = self.nRadius,
	})
end

function TeamCombat:CreateIdleState (tTeamMember)
	-- This is the state team members use when there are no enemies
	-- available to fight that match the necessary criteria
	return Create (Listen, {})
end
