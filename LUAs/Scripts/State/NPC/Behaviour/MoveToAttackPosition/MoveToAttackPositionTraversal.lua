----------------------------------------------------------------------
-- Name: MoveToAttackPositionTraversal State
-- Description: Graph traversal for the MoveToAttackPosition state
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\Action\\Equipment\\FaceAndPrimaryFire"

MoveToAttackPositionTraversal = Create (FaceAndPrimaryFire, 
{
	sStateName = "MoveToAttackPositionTraversal",
	bSuccess = false,
	bAvoidTarget = false,			-- Set this to make the traversal avoid the target
	nAvoidTargetRadius = nil,		-- This is the radius of the are to avoid around the target
})

function MoveToAttackPositionTraversal:OnEnter ()
	-- Check parameters
	assert (self.nNumInvalidPositions)
	assert (self.avInvalidPositions)

	-- Call parent
	FaceAndPrimaryFire.OnEnter (self)

	-- Subscribe events
	self.nTraversalFinishedID = self:Subscribe (eEventType.AIE_TRAVERSAL_FINISHED, self.tHost)
end

function MoveToAttackPositionTraversal:OnResume ()
	-- Call parent
	FaceAndPrimaryFire.OnResume (self)

	-- Start the Traversal service
	local tTraversalParams = cTraversalService.Traverse (self.tHost)

	tTraversalParams:SetNumTargetPositions (1)
	tTraversalParams:SetTargetPosition (0, self.tTargetInfo:RetLastTargetFocusPointPosition ())
	tTraversalParams:SetTargetEntity (0, self.tTargetInfo:RetTarget ())

	-- Specify invalid positions - increment number by one if we are avoiding the target
	local nTotalInvalidPositions = self.nNumInvalidPositions + (self.bAvoidTarget and 1 or 0)
	tTraversalParams:SetNumInvalidPositions (nTotalInvalidPositions)

	for i=1, self.nNumInvalidPositions do
		tTraversalParams:SetInvalidPosition (i-1, self.avInvalidPositions[i])
		tTraversalParams:SetInvalidPositionRadius (i-1, 2)
	end

	if self.bAvoidTarget then
		tTraversalParams:SetInvalidPosition (nTotalInvalidPositions-1, self.tTargetInfo:RetLastTargetCentrePosition ())
		tTraversalParams:SetInvalidPositionRadius (nTotalInvalidPositions-1, self.nAvoidTargetRadius)
	end

	-- Are we defending something?
	if self.vDefendedPosition or self.tDefendedObject then

		-- Center the search radius around the defended position or object
		assert (self.nRadius)
		local vCenterPosition = self.vDefendedPosition or self.tDefendedObject:RetPosition ()
		tTraversalParams:SetCenterPosition (vCenterPosition)
		tTraversalParams:SetRadius (self.nRadius)

	else

		-- Search is centered around me and radius is slightly further than the 
		-- last known distance to the target character
		local nRadius = AILib.CharacterPosDist (self.tHost, self.tTargetInfo:RetLastTargetFocusPointPosition ()) + 20

		-- If we are trying to avoid the target then search in a wider area
		if self.bAvoidTarget then
			nRadius = nRadius + self.nAvoidTargetRadius
		end

		tTraversalParams:SetRadius (nRadius)

	end

	-- Avoid positions that are already occupied by someone
	tTraversalParams:SetOccupiedPositionsRadius (2)

	self.nTraversalID = tTraversalParams:RetID ()
end

function MoveToAttackPositionTraversal:OnPause ()
	-- Call parent
	FaceAndPrimaryFire.OnPause (self)

	-- If a traversal is in progress cancel it
	if self.nTraversalID then
		cTraversalService.Cancel (self.nTraversalID)
	end
end

function MoveToAttackPositionTraversal:OnEvent (tEvent)

	if tEvent:HasID (self.nTraversalFinishedID) then

		-- Indicate that the search is finished
		self.nTraversalID = nil

		-- Found an attack position
		if tEvent:Success () then
			self.vAttackPosition = tEvent:RetResultPosition (0)
		end

		self.bSuccess = tEvent:Success ()
		self:Finish ()
		return true

	end

	-- Call parent
	return FaceAndPrimaryFire.OnEvent (self, tEvent)
end

function MoveToAttackPositionTraversal:Success ()
	return self.bSuccess
end
