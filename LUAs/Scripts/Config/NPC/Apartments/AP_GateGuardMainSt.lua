require "State\\Mission\\Apartments\\Guards\\ApartmentsStreetGuard"

return function (tNPC)

	tNPC:AddEquipment ("Revolver")
	tNPC:SetTeamSide (tMuchachos)
	tNPC:SetPersonality (ePersonality.nCowardly)
	tNPC:SetShootingAccuracy (eShootingAccuracy.nBad)
	
	tNPC:SetState (Create (Apartments.ApartmentsStreetGuard,
	{
		sTriggerZoneName = "TZ_AP_Gate_zone00",	-- Trigger zone to defend
		nIdleViewingDistance = 020,
		nAlertViewingDistance = 040,
		nRadius = 015,
	}))

end
