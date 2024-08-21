----------------------------------------------------------------------
-- Name: TeamWatch State
--	Description: Watch combat taking place
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\Team\\TeamState"
require "State\\NPC\\Behaviour\\Watch\\Watch"

TeamWatch = Create (TeamState,
{
	sStateName = "TeamWatch",
	nTimeout = 10,
})

function TeamWatch:OnEnter ()
	-- Check parameters
	assert (self.tEntity)

	-- Call parent
	TeamState.OnEnter (self)

	self:ResetTimer ()

	-- Subscribe events
	self.nTimerFinishedID = self:Subscribe (eEventType.AIE_TIMER_FINISHED, self.tHost)
end

function TeamWatch:ResetTimer ()
	if self.nTimerID then
		self:DeleteTimer (self.nTimerID)
	end
	self.nTimerID = self:AddTimer (self.nTimeout, false)
end

function TeamWatch:OnEvent (tEvent)

	if tEvent:HasID (self.nTimerFinishedID) and tEvent:HasTimerID (self.nTimerID) then

		self:Finish ()
		return true

	end

	for tTeamMember, tTeamMemberEvents in pairs (self.tTeamMembers) do

		if tEvent:HasID (tTeamMemberEvents.nCorpseAppearedID) then

			self:ResetTimer ()
			return true

		elseif tEvent:HasID (tTeamMemberEvents.nWeaponSoundID) then

			self:ResetTimer ()
			return true

		elseif tEvent:HasID (tTeamMemberEvents.nDangerVocalID) then

			self:ResetTimer ()
			return true

		elseif tEvent:HasID (tTeamMemberEvents.nPainVocalID) then

			self:ResetTimer ()
			return true

		end

	end

	-- Call parent
	return TeamState.OnEvent (self, tEvent)

end

function TeamWatch:OnEnterTeamMember (tTeamMember)
	-- Call parent
	TeamState.OnEnterTeamMember (self, tTeamMember)

	-- Subscribe events
	self.tTeamMembers[tTeamMember].nCorpseAppearedID = self:Subscribe (eEventType.AIE_CORPSE_APPEARED, self.tHost)
	self.tTeamMembers[tTeamMember].nWeaponSoundID = self:Subscribe (eEventType.AIE_WEAPON_SOUND, self.tHost)
	self.tTeamMembers[tTeamMember].nDangerVocalID = self:Subscribe (eEventType.AIE_DANGER_VOCAL, self.tHost)
	self.tTeamMembers[tTeamMember].nPainVocalID = self:Subscribe (eEventType.AIE_PAIN_VOCAL, self.tHost)
		
	tTeamMember:SetState (Create (Watch,
	{
		tEntity = self.tEntity,
	}))

end

function TeamWatch:OnExitTeamMember (tTeamMember)
	-- Unsubscribe from custom events
	self:Unsubscribe (self.tTeamMembers[tTeamMember].nCorpseAppearedID)
	self:Unsubscribe (self.tTeamMembers[tTeamMember].nWeaponSoundID)
	self:Unsubscribe (self.tTeamMembers[tTeamMember].nDangerVocalID)
	self:Unsubscribe (self.tTeamMembers[tTeamMember].nPainVocalID)

	-- Call parent
	TeamState.OnExitTeamMember (self, tTeamMember)
end
