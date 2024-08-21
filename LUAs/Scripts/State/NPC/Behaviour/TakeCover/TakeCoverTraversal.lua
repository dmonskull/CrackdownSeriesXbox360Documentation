----------------------------------------------------------------------
-- Name: TakeCoverTraversal State
--	Description:Graph traversal for the TakeCover state
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\Action\\Equipment\\FaceAndPrimaryFire"

TakeCoverTraversal = Create (FaceAndPrimaryFire, 
{
	sStateName = "TakeCoverTraversal",
	bSuccess = false,
	bIsCrouching = false,
})

function TakeCoverTraversal:OnEnter ()
	-- Check parameters
	assert (self.nRadius)
	assert (self.bCrouchAllowed ~= nil)

	-- Call parent
	FaceAndPrimaryFire.OnEnter (self)

	-- Subscribe events
	self.nTraversalFinishedID = self:Subscribe (eEventType.AIE_TRAVERSAL_FINISHED, self.tHost)
end

function TakeCoverTraversal:OnResume ()
	-- Call parent
	FaceAndPrimaryFire.OnResume (self)

	-- Start the Traversal service
	local tTraversalParams = cTraversalService.Traverse (self.tHost)

	tTraversalParams:SetNumThreatPositions (1)
	tTraversalParams:SetThreatPosition (0, self.tTargetInfo:RetLastTargetEyePosition ())

	-- If a defended object or position is specified, center the
	-- search radius on that object or position
	if self.vDefendedPosition or self.tDefendedObject then

		local vCenterPosition = self.vDefendedPosition or self.tDefendedObject:RetPosition ()
		tTraversalParams:SetCenterPosition (vCenterPosition)

	end

	-- Set current position as invalid, to force the NPC to move
--	tTraversalParams:SetNumInvalidPositions (1)
--	tTraversalParams:SetInvalidPosition (0, self.tHost:RetPosition ())
--	tTraversalParams:SetInvalidPositionRadius (0, 2)

	tTraversalParams:SetRadius (self.nRadius)
	tTraversalParams:SetOccupiedPositionsRadius (2)

	tTraversalParams:SetCrouchAllowed (self.bCrouchAllowed)

	self.nTraversalID = tTraversalParams:RetID ()
end

function TakeCoverTraversal:OnPause ()
	-- Call parent
	FaceAndPrimaryFire.OnPause (self)

	-- If a traversal is in progress cancel it
	if self.nTraversalID then
		cTraversalService.Cancel (self.nTraversalID)
	end
end

function TakeCoverTraversal:OnEvent (tEvent)

	if tEvent:HasID (self.nTraversalFinishedID) then

		-- Indicate that the search is finished
		self.nTraversalID = nil

		-- Found a cover position
		if tEvent:Success () then
			self.vCoverPosition = tEvent:RetResultPosition (0)
			self.bIsCrouching = tEvent:IsResultPositionCrouching (0)
		end

		self.bSuccess = tEvent:Success ()
		self:Finish ()
		return true

	end

	-- Call parent
	return FaceAndPrimaryFire.OnEvent (self, tEvent)
end

function TakeCoverTraversal:Success ()
	return self.bSuccess
end
