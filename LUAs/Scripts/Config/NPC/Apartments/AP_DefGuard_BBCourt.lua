--require "State\\NPC\\Character\\Guard"
require "State\\Mission\\Apartments\\DefGuards\\ApartmentsDefenderGuard"

return function (tNPC)

	tNPC:Speak ("I am a DEF GUARD")

	tNPC:AddEquipment ("M16") -- When AI can detect weapons better and you can place 
--them better, spawn these guys unarmed, they collect their weapons from the environment 
	tNPC:SetTeamSide (tMuchachos)

	-- Randomly set how good this guard is.
	tNPC:SetPersonality (cAIPlayer.Rand (0, 100))
	tNPC:SetShootingAccuracy (cAIPlayer.Rand (20, 60))

	tNPC:SetState (Create (Apartments.ApartmentsDefenderGuard,
	{
		-- some how give each guard a different spawn point
		-- some how get an event to change the boolean in your 
		-- defenderguard state
							
		nIdleViewingDistance = 30,
		nAlertViewingDistance = 60,
		nRadius = 60, 
		sGroupName = "E",
			
		nDefensiveIdleViewingDistance = 30,
		nDefensiveAlertViewingDistance = 60,
	}))


end