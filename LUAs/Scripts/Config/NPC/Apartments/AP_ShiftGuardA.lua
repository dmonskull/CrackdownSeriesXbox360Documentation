require "State\\Mission\\Apartments\\Guards\\ApartmentsShiftGuard_A"

return function (tNPC)

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
	
	tNPC:SetState (Create (Apartments.ApartmentsShiftGuard_A, 
	{	
		-- Give the guard a default patrol route, however this should get overidden
		-- when the guard is spawned onto a region. 
		-- We have to set tPatrolRouteNames to non nil otherwise it will assert later
		--tPatrolRouteNames = {"Default\\Apartments\\Aprt_EntCrtYrdA_patrol"}, 
	}))

end