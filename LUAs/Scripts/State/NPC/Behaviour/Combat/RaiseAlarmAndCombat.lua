----------------------------------------------------------------------
-- Name: RaiseAlarmAndCombat State
-- Description: Raise the alarm, then start fighting
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\Behaviour\\Combat\\Combat"
require "State\\NPC\\Behaviour\\Scripted\\RaiseAlarm"

RaiseAlarmAndCombat = Create (Combat,
{
	sStateName = "RaiseAlarmAndCombat",
})

function RaiseAlarmAndCombat:OnEnter ()
	-- Check parameters
	assert (self.tAttackSquadMission)

	-- Call parent
	Combat.OnEnter (self)
end

function RaiseAlarmAndCombat:OnActiveStateFinished ()
	
	if self:IsInState (ArmWithBestWeapon) then

		self:ChangeState (Create (RaiseAlarm, 
		{
			tAttackSquadMission = self.tAttackSquadMission,
		}))
		return true

	elseif self:IsInState (RaiseAlarm) then

		self:ChangeState (self:CreateFightState ())
		return true

	end	

	-- Call parent
	return Combat.OnActiveStateFinished (self)
end
