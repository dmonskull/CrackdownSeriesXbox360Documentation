require "State\\NPC\\Character\\TriggerGuard"

return function (tNPC)

	tNPC:AddEquipment ("SniperRifle")
	tNPC:SetTeamSide (tMuchachos)
	tNPC:SetPersonality (ePersonality.nCowardly)
	tNPC:SetShootingAccuracy (eShootingAccuracy.nBad)
	
	tNPC:SetState (Create (TriggerGuard,
	{
	 	nTriggerNo = 1,
	 	nIdleViewingDistance = 040,
		nAlertViewingDistance = 040,
	}))
	
end
