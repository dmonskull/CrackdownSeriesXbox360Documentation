require "State\\NPC\\Character\\GateGuard"

return function (tNPC)

	tNPC:AddEquipment ("Riley_Panther")
	tNPC:SetTeamSide (tMuchachos)
	tNPC:SetPersonality (ePersonality.nCowardly)
	tNPC:SetShootingAccuracy (eShootingAccuracy.nBad)
	
	tNPC:SetState (Create (GateGuard,
	{
		sTriggerZoneName = "TZ_SC_Gate_zone00",	-- Trigger zone to defend
		nIdleViewingDistance = 015,
		nAlertViewingDistance = 040,
		nRadius = 015,
	}))

end
