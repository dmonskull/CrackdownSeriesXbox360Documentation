----------------------------------------------------------------------
-- Name: AttackVehicleUnarmed State
-- Description: Attack a vehicle without weapons
-- Owner: pkg
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\Action\\Animation\\TimedBackAway"
require "State\\NPC\\Behaviour\\Combat\\UnarmedFightState"

AttackVehicleUnarmed = Create (UnarmedFightState, 
{
	sStateName = "AttackVehicleUnarmed",
	nTargetInfoFlags = eTargetInfoFlags.nVisibilityChecks,
	bTargetExitedVehicle = false,
})

function AttackVehicleUnarmed:OnEnter ()
	-- Set up parameters
	self.nStrikeTime = cAIPlayer.Rand (2, 8)
	self.nCircleDistance = cAIPlayer.Rand (10, 15)
	self.nMinCircleDistance = 5
	self.nMaxCircleDistance = 20

	-- Call parent
	UnarmedFightState.OnEnter (self)

	-- Subscribe events
	self.nTargetExitedVehicle = self:SubscribeImmediate (eEventType.AIE_TARGET_EXITED_VEHICLE, self.tTargetInfo)

	-- Deep meaningful prose
	self.tHost:ShoutEnemyWarningAudio (eVocals.nInsult, "He's in the car!", self.tTargetInfo:RetTarget ())
end

function AttackVehicleUnarmed:OnEvent (tEvent)

	if tEvent:HasID (self.nTargetExitedVehicle) then

		self:EvaluateConditions ()
		return true

	end

	-- Call parent
	return UnarmedFightState.OnEvent (self, tEvent)
end

function AttackVehicleUnarmed:OnActiveStateFinished ()

	if self:InBackAwayState () then

		self:ChangeState (self:CreateCircleState ())
		return true

	elseif self:InCircleState () then

		self:ChangeState (self:CreateTakeCoverState ())
		return true

	end

	-- Call parent
	return UnarmedFightState.OnActiveStateFinished (self)
end

function AttackVehicleUnarmed:EvaluateConditions ()

	if not self.tTargetInfo:IsTargetInsideVehicle () then

		self.bTargetExitedVehicle = true
		self:Finish ()
		return true

	elseif self:IsBackAwayConditionSatisfied () then

		self:ChangeState (self:CreateBackAwayState ())
		return true

	end

	-- Call parent
	return UnarmedFightState.EvaluateConditions (self)
end

function AttackVehicleUnarmed:IsBackAwayConditionSatisfied ()

	-- If target is getting close then back away so they don't run us over
	if self:IsTargetInProximity (self.nMinProximityCheckID) then

		if self:InCircleState () then
			return true
		end

	end
	return false

end

function AttackVehicleUnarmed:CreateBackAwayState ()
	return Create (TimedBackAway,
	{
		nMovementType = eMovementType.nRun,
		nTimeout = 2,
		nRadius = self.nCircleDistance,
	})
end

function AttackVehicleUnarmed:CreateTakeCoverState ()
	return Create (TakeCover,
	{
		nRadius = 40,	-- Use a bigger radius than the default
	})
end

function AttackVehicleUnarmed:InBackAwayState ()
	return self:IsInState (TimedBackAway)
end

function AttackVehicleUnarmed:TargetExitedVehicle ()
	return self.bTargetExitedVehicle
end
