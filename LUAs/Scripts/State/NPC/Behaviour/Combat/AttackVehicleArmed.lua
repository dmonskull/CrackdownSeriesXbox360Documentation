----------------------------------------------------------------------
-- Name: AttackVehicleArmed State
-- Description: Attack a vehicle using the primary weapon
-- Owner: pkg
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\Behaviour\\Combat\\ArmedFightState"

AttackVehicleArmed = Create (ArmedFightState,
{
	sStateName = "AttackVehicleArmed",
	bTargetExitedVehicle = false,
})

function AttackVehicleArmed:OnEnter (tEvent)
	-- Call parent
	ArmedFightState.OnEnter (self)

	-- Subscribe to events
	self.nTargetExitedVehicle = self:Subscribe (eEventType.AIE_TARGET_EXITED_VEHICLE, self.tTargetInfo)

	-- Insert some compelling dialogue here
	self.tHost:ShoutEnemyWarningAudio (eVocals.nInsult, "He's in the car!", self.tTargetInfo:RetTarget ())
end

function AttackVehicleArmed:OnEvent (tEvent)

	if tEvent:HasID (self.nTargetExitedVehicle) then

		self:EvaluateConditions ()
		return true

	end

	-- Call parent
	return ArmedFightState.OnEvent (self, tEvent)
end

function AttackVehicleArmed:EvaluateConditions ()

	if not self.tTargetInfo:IsTargetInsideVehicle () then

		self.bTargetExitedVehicle = true
		self:Finish ()
		return true

	end

	-- Call parent
	return ArmedFightState.EvaluateConditions (self)
end

function AttackVehicleArmed:CreateAttackState ()
	return Create (Attack, 
	{
		tDefendedObject = self.tDefendedObject,
		vDefendedPosition = self.vDefendedPosition,
		nRadius = self.nRadius,
		bAvoidTarget = true,							-- When finding an attack position don't go 
		bAvoidTargetRadius = cAIPlayer.Rand (8, 12),	-- too close to the target
	})
end

function AttackVehicleArmed:CreateTakeCoverAndWaitState (nWaitTime)
	return Create (TakeCoverAndWait,
	{
		tDefendedObject = self.tDefendedObject,
		vDefendedPosition = self.vDefendedPosition,
		nRadius = self.nRadius or 40,	-- Use a larger radius to find cover in than the default
		nWaitTime = nWaitTime,
	})
end

function AttackVehicleArmed:CreateTakeCoverAndReloadState ()
	return Create (TakeCoverAndReload, 
	{
		tDefendedObject = self.tDefendedObject,
		vDefendedPosition = self.vDefendedPosition,
		nRadius = self.nRadius or 40,	-- Use a larger radius to find cover in than the default
	})
end

function AttackVehicleArmed:TargetExitedVehicle ()
	return self.bTargetExitedVehicle
end
