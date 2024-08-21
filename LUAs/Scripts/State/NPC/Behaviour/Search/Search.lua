----------------------------------------------------------------------
-- Name: Search State
-- Description: 
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "System\\State"
require "State\\NPC\\Behaviour\\Listen\\WaitAndListen"
require "State\\NPC\\Behaviour\\Search\\SearchPosition"

Search = Create (State, 
{
	sStateName = "Search",
	nRadius = 60,
	nAngle = 90,
	bTargetFound = false,
	bTargetLost = false,
	bTargetDied = false,
})

function Search:OnEnter ()
	-- Call parent
	State.OnEnter (self)

	-- Check parameters
	assert (self.vStartingPosition)
	assert (self.vViewPointPosition)
	assert (self.vDirection)

	-- Cowardly NPCs do less searching
	if self.tHost:RetPersonality () >= ePersonality.nBrave then
		self.nNumCoverPositions = 3
	elseif self.tHost:RetPersonality () > ePersonality.nCowardly then
		self.nNumCoverPositions = 2
	else
		self.nNumCoverPositions = 1
	end

	self.tHost:SpeakAudio (eVocals.nLostThem, "Where did he go?")

	-- Start the Traversal service
	local tTraversalParams = cTraversalService.Traverse (self.tHost)

	tTraversalParams:SetNumResultPositions (self.nNumCoverPositions)
	tTraversalParams:SetResultPositionsRadius (5)

	-- Find somewhere hidden from my current eye position and the position 
	-- of my eye at the time when I last saw the enemy 
	tTraversalParams:SetNumThreatPositions (2)
	tTraversalParams:SetThreatPosition (0, self.tHost:RetEyePosition ())
	tTraversalParams:SetThreatPosition (1, self.vViewPointPosition)

	-- If a defended object or position is specified, center the
	-- search radius on that object or position
	if self.vDefendedPosition or self.tDefendedObject then

		local vCenterPosition = self.vDefendedPosition or self.tDefendedObject:RetPosition ()
		tTraversalParams:SetCenterPosition (vCenterPosition)

	end

	tTraversalParams:SetRadius (self.nRadius)
	tTraversalParams:SetAngle (self.nAngle)
	tTraversalParams:SetDirection (self.vDirection)
	tTraversalParams:SetStartingPosition (self.vStartingPosition)

	self.nTraversalID = tTraversalParams:RetID ()
	self.nTraversalFinishedID = self:Subscribe (eEventType.AIE_TRAVERSAL_FINISHED, self.tHost)
	self.nEntityAppearedID = self:Subscribe (eEventType.AIE_ENTITY_APPEARED, self.tHost)

	if self.tTarget then
		self.nTargetDeletedID = self:Subscribe (eEventType.AIE_OBJECT_DELETED, self.tTarget)
	end

end

function Search:OnExit ()
	-- Call parent
	State.OnExit (self)

	-- Cancel the traversal service if it was in progress
	if self.nTraversalID then
		cTraversalService.Cancel (self.nTraversalID)
	end
end

function Search:OnEvent (tEvent)

	if self.nTraversalID and tEvent:HasID (self.nTraversalFinishedID) and tEvent:HasTraversalID (self.nTraversalID) then

		if tEvent:Success () then
		
			-- Set the number of cover positions returned (in case it was less than the number we specified)		
			self.nNumCoverPositions = tEvent:RetNumResultPositions ()

			-- Copy the cover positions to an array
			self.avCoverPositions = {}

			for i=1, self.nNumCoverPositions do
				self.avCoverPositions[i] = tEvent:RetResultPosition (i-1)
			end

			self:PushState (Create (SearchPosition,
			{
				vPosition = self.avCoverPositions[self.nNumCoverPositions],
				vDefendedPosition = self.vDefendedPosition,
				tDefendedObject = self.tDefendedObject,
				nRadius = self.nRadius,
			}))
			
		else
			
			-- We can't search, so just stand and stare in that direction for a while
			self:PushState (Create (WaitAndListen,
			{
				vPosition = self.tHost:RetPosFromDirection (10, self.vDirection),
				nWaitTime = 5,
			}))

		end
		self.nTraversalID = nil
		return true
	
	elseif tEvent:HasID (self.nEntityAppearedID) then
	
		if tEvent:RetEntity () == self.tTarget then

			if self.tTarget:IsAlive () then
				self.bTargetFound = true			
			else
				self.bTargetDied = true
			end
			self:Finish ()
		
		end
		return true
	
	elseif tEvent:HasID (self.nTargetDeletedID) then

		self.tTarget = nil
		return true

	end

	-- Call parent
	return State.OnEvent (self, tEvent)
end

function Search:OnActiveStateFinished ()

	if self:IsInState (SearchPosition) then
	
		self.nNumCoverPositions = self.nNumCoverPositions - 1
		if self.nNumCoverPositions > 0 then

			self:ChangeState (Create (SearchPosition,
			{
				vPosition = self.avCoverPositions[self.nNumCoverPositions]
			}))
			
		else
			self.bTargetLost = true
			self:Finish ()
		end
		return true
	
	elseif self:IsInState (WaitAndListen) then

		self.bTargetLost = true
		self:Finish ()
		return true

	end

	-- Call parent
	return State.OnActiveStateFinished (self)
end

function Search:TargetFound ()
	return self.bTargetFound
end

function Search:TargetLost ()
	return self.bTargetLost
end

function Search:TargetDied ()
	return self.bTargetDied
end
