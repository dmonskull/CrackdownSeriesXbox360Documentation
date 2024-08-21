require "State\\NPC\\Character\\StreetSoldier"

return function (tEnforcer)

	tEnforcer:AddEquipment ("M16")
	tEnforcer:SetPersonality (cAIPlayer.Rand (0, 100))
	tEnforcer:SetShootingAccuracy (cAIPlayer.Rand (20, 60))
	tEnforcer:SetTeamSide (tAgency)
	tEnforcer:SetState (Create (StreetSoldier,
	{
		bOnSideWalk = true,
	}))

end
