----------------------------------------------------------------------
-- Name: UnarmedFightState
-- Description: Attack the target without a weapon
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\Action\\Animation\\TimedCircle"
require "State\\NPC\\Action\\Chase\\GetLineOfSight"
require "State\\NPC\\Action\\Chase\\GetInProximity"
require "State\\NPC\\Action\\Equipment\\MoveToAndPickUpItem"
require "State\\NPC\\Behaviour\\Combat\\FightState"
require "State\\NPC\\Behaviour\\Attack\\PropAttack"
require "State\\NPC\\Behaviour\\TakeCover\\TakeCover"
require "State\\NPC\\Behaviour\\Scripted\\Insult"

UnarmedFightState = Create (FightState, 
{
	sStateName = "UnarmedFightState",
	nPropAttackTime = 8,		-- Minimum time allowed between prop attacks
	nFirearmAttackTime = 8,		-- Minimum time allowed between failed attempts to pick up a weapon
	bCanPropAttack = true,		-- Can I throw props at the enemy?
	bCanFirearmAttack = true,	-- Can I pick up weapons in the area?
 	bFirearmFound = false,
})

function UnarmedFightState:OnEnter ()
	-- Check parameters
	assert (self.nCircleDistance)
	assert (self.nMinCircleDistance)
	assert (self.nMaxCircleDistance)
	assert (self.nStrikeTime)

	-- Set up target info checks - no point in checking for weapons in inventory
	-- or nearby area if we are not allowed to use them
	if self.bCanFirearmAttack then
		self.nTargetInfoFlags = self.nTargetInfoFlags + eTargetInfoFlags.nInventoryWeaponChecks
	end

	if self.bCanPropAttack or self.bCanFirearmAttack then
		self.nTargetInfoFlags = self.nTargetInfoFlags + eTargetInfoFlags.nAreaWeaponChecks
	end

	-- Call parent
	FightState.OnEnter (self)

	-- Set up proximity checks
	self.nMinProximityCheckID = self:AddProximityCheck (self.tHost, self.tTargetInfo:RetTarget (), self.nMinCircleDistance)
	self.nMaxProximityCheckID = self:AddProximityCheck (self.tHost, self.tTargetInfo:RetTarget (), self.nMaxCircleDistance)

	-- Subscribe events
	self.nTimerFinishedID = self:Subscribe (eEventType.AIE_TIMER_FINISHED, self.tHost)
	self.nTargetInProximityID = self:Subscribe (eEventType.AIE_TARGET_IN_PROXIMITY, self.tHost)
	self.nTargetNotInProximityID = self:Subscribe (eEventType.AIE_TARGET_NOT_IN_PROXIMITY, self.tHost)
	self.nTargetNotFacingMeID = self:Subscribe (eEventType.AIE_TARGET_NOT_FACING_ME, self.tTargetInfo)
	self.nTargetDisappearedID = self:Subscribe (eEventType.AIE_TARGET_DISAPPEARED, self.tTargetInfo)
	self.nInventoryWeaponCanBeUsedID = self:Subscribe (eEventType.AIE_INVENTORY_WEAPON_CAN_BE_USED, self.tTargetInfo)
	self.nAreaWeaponCanBeUsedID = self:Subscribe (eEventType.AIE_AREA_WEAPON_CAN_BE_USED, self.tTargetInfo)

	-- Circle the target
	self:PushState (self:CreateCircleState ())
end

function UnarmedFightState:OnEvent (tEvent)

	-- Prop Attack Timer finished, we are now allowed to prop attack
	if self.nPropAttackTimerID and tEvent:HasID (self.nTimerFinishedID) and tEvent:HasTimerID (self.nPropAttackTimerID) then

		self.nPropAttackTimerID = nil
		self.bCanPropAttack = true
		self:EvaluateConditions ()
		return true

	-- Firearm Attack Timer finished, we are now allowed to pick up firearms
	elseif self.nFirearmAttackTimerID and tEvent:HasID (self.nTimerFinishedID) and tEvent:HasTimerID (self.nFirearmAttackTimerID) then

		self.nFirearmAttackTimerID = nil
		self.bCanFirearmAttack = true
		self:EvaluateConditions ()
		return true

	-- Target is pretty close to me, so attack
	elseif tEvent:HasID (self.nTargetInProximityID) and tEvent:HasProximityCheckID (self.nMinProximityCheckID) then

		self:EvaluateConditions ()
		return true

	-- Target is getting a long way away
	elseif tEvent:HasID (self.nTargetInProximityID) and tEvent:HasProximityCheckID (self.nMaxProximityCheckID) then

		self:EvaluateConditions ()
		return true

	elseif tEvent:HasID (self.nTargetNotFacingMeID) then

		self:EvaluateConditions ()
		return true

	elseif tEvent:HasID (self.nTargetDisappearedID) then

		self:EvaluateConditions ()
		return true

	elseif tEvent:HasID (self.nInventoryWeaponCanBeUsedID) then

		self:EvaluateConditions ()
		return true

	elseif tEvent:HasID (self.nAreaWeaponCanBeUsedID) then

		self:EvaluateConditions ()
		return true

	end

	-- Call parent
	return FightState.OnEvent (self, tEvent)
end

function UnarmedFightState:OnActiveStateFinished ()

	local tState = self:RetActiveState ()

	if self:InGetLineOfSightState () then

		if tState:Success () then

			-- Established line of sight
			self:ChangeState (self:CreateCircleState ())

		else

			-- Failed to establish line of sight
			self.bTargetLost = true
			self:Finish ()

		end
		return true

	elseif self:InGetInProximityState () then

		if tState:Success () then

			-- Close enough to circle
			self:ChangeState (self:CreateCircleState ())

		else

			-- Failed to get close enough to target to circle - take cover
			self:ChangeState (self:CreateTakeCoverState ())

		end
		return true

	elseif self:InTakeCoverState () then

		-- Insult the enemy from a safe distance
		self:ChangeState (self:CreateInsultState ())
		return true

	elseif self:InInsultState () then

		self:ChangeState (self:CreateCircleState ())
		return true

	elseif self:InPropAttackState () then

		-- Set a timer until prop attacks are allowed
		self.nPropAttackTimerID = self:AddTimer (self.nPropAttackTime, false)
		self.bCanPropAttack = false
		self:ChangeState (self:CreateCircleState ())
		return true

	elseif self:InUseInventoryFirearmState () then

		if tState:Success () then

			-- We successfully equipped with the weapon - use a different combat mode
			self.bFirearmFound = true
			self:Finish ()

		else

			-- Failed to equip with the weapon
			-- Set a timer until firearm attacks are allowed
			self.nFirearmAttackTimerID = self:AddTimer (self.nFirearmAttackTime, false)
			self.bCanFirearmAttack = false
			self:ChangeState (self:CreateCircleState ())

		end
		return true

	elseif self:InUseAreaFirearmState () then

		if tState:Success () then

			-- We successfully picked up the weapon - use a different combat mode
			self.bFirearmFound = true
			self:Finish ()

		else

			-- Failed to pick up the weapon
			-- Set a timer until firearm attacks are allowed
			self.nFirearmAttackTimerID = self:AddTimer (self.nFirearmAttackTime, false)
			self.bCanFirearmAttack = false
			self:ChangeState (self:CreateCircleState ())

		end
		return true

	elseif self:InCircleState () then

		-- Override this in derived classes!
		self:ChangeState (self:CreateCircleState ())
		return true

	end

	-- Call parent
	return FightState.OnActiveStateFinished (self)
end

function UnarmedFightState:EvaluateConditions ()

	if self:IsUseInventoryFirearmConditionSatisfied () then

		self:ChangeState (self:CreateUseInventoryFirearmState ())
		return true

	elseif self:IsUseAreaFirearmConditionSatisfied () then

		self:ChangeState (self:CreateUseAreaFirearmState ())
		return true

	elseif self:IsPropAttackConditionSatisfied () then

		self:ChangeState (self:CreatePropAttackState ())
		return true

	elseif self:IsGetLineOfSightConditionSatisfied () then

		self:ChangeState (self:CreateGetLineOfSightState ())
		return true

	elseif self:IsGetInProximityConditionSatisfied () then

		self:ChangeState (self:CreateGetInProximityState ())
		return true

	end

	-- Call parent
	return FightState.EvaluateConditions (self)
end

function UnarmedFightState:IsPropAttackConditionSatisfied ()

	-- Is there a prop we could use in the nearby area?
	if self.bCanPropAttack then

		if self.tTargetInfo:RetAreaWeapon () and
			not self.tTargetInfo:RetAreaWeapon ():IsA (cEquipment) then
	
			if self:InCircleState () or
				self:InGetInProximityState () then
				
				return true
	
			end
	
		end

	end
	return false

end

function UnarmedFightState:IsUseInventoryFirearmConditionSatisfied ()

	-- Is there a weapon we could use in the inventory?
	if self.bCanFirearmAttack then

		if self.tTargetInfo:RetInventoryWeapon () then
	
			if self:InCircleState () or
				self:InGetInProximityState () then
				
				return true
	
			end
	
		end

	end
	return false

end

function UnarmedFightState:IsUseAreaFirearmConditionSatisfied ()

	-- Is there a primary weapon we could use in the nearby area?
	if self.bCanFirearmAttack then

		local tWeapon = self.tTargetInfo:RetAreaWeapon ()

		if tWeapon and
			tWeapon:IsA (cEquipment) and 
			tWeapon:RetEquipmentType () == eEquipmentType.nPrimary then
	
			if self:InCircleState () or
				self:InGetInProximityState () then
				
				return true
	
			end

		end
	
	end
	return false

end

function UnarmedFightState:IsGetLineOfSightConditionSatisfied ()

	-- Have we lost sight of the target?
	if not self.tTargetInfo:IsTargetVisible () then

		if self:InCircleState () or
			self:InGetInProximityState () then
	
			return true

		end

	end
	return false

end

function UnarmedFightState:IsGetInProximityConditionSatisfied ()

	-- Are we too far away from the target?
	if not self:IsTargetInProximity (self.nMaxProximityCheckID) then

		if self:InCircleState () then
			return true
		end

	end
	return false

end

function UnarmedFightState:CreateCircleState ()
	return Create (TimedCircle, 
	{
		nMovementType = eMovementType.nWalk,
		nDistance = self.nCircleDistance,
		nTimeout = self.nStrikeTime,
	})
end

function UnarmedFightState:CreateUseInventoryFirearmState ()
	return Create (EquipItem,
	{
		tEquipment = self.tTargetInfo:RetInventoryWeapon (),
	})
end

function UnarmedFightState:CreateUseAreaFirearmState ()
	return Create (MoveToAndPickUpItem,
	{
		nMovementType = eMovementType.nRun,
		tTarget = self.tTargetInfo:RetAreaWeapon (),
	})
end

function UnarmedFightState:CreatePropAttackState ()
	return Create (PropAttack,
	{
		nMovementType = eMovementType.nRun,
		tProp = self.tTargetInfo:RetAreaWeapon (),
	})
end

function UnarmedFightState:CreateGetInProximityState ()
	return Create (GetInProximity,
	{
		nMovementType = eMovementType.nRun,
		nRadius = self.nCircleDistance,
	})
end

function UnarmedFightState:CreateGetLineOfSightState ()
	return Create (GetLineOfSight, 
	{
		nMovementType = eMovementType.nRun,
	})
end

function UnarmedFightState:CreateInsultState ()
	return Create (Insult, {})
end

function UnarmedFightState:CreateTakeCoverState ()
	return Create (TakeCover, {})
end

function UnarmedFightState:InCircleState ()
	return self:IsInState (TimedCircle)
end

function UnarmedFightState:InPropAttackState ()
	return self:IsInState (PropAttack)
end

function UnarmedFightState:InUseInventoryFirearmState ()
	return self:IsInState (EquipItem)
end

function UnarmedFightState:InUseAreaFirearmState ()
	return self:IsInState (MoveToAndPickUpItem)
end

function UnarmedFightState:InGetInProximityState ()
	return self:IsInState (GetInProximity)
end

function UnarmedFightState:InGetLineOfSightState ()
	return self:IsInState (GetLineOfSight)
end

function UnarmedFightState:InInsultState ()
	return self:IsInState (Insult)
end

function UnarmedFightState:InTakeCoverState ()
	return self:IsInState (TakeCover)
end

function UnarmedFightState:FirearmFound ()
	return self.bFirearmFound
end
