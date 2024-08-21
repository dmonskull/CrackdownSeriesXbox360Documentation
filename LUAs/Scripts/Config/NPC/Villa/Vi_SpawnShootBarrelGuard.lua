-----------------------------------------------------------------------
-- Title: Defender Guard  
-- Description: A special type of guard that is used for set piece and hand scripted  
-- scenarios
-- Owner: BillG 
------------------------------------------------------------------------


require "State\\Mission\\Villa\\ScriptedObjects\\VillaSetPieceGuard"

return function (tNPC)

	tNPC:AddEquipment ("SniperRifle") 
	tNPC:SetTeamSide (tMuchachos)
	tNPC:SetPersonality (ePersonality.nBrave)
	tNPC:SetShootingAccuracy (eShootingAccuracy.nGood)
	
	tNPC:SetState (Create (Villa.VillaSetPieceGuard,
	{
		
		nIdleViewingDistance = 100,
		nAlertViewingDistance = 100,		
		nRadius = 2,		
		
	}))
	
end
