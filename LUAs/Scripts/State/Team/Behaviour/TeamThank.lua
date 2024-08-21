----------------------------------------------------------------------
-- Name: TeamThank State
--	Description: One team member plays an thanking animation
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\Team\\TeamState"
require "State\\NPC\\Behaviour\\Scripted\\Thank"
require "State\\NPC\\Action\\Turn\\Face"

TeamThank = Create (TeamState,
{
	sStateName = "TeamThank",
})

function TeamThank:OnEnter ()
	-- Check parameters
	assert (self.tTeamMember)
	assert (self.tTarget)

	self.tTeamMember:SetState (Create (Thank,
	{
		tTarget = self.tTarget,
	}))

	-- Call parent
	TeamState.OnEnter (self)

	--Subscribe events
	self.nCustomEventID = self:Subscribe (eEventType.AIE_CUSTOM, self.tTeamMember)
end

function TeamThank:OnEvent (tEvent)
	
	if tEvent:HasID (self.nCustomEventID) and tEvent:HasCustomEventID ("StateFinished") then

		-- Thank animation has finished
		if tEvent.tState:IsA (Thank) then
			self:Finish ()
		end
		return true

	elseif tEvent:HasID (self.nTeamMemberRemovedID) then

		-- The guy doing the thank animation has been removed from the team
		if tEvent:RetMember () == self.tTeamMember then
			self:Finish ()
		end

		-- Call parent
		return TeamState.OnEvent (self, tEvent)

	end

	-- Call parent
	return TeamState.OnEvent (self, tEvent)
end

function TeamThank:OnEnterTeamMember (tTeamMember)
	-- Call parent
	TeamState.OnEnterTeamMember (self, tTeamMember)

	-- The other team members face the target
	if tTeamMember ~= self.tTeamMember then
		tTeamMember:SetState (Create (Face,
		{
			tTarget = self.tTarget,
		}))
	end

end
