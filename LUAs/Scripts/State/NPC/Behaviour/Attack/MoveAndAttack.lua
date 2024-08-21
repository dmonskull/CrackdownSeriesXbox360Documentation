----------------------------------------------------------------------
-- Name: MoveAndAttack State
-- Description: Move to a specified position, but shoot the enemy if you
-- happen see them on the way
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"
require "State\\NPC\\Action\\Movement\\Move"
require "State\\NPC\\Action\\Movement\\MoveAndPrimaryFire"
require "State\\NPC\\Action\\Combat\\CloseAttack"
require "State\\NPC\\Action\\Equipment\\Reload"
require "State\\NPC\\Behaviour\\TakeCover\\TakeCoverAndReload"

MoveAndAttack = Create (TargetState, 
{
	sStateName = "MoveAndAttack",
	nTargetInfoFlags = eTargetInfoFlags.nVisibilityChecks + eTargetInfoFlags.nPrimaryFireChecks + eTargetInfoFlags.nCombatTargetingChecks,
	bSuccess = false,
	bCanTakeCover = true,	-- Can I take cover when under fire?	
	vDestination = nil,		-- Specify destination position
})

function MoveAndAttack:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)

	-- Check parameters
	assert (self.vDestination)

	-- Subscribe events
	self.nTargetAppearedID = self:Subscribe (eEventType.AIE_TARGET_APPEARED, self.tTargetInfo)
	self.nTargetDisappearedID = self:Subscribe (eEventType.AIE_TARGET_DISAPPEARED, self.tTargetInfo)
	self.nCombatTargetFoundID = self:Subscribe (eEventType.AIE_COMBAT_TARGET_FOUND, self.tTargetInfo)

	if self.tHost:RetCurrentPrimaryEquipment () then
		self.nLowAmmoID = self:Subscribe (eEventType.AIE_OUT_OF_AMMO, self.tHost:RetCurrentPrimaryEquipment ())
	end

	-- Go into initial state
	self:PushState (self:CreateNextState ())
end

function MoveAndAttack:OnEvent (tEvent)

	if tEvent:HasID (self.nTargetAppearedID) then

		if self:InMoveState () then
			self:ChangeState (self:CreateMoveState ())
		end
		return true

	elseif tEvent:HasID (self.nTargetDisappearedID) then

		if self:InMoveState () then
			self:ChangeState (self:CreateMoveState ())
		end
		return true

	elseif tEvent:HasID (self.nCombatTargetFoundID) then

		self:ChangeState (self:CreateNextState ())
		return true

	elseif self.nLowAmmoID and tEvent:HasID (self.nLowAmmoID) then

		self:ChangeState (self:CreateNextState ())
		return true

	end

	-- Call parent
	return TargetState.OnEvent (self, tEvent)
end

function MoveAndAttack:OnActiveStateFinished ()

	local tState = self:RetActiveState ()

	if self:InReloadState () then

		self:ChangeState (self:CreateNextState ())
		return true

	elseif self:InCloseAttackState () then

		self:ChangeState (self:CreateNextState ())
		return true

	elseif self:InMoveState () then

		-- Reached destination
		self.bSuccess = tState.bSuccess
		self:Finish ()
		return true

	end

	-- Call parent
	return TargetState.OnActiveStateFinished (self)
end

function MoveAndAttack:CreateNextState ()

	-- Target is right in front of me - punch them
	if self.tTargetInfo:CanCloseAttackTarget () then

		return self:CreateCloseAttackState ()

	-- Ammo low - reload
	elseif self.tHost:IsCurrentPrimaryEquipmentEquiped () and
			self.tHost:RetCurrentPrimaryEquipment ():IsAmmoLow () then

		return self:CreateReloadState ()

	-- Default - run towards destination
	else
		return self:CreateMoveState ()

	end
	
end

function MoveAndAttack:CreateCloseAttackState ()
	return Create (CloseAttack, {})
end

function MoveAndAttack:InCloseAttackState ()
	return self:IsInState (CloseAttack)
end

function MoveAndAttack:CreateReloadState ()

	-- If I can see target, take cover before reloading
	if self.bCanTakeCover and self.tTargetInfo:IsTargetVisible () then

		return Create (TakeCoverAndReload, {})

	else

		return Create (Reload, {})

	end

end

function MoveAndAttack:InReloadState ()
	return self:IsInState (Reload) or self:IsInState (TakeCoverAndReload)
end

function MoveAndAttack:CreateMoveState ()

	-- If I can see target and I have a gun, face the target and shoot while running
	-- Otherwise just run towards the destination and don't face the target
	if self.tHost:IsCurrentPrimaryEquipmentEquiped () and self.tTargetInfo:IsTargetVisible () then
		
		return Create (MoveAndPrimaryFire,
		{
			nMovementType = eMovementType.nRun,
			vDestination = self.vDestination,
		})
	
	else

		return Create (Move,
		{
			nMovementType = eMovementType.nRun,
			vDestination = self.vDestination,
		})

	end

end

function MoveAndAttack:InMoveState ()
	return self:IsInState (Move) or self:IsInState (MoveAndPrimaryFire)
end

function MoveAndAttack:Success ()
	return self.bSuccess
end
