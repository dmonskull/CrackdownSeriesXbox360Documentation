----------------------------------------------------------------------
-- Name: TeamFlee State
--	Description: Flee until no one in team has been damaged for specified
-- time period
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\Team\\TeamState"
require "State\\NPC\\Behaviour\\Retreat\\Retreat"

TeamFlee = Create (TeamState,
{
	sStateName = "TeamFlee",
	nTimeout = 20,
})

function TeamFlee:OnEnter ()
	-- Call parent
	TeamState.OnEnter (self)

	self:ResetTimer ()

	-- Subscribe events
	self.nTimerFinishedID = self:Subscribe (eEventType.AIE_TIMER_FINISHED, self.tHost)
end

function TeamFlee:ResetTimer ()
	if self.nTimerID then
		self:DeleteTimer (self.nTimerID)
	end
	self.nTimerID = self:AddTimer (self.nTimeout, false)
end

function TeamFlee:OnEvent (tEvent)

	if tEvent:HasID (self.nTimerFinishedID) and tEvent:HasTimerID (self.nTimerID) then

		self:Finish ()
		return true

	end

	for tTeamMember, tTeamMemberEvents in pairs (self.tTeamMembers) do

		if tEvent:HasID (tTeamMemberEvents.nDamagedID) then

			self:ResetTimer ()
			return true

		end

	end

	-- Call parent
	return TeamState.OnEvent (self, tEvent)

end

function TeamFlee:OnEnterTeamMember (tTeamMember)
	-- Call parent
	TeamState.OnEnterTeamMember (self, tTeamMember)

	-- Subscribe events
	self.tTeamMembers[tTeamMember].nDamagedID = self:Subscribe (eEventType.AIE_DAMAGE_TAKEN, tTeamMember)

	-- Retreat from closest enemy
	local tEnemy = self.tHost:RetClosestEnemyWithStatus (eEnemyStatus.nActive, tTeamMember:RetPosition ())
	if not tEnemy then
		tEnemy = self.tHost:RetClosestEnemyWithStatus (eEnemyStatus.nLost, tTeamMember:RetPosition ())
	end
		
	tTeamMember:SetState (Create (Retreat,
	{
		tTarget = tEnemy,
	}))

end

function TeamFlee:OnExitTeamMember (tTeamMember)
	-- Unsubscribe from custom events
	self:Unsubscribe (self.tTeamMembers[tTeamMember].nDamagedID)

	-- Call parent
	TeamState.OnExitTeamMember (self, tTeamMember)
end

function TeamFlee:IsLocked ()
	-- Team state is locked if any of the individual states are locked
	for tTeamMember in pairs (self.tTeamMembers) do
		if tTeamMember.tCurrentState and 
			tTeamMember.tCurrentState:IsLocked () then
			return true
		end
	end
	return false
end
