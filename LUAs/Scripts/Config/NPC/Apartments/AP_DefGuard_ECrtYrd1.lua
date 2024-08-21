--require "State\\NPC\\Character\\Guard"
require "State\\Mission\\Apartments\\DefGuards\\ApartmentsDefenderGuard"

return function (tNPC)

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

	tNPC:SetState (Create (Apartments.ApartmentsDefenderGuard,
	{
		-- some how give each guard a different spawn point
		-- some how get an event to change the boolean in your 
		-- defenderguard state
							
		nIdleViewingDistance = 30,
		nAlertViewingDistance = 60,
		nRadius = 60, 
		sGroupName = "B",
			
		nDefensiveIdleViewingDistance = 30,
		nDefensiveAlertViewingDistance = 60,
	}))


end