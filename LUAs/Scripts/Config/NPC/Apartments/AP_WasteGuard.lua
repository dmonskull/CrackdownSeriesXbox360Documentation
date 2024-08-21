require "State\\Mission\\Apartments\\Guards\\ApartmentsWasteGuard"

return function (tNPC)

	tNPC:AddEquipment ("SMG")
	tNPC:AddEquipment ("Grenade")
	
	tNPC:SetTeamSide (tMuchachos)

	-- Randomly set how good this guard is.
	tNPC:SetPersonality (cAIPlayer.Rand (0, 100))
	tNPC:SetShootingAccuracy (cAIPlayer.Rand (20, 60))
	
	tNPC:SetState (Create (Apartments.ApartmentsWasteGuard, 
	{	
		-- Give the guard a default patrol route, however this should get overidden
		-- when the guard is spawned onto a region. 
		-- We have to set tPatrolRouteNames to non nil otherwise it will assert later
		--tPatrolRouteNames = {"Default\\Apartments\\Aprt_EntCrtYrdA_patrol"}, 
	}))

end
