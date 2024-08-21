-----------------------------------------------------------------------
-- Title: Defender Guard Lookout
-- Description: Lookout Guard
-- scenarios Lighthouse
-- Owner: Steve I 
------------------------------------------------------------------------

require "State\\Mission\\Lighthouse\\Lookouts\\LighthouseLookouts"

return function (tNPC)

	tNPC:AddEquipment ("SMG")
	tNPC:SetTeamSide (tMuchachos)
	tNPC:SetPersonality (ePersonality.nCowardly)
	tNPC:SetShootingAccuracy (eShootingAccuracy.nExcellent)
	
	tNPC:SetState (Create (Lighthouse.LHLookout,
	{
		-- some how give each guard a different spawn point
		-- some how get an event to change the boolean in your 
		-- defenderguard state
							
		nIdleViewingDistance = 050,
		nAlertViewingDistance = 060,
		nRadius = 010, 
		sGroupName = "C",
			
		nDefensiveIdleViewingDistance = 70,
		nDefensiveAlertViewingDistance = 70,
	}))
	
end
