require "State\\Mission\\Docks\\Guards\\DocksGuard"

return function (tNPC)

	tNPC:AddEquipment ("M16")
	tNPC:AddEquipment ("Grenade")
	tNPC:SetTeamSide (tMob)
	tNPC:SetPersonality (ePersonality.nCowardly)
	tNPC:SetShootingAccuracy (eShootingAccuracy.nBad)
	
	tNPC:SetState (Create (Docks.DocksGuard,
	{
		nIdleViewingDistance = 025,
		nAlertViewingDistance = 050,
		nRadius = 020,
	}))
	
end
