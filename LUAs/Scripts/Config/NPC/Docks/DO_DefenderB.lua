-----------------------------------------------------------------------
-- Title: Defender Guard
-- Description: Defenders for the warehouse section of the docks. 
-- scenarios
-- Owner: Russ
------------------------------------------------------------------------

require "State\\Mission\\Docks\\WarehouseGuards\\DockDefenderGuard"

return function (tNPC)

	tNPC:AddEquipment ("M16")
	tNPC:AddEquipment ("Grenade")
	tNPC:SetTeamSide (tMob)
	tNPC:SetPersonality (ePersonality.nBrave)
	tNPC:SetShootingAccuracy (eShootingAccuracy.nNormal)
	
	tNPC:SetState (Create (Docks.DockDefenderGuard,
	{
		nIdleViewingDistance = 040,
		nAlertViewingDistance = 060,
		nRadius = 040,

		nDefensiveIdleViewingDistance = 50,
		nDefensiveAlertViewingDistance = 70,
		nDefensiveRadius = 40,     

        sGroupName = "B",        
	}))
	
end
