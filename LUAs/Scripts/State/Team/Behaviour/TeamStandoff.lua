----------------------------------------------------------------------
-- Name: TeamStandoff State
--	Description: One team member gets annoyed at someone, while the others
-- watch but look menacing
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\Team\\TeamState"
require "State\\NPC\\Behaviour\\Scripted\\Standoff"
require "State\\NPC\\Action\\Chase\\StayInProximity"

TeamStandoff = Create (TeamState,
{
	sStateName = "TeamStandoff",
	bEscalate = false,
	bStandDown = false,
})

function TeamStandoff:OnEnter ()
	-- Check parameters
	assert (self.tTeamMember)
	assert (self.tTarget)
	assert (self.nAnger)

	self.tTeamMember:SetState (Create (Standoff,
	{
		tTarget = self.tTarget,
		nAnger = self.nAnger,
	}))

	-- Call parent
	TeamState.OnEnter (self)

	--Subscribe events
	self.nCustomEventID = self:Subscribe (eEventType.AIE_CUSTOM, self.tTeamMember)
end

function TeamStandoff:OnEvent (tEvent)
	
	if tEvent:HasID (self.nCustomEventID) and tEvent:HasCustomEventID ("StateFinished") then

		-- Standoff animation has finished
		if tEvent.tState:IsA (Standoff) then
			self.bEscalate = tEvent.tState.bEscalate
			self.bStandDown = tEvent.tState.bStandDown
			self.nAnger = tEvent.tState.nAnger
			self:Finish ()
		end
		return true

	elseif tEvent:HasID (self.nTeamMemberRemovedID) then

		-- The guy doing the standoff animation has been removed from the team
		if tEvent:RetMember () == self.tTeamMember then
			self:Finish ()
		end

		-- Call parent
		return TeamState.OnEvent (self, tEvent)

	end

	-- Call parent
	return TeamState.OnEvent (self, tEvent)
end

function TeamStandoff:OnEnterTeamMember (tTeamMember)
	-- Call parent
	TeamState.OnEnterTeamMember (self, tTeamMember)

	-- The other team members move near the target
	if tTeamMember ~= self.tTeamMember then
		tTeamMember:SetState (Create (StayInProximity,
		{
			tTarget = self.tTarget,
			nMovementType = eMovementType.nWalk,
			nMinDist = 3,
			nMaxDist = 5,
		}))
	end

end

function TeamStandoff:Escalate ()
	return self.bEscalate
end

function TeamStandoff:StandDown ()
	return self.bStandDown
end
