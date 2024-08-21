----------------------------------------------------------------------
-- Name: TeamSearch State
--	Description: Search for the enemies in the enemy list
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\Team\\TeamState"
require "State\\NPC\\Behaviour\\Search\\SearchPosition"
require "State\\NPC\\Behaviour\\Listen\\Listen"

TeamSearch = Create (TeamState,
{
	sStateName = "TeamSearch",
	nRadius = 60,
	nAngle = 90,
})

function TeamSearch:OnEnter ()
	-- Call parent
	TeamState.OnEnter (self)

	-- Start the graph Traversal
	self:FindCover ()
	
	-- Subscribe events
	self.nTeamEnemyAppeared = self:Subscribe (eEventType.AIE_TEAM_ENEMY_APPEARED, self.tHost)
end

function TeamSearch:OnExit ()
	-- Call parent
	TeamState.OnExit (self)

	-- Cancel the traversal service if it was in progress
	if self.nTraversalID then
		cTraversalService.Cancel (self.nTraversalID)
	end
end

function TeamSearch:OnEvent (tEvent)

	if self.nTraversalID and tEvent:HasID (self.nTraversalFinishedID) and tEvent:HasTraversalID (self.nTraversalID) then
		
		if tEvent:Success () then
		
			-- Assign each team member to go to a cover position
			for i=1, self.tHost:RetNumberOfMembers () do

				local tTeamMember = self.tHost:RetMember (i-1)
				
				-- There's a slim chance a team member could have died while the Traversal service was processing
				if i <= tEvent:RetNumResultPositions () then
					
					tTeamMember:SetState (Create (SearchPosition,
					{
						vPosition = tEvent:RetResultPosition (i-1),
						vDefendedPosition = self.vDefendedPosition,
						tDefendedObject = self.tDefendedObject,
						nRadius = self.nRadius,
					}))
				
				else

					tTeamMember:SetState (Create (Listen,
					{
						vPosition = self.vPosition,
					}))
		
				end

			end

		else
			self:Finish ()
		end
		self.nTraversalID = nil
		return true
	
	elseif tEvent:HasID (self.nTeamEnemyAppeared) then

		self:OnEnemyAppeared (tEvent:RetEnemy ())
		return true

	end

	for tTeamMember, tTeamMemberEvents in pairs (self.tTeamMembers) do

		if tEvent:HasID (tTeamMemberEvents.nCustomEventID) and tEvent:HasCustomEventID ("StateFinished") then

			if tEvent.tState:IsA (SearchPosition) then
				self:OnFinishedSearch (tTeamMember)
			end
			return true

		end

	end

	-- Call parent
	return TeamState.OnEvent (self, tEvent)
end

function TeamSearch:FindCover ()

	-- Get the leader
	local tLeader = self.tHost:RetLeader ()

	tLeader:SpeakAudio (eVocals.nLostThem, "Where did he go?")

	-- Get the enemy whose last known position is closest to the leader
	local tEnemy = self.tHost:RetClosestEnemyWithStatus (eEnemyStatus.nLost, tLeader:RetPosition ())

	-- tEnemy will be nil if there are no enemies with the Lost status
	assert (tEnemy)

	local tEnemyInfo = self.tHost:FindEnemyInfo (tEnemy)

	self.vPosition = tEnemyInfo:RetLastKnownPosition ()
	self.vDirection = tEnemyInfo:RetLastKnownVelocity ()

	-- Start the Traversal service
	local tTraversalParams = cTraversalService.Traverse (tLeader)

	-- Set the starting position of the search to be the last known position of the enemy
	tTraversalParams:SetStartingPosition (self.vPosition)

	-- Make sure the search positions are a decent distance apart from each other
	tTraversalParams:SetResultPositionsRadius (5)
	tTraversalParams:SetNumResultPositions (self.tHost:RetNumberOfMembers ())

	-- Add the positions of each of the team members as threat positions
	tTraversalParams:SetNumThreatPositions (self.tHost:RetNumberOfMembers ())
	for i=1, self.tHost:RetNumberOfMembers () do
	
		local tTeamMember = self.tHost:RetMember (i-1)
		tTraversalParams:SetThreatPosition (i-1, tTeamMember:RetEyePosition ())

	end

	-- If a defended object or position is specified, center the
	-- search radius on that object or position
	if self.vDefendedPosition or self.tDefendedObject then

		local vCenterPosition = self.vDefendedPosition or self.tDefendedObject:RetPosition ()
		tTraversalParams:SetCenterPosition (vCenterPosition)

	end

	tTraversalParams:SetRadius (self.nRadius)
	tTraversalParams:SetDirection (self.vDirection)
	tTraversalParams:SetAngle (self.nAngle)

	self.nTraversalID = tTraversalParams:RetID ()
	self.nTraversalFinishedID = self:Subscribe (eEventType.AIE_TRAVERSAL_FINISHED, tLeader)

end

function TeamSearch:OnFinishedSearch (tTeamMember)
	-- Face in front of me and listen for anything suspicious
	tTeamMember:SetState (Create (Listen, {}))

	-- Check to see if any of the team members are still searching
	for i=1, self.tHost:RetNumberOfMembers () do

		local tTeamMember = self.tHost:RetMember (i-1)

		if tTeamMember:IsInState (SearchPosition) then
			return
		end
		
	end

	-- None of the team members are searching any more - quit out
	self:Finish ()

end

function TeamSearch:OnEnemyAppeared (tEnemy)

	local tEnemyInfo = self.tHost:FindEnemyInfo (tEnemy)
	if tEnemy:IsAlive () then

		-- We found an alive enemy - stop searching
		tEnemyInfo:SetStatus (eEnemyStatus.nActive)
		self:Finish ()

	else

		-- We found a dead enemy - update his status
		tEnemyInfo:SetStatus (eEnemyStatus.nDead)

		-- If no enemies remain to be found then stop searching
		if  self.tHost:RetNumberOfEnemiesWithStatus (eEnemyStatus.nLost) == 0 then
			self:Finish ()
		end

	end

end

function TeamSearch:OnEnterTeamMember (tTeamMember)
	-- Call parent
	TeamState.OnEnterTeamMember (self, tTeamMember)

	-- Subscribe to custom events
	self.tTeamMembers[tTeamMember].nCustomEventID = self:Subscribe (eEventType.AIE_CUSTOM, tTeamMember)

	-- Set all team members to idle initially
	-- If any are added in mid-state they will just become idle immediately
	tTeamMember:SetState (Idle)
end

function TeamSearch:OnExitTeamMember (tTeamMember)
	-- Unsubscribe from custom events
	self:Unsubscribe (self.tTeamMembers[tTeamMember].nCustomEventID)

	-- Call parent
	TeamState.OnExitTeamMember (self, tTeamMember)
end
