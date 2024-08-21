----------------------------------------------------------------------
-- Name: MoveToAndPickUpItem State
-- Description: Moves towards an equipment item until it is in range, 
-- then picks it up
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"
require "State\\NPC\\Action\\Turn\\MoveToAndFace"
require "State\\NPC\\Action\\Equipment\\PickUpItem"
require "State\\NPC\\Action\\Equipment\\EquipItem"

MoveToAndPickUpItem = Create (TargetState, 
{
	sStateName = "MoveToAndPickUpItem",
	nTargetInfoFlags = eTargetInfoFlags.nVisibilityChecks + eTargetInfoFlags.nObjectTargetingChecks,
	nMovementType = eMovementType.nWalk,
	nMovementPriority = eMovementPriority.nLow,
	bSuccess = false,
})

function MoveToAndPickUpItem:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)

	-- If I've already got that item make sure that I'm equipped with it
	if self.tHost:RetCurrentPrimaryEquipment () == self.tTargetInfo:RetTarget () then
		self:PushState (Create (EquipItem, 
		{
			tEquipment = self.tTargetInfo:RetTarget (),
		}))
	else
		-- If the target is already in range pick it up, otherwise move towards it
		if self.tTargetInfo:CanPickUpTarget () then
			self:PushState (Create (PickUpItem, {}))
		else
			self:PushState (Create (MoveToAndFace,
			{
				nMovementType = self.nMovementType,
				nMovementPriority = self.nMovementPriority,
			}))
		end
	
	end

	-- Subscribe events
	self.nObjectTargetFoundID = self:Subscribe (eEventType.AIE_OBJECT_TARGET_FOUND, self.tTargetInfo)
	self.nObjectLockedID = self:Subscribe (eEventType.AIE_OBJECT_LOCKED, self.tTargetInfo:RetTarget ())

end

function MoveToAndPickUpItem:OnActiveStateFinished ()
	
	local tState = self:RetActiveState ()

	-- Reached the last known target position but still unable to pick it up
	if tState:IsA (MoveToAndFace) then

		if self.tTargetInfo:CanPickUpTarget () then
			self:ChangeState (Create (PickUpItem, {}))
		else
			self.bSuccess = false
			self:Finish ()
		end
		return true

	elseif tState:IsA (PickUpItem) then

		self.bSuccess = tState:Success ()
		self:Finish ()
		return true

	elseif tState:IsA (EquipItem) then

		self.bSuccess = tState:Success ()
		self:Finish ()
		return true

	end

	-- Call parent
	return TargetState.OnActiveStateFinished (self)
end

function MoveToAndPickUpItem:OnEvent (tEvent)

	-- The object is now in range to be picked up
	if tEvent:HasID (self.nObjectTargetFoundID) then

		if not self:IsInState (PickUpItem) then
			self:ChangeState (Create (PickUpItem, {}))
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

function MoveToAndPickUpItem:Success ()
	return self.bSuccess
end
