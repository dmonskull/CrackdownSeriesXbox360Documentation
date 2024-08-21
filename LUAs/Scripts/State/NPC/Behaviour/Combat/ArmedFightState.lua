----------------------------------------------------------------------
-- Name: ArmedFightState State
-- Description: Attack the target using a primary weapon
-- Stays in range of the target
-- Takes cover to reload or avoid being damaged
-- Throws grenades when the target is blocked
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\Behaviour\\Combat\\FightState"
require "State\\NPC\\Behaviour\\Attack\\Attack"
require "State\\NPC\\Behaviour\\Attack\\StandAndAttack"
require "State\\NPC\\Behaviour\\Attack\\ProtectAndAttack"
require "State\\NPC\\Behaviour\\Attack\\GrenadeAttack"
require "State\\NPC\\Behaviour\\TakeCover\\TakeCoverAndWait"
require "State\\NPC\\Behaviour\\TakeCover\\TakeCoverAndReload"
require "State\\NPC\\Behaviour\\Arm\\ArmWithBestWeapon"

ArmedFightState = Create (FightState,
{
	sStateName = "ArmedFightState",
	nTargetInfoFlags = 
		eTargetInfoFlags.nVisibilityChecks + 
		eTargetInfoFlags.nPrimaryFireChecks +
		eTargetInfoFlags.nInventoryWeaponChecks,
	bFirearmChanged = false,
	nGrenadeAttackTime = 8,				-- Minimum time allowed between grenade attacks
	nTakeCoverFailTime = 10,			-- Minimum time allowed between failed attempts to take cover
	bCanGrenadeAttack = true,			-- Can I throw grenades?
	bCanTakeCover = true,				-- Can I take cover to reload or avoid being shot?
	nShotsFired = 0,
})

function ArmedFightState:OnEnter (tEvent)
	-- Call parent
	FightState.OnEnter (self)

	-- Get pointer to weapon
	self.tFirearm = self.tHost:RetCurrentPrimaryEquipment ()
	assert (self.tFirearm)

	-- Determine number of shots fired before taking cover, based on personality and clip size
	if self.tHost:RetPersonality () >= ePersonality.nBrave then
		self.nShotsFiredBeforeTakingCover = self.tFirearm:RetMaxAmmoCount ()
	elseif self.tHost:RetPersonality () <= ePersonality.nCowardly then
		self.nShotsFiredBeforeTakingCover = self.tFirearm:RetMaxAmmoCount () / 10
	else
		self.nShotsFiredBeforeTakingCover = self.tFirearm:RetMaxAmmoCount () / 3
	end

	-- Must fire at least one shot before taking cover
	self.nShotsFiredBeforeTakingCover = Max (1, self.nShotsFiredBeforeTakingCover)

	-- Subscribe to events
	self.nPrimaryFireFinishedID = self:Subscribe (eEventType.AIE_PRIMARY_FIRE_FINISHED, self.tHost)
	self.nTimerFinishedID = self:Subscribe (eEventType.AIE_TIMER_FINISHED, self.tHost)
	self.nTargetAppearedID = self:Subscribe (eEventType.AIE_TARGET_APPEARED, self.tTargetInfo)
	self.nTargetFacingMeID = self:Subscribe (eEventType.AIE_TARGET_FACING_ME, self.tTargetInfo)
	self.nTargetBlockedID = self:Subscribe (eEventType.AIE_PRIMARY_FIRE_BLOCKED, self.tTargetInfo)
	self.nTargetAreaNotClearID = self:Subscribe (eEventType.AIE_PRIMARY_FIRE_AREA_NOT_CLEAR, self.tTargetInfo)
	self.nInventoryWeaponCanBeUsedID = self:Subscribe (eEventType.AIE_INVENTORY_WEAPON_CAN_BE_USED, self.tTargetInfo)
	self.nEquipmentLostID = self:Subscribe (eEventType.AIE_EQUIPMENT_LOST, self.tHost)
	self.nLowAmmoID = self:Subscribe (eEventType.AIE_LOW_AMMO, tFirearm)

	self:PushState (self:CreateAttackState ()) 
end

function ArmedFightState:OnEvent (tEvent)

	if self.nGrenadeAttackTimerID and tEvent:HasID (self.nTimerFinishedID) and tEvent:HasTimerID (self.nGrenadeAttackTimerID) then
	
		self.bCanGrenadeAttack = true
		self:EvaluateConditions ()
		return true

	elseif self.nTakeCoverTimerID and tEvent:HasID (self.nTimerFinishedID) and tEvent:HasTimerID (self.nTakeCoverTimerID) then
	
		self.bCanTakeCover = true
		self:EvaluateConditions ()
		return true

	elseif tEvent:HasID (self.nPrimaryFireFinishedID) then

		self.nShotsFired = self.nShotsFired + 1
		self:EvaluateConditions ()
		return true

	elseif tEvent:HasID (self.nTargetAppearedID) then

		self:EvaluateConditions ()
		return true

	elseif tEvent:HasID (self.nTargetFacingMeID) then

		self:EvaluateConditions ()
		return true

	elseif tEvent:HasID (self.nTargetBlockedID) then

		self:EvaluateConditions ()
		return true

	elseif tEvent:HasID (self.nTargetAreaNotClearID) then

		self:EvaluateConditions ()
		return true

	elseif tEvent:HasID (self.nLowAmmoID) then

		self:EvaluateConditions ()
		return true

	elseif tEvent:HasID (self.nInventoryWeaponCanBeUsedID) then

		self:EvaluateConditions ()
		return true

	elseif tEvent:HasID (self.nEquipmentLostID) then

		self:EvaluateConditions ()
		return true

	end

	-- Call parent
	return FightState.OnEvent (self, tEvent)
end

function ArmedFightState:OnActiveStateFinished ()

	local tState = self:RetActiveState ()

	if self:InGrenadeAttackState () then

		-- Disable grenade attacks for a while
		self.bCanGrenadeAttack = false
		self.nGrenadeAttackTimerID = self:AddTimer (self.nGrenadeAttackTime, false)
		self:ChangeState (self:CreateAttackState ()) 
		return true

	elseif self:InTakeCoverAndWaitState () or
			self:InTakeCoverAndReloadState () then

		if not tState:Success () and not tState:ReachedCover () then
			-- Could not find any cover - disable taking cover for a while
			self.bCanTakeCover = false
			self.nTakeCoverTimerID = self:AddTimer (self.nTakeCoverFailTime, false)
		else
			-- Reset shots counter so we won't take cover again until we have fired enough
			self.nShotsFired = 0
		end

		self:ChangeState (self:CreateAttackState ()) 
		return true

	elseif self:InAttackState ()  then

		if tState:TargetUnreachable () then

			self:ChangeState (self:CreateTargetUnreachableState ()) 

		elseif tState:TargetLost () then

			self.bTargetLost = true
			self:Finish ()

		end
		return true

	elseif self:InTargetUnreachableState () then

		if self.tTargetInfo:IsTargetVisible () then

			self:ChangeState (self:CreateAttackState ())

		else

			self.bTargetLost = true
			self:Finish ()
			
		end
		return true

	elseif self:InChangeFirearmState () then

		self.bFirearmChanged = true
		self:Finish ()
		return true

	end

	-- Call parent
	return FightState.OnActiveStateFinished (self)
end

function ArmedFightState:EvaluateConditions ()

	if self:IsChangeFirearmConditionSatisfied () then

		self:ChangeState (self:CreateChangeFirearmState ())
		return true

	elseif self:IsTakeCoverAndReloadConditionSatisfied () then

		self:ChangeState (self:CreateTakeCoverAndReloadState ())
		return true

	elseif self:IsTakeCoverAndWaitConditionSatisfied () then

		self:ChangeState (self:CreateTakeCoverAndWaitState (2))
		return true

	elseif self:IsGrenadeAttackConditionSatisfied () then

		self:ChangeState (self:CreateGrenadeAttackState ())
		return true

	end

	-- Call parent
	return FightState.EvaluateConditions (self)
end

function ArmedFightState:IsChangeFirearmConditionSatisfied ()

	-- If it is no longer in the inventory, or if it has been deleted,
	-- then it must have been shot out of our hands
	if not self.tFirearm or 
		not self.tHost:IsEquipmentInInventory (self.tFirearm) then

		-- Must be in a state - any state
		if	self:InAttackState () or 
			self:InGrenadeAttackState () or
			self:InTakeCoverAndWaitState () or
			self:InTakeCoverAndReloadState () or
			self:InTargetUnreachableState () then

			return true
		end

	end

	-- Is there a better weapon in the inventory?
	if self.tTargetInfo:RetInventoryWeapon () then

		if	self:InAttackState () or 
			self:InTakeCoverAndWaitState () or
			self:InTargetUnreachableState () then

			return true

		end

	end

	-- If primary firing would hurt friendlies
	if not self.tTargetInfo:IsPrimaryFireAreaClear () then

		if	self:InAttackState () or 
			self:InTakeCoverAndWaitState () or
			self:InTargetUnreachableState () then

			return true

		end

	end
	return false

end

function ArmedFightState:IsTakeCoverAndWaitConditionSatisfied ()

	-- Is taking cover enabled?
	if self.bCanTakeCover then
	
		-- Only take cover after I have fired a certain number of shots
		if self.nShotsFired > self.nShotsFiredBeforeTakingCover then
	
			-- Am I in the Attack state?
			if	self:InAttackState () or
				self:InTargetUnreachableState () then
	
				-- Is the target facing me (so it could shoot me), and visible (so I know it is facing me)?
				if self.tTargetInfo:IsTargetFacingMe () and 
					self.tTargetInfo:IsTargetVisible () then
	
					return true
	
				end
	
			end

		end
		
	end
	return false

end

function ArmedFightState:IsTakeCoverAndReloadConditionSatisfied ()

	-- Is taking cover enabled?
	if self.bCanTakeCover then
	
		-- Am I in the Attack or TakeCoverAndWait state?
		if	self:InAttackState () or 
			self:InTakeCoverAndWaitState () or
			self:InTargetUnreachableState () then
	
			-- Am I running out of ammo soon?
			if self.tHost:RetCurrentPrimaryEquipment ():IsAmmoLow () then

				-- Is the target facing me (so it could shoot me), and visible (so I know it is facing me)?
				if self.tTargetInfo:IsTargetFacingMe () and 
					self.tTargetInfo:IsTargetVisible () then
	
					return true

				end

			end

		end

	end
	return false

end

function ArmedFightState:IsGrenadeAttackConditionSatisfied ()

	-- Is grenade attacking enabled?
	if self.bCanGrenadeAttack then

		-- Am I in the Attack state?
		if self:InAttackState () then

			-- Is the primary fire weapon blocked (so I can't just shoot it)
			if self.tTargetInfo:IsPrimaryFireBlocked () then

				-- Do I have a grenade in my inventory?
				local tGrenade = self.tHost:RetCurrentSecondaryEquipment ()
				if tGrenade then

					-- Could I hit the target with it from where I'm standing?
					if tGrenade:CanAttackTarget (
						self.tHost:RetCharacter (), 
						self.tTargetInfo:RetCharacterTarget (), 
						self.tHost:RetCentre (),
						self.tTargetInfo:RetLastTargetFocusPointPosition (),
						false) then

						return true

					end

				end

			end

		end
		
	end
	return false

end

function ArmedFightState:CreateChangeFirearmState ()
	return Create (ArmWithBestWeapon, 
	{
		bCanUseCurrentFirearm = false,
	})
end

function ArmedFightState:CreateAttackState ()
	return Create (Attack, 
	{
		tDefendedObject = self.tDefendedObject,
		vDefendedPosition = self.vDefendedPosition,
		nRadius = self.nRadius,
	})
end

function ArmedFightState:CreateTakeCoverAndWaitState (nWaitTime)
	return Create (TakeCoverAndWait,
	{
		tDefendedObject = self.tDefendedObject,
		vDefendedPosition = self.vDefendedPosition,
		nRadius = self.nRadius,
		nWaitTime = nWaitTime,
	})
end

function ArmedFightState:CreateTakeCoverAndReloadState ()
	return Create (TakeCoverAndReload, 
	{
		tDefendedObject = self.tDefendedObject,
		vDefendedPosition = self.vDefendedPosition,
		nRadius = self.nRadius,
	})
end

function ArmedFightState:CreateTargetUnreachableState ()

	-- We cannot find a good attack position because the target is too close - try to use a different weapon
	if self.tTargetInfo:IsTargetVisible () and
		self.tTargetInfo:IsPrimaryFireTooClose () then

		return self:CreateChangeFirearmState ()

	end

	-- Cannot reach target to attack - just try to take cover for a long
	-- period of time instead
	if self.bCanTakeCover then

		return self:CreateTakeCoverAndWaitState (10)

	end

	-- Cannot reach target to shoot them and unable to take cover!
	-- We are in shit but there is nothing we can do - just wait and hope something changes
	if self.vDefendedPosition or self.tDefendedObject then

		return Create (ProtectAndAttack,
		{
			vProtectedPosition = self.vDefendedPosition,
			tProtectedObject = self.tDefendedObject,
			nDistance = Min (self.nRadius, 3),
			nWaitTime = 5,
		})

	else

		return Create (StandAndAttack,
		{
			nWaitTime = 5,
		})

	end
	
end

function ArmedFightState:CreateGrenadeAttackState ()
	return Create (GrenadeAttack, {})
end

function ArmedFightState:InAttackState ()
	return self:IsInState (Attack)
end

function ArmedFightState:InChangeFirearmState ()
	return self:IsInState (ArmWithBestWeapon)
end

function ArmedFightState:InTakeCoverAndWaitState ()
	return self:IsInState (TakeCoverAndWait)
end

function ArmedFightState:InTakeCoverAndReloadState ()
	return self:IsInState (TakeCoverAndReload)
end

function ArmedFightState:InTargetUnreachableState ()
	return self:IsInState (StandAndAttack) or self:IsInState (ProtectAndAttack)
end

function ArmedFightState:InGrenadeAttackState ()
	return self:IsInState (GrenadeAttack)
end

function ArmedFightState:FirearmChanged ()
	return self.bFirearmChanged
end
