----------------------------------------------------------------------
-- Name: TeamArm State
--	Description: Everyone who has a weapon gets it out
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\Team\\TeamState"
require "State\\NPC\\Action\\Idle\\Idle"
require "State\\NPC\\Behaviour\\Arm\\Arm"

TeamArm = Create (TeamState,
{
	sStateName = "TeamArm",
	nCount = 0,
})

function TeamArm:OnEvent (tEvent)

	for tTeamMember, tTeamMemberEvents in pairs (self.tTeamMembers) do

		if tEvent:HasID (tTeamMemberEvents.nCustomEventID) and tEvent:HasCustomEventID ("StateFinished") then

			if tEvent.tState:IsA (Arm) then

				-- Finished arming
				tTeamMember:SetState (Idle)
				self.nCount = self.nCount + 1

				-- If they have all finished arming then end the state
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

function TeamArm:OnEnterTeamMember (tTeamMember)
	-- Call parent
	TeamState.OnEnterTeamMember (self, tTeamMember)

	-- Subscribe to custom events
	self.tTeamMembers[tTeamMember].nCustomEventID = self:Subscribe (eEventType.AIE_CUSTOM, tTeamMember)

	-- Go into Arm state
	tTeamMember:SetState (Arm)
end

function TeamArm:OnExitTeamMember (tTeamMember)
	-- Unsubscribe from custom events
	self:Unsubscribe (self.tTeamMembers[tTeamMember].nCustomEventID)

	-- Call parent
	TeamState.OnExitTeamMember (self, tTeamMember)
end
