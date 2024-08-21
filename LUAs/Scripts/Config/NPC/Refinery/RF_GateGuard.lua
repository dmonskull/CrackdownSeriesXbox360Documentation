require "State\\Mission\\Refinery\\Guards\\RefineryGateGuard"

return function (tNPC)

	tNPC:AddEquipment ("Revolver")
	tNPC:SetTeamSide (tMob)
	tNPC:SetPersonality (ePersonality.nCowardly)
	tNPC:SetShootingAccuracy (eShootingAccuracy.nBad)
	
	tNPC:SetState (Create (Refinery.RefineryGateGuard,
	{
		sTriggerZoneName = "TZ_RF_Zone00",	-- Trigger zone to defend
		nIdleViewingDistance = 020,
		nAlertViewingDistance = 040,
		nRadius = 015,
	}))

end
