require "State\\NPC\\Character\\Guard"

return function (tNPC)

	tNPC:AddEquipment ("SniperRifle")
	tNPC:SetTeamSide (tMuchachos)
	tNPC:SetPersonality (ePersonality.nBrave)
	tNPC:SetShootingAccuracy (eShootingAccuracy.nGood)
	
	tNPC:SetState (Create (Guard,
	{
		nIdleViewingDistance = 100,
		nAlertViewingDistance = 100,
		nRadius = 0,
	}))
end
