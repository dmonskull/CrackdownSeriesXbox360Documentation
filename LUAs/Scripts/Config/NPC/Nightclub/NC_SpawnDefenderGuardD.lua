-----------------------------------------------------------------------
-- Title: Defender Guard  
-- Description: A special type of guard that is used for set piece and hand scripted  
-- scenarios
-- Owner: BillG 
------------------------------------------------------------------------


require "State\\Mission\\Nightclub\\DefGuards\\NClubDefenderGuard"

return function (tNPC)

	tNPC:AddEquipment ("SMG") 
	tNPC:SetTeamSide (tMuchachos)
	tNPC:SetPersonality (ePersonality.nNormal)
	tNPC:SetShootingAccuracy (eShootingAccuracy.nNormal)
	
	tNPC:SetState (Create (Nightclub.NClubDefenderGuard,
	{
		nIdleViewingDistance = 30,
		nAlertViewingDistance = 100,
		nRadius = 010, 
		sGroupName = "D",
			
		nDefensiveIdleViewingDistance = 100,
		nDefensiveAlertViewingDistance = 100,
		nDefensiveRadius = 5,
	}))
	
end
