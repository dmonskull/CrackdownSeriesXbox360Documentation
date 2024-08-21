require "State\\Mission\\HillsideHousing\\Guards\\HHHillsideHousingGuard"

return function (tNPC)

	tNPC:AddEquipment ("SniperRifle")
	tNPC:SetTeamSide (tMuchachos)
	tNPC:SetPersonality (ePersonality.nCowardly)
	tNPC:SetShootingAccuracy (eShootingAccuracy.nBad)
	
	tNPC:SetState (Create (HillsideHousing.HillsideHousingGuard,
	{
		nIdleViewingDistance = 040,
		nAlertViewingDistance = 040,
		nRadius = 005,
	}))

end
