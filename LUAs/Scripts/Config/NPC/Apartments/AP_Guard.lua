require "State\\NPC\\Character\\Guard"

return function (tNPC)

	tNPC:AddEquipment ("M16")
	tNPC:SetTeamSide (tMuchachos)

	-- Randomly set how good this guard is.
	tNPC:SetPersonality (cAIPlayer.Rand (0, 100))
	tNPC:SetShootingAccuracy (cAIPlayer.Rand (20, 60))
	
	tNPC:SetState (Create (Guard, 
	{
		-- Give the guard a default patrol route, however this should get overidden
		-- when the guard is spawned onto a region. 
		-- We have to set tPatrolRouteNames to non nil otherwise it will assert later
		--tPatrolRouteNames = {"Default\\Apartments\\Aprt_EntCrtYrdA_patrol"}, 
	}))

end
