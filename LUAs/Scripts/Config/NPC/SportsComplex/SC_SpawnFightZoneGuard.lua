require "State\\Mission\\SportsComplex\\Guards\\SC_AlertGuard"

return function (tNPC)

	--tNPC:Speak ("I am the FIGHT ZONE ALERT GUARD")

	local nDecision = cAIPlayer.Rand (1,2)

	if nDecision == 1 then
		tNPC:AddEquipment ("Shotgun")
	elseif nDecision == 2 then
		tNPC:AddEquipment ("Revolver")					
	end
	
	tNPC:SetTeamSide (tMuchachos)

	-- Randomly set how good this guard is.
	tNPC:SetPersonality (cAIPlayer.Rand (0, 100))
	tNPC:SetShootingAccuracy (cAIPlayer.Rand (20, 60))
	
	tNPC:SetState (Create (SportsComplex.AlertGuard, 
	{
		tAttackSquadMission = MissionManager.RetNamedMission ("SportsComplexAttackSquad"),	

		--nIdleViewingDistance = 015,
		--nAlertViewingDistance = 040,
		--nRadius = 015,
		
		sAlarmPoint = "SP_SC_FightZoneAlert",
		nIdleViewingDistance = 40,
		nAlertViewingDistance = 60,
		nRadius = 50,		
		
		-- Give the guard a default patrol route, however this should get overidden
		-- when the guard is spawned onto a region. 
		-- We have to set tPatrolRouteNames to non nil otherwise it will assert later
		--tPatrolRouteNames = {"Default\\Apartments\\Aprt_EntCrtYrdA_patrol"}, 
	}))
	
end
