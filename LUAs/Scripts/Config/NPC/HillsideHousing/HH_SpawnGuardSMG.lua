require "State\\Mission\\HillsideHousing\\Guards\\HHHillsideHousingGuard"

return function (tNPC)

	tNPC:AddEquipment ("SMG")
	tNPC:SetTeamSide (tMuchachos)
	tNPC:SetPersonality (ePersonality.nCowardly)
	tNPC:SetShootingAccuracy (eShootingAccuracy.nBad)
	
	tNPC:SetState (Create (HillsideHousing.HillsideHousingGuard,
	{
		nIdleViewingDistance = 015,
		nAlertViewingDistance = 040,
		nRadius = 010,
	}))

end
