----------------------------------------------------------------------
-- Name: MoveToAndCloseAttack State
--	Description: This state encapsulates moving up to a target and kicking it up the arse
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"
require "State\\NPC\\Action\\Turn\\MoveToAndFace"
require "State\\NPC\\Action\\Turn\\WaitAndFace"
require "State\\NPC\\Action\\Combat\\CloseAttack"

MoveToAndCloseAttack = Create (TargetState, 
{
	sStateName = "MoveToAndCloseAttack",
	nTargetInfoFlags = eTargetInfoFlags.nVisibilityChecks + eTargetInfoFlags.nCombatTargetingChecks,
	nMovementType = eMovementType.nWalk,
	nMovementPriority = eMovementPriority.nLow,
	nCount = 1,
	nReactionTime = 0.1,
	bSuccess = false,
})

function MoveToAndCloseAttack:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)

	-- If the target is already in range punch it, otherwise move towards it
	if self.tTargetInfo:CanCloseAttackTarget () then
		self:PushState (Create (WaitAndFace, 
		{
			nWaitTime = self.nReactionTime,
		}))
	else
		self:PushState (Create (MoveToAndFace,
		{
			nMovementType = self.nMovementType,
			nMovementPriority = self.nMovementPriority,
		}))
	end

	-- Subscribe events
	self.nCombatTargetFoundID = self:Subscribe (eEventType.AIE_COMBAT_TARGET_FOUND, self.tTargetInfo)

end

function MoveToAndCloseAttack:OnActiveStateFinished ()
	
	local tState = self:RetActiveState ()

	-- Reached last known target position but still unable to punch it - fail
	if tState:IsA (MoveToAndFace) then

		self.bSuccess = false
		self:Finish ()
		return true

	-- Finished reaction time waiting - now attack
	elseif tState:IsA (WaitAndFace) then

		self:ChangeState (Create (CloseAttack, {}))
		return true

	-- Finished attacking - repeat attack for the desired number of times or until it fails
	elseif tState:IsA (CloseAttack) then

		self.nCount = self.nCount - 1

		if tState:Success () and self.nCount > 0 then
			self:ChangeState (Create (CloseAttack, {}))
		else
			self.bSuccess = tState:Success ()
			self:Finish ()
		end
		return true

	end

	-- Call parent
	return TargetState.OnActiveStateFinished (self)
end

function MoveToAndCloseAttack:OnEvent (tEvent)

	-- The object is now in range to be kicked
	if tEvent:HasID (self.nCombatTargetFoundID) then

		if self:IsInState (MoveToAndFace) then
			self:ChangeState (Create (WaitAndFace, 
			{
				nWaitTime = self.nReactionTime,
			}))
		end
		return true

	end

	-- Call parent
	return TargetState.OnEvent (self, tEvent)
end

function MoveToAndCloseAttack:Success ()
	return self.bSuccess
end
