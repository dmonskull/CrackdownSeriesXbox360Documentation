require "State\\NPC\\Character\\Traffic"

return function (tDriver) 

	tDriver:SetPersonality (cAIPlayer.Rand (0, 100))
	tDriver:SetShootingAccuracy (eShootingAccuracy.nBad)
	tDriver:SetTeamSide (tCivilians)
	tDriver:SetState (Traffic)

end
