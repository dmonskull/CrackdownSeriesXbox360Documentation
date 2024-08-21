----------------------------------------------------------------------
-- Name: Attack State
--	Description: Simple attack behaviour - Stand and shoot at the target
-- Reload if I run out of ammo
-- If I am out of range move closer
-- If the enemy is blocked move around the blockage
-- If the enemy disappears try to establish a line of sight
-- Finishes if a line of sight cannot be established or the enemy dies
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"
require "State\\NPC\\Action\\Combat\\CloseAttack"
require "State\\NPC\\Action\\Equipment\\FaceAndPrimaryFire"
require "State\\NPC\\Action\\Equipment\\Reload"
require "State\\NPC\\Action\\Equipment\\EquipItem"
require "State\\NPC\\Behaviour\\MoveToAttackPosition\\MoveToAttackPosition"

Attack = Create (TargetState,
{
	sStateName = "Attack",
	nTargetInfoFlags = eTargetInfoFlags.nVisibilityChecks + eTargetInfoFlags.nPrimaryFireChecks + eTargetInfoFlags.nCombatTargetingChecks,
	nMovementType = eMovementType.nRun,
	nMovementPriority = eMovementPriority.nLow,
	bTargetLost = false,
	bTargetUnreachable = false,
	bAvoidTarget = false,			-- Set this to make the traversal avoid the target
	nAvoidTargetRadius = nil,		-- This is the radius of the are to avoid around the target
})

function Attack:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)

	-- Subscribe to events
	self.nTargetLostID = self:Subscribe (eEventType.AIE_TARGET_DISAPPEARED, self.tTargetInfo)
	self.nTargetNotInRangeID = self:Subscribe (eEventType.AIE_PRIMARY_FIRE_NOT_IN_RANGE, self.tTargetInfo)
	self.nTargetTooCloseID = self:Subscribe (eEventType.AIE_PRIMARY_FIRE_TOO_CLOSE, self.tTargetInfo)
	self.nTargetBlockedID = self:Subscribe (eEventType.AIE_PRIMARY_FIRE_BLOCKED, self.tTargetInfo)
	self.nCombatTargetFoundID = self:Subscribe (eEventType.AIE_COMBAT_TARGET_FOUND, self.tTargetInfo)
	self.nEquipmentLostID = self:Subscribe (eEventType.AIE_EQUIPMENT_LOST, self.tHost)
	self.nOutOfAmmoID = self:Subscribe (eEventType.AIE_OUT_OF_AMMO, self.tHost:RetCurrentPrimaryEquipment ())

	-- Subscribe to proximity events to check if defended object moves out of radius
	if self.tDefendedObject then
		assert (self.nRadius)
		self.nProximityCheckID = self:AddProximityCheck (self.tHost, self.tDefendedObject, self.nRadius)
		self.nTargetNotInProximityID = self:Subscribe (eEventType.AIE_TARGET_NOT_IN_PROXIMITY, self.tHost)
	end

	-- Go into the Shoot state
	self:PushState (self:CreateShootState ())
end

function Attack:OnResume ()
	-- Call parent
	TargetState.OnResume (self)

	-- Re-evaluate conditions
	self:EvaluateConditions ()
end

function Attack:OnActiveStateChanged ()
	-- Re-evaluate conditions
	self:EvaluateConditions ()

	-- Call parent
	TargetState.OnActiveStateChanged (self)
end

-- Handle events
function Attack:OnEvent (tEvent)

	-- Target has disappeared
	if tEvent:HasID (self.nTargetLostID) then

		self:EvaluateConditions ()
		return true

	-- Target went out of range
	elseif tEvent:HasID (self.nTargetNotInRangeID) then

		self:EvaluateConditions ()
		return true

	-- Run out of ammo
	elseif tEvent:HasID (self.nOutOfAmmoID) then
	
		self:EvaluateConditions ()
		return true

	-- Target is blocked
	elseif tEvent:HasID (self.nTargetBlockedID) then

		self:EvaluateConditions ()
		return true

	-- Target is too close
	elseif tEvent:HasID (self.nTargetTooCloseID) then

		self:EvaluateConditions ()
		return true

	-- Target is close enough to punch
	elseif tEvent:HasID (self.nCombatTargetFoundID) then

		self:EvaluateConditions ()
		return true

	-- Dropped weapon
	elseif tEvent:HasID (self.nEquipmentLostID) then

		self:EvaluateConditions ()
		return true

	-- Defended object moved out of radius
	elseif self.tDefendedObject and
		tEvent:HasID (self.nTargetNotInProximityID) and
		tEvent:HasProximityCheckID (self.nProximityCheckID) then

		self:EvaluateConditions ()
		return true

	end

	-- Call parent
	return TargetState.OnEvent (self, tEvent)
end

function Attack:OnActiveStateFinished ()

	if self:InCloseAttackState () then

		self:ChangeState (self:CreateShootState ())
		return true

	elseif self:InReloadState () then

		self:ChangeState (self:CreateShootState ())
		return true

	elseif self:InMoveToAttackPositionState () then

		-- Failed to find a position from which to attack - bail out
		local tState = self:RetActiveState ()
		if tState:Success () then

			self:ChangeState (self:CreateShootState ())

		else

			self.bTargetUnreachable = tState:TargetUnreachable ()
			self.bTargetLost = tState:TargetLost ()
			self:Finish ()

		end
		return true

	end

	-- Call parent
	return TargetState.OnActiveStateFinished (self)
end

function Attack:EvaluateConditions ()

	if self:IsCloseAttackConditionSatisfied () then

		self:ChangeState (Create (CloseAttack, {}))
		return true

	elseif self:IsReloadConditionSatisfied () then

		self:ChangeState (self:CreateReloadState ())
		return true

	elseif self:IsMoveToAttackPositionConditionSatisfied () then

		self:ChangeState (self:CreateMoveToAttackPositionState ())
		return true
	
	end
	return false

end

function Attack:IsCloseAttackConditionSatisfied ()

	-- Target is in range to punch
	if self.tTargetInfo:CanCloseAttackTarget () then

		if self:InShootState () then
			return true
		end		

	end
	return false

end

function Attack:IsReloadConditionSatisfied ()

	-- Ran out of ammo (make sure he hasn't dropped the weapon)
	if self.tHost:IsCurrentPrimaryEquipmentEquiped () and
		self.tHost:RetCurrentPrimaryEquipment ():IsEmpty () then

		if self:InShootState () then
			return true
		end		

	end
	return false

end

function Attack:IsMoveToAttackPositionConditionSatisfied ()

	if self:InShootState () then

		-- Cannot see target
		if not self.tTargetInfo:IsTargetVisible () then
			return true
		end

		-- Target too far
		if not self.tTargetInfo:IsPrimaryFireInRange () then
			return true
		end

		-- Target too close
		if self.tTargetInfo:IsPrimaryFireTooClose () then
			return true
		end
		
		-- Target blocked
		if self.tTargetInfo:IsPrimaryFireBlocked () then
			return true
		end

		-- Defended object has moved away from us
		if self.tDefendedObject and not self:IsTargetInProximity (self.nProximityCheckID) then
			return true
		end

	end
	return false

end

function Attack:CreateCloseAttackState ()
	return Create (CloseAttack, {})
end

function Attack:CreateReloadState ()
	return Create (Reload, {})
end

function Attack:CreateShootState ()
	return Create (FaceAndPrimaryFire, {})
end

function Attack:CreateMoveToAttackPositionState ()
	return Create (MoveToAttackPosition, 
	{
		nMovementType = self.nMovementType,
		nMovementPriority = self.nMovementPriority,
		tDefendedObject = self.tDefendedObject,
		vDefendedPosition = self.vDefendedPosition,
		nRadius = self.nRadius,
	})
end

function Attack:InCloseAttackState ()
	return self:IsInState (CloseAttack)
end

function Attack:InReloadState ()
	return self:IsInState (Reload)
end

function Attack:InShootState ()
	return self:IsInState (FaceAndPrimaryFire)
end

function Attack:InMoveToAttackPositionState ()
	return self:IsInState (MoveToAttackPosition)
end

function Attack:FirearmLost ()
	return self.bFirearmLost
end

function Attack:TargetUnreachable ()
	return self.bTargetUnreachable
end

function Attack:TargetLost ()
	return self.bTargetLost
end
