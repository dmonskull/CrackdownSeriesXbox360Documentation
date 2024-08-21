-----------------------------------------------------------------------
-- Title: Defender Guard Lookout
-- Description: Lookout Guard
-- scenarios Lighthouse
-- Owner: Steve I 
------------------------------------------------------------------------

require "State\\Mission\\Lighthouse\\FoxtrotGuards\\LighthouseFoxtrotGuards"

return function (tNPC)

	tNPC:AddEquipment ("M16")
	tNPC:SetTeamSide (tMuchachos)
	tNPC:SetPersonality (ePersonality.nBrave)
	tNPC:SetShootingAccuracy (eShootingAccuracy.nExcellent)
	
	tNPC:SetState (Create (Lighthouse.LHFGuard,
	{
		-- some how give each guard a different spawn point
		-- some how get an event to change the boolean in your 
		-- defenderguard state
							
		nIdleViewingDistance = 050,
		nAlertViewingDistance = 060,
		nRadius = 010, 
		sGroupName = "GuardF",
			
		nDefensiveIdleViewingDistance = 50,
		nDefensiveAlertViewingDistance = 70,
	}))
	
end
