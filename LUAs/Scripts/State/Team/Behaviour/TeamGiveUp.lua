----------------------------------------------------------------------
-- Name: TeamGiveUp State
--	Description: Play suitable giving up animations
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\Team\\TeamState"
require "State\\NPC\\Behaviour\\Scripted\\GiveUpSearch"
require "State\\NPC\\Action\\Turn\\Face"

TeamGiveUp = Create (TeamState,
{
	sStateName = "TeamGiveUp",
})

function TeamGiveUp:OnEnter ()
	-- Get the team leader to play a give up animation
	self.tLeader = self.tHost:RetLeader ()
	self.tLeader:SetState (GiveUpSearch)

	-- Call parent
	TeamState.OnEnter (self)

	--Subscribe events
	self.nCustomEventID = self:Subscribe (eEventType.AIE_CUSTOM, self.tLeader)
end

function TeamGiveUp:OnEvent (tEvent)
	
	if tEvent:HasID (self.nCustomEventID) and tEvent:HasCustomEventID ("StateFinished") then

		-- Give up Search animation has finished
		if tEvent.tState:IsA (GiveUpSearch) then
			self:Finish ()
		end
		return true

	elseif tEvent:HasID (self.nTeamMemberRemovedID) then

		-- The guy doing the victory animation has been removed from the team
		if tEvent:RetMember () == self.tLeader then
			self:Finish ()
		end

		-- Call parent
		return TeamState.OnEvent (self, tEvent)

	end

	-- Call parent
	return TeamState.OnEvent (self, tEvent)
end

function TeamGiveUp:OnEnterTeamMember (tTeamMember)
	-- Call parent
	TeamState.OnEnterTeamMember (self, tTeamMember)

	-- The other team members face the leader
	if tTeamMember ~= self.tLeader then
		tTeamMember:SetState (Create (Face,
		{
			tTarget = self.tLeader,
		}))
	end

end
