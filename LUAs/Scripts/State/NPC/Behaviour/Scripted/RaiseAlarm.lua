----------------------------------------------------------------------
-- Name: RaiseAlarm State
--	Description: Raise the alarm that sends out an attack squad
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\Action\\Animation\\UpperBodyAnimateAndFace"

RaiseAlarm = Create (UpperBodyAnimateAndFace, 
{
	sStateName = "RaiseAlarm",
})

function RaiseAlarm:OnEnter ()
	-- Set animation
	if self.tHost:IsCurrentPrimaryEquipmentEquiped () and self.tHost:RetCurrentPrimaryEquipment ():RetNumHands () == 2 then
		self.nAnimationID = eUpperBodyAnimationID.nSignalAttack2HandGun
	else
		self.nAnimationID = eUpperBodyAnimationID.nSignalAttack1HandGun
	end

	-- Call parent
	UpperBodyAnimateAndFace.OnEnter (self)

	-- Speak
	self.tHost:ShoutEnemyWarningAudio (eVocals.nInsult, "Raise the alarm!", self.tTargetInfo:RetTarget ())
end

function RaiseAlarm:OnExit ()
	-- Check parameters
	assert (self.tAttackSquadMission)

	-- Raise the alarm
	self.tAttackSquadMission:AddEnemy (self.tTargetInfo:RetTarget ())	

	-- Call parent
	UpperBodyAnimateAndFace.OnExit (self)
end
