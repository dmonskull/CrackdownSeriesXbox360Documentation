----------------------------------------------------------------------
-- Name: MoveToAttackPosition State
-- Description: Get into a position from which we can shoot the target
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"
require "State\\NPC\\Action\\Turn\\MoveToAndFace"
require "State\\NPC\\Action\\Equipment\\WaitAndPrimaryFire"
require "State\\NPC\\Action\\Movement\\MoveAndPrimaryFire"
require "State\\NPC\\Behaviour\\MoveToAttackPosition\\MoveToAttackPositionTraversal"

MoveToAttackPosition = Create (TargetState, 
{
	sStateName = "MoveToAttackPosition",
	nTargetInfoFlags = eTargetInfoFlags.nVisibilityChecks + eTargetInfoFlags.nPrimaryFireChecks,
	nMovementType = eMovementType.nRun,
	nMovementPriority = eMovementPriority.nLow,
	bSuccess = false,
	bTargetLost = false,
	bTargetUnreachable = false,
	bAvoidTarget = false,			-- Set this to make the traversal avoid the target
	nAvoidTargetRadius = nil,		-- This is the radius of the are to avoid around the target
})

MoveToTraversalPosition = Create (MoveAndPrimaryFire,
{
	sStateName = "MoveToAttackPosition",
})

MoveToLastKnownTargetPosition = Create (MoveAndPrimaryFire,
{
	sStateName = "MoveToLastTargetPosition",
})

function MoveToAttackPosition:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)

	-- Subscribe to proximity events to check if defended object moves into radius
	if self.tDefendedObject then
		assert (self.nRadius)
		self.nProximityCheckID = self:AddProximityCheck (self.tHost, self.tDefendedObject, self.nRadius)
		self.nTargetInProximityID = self:Subscribe (eEventType.AIE_TARGET_IN_PROXIMITY, self.tHost)
	end

	if self:InAttackPosition () then

		-- Target is already visible so just finish
		self.bSuccess = true
		self:Finish ()

	else
	
		-- Initialise array of invalid positions
		self.avInvalidPositions = {}
		self.nNumInvalidPositions = 0

		-- Subscribe to events
		self.nTargetAppearedID = self:Subscribe (eEventType.AIE_TARGET_APPEARED, self.tTargetInfo)
		self.nTargetUnblockedID = self:Subscribe (eEventType.AIE_PRIMARY_FIRE_UNBLOCKED, self.tTargetInfo)
		self.nTargetNotTooCloseID = self:Subscribe (eEventType.AIE_PRIMARY_FIRE_NOT_TOO_CLOSE, self.tTargetInfo)
		self.nTargetInRangeID = self:Subscribe (eEventType.AIE_PRIMARY_FIRE_IN_RANGE, self.tTargetInfo)

		-- HACK! - Wait for a short period of time to make sure we are not crouching
		self:PushState (self:CreateInitialWaitState ())

	end

end

function MoveToAttackPosition:OnResume ()
	-- Call parent
	TargetState.OnResume (self)
	self:EvaluateConditions ()	
end

function MoveToAttackPosition:OnEvent (tEvent)
	
	if tEvent:HasID (self.nTargetAppearedID) then

		self:EvaluateConditions ()
		return true

	elseif tEvent:HasID (self.nTargetUnblockedID) then

		self:EvaluateConditions ()
		return true

	elseif tEvent:HasID (self.nTargetNotTooCloseID) then

		self:EvaluateConditions ()
		return true

	elseif tEvent:HasID (self.nTargetInRangeID) then

		self:EvaluateConditions ()
		return true

	elseif self.tDefendedObject and
			tEvent:HasID (self.nTargetInProximityID) and 
			tEvent:HasProximityCheckID (self.nProximityCheckID) then

		self:EvaluateConditions ()
		return true

	end

	-- Call parent
	return TargetState.OnEvent (self, tEvent)
end

function MoveToAttackPosition:OnActiveStateFinished ()

	local tState = self:RetActiveState ()

	if self:InInitialWaitState () then

		-- Traverse the graph to find a position to attack from
		self:MoveToTraversalPosition ()
		return true

	elseif self:InTraversalState () then

		-- Found a possible position to attack from
		if tState:Success () then
		
			-- Move to the attack position
			self:ChangeState (self:CreateMoveToTraversalPositionState (tState.vAttackPosition))
			
		else
			
			-- No position was found from which to attack the target - give up
			self.bTargetUnreachable = true
			self:Finish ()
		
		end
		return true

	elseif self:InMoveToTraversalPositionState () then

		if self.tTargetInfo:IsTargetVisible () then

			-- Target is visible but we still can't shoot him - try to find a better
			-- position to attack from
			self:MoveToTraversalPosition ()

		else

			-- Target is not visible, which means our information about it is no longer
			-- up to date and there's not likely to be much point traversing the graph to
			-- find another attack position, so just go to where we last saw the target
			self:MoveToLastKnownTargetPosition ()

		end
		return true

	elseif self:InMoveToLastKnownTargetPositionState () then

		-- We reached the last position we saw the target and still haven't seen them
		self.bTargetLost = true
		self:Finish ()
		return true

	end

	-- Call parent
	return TargetState.OnActiveStateFinished (self)
end

function MoveToAttackPosition:InAttackPosition ()

	if self.tTargetInfo:IsTargetVisible () and 
		self.tTargetInfo:IsPrimaryFireInRange () and 
	not self.tTargetInfo:IsPrimaryFireTooClose () and
	not self.tTargetInfo:IsPrimaryFireBlocked () then

		-- If we are trying to avoid the target then make sure we are far enough away
		if self.bAvoidTarget then
			if AILib.CharacterDist (self.tHost, self.tTargetInfo:RetTarget ()) > 
				self.nAvoidTargetRadius then
				return false
			end
		end

		-- If we are defending something then make sure we are within our radius of it
		if self.tDefendedObject then
			if not self:IsTargetInProximity (self.nProximityCheckID) then
				return false
			end
		end

		return true

	end
	return false

end

function MoveToAttackPosition:IsLastKnownTargetPositionInDefensiveRadius ()

	-- If we aren't defending anything then this always returns true
	if self.vDefendedPosition or self.tDefendedObject then

		-- Get the defended position
		local vCenterPosition = self.vDefendedPosition or self.tDefendedObject:RetPosition ()
		
		-- Get the distance between the defended position and the last known target position
		local nDist = AILib.Dist (vCenterPosition, self.tTargetInfo:RetLastTargetCentrePosition ())
	
		-- Return true if the last known target position is within the defensive radius
		return nDist < self.nRadius	

	end
	return true

end

function MoveToAttackPosition:MoveToTraversalPosition ()

	if self.nNumInvalidPositions < 5 then

		-- Traverse the graph to find a position to attack from 
		self:ChangeState (self:CreateTraversalState ())

		-- Add current position to list of invalid positions
		self.nNumInvalidPositions = self.nNumInvalidPositions + 1
		self.avInvalidPositions [self.nNumInvalidPositions] = self.tHost:RetPosition ()

	else

		-- If we have tried a lot of positions without success, give up
		self.bTargetUnreachable = true
		self:Finish ()

	end

end

function MoveToAttackPosition:MoveToLastKnownTargetPosition ()

	if self:IsLastKnownTargetPositionInDefensiveRadius () then

		-- Move to the last known target position
		self:ChangeState (self:CreateMoveToLastKnownTargetPositionState ())

	else

		-- We can't go to the last known target position because it's too far away
		-- so just give up
		self.bTargetLost = true
		self:Finish ()

	end

end

function MoveToAttackPosition:EvaluateConditions ()

	if self:InAttackPosition () then
		
		-- We are able to get a clear shot at the target
		self.bSuccess = true
		self:Finish ()

	elseif self.tTargetInfo:IsTargetVisible () and
		self:InMoveToLastKnownTargetPositionState () then

		-- We've caught sight of the target again but we still don't have a clear shot
		self:MoveToTraversalPosition ()

	end

end

function MoveToAttackPosition:CreateInitialWaitState ()
	return Create (WaitAndPrimaryFire,
	{
		nWaitTime = 0.5,
	})
end

function MoveToAttackPosition:CreateTraversalState ()
	return Create (MoveToAttackPositionTraversal,
	{
		nNumInvalidPositions = self.nNumInvalidPositions,
		avInvalidPositions = self.avInvalidPositions,
		vDefendedPosition = self.vDefendedPosition,
		tDefendedObject = self.tDefendedObject,
		nRadius = self.nRadius,
		bAvoidTarget = self.bAvoidTarget,
		nAvoidTargetRadius = self.nAvoidTargetRadius,
	})
end

function MoveToAttackPosition:CreateMoveToTraversalPositionState (vPosition)
	return Create (MoveToTraversalPosition,
	{
		nMovementType = self.nMovementType,
		nMovementPriority = self.nMovementPriority,
		vDestination = vPosition,
	})
end

function MoveToAttackPosition:CreateMoveToLastKnownTargetPositionState ()
	return Create (MoveToLastKnownTargetPosition,
	{
		nMovementType = self.nMovementType,
		nMovementPriority = self.nMovementPriority,
		vDestination = self.tTargetInfo:RetLastTargetCentrePosition (),
	})
end

function MoveToAttackPosition:InInitialWaitState ()
	return self:IsInState (WaitAndPrimaryFire)
end

function MoveToAttackPosition:InTraversalState ()
	return self:IsInState (MoveToAttackPositionTraversal)
end

function MoveToAttackPosition:InMoveToTraversalPositionState ()
	return self:IsInState (MoveToTraversalPosition)
end

function MoveToAttackPosition:InMoveToLastKnownTargetPositionState ()
	return self:IsInState (MoveToLastKnownTargetPosition)
end

function MoveToAttackPosition:Success ()
	return self.bSuccess
end

function MoveToAttackPosition:TargetLost ()
	return self.bTargetLost
end

function MoveToAttackPosition:TargetUnreachable ()
	return self.bTargetUnreachable
end
