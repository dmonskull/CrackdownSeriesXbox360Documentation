----------------------------------------------------------------------
-- Name: MoveToAndFace State
-- Description: Move to the target and then turn to face it.
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"
require "State\\NPC\\Action\\Chase\\MoveToTarget"

MoveToAndFace = Create (TargetState, 
{
	sStateName = "MoveToAndFace",
	nMovementType = eMovementType.nRun,
	nMovementPriority = eMovementPriority.nLow,
	bSuccess = false,
})

function MoveToAndFace:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)

	self:PushState (Create (Turn, {}))
end

function MoveToAndFace:OnActiveStateFinished ()

	local tState = self:RetActiveState ()

	if tState:IsA (Turn) then

		self:ChangeState (Create (MoveToTarget,
		{
			nMovementType = self.nMovementType,
			nMovementPriority = self.nMovementPriority,
		}))
		return true

	elseif tState:IsA (MoveToTarget) then

		if self.tTargetInfo:IsFacingTarget () then
			self.bSuccess = tState:Success ()
			self:Finish ()
		else
			self:ChangeState (Create (Turn, {}))
		end
		return true

	end

	-- Call parent
	return TargetState.OnActiveStateFinished (self)
end

function MoveToAndFace:Success ()
	return self.bSuccess
end

