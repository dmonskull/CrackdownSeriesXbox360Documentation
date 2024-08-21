----------------------------------------------------------------------
-- Name: TeamPatrol State
--	Description: All team members walk together around a patrol route
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\Team\\TeamState"
require "State\\NPC\\Action\\Follow\\Follow"
require "State\\NPC\\Behaviour\\Patrol"

TeamPatrol = Create (TeamState,
{
	sStateName = "TeamPatrol",
	nAngle = 120,
	nDistance = 0,
})

function TeamPatrol:OnEnterTeamMember (tTeamMember)
	-- Call parent
	TeamState.OnEnterTeamMember (self, tTeamMember)

	if tTeamMember == self.tHost:RetLeader () then

		--Set the leader to patrol along the patrol route
		tTeamMember:SetState (Create (Patrol,
		{
			tPatrolRouteNames = self.tPatrolRouteNames,
			tRegionChange = self.tRegionChange,
		}))

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
	
		-- We are now assumed to be on our patrol route
		tTeamMember:SetGuardObject (self.tHost:RetLeader ())

	end

end

function TeamPatrol:OnExitTeamMember (tTeamMember)
	-- We are now assumed to be off our patrol route
	tTeamMember:SetGuardObject (nil)

	-- Call parent
	TeamState.OnExitTeamMember (self, tTeamMember)
end
