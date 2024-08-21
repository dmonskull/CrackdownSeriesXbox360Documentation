----------------------------------------------------------------------
-- Name: TeamAlert State
--	Description: A team member is under attack - turn to see who did it
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\Team\\TeamState"
require "State\\NPC\\Behaviour\\Alert\\Alert"

TeamAlert = Create (TeamState,
{
	sStateName = "TeamAlert",
})

function TeamAlert:OnEnter ()
	-- Check parameters
	assert (self.tAttacker)

	-- Call parent
	TeamState.OnEnter (self)
end

function TeamAlert:OnEvent (tEvent)
	
	for tTeamMember, tTeamMemberEvents in pairs (self.tTeamMembers) do

		if tEvent:HasID (tTeamMemberEvents.nCustomEventID) and tEvent:HasCustomEventID ("StateFinished") then

			if tEvent.tState:IsA (Alert) then
	
				if tEvent.tState:AttackerFound () then
					self.tHost:AddEnemy (tEvent.tState.tAttacker, eEnemyStatus.nActive)
				end
	
				self:Finish ()
			end
			return true

		end

	end

	-- Call parent
	return TeamState.OnEvent (self, tEvent)
end

function TeamAlert:OnEnterTeamMember (tTeamMember)
	-- Call parent
	TeamState.OnEnterTeamMember (self, tTeamMember)

	tTeamMember:SetState (Create (Alert,
	{
		tAttacker = self.tAttacker,
		tDefendedObject = self.tDefendedObject,
		vDefendedPosition = self.vDefendedPosition,
		nRadius = self.nRadius,
	}))

	--Subscribe events
	self.tTeamMembers[tTeamMember].nCustomEventID = self:Subscribe (eEventType.AIE_CUSTOM, tTeamMember)
end

function TeamAlert:OnExitTeamMember (tTeamMember)
	-- Unsubscribe from custom events
	self:Unsubscribe (self.tTeamMembers[tTeamMember].nCustomEventID)

	-- Call parent
	TeamState.OnExitTeamMember (self, tTeamMember)
end

function TeamAlert:IsLocked ()
	-- Team state is locked if any of the individual states are locked
	for tTeamMember in pairs (self.tTeamMembers) do
		if tTeamMember.tCurrentState and 
			tTeamMember.tCurrentState:IsLocked () then
			return true
		end
	end
	return false
end
