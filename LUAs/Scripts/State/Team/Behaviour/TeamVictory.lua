----------------------------------------------------------------------
-- Name: TeamVictory State
--	Description: Play suitable victory animations
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\Team\\TeamState"
require "State\\NPC\\Behaviour\\Victory\\Victory"
require "State\\NPC\\Action\\Chase\\StayInProximity"

TeamVictory = Create (TeamState,
{
	sStateName = "TeamVictory",
})

function TeamVictory:OnEnter ()

	-- Get the team leader
	self.tLeader = self.tHost:RetLeader ()
	assert (self.tLeader)

	-- Get the enemy whose last known position is closest to the leader
	self.tEnemyCorpse = self.tHost:RetClosestEnemyWithStatus (eEnemyStatus.nDead, self.tLeader:RetPosition ())
	assert (self.tEnemyCorpse)

	self.tLeader:SetState (Create (Victory, 
	{
		tTarget = self.tEnemyCorpse,
	}))

	-- Call parent
	TeamState.OnEnter (self)

	--Subscribe events
	self.nCustomEventID = self:Subscribe (eEventType.AIE_CUSTOM, self.tLeader)

end

function TeamVictory:OnEvent (tEvent)
	
	if tEvent:HasID (self.nCustomEventID) and tEvent:HasCustomEventID ("StateFinished") then

		-- Victory animation has finished
		if tEvent.tState:IsA (Victory) then
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

function TeamVictory:OnEnterTeamMember (tTeamMember)
	-- Call parent
	TeamState.OnEnterTeamMember (self, tTeamMember)

	-- Set all the other team members to the StayInProximity state, which means they will get
	-- within range of the enemy corpse and then stand facing it
	if tTeamMember ~= self.tLeader then
		tTeamMember:SetState (Create (StayInProximity,
		{
			tTarget = self.tEnemyCorpse,
			nMovementType = eMovementType.nWalk,
			nMinDist = 5,
			nMaxDist = 8,
		}))
	end

end
