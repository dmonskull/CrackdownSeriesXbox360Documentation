----------------------------------------------------------------------
-- Name: AttackCharacterArmed State
-- Description: Attack a character using the primary weapon
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\Behaviour\\Combat\\ArmedFightState"

AttackCharacterArmed = Create (ArmedFightState,
{
	sStateName = "AttackCharacterArmed",
	bTargetEnteredVehicle = false,
})

function AttackCharacterArmed:OnEnter (tEvent)
	-- Call parent
	ArmedFightState.OnEnter (self)

	-- Subscribe to events
	self.nTargetEnteredVehicle = self:Subscribe (eEventType.AIE_TARGET_ENTERED_VEHICLE, self.tTargetInfo)

	-- Insert some compelling dialogue here
	self.tHost:ShoutEnemyWarningAudio (eVocals.nInsult, "Kill him!", self.tTargetInfo:RetTarget ())
end

function AttackCharacterArmed:OnEvent (tEvent)

	if tEvent:HasID (self.nTargetEnteredVehicle) then

		self:EvaluateConditions ()
		return true

	end

	-- Call parent
	return ArmedFightState.OnEvent (self, tEvent)
end

function AttackCharacterArmed:EvaluateConditions ()

	if self.tTargetInfo:IsTargetInsideVehicle () then

		self.bTargetEnteredVehicle = true
		self:Finish ()
		return true

	end

	-- Call parent
	return ArmedFightState.EvaluateConditions (self)
end

function AttackCharacterArmed:TargetEnteredVehicle ()
	return self.bTargetEnteredVehicle
end
