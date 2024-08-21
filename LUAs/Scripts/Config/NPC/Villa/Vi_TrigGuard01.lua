require "State\\NPC\\Character\\TriggerGuard"

return function (tNPC)

	tNPC:AddEquipment ("SMG")
	tNPC:SetTeamSide (tMuchachos)
	tNPC:SetPersonality (ePersonality.nCowardly)
	tNPC:SetShootingAccuracy (eShootingAccuracy.nBad)
	
	tNPC:SetState (Create (TriggerGuard,
	{
	 	nTriggerNo = 1,
	 	nIdleViewingDistance = 050,
		nAlertViewingDistance = 100,
	}))
	
end
