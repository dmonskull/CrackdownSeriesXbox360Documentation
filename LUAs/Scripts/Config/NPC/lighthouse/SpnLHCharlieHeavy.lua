-----------------------------------------------------------------------
-- Title: Defender Guard Lookout
-- Description: Lookout Guard
-- scenarios Lighthouse
-- Owner: Steve I 
------------------------------------------------------------------------

require "State\\Mission\\Lighthouse\\CharlieGuards\\LighthouseCharlieGuards"

return function (tNPC)

	tNPC:AddEquipment ("M16")
	tNPC:AddEquipment ("Grenade")
	tNPC:SetTeamSide (tMuchachos)
	tNPC:SetPersonality (ePersonality.nBrave)
	tNPC:SetShootingAccuracy (eShootingAccuracy.nExcellent)
	
	tNPC:SetState (Create (Lighthouse.LHCGuard,
	{
		-- some how give each guard a different spawn point
		-- some how get an event to change the boolean in your 
		-- defenderguard state
							
		nIdleViewingDistance = 050,
		nAlertViewingDistance = 060,
		nRadius = 010, 
		sGroupName = "HeavyC",
			
		nDefensiveIdleViewingDistance = 50,
		nDefensiveAlertViewingDistance = 70,
	}))
	
end
