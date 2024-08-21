----------------------------------------------------------------------
-- Name: CloseAttack State
--	Description: Kick or punch the current target
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"

CloseAttack = Create (TargetState, 
{
	sStateName = "CloseAttack",
	nTargetInfoFlags = eTargetInfoFlags.nVisibilityChecks + eTargetInfoFlags.nCombatTargetingChecks,
	bSuccess = false,
})

function CloseAttack:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)

	-- Subscribe to CloseAttack finished event
	self.nCloseAttackFinishedID = self:Subscribe (eEventType.AIE_CLOSE_ATTACK_FINISHED, self.tHost)

	self:OnResume ()
end

function CloseAttack:OnResume ()
	-- Call parent
	TargetState.OnResume (self)

	-- Go into the CloseAttack brain state
	if self.tTargetInfo:CanCloseAttackTarget () then
		self.tHost:CloseAttack ()
	else
		self.bSuccess = false
		self:Finish ()
	end
end

function CloseAttack:OnPause ()
	-- Clean up the brain state
	self.tHost:ClearBrainState ()

	-- Call parent
	TargetState.OnPause (self)
end

function CloseAttack:OnExit ()
	self:OnPause ()

	-- Call parent
	TargetState.OnExit (self)
end

function CloseAttack:OnEvent (tEvent)

	if tEvent:HasID (self.nCloseAttackFinishedID) then
		
		self.bSuccess = tEvent:RetSuccess ()
		self:Finish ()
		return true
		
	end
	
	-- Call parent
	return TargetState.OnEvent (self, tEvent)
end

function CloseAttack:Success ()
	return self.bSuccess
end
