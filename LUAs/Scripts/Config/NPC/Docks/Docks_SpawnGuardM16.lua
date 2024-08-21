require "State\\Mission\\Docks\\Guards\\HHDocksGuard"

return function (tNPC)

	tNPC:AddEquipment ("M16")
	tNPC:AddEquipment ("Grenade")
	tNPC:SetTeamSide (tMuchachos)
	tNPC:SetPersonality (ePersonality.nCowardly)
	tNPC:SetShootingAccuracy (eShootingAccuracy.nBad)
	
	tNPC:SetState (Create (Docks.DocksGuard,
	{
		nIdleViewingDistance = 020,
		nAlertViewingDistance = 040,
		nRadius = 020,
	}))
	
end
