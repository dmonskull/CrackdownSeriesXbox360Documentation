----------------------------------------------------------------------
-- Name: AttackEnemy State
--	Description: The gang members all attack an enemy, probably the player
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\Mission\\MissionState"
require "State\\Team\\Character\\GangsterTeam"

namespace ("LMAssault")

AttackEnemy = Create (MissionState,
{
	sStateName = "AttackEnemy",
})

function AttackEnemy:OnEnter ()
	-- Call parent
	MissionState.OnEnter (self)

	-- Debugging text
	self.tHost:SetCrimeDebugString ("In AttackEnemy state")

	-- Create a team to handle combat behaviour, using the name of the mission for a team name
	self.tTeam = cTeamManager.CreateTeam (self.tHost:RetName (), tMuchachos, false)

	-- Add all gang members to team
	for i, tGangMember in pairs (self.tParent.atGangMember) do
		self.tTeam:AddEntity (tGangMember)
	end

	-- Let the team take over for the combat behaviour
	self.tTeam:SetState (Create (GangsterTeam, {}))

	-- Subscribe events
	self.nTeamIsIdleEventID = self:Subscribe (eEventType.AIE_IS_IDLE, self.tTeam)

end

function AttackEnemy:OnExit ()
	-- Call parent
	MissionState.OnExit (self)

	-- Destroy the team object
	cTeamManager.DestroyTeam (self.tTeam)
end

function AttackEnemy:OnEvent (tEvent)

	if tEvent:HasID (self.nTeamIsIdleEventID) then

		-- All enemies have been killed or escaped, and the team is reverting to its idle state
		self:Finish ()
		return true

	end

	-- Call parent
	return MissionState.OnEvent (self, tEvent)
end
