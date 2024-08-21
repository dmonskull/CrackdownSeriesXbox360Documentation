-----------------------------------------------------------------------
-- Title: Defender Guard Lookout
-- Description: Lookout Guard
-- scenarios Lighthouse
-- Owner: Steve I 
------------------------------------------------------------------------

require "State\\Mission\\Lighthouse\\DeltaGuards\\LighthouseDeltaGuards"

return function (tNPC)

	tNPC:AddEquipment ("SMG")
	tNPC:SetTeamSide (tMuchachos)
	tNPC:SetPersonality (ePersonality.nBrave)
	tNPC:SetShootingAccuracy (eShootingAccuracy.nExcellent)
	
	tNPC:SetState (Create (Lighthouse.LHDGuard,
	{
		-- some how give each guard a different spawn point
		-- some how get an event to change the boolean in your 
		-- defenderguard state
							
		nIdleViewingDistance = 050,
		nAlertViewingDistance = 060,
		nRadius = 010, 
		sGroupName = "GuardD",
			
		nDefensiveIdleViewingDistance = 50,
		nDefensiveAlertViewingDistance = 70,
	}))
	
end
