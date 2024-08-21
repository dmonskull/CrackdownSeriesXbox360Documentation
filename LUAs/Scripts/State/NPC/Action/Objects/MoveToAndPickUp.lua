----------------------------------------------------------------------
-- Name: MoveToAndPickUp State
-- Description: Moves towards an object until it is in range, then picks it up
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"
require "State\\NPC\\Action\\Turn\\MoveToAndFace"
require "State\\NPC\\Action\\Objects\\PickUp"

MoveToAndPickUp = Create (TargetState, 
{
	sStateName = "MoveToAndPickUp",
	nTargetInfoFlags = eTargetInfoFlags.nVisibilityChecks + eTargetInfoFlags.nObjectTargetingChecks,
	nMovementType = eMovementType.nWalk,
	nMovementPriority = eMovementPriority.nLow,
	bSuccess = false,
})

function MoveToAndPickUp:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)

	-- Are we already carrying this object?
	if self.tHost:RetCarriedObject () == self.tTargetInfo:RetTarget () then
		self.bSuccess = true
		self:Finish ()
	else
		-- If the target is already in range pick it up, otherwise move towards it
		if self.tTargetInfo:CanPickUpTarget () then
			self:PushState (Create (PickUp, {}))
		else
			self:PushState (Create (MoveToAndFace,
			{
				nMovementType = self.nMovementType,
				nMovementPriority = self.nMovementPriority,
			}))
		end
	
		-- Subscribe events
		self.nObjectTargetFoundID = self:Subscribe (eEventType.AIE_OBJECT_TARGET_FOUND, self.tTargetInfo)
		self.nObjectLockedID = self:Subscribe (eEventType.AIE_OBJECT_LOCKED, self.tTargetInfo:RetTarget ())
	end

end

function MoveToAndPickUp:OnActiveStateFinished ()
	
	local tState = self:RetActiveState ()

	-- Reached the last known target position but still unable to pick it up
	if tState:IsA (MoveToAndFace) then

		if self.tTargetInfo:CanPickUpTarget () then
			self:ChangeState (Create (PickUp, {}))
		else
			self.bSuccess = false
			self:Finish ()
		end
		return true

	elseif tState:IsA (PickUp) then

		self.bSuccess = tState:Success ()
		self:Finish ()
		return true

	end

	-- Call parent
	return TargetState.OnActiveStateFinished (self)
end

function MoveToAndPickUp:OnEvent (tEvent)

	-- The object is now in range to be picked up
	if tEvent:HasID (self.nObjectTargetFoundID) then

		if not self:IsInState (PickUp) then
			self:ChangeState (Create (PickUp, {}))
		end
		return true

	-- Someone else picked the object up
	elseif tEvent:HasID (self.nObjectLockedID) then

		self.bSuccess = false
		self:Finish ()
		return true

	end

	-- Call parent
	return TargetState.OnEvent (self, tEvent)
end

function MoveToAndPickUp:Success ()
	return self.bSuccess
end
