----------------------------------------------------------------------
-- Name: PreCrime State
--	Description: The gang members stand around waiting for a pedestrian
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\Mission\\MissionState"
require "State\\Crime\\LMAssault\\GangMember"

namespace ("LMAssault")

PreCrime = Create (MissionState,
{
	sStateName = "PreCrime",
})

function PreCrime:OnEnter ()
	-- Call parent
	MissionState.OnEnter (self)

	-- Debugging text
	self.tHost:SetCrimeDebugString ("In PreCrime state")

	-- Set each of the gang members to use the GangMember state
	for i, tGangMember in pairs (self.tParent.atGangMember) do

		tGangMember:SetState (Create (GangMember,
		{
			vTargetPosition = self.tParent.avFacePoints[i],
		}))

	end

end
