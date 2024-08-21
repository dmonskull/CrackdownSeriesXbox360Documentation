require "State\\NPC\\Character\\Guard"

return function (tNPC)

	tNPC:AddEquipment ("SniperRifle")
	tNPC:SetTeamSide (tMuchachos)

	-- Randomly set how good this guard is.
	tNPC:SetPersonality (cAIPlayer.Rand (0, 100))
	tNPC:SetShootingAccuracy (cAIPlayer.Rand (60, 80))
	
	tNPC:SetState (Create (Guard, 
	{
		tAttackSquadMission = MissionManager.RetNamedMission ("SportsComplexAttackSquad"),	

		--nIdleViewingDistance = 015,
		--nAlertViewingDistance = 040,
		--nRadius = 015,
		
		nIdleViewingDistance = 50,
		nAlertViewingDistance = 60,
		nRadius = 50,		
		
		-- Give the guard a default patrol route, however this should get overidden
		-- when the guard is spawned onto a region. 
		-- We have to set tPatrolRouteNames to non nil otherwise it will assert later
		--tPatrolRouteNames = {"Default\\Apartments\\Aprt_EntCrtYrdA_patrol"}, 
	}))

end
