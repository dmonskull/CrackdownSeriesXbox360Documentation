require "State\\Mission\\HillsideHousing\\Guards\\HHHillsideHousingGateGuard"

return function (tNPC)

	tNPC:AddEquipment ("Riley_Panther")
	tNPC:SetTeamSide (tMuchachos)
	tNPC:SetPersonality (ePersonality.nCowardly)
	tNPC:SetShootingAccuracy (eShootingAccuracy.nBad)
	
	tNPC:SetState (Create (HillsideHousing.HillsideHousingGateGuard,
	{
		sTriggerZoneName = "TZ_HH_GateGuardsLower",	-- Trigger zone to defend
		nIdleViewingDistance = 015,
		nAlertViewingDistance = 040,
		nRadius = 015,
	}))

end
