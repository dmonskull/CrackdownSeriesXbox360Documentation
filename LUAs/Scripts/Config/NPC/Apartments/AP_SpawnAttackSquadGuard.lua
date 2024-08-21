return function (tNPC)

	--AILib.Emit ("***** ATTACKSQUAD GUARD SPAWNED")

	tNPC:AddEquipment ("SMG")
	tNPC:SetTeamSide (tMuchachos)
	tNPC:SetPersonality (ePersonality.nCowardly)
	tNPC:SetShootingAccuracy (eShootingAccuracy.nBad)
	
end
