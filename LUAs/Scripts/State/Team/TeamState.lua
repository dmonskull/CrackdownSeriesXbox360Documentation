----------------------------------------------------------------------
-- Name: TeamState State
--	Description: Base Team state - Handles a few useful functions common
-- to all team states
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "System\\State"

TeamState = Create (State,
{
	sStateName = "TeamState",
})

function TeamState:OnEnter ()
	-- Call parent
	State.OnEnter (self)

	self.tTeamMembers = {}

	self.nTeamMemberAddedID = self:Subscribe (eEventType.AIE_TEAM_MEMBER_ADDED, self.tHost)
	self.nTeamMemberRemovedID = self:Subscribe (eEventType.AIE_TEAM_MEMBER_REMOVED, self.tHost)

	for i=1, self.tHost:RetNumberOfMembers () do

		local tTeamMember = self.tHost:RetMember (i-1)
		self:OnEnterTeamMember (tTeamMember)

	end
end

function TeamState:OnExit ()
	for i=1, self.tHost:RetNumberOfMembers () do
		
		local tTeamMember = self.tHost:RetMember (i-1)
		self:OnExitTeamMember (tTeamMember)

	end

	-- Call parent
	State.OnExit (self)
end

function TeamState:OnEvent (tEvent)

	if tEvent:HasID (self.nTeamMemberAddedID) then

		if not self.tTeamMembers[tEvent:RetMember ()] then
			self:OnEnterTeamMember (tEvent:RetMember ())
		end
		return true

	elseif tEvent:HasID (self.nTeamMemberRemovedID) then

		if self.tTeamMembers[tEvent:RetMember ()] then
			self:OnExitTeamMember (tEvent:RetMember ())
		end
		return true

	end

	-- Call parent
	return State.OnEvent (self, tEvent)
end

function TeamState:OnEnterTeamMember (tTeamMember)
	self.tTeamMembers[tTeamMember] = {}
end

function TeamState:OnExitTeamMember (tTeamMember)
	self.tTeamMembers[tTeamMember] = nil
end
