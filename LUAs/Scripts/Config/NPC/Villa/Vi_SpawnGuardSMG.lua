require "State\\NPC\\Character\\Guard"

return function (tNPC)

	tNPC:AddEquipment ("SMG")
	tNPC:SetTeamSide (tMuchachos)
	tNPC:SetPersonality (ePersonality.nCowardly)
	tNPC:SetShootingAccuracy (eShootingAccuracy.nBad)
	
	tNPC:SetState (Create (Guard,
	{
		nIdleViewingDistance = 015,
		nRadius = 010,
	}))
end
