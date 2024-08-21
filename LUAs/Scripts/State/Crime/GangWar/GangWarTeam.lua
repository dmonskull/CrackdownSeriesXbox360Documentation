----------------------------------------------------------------------
-- Name: GangWarTeam State
--	Description: Combat behaviour for the gang war crime
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\Team\\Character\\GangsterTeam"
require "State\\Crime\\GangWar\\GangWarTeamCombat"
require "State\\NPC\\Character\\StreetSoldier"

namespace ("GangWar")

GangWarTeam = Create (GangsterTeam, 
{
	sStateName = "GangWarTeam",
	bDeleteMembers = true,
})

----------------------------------------------------------------------
-- Attack State - Use specialised combat state 
----------------------------------------------------------------------

function GangWarTeam:CreateAttackState ()
	return Create (GangWarTeamCombat, {})
end

function GangWarTeam:InAttackState ()
	return self:IsInState (GangWarTeamCombat)
end

----------------------------------------------------------------------
-- Return true if any of the gang members are within an activity volume
----------------------------------------------------------------------

function GangWarTeam:IsAnyoneWithinActivityVolume ()

	for i=1, self.tHost:RetNumberOfMembers () do
		if self.tHost:RetMember(i-1):IsInsideAnyActivityVolume () then
			return true
		end
	end
	return false

end

----------------------------------------------------------------------
-- OnExit
----------------------------------------------------------------------

function GangWarTeam:OnExit ()
	-- Call parent
	GangsterTeam.OnExit (self)

	if self.bDeleteMembers then
		
		-- Delete all remaining team members
		while self.tHost:RetNumberOfMembers () > 0 do
			local tGangMember = self.tHost:RetMember (0)
			self.tHost:RemoveEntity (tGangMember)
			AILib.DeleteGameObject (tGangMember)
		end

	else
		
		-- Disperse remaining team members as individual streetsoldiers
		while self.tHost:RetNumberOfMembers () > 0 do
			local tGangMember = self.tHost:RetMember (0)
			self.tHost:RemoveEntity (tGangMember)
			tGangMember:SetState (StreetSoldier)
			tGangMember:SetGameImportance (eGameImportance.nDefault)
		end		

	end
	
end
