----------------------------------------------------------------------
-- Name: Reset State
--	Description: The gang members walk back to their original positions
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\Mission\\MissionState"
require "State\\Crime\\GangHarassment\\WalkBackToSpawnPoint"

namespace ("GangHarassment")

Reset = Create (MissionState,
{
	sStateName = "Reset",
})

function Reset:OnEnter ()
	-- Call parent
	MissionState.OnEnter (self)

	-- Regenerate spawn positions
	self.tParent:GenerateSpawnPoints (self.tParent:RetNumGangMembers ())

	self.anGangMemberEventID = {}

	-- Tell the gang members to walk back to their spawn points
	for i, tGangMember in pairs (self.tParent.atGangMember) do

		tGangMember:SetState (Create (WalkBackToSpawnPoint,
		{
			vDestination = self.tParent.avSpawnPoints[i],
			vTargetPosition = self.tParent.avFacePoints[i],
		}))

		-- Subscribe events
		self.anGangMemberEventID[i] = self:Subscribe (eEventType.AIE_CUSTOM, tGangMember)

	end

end

function Reset:OnEvent (tEvent)

	for i, nGangMemberEventID in pairs (self.anGangMemberEventID) do

		if tEvent:HasID (nGangMemberEventID) and 
			tEvent:HasCustomEventID ("ReachedSpawnPoint") then
	
			-- Count the gang members who have reached their spawn points
			local n = 0
		
			for j, tGangMember in pairs (self.tParent.atGangMember) do
				if tGangMember:RetState ():HasReachedSpawnPoint () then
					n = n + 1
				end
			end
		
			-- If they have all reached their spawn points then finish the state
			if n == self.tParent:RetNumGangMembers () then
				self:Finish ()
			end
			return true
	
		end

	end
	
	-- Call parent
	return MissionState.OnEvent (self, tEvent)
end
