----------------------------------------------------------------------
-- Name: TeamInvestigate State
--	Description: Investigate a suspicious sound
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\Team\\TeamState"
require "State\\NPC\\Behaviour\\Investigate"
require "State\\NPC\\Behaviour\\Listen\\Listen"

TeamInvestigate = Create (TeamState,
{
	sStateName = "TeamInvestigate",
})

function TeamInvestigate:OnEnter ()
	-- Check parameters
	assert (self.vPosition)
	assert (self.tHost:RetNumberOfMembers () > 0)

	-- Send the closest team member off to investigate it
	self.tInvestigator = self.tHost:RetClosestMemberToPosition (self.vPosition)
	self.tInvestigator:SetState (Create (Investigate,
	{
		vPosition = self.vPosition,
		tDefendedObject = self.tDefendedObject,
		vDefendedPosition = self.vDefendedPosition,
		nRadius = self.nRadius,
	}))

	-- Call parent
	TeamState.OnEnter (self)

	--Subscribe events
	self.nCustomEventID = self:Subscribe (eEventType.AIE_CUSTOM, self.tInvestigator)
end

function TeamInvestigate:OnEvent (tEvent)
	
	if tEvent:HasID (self.nCustomEventID) and tEvent:HasCustomEventID ("StateFinished") then

		-- The guy assigned to investigate has finished and found nothing, so end the state
		if tEvent.tState:IsA (Investigate) then
			self:Finish ()
		end
		return true

	elseif tEvent:HasID (self.nTeamMemberRemovedID) then

		-- The investigator was for some reason removed from the team
		if tEvent:RetMember () == self.tInvestigator then
			self:Finish ()
		end

		-- Call parent
		return TeamState.OnEvent (self, tEvent)

	end

	-- Call parent
	return TeamState.OnEvent (self, tEvent)
end

function TeamInvestigate:OnEnterTeamMember (tTeamMember)
	-- Call parent
	TeamState.OnEnterTeamMember (self, tTeamMember)

	-- Set all the other members of the team to stand and listen
	if tTeamMember ~= self.tInvestigator then
		tTeamMember:SetState (Create (Listen,
		{
			vPosition = self.vPosition,
		}))
	end

end
