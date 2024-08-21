----------------------------------------------------------------------
-- Name: MoveAndShoot State
-- Description: Simple state where the NPC finds a suitable position to
-- fire on the target and then fires his primary weapon
-- Owner: pkg
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"
require "State\\NPC\\Behaviour\\MoveToAttackPosition\\MoveToAttackPosition"
require "State\\NPC\\Action\\Equipment\\PrimaryFire"

MoveAndShoot = Create (TargetState, 
{
	sStateName = "MoveAndShoot",
	nTargetInfoFlags = eTargetInfoFlags.nVisibilityChecks + eTargetInfoFlags.nPrimaryFireChecks,
	nMovementType = eMovementType.nWalk,
	nMovementPriority = eMovementPriority.nLow,
	nRadius = 20,
	bSuccess = false,

	bTargetLost = false,
	bTargetDied = false,
	bTargetUnreachable = false,
})


function MoveAndShoot:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)

	-- Subscribe events
	self.nTargetDiedID = self:Subscribe (eEventType.AIE_TARGET_DIED, self.tTargetInfo)

	-- Get into an attack position
	self:PushState (Create (MoveToAttackPosition,
	{
		nMovementType = self.nMovementType,
		nMovementPriority = self.nMovementPriority,
	}))
end


function MoveAndShoot:OnActiveStateFinished ()
	
	local tState = self:RetActiveState ()

	-- Finished trying to get into position
	if tState:IsA (MoveToAttackPosition) then

		if tState:Success () then
			self:ChangeState (Create (PrimaryFire, {}))
		else
			self.bTargetUnreachable = tState:TargetUnreachable ()
			self.bTargetLost = tState:TargetLost ()
			self:Finish ()
		end
		return true

	-- Finished attacking
	elseif tState:IsA (PrimaryFire) then

		self.bSuccess = tState:Success ()
		self:Finish ()
		return true

	end

	-- Call parent
	return TargetState.OnActiveStateFinished (self)
end


function MoveAndShoot:OnEvent (tEvent)

	if tEvent:HasID (self.nTargetDiedID) then

		self.bTargetDied = true
		self:Finish ()
		return true

	end

	-- Call parent
	return TargetState.OnEvent (self, tEvent)
end


function MoveAndShoot:Success ()
	return self.bSuccess
end


function MoveAndShoot:TargetLost ()
	return self.bTargetLost
end


function MoveAndShoot:TargetDied ()
	return self.bTargetDied
end


function MoveAndShoot:TargetUnreachable ()
	return self.bTargetUnreachable
end
