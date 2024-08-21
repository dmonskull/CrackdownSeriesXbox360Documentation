require "State\\Mission\\HillsideHousing\\Guards\\HHHillsideHousingGuard"

return function (tNPC)

	tNPC:AddEquipment ("M16")
	tNPC:SetTeamSide (tMuchachos)
	tNPC:SetPersonality (ePersonality.nCowardly)
	tNPC:SetShootingAccuracy (eShootingAccuracy.nBad)
	
	tNPC:SetState (Create (HillsideHousing.HillsideHousingGuard,
	{
		nIdleViewingDistance = 020,
		nAlertViewingDistance = 040,
		nRadius = 020,
	}))
	
end
