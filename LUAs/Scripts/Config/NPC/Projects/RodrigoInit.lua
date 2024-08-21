require ("State\\Mission\\Projects\\RodrigoAlvarez")

return function (tRodrigo) 

	tRodrigo:AddEquipment ("Riley_Panther")
	tRodrigo:SetTeamSide (tMuchachos)
	tRodrigo:SetPersonality (ePersonality.nBrave)
	tRodrigo:SetShootingAccuracy (eShootingAccuracy.nExcellent)

	tRodrigo:SetState (Create (RodrigoAlvarez, 
	{
		tPatrolRouteNames = {"Default\\Projects\\Route_PJ_TowerFloor5"}, 
	}))

end
