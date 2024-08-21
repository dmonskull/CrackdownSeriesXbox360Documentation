----------------------------------------------------------------------
-- Name: TeamDisarm State
--	Description: Everyone who has a weapon puts it away
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\Team\\TeamState"
require "State\\NPC\\Action\\Idle\\Idle"
require "State\\NPC\\Behaviour\\Arm\\Disarm"

TeamDisarm = Create (TeamState,
{
	sStateName = "TeamDisarm",
	nCount = 0,
})

function TeamDisarm:OnEvent (tEvent)

	for tTeamMember, tTeamMemberEvents in pairs (self.tTeamMembers) do

		if tEvent:HasID (tTeamMemberEvents.nCustomEventID) and tEvent:HasCustomEventID ("StateFinished") then

			if tEvent.tState:IsA (Disarm) then

				-- Finished disarming
				tTeamMember:SetState (Idle)
				self.nCount = self.nCount + 1

				-- If they have all finished disarming then end the state
				if self.nCount == self.tHost:RetNumberOfMembers () then
					self:Finish ()
				end

			end
			return true

		end

	end

	-- Call parent
	return TeamState.OnEvent (self, tEvent)
end

function TeamDisarm:OnEnterTeamMember (tTeamMember)
	-- Call parent
	TeamState.OnEnterTeamMember (self, tTeamMember)

	-- Subscribe to custom events
	self.tTeamMembers[tTeamMember].nCustomEventID = self:Subscribe (eEventType.AIE_CUSTOM, tTeamMember)

	-- Go into Arm state
	tTeamMember:SetState (Disarm)
end

function TeamDisarm:OnExitTeamMember (tTeamMember)
	-- Unsubscribe from custom events
	self:Unsubscribe (self.tTeamMembers[tTeamMember].nCustomEventID)

	-- Call parent
	TeamState.OnExitTeamMember (self, tTeamMember)
end
