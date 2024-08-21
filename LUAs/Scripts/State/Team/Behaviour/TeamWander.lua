----------------------------------------------------------------------
-- Name: TeamWander State
--	Description: Team wanders around randomly, but sticks together
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\Team\\TeamState"
require "State\\NPC\\Behaviour\\Wander\\WanderEx"
require "State\\NPC\\Action\\Follow\\Follow"

TeamWander = Create (TeamState,
{
	sStateName = "TeamWander",
	nAngle = 75,
	nDistance = 0,
})

function TeamWander:OnEnterTeamMember (tTeamMember)
	-- Call parent
	TeamState.OnEnterTeamMember (self, tTeamMember)

	-- Subscribe to custom events
	self.tTeamMembers[tTeamMember].nCustomEventID = self:Subscribe (eEventType.AIE_CUSTOM, tTeamMember)

	if tTeamMember == self.tHost:RetLeader () then

		-- Set the team leader to wander around randomly
		tTeamMember:SetState (WanderEx)

	else
	
		-- Flip angle so followers will be added on alternate sides of the leader
		self.nAngle = - self.nAngle

		-- Increment distance from leader with every other team member
		-- resulting in a V formation with the leader at the apex
		if self.nAngle < 0 then
			self.nDistance = self.nDistance + 2
		end

		-- Set to follow leader
		tTeamMember:SetState (Create (Follow,
		{
			tTarget = self.tHost:RetLeader (),
			nAngle = self.nAngle, 
			nDistance = self.nDistance,
		}))

	end

end

