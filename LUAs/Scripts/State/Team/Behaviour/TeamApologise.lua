----------------------------------------------------------------------
-- Name: TeamApologise State
--	Description: One team member plays an apologising animation
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\Team\\TeamState"
require "State\\NPC\\Behaviour\\Scripted\\Apologise"
require "State\\NPC\\Action\\Turn\\Face"

TeamApologise = Create (TeamState,
{
	sStateName = "TeamApologise",
})

function TeamApologise:OnEnter ()
	-- Check parameters
	assert (self.tTeamMember)
	assert (self.tTarget)

	self.tTeamMember:SetState (Create (Apologise,
	{
		tTarget = self.tTarget,
	}))

	-- Call parent
	TeamState.OnEnter (self)

	--Subscribe events
	self.nCustomEventID = self:Subscribe (eEventType.AIE_CUSTOM, self.tTeamMember)
end

function TeamApologise:OnEvent (tEvent)
	
	if tEvent:HasID (self.nCustomEventID) and tEvent:HasCustomEventID ("StateFinished") then

		-- Apologise animation has finished
		if tEvent.tState:IsA (Apologise) then
			self:Finish ()
		end
		return true

	elseif tEvent:HasID (self.nTeamMemberRemovedID) then

		-- The guy doing the apologise animation has been removed from the team
		if tEvent:RetMember () == self.tTeamMember then
			self:Finish ()
		end

		-- Call parent
		return TeamState.OnEvent (self, tEvent)

	end

	-- Call parent
	return TeamState.OnEvent (self, tEvent)
end

function TeamApologise:OnEnterTeamMember (tTeamMember)
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
