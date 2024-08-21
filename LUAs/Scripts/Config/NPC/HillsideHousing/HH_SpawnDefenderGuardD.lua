-----------------------------------------------------------------------
-- Title: Defender Guard  
-- Description: A special type of guard that is used for set piece and hand scripted  
-- scenarios
-- Owner: BillG 
------------------------------------------------------------------------


require "State\\Mission\\HillsideHousing\\DefGuards\\HillsideHousingDefenderGuard"

return function (tNPC)

	tNPC:AddEquipment ("M16") -- When AI can detect weapons better and you can place 
--them better, spawn these guys unarmed, they collect their weapons from the environment 
	tNPC:SetTeamSide (tMuchachos)
	tNPC:SetPersonality (ePersonality.nCowardly)
	tNPC:SetShootingAccuracy (eShootingAccuracy.nBad)
	
	tNPC:SetState (Create (HillsideHousing.HillsideHousingDefenderGuard,
	{
		-- some how give each guard a different spawn point
		-- some how get an event to change the boolean in your 
		-- defenderguard state
							
		nIdleViewingDistance = 010,
		nAlertViewingDistance = 030,
		nRadius = 010, 
		sGroupName = "D",
			
		nDefensiveIdleViewingDistance = 040,
		nDefensiveAlertViewingDistance = 040,
	}))
	
end
