----------------------------------------------------------------------
-- Name: AlertTraversal State
--	Description: Graph traversal for the Alert state
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\Action\\Idle\\Idle"

AlertTraversal = Create (Idle, 
{
	sStateName = "AlertTraversal",
	nRadius = 40,
	bSuccess = false,
})

function AlertTraversal:OnEnter ()
	-- Check parameters
	assert (self.nNumAttackers)
	assert (self.tAttackerPositions)

	-- Call parent
	Idle.OnEnter (self)

	-- Subscribe events
	self.nTraversalFinishedID = self:Subscribe (eEventType.AIE_TRAVERSAL_FINISHED, self.tHost)
end

function AlertTraversal:OnResume ()
	-- Call parent
	Idle.OnResume (self)

	-- Start the Traversal service
	local tTraversalParams = cTraversalService.Traverse (self.tHost)

	tTraversalParams:SetNumThreatPositions (self.nNumAttackers)

	local i = 0
	for tAttacker, vPosition in pairs (self.tAttackerPositions) do
		tTraversalParams:SetThreatPosition (i, vPosition)
		i = i + 1
	end

	-- If a defended object or position is specified, center the
	-- search radius on that object or position
	if self.vDefendedPosition or self.tDefendedObject then

		local vCenterPosition = self.vDefendedPosition or self.tDefendedObject:RetPosition ()
		tTraversalParams:SetCenterPosition (vCenterPosition)

	end

	-- Set current position as invalid, to force the NPC to move
	tTraversalParams:SetNumInvalidPositions (1)
	tTraversalParams:SetInvalidPosition (0, self.tHost:RetPosition ())
	tTraversalParams:SetInvalidPositionRadius (0, 2)

	tTraversalParams:SetRadius (self.nRadius)
	tTraversalParams:SetOccupiedPositionsRadius (2)

	self.nTraversalID = tTraversalParams:RetID ()
end

function AlertTraversal:OnPause ()
	-- Call parent
	Idle.OnPause (self)

	-- If a traversal is in progress cancel it
	if self.nTraversalID then
		cTraversalService.Cancel (self.nTraversalID)
	end
end

function AlertTraversal:OnEvent (tEvent)

	if tEvent:HasID (self.nTraversalFinishedID) then

		-- Indicate that the search is finished
		self.nTraversalID = nil

		-- Found a cover position
		if tEvent:Success () then
			self.vCoverPosition = tEvent:RetResultPosition (0)
		end

		self.bSuccess = tEvent:Success ()
		self:Finish ()
		return true

	end

	-- Call parent
	return Idle.OnEvent (self, tEvent)
end

function AlertTraversal:Success ()
	return self.bSuccess
end
