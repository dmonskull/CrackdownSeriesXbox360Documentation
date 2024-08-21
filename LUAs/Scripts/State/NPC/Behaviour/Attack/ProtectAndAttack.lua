----------------------------------------------------------------------
-- Name: ProtectAndAttack State
--	Description: Stand in front of a protected object or position and attack
-- the enemy if they are in range
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"
require "State\\NPC\\Action\\Combat\\CloseAttack"
require "State\\NPC\\Action\\Equipment\\Reload"
require "State\\NPC\\Action\\Protect\\Protect"

ProtectAndAttack = Create (TargetState, 
{
	sStateName = "ProtectAndAttack",
	nTargetInfoFlags = eTargetInfoFlags.nVisibilityChecks + eTargetInfoFlags.nPrimaryFireChecks + eTargetInfoFlags.nCombatTargetingChecks,
	tProtectedObject = nil,		-- Specify object to protect, or
	vProtectedPosition = nil,	-- Specify position to protect
	nDistance = nil,			-- Specify distance from protected object or position
	nWaitTime = nil,			-- Specify if you want the state to finish after a certain amount of time
})

function ProtectAndAttack:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)

	-- Check parameters
	assert (self.tProtectedObject or self.vProtectedPosition)
	assert (self.nDistance)

	-- Subscribe events
	self.nCombatTargetFoundID = self:Subscribe (eEventType.AIE_COMBAT_TARGET_FOUND, self.tTargetInfo)

	if self.tHost:RetCurrentPrimaryEquipment () then
		self.nLowAmmoID = self:Subscribe (eEventType.AIE_OUT_OF_AMMO, self.tHost:RetCurrentPrimaryEquipment ())
	end

	-- Start non-looping timer
	if self.nWaitTime then
		self.nTimerID = self:AddTimer (self.nWaitTime, false)
		self.nTimerFinishedID = self:Subscribe (eEventType.AIE_TIMER_FINISHED, self.tHost)
	end

	-- Go into initial state
	self:PushState (self:CreateNextState ())
end

function ProtectAndAttack:OnEvent (tEvent)

	if tEvent:HasID (self.nCombatTargetFoundID) then

		self:ChangeState (self:CreateNextState ())
		return true

	elseif self.nLowAmmoID and tEvent:HasID (self.nLowAmmoID) then

		self:ChangeState (self:CreateNextState ())
		return true

	elseif self.nWaitTime and tEvent:HasID (self.nTimerFinishedID) and tEvent:HasTimerID (self.nTimerID) then

		self:Finish ()
		return true

	end

	-- Call parent
	return TargetState.OnEvent (self, tEvent)
end

function ProtectAndAttack:OnActiveStateFinished ()
	self:ChangeState (self:CreateNextState ())
	return true
end

function ProtectAndAttack:CreateNextState ()

	-- Target is right in front of me - punch them
	if self.tTargetInfo:CanCloseAttackTarget () then

		return Create (CloseAttack, {})

	-- Ammo low - reload
	elseif self.tHost:IsCurrentPrimaryEquipmentEquiped () and 
			self.tHost:RetCurrentPrimaryEquipment ():IsAmmoLow () then

		return Create (Reload, {})

	-- Default - stand in front of protected object or position and shoot
	else

		return Create (Protect, 
		{
			tProtectedObject = self.tProtectedObject,
			vProtectedPosition = self.vProtectedPosition,
			nDistance = self.nDistance,
		})

	end
	
end
