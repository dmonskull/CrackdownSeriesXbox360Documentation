-----------------------------------------------------------------------
-- Title: Defender Guard Lookout
-- Description: Lookout Guard
-- scenarios Lighthouse
-- Owner: Steve I 
------------------------------------------------------------------------

require "State\\Mission\\Lighthouse\\BravoGuards\\LighthouseBravoGuards"

return function (tNPC)

	tNPC:AddEquipment ("SMG")
	tNPC:SetTeamSide (tMuchachos)
	tNPC:SetPersonality (ePersonality.nBrave)
	tNPC:SetShootingAccuracy (eShootingAccuracy.nExcellent)
	
	tNPC:SetState (Create (Lighthouse.LHBGuard,
	{
		-- some how give each guard a different spawn point
		-- some how get an event to change the boolean in your 
		-- defenderguard state
							
		nIdleViewingDistance = 050,
		nAlertViewingDistance = 060,
		nRadius = 010, 
		sGroupName = "GuardB",
			
		nDefensiveIdleViewingDistance = 50,
		nDefensiveAlertViewingDistance = 70,
	}))
	
end
