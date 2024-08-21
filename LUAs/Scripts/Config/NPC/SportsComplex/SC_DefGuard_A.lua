require "State\\Mission\\SportsComplex\\Guards\\SportsComplexDefenderGuard"

return function (tNPC)

	--tNPC:Speak ("I am a DEF GUARD group A")

	tNPC:AddEquipment ("SMG") -- When AI can detect weapons better and you can place 
--them better, spawn these guys unarmed, they collect their weapons from the environment 
	tNPC:SetTeamSide (tMuchachos)

	-- Randomly set how good this guard is.
	tNPC:SetPersonality (cAIPlayer.Rand (0, 100))
	tNPC:SetShootingAccuracy (cAIPlayer.Rand (20, 60))

	tNPC:SetState (Create (SportsComplex.SportsComplexDefenderGuard,
	{
		-- some how give each guard a different spawn point
		-- some how get an event to change the boolean in your 
		-- defenderguard state
							
		nIdleViewingDistance = 20,
		nAlertViewingDistance = 60,
		nRadius = 1000, 
		sGroupName = "A",
			
		nDefensiveIdleViewingDistance = 040,
		nDefensiveAlertViewingDistance = 060,
	}))


end