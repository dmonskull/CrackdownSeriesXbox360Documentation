require "State\\NPC\\Character\\Guard"

return function (tNPC)

	--tNPC:Speak ("I am a STANDARD GUARD")

	local nDecision = cAIPlayer.Rand (1,3)

	if nDecision == 1 then
		tNPC:AddEquipment ("Shotgun")
	elseif nDecision == 2 then
		tNPC:AddEquipment ("Revolver")		
	elseif nDecision == 3 then
		tNPC:AddEquipment ("SMG")						
	end
	
	tNPC:SetTeamSide (tMuchachos)

	-- Randomly set how good this guard is.
	tNPC:SetPersonality (cAIPlayer.Rand (0, 100))
	tNPC:SetShootingAccuracy (cAIPlayer.Rand (20, 60))
	
	tNPC:SetState (Create (Guard, 
	{
		tAttackSquadMission = MissionManager.RetNamedMission ("SportsComplexAttackSquad"),	

		--nIdleViewingDistance = 015,
		--nAlertViewingDistance = 040,
		--nRadius = 015,
		
		nIdleViewingDistance = 25,
		nAlertViewingDistance = 50,
		nRadius = 50,		
		
		-- Give the guard a default patrol route, however this should get overidden
		-- when the guard is spawned onto a region. 
		-- We have to set tPatrolRouteNames to non nil otherwise it will assert later
		--tPatrolRouteNames = {"Default\\Apartments\\Aprt_EntCrtYrdA_patrol"}, 
	}))

end