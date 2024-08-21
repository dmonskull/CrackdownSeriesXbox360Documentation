require "State\\NPC\\Character\\Queue"

return function (tNPC)

--	tNPC:AddEquipment ("Riley_Panther")
	tNPC:SetTeamSide (tCivilians)
	tNPC:SetPersonality (ePersonality.nCowardly)
ss	tNPC:SetShootingAccuracy (eShootingAccuracy.nBad)
	
	tNPC:SetState (Create (Queue,
	{
		
	}))

end
