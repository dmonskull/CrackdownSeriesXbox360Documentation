----------------------------------------------------------------------
-- Name: MoveToAndPrimaryFire State
-- Description: This state encapsulates moving up to a target and shooting it
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"
require "State\\NPC\\Action\\Turn\\MoveToAndFace"
require "State\\NPC\\Action\\Equipment\\PrimaryFire"

MoveToAndPrimaryFire = Create (TargetState, 
{
	sStateName = "MoveToAndPrimaryFire",
	nTargetInfoFlags = eTargetInfoFlags.nVisibilityChecks + eTargetInfoFlags.nPrimaryFireChecks,
	nMovementType = eMovementType.nWalk,
	nMovementPriority = eMovementPriority.nLow,
	nCount = 1,
	nRadius = 20,
	bSuccess = false,
})

function MoveToAndPrimaryFire:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)

	-- Set up proximity check
	self.nProximityCheckID = self:AddProximityCheck (self.tHost, self.tTargetInfo:RetTarget (), self.nRadius)

	-- Subscribe events
	self.nTargetInProximityID = self:Subscribe (eEventType.AIE_TARGET_IN_PROXIMITY, self.tHost)
	self.nTargetInRangeID = self:Subscribe (eEventType.AIE_PRIMARY_FIRE_IN_RANGE, self.tTargetInfo)
	self.nTargetUnblockedID = self:Subscribe (eEventType.AIE_PRIMARY_FIRE_UNBLOCKED, self.tTargetInfo)
	self.nTargetAppearedID = self:Subscribe (eEventType.AIE_TARGET_APPEARED, self.tTargetInfo)
	self.nFacingTargetID = self:Subscribe (eEventType.AIE_FACING_TARGET, self.tTargetInfo)

	-- Move towards target
	self:PushState (Create (MoveToAndFace,
	{
		nMovementType = self.nMovementType,
		nMovementPriority = self.nMovementPriority,
	}))

	self:EvaluateConditions ()
end

function MoveToAndPrimaryFire:OnActiveStateFinished ()
	
	local tState = self:RetActiveState ()

	-- Reached last known target position but still unable to shoot it - fail
	if tState:IsA (MoveToAndFace) then

		self.bSuccess = false
		self:Finish ()
		return true

	-- Finished attacking - repeat attack for the desired number of times or until it fails
	elseif tState:IsA (PrimaryFire) then

		self.nCount = self.nCount - 1

		if tState:Success () and self.nCount > 0 then
			self:ChangeState (Create (PrimaryFire, {}))
		else
			self.bSuccess = tState:Success ()
			self:Finish ()
		end
		return true

	end

	-- Call parent
	return TargetState.OnActiveStateFinished (self)
end

function MoveToAndPrimaryFire:OnEvent (tEvent)

	if tEvent:HasID (self.nTargetInRangeID) then

		self:EvaluateConditions ()
		return true

	elseif tEvent:HasID (self.nTargetUnblockedID) then

		self:EvaluateConditions ()
		return true

	elseif tEvent:HasID (self.nTargetInProximityID) then

		self:EvaluateConditions ()
		return true

	elseif tEvent:HasID (self.nTargetAppearedID) then

		self:EvaluateConditions ()
		return true

	elseif tEvent:HasID (self.nFacingTargetID) then

		self:EvaluateConditions ()
		return true

	end

	-- Call parent
	return TargetState.OnEvent (self, tEvent)
end

function MoveToAndPrimaryFire:EvaluateConditions ()

	if self:IsInState (MoveToAndFace) then

		if self.tTargetInfo:CanPrimaryFire () and self:IsTargetInProximity (self.nProximityCheckID) then

			self:ChangeState (Create (PrimaryFire, {}))
		
		end

	end

end

function MoveToAndPrimaryFire:Success ()
	return self.bSuccess
end
