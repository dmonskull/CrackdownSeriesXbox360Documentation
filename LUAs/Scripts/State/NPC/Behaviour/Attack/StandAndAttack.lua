----------------------------------------------------------------------
-- Name: StandAndAttack State
--	Description: Stand still and attack the enemy if they are in range
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"
require "State\\NPC\\Action\\Combat\\CloseAttack"
require "State\\NPC\\Action\\Equipment\\Reload"
require "State\\NPC\\Action\\Equipment\\FaceAndPrimaryFire"

StandAndAttack = Create (TargetState, 
{
	sStateName = "StandAndAttack",
	nTargetInfoFlags = eTargetInfoFlags.nVisibilityChecks + eTargetInfoFlags.nPrimaryFireChecks + eTargetInfoFlags.nCombatTargetingChecks,
	nWaitTime = nil,	-- Specify if you want the state to finish after a certain amount of time
})

function StandAndAttack:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)

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

function StandAndAttack:OnEvent (tEvent)

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

function StandAndAttack:OnActiveStateFinished ()
	self:ChangeState (self:CreateNextState ())
	return true
end

function StandAndAttack:CreateNextState ()

	-- Target is right in front of me - punch them
	if self.tTargetInfo:CanCloseAttackTarget () then

		return Create (CloseAttack, {})

	-- Ammo low - reload
	elseif self.tHost:IsCurrentPrimaryEquipmentEquiped () and 
			self.tHost:RetCurrentPrimaryEquipment ():IsAmmoLow () then

		return Create (Reload, {})

	-- Default - stand and shoot
	else
		return Create (FaceAndPrimaryFire, {})

	end
	
end
