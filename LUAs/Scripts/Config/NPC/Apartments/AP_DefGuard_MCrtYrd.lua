--require "State\\NPC\\Character\\Guard"
require "State\\Mission\\Apartments\\DefGuards\\ApartmentsDefenderGuard"

return function (tNPC)

	tNPC:AddEquipment ("SMG")
	tNPC:AddEquipment ("Grenade") -- When AI can detect weapons better and you can place 
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
		nAlertViewingDistance = 50,
		nRadius = 60, 
		sGroupName = "A",
			
		nDefensiveIdleViewingDistance = 35,
		nDefensiveAlertViewingDistance = 60,
	}))


end