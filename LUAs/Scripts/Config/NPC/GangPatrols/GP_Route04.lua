require "State\\NPC\\Character\\Guard"

return function (tNPC)

	tNPC:AddEquipment ("M16")
--	MyNPC:AddEquipment ("Grenade")
	tNPC:SetTeamSide (tMuchachos)
	tNPC:SetPersonality (ePersonality.nCowardly)
	tNPC:SetShootingAccuracy (eShootingAccuracy.nBad)

	tNPC:SetState (Create (Guard, 
	{
		tPatrolRouteNames = {"Default\\GangPatrols\\Gang_Route04_patrol"}, 
	}))

end
