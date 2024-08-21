require "State\\NPC\\Character\\Guard"

return function (tNPC)

	tNPC:AddEquipment ("M16")
--	MyNPC:AddEquipment ("Grenade")
	tNPC:SetTeamSide (tMuchachos)
	tNPC:SetPersonality (ePersonality.nNormal)
	tNPC:SetShootingAccuracy (eShootingAccuracy.nNormal)

	tNPC:SetState (Create (Guard, 
	{
		tPatrolRouteNames = {"Default\\Projects\\Route_PJ_TowerBaseRight"}, 
	}))

end
