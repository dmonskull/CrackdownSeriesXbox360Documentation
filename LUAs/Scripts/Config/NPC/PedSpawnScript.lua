require "State\\NPC\\Character\\Pedestrian"

return function (tPedestrian)

	tPedestrian:SetPersonality (cAIPlayer.Rand (0, 80))
	tPedestrian:SetShootingAccuracy (eShootingAccuracy.nBad)
	tPedestrian:SetTeamSide (tCivilians)
	tPedestrian:SetState (Pedestrian)

end
